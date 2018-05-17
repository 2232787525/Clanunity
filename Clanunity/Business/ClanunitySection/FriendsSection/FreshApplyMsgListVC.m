//
//  FreshApplyMsgListVC.m
//  Clanunity
//
//  Created by wangyadong on 2018/3/16.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import "FreshApplyMsgListVC.h"

@interface FreshApplyMsgListVC ()<UITableViewDataSource,UITableViewDelegate>{
    NSInteger _page;
    NSInteger _pageSize;
}
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray * dataArray;


@end

@implementation FreshApplyMsgListVC

-(void)viewWillAppear:(BOOL)animated{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.knavigationBar.title = @"新朋友";
    _pageSize = 15;
    _page = 0;
    [self makeTableView];
    [self.tableView reloadData];
    WeakSelf;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [weakSelf requestForList];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page = _page + 1;
        [weakSelf requestForList];
    }];
    self.tableView.mj_footer.hidden = YES;
    [self.tableView.mj_header beginRefreshing];

    // Do any additional setup after loading the view.
}

-(void)requestForList{
    WeakSelf;
    [ClanAPI requestForFriendsApplyListWithPage:_page pageSize:_pageSize result:^(ClanAPIResult * _Nonnull result) {
        [weakSelf.tableView.mj_footer endRefreshing];
        [weakSelf.tableView.mj_header endRefreshing];
        if ([result.status isEqualToString:@"200"]) {
            BOOL lastPage = [result.data[@"lastPage"] boolValue];
            if (lastPage) {
                weakSelf.tableView.mj_footer.hidden = YES;
            }else{
                weakSelf.tableView.mj_footer.hidden = NO;
            }
            NSArray *list = result.data[@"list"];
            list = [FreshApplyModel mj_objectArrayWithKeyValuesArray:list];
            if ([result.data[@"firstPage"] boolValue]) {
                [weakSelf.dataArray removeAllObjects];
            }
            [weakSelf.dataArray addObjectsFromArray:list];
            [weakSelf.tableView reloadData];
            
        }else{
            _page = _page - 1;
            [WFHudView showMsg:result.message inView:weakSelf.view];
        }
    }];
    
}

-(void)makeTableView{
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, KTopHeight,KScreenWidth,KScreenHeight-KTopHeight)  style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    //ios8
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self.view addSubview:self.tableView];
    
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
//修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

//点击删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //在这里实现删除操作
    FreshApplyModel *model = self.dataArray[indexPath.row];
    WeakSelf;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ClanAPI requestForFriendsUpdateAppleStatusWithUserid:model.id status:2 result:^(ClanAPIResult * _Nonnull result) {
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        if  ([result.status isEqualToString:@"200"]){
            //删除数据，和删除动画
            [self.dataArray removeObject:model];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        }else{
            [WFHudView showMsg:result.message inView:weakSelf.view];
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
    return 60;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"FreshApplyCell";
     FreshApplyCell*cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[FreshApplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.model = self.dataArray[indexPath.row];
    WeakSelf;
    [cell setAcceptApplyBlock:^(FreshApplyModel *model, FreshApplyCell *cell) {
       
     [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
        [ClanAPI requestForFriendsUpdateAppleStatusWithUserid:model.id status:1 result:^(ClanAPIResult * _Nonnull result) {
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
            if  ([result.status isEqualToString:@"200"]){
                model.status = 1;
                [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[tableView indexPathForCell:cell]] withRowAnimation:(UITableViewRowAnimationFade)];
                if (weakSelf.friendFreshList) {
                    MTTUserEntity *user = [[MTTUserEntity alloc] initWithUserID:[MTTUserEntity pbUserIdToLocalID:model.teamid] name:model.nickname nick:model.nickname avatar:model.headimg userRole:0 userUpdated:0];
                    [[DDUserModule shareInstance]addMaintanceUser:user];
                    weakSelf.friendFreshList();
                }
            }else{
                [WFHudView showMsg:result.message inView:weakSelf.view];
            }
        }];
        
    }];
    
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FreshApplyModel *model = self.dataArray[indexPath.row];

    if ([model.id isEqualToString:[UserServre shareService].userModel.id]) {
        MyInfoVC *vc = [[MyInfoVC alloc] init];
        vc.username = model.username;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        StrangerOrFriendVC *vc = [[StrangerOrFriendVC alloc] init];
        vc.username = model.username;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
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



@implementation FreshApplyCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.header = [[UIImageView alloc] initWithFrame:CGRectMake(12, 10, 40, 40)];
        [self.contentView addSubview:self.header];
        self.name = [UILabel labelWithFrame:CGRectMake(self.header.right_sd+5, self.header.top_sd, KScreenWidth-90, 25) text:@"" font:[UIFont systemFontOfSize:15] textColor:[UIColor textColor1] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.name];
        self.sex = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.name.bottom_sd, 17, 12)];
        self.sex.left_sd = self.name.left_sd;
        [self.contentView addSubview:self.sex];
        
        self.status = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
        self.status.layer.cornerRadius = 5;
        self.status.clipsToBounds = YES;
        self.status.backgroundColor = [UIColor theme];
        self.status.titleLabel.font = [UIFont systemFontOfSize:15];
        self.status.right_sd = KScreenWidth-12;
        self.status.centerY_sd = self.header.centerY_sd;
        [self.contentView addSubview:self.status];
        WeakSelf
        [self.status handleEventTouchUpInsideCallback:^{
            if (weakSelf.acceptApplyBlock) {
                weakSelf.acceptApplyBlock(weakSelf.model, weakSelf);
            }
        }];
    }
    return self;
}
-(void)setModel:(FreshApplyModel *)model{
    _model = model;
    if (model.gender == 0) {
        self.sex.image = [UIImage imageNamed:@"gender_woman"];
    }else{
        self.sex.image = [UIImage imageNamed:@"gender_man"];
    }
    [self.header sd_setImageWithURL:[NSURL URLWithString:[NSString formatImageUrlWith:model.headimg ifThumb:true thumb_W:80]] placeholderImage:[UIImage imageNamed:CUKey.kPlaceHead]];
    self.name.text = model.nickname;
    if (model.status == 1) {
        [self.status setTitle:@"已添加" forState:UIControlStateNormal];
        self.status.backgroundColor = [UIColor whiteColor];
        [self.status setTitleColor:[UIColor textColor2] forState:UIControlStateNormal];
        self.status.userInteractionEnabled = NO;
    }else if (model.status == 0){
        [self.status setTitle:@"接受" forState:UIControlStateNormal];
        self.status.backgroundColor = [UIColor baseColor];
        [self.status setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
}


@end


@implementation FreshApplyModel

@end
