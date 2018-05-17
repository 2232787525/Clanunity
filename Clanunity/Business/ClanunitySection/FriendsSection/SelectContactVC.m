//
//  SelectContactVC.m
//  Clanunity
//
//  Created by wangyadong on 2018/3/13.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//
/*
 不停数据源
 */
#import "SelectContactVC.h"
#import "SelectContactCell.h"
#import "DDCreateGroupAPI.h"
@interface SelectContactVC ()
<UITableViewDataSource,UITableViewDelegate>{
    NSInteger _page;
    NSInteger _pageSize;
}
@property(nonatomic,strong)UITableView *tableView;

/**
 用于显示table数据的数组
 */
@property(nonatomic,strong)NSMutableArray * dataArray;


/**
 搜索结果数据
 */
@property(nonatomic,strong)NSMutableArray *searchArray;

/**
 联系人数组
 */
@property(nonatomic,strong)NSMutableArray * contactArray;
@property(nonatomic,strong)SelectContactVC_SelectedView * collectionView;


@end

@implementation SelectContactVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.knavigationBar.title = @"选择联系人";
    
    _page = 1;
    _pageSize = 10000;
    WeakSelf;
    self.knavigationBar.rightBarBtnItem = [[KNaviBarBtnItem alloc] initWithFrame:CGRectMake(0, 0, 44, 44) title:@"确定" hander:^(id _Nonnull sender) {
       
        if (weakSelf.collectionView.dataArray.count == 0) {
            [WFHudView showMsg:@"请选择联系人" inView:weakSelf.view];
            return;
        }
        if (weakSelf.collectionView.dataArray.count == 1) {
            MTTUserEntity *user = weakSelf.collectionView.dataArray.firstObject;
            NSLog(@"%@,%@",user.objID,user.nick);
            [weakSelf kBackBtnAction];
            if (weakSelf.singleChat) {
                weakSelf.singleChat(weakSelf.collectionView.dataArray.firstObject);
            }
            return;
        }
        
        [weakSelf showAlertCreateGroup];
    }];
    
    //选中联系人的数据
    SelectContactVC_SelectedView *view = [[SelectContactVC_SelectedView alloc] initWithFrame:CGRectMake(0, KTopHeight, KScreenWidth, 55)];
    self.collectionView = view;
    [self.view addSubview:view];
    [view setCollectionItemChanged:^(MTTUserEntity *model) {
        NSIndexPath *path = [NSIndexPath indexPathForItem:[weakSelf.dataArray indexOfObject:model] inSection:0];
        [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:(UITableViewRowAnimationFade)];
    }];
    [view setSearchResultBlock:^(MTTUserEntity *model) {
        NSInteger index = [weakSelf.dataArray indexOfObject:model];
        NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:0];
        [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:(UITableViewRowAnimationFade)];
    }];
    [view setSearchTFBeginEditBlock:^{
        //把原始数据给过去
        weakSelf.collectionView.contactArray = weakSelf.contactArray;
    }];
    
    [self makeTableView];
    
    [self loadMyFriend];
    
}

-(void)showAlertCreateGroup{
    WeakSelf;
    // 1.创建UIAlertController
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"创建群" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    // 2.1 添加文本框
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"设置群名称";
        [textField addTarget:self action:@selector(alertUserAccountInfoDidChange:) forControlEvents:UIControlEventEditingChanged];     // 添加响应事件

    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Cancel Action");
    }];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *userName = alertController.textFields.firstObject;
        if ([userName.text trim] > 0) {
            [weakSelf ttCreateGroupWithGroupName:[userName.text trim]];
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:sureAction];
    sureAction.enabled = NO;
    [self presentViewController:alertController animated:YES completion:nil];

    
}
-(void)alertUserAccountInfoDidChange:(UITextField*)sender{
     UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        NSString *userName = alertController.textFields.firstObject.text;
        UIAlertAction *sureAction = alertController.actions.lastObject;
        if ([userName trim].length > 0) {
            sureAction.enabled = YES;
        }else{
            sureAction.enabled = NO;
        }
    }
}
-(void)ttCreateGroupWithGroupName:(NSString*)name{
    NSLog(@"%@",name);
    if( TheRuntime.loginSuccess == NO){
        [WFHudView showMsg:@"暂无服务，请重新登录" inView:self.view];
        return;
    }
    NSMutableArray * userList = [NSMutableArray arrayWithCapacity:0];
    [userList addObject:TheRuntime.user.objID];
    for (NSInteger i = 0 ; i < self.collectionView.dataArray.count;i++) {
        MTTUserEntity *model = self.collectionView.dataArray[i];
        [userList addObject:model.objID];
    }
    NSLog(@"%@",userList);
    WeakSelf;
    DDCreateGroupAPI *creatGroupApi = [[DDCreateGroupAPI alloc] init];
    NSArray *comparaArray = @[name,@"",userList,@(1)];//创建固定群
    [creatGroupApi requestWithObject:comparaArray Completion:^(MTTGroupEntity *  _Nullable response, NSError * _Nullable error) {
        if (response != nil) {
            [WFHudView showMsg:@"创建群成功" inView:weakSelf.view];
            response.groupCreatorId=TheRuntime.user.objID;
            if (weakSelf.createGroupSuccess) {
                weakSelf.createGroupSuccess(YES);
            }
            [weakSelf kBackBtnAction];
        }else{
            [WFHudView showMsg:@"创建群失败" inView:weakSelf.view];
        }
    }];
}

