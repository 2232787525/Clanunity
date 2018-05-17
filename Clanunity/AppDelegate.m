//
//  AppDelegate.m
//  Clanunity
//
//  Created by wangyadong on 2018/1/29.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//
//TODO:前往登录页面
/*
 
 同宗汇 登录流程
 
 1：获取验证码登录，登录成功后拿到登录标识 token，以及相关的用户信息usermodel
 
 2：判断用户信息，如果没有 姓氏，地址，相关信息，那么说明没有完善信息，就需要走完善信息。
 
 3：如果信息完善就可以直接到首页
 
 4：没有完善信息需要先完善信息
 
 启动流程： 判断手机是否保存登录标识 token
 
 1: token != "0" 那么已经登录，直接到首页
 2: token = "0" 那么没有登录，去登录页面
 
 注意： 在首页的动态接口，这么说，底层的接口会有状态码判断，如果登录了，但是姓氏，地址等用户关键信息没有，会根据相应的状态来做出相应的跳转，完善信息去
 */

#import "AppDelegate.h"
#import "DeviceConfigure.h"
#import "ChinaCityModel.h"
#import "XHlaunchAdManager.h"
#import "ThirdLoginManager.h"
#import "NSDictionary+Safe.h"
#import "DDClientStateMaintenanceManager.h"
#import "IMBaseDefine.pb.h"
#import "MTTSessionEntity.h"
#import "ChattingMainViewController.h"
#import "LoginModule.h"
#import "SendPushTokenAPI.h"
#import "FreshApplyMsgListVC.h"
#import <UserNotifications/UserNotifications.h>

#import <AFNetworking/AFNetworking.h>


#import "WXApi.h"

@interface AppDelegate ()<UNUserNotificationCenterDelegate,QQApiInterfaceDelegate>
@property (strong, nonatomic) NoticeModel *remoteModel;

@end

@implementation AppDelegate

//TODO:前往tabbar跟视图
-(void)gotoTabbarVC{
    if (self.window.rootViewController == nil) {
        //没有跟视图或者跟视图是登录时，直接设跟视图
        KBaseTabbarViewController *vc = [[KBaseTabbarViewController alloc]init];
        self.window.rootViewController = vc;
    }else if([self.window.rootViewController isKindOfClass:[KBaseTabbarViewController class]]&&[[PLGlobalClass currentViewController] isKindOfClass:[ClanLoginManagerVC class]]){
        //跟视图是tabber，并且当前页面是登录页，dissmiss
        KBaseTabbarViewController *tabbar = (KBaseTabbarViewController *)self.window.rootViewController;
        tabbar.selectedIndex = 0;
        [[PLGlobalClass currentViewController] dismissViewControllerAnimated:true completion:nil];
    }else if(![self.window.rootViewController isKindOfClass:[KBaseTabbarViewController class]]&&[[PLGlobalClass currentViewController] isKindOfClass:[ClanLoginManagerVC class]]){
        KBaseTabbarViewController *vc = [[KBaseTabbarViewController alloc]init];
        self.window.rootViewController = vc;
    }
}

