//
//  TextFieldView.m
//  Bike51
//
//  Created by wangyadong on 16/9/9.
//  Copyright © 2016年 wangyadong. All rights reserved.
//

#import "FooterReviewView.h"

//MARK: - 评论输入框View

@implementation ReviewInputView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor bgColor2];
    self.cancle = [[UIButton alloc] initWithFrame:CGRectMake(12,0, 44, 40)];
    [self.cancle setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancle setTitleColor:[UIColor textColor2] forState:UIControlStateNormal];
    self.cancle.titleLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:self.cancle];
    
    self.titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0,0, 100,20)];
    self.titleLab.text = @"评论";
    self.titleLab.font = [UIFont systemFontOfSize:16];
    self.titleLab.textColor = [UIColor textColor1];
    self.titleLab.textAlignment = NSTextAlignmentCenter;
    self.titleLab.centerX_sd = self.width_sd/2.0;
    self.titleLab.centerY_sd = self.cancle.centerY_sd;
    [self addSubview:self.titleLab];
    
    self.send = [[UIButton alloc] initWithFrame:self.cancle.bounds];
    [self.send setTitle:@"发布" forState:UIControlStateNormal];
    [self.send setTitleColor:[UIColor textColor2] forState:UIControlStateNormal];
    self.send.titleLabel.font = [UIFont systemFontOfSize:15];
    self.send.right_sd = self.width_sd-12;
    self.send.centerY_sd = self.cancle.centerY_sd;
    self.send.layer.cornerRadius = 3;
    self.send.clipsToBounds = YES;
    [self addSubview:self.send];
    
    self.inputText = [[UITextField alloc] initWithFrame:CGRectMake(12, self.cancle.bottom_sd, self.width_sd-24, 65)];
    self.inputText.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.inputText];
    self.inputText.font = [UIFont systemFontOfSize:14];
    self.inputText.layer.cornerRadius = 3;
    self.inputText.clipsToBounds = YES;
    self.inputText.layer.borderColor = [UIColor cutLineColor].CGColor;
    self.inputText.layer.borderWidth = 0.5;
    [self.inputText addTarget:self action:@selector(textFiedlChanged) forControlEvents:(UIControlEventEditingChanged)];
    [self.inputText setValue:[UIColor textColor2] forKeyPath:@"_placeholderLabel.textColor"];
    self.inputText.returnKeyType = UIReturnKeySend;
    
    self.cancle.hidden = YES;
    self.titleLab.hidden = YES;
    
    self.inputText.width_sd = 289 * kScreenScale;
    self.inputText.height_sd = 44 * kScreenScale;
    self.inputText.top_sd = 18 * kScreenScale;
    self.send.backgroundColor = [UIColor whiteColor];
    
    self.send.top_sd = self.inputText.top_sd;
    self.send.left_sd = self.inputText.right_sd + 5;
    self.send.width_sd = KScreenWidth - self.send.left_sd - 12;
    self.send.height_sd = self.inputText.height_sd;
    return self;
}

-(void)textFiedlChanged{
    if ([[NSString trimString:self.inputText.text] length]>0){
        self.send.backgroundColor = [UIColor baseColor];
        [self.send setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.send.userInteractionEnabled = YES;
    }else{
        self.send.backgroundColor = [UIColor whiteColor];
        [self.send setTitleColor:[UIColor textColor1] forState:UIControlStateNormal];
        self.send.userInteractionEnabled = NO;
    }
}

//MARK: - 输入框代理方法
//-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    return YES;
//}
//
//
//-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    return YES;
//}

@end


@interface commentInputView()<UITextFieldDelegate>
@property(nonatomic,strong)UIView *backView;
@property(nonatomic,copy)void(^ _Nullable sendTempText)(NSString* _Nonnull text);

@end

static commentInputView * commentView = nil;

@implementation commentInputView

+(instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        commentView = [[commentInputView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        [APPDELEGATE.window addSubview:commentView];
    });
    return commentView;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.backView = [[UIView alloc] initWithFrame:self.bounds];
        self.backView.backgroundColor = [UIColor blackColor];
        [self addSubview:self.backView];
        WeakSelf;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            [weakSelf hidden];
        }];
        [self.backView addGestureRecognizer:tap];
        
        self.inputView = [[ReviewInputView alloc] initWithFrame:CGRectMake(0, KScreenHeight -  140+65+15 - KTopHeight, KScreenWidth, 40+65+15)];
        [self addSubview:self.inputView];
        [self.inputView.cancle handleEventTouchUpInsideCallback:^{
            [weakSelf hidden];
            weakSelf.inputView.inputText.text = nil;
        }];
        self.inputView.inputText.delegate = self;

        [self.inputView.send handleEventTouchUpInsideCallback:^{
            [weakSelf send];
        }];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoard:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoard:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self send];
    return YES;
}

//TODO:发送
-(void)send{
    if (self.sendTempText && [self.inputView.inputText.text length]>0) {
        NSString *sendStr = self.inputView.inputText.text;
        if ([[NSString trimString:sendStr] length]>0){
            sendStr = [NSString trimString:sendStr];
        }
        if ([sendStr length] > 0){
            self.sendTempText(sendStr);
            self.inputView.clear = NO;
        }
        [self hidden];
        self.inputView.inputText.text = nil;
    }
}

-(void)deallocRemove{
    [self removeFromSuperview];
}


//ifSingleType 1 没有取消按钮 0 正常显示
-(void)showcommentViewWithmsg:(NSString *)msg ifSingleType:(BOOL)ifSingleType SendText:(void (^)(NSString * _Nonnull))block{
    [APPDELEGATE.window addSubview:commentView];
    self.sendTempText = block;
    
    if (ifSingleType){

        self.inputView.height_sd = 79 * kScreenScale;

        self.inputView.inputText.placeholder = msg;
        if(self.inputView.ifReadTheText){
            if ([[NSString trimString:self.inputView.inputText.text] length] == 0){
                self.inputView.clear = NO;
            }
        }else{
            self.inputView .inputText.text = @"";
            self.inputView.clear = NO;
        }
        [self.inputView textFiedlChanged];

    }else{
        self.inputView.cancle.hidden = NO;
        self.inputView.titleLab.hidden = NO;
        self.inputView.titleLab.text = msg;
        self.inputView.send.backgroundColor = [UIColor clearColor];
        self.inputView.frame = CGRectMake(0, KScreenHeight -  140+65+15 - KTopHeight, KScreenWidth, 40+65+15);
        self.inputView.inputText.frame = CGRectMake(12, self.inputView.cancle.bottom_sd, self.inputView.width_sd-24, 65);
        self.inputView.send.bounds = self.inputView.cancle.bounds;
        self.inputView.send.right_sd = self.inputView.width_sd-12;
        self.inputView.send.centerY_sd = self.inputView.cancle.centerY_sd;
        self.inputView.placeStr = @"";
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.backView.alpha = 0.25;
        self.alpha = 1;
    } completion:^(BOOL finished) {
    }];

    [self.inputView.inputText becomeFirstResponder];
}


-(void)hidden{
    [self.inputView.inputText resignFirstResponder];
    [self removeFromSuperview];
}



#pragma mark - 键盘通知
-(void)keyBoard:(NSNotification *)notification{
    //获取userInfo
    NSDictionary *userInfo = [notification userInfo];
    //获取键盘的size
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];    //键盘的y偏移量

    //键盘弹出的时间
    float duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];

    //界面偏移动画
    [UIView animateWithDuration:duration animations:^{
        self.inputView.bottom_sd = keyboardRect.origin.y;
    }];
}







@end


