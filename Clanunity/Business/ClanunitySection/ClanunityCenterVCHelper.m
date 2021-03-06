//
//  ClanunityCenterVCHelper.m
//  Clanunity
//
//  Created by wangyadong on 2018/2/27.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import "ClanunityCenterVCHelper.h"
#import <Masonry/Masonry.h>
#import "UIButton+WebCache.h"
#import "DDFixedGroupAPI.h"
#import "MTTUtil.h"
#import "DDGroupModule.h"
#import "IMBaseDefine.pb.h"
#import "MTTDatabaseUtil.h"
#import "MTTAvatarImageView.h"
#import "MTTDatabaseUtil.h"
@implementation ClanunityCenterVCHelper



+(UIView*)makeCenterSearchViewWithBlock:(void (^)(void))block
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(50, 0, KScreenWidth-100, 30)];
    view.layer.masksToBounds = YES;
    view.top_sd = KStatusBarHeight + 7;
    view.layer.cornerRadius = view.height_sd/2.0;
    view.backgroundColor = [UIColor whiteColor];
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(10*kScreenScale, 0, 13, 13)];
    img.centerY_sd = view.height_sd/2.0;
    img.image = [UIImage imageNamed:@"sousuo"];
    [view addSubview:img];
    
    UILabel *lb = [UILabel labelWithFrame:CGRectMake(img.right_sd+5, 0, view.width_sd-img.right_sd-10, 20) text:@"请输入群名称或好友名称" font:[UIFont systemFontOfSize:14] textColor:UIColor.textColor2 textAlignment:NSTextAlignmentLeft];
    lb.centerY_sd = view.height_sd/2.0;
    [view addSubview:lb];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:view.bounds];
    [view addSubview:btn];
    [btn handleEventTouchUpInsideCallback:^{
        block();
    }];
    return view;
    
}

+(CenterTabHeaderView*)makeCenterTabHeaderView;
{
    CenterTabHeaderView *view = [[CenterTabHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 85 * kScreenScale)];
    return view;
}
+(CenterTabSessionHeader *)makeSectionHeaderView{
    CenterTabSessionHeader *head = [[CenterTabSessionHeader alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 44)];
    head.backgroundColor = [UIColor whiteColor];
    return  head;
}



@end


@implementation CenterChatRoomItem

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backImg = [[UIImageView alloc] init];
        self.backImg.image = [UIImage imageNamed:@"centerBgImg"];
        self.backImg.layer.cornerRadius = 4;
        self.backImg.clipsToBounds = YES;
        [self addSubview:self.backImg];
        self.backImg.userInteractionEnabled = YES;
        WeakSelf;
        [self.backImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakSelf).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        UIView *imgTopview = [[UIView alloc] init];
        [self.backImg addSubview:imgTopview];
        imgTopview.alpha = 0.37;
        imgTopview.backgroundColor = [UIColor blackColor];
        [imgTopview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakSelf.backImg).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        self.titlelb = [UILabel labelWithFrame:CGRectMake(9, 13, self.width_sd-18, 20) text:@"" font:[UIFont systemFontOfSize:15] textColor:[UIColor whiteColor] textAlignment:NSTextAlignmentCenter];
        self.titlelb.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.titlelb];
        [self.titlelb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(15);
            make.left.equalTo(weakSelf).with.offset(10);
            make.right.equalTo(weakSelf).with.offset(-10);
            make.height.mas_equalTo(20);
            
        }];
//        self.chaterCountLb = [UILabel labelWithFrame:CGRectMake(12, 0, self.width_sd/2.0, 20) text:@"128人" font:[UIFont systemFontOfSize:12] textColor:[UIColor whiteColor] textAlignment:NSTextAlignmentLeft];
//        [self addSubview:self.chaterCountLb];
       
        self.chatStatuslb = [UILabel labelWithText:@"加入聊天" font:[UIFont systemFontOfSize:11] textColor:[UIColor whiteColor] textAlignment:NSTextAlignmentCenter];
        self.chatStatuslb.backgroundColor = [UIColor colorWithHexString:@"#A3BC9A"];
        [self addSubview:self.chatStatuslb];
        self.chatStatuslb.layer.cornerRadius = 10 * kScreenScale;
        self.chatStatuslb.clipsToBounds = YES;
        [self.chatStatuslb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(20 * kScreenScale);
            make.width.mas_equalTo(65 * kScreenScale);
            make.centerX.equalTo(weakSelf).with.offset(0);
            make.bottom.equalTo(weakSelf).with.offset(-11);
        }];
