//
//  ClanunityCenterVC.m
//  Clanunity
//
//  Created by wangyadong on 2018/2/27.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import "ClanunityCenterVC.h"
#import "ClanunityCenterVCHelper.h"

#import "LoginModule.h"
#import "SendPushTokenAPI.h"
#import "SessionModule.h"
#import "RecentUserCell.h"
#import "MTTSessionEntity.h"
#import "DDMessageModule.h"
#import "MTTDatabaseUtil.h"
#import "ChattingMainViewController.h"
#import "DDUserModule.h"
#import "DDGroupModule.h"
#import "DDAllUserAPI.h"
#import "DDCreateGroupAPI.h"
#import "DDDeleteMemberFromGroupAPI.h"
#import "DDAddMemberToGroupAPI.h"

#import "DDContactsCell.h"
#import "DDFixedGroupAPI.h"
#import "MTTGroupEntity.h"

#import "SelectContactVC.h"
#import "ContactSearchVC.h"
#import "CenterSearchVC.h"
#import "FreshApplyMsgListVC.h"
#import "GetRecentSession.h"
#import "DDUserDetailInfoAPI.h"



#import "MyChatViewController.h"

/**
 页面显示类型

 - SectionTypeMsg: 消息
 - SectionTypeFreinds: 我的好友
 */
typedef NS_ENUM(NSInteger, SectionType) {
    SectionTypeMsg = 0,
    SectionTypeFreinds,
};

@interface ClanunityCenterVC ()<UITableViewDataSource,UITableViewDelegate,SessionModuelDelegate>{
    NSInteger _page;
    NSInteger _pageSize;
    
}
@property(nonatomic,strong)EmptySwiftView *emptyView;

@property(nonatomic,weak) CenterTabHeaderView * headerView;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray * dataArray;

@property(nonatomic,assign)NSInteger fixedCount;
@property(nonatomic,strong)NSMutableDictionary *lastMsgs;


@property(nonatomic,assign)SectionType selectIndex;
@property(nonatomic,strong)NSMutableArray *msgItems;
@property(nonatomic,strong)NSMutableArray<MTTUserEntity*> *friendsItems;


@end

@implementation ClanunityCenterVC

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.headerView.chatRoomView requestForRoom];
    [self.headerView.myGroupView freshRequestForMyGroups];

}
- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    [ChattingMainViewController shareInstance].module.MTTSessionEntity=nil;
}
-(void)loadFriendsItems{
    if (self.friendsItems.count == 0) {
        _page = 1;
        [self loadForListWithType:1];
    }
    
    [self.tableView reloadData];
}

-(void)loadRecentMessageList{
    [self sortItems];
    WeakSelf;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SessionModule instance] getRecentSession:^(NSUInteger count) {
            [weakSelf sortItems];
        }];
    });
    
}

