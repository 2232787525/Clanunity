//选择成员页面
//  SelectedUserVC.m
//  Clanunity
//
//  Created by wangyadong on 2018/3/30.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import "SelectedUserVC.h"
#import "SelectContactCell.h"
#import "DDAddMemberToGroupAPI.h"
#import "DDDeleteMemberFromGroupAPI.h"
#import "MTTDatabaseUtil.h"
@interface SelectedUserVC ()
<UITableViewDataSource,UITableViewDelegate>{
    NSInteger _page;
    NSInteger _pageSize;
}
@property(nonatomic,strong)UITableView *tableView;

/**
 用于显示table数据的数组
 */
@property(nonatomic,strong)NSMutableArray * dataArray;


@property(nonatomic,strong)NSMutableDictionary * selectedKeyValues;
/**
 原始key-value数据,model.objID作为key
 */
@property(nonatomic,strong)NSDictionary * groupKeyValues;

@property(nonatomic,strong)LewPopupViewAnimationSlide * animation;
@property(nonatomic,strong)msgAlterView * alterV;



@end

@implementation SelectedUserVC

-(NSMutableDictionary *)selectedKeyValues{
    if (_selectedKeyValues == nil) {
        _selectedKeyValues = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _selectedKeyValues;
}


-(void)setGroupArray:(NSArray<MTTUserEntity *> *)groupArray{
    _groupArray = groupArray;
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithCapacity:0];
    for (MTTUserEntity *obj in groupArray) {
        [tempDic setObject:obj forKey:obj.objID];
    }
    self.groupKeyValues = tempDic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    WeakSelf;
    self.knavigationBar.rightBarBtnItem = [[KNaviBarBtnItem alloc] initWithFrame:CGRectMake(0, 0, 44, 44) title:@"确定" hander:^(id _Nonnull sender) {
        
        if (weakSelf.selectedKeyValues.allValues.count == 0) {
            [WFHudView showMsg:@"请选择联系人" inView:weakSelf.view];
            return;
        }
        [weakSelf showAlertCreateGroup];
    }];
    
    
    [self makeTableView];
    //如果是删除的话就不请求所有人
    if (self.type == 33) {
        self.knavigationBar.title = @"选择群成员";
        for (MTTUserEntity *model in self.groupArray) {
            model.selected = 0;
            
            if ([UserServre shareService].userModel.teamid == model.teamid) {
                model.selected = 2;//群主自己不能删除自己
            }
        }
        [self.dataArray addObjectsFromArray:self.groupArray];
    }else{
        self.knavigationBar.title = @"选择联系人";
        _page = 1;
        _pageSize = 10000;
        //如果是添加好友那么久需要请求好友列表
        [self loadMyFriend];
    }
    // Do any additional setup after loading the view.
}
-(void)showAlertCreateGroup{
    // 1.创建UIAlertController
    WeakSelf;
    if (weakSelf.type == 11) {
        [weakSelf addTTGroupMenmbers];
    }else{
        [self.alterV.btn setTitleColor:[UIColor orangeColor] forState:(UIControlStateNormal)];
        [self lew_presentPopupView:self.alterV animation:self.animation backgroundClickable:true];
        self.alterV.btnClickBlock = ^{
            [weakSelf deleteTTGroupMembers];
        };
    }
}

-(void)addTTGroupMenmbers{
    NSLog(@"%@",[self.selectedKeyValues allKeys]);
    if( TheRuntime.loginSuccess == NO){
        [WFHudView showMsg:@"暂无服务，请重新登录" inView:self.view];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    DDAddMemberToGroupAPI *addMember = [[DDAddMemberToGroupAPI alloc] init];
    WeakSelf;
    [addMember requestWithObject:@[self.groupid,self.selectedKeyValues.allKeys] Completion:^(NSMutableArray * response, NSError *error) {
        
        if (response != nil) {
            if (weakSelf.resultBlock) {
                NSArray *addMembers = weakSelf.selectedKeyValues.allValues;
                weakSelf.resultBlock(YES, addMembers);
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                [weakSelf.tableView reloadData];
                [weakSelf.selectedKeyValues removeAllObjects];
                [weakSelf kBackBtnAction];
            });
        }else{
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
            [WFHudView showMsg:@"邀请失败" inView:weakSelf.view];
        }
    }];
}
-(void)deleteTTGroupMembers{
    
    if( TheRuntime.loginSuccess == NO){
        [WFHudView showMsg:@"暂无服务，请重新登录" inView:self.view];
        return;
    }
    
    DDDeleteMemberFromGroupAPI* deleteMemberAPI = [[DDDeleteMemberFromGroupAPI alloc] init];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WeakSelf;
    [deleteMemberAPI requestWithObject:@[self.groupid,self.selectedKeyValues.allKeys] Completion:^(MTTGroupEntity *response, NSError *error) {
        if (error) {
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
            [WFHudView showMsg:@"删除失败" inView:weakSelf.view];
            return ;
        }
        if (response != nil) {
            //删除成功
            for (MTTUserEntity *item in weakSelf.selectedKeyValues.allValues) {
                if ([weakSelf.dataArray containsObject:item]) {
                    [weakSelf.dataArray removeObject:item];
                }
            }
            if (weakSelf.resultBlock) {
                NSArray *deletedArray = self.selectedKeyValues.allValues;
                weakSelf.resultBlock(NO, deletedArray);
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
                [weakSelf.tableView reloadData];
                [weakSelf.selectedKeyValues removeAllObjects];
                [weakSelf kBackBtnAction];
            });
            //更新数据库
            [[MTTDatabaseUtil instance] updateRecentGroup:response completion:^(NSError *error) {
            }];
 
        }
    }];
    
}