//        [self.chaterCountLb mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(weakSelf).with.offset(8);
//            make.size.mas_equalTo(CGSizeMake(50, 20));
//            make.bottom.equalTo(weakSelf.chatStatuslb);
//        }];
        
        UIButton *btn = [[UIButton alloc] init];
        [self addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakSelf).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        [btn handleEventTouchUpInsideCallback:^{
            if (weakSelf.roomClickedBlock&&weakSelf.model.roomname.length > 0) {
                weakSelf.roomClickedBlock();
            }
        }];
        
    }
    return self;
}
-(void)setModel:(ChatRoomModel *)model{
    _model = model;
//    self.chatStatuslb.text = @"加入聊天";
//    self.chatStatuslb.hidden = NO;
    self.title = model.roomname;
    if (model.roomname.length == 0) {
//        self.chatStatuslb.text = @"";
//        self.chatStatuslb.hidden = YES;
    }
    
}
-(void)setCount:(NSInteger)count{
    _count = count;

}
-(void)setTitle:(NSString *)title{
    _title = title;
    self.titlelb.text = title;
}


@end


@implementation ChatRoomModel

@end

@implementation CenterChatRoomView

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        CGFloat w = (KScreenWidth - 12*2 - 3*2)/3.0;
        
        self.countryRoom = [[CenterChatRoomItem alloc] initWithFrame:CGRectMake(12, 7, w, self.height_sd - 14)];
        [self addSubview:self.countryRoom];
        self.provinceRoom = [[CenterChatRoomItem alloc] initWithFrame:CGRectMake(12, 7, w, self.height_sd - 14)];
        self.provinceRoom.left_sd = self.countryRoom.right_sd+3;
        [self addSubview:self.provinceRoom];
        self.cityRoom = [[CenterChatRoomItem alloc] initWithFrame:CGRectMake(12, 7, w, self.height_sd - 14)];
        self.cityRoom.left_sd = self.provinceRoom.right_sd+3;
        [self addSubview:self.cityRoom];
        NSMutableArray*masonryViewArray = [NSMutableArray array];
        [masonryViewArray addObjectsFromArray:@[self.countryRoom,self.provinceRoom,self.cityRoom]];
        
        [masonryViewArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:3 leadSpacing:12 tailSpacing:12];
        
        // 设置array的垂直方向的约束
        [masonryViewArray mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(7);
            make.height.mas_equalTo(95-14);
        }];

    }
    return self;
}
-(void)requestForRoom{
    WeakSelf;
    [ClanAPI requestForchatroomWithResult:^(ClanAPIResult * _Nonnull result) {
        if ([result.status isEqualToString:@"200"]) {
            
            NSArray * array = [ChatRoomModel mj_objectArrayWithKeyValuesArray:result.data];
            if (array.firstObject) {
                weakSelf.countryRoom.model = array.firstObject;
            }
            if (array.count >= 2) {
                weakSelf.provinceRoom.model = array[1];
            }
            if (array.count >= 3) {
                weakSelf.cityRoom.model = array[2];
            }
            
        }else{
            ChatRoomModel *model = [[ChatRoomModel alloc] init];
            model.roomname = @"";
            weakSelf.countryRoom.model = [[ChatRoomModel alloc]initWithDic:[model mj_keyValues]];
            weakSelf.provinceRoom.model = [[ChatRoomModel alloc]initWithDic:[model mj_keyValues]];
            weakSelf.cityRoom.model = [[ChatRoomModel alloc]initWithDic:[model mj_keyValues]];
        }
        
    }];
}

@end


@implementation CenterGroupItem

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame: frame];
    if (self) {
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.headerImg = [[MTTAvatarImageView alloc] init];
        self.headerImg.clipsToBounds = YES;
        self.headerImg.layer.cornerRadius =  25 * kScreenScale;
        [self addSubview:self.headerImg];
        self.headerImg.backgroundColor = RGB(228, 227, 230);
        
        self.namelb = [UILabel labelWithText:@"天下无贼" font:[UIFont systemFontOfSize:14] textColor:[UIColor textColor1] textAlignment:NSTextAlignmentCenter];
        [self addSubview:self.namelb];
        WeakSelf;
        self.headerImg.frame = CGRectMake(0, 0, 50 * kScreenScale, 50 * kScreenScale);
        self.headerImg.centerX_sd = self.width_sd/2.0;
        self.headerImg.top_sd = 7*kScreenScale;
        self.headerImg.layer.borderWidth = 0.5;
        self.headerImg.layer.borderColor = [UIColor cutLineColor].CGColor;
        
        self.namelb.left_sd = 0;
        self.namelb.top_sd = self.headerImg.bottom_sd;
        self.namelb.width_sd = self.width_sd;
        self.namelb.height_sd = self.height_sd-self.headerImg.bottom_sd;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = self.bounds;
        [self addSubview:btn];
       
        [btn handleEventTouchUpInsideCallback:^{
            if (weakSelf.groupCallBack) {
                weakSelf.groupCallBack(weakSelf.model);
            }
        }];
        
    }
    return self;
}
-(void)setModel:(MTTGroupEntity *)model{
    _model = model;
    
    if (model.type == 0) {
        self.name = model.name;
        NSLog(@"%@,===>%@",model.name,model.imgArray);
        [self.headerImg setGroupAvatars:model.imgArray];
    }else if (model.type == 1){
        [self.headerImg removeAllSubviews];
        self.name = @"查看更多";
        [self.headerImg setAvatarNextMoreImg:@"nextMore"];
        self.headerImg.backgroundColor = [UIColor textColor3];

    }else if (model.type == 2){
        [self.headerImg removeAllSubviews];
        self.name = @"创建群聊";
        [self.headerImg setAvatarNextMoreImg:@"addGroupImg"];
        self.headerImg.backgroundColor = [UIColor textColor3];
    }
}