-(void)loadNotificationCenter{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRedPoint) name:@"NewFriendRedPoint" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveLoginFailureNotification:) name:DDNotificationUserLoginFailure object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveLoginNotification:) name:DDNotificationUserLoginSuccess object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveReLoginSuccessNotification) name:CUKey.ReloginSuccess object:nil];
    ////最近联系人置顶或者屏蔽
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:MTTNotificationSessionShieldAndFixed object:nil];
}
-(void)receiveRedPoint{
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _page = 1;
    _pageSize = 10000;
    
    //消息列表
    [SessionModule instance].delegate=self;

    // Do any additional setup after loading the view.
    WeakSelf;
    self.knavigationBar.rightBarBtnItem = [[KNaviBarBtnItem alloc] initWithFrame:CGRectMake(0, 0,44, 44) image:@"addImg" hander:^(id _Nonnull sender) {
        CenterMoreView * alert = [[CenterMoreView alloc] initWithFrame:CGRectMake(0,0,KScreenWidth, KScreenHeight)];
        [weakSelf.view addSubview:alert];
        [alert show];
        [alert setSelectedIndexBlock:^(NSInteger index) {
            NSLog(@"%@",@(index));
            if (index == 1) {
                //建群
                SelectContactVC *vc = [[SelectContactVC alloc] init];
                [vc setCreateGroupSuccess:^(BOOL success) {
                    [weakSelf.headerView.myGroupView freshRequestForMyGroups];
                }];
                [vc setSingleChat:^(MTTUserEntity *user) {
                    [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                        [ChattingMainViewController shareInstance].module.MTTSessionEntity=nil;
                        MTTSessionEntity *session = [[MTTSessionEntity alloc] initWithSessionID:user.objID type:SessionTypeSessionTypeSingle];
                        [session setSessionName:user.nick];
                        [[ChattingMainViewController shareInstance] showChattingContentForSession:session];
                        [weakSelf.navigationController pushViewController:[ChattingMainViewController shareInstance] animated:YES];
                        [ChattingMainViewController shareInstance].knavigationBar.title = user.nick;
                    });
                    
                   
                }];
                KNavigationController *nav = [[KNavigationController alloc] initWithRootViewController:vc];
                [weakSelf presentViewController:nav animated:YES completion:nil];
            }else if (index == 0){
                //邀请好友
                [PLShareGlobalView toShareWithSharetype:nil targetid:@"" shareTitle:@"分享同宗汇" shareUrl:@"http://www.tzhhx.com" shareImgUrl:@"" shareDes:nil shareimg:nil];
                
            }else if (index == 2){
                //添加好友
                ContactSearchVC *search = [[ContactSearchVC alloc] init];
                [weakSelf.navigationController pushViewController:search animated:YES];
            }
        }];
    }];
   
    UIView *centerView = [ClanunityCenterVCHelper makeCenterSearchViewWithBlock:^{
        //搜群或搜好友
        CenterSearchVC *vc = [[CenterSearchVC alloc] init];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
    [self.knavigationBar addSubview:centerView];
    self.selectIndex = SectionTypeMsg;
    [self makeTableView];
    
    self.lastMsgs = [NSMutableDictionary new];
    [self loadNotificationCenter];

    [self loadRecentMessageList];
}
-(void)setSelectIndex:(SectionType)selectIndex{
    _selectIndex = selectIndex;
    if (selectIndex == SectionTypeMsg) {
        [self.tableView.mj_header endRefreshing];
        self.tableView.mj_header.hidden = YES;
    }else{
        self.tableView.mj_header.hidden = NO;

    }
}

#pragma mark - 好友列表
-(void)loadForListWithType:(NSInteger)type{
    WeakSelf;
    [ClanAPI requestForMyFriendListWithPage:_page pageSize:_pageSize result:^(ClanAPIResult * _Nonnull result) {
        [weakSelf.tableView.mj_header endRefreshing];
        if ([result.status isEqualToString:@"200"]) {
            BOOL first = [result.data[@"firstPage"] boolValue];
            NSArray *array = [MTTUserEntity mj_objectArrayWithKeyValuesArray:result.data[@"list"]];
            for (MTTUserEntity *model in array) {
                model.realname = model.remark;
                model.name = model.username;
                model.avatar = model.headimg;
                model.nick = model.remark;
                model.objID = [MTTUserEntity pbUserIdToLocalID:model.teamid];
            }
            if (first) {
                [weakSelf.friendsItems removeAllObjects];
            }
            [weakSelf.friendsItems addObjectsFromArray:array];
            [weakSelf.tableView reloadData];
            
        }else{
        }
        
    }];
}
-(void)kNoticeLogoutSuccess{
    NSLog(@"退出登录");
    [self.headerView.myGroupView clearData];
    [self.msgItems removeAllObjects];
    [self.friendsItems removeAllObjects];
    [self.tableView reloadData];
}
-(void)kNotifiLoginSuccess{
    NSLog(@"登录成功");
    [self.headerView.myGroupView freshRequestForMyGroups];
    [self loadFriendsItems];
    [self loadRecentMessageList];
    [self.headerView.chatRoomView requestForRoom];
}
-(void)makeTableView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, KTopHeight,KScreenWidth,KScreenHeight-KTopHeight-KBottomHeight)    style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
    self.tableView.separatorColor = [UIColor cutLineColor];
    self.tableView.backgroundColor = [UIColor bgGreyColor];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    //ios8
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self.view addSubview:self.tableView];
    self.tableView.contentOffset = CGPointMake(0, 0);
    self.tableView.contentInset = UIEdgeInsetsMake(0,0 ,0 ,0 );
    
    [self.tableView registerClass:[RecentUserCell class] forCellReuseIdentifier:@"MTTRecentUserCellIdentifier"];
    [self.tableView registerClass:[DDContactsCell class] forCellReuseIdentifier:@"DDContactsCell"];
    
    CenterTabHeaderView * header = [ClanunityCenterVCHelper makeCenterTabHeaderView];
    self.headerView = header;
    __block CenterTabHeaderView * weakheader = header;

    WeakSelf;
    [header.chatRoomView.countryRoom setRoomClickedBlock:^{

        [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
        [ClanAPI requestForChatRoomFullWithAreaid:weakheader.chatRoomView.countryRoom.model.areaid result:^(ClanAPIResult * _Nonnull result) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if ([result.status isEqualToString:@"200"]) {
                NSDictionary *dic = (NSDictionary*)result.data;
                BOOL isFull = [dic[@"isFull"] boolValue];
                if (isFull) {
                    [WFHudView showMsg:result.message inView:weakSelf.view];
                }else{
                    ChatroomVC *vc = [[ChatroomVC alloc] init];
                    vc.model = weakheader.chatRoomView.countryRoom.model;
                    NSString * string = [NSString stringWithFormat:@"%@%@&roomId=%@",[ClanAPI H5_chatRoomWebsocket],UserServre.shareService.userModel.username,vc.model.areaid];
                    [vc loadWebURLSring:string];
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }
            }
        }];
        
    }];
    [header.chatRoomView.provinceRoom setRoomClickedBlock:^{
        
        [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
        [ClanAPI requestForChatRoomFullWithAreaid:weakheader.chatRoomView.provinceRoom.model.areaid result:^(ClanAPIResult * _Nonnull result) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if ([result.status isEqualToString:@"200"]) {
                NSDictionary *dic = (NSDictionary*)result.data;
                BOOL isFull = [dic[@"isFull"] boolValue];
                if (isFull) {
                    [WFHudView showMsg:result.message inView:weakSelf.view];
                }else{
                    ChatroomVC *vc = [[ChatroomVC alloc] init];
                    vc.model = weakheader.chatRoomView.provinceRoom.model;
                    NSString * string = [NSString stringWithFormat:@"%@%@&roomId=%@",[ClanAPI H5_chatRoomWebsocket],UserServre.shareService.userModel.username,vc.model.areaid];
                    [vc loadWebURLSring:string];
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }
            }
        }];
  
    }];
    [header.chatRoomView.cityRoom setRoomClickedBlock:^{
        
        [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
        [ClanAPI requestForChatRoomFullWithAreaid:weakheader.chatRoomView.cityRoom.model.areaid result:^(ClanAPIResult * _Nonnull result) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if ([result.status isEqualToString:@"200"]) {
                NSDictionary *dic = (NSDictionary*)result.data;
                BOOL isFull = [dic[@"isFull"] boolValue];
                if (isFull) {
                    [WFHudView showMsg:result.message inView:weakSelf.view];
                }else{
                    ChatroomVC *vc = [[ChatroomVC alloc] init];
                    vc.model = weakheader.chatRoomView.cityRoom.model;
                    NSString * string = [NSString stringWithFormat:@"%@%@&roomId=%@",[ClanAPI H5_chatRoomWebsocket],UserServre.shareService.userModel.username,vc.model.areaid];
                    [vc loadWebURLSring:string];
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }
            }
        }];
  
    }];
    
    [header.myGroupView setGroupCallBack:^(MTTGroupEntity * _Nullable model) {
        if (model.type == 0) {
            NSLog(@"%@,%@",model.name,model.objID);
            MTTSessionEntity *session = [[MTTSessionEntity alloc] initWithSessionID:model.objID type:SessionTypeSessionTypeGroup];
            [session setSessionName:model.name];
             ChattingMainViewController *main = [ChattingMainViewController shareInstance];
            
            [main showChattingContentForSession:session];
            [self.navigationController pushViewController:main animated:YES];
            [ChattingMainViewController shareInstance].knavigationBar.title = model.name;
        
        }else if(model.type == 1){
            //更多
            MyMoreGroupsListVC *vc = [[MyMoreGroupsListVC alloc] init];
            vc.list = weakSelf.headerView.myGroupView.dataArray;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }else{
            SelectContactVC *vc = [[SelectContactVC alloc] init];
            [vc setCreateGroupSuccess:^(BOOL success) {
                NSLog(@"创建群成功");
                [weakSelf.headerView.myGroupView freshRequestForMyGroups];
            }];
            [vc setSingleChat:^(MTTUserEntity *user) {
            
                [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    [ChattingMainViewController shareInstance].module.MTTSessionEntity=nil;
                    MTTSessionEntity *session = [[MTTSessionEntity alloc] initWithSessionID:user.objID type:SessionTypeSessionTypeSingle];
                    [session setSessionName:user.nick];
                    [[ChattingMainViewController shareInstance] showChattingContentForSession:session];
                    [weakSelf.navigationController pushViewController:[ChattingMainViewController shareInstance] animated:YES];
                    [ChattingMainViewController shareInstance].knavigationBar.title = user.nick;
                });
                
            }];
            
            
            KNavigationController *nav = [[KNavigationController alloc] initWithRootViewController:vc];
            [weakSelf presentViewController:nav animated:YES completion:nil];
        }
    }];
    [header.myGroupView freshRequestForMyGroups];
    self.tableView.tableHeaderView = header;
    

    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (weakSelf.selectIndex == SectionTypeFreinds) {
            _page = 1;
            [weakSelf loadForListWithType:SectionTypeFreinds];
        }else{
            
        }
    }];
    self.tableView.mj_header.hidden = YES;
}
#pragma mark - table delegate
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.selectIndex == SectionTypeMsg) {
        return YES;
    }
    return NO;
}
//定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
//修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

