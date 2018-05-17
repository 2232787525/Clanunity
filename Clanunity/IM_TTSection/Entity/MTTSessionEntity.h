//
//  DDMTTSessionEntity.h
//  IOSDuoduo
//
//  Created by 独嘉 on 14-6-5.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMBaseDefine.pb.h"
@class MTTUserEntity,MTTGroupEntity;

@interface MTTSessionEntity : NSObject
@property (nonatomic,retain)NSString* sessionID;
@property (nonatomic,assign)SessionType sessionType;
@property (nonatomic,copy,readonly)NSString * name;
@property(assign)NSInteger unReadMsgCount;
@property (nonatomic,assign)NSUInteger timeInterval;
@property(nonatomic,strong,readonly)NSString* orginId;
@property(assign)BOOL isShield;
@property(assign)BOOL isFixedTop;
@property(strong)NSString *lastMsg;
@property(assign)NSInteger lastMsgID;
@property(nonatomic,assign)NSInteger lastFromUserId;
@property(nonatomic,copy)NSString * lastFromUserNickname;
@property(strong)NSString *avatar;
-(NSArray*)sessionUsers;
/**
 *  创建一个session，只需赋值sessionID和Type即可
 *
 *  @param sessionID 会话ID，群组传入groupid，p2p传入对方的userid
 *  @param type      会话的类型
 *
 *  @return  nil
 */
- (id)initWithSessionID:(NSString*)sessionID type:(SessionType)type;
- (id)initWithSessionID:(NSString*)sessionID SessionName:(NSString *)name type:(SessionType)type;
- (id)initWithSessionIDByUser:(MTTUserEntity*)user;
- (id)initWithSessionIDByGroup:(MTTGroupEntity*)group;
- (void)updateUpdateTime:(NSUInteger)date;
-(NSString *)getSessionGroupID;
-(void)setSessionName:(NSString *)theName;
-(BOOL)isGroup;
//-(id)dicToGroup:(NSDictionary *)dic;
//-(void)setSessionUser:(NSArray *)array;
@end
