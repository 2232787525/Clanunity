//
//  DDLoginManager.m
//  Duoduo
//
//  Created by 独嘉 on 14-4-5.
//  Copyright (c) 2015年 MoguIM All rights reserved.
//

#import "LoginModule.h"
#import "DDHttpServer.h"
#import "DDMsgServer.h"
#import "DDTcpServer.h"
#import "SpellLibrary.h"
#import "DDUserModule.h"
#import "MTTUserEntity.h"
#import "DDClientState.h"
#import "RuntimeStatus.h"
#import "ContactsModule.h"
#import "MTTDatabaseUtil.h"
#import "DDAllUserAPI.h"
#import "LoginAPI.h"
#import "MTTNotification.h"
#import "SessionModule.h"
#import "DDGroupModule.h"
#import "MTTUtil.h"

@interface LoginModule(privateAPI)

//- (void)p_loadAfterHttpServerWithToken:(NSString*)token userID:(NSString*)userID dao:(NSString*)dao password:(NSString*)password uname:(NSString*)uname success:(void(^)(MTTUserEntity* loginedUser))success failure:(void(^)(NSString* error))failure;
//- (void)reloginAllFlowSuccess:(void(^)(void))success failure:(void(^)(void))failure;

@end

@implementation LoginModule
{
    NSString* _lastLoginUser;       //最后登录的用户ID
    NSString* _lastLoginPassword;
    NSString* _lastLoginUserName;
    NSString* _dao;
    NSString * _priorIP;
    NSInteger _port;
    BOOL _relogining;
}
+ (instancetype)instance
{
    static LoginModule *g_LoginManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_LoginManager = [[LoginModule alloc] init];
    });
    return g_LoginManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _httpServer = [[DDHttpServer alloc] init];
        _msgServer = [[DDMsgServer alloc] init];
        _tcpServer = [[DDTcpServer alloc] init];
        _relogining = NO;
    }
    return self;
}


#pragma mark Public API
- (void)extracted:(void (^)(NSString *))failure name:(NSString *)name password:(NSString *)password success:(void (^)(MTTUserEntity *))success {
    WeakSelf;
    [_msgServer checkUserID:name Pwd:password token:@"" success:^(id object) {
        [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"password"];
        [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"username"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"autologin"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        _lastLoginPassword=password;
        _lastLoginUserName=name;
        DDClientState* clientState = [DDClientState shareInstance];
        clientState.userState=DDUserOnline;
        _relogining=YES;
        MTTUserEntity* user = object[@"user"];
        TheRuntime.user=user;
        //打开数据库
        [[MTTDatabaseUtil instance] openCurrentUserDB];
        [weakSelf loadAllFriends];

        [[SessionModule instance] loadLocalSession:^(bool isok) {}];
        success(user);
        [MTTNotification postNotification:DDNotificationUserLoginSuccess userInfo:nil object:user];
        
    } failure:^(NSError *object) {
        
        DDLog(@"login#登录验证失败");
        
        failure(object.domain);
    }];
}
-(void)loadAllFriends{
    
    [[MTTDatabaseUtil instance] getAllUsers:^(NSArray *contacts, NSError *error){
        //数据库里面没有 ,数据缓存里面拿数据
        if ([contacts count] !=0) {
            [contacts enumerateObjectsUsingBlock:^(MTTUserEntity *obj, NSUInteger idx, BOOL *stop) {
                [[DDUserModule shareInstance] addMaintanceUser:obj];
            }];
        }else{
        }
    }];
    
    [ClanAPI requestForMyFriendListWithPage:1 pageSize:10000 result:^(ClanAPIResult * _Nonnull result) {
       
        if ([result.status isEqualToString:@"200"]) {
            NSArray *array = [MTTUserEntity mj_objectArrayWithKeyValuesArray:result.data[@"list"]];
            for (MTTUserEntity *model in array) {
                model.realname = model.remark;
                model.name = model.username;
                model.avatar = model.headimg;
                model.nick = model.remark;
                model.objID = [MTTUserEntity pbUserIdToLocalID:model.teamid];
            }
            [[MTTDatabaseUtil instance] insertAllUser:array completion:^(NSError *error) {
            }];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [array enumerateObjectsUsingBlock:^(MTTUserEntity *obj, NSUInteger idx, BOOL *stop) {
                    [[DDUserModule shareInstance] addMaintanceUser:obj];
                }];
            });
            
            
            
            
            
        }else{
        }
    }];
    
    
    
}


