//
//  CameraPhotoAlbumManager.m
//  PlamLive
//
//  Created by wangyadong on 2017/3/27.
//  Copyright © 2017年 wangyadong. All rights reserved.
//

#import "CameraPhotoAlbumManager.h"

@interface CameraPhotoAlbumManager ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property(nonatomic,copy)CameraPhotoAlbumBlock  pickerBlock;
@end


static CameraPhotoAlbumManager *manager = nil;

@implementation CameraPhotoAlbumManager

+(instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CameraPhotoAlbumManager alloc] init];
    });
    return manager;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)CameraPhotoAlbumForDelegate:(UIViewController*)delegate returnBlock:(CameraPhotoAlbumBlock)block{
    self.pickerBlock = block;
    [PLGlobalClass alertActionSheetWithDefaultTitles:@[@"拍照",@"相册选择"] cancelTitle:@"取消" forDelegate:delegate defaultActionBlock:^(NSInteger index) {
       
        //实例化
        UIImagePickerController * picker = [[UIImagePickerController alloc]init];
        //设置图片来源，相机或者相册
        //设置后续是否可编辑
        picker.allowsEditing = YES;
        //设置代理
        picker.delegate = self;
        if (index == 0) {
            //判断有无相机设备
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                //访问相机
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            }else{
                self.pickerBlock(nil,@"未开启相机");
                return ;
            }
        }else{
            if ([picker.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
                [picker.navigationBar setBarTintColor:[UIColor baseColor]];
                [picker.navigationBar setTranslucent:YES];
                [picker.navigationBar setTintColor:[UIColor whiteColor]];
                NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
                attrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
                [picker.navigationBar setTitleTextAttributes:attrs];
                
            }else{
                [picker.navigationBar setBackgroundColor:[UIColor redColor]];
            }
            //相册
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        [delegate presentViewController:picker animated:YES completion:nil];
    } cancelBlock:^{
        self.pickerBlock(nil,nil);
    }];
}

#pragma mark - 代理方法
//完成选择图片之后的回调,也就是点击系统自带的choose按钮之后调用的方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //获取选择的照片
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    self.pickerBlock(image,nil);
    [picker dismissViewControllerAnimated:YES completion:nil];
}
//取消选择
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.pickerBlock(nil,nil);
    [picker dismissViewControllerAnimated:YES completion:nil];

}




@end
