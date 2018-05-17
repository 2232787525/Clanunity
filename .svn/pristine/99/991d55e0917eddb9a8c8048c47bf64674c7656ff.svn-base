//
//  MTTUserEntity.h
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTTDepartment.h"
#import "MTTBaseEntity.h"
//#import "IMBaseDefine.pb.h"
#define DD_USER_INFO_SHOP_ID_KEY                    @"shopID"

@class UserInfo;

@interface MTTUserEntity : MTTBaseEntity


/**
 0未选中，1是选中，2是选中不可点击
 */
@property(nonatomic,assign)NSInteger selected;

/**
 添加是11，删除是33
 */
@property(nonatomic,assign)NSInteger addDelete;


/**
 真实姓名
 */
@property(nonatomic,copy)NSString * _Nullable realname;



/**
 手机号 18955555555
 */
@property(nonatomic,copy)NSString *_Nullable username;

//
@property(nonatomic,copy)NSString *_Nullable birthday;
//-api/friend 性别男女 1是女的
@property(nonatomic,assign)NSInteger  gender;
@property(nonatomic,assign)BOOL isfriend;
@property(nonatomic,copy)NSString *_Nullable job;
@property(nonatomic,copy)NSString *_Nullable nickname;
@property(nonatomic,copy)NSString *_Nullable speciality;
@property(nonatomic,copy)NSString *_Nullable userid;

/**
 2a5e58a2bd8640d58d5b3a414790ba18
 */
@property(nonatomic,copy)NSString * _Nullable id;

/**
 户籍
 */
@property(nonatomic,copy)NSString *_Nullable registerString;
//-api/friend
@property(nonatomic,copy)NSString *_Nullable created;//创建时间
//-api/friend 好友的用户id
@property(nonatomic,copy)NSString *_Nullable friendUserid;
//-api/friend 我自己的用户id
@property(nonatomic,copy)NSString *_Nullable meUserid;
//-api/friend - 好友名称
@property(nonatomic,copy)NSString *_Nullable remark;
@property(nonatomic,copy)NSString *_Nullable updated;
//-api/friend 暂时无用（之前约定的删除标识）
@property(nonatomic,assign)NSInteger status;

/**同宗汇 - 关联的teamid*/
@property(nonatomic,assign)NSInteger teamid;
/** 头像*/
@property(nonatomic,copy)NSString * _Nullable headimg;

/** 用户名*/
@property(nonatomic,strong) NSString * _Nullable name;
/**
*用户昵称
 */
@property(nonatomic,strong) NSString * _Nullable nick;

/**
 *用户头像
 */
@property(nonatomic,strong) NSString *_Nullable avatar;

/**
 *用户部门
 */
@property(nonatomic,strong) NSString *_Nullable department;

/**
 *个性签名
 */
@property(nonatomic,strong) NSString *_Nullable signature;

/**
 特殊标识
 */
@property(strong)NSString * _Nullable position;
@property(assign)NSInteger sex;
@property(strong)NSString * _Nullable departId;
@property(strong)NSString * _Nullable telphone;
@property(strong)NSString * _Nullable email;
@property(strong)NSString * _Nullable pyname;
@property(assign)NSInteger userStatus;


- (id _Nonnull )initWithUserID:(NSString*_Nullable)userID name:(NSString*_Nullable)name nick:(NSString*_Nullable)nick avatar:(NSString*_Nullable)avatar userRole:(NSInteger)userRole userUpdated:(NSUInteger)updated;
+(id _Nonnull )dicToUserEntity:(NSDictionary *_Nullable)dic;
+(NSMutableDictionary *_Nullable)userToDic:(MTTUserEntity *_Nullable)user;
-(void)sendEmail;
-(void)callPhoneNum;
-(NSString *_Nullable)getAvatarUrl;
-(NSString *_Nullable)get300AvatarUrl;
-(NSString *_Nullable)getAvatarPreImageUrl;
-(id _Nullable )initWithPB:(UserInfo *_Nonnull)pbUser;
+(UInt32)localIDTopb:(NSString *_Nullable)userid;
+(NSString *_Nullable)pbUserIdToLocalID:(NSUInteger)userID;

@end
