//
//  AppDelegate.h
//  Clanunity
//
//  Created by wangyadong on 2018/1/29.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import "UMessage.h"//友盟推送


@class KBaseTabbarViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (copy, nonatomic) NSString * _Nonnull deviceToken;

@property (strong, nonatomic) UIWindow * _Nonnull window;

/**当前网络状态 */ //0无网络 1流量 2无线
@property(nonatomic,assign)NSInteger networkStatus;

//分享成功的回调
@property(nonatomic,copy)void(^ _Nullable shareSucceedBlock)(void);

//TODO:前往tabbar跟视图
-(void)gotoTabbarVC;

-(void)loginIM;
/**分享到qq，在PLShareGlobalView中无法调起qq，只能在这里，此bug有待解决 */
- (void)shareToQQWithShareType:(ShareThirdType)shareType shareObjc:(QQApiObject *_Nullable)shareObjc;
-(void)registerNotfication;
@end