-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    NSLog(@"willFinishLaunchingWithOptions===> %@",launchOptions);
    //广告页面以及引导页
    [XHlaunchAdManager shareManager];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //IM ----------------
    [DDClientStateMaintenanceManager shareInstance];
    [RuntimeStatus instance];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    //这个判断是在程序没有运行的情况下收到通知，点击通知跳转页面
    if (launchOptions) {
        NSDictionary * remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (remoteNotification) {
            if ([remoteNotification[@"type"] isEqualToString:@"10"]) {
                
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                [user setObject:@"1" forKey:@"NewFriendRedPoint"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NewFriendRedPoint" object:nil];
                
                
            }else{
                [self insertModel:remoteNotification];
            }
        }
    }

    [self appConfigThirdSDKWithOptions:launchOptions];
    //监听网络变化
    [self configureNetworkStatus];

    //登录
    if ([LoginServer share].islogin) {
        KBaseTabbarViewController *vc = [[KBaseTabbarViewController alloc]init];
        self.window.rootViewController = vc;
        [self loginIM];
    }else{
        //显示登录
        [[LoginServer share] showLoginVCWithBlock:^(NSInteger status) {
        }];
    }
    // 移除webview cache
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    BOOL closeNotice = [PLGlobalClass getValueFromFile:[CUKey kStartupInfo] withKey:[CUKey kStartupInfo_CloseNotice]];
    if (closeNotice == YES){
    }else{
        [self registerNotfication];
    }
    
    if( SYSTEM_VERSION >=8 ) {
        [[UINavigationBar appearance] setTranslucent:YES];
    }
    
    [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    //----------------------
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)registerNotfication{
    // 推送消息的注册方式
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // for iOS 8
        UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

-(void)loginIM{
    //登录 - 用户名密码
    [[LoginModule instance] loginWithUsername:[UserServre shareService].userModel.username password:CUKey.TT_DEFAULT_PSD success:^(MTTUserEntity *user) {
        if (user) {
            NSLog(@"◊◊◊◊IM_TT 登录成功");
            TheRuntime.loginSuccess = YES;
            TheRuntime.user = user;
            [TheRuntime updateData];
            if (TheRuntime.pushToken) {
                SendPushTokenAPI *pushtoken = [[SendPushTokenAPI alloc] init];
                [pushtoken requestWithObject:TheRuntime.pushToken Completion:^(id response, NSError *error) {
                    NSLog(@"%@",response);
                }];
            }    
        }
           
    } failure:^(NSString *error) {
        NSLog(@"◊◊◊◊IM_TT 登录失败");
        TheRuntime.loginSuccess = NO;

    }];
}


#pragma mark - 配置注册第三方sdk
-(void)appConfigThirdSDKWithOptions:(NSDictionary *)launchOptions{
   
    IQKeyboardManager *iqManager = [IQKeyboardManager sharedManager];
    iqManager.enable = YES;
    iqManager.overrideKeyboardAppearance = YES;
    iqManager.shouldResignOnTouchOutside = YES;//点击屏幕隐藏键盘
    iqManager.enableAutoToolbar = NO;//工具栏
    iqManager.keyboardDistanceFromTextField = 0;//当你的输入框被键盘覆盖后页面会自动上移,上移的距离
    iqManager.toolbarDoneBarButtonItemText = @"完成";
    //TODO:注册微信appid
    [WXApi registerApp:ThirdKey.WeXAppId];
    
    //TODO:通知、推送设置
    UNUserNotificationCenter *center=[UNUserNotificationCenter currentNotificationCenter];
    center.delegate=self;
    //友盟推送 适配Https
    [UMessage startWithAppkey:ThirdKey.UMAppKey launchOptions:launchOptions httpsEnable:YES];
    [UMessage registerForRemoteNotifications];
    
    UNAuthorizationOptions types10=UNAuthorizationOptionBadge|  UNAuthorizationOptionAlert|UNAuthorizationOptionSound;
    [center requestAuthorizationWithOptions:types10     completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            //点击允许
            //这里可以添加一些自己的逻辑
        } else {
            //点击不允许
            //这里可以添加一些自己的逻辑
        }}];
    [UMessage openDebugMode:NO];
}

#pragma mark - 配置 监测网络状态的改变
- (void)configureNetworkStatus{
    
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];//开始监视
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (self.networkStatus == status) {
            return ;
        }
        self.networkStatus = status;
//        if (status == 0) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"未连接到网络，请检查您的网络设置" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles: nil];
//            [alert show];
//        }
//        switch (status) {
//            case -1:
//                NSLog(@"未知网络状态");//-1
//                break;
//            case 0:
//                NSLog(@"无网络");//0
//                break;
//            case 1:
//                NSLog(@"蜂窝数据网");//1
//                break;
//            case 2:
//                NSLog(@"WiFi网络");//2
//                break;
//            default:
//                break;
//        }
    }] ;
}

