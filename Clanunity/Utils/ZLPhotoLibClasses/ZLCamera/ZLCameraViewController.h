//
//  BQCamera.h
//  BQCommunity
//
//  Created by ZL on 14-9-11.
//  Copyright (c) 2014年 beiqing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLCamera.h"

typedef void(^codeBlock)();
typedef void(^ZLComplate)(id object);



@interface ZLCameraViewController : UIViewController

/**
 *  打开相机
 *
 *  @param viewController 控制器
 *  @param complate       成功后的回调
 */
- (void)startCameraOrPhotoFileWithViewController:(UIViewController*)viewController complate : (ZLComplate ) complate;
@property (strong, nonatomic) UIViewController *currentViewController;

-(void)takePhoto;

// 完成后回调
@property (copy, nonatomic) ZLComplate complate;

//限制参数  不设置默认 最多选取9 张
@property (assign ,nonatomic) NSInteger maxCanSelecrted;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
