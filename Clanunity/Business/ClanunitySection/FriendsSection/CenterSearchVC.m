//
//  CenterSearchVC.m
//  Clanunity
//
//  Created by wangyadong on 2018/3/16.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import "CenterSearchVC.h"
#import "SearchContactCell.h"
#import "SelectContactVC.h"
@interface CenterSearchVC ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)SearchTF *searchTf;
@property(nonatomic,strong)SearchContactKeyView *keyView;

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *contactData;
@property(nonatomic,strong)NSMutableArray *groupData;

@property(nonatomic,strong)LewPopupViewAnimationSlide * animation;
@property(nonatomic,strong)msgAlterView * alterV;
@end

@implementation CenterSearchVC
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [ChattingMainViewController shareInstance].module.MTTSessionEntity=nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeCenterSearch];
    
    [self makeTableView];

    // Do any additional setup after loading the view.
}
-(void)makeCenterSearch{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(50, 0, KScreenWidth-100, 30)];
    view.layer.masksToBounds = YES;
    view.top_sd = KStatusBarHeight + 7;
    view.layer.cornerRadius = view.height_sd/2.0;
    view.backgroundColor = [UIColor whiteColor];
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(10*kScreenScale, 0, 13, 13)];
    img.centerY_sd = view.height_sd/2.0;
    img.image = [UIImage imageNamed:@"sousuo"];
    [view addSubview:img];
    
    SearchTF *tf = [[SearchTF alloc] initWithFrame:CGRectMake(img.right_sd+3, 0, view.width_sd-img.right_sd-3, 30)];
    self.searchTf = tf;
    tf.font = [UIFont systemFontOfSize:14];
    tf.textColor = [UIColor textColor2];
    tf.returnKeyType = UIReturnKeySearch;
    tf.placeholder = @"请输入群名称或好友名称";
    [tf setValue:[UIColor textColor1] forKeyPath:@"_placeholderLabel.textColor"];
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    tf.enablesReturnKeyAutomatically = YES;//有内容键盘搜索按钮可点击，无内容不可点击
    tf.keyboardType = UIKeyboardTypeDefault;
    tf.tintColor = [UIColor theme];
    tf.delegate = self;
    [view addSubview:tf];
    [tf addTarget:self action:@selector(textFieldChanged:) forControlEvents:(UIControlEventEditingChanged)];
    
    self.knavigationBar.titleView = view;
    
    WeakSelf
    self.knavigationBar.rightBarBtnItem = [[KNaviBarBtnItem alloc] initWithFrame:CGRectMake(0, 0, 44, 44) title:@"取消" hander:^(id _Nonnull sender) {
        weakSelf.searchTf.text = nil;
        [weakSelf.groupData removeAllObjects];
        [weakSelf.contactData removeAllObjects];
        weakSelf.keyView.name.text = nil;
        [weakSelf.tableView reloadData];
        weakSelf.tableView.tableHeaderView = nil;

    }];
    
    self.keyView = [[SearchContactKeyView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 60)];
    [self.keyView setSearchClickedBlock:^(NSString *key) {
        NSLog(@"%@",key);
        [weakSelf requestForSearch];
    }];
    
}
#pragma mark - tf delegate
-(void)textFieldChanged:(UITextField *)textField{
    if (self.tableView.tableHeaderView == nil) {
        self.keyView.name.text = @"";
        self.tableView.tableHeaderView = self.keyView;
    }
    
    if (textField.text.length == 0) {
        self.tableView.tableHeaderView = nil;
    }else{
        self.emptyImg.hidden = YES;
        self.emptylb.hidden = YES;
    }
    self.keyView.name.text = textField.text;
}

#pragma mark - tf delegate
//-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//
//    NSMutableString* textString = [NSMutableString stringWithString:textField.text];
//    [textString replaceCharactersInRange:range withString:string];
//    if (self.tableView.tableHeaderView == nil) {
//        self.keyView.name.text = @"";
//        self.tableView.tableHeaderView = self.keyView;
//    }
//    if (range.location > 10) {
//        return NO;
//    }
//    if (textString.length == 0) {
//        self.tableView.tableHeaderView = nil;
//    }
//    self.keyView.name.text = textField.text;
//
//    return YES;
//}
-(BOOL)textFieldShouldClear:(UITextField *)textField{
    self.searchTf.text = @"";
    self.keyView.name.text = nil;
    self.tableView.tableHeaderView = nil;
    [self.groupData removeAllObjects];
    [self.contactData removeAllObjects];
    [self.tableView reloadData];
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField.text.length == 0) {
        return NO;
    }
    [self requestForSearch];
    
    return YES;
}




