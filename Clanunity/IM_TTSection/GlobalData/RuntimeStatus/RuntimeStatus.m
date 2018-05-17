//
//  RuntimeStatus.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-07-31.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "RuntimeStatus.h"
#import "MTTUserEntity.h"
#import "DDGroupModule.h"
#import "DDMessageModule.h"
#import "DDClientStateMaintenanceManager.h"
#import "NSString+Additions.h"
#import "ReceiveKickoffAPI.h"
#import "LogoutAPI.h"
#import "DDClientState.h"
#import "IMLogin.pb.h"
#import <AFNetworking/AFNetworking.h>
#import "MTTSignNotifyAPI.h"
#import "MTTPCLoginStatusNotifyAPI.h"
#import "MTTUtil.h"

@interface RuntimeStatus()

@end

@implementation RuntimeStatus
-(void)setUser:(MTTUserEntity *)user{
    _user = user;
    self.userID = user.objID;
}
+ (instancetype)instance
{
    static RuntimeStatus* g_runtimeState;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_runtimeState = [[RuntimeStatus alloc] init];
        
    });
    return g_runtimeState;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.user = [MTTUserEntity new];
        [self registerAPI];//注册api
    }
    return self;
}

-(void)registerAPI
{
    //接收踢出
    ReceiveKickoffAPI *receiveKick = [ReceiveKickoffAPI new];
    [receiveKick registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
        NSLog(@"NOTICE账号被踢了");
        [[NSNotificationCenter defaultCenter] postNotificationName:DDNotificationUserKickouted object:object];
    }];
    //接收签名改变通知
    MTTSignNotifyAPI *receiveSignNotify = [MTTSignNotifyAPI new];
    [receiveSignNotify registerAPIInAPIScheduleReceiveData:^(id object, NSError *error) {
        NSLog(@"NOTICE签名改变");
        [[NSNotificationCenter defaultCenter] postNotificationName:DDNotificationUserSignChanged object:object];
    }];
}

-(void)updateData
{
    //消息模块
    [DDMessageModule shareInstance];
    //连接模块
    [DDClientStateMaintenanceManager shareInstance];
    //群模块
    [DDGroupModule instance];
}


@end
