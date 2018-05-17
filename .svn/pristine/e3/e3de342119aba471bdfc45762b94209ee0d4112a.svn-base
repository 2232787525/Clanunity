//
//  KBaseClanViewController.h
//  Clanunity
//
//  Created by wangyadong on 2018/1/31.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

#define SHOW_HUD [MBProgressHUD showHUDAddedTo:self.view animated:YES];
#define HIDDEN_HUD      [MBProgressHUD hideHUDForView:self.view animated:YES];

@interface KBaseClanViewController : UIViewController

/**
 增加frame
 
 @param frame frame
 @return self
 */
-(instancetype)initWithFrame:(CGRect)frame;

@property(nonatomic,assign)CGRect frame;

@property(nonatomic,weak)KBaseClanViewController * fatherSuperVC;

-(void)kNotifiLoginSuccess;

/**
 退出登录
 */
-(void)kNoticeLogoutSuccess;

-(void)showGifView;

-(void)hiddenGifView;


//字数限制
//手机号限制11位
-(void)wordlimitTelephoneWithTf:(id)tf;
//标题限制30位
-(void)wordlimitTitleWithTf:(id)tf;
//名字昵称限制8位
-(void)wordlimitNameWithTf:(id)tf;
//人数限制4位 几千人
-(void)wordlimitNumOfPeopleWithTf:(id)tf;
@end