#pragma mark - 通知
//iOS10新增：处理前台收到通知的代理方法
//(捕捉PLChatHelper里的showNotificationWithMessage发的通知并显示)
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    
    NSDictionary *userInfo = notification.request.content.userInfo;
    //{
    //    aps =     {
    //        alert = bbbbbb;
    //    };
    //    d = umsncwf152265496319200;
//    uushbe4152385895301410
    //    id = 111;
    //    p = 0;
    //    type = 1 系统消息（跟姓氏和个人都没有关系的通用通知） 2 动态评论通知  3 系统消息（跟姓氏或个人有关系的通知）
    //}

    if ([userInfo[@"type"] isEqualToString:@"10"]) {
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setObject:@"1" forKey:@"NewFriendRedPoint"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewFriendRedPoint" object:nil];
       
    }else{
        [self insertModel:userInfo];
        
        if ([[PLGlobalClass currentViewController]isKindOfClass:[NoticeList class]]){
            NoticeList *vc = (NoticeList *)[PLGlobalClass currentViewController];
            [vc reloadTableViewWithNewData];
        }else{
            if (@available(iOS 10.0, *)) {
                completionHandler(UNNotificationPresentationOptionAlert);
            } else {
            }
        }
    }
    
    
    
    //友盟
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于前台时的远程推送接受
        //关闭U-Push自带的弹出框
        [UMessage setAutoAlert:NO];
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
    }else{
        //应用处于前台时的本地推送接受
    }
}

//iOS10新增：点击通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    
    NSMutableDictionary * userInfo = (NSMutableDictionary *)response.notification.request.content.userInfo;
    //友盟
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于后台时的远程推送接受 //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
    }else{
        //应用处于后台时的本地推送接受
    }
    
    if ([userInfo[@"type"] isEqualToString: @"10"]) {
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setObject:@"1" forKey:@"NewFriendRedPoint"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewFriendRedPoint" object:nil];
        if ([[PLGlobalClass currentViewController]isKindOfClass:[FreshApplyMsgListVC class]]){
        }else{
            FreshApplyMsgListVC *vc = [[FreshApplyMsgListVC alloc] init];
            UINavigationController *nav = [PLGlobalClass currentViewController].navigationController;
            if(nav == nil){
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
                [[PLGlobalClass currentViewController] presentViewController:nav animated:YES completion:nil];
            }else{
                [nav pushViewController:vc animated:YES];
            }
            
        }
        
    }else{
        [self insertModel:userInfo];
        
        if ([[PLGlobalClass currentViewController]isKindOfClass:[NoticeList class]]){
        }else{
            UINavigationController *nav = [PLGlobalClass currentViewController].navigationController;
            if(nav == nil){
                UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[NoticeList new]];
                [[PLGlobalClass currentViewController] presentViewController:nav animated:YES completion:nil];
            }else{
                [nav pushViewController:[NoticeList new] animated:YES];
            }
        }
    }
    
    
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [UIApplication sharedApplication].applicationIconBadgeNumber ++;
}

-(void)insertModel:(NSDictionary *)userInfo{
    NoticeModel *model = [[NoticeModel alloc]init];
    model.date = [NSString timeStringyyyyMMddHHmmssWithDate:[NSDate date]];
    model.id = userInfo[@"id"];
    model.d = userInfo[@"d"];
    model.type = [userInfo[@"type"] intValue];
    model.alert = userInfo[@"aps"][@"alert"];
    if (model.type == 1){
        model.username = @"";
    }else{
        model.username = [UserServre shareService].userModel.username;
    }
    [NoticeModel insertModel:model];
    
    [PLGlobalClass writeToFile:[CUKey kStartupInfo] withKey:[CUKey kNewMessage] value:@"1"];
}

