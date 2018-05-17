//
//  UIImage+Utilities.h
//  yixin_iphone
//
//  Created by zqf on 13-1-18.
//  Copyright (c) 2013年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Util)
- (UIImage *)scaleWithMaxPixels: (CGFloat)maxPixels;

- (UIImage *)scaleToSize:(CGSize)newSize;

- (UIImage *)externalScaleSize: (CGSize)scaledSize;

- (UIImage *)thumb;

- (UIImage *)thumbForSNS: (NSInteger)count;

- (UIImage *)makeImageRounded;


- (BOOL)saveToFilepathWithFullQuality: (NSString *)filepath; //全质量

- (BOOL)saveToFilepathWithPng:(NSString*)filepath; //png

- (UIImage *)fixOrientation;/**<  拍照时防止照片旋转  */

+(UIImage *)drowAImage:(UIImage*)img;/**< 截取方形图片  */

+ (UIImage *)mergeImagesToBoxStyle: (NSArray *)images;

/// 不指定resizableImageWithCapInsets第2拉伸参数的时候，用的是平铺模式遇到大图片的拉伸时GPU卡爆，所以构造了本方法
- (UIImage *)resizableImageWithCapInsetsForStretch:(UIEdgeInsets)capInsets;

+(NSArray *)procesPic:(NSArray*)imgArr;
+(UIImage *) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size;
//指定宽度按比例缩放
+(UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth;

//TODO: 图片方向修正 变形拉伸修复 适合于加载图片时发生变形拉伸方向错乱的状况
- (UIImage *)normalizedImage;

//传入图片放缓一个像素大小的UIImage图片
+(UIImage*)imageWithColor:(UIColor*)color;
@end

