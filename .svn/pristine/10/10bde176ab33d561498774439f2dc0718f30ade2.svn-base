//
//  ZHX_HUDView.m
//  ZHX
//
//  Created by 阿虎 on 14-1-6.
//  Copyright (c) 2014年 阿虎. All rights reserved.
//

#import "WFHudView.h"

@implementation WFHudView


//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}

+(void)showMsg:(NSString *)msg inView:(UIView*)theView
{
    
    WFHudView * alert = [[WFHudView alloc] initWithMsg:msg];

    if (!theView){
        [[self getUnhiddenFrontWindowOfApplication] addSubview:alert];
    }
    else{
        for (UIView *view in [theView subviews]) {
            if ([view isKindOfClass:[WFHudView class]]) {
                [view removeFromSuperview];
            }
        }
        [[WFHudView getWindow] addSubview:alert];
    }
    if ([msg length]>0) {
        [alert showAlert];
    }
   
}
-(void)showAlert
{
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
    self.alpha = 0.0;
    CGPoint center = [WFHudView getWindow].center;
    //    //调整位置
    //    center.y -= (int)((SCREEN_HEIGHT - self.frame.size.height) / 164.0f * 36 / 2);
    self.center=center;
    CAKeyframeAnimation* opacityAnimation= [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    
    opacityAnimation.duration = _totalDuration;
    opacityAnimation.cumulative = YES;
    opacityAnimation.repeatCount = 1;
    opacityAnimation.removedOnCompletion = NO;
    opacityAnimation.fillMode = kCAFillModeBoth;
    opacityAnimation.values = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.2],
                               [NSNumber numberWithFloat:0.92],
                               [NSNumber numberWithFloat:0.92],
                               [NSNumber numberWithFloat:0.1], nil];
    
    opacityAnimation.keyTimes = [NSArray arrayWithObjects:
                                 [NSNumber numberWithFloat:0.0f],
                                 [NSNumber numberWithFloat:0.08f],
                                 [NSNumber numberWithFloat:0.92f],
                                 [NSNumber numberWithFloat:1.0f], nil];
    
    opacityAnimation.timingFunctions = [NSArray arrayWithObjects:
                                        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                                        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], nil];
    
    
    CAKeyframeAnimation* scaleAnimation =[CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.duration = _totalDuration;
    scaleAnimation.cumulative = YES;
    scaleAnimation.repeatCount = 1;
    scaleAnimation.removedOnCompletion = NO;
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.values = [NSArray arrayWithObjects:
                             [NSNumber numberWithFloat:self.animationTopScale],
                             [NSNumber numberWithFloat:1.0f],
                             [NSNumber numberWithFloat:1.0f],
                             [NSNumber numberWithFloat:self.animationTopScale],
                             nil];
    
    scaleAnimation.keyTimes = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0f],
                               [NSNumber numberWithFloat:0.085f],
                               [NSNumber numberWithFloat:0.92f],
                               [NSNumber numberWithFloat:1.0f], nil];
    
    scaleAnimation.timingFunctions = [NSArray arrayWithObjects:
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                      [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], nil];
    
    
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = _totalDuration;
    group.delegate = self;
    group.animations = [NSArray arrayWithObjects:opacityAnimation,scaleAnimation, nil];
    [self.layer addAnimation:group forKey:@"group"];
    
}


-(id)initWithMsg:(NSString*)msg
{
    static dispatch_once_t onceToken;
    static WFHudView *alert = nil;
    
    dispatch_once(&onceToken, ^{
        alert = [super init];
        
        UILabel *labelText = [[UILabel alloc] init];
        labelText.numberOfLines = 0;
        msgFont = [UIFont systemFontOfSize:14.0f];
        labelText.font = msgFont;
        labelText.backgroundColor = [UIColor clearColor];
        labelText.textColor = [UIColor whiteColor];
        labelText.textAlignment = NSTextAlignmentCenter;
        alert.labelText = labelText;
        [alert  addSubview:labelText];
    });
    
    if (alert ) {
        alert.leftMargin = 20;
        alert.topMargin = 10;
        
        alert.msg = msg;
        alert.totalDuration = 1.5f;
        alert.animationTopScale = 1.2;
        alert.animationLeftScale = 1.2;
        alert.bounds = CGRectMake(0, 0, 180, 50);

        alert.labelText.text = msg;
        CGSize textSize = [self getSizeFromString:msg];
        
        if (textSize.height > 32) {
            [alert.labelText setFrame:CGRectMake((180 - textSize.width) / 2, 8,textSize.width, textSize.height)];
            alert.height_sd = [self getSizeFromString:msg].height+10;
        }else{
            alert.labelText.height_sd = 32;
            alert.labelText.width_sd = 180;
            alert.labelText.left_sd = 0;
            alert.labelText.top_sd = 9;
        }
        alert.layer.cornerRadius = 10;
        
    }
    return alert;
}

//-(void)setMsg:(NSString *)msg{
//    _msg = msg;
//    _labelText.text = msg;
//    CGSize textSize = [self getSizeFromString:msg];
//
//    if ([self getSizeFromString:msg].height > 32) {
//        [_labelText setFrame:CGRectMake((180 - textSize.width) / 2, 8,textSize.width, textSize.height)];
//    }
//}

+(UIWindow *) getUnhiddenFrontWindowOfApplication{
    NSArray *windows = [[UIApplication sharedApplication] windows];
    NSInteger windowCnt = [windows count];
    for (NSInteger i = windowCnt - 1; i >= 0; i--) {
        UIWindow* window = [windows objectAtIndex:i];
        if (FALSE == window.hidden) {
            //定制：防止产生bar提示，用的是新增window,排除这个window
            if (window.frame.size.height > 50.0f) {
                return window;
            }
        }
    }
    return NULL;
}

+(UIWindow*)getWindow
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    return window;
}

-(CGSize)getSizeFromString:(NSString*)_theString
{
    if (!msgFont) {
        msgFont = [UIFont systemFontOfSize:14.0f];
    }
    CGSize size = CGSizeMake(160, 2000);
    
   CGSize tempSize = [_theString boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:msgFont} context:nil].size;
    
    return tempSize;
}

-(void)dealloc
{
}
@end
