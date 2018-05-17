//
//  PopupView.m
//  PlamLive
//
//  Created by wangyadong on 2017/3/14.
//  Copyright © 2017年 wangyadong. All rights reserved.
//

#import "PopupView.h"


@interface PopupView ()
@property (nonatomic, weak)UIViewController *parentVC;

@property(nonatomic,assign)id<LewPopupAnimation>animation;

@end

@implementation PopupView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame parentVC:(UIViewController *)parentVC dismissAnimation:(id<LewPopupAnimation>)animation{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.parentVC = parentVC;
        self.animation = animation;
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(popupViewTap)];
//        [self addGestureRecognizer:tapGesture];
    }
    return self;
}
-(void)popupViewTap{
    [self dismissClicked];
}
-(void)dismissClicked{
    if (_animation) {
        [_parentVC lew_dismissPopupViewWithanimation:_animation];
    }
}
@end
