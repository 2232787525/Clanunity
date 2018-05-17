//
//  BQCamera.m
//  BQCommunity
//
//  Created by ZL on 14-9-11.
//  Copyright (c) 2014年 beiqing. All rights reserved.
//

#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define CAMERA_TRANSFORM_X 1.2
#define CAMERA_TRANSFORM_Y 1.2

#import "ZLCameraViewController.h"
#import "ZLCameraImageView.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import "ZLCameraView.h"
#import "ZLPhoto.h"
#import <objc/message.h>

static CGFloat ZLCameraColletionViewW = 75;
static CGFloat ZLCameraColletionViewPadding = 10;
static CGFloat BOTTOM_HEIGHT = 60;

@interface ZLCameraViewController () <UIActionSheetDelegate,UICollectionViewDataSource,UICollectionViewDelegate,AVCaptureMetadataOutputObjectsDelegate,ZLCameraImageViewDelegate,ZLCameraViewDelegate,ZLPhotoPickerViewControllerDelegate,ZLPhotoPickerBrowserViewControllerDelegate>

@property (weak, nonatomic) UIView *controlView;

// 代码块
@property (copy, nonatomic) codeBlock codeBlock;

@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableDictionary *dictM;

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureStillImageOutput *captureOutput;
@property (strong, nonatomic) AVCaptureDevice *device;

@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;

@property (weak,nonatomic) ZLCameraView *caramView;

@property(nonatomic,weak)UIButton * cameraBtn;

@end

@implementation ZLCameraViewController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    NSString *mediaType = AVMediaTypeVideo;// Or AVMediaTypeAudio
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusDenied){
        //已经拒绝
        [PLGlobalClass aletWithTitle:@"未获得授权使用摄像头" Message:@"请在iOS\"设置-隐私-相机\"中打开。" sureTitle:nil CancelTitle:@"知道了" SureBlock:^{} andCancelBlock:^{
            [self cancel:nil];
        } andDelegate:self];
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
}
- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    //回到主线程修改UI
    [self initialize];
    
    [self makeUI];
    
    if (self.session) {
        [self.session startRunning];
    }
   
}
#pragma mark -初始化界面
- (void)makeUI{
    // 头部View
    UIButton *deviceBtn = [self setupButtonWithImageName:@"camer" frame:CGRectMake(10, KStatusBarHeight/2.0,44, 44)];
    deviceBtn.right_sd = KScreenWidth-15;
    [self.view addSubview:deviceBtn];
    [deviceBtn addTarget:self action:@selector(changeCameraDevice:) forControlEvents:UIControlEventTouchUpInside];
    
    // 底部View
    UIView *controlView = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.width_sd, BOTTOM_HEIGHT+KBottomStatusH)];
    controlView.bottom_sd = KScreenHeight;
    controlView.backgroundColor = [UIColor clearColor];
    controlView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.controlView = controlView;
    
    UIView *contentView = [[UIView alloc] init];
    contentView.frame = controlView.bounds;
    contentView.backgroundColor = [UIColor blackColor];
    contentView.alpha = 0.3;
    [controlView addSubview:contentView];
    
   
    //拍照
    UIButton *camBtn = [self setupButtonWithImageName:@"camer" frame:CGRectMake(0, 0,45, 45)];
    self.cameraBtn = camBtn;
    camBtn.centerX_sd = self.controlView.width_sd/2.0;
    camBtn.centerY_sd = self.controlView.height_sd/2.0;
    self.cameraBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.cameraBtn addTarget:self action:@selector(stillImage:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:camBtn];
    
    //取消
    UIButton *cancalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancalBtn.frame = CGRectMake(0, 0,50, 50);
    cancalBtn.centerY_sd =controlView.height_sd/2.0;
    cancalBtn.centerX_sd = camBtn.left_sd/2.0;
    [cancalBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancalBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:cancalBtn];
    
    // 完成
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(0, 0,50,50);
    doneBtn.centerY_sd = cancalBtn.centerY_sd;
    doneBtn.right_sd =KScreenWidth- cancalBtn.left_sd;
    [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:doneBtn];
    
    [self.view addSubview:controlView];
}
#pragma mark 初始化按钮
- (UIButton *) setupButtonWithImageName : (NSString *) imageName frame:(CGRect)frame{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    button.frame = frame;
    return button;
}

#pragma mark - 拍照触发方法
- (void)stillImage:(id)sender
{
    if (self.images.count >= self.maxCanSelecrted) {
        [PLGlobalClass aletWithTitle:@"温馨提示" Message:@"您已选满图片了" sureTitle:nil CancelTitle:@"好的" SureBlock:^{} andCancelBlock:^{
        } andDelegate:self];
        return;
    }
    self.cameraBtn.userInteractionEnabled = NO;
    [self Captureimage];
    //拍照闪一下的效果
    UIView *maskView = [[UIView alloc] init];
    maskView.frame = self.view.bounds;
    maskView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:maskView];
    [UIView animateWithDuration:.5 animations:^{
        maskView.alpha = 0;
    } completion:^(BOOL finished) {
        [maskView removeFromSuperview];
    }];
}

