//
//  DeviceConfigure.h
//  Clanunity
//
//  Created by wangyadong on 2018/1/30.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//
#pragma mark -  设置相关的信息 - 一般在swift中DeviceConfig没办法做出的方法等可以在这里完善添加
#import <Foundation/Foundation.h>

@interface DeviceConfigure : NSObject

/**
 手机此刻的网络类型

 @return 2G，3G，4G，Wifi等并且带上信号强如量
 */
+(NSString *)networkingStates;

@end