#pragma mark 删除 一条消息列表
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectIndex == SectionTypeMsg) {
        NSUInteger row = [indexPath row];
        MTTSessionEntity *session = self.msgItems[row];
        [[SessionModule instance] removeSessionByServer:session];
        [self.msgItems removeObjectAtIndex:row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView reloadData];
        [WFHudView showMsg:@"删除成功" inView:self.view];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.selectIndex == SectionTypeMsg ) {
        if (self.msgItems.count == 0) {
            [self showEmptyView];
        }else{
            [self hiddenEmptyView];
        }
        return self.msgItems.count;
        
    }else if (self.selectIndex == SectionTypeFreinds){
        if (self.friendsItems.count == 0) {
            [self showEmptyView];
        }else{
            [self hiddenEmptyView];
        }
        return self.friendsItems.count+1;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}
#pragma mark header 消息 / 好友
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    static NSString *headerSectionID = @"headerId";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerSectionID];
    if (headerView == nil)
    {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerSectionID];
        CenterTabSessionHeader *header = [ClanunityCenterVCHelper makeSectionHeaderView];
        WeakSelf;
        [header setClickCallBack:^(NSInteger index, BOOL repeatTap) {
            NSLog(@"点击：%@,重复点击：%@",@(index),@(repeatTap));
            if (repeatTap) {
                return ;
            }
            [weakSelf.tableView.mj_header endRefreshing];
            weakSelf.selectIndex = index;
            if (index == 0) {
                [weakSelf.tableView reloadData];
//                [weakSelf loadRecentMessageList];
            }else{
                if (self.friendsItems.count == 0) {
                    [weakSelf.tableView.mj_header endRefreshing];
                    [weakSelf loadFriendsItems];
                }
                [weakSelf.tableView reloadData];
               
            }
        }];
        header.currentIndex = self.selectIndex;
        [headerView addSubview:header];
    }
    
    return headerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.selectIndex == SectionTypeFreinds && indexPath.row == 0) {
        return 44;
    }
    return 70;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.selectIndex == SectionTypeMsg) {
        RecentUserCell* cell = (RecentUserCell*)[tableView dequeueReusableCellWithIdentifier:@"MTTRecentUserCellIdentifier"];
        NSInteger row = [indexPath row];
        UIView *view = [[UIView alloc] initWithFrame:cell.bounds];
        view.backgroundColor=RGB(229, 229, 229);
        MTTSessionEntity *session = self.msgItems[row];
        if(session.isFixedTop){
            [cell setBackgroundColor:RGB(243, 243, 247)];
        }else{
            [cell setBackgroundColor:[UIColor whiteColor]];
        }
        view.backgroundColor=RGB(229, 229, 229);
        cell.selectedBackgroundView=view;
        [cell setShowSession:session];
        [self preLoadMessage:session];
        WeakSelf;
        
        return cell;
        
    }else if (self.selectIndex == SectionTypeFreinds){
        DDContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDContactsCell" ];
        cell.avatar.hidden = NO;
        cell.nameLabel.hidden = NO;
        cell.newfriend.hidden = YES;
        cell.rightArrow.hidden = YES;
        cell.redPoint.hidden = YES;
        cell.gender.hidden = YES;
        if (indexPath.row == 0) {
            cell.newfriend.hidden = NO;
            cell.rightArrow.hidden = NO;
            cell.avatar.hidden = YES;
            cell.nameLabel.hidden = YES;
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            if ([user objectForKey:@"NewFriendRedPoint"] != nil && [[user objectForKey:@"NewFriendRedPoint"] isEqualToString:@"1"] ) {
                cell.redPoint.hidden = NO;
            }
        }else{
            MTTUserEntity *user = [self.friendsItems objectAtIndex:indexPath.row-1];
            [cell setCellContent:[NSString formatImageUrlWith:user.headimg ifThumb:true thumb_W:80] Name:user.realname];
            cell.gender.hidden = NO;
            if (user.gender == 0) {
                cell.gender.image = [UIImage imageNamed:@"gender_woman"];
            }else{
                cell.gender.image = [UIImage imageNamed:@"gender_man"];
            }
        }
       
        return cell;  
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WeakSelf;
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (self.selectIndex == SectionTypeMsg) {
        NSInteger row = [indexPath row];
        MTTSessionEntity *session = self.msgItems[row];
        
        session.unReadMsgCount = 0;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [[ChattingMainViewController shareInstance] showChattingContentForSession:session];
        [self.navigationController pushViewController:[ChattingMainViewController shareInstance] animated:YES];
        [ChattingMainViewController shareInstance].knavigationBar.title=session.name;
    }else{
        if (indexPath.row == 0) {
            FreshApplyMsgListVC *vc = [[FreshApplyMsgListVC alloc] init];
            [vc setFriendFreshList:^{
                [weakSelf loadForListWithType:1];
            }];
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            [user setObject:@"0" forKey:@"NewFriendRedPoint"];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
        
        MTTUserEntity *user = [self.friendsItems objectAtIndex:indexPath.row-1];
        
        StrangerOrFriendVC * strangerOrFriendVC = [[StrangerOrFriendVC alloc] init];
        strangerOrFriendVC.username = user.username;
        
        [strangerOrFriendVC setDeleteFriendBack:^{
            [weakSelf loadForListWithType:1];
        }];
        [self.navigationController pushViewController:strangerOrFriendVC animated:YES];
        
    }
}


-(NSMutableArray*)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArray;
}


