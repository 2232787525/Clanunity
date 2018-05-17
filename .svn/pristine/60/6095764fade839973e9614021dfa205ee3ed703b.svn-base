//
//  DDDDChatUtilityViewController.m
//  IOSDuoduo
//
//  Created by 东邪 on 14-5-23.
//  Copyright (c) 2014年 dujia. All rights reserved.
//
#import "ChatUtilityViewController.h"
#import "ChattingMainViewController.h"
#import "DDSendPhotoMessageAPI.h"
#import "ChattingMainViewController.h"
#import "DDMessageSendManager.h"
#import "MTTPhotosCache.h"
#import "MTTShakeAPI.h"
#import <Masonry/Masonry.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ChatUtilityViewController ()
@property(nonatomic,strong)NSArray *itemsArray;
@property(nonatomic,strong)UIView *rightView;
@end

@implementation ChatUtilityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    MTT_WEAKSELF(ws);
    [super viewDidLoad];
    
    self.view.backgroundColor=RGB(244, 244, 246);
    
    UIView *topLine = [UIView new];
    [topLine setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
    
    UIView *leftView = [UIView new];
    [self.view addSubview:leftView];
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(ws.view);
        make.height.equalTo(ws.view);
        make.top.equalTo(ws.view);
        make.width.equalTo(ws.view).multipliedBy(0.25);
    }];
    
    UIButton *takePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:takePhotoBtn];
    [takePhotoBtn setBackgroundImage:[UIImage imageNamed:@"chat_take_photo"] forState:UIControlStateNormal];
    [takePhotoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(leftView);
        make.top.mas_equalTo(15);
        make.size.mas_equalTo(CGSizeMake(65, 65));
    }];
//    [takePhotoBtn setClipsToBounds:YES];
//    [takePhotoBtn.layer setCornerRadius:5];
//    [takePhotoBtn.layer setBorderWidth:0.5];
//    [takePhotoBtn.layer setBorderColor:RGB(174, 177, 181).CGColor];
    
    [takePhotoBtn addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *takePhotoLabel = [UILabel new];
    [takePhotoLabel setText:@"拍照"];
    [takePhotoLabel setTextAlignment:NSTextAlignmentCenter];
    [takePhotoLabel setFont:systemFont(13)];
    [takePhotoLabel setTextColor:RGB(174, 177, 181)];
    [self.view addSubview:takePhotoLabel];
    [takePhotoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(leftView);
        make.top.mas_equalTo(takePhotoBtn.mas_bottom).offset(15);
        make.width.equalTo(leftView);
        make.height.mas_equalTo(13);
    }];
    
    UIView *middleView = [UIView new];
    [self.view addSubview:middleView];
    [middleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftView.mas_right);
        make.height.equalTo(ws.view);
        make.top.equalTo(ws.view);
        make.width.equalTo(ws.view).multipliedBy(0.25);
    }];
    
    UIButton *choosePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:choosePhotoBtn];
    [choosePhotoBtn setBackgroundImage:[UIImage imageNamed:@"chat_pick_photo"] forState:UIControlStateNormal];
    [choosePhotoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(middleView);
        make.top.mas_equalTo(15);
        make.size.mas_equalTo(CGSizeMake(65, 65));
    }];
