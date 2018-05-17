//
//  AmbitionTextView.m
//  PlamLive
//
//  Created by wangyadong on 2016/12/21.
//  Copyright © 2016年 wangyadong. All rights reserved.
//

#import "AmbitionTextView.h"

@interface AmbitionTextView ()<UITextViewDelegate>


@property(nonatomic,strong)UILabel * placelb;


@end

@implementation AmbitionTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.maxCount = -1;
        UIView *topline = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.width_sd, 0.5)];
        topline.backgroundColor = [UIColor clearColor];
        [self addSubview:topline];
        self.topLine = topline;
        
        UIView *bottomline = [[UIView alloc] initWithFrame:CGRectMake(0, self.height_sd-0.5,self.width_sd, 0.5)];
        bottomline.backgroundColor = [UIColor clearColor];
        [self addSubview:bottomline];
        self.bottomLine = bottomline;
        self.placelb = [[UILabel alloc] initWithFrame:CGRectMake(14,10+8, self.width_sd-20, 15)];
        self.placelb.textColor = [UIColor textColor3];
        self.placelb.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.placelb];
        self.placelb.numberOfLines = 0;
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, self.width_sd-20, self.height_sd-20)];
        self.textView.textColor = [UIColor textColor3];
        self.textView.font = [UIFont systemFontOfSize:14];
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.delegate = self;
        [self addSubview:self.textView];
        
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        if(self.indexOfTextView == 0){
            self.indexOfTextView = 100 ;
        }
    }
    return self;
}

-(void)setPlaceHolder:(NSString *)placeHolder{
    _placeHolder = placeHolder;
    CGSize size = [PLGlobalClass sizeWithText:placeHolder font:[UIFont systemFontOfSize:14] width:self.placelb.width_sd height:MAXFLOAT];
    self.placelb.height_sd = size.height;
    self.placelb.text = placeHolder;
}
-(void)setMarginEdgeInsets:(UIEdgeInsets)marginEdgeInsets{
    _marginEdgeInsets = marginEdgeInsets;
    self.textView.top_sd = marginEdgeInsets.top;
    self.textView.left_sd = marginEdgeInsets.left;
    self.textView.width_sd = self.width_sd-marginEdgeInsets.left-marginEdgeInsets.right;
    self.textView.height_sd = self.height_sd - marginEdgeInsets.top-marginEdgeInsets.bottom;
    self.placelb.top_sd = self.textView.top_sd+8;
    self.placelb.left_sd = self.textView.left_sd+4;
    self.placelb.width_sd = self.textView.width_sd-10;
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    if (textView.isFirstResponder) {
        if (self.textViewShouldBeginEdit&&textView == self.textView) {
            self.textViewShouldBeginEdit();
        }
        return NO;
        
    }
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    NSMutableString* textString = [NSMutableString stringWithString:textView.text];
    [textString replaceCharactersInRange:range withString:text];
    if ([text isEqualToString:@" "]) {//输入的是空格，就不要
        return NO;
    }
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    if (self.maxCount > 0 && range.location > self.maxCount-1) {
        return NO;
    }
    
    return YES;
}
-(void)textViewDidChange:(UITextView *)textView{
    
    NSInteger number = [textView.text length];
    if (number > self.indexOfTextView) {
        textView.text = [textView.text substringToIndex:self.indexOfTextView];
    }
    if (self.textViewValueChanged) {
        self.textViewValueChanged();
    }
    if (textView.text.length==0){//textview长度为0
            self.placelb.hidden=NO;//隐藏文字
    }else{
        self.placelb.hidden=YES;
    }
}

-(void)setTextString:(NSString *)textString{
    _textString = textString;
    self.placelb.hidden = YES;
    self.textView.text = [NSString stringWithFormat:@"%@%@",self.textView.text,textString];
}
#pragma mark - 键盘通知
- (void)keyboardNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    if ([self.textView isFirstResponder]) {
        if (self.keyBoardNotificationBlock) {
            self.keyBoardNotificationBlock(keyboardRect);
        }
    }
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