#pragma mark - SessionModuelDelegate
/**刷新 消息列表@param session session@param action action*/
-(void)sessionUpdate:(MTTSessionEntity *)session Action:(SessionAction)action
{
    if (session!= nil && ![self.msgItems containsObject:session]) {
        
        [self.msgItems insertObject:session atIndex:0];
    }
    [self sortItems];
    [self.tableView reloadData];
    NSUInteger count = [[SessionModule instance]getAllUnreadMessageCount];
    NSLog(@"%lu",(unsigned long)count);
}

#pragma mark -  SNotification
- (void)n_receiveLoginFailureNotification:(NSNotification*)notification{
    NSLog(@"NOTICEn_receiveLoginFailureNotification");
}
- (void)n_receiveStartLoginNotification:(NSNotification*)notification{
    NSLog(@"NOTICEn_receiveStartLoginNotification");
}
- (void)n_receiveLoginNotification:(NSNotification*)notification{
    NSLog(@"NOTICEn_receiveLoginNotification");
    
    [self.headerView.myGroupView freshRequestForMyGroups];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SessionModule instance] getRecentSession:^(NSUInteger count) {
            
            [self.msgItems removeAllObjects];
            [self.msgItems addObjectsFromArray:[[SessionModule instance] getAllSessions]];
            [self sortItems];
        }];
    });
}
-(void)n_receiveReLoginSuccessNotification{
    NSLog(@"NOTICE:n_receiveReLoginSuccessNotification");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SessionModule instance] getRecentSession:^(NSUInteger count) {
            [self.msgItems removeAllObjects];
            [self.msgItems addObjectsFromArray:[[SessionModule instance] getAllSessions]];
            [self sortItems];
        }];
    });
}