- (void) initialize
{
    //1.创建会话层
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // Input
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    // Output
    self.captureOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [self.captureOutput setOutputSettings:outputSettings];
    
    // Session
    self.session = [[AVCaptureSession alloc]init];
    //拿到的图像的大小可以自行设定
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];//AVCaptureSessionPresetMedium
    
    if ([self.session canAddInput:self.input])
    {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:_captureOutput])
    {
        [self.session addOutput:_captureOutput];
    }
    self.preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = self.view.bounds;
    
    ZLCameraView *caramView = [[ZLCameraView alloc] initWithFrame:CGRectMake(0,0, KScreenWidth, KScreenHeight-BOTTOM_HEIGHT-KBottomStatusH)];
    caramView.backgroundColor = [UIColor clearColor];
    caramView.delegate = self;
    [self.view addSubview:caramView];
    [self.view.layer insertSublayer:self.preview atIndex:0];
    self.caramView = caramView;
    

}
- (void)cameraDidSelected:(ZLCameraView *)camera{
    
    [self.device lockForConfiguration:nil];
    [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
    [self.device setFocusPointOfInterest:CGPointMake(50,50)];
    //操作完成后，记得进行unlock。
    [self.device unlockForConfiguration];

}
//对焦回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if( [keyPath isEqualToString:@"adjustingFocus"] ){
        BOOL adjustingFocus = [ [change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1] ];
        NSLog(@"Is adjusting focus? %@", adjustingFocus ? @"YES" : @"NO" );
        NSLog(@"Change dictionary: %@", change);
        //        if (delegate) {
        //            [delegate foucusStatus:adjustingFocus];
        //        }
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}
#pragma mark - UICollectionViewDelegate
- (NSInteger ) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger ) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.images.count;
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, ZLCameraColletionViewPadding, 0, ZLCameraColletionViewPadding);
}
- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
   
    ZLCamera *camera = self.images[indexPath.item];
    
    ZLCameraImageView *lastView = [cell.contentView.subviews lastObject];
    if(![lastView isKindOfClass:[ZLCameraImageView class]]){
        // 解决重用问题
        UIImage *image = camera.thumbImage;
        ZLCameraImageView *imageView = [[ZLCameraImageView alloc] init];
        imageView.delegatge = self;
        imageView.edit = YES;
        imageView.image = image;
        imageView.frame = cell.bounds;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [cell.contentView addSubview:imageView];
    }
    
    lastView.image = camera.thumbImage;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    // 图片游览器
    ZLPhotoPickerBrowserViewController *pickerBrowser = [[ZLPhotoPickerBrowserViewController alloc] init];
    // 淡入淡出效果
    // pickerBrowser.status = UIViewAnimationAnimationStatusFade;
    // 数据源/delegate
    pickerBrowser.editing = YES;
    NSMutableArray *photoArr = [NSMutableArray arrayWithCapacity:0];
    for (ZLCamera *cam in self.images) {
        ZLPhotoPickerBrowserPhoto *model = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:cam.fullScreenImage];
        [photoArr addObject:model];
    }
    
    
    pickerBrowser.photos = photoArr;
    
    // 能够删除
    pickerBrowser.delegate = self;
    // 当前选中的值
    pickerBrowser.currentIndex = indexPath.row;
    // 展示控制器
    [pickerBrowser showPickerVc:self];
    

}


#pragma mark - <ZLPhotoPickerBrowserViewControllerDataSource>
- (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser removePhotoAtIndex:(NSInteger)index{
    if (self.images.count > index) {
        [self.images removeObjectAtIndex:index];
        [self.collectionView reloadData];
    }
}
- (NSInteger)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section{
    return self.images.count;
}

- (ZLPhotoPickerBrowserPhoto *) photoBrowser:(ZLPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath{
    
    id imageObj = [[self.images objectAtIndex:indexPath.row] fullScreenImage];
    ZLPhotoPickerBrowserPhoto *photo = [ZLPhotoPickerBrowserPhoto photoAnyImageObjWith:imageObj];
    
    UICollectionViewCell *cell = (UICollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    
    UIImageView *imageView = [[cell.contentView subviews] lastObject];
    photo.thumbImage = imageView.image;
    
    return photo;
}

- (void)photoBrowser:(ZLPhotoPickerBrowserViewController *)photoBrowser removePhotoAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableArray *arrM = [self.images mutableCopy];
    [arrM removeObjectAtIndex:indexPath.row];
    self.images = arrM;
    [self.collectionView reloadData];
    
    
}



- (void)deleteImageView:(ZLCameraImageView *)imageView{
    NSMutableArray *arrM = [self.images mutableCopy];
    for (ZLCamera *camera in self.images) {
        UIImage *image = camera.thumbImage;
        if ([image isEqual:imageView.image]) {
            [arrM removeObject:camera];
        }
    }
    self.images = arrM;
    [self.collectionView reloadData];
}

- (void)startCameraOrPhotoFileWithViewController:(UIViewController *)viewController complate:(ZLComplate)complate{
    self.currentViewController = viewController;
    UIActionSheet *myActionSheet = [[UIActionSheet alloc]initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:@"取消"
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:@"打开照相机",@"从手机相册获取",nil];
    
    [myActionSheet showInView:[UIApplication sharedApplication].keyWindow];
    self.complate = complate;
}

#pragma mark - ActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:  //打开照相机拍照
            [self takePhoto];
            break;
        case 1:  //打开本地相册
            [self LocalPhoto];
            break;
    }
}