-(void)loadMyFriend{
    
    WeakSelf;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [ClanAPI requestForMyFriendListWithPage:_page pageSize:_pageSize result:^(ClanAPIResult * _Nonnull result) {
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        [weakSelf.tableView.mj_header endRefreshing];
        if ([result.status isEqualToString:@"200"]) {
            BOOL first = [result.data[@"firstPage"] boolValue];
            BOOL last = [result.data[@"lastPage"] boolValue];
            NSArray *array = [MTTUserEntity mj_objectArrayWithKeyValuesArray:result.data[@"list"]];
            NSMutableArray *pageData = [NSMutableArray arrayWithCapacity:0];
            for (MTTUserEntity *model in array) {
                model.name = model.remark;
                model.realname = model.remark;
                model.nick = model.remark;
                model.objID = [MTTUserEntity pbUserIdToLocalID:model.teamid];
                model.selected = NO;
                model.headimg = [NSString formatImageUrlWith:model.headimg ifThumb:true thumb_W:80];
//                model.headimg = [NSString formatImageUrlWith:model.headimg];
                [pageData addObject:model];
            }
            if (first) {
                [weakSelf.contactArray removeAllObjects];
                [weakSelf.dataArray removeAllObjects];
            }
            [weakSelf.contactArray addObjectsFromArray:pageData];
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

-(void)makeTableView{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, KTopHeight+55,KScreenWidth,KScreenHeight-KTopHeight-55) style:UITableViewStyleGrouped];
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
    
    [self.view addSubview:self.tableView];
    WeakSelf;
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            _page = _page + 1;
            [weakSelf loadMyFriend];
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
    if (cell.model.selected == 0) {
        cell.model.selected = 1;
    }else{
        cell.model.selected = 0;
    }
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.collectionView dataChangeStatusAdd:cell.model.selected forModel:cell.model];
}

//MARK:懒加载

-(NSMutableArray*)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArray;
}
-(NSMutableArray *)searchArray{
    if (_searchArray) {
        _searchArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _searchArray;
}
-(NSMutableArray *)contactArray{
    if (!_contactArray) {
        _contactArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _contactArray;
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


@implementation SelectContactVC_SelectedView

//@property(nonatomic,strong)EmptySwiftView * emptyView;


-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 0.5)];
        line.backgroundColor = [UIColor cutLineColor];
        [self addSubview:line];
        line.bottom_sd = self.height_sd;
        
        self.searchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(12, 0, 15, 15)];
        self.searchIcon.image = [UIImage imageNamed:@"searchImg"];
        self.searchIcon.centerY_sd = self.height_sd/2.0;
        [self addSubview:self.searchIcon];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];//横向滑动
        layout.itemSize =CGSizeMake(35, 35);
        layout.minimumLineSpacing = 0.0;
        layout.minimumInteritemSpacing = 0.0;

        self.usersView = [[UICollectionView alloc] initWithFrame:CGRectMake(12, 10, KScreenWidth, 35) collectionViewLayout:layout];
        self.usersView.centerY_sd = self.searchIcon.centerY_sd;
        self.usersView.width_sd = KScreenWidth-75-12-12;
        self.usersView.backgroundColor = [UIColor whiteColor];
        [self.usersView registerClass:[SelectedCollectionCell class] forCellWithReuseIdentifier:@"CollectionID"];
        self.usersView.delegate = self;
        self.usersView.dataSource = self;
        self.usersView.bounces =NO;
        self.usersView.hidden = YES;
        [self addSubview:self.usersView];
        [self.usersView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew |NSKeyValueObservingOptionOld) context:nil];
        
        self.searchTf = [[SearchTF alloc] initWithFrame:CGRectMake(self.searchIcon.right_sd, 10, KScreenWidth, 35)];
        self.searchTf.returnKeyType = UIReturnKeySearch;
        self.searchTf.keyboardType = UIKeyboardTypeDefault;
        self.searchTf.delegate = self;
        self.searchTf.width_sd = KScreenWidth-self.searchIcon.right_sd-8;
        [self addSubview:self.searchTf];
        self.searchTf.placeholder = @"搜索";
        self.searchTf.font = [UIFont systemFontOfSize:15];
        WeakSelf
        [self.searchTf setDeleteBackwardBlock:^{
            if (weakSelf.searchTf.text.length <= 0) {
                [weakSelf.searchTf resignFirstResponder];
            }
        }];
        
        [self makeTableView];
    }
    return self;
}

