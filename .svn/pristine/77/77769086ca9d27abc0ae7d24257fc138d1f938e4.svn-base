//
//  AmbitionTextView.h
//  PlamLive
//
//  Created by wangyadong on 2016/12/21.
//  Copyright © 2016年 wangyadong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AmbitionTextView : UIView

/**
 textview距离上下左右的距离，默认（10，10，10，10）
 */
@property(nonatomic,assign)UIEdgeInsets marginEdgeInsets;
@property(nonatomic,copy)NSString * placeHolder;
@property(nonatomic,strong)UITextView * textView;
@property(nonatomic,copy)NSString * textString;
@property(nonatomic,copy)void(^keyBoardNotificationBlock)(CGRect rect);

/**
 输入最多字数；
 */
@property(nonatomic,assign)NSInteger maxCount;
@property(nonatomic,weak)UIView * topLine;
@property(nonatomic,weak)UIView * bottomLine;
@property(nonatomic,assign)NSInteger indexOfTextView;
@property(nonatomic,copy)void(^textViewShouldBeginEdit)(void);
@property(nonatomic,copy)void(^textViewValueChanged)(void);

@end