#pragma mark - 跳转第三方App
//重写handleOpenURL和openURL方法、openURL是IOS9的方法
-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSString *urlCodeString = [NSString stringWithFormat:@"%@",url];
    NSString *wx = [urlCodeString substringToIndex:18];
    NSString *tencentqq = [urlCodeString substringToIndex:17];
    if ([tencentqq isEqualToString:@"tencent1106744398"]) {
        return [[ThirdLoginManager shareInstance] thirdApplication:application handleOpenURL:url thirdType:0];
    }else
        if ([wx isEqualToString:@"wx85c752c2b9fd1176"]){
            
            return [[ThirdLoginManager shareInstance] thirdApplication:application handleOpenURL:url thirdType:1];
        }
    return YES;
}
#ifdef IOS9
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    NSString *urlCodeString = [NSString stringWithFormat:@"%@",url];
    NSString *wx = [urlCodeString substringToIndex:18];
    NSString *tencentqq = [urlCodeString substringToIndex:17];
    if ([tencentqq isEqualToString:@"tencent1106744398"]) {
        return [[ThirdLoginManager shareInstance] thirdApplication:app handleOpenURL:url thirdType:0];
    }else
        if ([wx isEqualToString:@"wx85c752c2b9fd1176"]){
            return [[ThirdLoginManager shareInstance] thirdApplication:app handleOpenURL:url thirdType:1];
        }
    return YES;
}
#endif

#pragma mark - 第三方分享返回后的回调方法，在此设置了QQ的代理
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nonnull id)annotation
{
    NSString *urlCodeString = [NSString stringWithFormat:@"%@",url];
    NSString *wx = [urlCodeString substringToIndex:18];
    NSString *tencentqq = [urlCodeString substringToIndex:17];
    if ([tencentqq isEqualToString:@"tencent1106744398"]) {
        [QQApiInterface handleOpenURL:url delegate:self];
        return [[ThirdLoginManager shareInstance] thirdApplication:app handleOpenURL:url thirdType:0];
    }else
        if ([wx isEqualToString:@"wx85c752c2b9fd1176"]){
            return [[ThirdLoginManager shareInstance] thirdApplication:app handleOpenURL:url thirdType:1];
        }
    return YES;
}

#pragma mark - TTIM 相关
//获取pushToken
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
    NSString *dt = [token stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    NSString *dn = [dt stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.deviceToken = [dn stringByReplacingOccurrencesOfString:@" " withString:@""];
    TheRuntime.pushToken= [dn stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"deviceToken:__________     %@",TheRuntime.pushToken);
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSString *error_str = [NSString stringWithFormat: @"%@", error];
    NSLog(@"获取令牌失败 TheRuntime.pushToken:  %@",error_str);
}

// 处理推送消息
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    UIApplicationState state =application.applicationState;
    if ( state != UIApplicationStateBackground) {
        return;
    }
    //这都是服务端给的数据定义：custom，from_id，group_id，msg_type都是前后约定好的字段
    NSString *jsonString = [userInfo safeObjectForKey:@"custom"];
    NSData* infoData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* info = [NSJSONSerialization JSONObjectWithData:infoData options:0 error:nil];
    NSInteger from_id =[[info safeObjectForKey:@"from_id"] integerValue];
    SessionType type = (SessionType)[[info safeObjectForKey:@"msg_type"] integerValue];
    NSInteger group_id =[[info safeObjectForKey:@"group_id"] integerValue];
    if (from_id) {
//        NSInteger sessionId = type==1?from_id:group_id;
//        MTTSessionEntity *session = [[MTTSessionEntity alloc] initWithSessionID:[MTTUtil changeOriginalToLocalID:(UInt32)sessionId SessionType:(int)type] type:type] ;
//        [[ChattingMainViewController shareInstance] showChattingContentForSession:session];
    }
    
    //友盟接收到消息的方法
    [UMessage didReceiveRemoteNotification:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.window endEditing:YES];
}


-(void)onResp:(QQBaseResp *)resp{
    if ([resp isKindOfClass:[SendMessageToQQResp class]]){
        if ([resp.result intValue] == 0){
            NSLog(@"分享成功，分享次数增加");
            self.shareSucceedBlock();
        }
    }
}

@end