//-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//
//    return YES;
//}
//-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//
//    NSMutableString* textString = [NSMutableString stringWithString:textField.text];
//    [textString replaceCharactersInRange:range withString:string];
//
//
//    return YES;
//}
//-(BOOL)textFieldShouldClear:(UITextField *)textField{
//    [self.groupData removeAllObjects];
//    [self.contactData removeAllObjects];
//    [self.tableView reloadData];
//    return YES;
//}
//-(BOOL)textFieldShouldReturn:(UITextField *)textField{
//    NSLog(@"%@",textField.text);
//    if (textField.text.length == 0) {
//        return NO;
//    }
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [ClanAPI requestForSearchFriendGroupWithSearchkey:[NSString trimString:textField.text] result:^(ClanAPIResult * _Nonnull result) {
//        [self.contactData removeAllObjects];
//        [self.groupData removeAllObjects];
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//        if ([result.status isEqualToString:@"200"]) {
//            NSArray *group = result.data[@"groups"];
//            NSArray *friends = result.data[@"friends"];
//            group = [MTTGroupEntity mj_objectArrayWithKeyValuesArray:group];
//            friends = [SearchAddFriendModel mj_objectArrayWithKeyValuesArray:friends];
//            [friends enumerateObjectsUsingBlock:^(SearchAddFriendModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                obj.nickname = obj.remark;
//            }];
//            [self.contactData addObjectsFromArray:friends];
//
//            [group enumerateObjectsUsingBlock:^(MTTGroupEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                //头像数组
//                [obj.users enumerateObjectsUsingBlock:^(MTTUserEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    if (obj.headimg.length == 0) {
//                        [[DDUserModule shareInstance] getUserForUserID:[MTTUtil changeOriginalToLocalID:(UInt32)obj.teamid SessionType:1] Block:^(MTTUserEntity *user) {
//                            obj.headimg = user.avatar;
//                        }];
//                    }
//
//                }];
//
//            }];
//            [self.groupData addObjectsFromArray:group];
//            [self.tableView reloadData];
//
//        }else{
//
//        }
//    }];
//
//    [textField resignFirstResponder];
//
//    return YES;
//}

-(void)checkIfNull{
    [self.tableView reloadData];
    if (self.contactData.count > 0 || self.groupData.count > 0){
        self.emptyImg.hidden = YES;
        self.emptylb.hidden = YES;
    }else{
        self.emptyImg.hidden = NO;
        self.emptylb.hidden = NO;
    }
}

-(void)requestForSearch{
    if (_searchTf.text.length == 0) {
        return;
    }
    WeakSelf
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ClanAPI requestForSearchFriendGroupWithSearchkey:[NSString trimString:_searchTf.text] result:^(ClanAPIResult * _Nonnull result) {
        [weakSelf.contactData removeAllObjects];
        [weakSelf.groupData removeAllObjects];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if ([result.status isEqualToString:@"200"]) {
            NSArray *group = result.data[@"groups"];
            NSArray *friends = result.data[@"friends"];
            group = [MTTGroupEntity mj_objectArrayWithKeyValuesArray:group];
            friends = [SearchAddFriendModel mj_objectArrayWithKeyValuesArray:friends];
            [friends enumerateObjectsUsingBlock:^(SearchAddFriendModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.nickname = obj.remark;
            }];
            [weakSelf.contactData addObjectsFromArray:friends];
            
            [group enumerateObjectsUsingBlock:^(MTTGroupEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                //头像数组
                [obj.users enumerateObjectsUsingBlock:^(MTTUserEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.headimg.length == 0) {
                        [[DDUserModule shareInstance] getUserForUserID:[MTTUtil changeOriginalToLocalID:(UInt32)obj.teamid SessionType:1] Block:^(MTTUserEntity *user) {
                            obj.headimg = user.avatar;
                        }];
                    }
                }];
                
            }];
            [weakSelf.groupData addObjectsFromArray:group];
            [weakSelf.tableView reloadData];
            weakSelf.tableView.tableHeaderView = nil;
        }else{
        }
        [weakSelf checkIfNull];
    }];
    
    [_searchTf resignFirstResponder];
}

