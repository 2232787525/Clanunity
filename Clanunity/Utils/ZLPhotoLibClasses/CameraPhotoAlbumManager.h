//
//  CameraPhotoAlbumManager.h
//  PlamLive
//
//  Created by wangyadong on 2017/3/27.
//  Copyright © 2017年 wangyadong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CameraPhotoAlbumBlock)(UIImage*pickerImg,NSString*message);

@interface CameraPhotoAlbumManager : NSObject

+(instancetype)shareManager;
-(void)CameraPhotoAlbumForDelegate:(UIViewController*)delegate returnBlock:(CameraPhotoAlbumBlock)block;

@end