//    [choosePhotoBtn setClipsToBounds:YES];
//    [choosePhotoBtn.layer setCornerRadius:5];
//    [choosePhotoBtn.layer setBorderWidth:0.5];
//    [choosePhotoBtn.layer setBorderColor:RGB(174, 177, 181).CGColor];
    [choosePhotoBtn addTarget:self action:@selector(choosePicture:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *choosePhotoLabel = [UILabel new];
    [choosePhotoLabel setText:@"相册"];
    [choosePhotoLabel setTextAlignment:NSTextAlignmentCenter];
    [choosePhotoLabel setFont:systemFont(13)];
    [choosePhotoLabel setTextColor:RGB(174, 177, 181)];
    [self.view addSubview:choosePhotoLabel];
    [choosePhotoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(middleView);
        make.top.mas_equalTo(choosePhotoBtn.mas_bottom).offset(15);
        make.width.equalTo(middleView);
        make.height.mas_equalTo(13);
    }];
    
    _rightView = [UIView new];
    [self.view addSubview:_rightView];
    [_rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(middleView.mas_right);
        make.height.equalTo(ws.view);
        make.top.equalTo(ws.view);
        make.width.equalTo(ws.view).multipliedBy(0.25);
    }];
    
    UIButton *shakeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightView addSubview:shakeBtn];
    [shakeBtn setBackgroundImage:[UIImage imageNamed:@"chat_shake_pc"] forState:UIControlStateNormal];
    [shakeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_rightView);
        make.top.mas_equalTo(15);
        make.size.mas_equalTo(CGSizeMake(65, 65));
    }];
    [shakeBtn setClipsToBounds:YES];
    [shakeBtn.layer setCornerRadius:5];
    [shakeBtn.layer setBorderWidth:0.5];
    [shakeBtn.layer setBorderColor:RGB(174, 177, 181).CGColor];
    [shakeBtn addTarget:self action:@selector(shakePC:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UILabel *shakeLabel = [UILabel new];
    [shakeLabel setText:@"抖动"];
    [shakeLabel setTextAlignment:NSTextAlignmentCenter];
    [shakeLabel setFont:systemFont(13)];
    [shakeLabel setTextColor:RGB(174, 177, 181)];
    [_rightView addSubview:shakeLabel];
    [shakeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(shakeBtn);
        make.top.mas_equalTo(shakeBtn.mas_bottom).offset(15);
        make.width.equalTo(_rightView);
        make.height.mas_equalTo(13);
    }];
}
-(void)setShakeHidden
{
    
    if(self.userId){
        [_rightView setHidden:NO];
    }else{
        [_rightView setHidden:YES];
    }
    //都隐藏
    [_rightView setHidden:YES];

}
-(void)shakePC:(id)sender
{
    if([MTTUtil ifCanShake])
    {
        NSDate *date = [NSDate date];
        [MTTUtil setLastShakeTime:date];
        MTTShakeAPI *request = [MTTShakeAPI new];
        NSMutableArray *array = [NSMutableArray new];
        [array addObject:@(self.userId)];
        [request requestWithObject:array Completion:^(id response, NSError *error) {
        }];
        [[ChattingMainViewController shareInstance] sendPrompt:@"你向对方发送了一个抖动~"];
        NSString* nick = [RuntimeStatus instance].user.nick;
        NSDictionary *dict = @{@"nick":nick};
        NSLog(@"%@",dict);
    }else{
        [[ChattingMainViewController shareInstance] sendPrompt:@"留条活路吧...别太频繁了"];
    }
}
#pragma mark - 选择相册
-(void)choosePicture:(id)sender
{
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.navigationBar.barTintColor = [UIColor theme];
    picker.navigationBar.tintColor = [UIColor whiteColor];
    picker.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    NSLog(@"%@",picker.navigationController.navigationItem.rightBarButtonItem);
    [picker.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied){
        //无权限
        [PLGlobalClass aletWithTitle:@"未获得访问相册授权" Message:@"请在 设置-照片中打开" sureTitle:@"知道了" CancelTitle:nil SureBlock:^{
            [picker removeFromParentViewController];
        } andCancelBlock:^{
        } andDelegate:self];
        return;
    }
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //设置代理
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:^{
    }];
}

-(void)takePicture:(id)sender
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //判断有无相机设备
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            UIImagePickerController * picker = [[UIImagePickerController alloc]init];
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];//读取设备授权状态
            if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
                [PLGlobalClass aletWithTitle:@"未获得授权使用摄像头" Message:@"请在 设置-隐私-相机中打开" sureTitle:@"知道了" CancelTitle:nil SureBlock:^{
                    [picker removeFromParentViewController];
                } andCancelBlock:^{
                } andDelegate:self];
                return;
            }
            //设置图片来源，相机或者相册
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            
            //设置后续是否可编辑
            picker.allowsEditing = NO;
            //设置代理
            picker.delegate = self;
            [self presentViewController:picker animated:YES completion:nil];
        }else{
            [PLGlobalClass aletWithTitle:@"您还未打开相加" Message:nil sureTitle:@"知道了" CancelTitle:nil SureBlock:^{
            } andCancelBlock:^{
            } andDelegate:self];
        }
    });
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}
#pragma mark - UIImagePickerController Delegate
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        __block UIImage *theImage = nil;
        if ([picker allowsEditing]){
            theImage = [info objectForKey:UIImagePickerControllerEditedImage];
        } else {
            theImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        UIImage *image = [self scaleImage:theImage toScale:0.3];
        NSData *imageData = UIImageJPEGRepresentation(image, (CGFloat)1.0);
        UIImage * m_selectImage = [UIImage imageWithData:imageData];
            __block MTTPhotoEnity *photo = [MTTPhotoEnity new];
            NSString *keyName = [[MTTPhotosCache sharedPhotoCache] getKeyName];
            photo.localPath=keyName;
        [picker dismissViewControllerAnimated:YES completion:^{
        }];
        [[ChattingMainViewController shareInstance] sendImageMessage:photo Image:m_selectImage];
    }
}
#pragma mark - 等比縮放image
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize, image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
