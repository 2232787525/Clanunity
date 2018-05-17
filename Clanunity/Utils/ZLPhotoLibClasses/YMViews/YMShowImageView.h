//
//  YMShowImageView.h
//  WFCoretext
//
//  Created by 阿虎 on 14/11/3.
//  Copyright (c) 2014年 tigerwf. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef  void(^didRemoveImage)(void);

typedef enum {
    CarCirclImageType,
    HeadImageImageType,
    HidenBarType,
    
}ImageURlAlterRule;//枚举名称

@interface YMShowImageView : UIView<UIScrollViewDelegate>
{
    UIImageView *showImage;
}
@property (nonatomic,copy) didRemoveImage removeImg;

- (void)show:(UIView *)bgView didFinish:(didRemoveImage)tempBlock;

- (id)initWithFrame:(CGRect)frame byClick:(NSInteger)clickTag appendArray:(NSArray *)appendArray ImageType:(ImageURlAlterRule)rule;

@end