-(void)preLoadMessage:(MTTSessionEntity *)session
{
    [[MTTDatabaseUtil instance] getLastestMessageForSessionID:session.sessionID completion:^(MTTMessageEntity *message, NSError *error) {
        if (message) {
            NSLog(@"-message---》%@",message.username);
            if (message.msgID != session.lastMsgID ) {
                [[DDMessageModule shareInstance] getMessageFromServer:session.lastMsgID currentSession:session count:20 Block:^(NSMutableArray *array, NSError *error) {
                    [[MTTDatabaseUtil instance] insertMessages:array success:^{
                        
                    } failure:^(NSString *errorDescripe) {
                        
                    }];
                }];
            }
        }else{
            if (session.lastMsgID !=0) {
                [[DDMessageModule shareInstance] getMessageFromServer:session.lastMsgID currentSession:session count:20 Block:^(NSMutableArray *array, NSError *error) {
                    [[MTTDatabaseUtil instance] insertMessages:array success:^{
                        
                    } failure:^(NSString *errorDescripe) {
                        
                    }];
                }];
            }
        }
    }];
}
#pragma mark - 给 消息列表排序
-(void)sortItems
{
    [self.msgItems removeAllObjects];
    [self.msgItems addObjectsFromArray:[[SessionModule instance] getAllSessions]];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeInterval" ascending:NO];
    NSSortDescriptor *sortFixed = [[NSSortDescriptor alloc] initWithKey:@"isFixedTop" ascending:NO];
    [self.msgItems sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [self.msgItems sortUsingDescriptors:[NSArray arrayWithObject:sortFixed]];
    [self.tableView reloadData];
   
}

-(void)refreshData{
    [self sortItems];
}

-(NSMutableArray *)msgItems{
    if (!_msgItems) {
        _msgItems = [NSMutableArray arrayWithCapacity:0];
    }
    return _msgItems;
}
-(NSMutableArray<MTTUserEntity *> *)friendsItems{
    if (!_friendsItems) {
        _friendsItems = [NSMutableArray arrayWithCapacity:0];
    }
    return _friendsItems;
}
-(void)showEmptyView{
    if (self.emptyView == nil) {
        self.emptyView = [EmptySwiftView showEmptyViewWithEmptyPicName:@"emptyMsgImg" describe:@"暂无消息"];
        [self.tableView addSubview:self.emptyView];
        [self.tableView bringSubviewToFront:self.emptyView];
        self.emptyView.centerX_sd = KScreenWidth/2.0;
    }
    if (self.selectIndex == SectionTypeMsg) {
        self.emptyView.top_sd = self.headerView.height_sd + 60;
        self.emptyView.describeLabel.text = @"暂无消息";
        self.emptyView.picName = @"emptyMsgImg";
    }else{
        self.emptyView.top_sd = self.headerView.height_sd + 120;
        self.emptyView.describeLabel.text = @"暂无好友，赶快去添加好友吧";
        self.emptyView.picName = @"emptyFrdsimg";
    }
    NSLog(@"%@",self.emptyView);
    self.emptyView.hidden = NO;
}
-(void)hiddenEmptyView{
    if (self.emptyView != nil && self.emptyView.isHidden == NO) {
        self.emptyView.hidden = YES;
    }
}

-(NSMutableDictionary *)lastMsgs{
    if (!_lastMsgs) {
        _lastMsgs = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _lastMsgs;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end



@implementation ListFriendModel


@end
