//
//  ContactSearchVC.m
//  Clanunity
//
//  Created by wangyadong on 2018/3/15.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import "ContactSearchVC.h"
#import "SearchContactCell.h"
#import "SelectContactVC.h"
#import "SearchContactCell.h"
@interface ContactSearchVC ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)SearchContactKeyView *keyView;
@property(nonatomic,strong)SearchTF *searchTf;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray * dataArray;

@property(nonatomic,strong)LewPopupViewAnimationSlide * animation;
@property(nonatomic,strong)msgAlterView * alterV;

@end
//添加好友
@implementation ContactSearchVC

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
    tf.font = [UIFont systemFontOfSize:15];
    tf.textColor = [UIColor textColor1];
    tf.returnKeyType = UIReturnKeySearch;
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    tf.enablesReturnKeyAutomatically = YES;//有内容键盘搜索按钮可点击，无内容不可点击

    tf.placeholder = @"请输入手机号";
    tf.keyboardType = UIKeyboardTypeNumberPad;
    
    tf.delegate = self;
    [tf becomeFirstResponder];
    tf.tintColor = [UIColor theme];
    [view addSubview:tf];
    self.knavigationBar.titleView = view;
    WeakSelf
    self.knavigationBar.rightBarBtnItem = [[KNaviBarBtnItem alloc] initWithFrame:CGRectMake(0, 0, 44, 44) title:@"取消" hander:^(id _Nonnull sender) {
        weakSelf.searchTf.text = @"";
        weakSelf.keyView.name.text = nil;
        weakSelf.tableView.tableHeaderView = nil;
        [weakSelf.dataArray removeAllObjects];
        [weakSelf.tableView reloadData];
        weakSelf.emptylb.hidden = YES;
        weakSelf.emptyImg.hidden = YES;
    }];
    
    self.keyView = [[SearchContactKeyView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 60)];
    [self.keyView setSearchClickedBlock:^(NSString *key) {
        NSLog(@"%@",key);
        [weakSelf requestForSearch];
    }];
}

#pragma mark - tf delegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSMutableString* textString = [NSMutableString stringWithString:textField.text];
    [textString replaceCharactersInRange:range withString:string];
    if (self.tableView.tableHeaderView == nil) {
        self.keyView.name.text = @"";
        self.tableView.tableHeaderView = self.keyView;
    }
    if (range.location > 10) {
        return NO;
    }
    if (textString.length == 0) {
        self.tableView.tableHeaderView = nil;
    }
    self.keyView.name.text = textString;

    
    return YES;
}
-(BOOL)textFieldShouldClear:(UITextField *)textField{
    self.emptylb.hidden = YES;
    self.emptyImg.hidden = YES;
    self.searchTf.text = @"";
    self.keyView.name.text = nil;
    self.tableView.tableHeaderView = nil;
    [self.dataArray removeAllObjects];
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

/**
 搜索
 */
-(void)requestForSearch{
    self.emptylb.hidden = YES;
    self.emptyImg.hidden = YES;
    WeakSelf
    SHOW_HUD
    [ClanAPI requestForSearchFriendWithPhone:[self.searchTf.text trim] result:^(ClanAPIResult * _Nonnull result) {
        HIDDEN_HUD
        if ([result.status isEqualToString:@"200"]) {
            NSLog(@"%@",result.data);
            SearchAddFriendModel *model = [SearchAddFriendModel mj_objectWithKeyValues:result.data];
            //model的status=0可申请，1就是好友
            model.headimg = [NSString formatImageUrlWith:model.headimg ifThumb:true thumb_W:80];

            model.realname =model.nickname;
            [weakSelf.searchTf resignFirstResponder];
            if ([model.id isEqualToString:[UserServre shareService].userModel.id]) {
                
                
                [weakSelf.alterV.btn setTitleColor:[UIColor orangeColor] forState:(UIControlStateNormal)];
                [weakSelf lew_presentPopupView:weakSelf.alterV animation:weakSelf.animation backgroundClickable:true];
                weakSelf.alterV.btnClickBlock = ^{
                };

            }else{
                weakSelf.keyView.name.text = nil;
                weakSelf.tableView.tableHeaderView = nil;
                model.type = 0;
                [weakSelf.dataArray removeAllObjects];
                [weakSelf.dataArray addObject:model];
                [weakSelf.tableView reloadData];
            }
        }else{
            
            weakSelf.emptylb.hidden = NO;
            weakSelf.emptyImg.hidden = NO;
            weakSelf.emptylb.text = result.message;
//            [WFHudView showMsg:result.message inView:weakSelf.view];
            [weakSelf.searchTf resignFirstResponder];
        }
    }];
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
    self.emptylb.hidden = YES;
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
    return 70;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier =@"ID";
    SearchContactCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SearchContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.model = self.dataArray[indexPath.row];;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SearchAddFriendModel *model = self.dataArray[indexPath.row];
    if ([model.id isEqualToString:[UserServre shareService].userModel.id]) {
        // 自己 就去个人中心页面
        [WFHudView showMsg:@"不能添加自己为好友" inView:self.view];
        return;
    }else{
        StrangerOrFriendVC *vc = [[StrangerOrFriendVC alloc] init];
        vc.username = model.username;
        [self.navigationController pushViewController:vc animated:YES];
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
        _alterV = [[msgAlterView alloc]initWithFrame:CGRectMake(0, 0, 251 * kScreenScale, 102 * kScreenScale) parentVC:self dismissAnimation:self.animation title:@"你不能添加自己为好友"];
        _alterV.btnArr = @[@"确定"];
    }
    return _alterV;
}

-(NSMutableArray*)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArray;
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