-(void)setMore:(BOOL)more{
    _more = more;
    if (more == YES) {
        self.name = @"查看更多";
        self.headerImg.backgroundColor = [UIColor bgColor3];
        self.headerImg.image = [UIImage imageNamed:@"nextMore"];
    }
}

-(void)setName:(NSString *)name{
    _name = name;
    self.namelb.text = name;
}
@end




@implementation CenterGroupView
-(NSMutableArray *)dbAllGroups{
    if (_dbAllGroups == nil) {
        _dbAllGroups = [NSMutableArray arrayWithCapacity:0];
    }
    return _dbAllGroups;
}
-(NSMutableArray<MTTGroupEntity *> *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArray;
}
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.backgroundColor = [UIColor bgGreyColor];
        CGFloat h = 85 * kScreenScale;
        self.height_sd = h + 20;
    }
    return self;
}

-(void)freshRequestForMyGroups{
    [self requestForNormalGroupList];
}
-(void)clearData{
    [self.dataArray removeAllObjects];
    self.array = self.dataArray;
}
#pragma mark - 获取 群列表
-(void)requestForNormalGroupList{
    WeakSelf;
    if (self.array.count == 0) {
        [MBProgressHUD hideHUDForView:self animated:YES];
        [MBProgressHUD showHUDAddedTo:self animated:YES];
    }
    
    [ClanAPI requestForMyGroupListWithResult:^(ClanAPIResult * _Nonnull result) {
        [MBProgressHUD hideHUDForView:weakSelf animated:YES];
        if ([result.status isEqualToString:@"200"]) {
            [weakSelf.dataArray removeAllObjects];
            [weakSelf.dataArray addObjectsFromArray:[MTTGroupEntity mj_objectArrayWithKeyValuesArray:result.data]];
            [weakSelf.dataArray enumerateObjectsUsingBlock:^(MTTGroupEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.objID = [MTTGroupEntity pbGroupIdToLocalID:(UInt32)obj.id];
                obj.groupCreatorId = [MTTUserEntity pbUserIdToLocalID:obj.tuserid];
                //头像数组
                __block NSMutableArray *temArray = [NSMutableArray arrayWithCapacity:0];
                __block NSMutableArray *temUseridsArray = [NSMutableArray arrayWithCapacity:0];
                [obj.users enumerateObjectsUsingBlock:^(MTTUserEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [temUseridsArray addObject:[MTTUtil changeOriginalToLocalID:(UInt32)obj.teamid SessionType:1]];
                    obj.headimg = [NSString formatImageUrlWith:obj.headimg ifThumb:true thumb_W:80];
                    if (obj.headimg.length == 0) {
                        [[DDUserModule shareInstance] getUserForUserID:[MTTUtil changeOriginalToLocalID:(UInt32)obj.teamid SessionType:1] Block:^(MTTUserEntity *user) {
                            obj.headimg = user.avatar;
                            NSLog(@"avatar = %@",user.avatar);
                        }];
                    }
                    if (idx < 4 ) {
                        if (obj.headimg != nil && [obj.headimg isKindOfClass:[NSString class]]) {
                            [temArray addObject:obj.headimg];
                        }else{
                            [temArray addObject:@""];
                        }
                    }
                }];
                obj.groupUserIds = temUseridsArray;
                obj.imgArray = temArray;
                if (![[DDGroupModule instance] getGroupByGId:obj.objID]) {
                    [[DDGroupModule instance] addGroup:obj];
                    [[MTTDatabaseUtil instance] updateRecentGroup:obj completion:^(NSError *error) {
                        DDLog(@"insert group to database error.");
                    }];
                } 
            }];
            if (weakSelf.dataArray.count > 3) {
                MTTGroupEntity *moreM = [[MTTGroupEntity alloc] init];
                moreM.type = 1;//更多
                weakSelf.array = @[weakSelf.dataArray[0],weakSelf.dataArray[1],weakSelf.dataArray[2],moreM];
            }else{
                MTTGroupEntity *addM = [[MTTGroupEntity alloc] init];
                addM.type = 2;//新增
                NSMutableArray *temp = [NSMutableArray arrayWithCapacity:0];
                [temp addObjectsFromArray:weakSelf.dataArray];
                [temp addObject:addM];
                weakSelf.array = temp;
            }
        }else if ([result.status isEqualToString:@"301"]){
            MTTGroupEntity *addM = [[MTTGroupEntity alloc] init];
            addM.type = 2;//新增
            NSMutableArray *temp = [NSMutableArray arrayWithCapacity:0];
            [temp addObjectsFromArray:weakSelf.dataArray];
            [temp addObject:addM];
            weakSelf.array = temp;
        }
    }];
    
    
}

