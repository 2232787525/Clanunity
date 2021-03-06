//
//  DeviceConfigure.m
//  Clanunity
//
//  Created by wangyadong on 2018/1/30.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import "DeviceConfigure.h"

@implementation DeviceConfigure

/**
 手机此刻的网络类型
 
 @return 2G，3G，4G，Wifi等并且带上信号强如量
 */

+ (NSString *)networkingStates{
    
    
    NSArray *children;
    UIApplication *app = [UIApplication sharedApplication];
    NSString *state = [[NSString alloc] init]; //iPhone X
    if ([[app valueForKeyPath:@"_statusBar"] isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]){
        
        children = [[[[app valueForKeyPath:@"_statusBar"] valueForKeyPath:@"_statusBar"] valueForKeyPath:@"foregroundView"] subviews];
        for (UIView *view in children) {
            for (id child in view.subviews) {
                //wifi
                if ([child isKindOfClass:NSClassFromString(@"_UIStatusBarWifiSignalView")]){
                    state = @"wifi";
                }
                //2G 3G 4G
                if ([child isKindOfClass:NSClassFromString(@"_UIStatusBarStringView")]){
                    if ([[child valueForKey:@"_originalText"] containsString:@"G"]) {
                        state = [child valueForKey:@"_originalText"];
                    }
                }
            }
        }
        if ([state length]==0) {
            state = @"无网络";
        }
    }else {
        
        children = [[[app valueForKeyPath:@"_statusBar"] valueForKeyPath:@"foregroundView"] subviews];
        for (id child in children) {
            if ([child isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) { //获取到状态栏
                //                NSLog(@"当前网络状态 ： %d",[[child valueForKeyPath:@"dataNetworkType"] intValue]);
                switch ([[child valueForKeyPath:@"dataNetworkType"] intValue]) {
                        
                    case 0: state = @"无网络"; //无网模式
                        break;
                    case 1: state = @"2G";
                        break;
                    case 2: state = @"3G";
                        break;
                    case 3: state = @"4G";
                        break;
                    case 5: state = @"wifi";
                        break;
                    default: break;
                }
            }
        }
        
    }
    return state;
    
    
    
    
}




//+(NSString *)networkingStates{
//
//    NSArray *subviews = nil;
//
//    if([DeviceConfig.iphoneModel isEqualToString: @"iPhone X"])
//    {
//        NSLog(@"1111 %@",DeviceConfig.iphoneModel);
//
////        return [[NSString alloc] initWithFormat:@"%@_%@", @"WiFi", wifiStrengthBars];
//        return @"4G";
//    }
//    NSLog(@"%@",DeviceConfig.iphoneModel);
//
//    NSLog(@"%@",[[UIApplication sharedApplication] valueForKey:@"statusBar"]);
//    if ([[[UIApplication sharedApplication] valueForKey:@"statusBar"] isKindOfClass:NSClassFromString(@"UIStatusBar_Modern")]) {
//
//
//        UIApplication *app = [UIApplication sharedApplication];
//
//        subviews = [[[[app valueForKey:@"statusBar"] valueForKey:@"statusBar"] valueForKey:@"foregroundView"]subviews];
//
//
//    }else{
//
//
//        subviews = [[[[UIApplication sharedApplication] valueForKey:@"statusBar"] valueForKey:@"foregroundView"]subviews];
//
//
//
//    }
//
//
//    NSNumber *dataNetworkItemView = nil;
//    NSNumber *signalStrengthItemView = nil;
//    for (id subview in subviews) {
//        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
//            dataNetworkItemView = subview;
//        }
//        if ([subview isKindOfClass:[NSClassFromString(@"UIStatusBarSignalStrengthItemView") class]]) {
//            signalStrengthItemView = subview;
//        }
//        if (dataNetworkItemView && signalStrengthItemView) {
//            break;
//        }
//    }
//
//    if (!dataNetworkItemView) {
//        return nil;
//    }
//
//    NSNumber *networkTypeNum = [dataNetworkItemView valueForKey:@"dataNetworkType"];
//    NSNumber *wifiStrengthBars = [dataNetworkItemView valueForKey:@"wifiStrengthBars"];
//    NSNumber *signalStrengthBars = [signalStrengthItemView valueForKey:@"signalStrengthBars"];
//    if (!networkTypeNum) {
//        return nil;
//    }
//
//    NSInteger networkType = [networkTypeNum integerValue];
//    switch (networkType) {
//        case 0:
//            return @"No Service";
//            break;
//
//        case 1:
//            return [[NSString alloc] initWithFormat:@"%@_%@", @"2G", signalStrengthBars];
//            break;
//
//        case 2:
//            return [[NSString alloc] initWithFormat:@"%@_%@", @"3G", signalStrengthBars];
//            break;
//
//        case 3:
//            return [[NSString alloc] initWithFormat:@"%@_%@", @"4G", signalStrengthBars];
//            break;
//
//        case 4:
//            return [[NSString alloc] initWithFormat:@"%@_%@", @"LTE", signalStrengthBars];
//            break;
//
//        case 5:
//            return [[NSString alloc] initWithFormat:@"%@_%@", @"WiFi", wifiStrengthBars];
//            break;
//        default:
//            return [[NSString alloc] initWithFormat:@"%@_%@_%@", networkTypeNum, wifiStrengthBars, signalStrengthBars];
//            break;
//    }
//
//
//
//
//
//}

@end
