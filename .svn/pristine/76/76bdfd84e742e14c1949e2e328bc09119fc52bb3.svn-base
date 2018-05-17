//
//  BQImageView.m
//  BQCommunity
//
//  Created by TJQ on 14-8-5.
//  Copyright (c) 2014年 beiqing. All rights reserved.
//

#import "ZLCameraImageView.h"

@interface ZLCameraImageView ()

@property (assign, nonatomic) CGPoint point;

@property (strong, nonatomic) UIImageView *deleBjView;

@property (weak, nonatomic) UIView *mView;
/**
 *  记录所有的图片显示标记
 */
@property (strong, nonatomic) NSMutableArray *images;

@end

@implementation ZLCameraImageView


- (UIImageView *)deleBjView{
    if (!_deleBjView) {
        _deleBjView = [[UIImageView alloc] init];
        _deleBjView.image = [UIImage imageNamed:@"X"];
        _deleBjView.width_sd = 25;
        _deleBjView.height_sd = 25;
        _deleBjView.hidden = YES;
        _deleBjView.left_sd = 50;
        _deleBjView.top_sd = 0;
        _deleBjView.userInteractionEnabled = YES;
        [_deleBjView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleImage:)]];
        [self addSubview:_deleBjView];
    }
    return _deleBjView;
}

- (void)setEdit:(BOOL)edit{
    self.deleBjView.hidden = NO;
}

- (void)dealloc{
    [self.layer removeAllAnimations];
    
}


- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

#pragma mark 删除图片
- (void) deleImage : ( UITapGestureRecognizer *) tap{
    if ([self.delegatge respondsToSelector:@selector(deleteImageView:)]) {
        [self.delegatge deleteImageView:self];
    }
}

- (void)drawRect:(CGRect)rect{
    
}

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
