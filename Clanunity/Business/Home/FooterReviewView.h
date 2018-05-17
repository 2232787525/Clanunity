//
//  TextFieldView.h
//  Bike51
//
//  Created by wangyadong on 16/9/9.
//  Copyright © 2016年 wangyadong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewInputView : UIView<UITextFieldDelegate>

@property(nonatomic,copy,nonnull)NSString * placeStr;
@property(nonatomic,strong,nonnull)UIButton * cancle;
@property(nonatomic,strong,nonnull)UILabel * titleLab;
@property(nonatomic,strong,nonnull)UIButton * send;
@property(nonatomic,strong,nonnull)UITextField * inputText;
@property(nonatomic,assign)BOOL clear;
@property(nonatomic,assign)BOOL ifReadTheText; //是否读取上一次未发送的评论内容

-(void)textFiedlChanged;

@end

@class commentInputView;
@interface commentInputView : UIScrollView
@property(nonatomic,strong)ReviewInputView * inputView;

+(instancetype)shareInstance;

//ifSingleType 1 没有取消按钮 0 正常显示
-(void)showcommentViewWithmsg:(NSString *)msg ifSingleType:(BOOL)ifSingleType SendText:(void (^)(NSString * _Nonnull))block;

-(void)deallocRemove;
@end
