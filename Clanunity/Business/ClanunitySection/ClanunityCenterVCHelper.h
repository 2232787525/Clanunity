//
//  ClanunityCenterVCHelper.h
//  Clanunity
//
//  Created by wangyadong on 2018/2/27.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTTGroupEntity.h"

@class CenterChatRoomView,CenterTabHeaderView,CenterTabSessionHeader,ChatRoomModel,MTTAvatarImageView;

@interface ClanunityCenterVCHelper : NSObject

+(UIView*_Nonnull)makeCenterSearchViewWithBlock:(void (^_Nullable)(void))block;

+(CenterTabHeaderView*_Nonnull)makeCenterTabHeaderView;

+(CenterTabSessionHeader*_Nonnull)makeSectionHeaderView;

//+(void)showCenterMoreViewWithSuperView:(UIView *_Nonnull)superView;


@end



#pragma mark - 聊天室
@interface CenterChatRoomItem : UIView
/**
 1 全国，2省级，3市级
 */
@property(nonatomic,assign)NSInteger type;

/**
 l聊天室名称
 */
@property(nonatomic,copy)NSString * _Nullable title;

/**
 聊天人数： 0人就是聊天结束，多人就是正在聊天
 */
@property(nonatomic,assign)NSInteger count;

@property(nonatomic,strong)UIImageView * _Nonnull backImg;

@property(nonatomic,strong)UILabel * _Nonnull titlelb;
@property(nonatomic,strong)UILabel * _Nonnull chaterCountLb;
@property(nonatomic,strong)UILabel * _Nonnull chatStatuslb;
@property(nonatomic,copy)void(^ _Nullable roomClickedBlock)(void);

@property(nonatomic,strong)ChatRoomModel * _Nullable model;

@end

@interface ChatRoomModel : KBaseModel

@property(nonatomic,assign)NSInteger persons;
@property(nonatomic,copy)NSString * _Nullable roomname;
@property(nonatomic,copy)NSString * _Nullable areaid;
@property(nonatomic,copy)NSString * _Nullable users;
@property(nonatomic,copy)NSString * _Nullable roomtype;
@property(nonatomic,copy)NSString * _Nullable port;

@end


#pragma mark - 聊天室 view
@interface CenterChatRoomView : UIView

@property(nonatomic,strong)CenterChatRoomItem * _Nonnull countryRoom;
@property(nonatomic,strong)CenterChatRoomItem * _Nonnull provinceRoom;
@property(nonatomic,strong)CenterChatRoomItem * _Nonnull cityRoom;
-(void)requestForRoom;

@end

#pragma mark - 群item
@interface CenterGroupItem : UIView
@property(nonatomic,assign)BOOL more;
@property(nonatomic,strong)MTTAvatarImageView *_Nonnull headerImg;
@property(nonatomic,strong)UILabel *_Nonnull namelb;
@property(nonatomic,copy)NSString * _Nullable name;
@property(nonatomic,copy)void(^ _Nullable groupCallBack)(MTTGroupEntity * _Nullable model);
@property(nonatomic,strong)MTTGroupEntity * _Nullable model;

@end


#pragma mark - 我的群
@interface CenterGroupView : UIScrollView
@property(nonatomic,strong)NSMutableArray * _Nullable dbAllGroups;
@property(nonatomic,strong)NSArray<MTTGroupEntity*> * _Nullable array;
@property(nonatomic,strong)NSMutableArray<MTTGroupEntity*> * _Nullable dataArray;
@property(nonatomic,copy)void(^ _Nullable groupCallBack)(MTTGroupEntity* _Nullable model);
-(void)freshRequestForMyGroups;
-(void)clearData;

@end


@interface CenterTabHeaderView : UIView

@property(nonatomic,strong)UILabel * _Nonnull roomtitlelb;
@property(nonatomic,strong)UILabel * _Nonnull grouptitlelb;

@property(nonatomic,strong)CenterGroupView * _Nonnull myGroupView;

@property(nonatomic,strong)CenterChatRoomView * _Nonnull chatRoomView;

@end

@interface CenterTabSessionHeader : UIView

@property(nonatomic,assign)NSInteger currentIndex;

/**
 回调，NSInteger 当前点击的index，BOOL是，是否是重复点击当前的btn，yes，重复点击，NO，最新点击
 */
@property(nonatomic,copy)void(^ _Nullable clickCallBack)(NSInteger,BOOL);


@end;



@interface CenterMoreView : UIView
@property(nonatomic,strong)UIButton * _Nullable alphaBtn;
@property(nonatomic,strong)UIImageView * _Nullable selectView;
@property(nonatomic,assign)CGFloat selectheight;
@property(nonatomic,copy)void(^ _Nullable selectedIndexBlock)(NSInteger);
-(void)show;

@end
