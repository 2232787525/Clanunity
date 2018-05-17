//
//  PopupView.h
//  PlamLive
//
//  Created by wangyadong on 2017/3/14.
//  Copyright © 2017年 wangyadong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+LewPopupViewController.h"
#import "LewPopupViewAnimationFade.h"
#import "LewPopupViewAnimationSlide.h"
#import "LewPopupViewAnimationSpring.h"
#import "LewPopupViewAnimationDrop.h"
@interface PopupView : UIView
-(instancetype)initWithFrame:(CGRect)frame parentVC:(UIViewController*)parentVC dismissAnimation:(id<LewPopupAnimation>)animation;
//消失的方法
-(void)dismissClicked;
//view的整体点击事件
-(void)popupViewTap;

@end

/*
 
 LewPopupViewAnimationSlide *animation = [[LewPopupViewAnimationSlide alloc]init];
 animation.type = LewPopupViewAnimationSlideTypeBottomBottom;
 
 */