-(void)makeTableView{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, KTopHeight,KScreenWidth,KScreenHeight-KTopHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor bgGreyColor];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    //ios8
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self.view addSubview:self.tableView];
    
    UIImage *empty = [UIImage imageNamed:@"empty_search"];
    self.emptyImg = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.emptyImg.image = empty;
    self.emptyImg.top_sd = 0;
    self.emptyImg.size_sd = empty.size;
    self.emptyImg.centerX_sd = KScreenWidth/2.0;
    [self.tableView addSubview:self.emptyImg];
    self.emptyImg.hidden = YES;
    self.emptylb = [UILabel labelWithFrame:CGRectMake(0, self.emptyImg.bottom_sd+15, KScreenWidth, 30) text:@"" font:[UIFont systemFontOfSize:14] textColor:[UIColor textColor1] textAlignment:NSTextAlignmentCenter];
    [self.tableView addSubview:self.emptylb];
    self.emptylb.text = @"搜索结果不存在";
    self.emptylb.hidden = YES;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.contactData.count;
    }
    if (section == 1) {
        return self.groupData.count;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0&&self.contactData.count>0) {
        return 40;
    }
    if (section == 1 && self.groupData.count>0) {
        return 40;
    }
    return 0.01;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Header"];
    if (view == nil) {
        view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"Header"];
        UILabel *lb = [UILabel labelWithFrame:CGRectMake(12, 10, 100, 20) text:@"" font:[UIFont systemFontOfSize:15] textColor:[UIColor textColor1] textAlignment:NSTextAlignmentLeft];
        lb.tag = 12306;
        [view.contentView addSubview:lb];
        view.contentView.backgroundColor = [UIColor whiteColor];
        UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 0.5)];
        bottom.backgroundColor = [UIColor cutLineColor];
        [view.contentView addSubview:bottom];
        bottom.bottom_sd = 40;
    }
    UILabel *lb = (UILabel*)[view.contentView viewWithTag:12306];
    if (section == 0&&self.contactData.count>0) {
        lb.text = @"好友";
        return view;
    }
    if (section == 1 && self.groupData.count>0) {
        lb.text = @"群聊";
        return view;
    }
    
    
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0 && self.groupData.count>0) {
        return 5;
    }
    return 0.01;
}
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0 && self.groupData.count>0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 10)];
        view.backgroundColor = [UIColor bgColor5];
        return view;
    }
    return nil;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier =@"ID";
    SearchContactCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SearchContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (indexPath.section == 0) {
        MTTUserEntity * model = self.contactData[indexPath.row];
        cell.name.text = model.remark;
        cell.detial.hidden = YES;
        cell.name.centerY_sd = cell.header.centerY_sd;
        [cell.header removeAllSubviews];
        [cell.header sd_setImageWithURL:[NSURL URLWithString:[NSString formatImageUrlWith:model.headimg ifThumb:true thumb_W:80]] placeholderImage:[UIImage imageNamed:CUKey.kPlaceHead]];
    }
    if (indexPath.section == 1) {
        MTTGroupEntity *model = self.groupData[indexPath.row];
        cell.name.text = model.name;
        cell.detial.text = self.searchTf.text;
        cell.detial.hidden = NO;
        cell.name.top_sd = cell.header.top_sd;
        cell.detial.bottom_sd = cell.header.bottom_sd;
        [cell.header removeAllSubviews];
        NSMutableArray *headers = [NSMutableArray arrayWithCapacity:0];

        [model.users enumerateObjectsUsingBlock:^(MTTUserEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx <=4) {
                [headers addObject: [NSString formatImageUrlWith:obj.headimg ifThumb:true thumb_W:80]];
            }
        }];
        [cell.header setGroupAvatars:headers];
        for (MTTUserEntity *user in model.users) {
            if ([user.realname containsString:self.searchTf.text]) {
                cell.detial.text = [NSString stringWithFormat:@"包含：%@",user.realname];
                break;
            }
        }
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        MTTUserEntity * model = self.contactData[indexPath.row];
        
        NSLog(@"%@,%@",model.name,model.objID);
        MTTSessionEntity *session = [[MTTSessionEntity alloc] initWithSessionID:[MTTUserEntity pbUserIdToLocalID:model.teamid] type:SessionTypeSessionTypeGroup];
        [session setSessionName:model.realname];
        ChattingMainViewController *main = [ChattingMainViewController shareInstance];
        [main showChattingContentForSession:session];
        [self.navigationController pushViewController:main animated:YES];
        [ChattingMainViewController shareInstance].knavigationBar.title = model.realname;

    }else{
        MTTGroupEntity *model = self.groupData[indexPath.row];
        MTTSessionEntity *session = [[MTTSessionEntity alloc] initWithSessionID:[MTTGroupEntity pbGroupIdToLocalID:model.id] type:SessionTypeSessionTypeGroup];
        [session setSessionName:model.name];
        ChattingMainViewController *main = [ChattingMainViewController shareInstance];
        
        [main showChattingContentForSession:session];
        [self.navigationController pushViewController:main animated:YES];
        [ChattingMainViewController shareInstance].knavigationBar.title = model.name;
    }
    
    
    
    
    
}

//TODO:懒加载
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

-(NSMutableArray*)contactData{
    if (!_contactData) {
        _contactData = [NSMutableArray arrayWithCapacity:0];
    }
    return _contactData;
}
-(NSMutableArray*)groupData{
    if (!_groupData) {
        _groupData = [NSMutableArray arrayWithCapacity:0];
    }
    return _groupData;
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