-(void)makeTableView{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, KTopHeight,KScreenWidth,KScreenHeight-KTopHeight) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor whiteColor];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    //ios8
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    self.tableView.mj_footer.hidden = YES;
    [self.view addSubview:self.tableView];
}

/**
 新增的时候才会请求所有好友
 */
-(void)loadMyFriend{
    
    WeakSelf;
    [ClanAPI requestForMyFriendListWithPage:_page pageSize:_pageSize result:^(ClanAPIResult * _Nonnull result) {
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView.mj_footer endRefreshing];
        if ([result.status isEqualToString:@"200"]) {
            BOOL first = [result.data[@"firstPage"] boolValue];
            BOOL last = [result.data[@"lastPage"] boolValue];
            NSArray *array = [MTTUserEntity mj_objectArrayWithKeyValuesArray:result.data[@"list"]];
            NSMutableArray *pageData = [NSMutableArray arrayWithCapacity:0];
            for (MTTUserEntity *model in array) {
                model.name = model.username;
                model.avatar = model.headimg;
                model.nick = model.remark;
                model.objID = [MTTUserEntity pbUserIdToLocalID:model.teamid];
                
                MTTUserEntity *data = [[MTTUserEntity alloc] init];
                data.headimg = model.headimg;
                data.nickname = model.nick;
                data.realname = model.nick;
                data.id = model.id;
                data.objID = model.objID;
                data.selected = 0;
                //本身已经存在的数据已选，不可删除
                if ([weakSelf.groupKeyValues objectForKey:data.objID]) {
                    data.selected = 2;
                }
                
                [pageData addObject:data];
            }
            if (first) {
                [weakSelf.dataArray removeAllObjects];
            }
            [weakSelf.dataArray addObjectsFromArray:pageData];
            [weakSelf.tableView reloadData];
            if (last) {
                weakSelf.tableView.mj_footer.hidden = YES;
            }else{
                weakSelf.tableView.mj_footer.hidden = NO;
            }
        }else{
            _page = _page -1;
        }
        
    }];
    
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
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
    return 55;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier =@"SelectContactCell";
    SelectContactCell*cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SelectContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    SelectContactCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (self.type == 11) {//新增
        
        if (self.groupKeyValues[cell.model.objID] != nil ||cell.model.selected == 2) {
            return;//不可删除/新增
        }
        if (cell.model.selected == 0) {
            cell.model.selected = 1;
        }else{
            cell.model.selected = 0;
        }
        if (cell.model.selected == 1) {
            [self.selectedKeyValues setObject:cell.model forKey:cell.model.objID]; //选中
        }else{
            if ([self.selectedKeyValues objectForKey:cell.model.objID]) {
                [self.selectedKeyValues removeObjectForKey:cell.model.objID];//删除
            }
        }
    }
    if (self.type == 33) {//删除-->选中的就是要删除的
        if (cell.model.selected == 2) {
            return;//群主自己不可删除不可加入
        }
        if (cell.model.selected == 0) {
            cell.model.selected = 1;
        }else{
            cell.model.selected = 0;
        }
        if (cell.model.selected == 1) {
            [self.selectedKeyValues setObject:cell.model forKey:cell.model.objID]; //选中
        }else{
            //取消选中
            if ([self.selectedKeyValues objectForKey:cell.model.objID]) {
                [self.selectedKeyValues removeObjectForKey:cell.model.objID];//删除
            }
        }
    }
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}
-(NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArray;
}

//TODO:弹窗懒加载
-(LewPopupViewAnimationSlide *)animation{
    if (_animation==nil){
        _animation = [[LewPopupViewAnimationSlide alloc]init];
        _animation.type = LewPopupViewAnimationSlideTypeBottomBottom;
    }
    return _animation;
}

-(msgAlterView *)alterV{
    if (_alterV == nil){
        _alterV = [[msgAlterView alloc]initWithFrame:CGRectMake(0, 0, 251 * kScreenScale, 142 * kScreenScale) parentVC:self dismissAnimation:self.animation title:@"是否确定删除该群成员"];
    }
    return _alterV;
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
