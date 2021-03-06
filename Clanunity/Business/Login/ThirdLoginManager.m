//
//  ThirdLoginManager.m
//  PlamLive
//
//  Created by wangyadong on 2016/11/23.
//  Copyright © 2016年 wangyadong. All rights reserved.
//


#import "ThirdLoginManager.h"
#import "WXApi.h"
#import "WXApiObject.h"

#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentOAuthObject.h>
#import <TencentOpenAPI/TencentApiInterface.h>

@interface ThirdLoginManager ()<WXApiDelegate,TencentSessionDelegate>


/**QQ权限 */
@property (strong, nonatomic) NSArray * qqPermissions;

@property (nonatomic, strong) TencentOAuth * tencentOAuth;

@end

static ThirdLoginManager * manager = nil;


@implementation ThirdLoginManager

+(instancetype)shareInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ThirdLoginManager alloc] init];
    });
    return manager;
}

//从QQ或微信返回同宗汇时调用
-(BOOL)thirdApplication:(UIApplication *)application handleOpenURL:(NSURL *)url thirdType:(NSInteger)type{
    if (type == 1) {
        //TODO:这边设置了微信的代理
        return  [WXApi handleOpenURL:url delegate:self];
    }else{
        //TODO:这边获取QQ打开的权限
        return [TencentOAuth HandleOpenURL:url];
    }
}

#pragma mark - 微信登录
-(void)thirdWeChatLoginWithResultBlock:(ThirdLoginResultBlock)block{
    self.resultBlock = block;
    _type = 2;
    _openid = nil;
    _head = nil;
    _code = nil;
    if ([WXApi isWXAppInstalled]) {
        
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"wx85c752c2b9fd1176";
        [WXApi sendReq:req];
    }else{
        self.resultBlock(0, @"未安装微信", nil);
    }
}

#pragma mark - QQ登录
-(void)thirdQQLoginWithResultBlock:(ThirdLoginResultBlock)block{
    self.resultBlock = block;
    _type = 3;
    _openid = nil;
    _head = nil;
    _code = nil;
    if ([TencentOAuth iphoneQQInstalled]){
        self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:ThirdKey.QQAppId andDelegate:self];
        self.qqPermissions = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_INFO, kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, nil];
        [self.tencentOAuth setAuthShareType:AuthShareType_QQ];
        
        BOOL auth = [self.tencentOAuth authorize:self.qqPermissions localAppId:ThirdKey.QQAppId inSafari:NO];
        NSLog(@"qq第三方调起  %@",@(auth));
        
    }else{
        self.resultBlock(0, @"未安装QQ", nil);
    }
}

#pragma mark - - qq TencentSessionDelegate
#pragma mark - - qq 登录回调
-(void)tencentDidLogin{
    if (_tencentOAuth.accessToken.length > 0) {
        // 获取用户信息
        NSString *code = [_tencentOAuth getServerSideCode];
        NSLog(@"%@",code);
        NSLog(@"%@",_tencentOAuth.openId);
        if (![_tencentOAuth getUserInfo]) {
            self.resultBlock(0, @"获取用户信息失败", nil);
        }
    } else {
        NSLog(@"登录不成功 没有获取accesstoken");
        self.resultBlock(0, @"失败", nil);
    }
}
-(void)tencentDidNotLogin:(BOOL)cancelled{
    self.resultBlock(0, @"取消", nil);
}
-(void)tencentDidNotNetWork{
    self.resultBlock(0, @"取消", nil);
}

-(NSArray *)getAuthorizedPermissions:(NSArray *)permissions withExtraParams:(NSDictionary *)extraParams{
    return self.qqPermissions;
};
/** QQ登录成功拿到用户信息 */
-(void)getUserInfoResponse:(APIResponse *)response{
    NSDictionary *jsonDicE = response.jsonResponse;
    NSString *qq1 = jsonDicE[@"figureurl_qq_1"];
    NSString *qq2 = jsonDicE[@"figureurl_qq_2"];
    _head = qq2 != nil ? qq2:qq1 ;
    _head = _head.length > 0 ? _head : @"";
    _openid = self.tencentOAuth.openId.length > 0 ? self.tencentOAuth.openId : @"";
    NSLog(@"+++response");
    self.resultBlock(1,@"成功",@{@"openid":self.tencentOAuth.openId,@"headimg":_head});
}

#pragma mark --  wxApiDelegate
/**
 *如果第三方程序向微信发送了sendReq的请求，那么onResp会被回调。
 *sendReq请求调用后，会切到微信终端程序界面。
 */
-(void) onResp:(BaseResp*)resp
{
    if ([resp isKindOfClass:[SendAuthResp class]]) {   //授权登录的类。
        if (resp.errCode == 0) {  //成功。
            //这里处理回调的方法。通过代理吧对应的登录消息传送过去。
            SendAuthResp *resp2 = (SendAuthResp *)resp;
            NSLog(@"%@",resp2.code);
            _code = resp2.code;
            self.resultBlock(1, @"成功", resp2.code);
            
        }else{ //失败
            //-2取消
            if (resp.errCode == -2) {
                self.resultBlock(0, @"取消登录", nil);
            }else{
                self.resultBlock(0, @"登录失败", nil);
            }
        }
    }else if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        
        if (resp.errCode == 0) {  //成功。
            self.shareSucceedBlock();
        }
        
    }else{
        NSLog(@"resp的类别是什么  %@",resp);
    }
}

@end
