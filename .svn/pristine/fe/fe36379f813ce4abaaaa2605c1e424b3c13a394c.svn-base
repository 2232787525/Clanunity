//
//  AppDefine.h
//  Clanunity
//
//  Created by wangyadong on 2018/1/29.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#pragma mark -  一些在OC中使用的宏定义

#ifndef AppDefine_h
#define AppDefine_h


#define WeakSelf __weak typeof(self) weakSelf = self;

#define APPDELEGATE ((AppDelegate*)[[UIApplication sharedApplication] delegate])

//-------------------获取设备大小-------------------------
// 动态获取屏幕宽高
#define KScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define KScreenWidth  ([UIScreen mainScreen].bounds.size.width)
#define KIPHONE_X   ([[UIScreen mainScreen] bounds].size.height == 812 ? YES : NO)

#define kScreenScale KScreenWidth/375.0

// NavBar高度
#define KNavigationBarHeight (44.0)
// 状态栏高度
#define KStatusBarHeight (KIPHONE_X == YES ? 44.0 : 20.0)
// 顶部高度
#define KTopHeight (KNavigationBarHeight + KStatusBarHeight)

// 底部 TabBar 高度
#define KTabBarHeight (49.0)
//底部虚拟状态高
#define KBottomStatusH (KIPHONE_X == YES ? 34.0 : 0.0)
//底部高
#define KBottomHeight (KTabBarHeight + KBottomStatusH)

#define  IsEmptyStr(string) string == nil || string == NULL || [string isEqualToString:@""] ||[string isKindOfClass:[NSNull class]]||[[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0 ? YES : NO


#define MyLog(format, ...)








#endif /* AppDefine_h */