- (void)loginWithUsername:(NSString*)name password:(NSString*)password success:(void(^)(MTTUserEntity* loginedUser))success failure:(void(^)(NSString* error))failure
{
    
    [_httpServer getMsgIp:^(NSDictionary *dic) {
        NSInteger code  = [[dic objectForKey:@"code"] integerValue];
        if (code == 0) {
            _priorIP = [dic objectForKey:@"priorIP"];
            _port    =  [[dic objectForKey:@"port"] integerValue];
            [MTTUtil setMsfsUrl:[dic objectForKey:@"msfsPrior"]];
            
            [_tcpServer loginTcpServerIP:_priorIP port:_port Success:^{
                [self extracted:failure name:name password:password success:success];

            } failure:^(NSError *error) {
                DDLog(@"连接消息服务器失败");
                failure(@"连接消息服务器失败");
            }];
        }
    } failure:^(NSString *error) {
         failure(@"连接消息服务器失败");
    }];
    
}

- (void)reloginSuccess:(void(^)(void))success failure:(void(^)(NSString* error))failure
{
    //DDLog(@"relogin fun重新登录");
    if ([DDClientState shareInstance].userState == DDUserOffLine && _lastLoginPassword && _lastLoginUserName) {
        
        [self loginWithUsername:_lastLoginUserName password:_lastLoginPassword success:^(MTTUserEntity *user) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CUKey.ReloginSuccess object:nil];
            success();
        } failure:^(NSString *error) {
            failure(@"重新登陆失败");
        }];

    }
}

- (void)offlineCompletion:(void(^)(void))completion
{
    completion();
}

/**
 *  登录成功后获取所有用户
 *
 *  @param completion 异步执行的block
 */
- (void)p_loadAllUsersCompletion:(void(^)(void))completion
{
    __block NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    __block NSInteger version = [[defaults objectForKey:@"alllastupdatetime"] integerValue];
    [[MTTDatabaseUtil instance] getAllUsers:^(NSArray *contacts, NSError *error) {
        if ([contacts count] !=0) {
            [contacts enumerateObjectsUsingBlock:^(MTTUserEntity *obj, NSUInteger idx, BOOL *stop) {
                [[DDUserModule shareInstance] addMaintanceUser:obj];
            }];
            if (completion !=nil) {
                completion();
            }
        }else{
            version=0;
            DDAllUserAPI* api = [[DDAllUserAPI alloc] init];
            [api requestWithObject:@[@(version)] Completion:^(id response, NSError *error) {
                if (!error)
                {
                    NSUInteger responseVersion = [[response objectForKey:@"alllastupdatetime"] integerValue];
                    if (responseVersion == version && responseVersion !=0) {
                        
                        return ;
                        
                    }
                    [defaults setObject:@(responseVersion) forKey:@"alllastupdatetime"];
                    NSMutableArray *array = [response objectForKey:@"userlist"];
                    [[MTTDatabaseUtil instance] insertAllUser:array completion:^(NSError *error) {
                        
                    }];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [array enumerateObjectsUsingBlock:^(MTTUserEntity *obj, NSUInteger idx, BOOL *stop) {
                            [[DDUserModule shareInstance] addMaintanceUser:obj];
                        }];
                        
                        dispatch_async(dispatch_get_main_queue(),^{
                            if (completion !=nil) {
                                completion();
                            }
                        });
     
                    });
                    
                    
                }
            }];
        }
    }];
    
    DDAllUserAPI* api = [[DDAllUserAPI alloc] init];
    [api requestWithObject:@[@(version)] Completion:^(id response, NSError *error) {
        if (!error)
        {
            NSUInteger responseVersion = [[response objectForKey:@"alllastupdatetime"] integerValue];
            if (responseVersion == version && responseVersion !=0) {
                
                return ;

            }
            [defaults setObject:@(responseVersion) forKey:@"alllastupdatetime"];
            NSMutableArray *array = [response objectForKey:@"userlist"];
            [[MTTDatabaseUtil instance] insertAllUser:array completion:^(NSError *error) {
                
            }];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [array enumerateObjectsUsingBlock:^(MTTUserEntity *obj, NSUInteger idx, BOOL *stop) {
                    [[DDUserModule shareInstance] addMaintanceUser:obj];
                }];
            });
            
            
        }
    }];
    
}

-(void)p_loadAllMyFriendsCompletion:(void(^)(void))completion{
    __block NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    __block NSInteger version = [[defaults objectForKey:@"alllastupdatetime"] integerValue];
    [[MTTDatabaseUtil instance] getAllFriends:^(NSArray *contacts, NSError *error) {
        if ([contacts count] !=0) {
            [contacts enumerateObjectsUsingBlock:^(MTTUserEntity *obj, NSUInteger idx, BOOL *stop) {
                [[DDUserModule shareInstance] addMaintanceUser:obj];
            }];
            if (completion !=nil) {
                completion();
            }
        }
        
        
        
        
        
        
        
    }];
   
    
    
    
    
    
}


@end
