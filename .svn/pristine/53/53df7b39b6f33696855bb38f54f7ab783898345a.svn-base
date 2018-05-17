//
//  DDUserModule.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "DDUserModule.h"
#import "MTTDatabaseUtil.h"
#import "MTTNotification.h"

@interface DDUserModule(PrivateAPI)


- (void)n_receiveUserLogoutNotification:(NSNotification*)notification;
- (void)n_receiveUserLoginNotification:(NSNotification*)notification;
@end

@implementation DDUserModule
{
    NSMutableDictionary* _allUsers;
    NSMutableDictionary* _allUsersNick;
    
}

-(NSMutableDictionary *)allFriends{
    if (_allFriends == nil) {
        _allFriends = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return  _allFriends;
}
-(NSMutableDictionary *)allFriendsNick{
    if (_allFriendsNick == nil) {
        _allFriendsNick = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _allFriendsNick;
}


+ (instancetype)shareInstance
{
    static DDUserModule* g_userModule;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_userModule = [[DDUserModule alloc] init];
    });
    return g_userModule;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _allUsers = [[NSMutableDictionary alloc] init];
        _recentUsers = [[NSMutableDictionary alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveUserLoginNotification:) name:DDNotificationUserLoginSuccess object:nil];
        //用户断线重连成功 收到通知更新
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(n_receiveUserLoginNotification:) name:DDNotificationUserReloginSuccess object:nil];        
    }
    return self;
}

-(void)addMyFriend:(MTTUserEntity *)friendEntity{
    if (!friendEntity) {
        return;
    }
    [self.allFriends setValue:friendEntity forKey:friendEntity.objID];
    [self.allFriendsNick setValue:friendEntity forKey:friendEntity.nick];
    
}
- (void)addMaintanceUser:(MTTUserEntity*)user
{
    
    if (!user)
    {
        return;
    }
    if (!_allUsers)
    {
        _allUsers = [[NSMutableDictionary alloc] init];
    }
    if(!_allUsersNick)
    {
        _allUsersNick = [[NSMutableDictionary alloc] init];
    }
    [_allUsers setValue:user forKey:user.objID];
    [_allUsersNick setValue:user forKey:user.nick];
    
}
-(NSArray *)getAllUsersNick
{
    return [_allUsersNick allKeys];
}
-(MTTUserEntity *)getUserByNick:(NSString *)nickName
{
//    NSInteger index = [[self getAllUsersNick] indexOfObject:nickName];
    return [_allUsersNick objectForKey:nickName];
}
-(NSArray *)getAllMaintanceUser
{
    return [_allUsers allValues];
}
- (void )getUserForUserID:(NSString*)userID Block:(void(^)(MTTUserEntity *user))block
{
    
    if ([userID isEqualToString: [MTTUtil changeOriginalToLocalID:(UInt32)[UserServre shareService].userModel.teamid SessionType:1]]) {
        MTTUserEntity *user = [[MTTUserEntity alloc] initWithUserID:userID name:[UserServre shareService].userModel.username nick:[UserServre shareService].userModel.nickname avatar:[UserServre shareService].userModel.headimg userRole:1 userUpdated:0];
        return block(user);
    }
    return block(_allUsers[userID]);
}
- (void)addRecentUser:(MTTUserEntity*)user
{
    if (!user)
    {
        return;
    }
    if (!self.recentUsers)
    {
        self.recentUsers = [[NSMutableDictionary alloc] init];
    }
    NSArray* allKeys = [self.recentUsers allKeys];
    if (![allKeys containsObject:user.objID])
    {
        [self.recentUsers setValue:user forKey:user.objID];
        [[MTTDatabaseUtil instance] insertUsers:@[user] completion:^(NSError *error) {
            
        }];
    }
   
}

/**
 加载本地联系人

 @param completion <#completion description#>
 */
- (void)loadAllRecentUsers:(DDLoadRecentUsersCompletion)completion
{
    //加载本地最近联系人
}

#pragma mark - 
#pragma mark PrivateAPI

- (void)n_receiveUserLogoutNotification:(NSNotification*)notification
{
    //用户登出
    _recentUsers = nil;
}

/**
 重新连接成功

 @param notification 通知
 */
- (void)n_receiveUserLoginNotification:(NSNotification*)notification
{
    if (!_recentUsers)
    {
        _recentUsers = [[NSMutableDictionary alloc] init];
        [self loadAllRecentUsers:^{
            [MTTNotification postNotification:DDNotificationRecentContactsUpdate userInfo:nil object:nil];
        }];
    }
}

-(void)clearRecentUser
{
    DDUserModule* userModule = [DDUserModule shareInstance];
    [[userModule recentUsers] removeAllObjects];
}

@end
