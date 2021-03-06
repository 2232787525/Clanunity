//
//  KBaseClanViewController.m
//  Clanunity
//
//  Created by wangyadong on 2018/1/31.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import "KBaseClanViewController.h"
#import "CGImageGIFView.h"

@interface KBaseClanViewController ()<UIGestureRecognizerDelegate>
@property(nonatomic,weak) CGImageGIFView *gifView;

@end

@implementation KBaseClanViewController

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super init];
    if (self) {
        self.frame = frame;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.frame.size.width>0) {
        self.view.frame = self.frame;
    }
    [self preferredStatusBarStyle];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    if ((self.isRootVC || !self.knavigationBar.superview) && self.knavigationBar)
    {
        [self.view addSubview:self.knavigationBar];
    }
    
    if (@available(iOS 11.0, *)) {
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(kNotifiLoginSuccess) name:CUKey.kNotifiCompleteUserinfo object:nil];

    //退出通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kNoticeLogoutSuccess) name:DDNotificationLogout object:nil];
    // Do any additional setup after loading the view.
}
-(void)kNotifiLoginSuccess{
    NSLog(@"KBaseClanViewController notice 完善信息成功");
   
}
-(void)kNoticeLogoutSuccess{
    NSLog(@"NoticeLogout 退出");

}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:CUKey.kLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:DDNotificationLogout object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showGifView{
    if (self.gifView == nil) {
        CGImageGIFView *imgView = [CGImageGIFView gifViewShowSuperView:self.view];
        self.gifView = imgView;
    }
    [self.view bringSubviewToFront:self.gifView];
    self.gifView.hidden = NO;
    [self.gifView startGIF];
}
-(void)hiddenGifView{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.gifView stopGIF];
        self.gifView.hidden = YES;
    });
}

-(void)wordlimitTelephoneWithTf:(id )tf{
    [PLGlobalClass wordlimitWithtextField:tf limitnum:11];
}

-(void)wordlimitTitleWithTf:(id)tf{
    [PLGlobalClass wordlimitWithtextField:tf limitnum:numDefault.knum_biaoti];
}

-(void)wordlimitNameWithTf:(id)tf{
    [PLGlobalClass wordlimitWithtextField:tf limitnum:8];
}

//人数限制4位 几千人
-(void)wordlimitNumOfPeopleWithTf:(id)tf;{
    [PLGlobalClass wordlimitWithtextField:tf limitnum:4];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