-(void)Captureimage
{
    //get connection
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.captureOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    //get UIImage
    [self.captureOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments) {
             // Do something with the attachments.
         }
         
         // Continue as appropriate.
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *t_image = [UIImage imageWithData:imageData];
         
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             NSData *data;
             if (UIImagePNGRepresentation(t_image) == nil)
             {
                 data = UIImageJPEGRepresentation(t_image, 1.0);
             }
             else
             {
                 data = UIImagePNGRepresentation(t_image);
             }
         });
         
         NSDateFormatter *formater = [[NSDateFormatter alloc] init];
         formater.dateFormat = @"yyyyMMddHHmmss";
         NSString *currentTimeStr = [[formater stringFromDate:[NSDate date]] stringByAppendingFormat:@"_%d" ,arc4random_uniform(10000)];
         t_image = [self fixOrientation:t_image];
         NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:currentTimeStr];
         [UIImagePNGRepresentation(t_image) writeToFile:path atomically:YES];
         NSData *data = UIImageJPEGRepresentation(t_image, 0.3);
         ZLCamera *camera = [[ZLCamera alloc] init];
        camera.imagePath = path;
         camera.thumbImage = [UIImage imageWithData:data];
        [self.images addObject:camera];
        
         self.cameraBtn.userInteractionEnabled = YES;
         [self.collectionView reloadData];
         [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:self.images.count - 1 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionRight];
         
     }];
}

-(void)CaptureStillImage
{
    [self  Captureimage];
}

#pragma mark - 拍照
-(void)takePhoto
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        ZLCameraViewController *camreaVc = [[ZLCameraViewController alloc] init];
        camreaVc.complate = self.complate;
        [self.currentViewController presentViewController:camreaVc animated:YES completion:nil];
        
    }else
    {
        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
    }
}


//打开本地相册
-(void)LocalPhoto
{
    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
    // 最多能选9张图片
    if (self.maxCanSelecrted==0) {
        self.maxCanSelecrted =9;
    }
    pickerVc.maxCount = self.maxCanSelecrted;
    pickerVc.status = PickerViewShowStatusGroup;

    pickerVc.delegate = self;
    [pickerVc showPickerVc:self.currentViewController];
}

- (void)pickerViewControllerDoneAsstes:(NSArray *)assets{
    if (self.complate) {
        self.complate(assets);
    }
    
    if ([self.currentViewController respondsToSelector:@selector(pickerViewControllerDoneAsstes:)]) {
        
        [self.currentViewController performSelectorInBackground:@selector(pickerViewControllerDoneAsstes:) withObject:assets];
    }
    
    
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}

- (void)changeCameraDevice:(id)sender
{
    // 翻转
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:.5f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
    [UIView commitAnimations];
    
    NSArray *inputs = self.session.inputs;
    for ( AVCaptureDeviceInput *input in inputs ) {
        AVCaptureDevice *device = input.device;
        if ( [device hasMediaType:AVMediaTypeVideo] ) {
            AVCaptureDevicePosition position = device.position;
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput = nil;
            
            if (position == AVCaptureDevicePositionFront)
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            else
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            
            [self.session beginConfiguration];
            
            [self.session removeInput:input];
            [self.session addInput:newInput];
            
            // Changes take effect once the outermost commitConfiguration is invoked.
            [self.session commitConfiguration];
            break;
        }
    }
}

- (void)cancel:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}


//完成、取消
- (void)doneAction
{
    //关闭相册界面
    if(self.complate){
        self.complate(self.images);
    }
    [self cancel:nil];
}



- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (UIImage *)fixOrientation:(UIImage *)srcImg
{
    if (srcImg.imageOrientation == UIImageOrientationUp) return srcImg;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (srcImg.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (srcImg.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, srcImg.size.width, srcImg.size.height,
                                             CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                             CGImageGetColorSpace(srcImg.CGImage),
                                             CGImageGetBitmapInfo(srcImg.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (srcImg.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.height,srcImg.size.width), srcImg.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.width,srcImg.size.height), srcImg.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

#pragma mark - lazy
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(ZLCameraColletionViewW, ZLCameraColletionViewW);
        layout.minimumLineSpacing = ZLCameraColletionViewPadding;
        CGFloat collectionViewH = ZLCameraColletionViewW;
        CGFloat collectionViewY = self.caramView.height_sd - collectionViewH - 10;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, collectionViewY, self.view.width_sd, collectionViewH) collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor clearColor];
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [self.caramView addSubview:collectionView];
        self.collectionView = collectionView;
    }
    return _collectionView;
}

- (NSMutableArray *)images{
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
}
- (NSMutableDictionary *)dictM{
    if (!_dictM) {
        _dictM = [NSMutableDictionary dictionary];
    }
    return _dictM;
}


@end