-(void)dataChangeStatusAdd:(NSInteger)add forModel:(MTTUserEntity *)model{
    if (add == 1) {
        if ([self.dataMap objectForKey:model.id] != nil) {
            NSInteger index = [self.dataArray indexOfObject:[self.dataMap objectForKey:model.id]];
            [self.dataMap setObject:model forKey:model.id];
            [self.dataArray replaceObjectAtIndex:index withObject:model];
        }else{
            [self.dataMap setObject:model forKey:model.id];
            [self.dataArray addObject:model];
        }

        [self.usersView reloadData];
        [self.usersView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.dataArray.count-1 inSection:0] atScrollPosition:(UICollectionViewScrollPositionRight) animated:YES];
    }else{
        
        if ([self.dataMap objectForKey:model.id] != nil) {
            
            NSInteger index = [self.dataArray indexOfObject:[self.dataMap objectForKey:model.id]];
            [self.dataMap removeObjectForKey:model.id];
            NSIndexPath * path = [NSIndexPath indexPathForItem:[self.dataArray indexOfObject:model] inSection:0];
            [self.dataArray removeObjectAtIndex:index];
            [self.usersView deleteItemsAtIndexPaths:[NSArray arrayWithObject:path]];
        }  
    }
    if (self.dataArray.count > 0) {
        self.usersView.hidden = NO;
    }else{
        self.usersView.hidden = YES;
    }
}
#pragma make table

-(void)makeTableView{
    
    self.searchTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.height_sd,KScreenWidth,KScreenHeight-self.bottom_sd) style:UITableViewStyleGrouped];
    self.searchTable.delegate = self;
    self.searchTable.dataSource = self;
    self.searchTable.backgroundColor = [UIColor whiteColor];
    if ([self.searchTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.searchTable setSeparatorInset:UIEdgeInsetsZero];
    }
    //ios8
    if ([self.searchTable respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.searchTable setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self addSubview:self.searchTable];
    self.searchTable.hidden = YES;
    UIImage *empty = [UIImage imageNamed:@"empty_search"];
    self.emptyImg = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.emptyImg.image = empty;
    self.emptyImg.top_sd = 0;
    self.emptyImg.size_sd = empty.size;
    self.emptyImg.centerX_sd = KScreenWidth/2.0;
    [self.searchTable addSubview:self.emptyImg];
    self.emptyImg.hidden = YES;
    self.emptylb = [UILabel labelWithFrame:CGRectMake(0, self.emptyImg.bottom_sd+15, KScreenWidth, 30) text:@"" font:[UIFont systemFontOfSize:14] textColor:[UIColor textColor1] textAlignment:NSTextAlignmentCenter];
    [self.searchTable addSubview:self.emptylb];
    self.emptylb.hidden = YES;
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.searchData.count;
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
    cell.model = self.searchData[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    SelectContactCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.model.selected == 0) {//搜索出来的结果只能添加，如果搜索出来的已经在选中列表，那么点击不做操作
        cell.model.selected = 1;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self dataChangeStatusAdd:cell.model.selected forModel:cell.model];
        //通知主页table选中这个model
        if (self.searchResultBlock) {
            self.searchResultBlock(cell.model);
        }
    }
    self.height_sd = 55;
    self.searchTable.hidden = YES;
    [self.searchData removeAllObjects];
    [self checkIfNull];
    self.searchTf.text = nil;
   
}
-(NSMutableArray*)searchData{
    if (!_searchData) {
        _searchData = [NSMutableArray arrayWithCapacity:0];
    }
    return _searchData;
}


