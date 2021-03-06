//
//  ThirdLoginManager.h
//  PlamLive
//
//  Created by wangyadong on 2016/11/23.
//  Copyright © 2016年 wangyadong. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 第三方结果

 @param type 类型 1成功，0失败
 @param masg 消息
 @param result 返回结果
 */
typedef void(^ThirdLoginResultBlock)(NSInteger type, NSString * _Nullable masg,id _Nullable result);


@interface ThirdLoginManager : NSObject

+(instancetype _Nonnull )shareInstance;

/**2微信，3qq
 {type:2/3,code:@“wsss”,head:@"",@"openid":@"23332222"}
 */

/**
 2微信，3qq
 */
@property(nonatomic,assign,readonly)NSInteger type;
@property(nonatomic,copy,readonly)NSString *_Nullable code;
@property(nonatomic,copy,readonly)NSString *_Nullable openid;
@property(nonatomic,copy,readonly)NSString *_Nullable head;

//第三方回调
@property(nonatomic,copy)ThirdLoginResultBlock resultBlock;
//微信分享成功的回调
@property(nonatomic,copy)void(^ _Nullable shareSucceedBlock)(void);

/**
 appdelegate 中与微信客户端app之间切换
 @param application app
 @param url URL
 @param type 0qq，1微信
 @return yes/no
 */
-(BOOL)thirdApplication:(UIApplication *_Nullable)application handleOpenURL:(NSURL *_Nullable)url thirdType:(NSInteger)type;


/**
 第三方 微信 登录

 @param block 回调 result里面是code
 */
-(void)thirdWeChatLoginWithResultBlock:(ThirdLoginResultBlock _Nonnull )block;

/**
 第三方 qq 登录

 @param block 回调 result里面是 openid和headimg
 */
-(void)thirdQQLoginWithResultBlock:(ThirdLoginResultBlock _Nonnull)block;

@end