-(void)setArray:(NSArray<MTTGroupEntity *> *)array{

    _array = array;
    [self removeAllSubviews];
//    CGFloat w = (KScreenWidth+25 - 12*2 - 3*3)/4.0;
    CGFloat w = 88 * kScreenScale;
    CGFloat h = 85 * kScreenScale;

    
    WeakSelf;
    for (NSInteger i = 0; i < array.count; i++) {
        CenterGroupItem *view = [[CenterGroupItem alloc] initWithFrame:CGRectMake(12+i*w+3*i, 5, w, h)];
        MTTGroupEntity *groupModel = array[i];
        view.model = groupModel;
        [view setGroupCallBack:^(MTTGroupEntity * _Nullable model) {
            if (weakSelf.groupCallBack) {
                weakSelf.groupCallBack(model);
            }
        }];
       
        [self addSubview:view];
        self.contentSize = CGSizeMake(view.right_sd+12, self.height_sd);
    }
   
}


@end


@implementation CenterTabHeaderView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame: frame];
    if (self) {
        self.backgroundColor = [UIColor bgGreyColor];
        self.roomtitlelb = [UILabel labelWithFrame:CGRectMake(12, 0, 200, 20) text:@"我的聊天室" font:[UIFont systemFontOfSize:18] textColor:[UIColor textColor1] textAlignment:NSTextAlignmentLeft];
        [self addSubview:self.roomtitlelb];
        self.roomtitlelb.centerY_sd = 25;
        self.chatRoomView = [[CenterChatRoomView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 95)];
        self.chatRoomView.top_sd = 50;
        [self addSubview:self.chatRoomView];

        self.grouptitlelb =[UILabel labelWithFrame:CGRectMake(12, 0, 200, 20) text:@"我的群" font:[UIFont systemFontOfSize:18] textColor:[UIColor textColor1] textAlignment:NSTextAlignmentLeft];
        self.grouptitlelb.top_sd = self.chatRoomView.bottom_sd+15;
        [self addSubview:self.grouptitlelb];

        self.myGroupView = [[CenterGroupView alloc] initWithFrame:CGRectMake(0, self.grouptitlelb.bottom_sd + 10, KScreenWidth, 0)];
        [self addSubview:self.myGroupView];
        self.height_sd = self.myGroupView.bottom_sd;

        [self.chatRoomView requestForRoom];
    }
    return self;
}
@end

@implementation CenterTabSessionHeader

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame: frame];
    if (self) {
        UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 0.5)];
        bottom.backgroundColor = [UIColor cutLineColor];
        [self addSubview:bottom];
        bottom.bottom_sd = self.height_sd;
        NSArray *title = @[@"消息",@"我的好友"];
        CGFloat w = KScreenWidth/title.count;
        for (NSInteger i = 0; i < title.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            btn.frame = CGRectMake(i*w, 0,w, 30);
            btn.titleLabel.font = [UIFont systemFontOfSize:16];
            [btn setTitle:title[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor textColor1] forState:UIControlStateNormal];
            btn.centerY_sd = self.height_sd/2.0;
            [self addSubview:btn];
            btn.tag = 12306+i;
            if (i == 0) {
                [btn setTitleColor:[UIColor baseColor] forState:UIControlStateNormal];
            }
            if (i != title.count-1) {
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.5, 20)];
                line.backgroundColor = [UIColor textColor3];
                line.left_sd = btn.right_sd;
                [self addSubview:line];
                line.centerY_sd = btn.centerY_sd;
            }
            [btn addTarget:self action:@selector(messageBtnTap:) forControlEvents:UIControlEventTouchUpInside];
        }
        self.currentIndex = 0;

    }
    return self;
}
-(void)messageBtnTap:(UIButton*)sender{
    NSLog(@"点击：%@",@(sender.tag));
    if (self.currentIndex == sender.tag-12306) {
        if (self.clickCallBack != nil) {
            self.clickCallBack(self.currentIndex, YES);
        }
    }else{
        
        UIButton *btn = (UIButton*)[self viewWithTag:self.currentIndex+12306];
        [btn setTitleColor:[UIColor textColor1] forState:UIControlStateNormal];
        [sender setTitleColor:[UIColor baseColor] forState:UIControlStateNormal];
        self.currentIndex = sender.tag - 12306;
        if (self.clickCallBack != nil) {
            self.clickCallBack(self.currentIndex, NO);
        }
    }
}

