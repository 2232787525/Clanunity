//
//  CGImageGIFView.m
//  LoadGIF
//
//  Created by ZhengWei on 16/4/26.
//  Copyright © 2016年 Bourbon. All rights reserved.
//
// 陈丹丹 你好 漂亮啊！
#import "CGImageGIFView.h"
#import <ImageIO/ImageIO.h>
@interface CGImageGIFView ()
{
    //gif的字典属性，定义了gif的一些特殊内容，这里虽然设置了，但是没啥特殊设置，一般情况下可以设置为NULL
    NSDictionary *gifProperties;
    size_t index;
    size_t count;
    CGImageSourceRef gifRef;
    NSTimer *timer;
}
@property (nonatomic,assign,readwrite) BOOL isAnimating;

@property(nonatomic,weak)UIView * topView;

@end

static CGImageGIFView *gifView = nil;

@implementation CGImageGIFView



+(instancetype)gifViewShowSuperView:(UIView *)view{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"jiazai-" ofType:@"gif"];
    CGImageGIFView *gifView =[[CGImageGIFView alloc] initWithGIFPath:path];
    
    CGPoint point = view.center;
    [gifView setCenter:CGPointMake(point.x,point.y -20)];
    [view addSubview:gifView];
    return gifView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithGIFPath:(NSString *)path
{
    if (self = [super init]) {
        
        //设置gif的属性来获取gif的图片信息
        NSDictionary *loopDic = [NSDictionary dictionaryWithObject:@0 forKey:(NSString *)kCGImagePropertyGIFLoopCount];
        gifProperties = [NSDictionary dictionaryWithObject:loopDic forKey:(NSString *)kCGImagePropertyGIFDictionary];
        //这个是拿到图片的信息
        gifRef = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path], (CFDictionaryRef)gifProperties);
        //这个拿到的是图片的张数，一张gif其实内部是有好几张图片组合在一起的，如果是普通图片的话，拿到的数就等于1
        count = CGImageSourceGetCount(gifRef);
        
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        self.frame = CGRectMake(0, 0, image.size.width/2.0+5, image.size.height/2.0+5);
        self.isAnimating = NO;
    }
    return self;
}
-(void)startGIF
{
    //开始动画，启动一个定时器，每隔一段时间调用一次方法，切换图片
    if (timer == nil) {
        timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(play) userInfo:nil repeats:YES];
    }
    [timer fire];
    self.isAnimating = YES;
}
-(void)play
{
    index = index + 1;
    index=  index % count;
    //方法的内容是根据上面拿到的imageSource来获取gif内部的第几张图片，拿到后在进行layer重新填充
    CGImageRef currentRef = CGImageSourceCreateImageAtIndex(gifRef, index, (CFDictionaryRef)gifProperties);
    self.layer.contents = (id)CFBridgingRelease(currentRef);
}
-(void)stopGIF
{
    //停止定时器
    self.isAnimating = NO;
    [timer invalidate];
    timer = nil;
}
@end