#pragma mark - tf delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
   
    if (textField.text.length == 0) {
        [textField resignFirstResponder];
    }else{
    
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:@"没有找到"];
        NSString *showStr = @"";
        if ([textField.text length] > 10){
            showStr = [NSString stringWithFormat:@"%@...",[textField.text substringToIndex:10]] ;
        }else{
            showStr = textField.text;
        }
        
        NSAttributedString * str2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"“%@”",showStr] attributes:@{NSForegroundColorAttributeName:[UIColor orangeColor]}];
        NSAttributedString * str3 = [[NSAttributedString alloc] initWithString:@"相关结果"];
        [str appendAttributedString:str2];
        [str appendAttributedString:str3];
        self.emptylb.attributedText = str;
        
        [MBProgressHUD showHUDAddedTo:self.searchTable animated:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            for (MTTUserEntity *model in self.contactArray) {
                if ([model.realname containsString:textField.text]) {
                    [self.searchData addObject:model];
                }
            }
            [self checkIfNull];
            [self.searchTf resignFirstResponder];
            [MBProgressHUD hideAllHUDsForView:self.searchTable animated:YES];
        });
    }
    return YES;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if (self.searchTFBeginEditBlock) {
        self.searchTFBeginEditBlock();
    }
    [self.searchData removeAllObjects];
    [self.searchTable reloadData];
    [self.superview bringSubviewToFront:self];
    self.searchTable.hidden = NO;
    self.height_sd = KScreenHeight-KTopHeight;
    
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if (textField.text.length == 0) {
        [self.searchData removeAllObjects];
        self.height_sd = 55;
        self.searchTable.hidden = YES;
        [self checkIfNull];
    }
    return YES;
}

-(void)checkIfNull{
    [self.searchTable reloadData];
    if (self.searchData.count > 0){
        self.emptyImg.hidden = YES;
        self.emptylb.hidden = YES;
    }else{
        self.emptyImg.hidden = NO;
        self.emptylb.hidden = NO;
    }
}

-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArray;
}
-(NSMutableDictionary *)dataMap{
    if (!_dataMap) {
        _dataMap = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _dataMap;
}

#pragma mark ---- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SelectedCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionID" forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

// 选中某item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SelectedCollectionCell *cell = (SelectedCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self.dataArray removeObject:cell.model];
    [collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    [self.dataMap removeObjectForKey:cell.model.id];
    if (self.dataArray.count == 0) {
        self.usersView.hidden = YES;
    }
    if (self.collectionItemChanged) {
        cell.model.selected = 0;
        self.collectionItemChanged(cell.model);
    }
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if( [keyPath isEqualToString:@"contentSize"] ){

        [UIView animateWithDuration:0.20 animations:^{
            if (self.usersView.contentSize.width >= self.usersView.width_sd) {
                self.searchTf.left_sd = self.usersView.right_sd+4;
                self.searchTf.width_sd = KScreenWidth-8-self.searchTf.left_sd;
                return;
            }else{
                if (self.usersView.contentSize.width <= 0 && self.dataArray.count == 0) {
                    self.usersView.hidden = YES;
                    self.searchTf.left_sd = self.searchIcon.right_sd;
                }else{
                    self.searchTf.left_sd  = self.usersView.contentSize.width+self.usersView.left_sd+4;
                }
                self.searchTf.width_sd = KScreenWidth-8-self.searchTf.left_sd;
            }
        }];
    }
}

-(void)dealloc{
    [self.usersView removeObserver:self forKeyPath:@"contentSize" context:nil];
}
@end


@implementation SelectedCollectionCell

-(void)awakeFromNib{
    [super awakeFromNib];
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.header = [[UIImageView alloc] initWithFrame:self.bounds];
        self.header.image = [UIImage imageNamed:CUKey.kPlaceHead];
        [self addSubview:self.header];
    }
    return self;
}
-(void)setModel:(MTTUserEntity *)model{
    _model = model;
    [self.header sd_setImageWithURL:[NSURL URLWithString:model.headimg] placeholderImage:[UIImage imageNamed:CUKey.kPlaceHead]];
}

@end


@implementation SearchTF

-(void)deleteBackward{
    [super deleteBackward];
    if (self.deleteBackwardBlock) {
        self.deleteBackwardBlock();
    }
}
@end