@end

@implementation CenterMoreView

-(UIButton *)alphaBtn{
    if (_alphaBtn == nil) {
        WeakSelf;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-KBottomHeight)];
        btn.backgroundColor = [UIColor blackColor];
        btn.alpha = 0;
        _alphaBtn = btn;
        [btn handleEventTouchUpInsideCallback:^{
            [weakSelf close];
        }];
    }
    return _alphaBtn;
}
-(UIImageView *)selectView{
    if (_selectView == nil) {
        // 处理区域拉伸的图片
        WeakSelf;
        UIImage *img = [UIImage imageNamed:@"alertBgImg"];
        // 四个数值对应图片中距离上、左、下、右边界的不拉伸部分的范围宽度
        img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(5,5, 0, 10) resizingMode:UIImageResizingModeStretch];
       UIImageView *imgView= [[UIImageView alloc] initWithFrame:CGRectMake(0, KTopHeight, 115, 40)];
        imgView.image = img;

        _selectView = imgView;
        imgView.clipsToBounds = YES;
        imgView.right_sd = KScreenWidth-12;
        imgView.userInteractionEnabled = YES;
        
        NSArray *titles  = @[@"邀请好友",@"建群",@"添加好友"];
        NSArray *imgs = @[@"invitefrd",@"createGroup",@"addfriend"];
        for (NSInteger i = 0; i < titles.count; i++) {
            
            UILabel *lb = [UILabel labelWithFrame:CGRectMake(0, 8+i*44, self.selectView.width_sd-30, 44) text:titles[i] font:[UIFont systemFontOfSize:16] textColor:[UIColor whiteColor] textAlignment:NSTextAlignmentLeft];
            [imgView addSubview:lb];
            lb.userInteractionEnabled = YES;
            UIImage *icon = [UIImage imageNamed:imgs[i]];
            UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
            iconView.userInteractionEnabled = YES;
            iconView.image = icon;
            iconView.size_sd = icon.size;
            iconView.left_sd = 10;
            iconView.centerY_sd = lb.centerY_sd;
            lb.left_sd = iconView.right_sd + 10;
            [imgView addSubview:iconView];
            lb.width_sd = imgView.width_sd - lb.left_sd;
            
            if (i != titles.count-1) {
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,lb.bottom_sd, imgView.width_sd, 0.5)];
                line.backgroundColor = [UIColor colorWithHexString:@"#8D5506"];
                [imgView addSubview:line];
            }
            imgView.height_sd = lb.bottom_sd+1;
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, lb.top_sd, imgView.width_sd, lb.height_sd)];
            [imgView addSubview:btn];
            
            [btn handleEventTouchUpInsideCallback:^{
                if (weakSelf.selectedIndexBlock) {
                    weakSelf.selectedIndexBlock(i);
                }
                [weakSelf close];
            }];
        }
    }
    return _selectView;
}
-(instancetype)initWithFrame:(CGRect)frame{
    self= [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.alphaBtn];
        [self addSubview:self.selectView];
        self.selectheight = self.selectView.height_sd;
        self.selectView.height_sd = 0;
    }
    return self;
}
-(void)close{
    [UIView animateWithDuration:0.25 animations:^{
        self.selectView.height_sd = 0.0;
        self.alphaBtn.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.selectView removeFromSuperview];
            [self.alphaBtn removeFromSuperview];
            [self removeFromSuperview];
        }
    }];
}
-(void)show{
    [UIView animateWithDuration:0.25 animations:^{
        self.selectView.height_sd = self.selectheight;
        self.alphaBtn.alpha = 0.25;
    } completion:^(BOOL finished) {
        if (finished) {
            
        }
    }];
}

@end



