//
//  XHlaunchAdManager.m
//  PalmLive
//
//  Created by wangyadong on 2018/1/22.
//  Copyright © 2018年 zfy_srf. All rights reserved.
//

#import "XHlaunchAdManager.h"
#import "XHLaunchAd.h"

static XHlaunchAdManager * manager = nil;

NSString *const GuidePageStartKey = @"GuidePageStartKey";

@interface XHlaunchAdManager()<XHLaunchAdDelegate>{
    UIScrollView *_guideScrollView;
}



@end


@implementation XHlaunchAdManager

+(XHlaunchAdManager *)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XHlaunchAdManager alloc] init];
    });
    return manager;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        //在UIApplicationDidFinishLaunching时初始化开屏广告,做到对业务层无干扰,当然你也可以直接在AppDelegate didFinishLaunchingWithOptions方法中初始化
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            NSLog(@"DidFinishLaunchingNotification");
            //初始化开屏广告
            NSUserDefaults *guideUser = [NSUserDefaults standardUserDefaults];
            NSString *AppV =[DeviceConfig appVersion];
            if ([guideUser objectForKey:GuidePageStartKey] != nil && [[guideUser objectForKey:GuidePageStartKey] isEqualToString:AppV]) {
                [self setupXHLaunchAd];
            }else{
                [self createGuideView];
                [self showGuideInWindow];
            }
        }];
    }
    return self;
}

//TODO:设置广告启动页
-(void)setupXHLaunchAd{
    //设置你工程的启动页使用的是:LaunchImage 还是 LaunchScreen.storyboard(不设置默认:LaunchImage)
    [XHLaunchAd setLaunchSourceType:SourceTypeLaunchImage];
    //注意:请求广告数据前,必须设置此属性,否则会先进入window的的根控制器
    [XHLaunchAd setWaitDataDuration:0];
    
    WeakSelf;
    //取已经保存的广告页图片
    NSDictionary *startupDic = [PLGlobalClass getValueFromFile:[CUKey kStartupInfo] withKey:CUKey.kStartupInfo];

    if (startupDic != nil && [startupDic isKindOfClass:[NSDictionary class]]) {
        //直接显示广告页
        [self xhLaunchAdShow:startupDic[@"startImgUrl"] gourl:startupDic[@"startImgGoUrl"]];
        [self requestForStartupWithResult:nil];
    }else{
        //先请求再显示广告页
        [self requestForStartupWithResult:^(id data) {
            [weakSelf xhLaunchAdShow:data[@"startImgUrl"] gourl:data[@"startImgGoUrl"]];
        }];
    }
}

//TODO:启动页接口数据请求及保存结果
-(void)requestForStartupWithResult:(void(^)(id data))show;{
    [ClanAPI requestForStartupWithResult:^(ClanAPIResult * _Nonnull result) {
        NSLog(@"启动 result.data = %@",result.data);
        NSDictionary *dic = result.data;
        if(dic.count>0){
            //保存启动接口返回数据
            [PLGlobalClass writeToFile:[CUKey kStartupInfo] withKey:[CUKey kStartupInfo] value:dic];
            [PLGlobalClass writeToFile:[CUKey kSourceSave] withKey:[CUKey kServerSourceVersion] value:dic[@"resversion"]];

            if (show){
                show(dic);
            }
        }
    }];
}

-(void)xhLaunchAdShow:(NSString *)ImageurlStr gourl:(NSString *)goUrlStr{
    /*
     {
     adname = "\U542f\U52a8\U5e7f\U544a";
     adtext = 1;
     imgurl = "http://apk.zhangfangyuan.com/serverimg/ad/6fc001ba84e04156891736bbf01eafe7.png";
     ts = 1495180498000;
     url = 1;
     }
     */
    //广告数据转模型
    //配置广告数据
    XHLaunchImageAdConfiguration *imageAdconfiguration = [XHLaunchImageAdConfiguration new];
    //广告停留时间
    imageAdconfiguration.duration = 3;
    //广告frame
    imageAdconfiguration.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 0.8);
    //广告图片URLString/或本地图片名(.jpg/.gif请带上后缀)
    imageAdconfiguration.imageNameOrURLString = ImageurlStr;
    //设置GIF动图是否只循环播放一次(仅对动图设置有效)
    imageAdconfiguration.GIFImageCycleOnce = NO;
    //缓存机制(仅对网络图片有效)
    //为告展示效果更好,可设置为XHLaunchAdImageCacheInBackground,先缓存,下次显示
    imageAdconfiguration.imageOption = XHLaunchAdImageDefault;
    //图片填充模式
    imageAdconfiguration.contentMode = UIViewContentModeScaleAspectFill;
    //广告点击打开页面参数(openModel可为NSString,模型,字典等任意类型)
    
    
    if (goUrlStr!=nil && goUrlStr != [NSNull null] && [goUrlStr length] >0 && [goUrlStr hasPrefix:@"http"]) {
        imageAdconfiguration.openModel = goUrlStr;
    }
    //广告显示完成动画
    imageAdconfiguration.showFinishAnimate =ShowFinishAnimateLite;
    //广告显示完成动画时间
    imageAdconfiguration.showFinishAnimateTime = 0.8;
    //跳过按钮类型
    imageAdconfiguration.skipButtonType = SkipTypeTimeText;
    //后台返回时,是否显示广告
    imageAdconfiguration.showEnterForeground = NO;
    
    //图片已缓存 - 显示一个 "已预载" 视图 (可选)
    if([XHLaunchAd checkImageInCacheWithURL:[NSURL URLWithString:ImageurlStr]]){
        //设置要添加的自定义视图(可选)
        //                    imageAdconfiguration.subViews = [self launchAdSubViews_alreadyView];
        
    }
    //显示开屏广告
    [XHLaunchAd imageAdWithImageAdConfiguration:imageAdconfiguration delegate:self];
}

#pragma mark - XHLaunchAd delegate - 其他
//跳过按钮点击事件
-(void)skipAction{
    //移除广告
    [XHLaunchAd removeAndAnimated:YES];
}
/**
 广告点击事件回调
 */
-(void)xhLaunchAd:(XHLaunchAd *)launchAd clickAndOpenModel:(id)openModel clickPoint:(CGPoint)clickPoint{
    
    NSLog(@"广告点击事件");
    /**
     openModel即配置广告数据设置的点击广告时打开页面参数
     */
}
/**
 *  图片本地读取/或下载完成回调
 *
 *  @param launchAd  XHLaunchAd
 *  @param image 读取/下载的image
 *  @param imageData 读取/下载的imageData
 */
-(void)xhLaunchAd:(XHLaunchAd *)launchAd imageDownLoadFinish:(UIImage *)image imageData:(NSData *)imageData{
    NSLog(@"图片下载完成/或本地图片读取完成回调");
}
/**
 *  广告显示完成
 */
-(void)xhLaunchAdShowFinish:(XHLaunchAd *)launchAd{
    
    NSLog(@"广告显示完成");
    
}



#pragma mark - 引导页显示
-(void)createGuideView{
    
        _guideScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _guideScrollView.bounces = NO;
        _guideScrollView.showsHorizontalScrollIndicator = NO;
        _guideScrollView.showsVerticalScrollIndicator = NO;
        _guideScrollView.pagingEnabled = YES;
        
        _guideScrollView.contentSize = CGSizeMake(3*KScreenWidth, KScreenHeight);
        CGFloat model = KScreenHeight/667;
        for (int i = 0; i < 3; i++) {
            UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(i*[UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
            imageV.userInteractionEnabled = YES;
            imageV.tag = 12306+i;
            imageV.image = [UIImage imageNamed:[NSString stringWithFormat:@"Guide%d.jpg",i+1]];
//            [PLHelp imageAspectFillForImageView:imageV];
            [_guideScrollView addSubview:imageV];
            
            if (i < 2) {
                UIImageView *pointImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 47, 9)];
                pointImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"point_%d",i+1]];
                [imageV addSubview:pointImg];
                pointImg.centerX_sd = imageV.width_sd/2.0;
                pointImg.centerY_sd = KScreenHeight - KBottomHeight - 35*model;
            }
        }
        
        UIImageView *img = (UIImageView*)[_guideScrollView viewWithTag:12306+2];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((KScreenWidth-130)/2.0,KScreenHeight-150,115,32);
        [btn setImage:[UIImage imageNamed:@"Guide3_btn"] forState:UIControlStateNormal];
        btn.centerX_sd = img.centerX_sd;
        btn.centerY_sd = KScreenHeight - KBottomHeight - 35*model;
        [btn addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
        [_guideScrollView addSubview:btn];
}
- (void)dismissView{
    
    [UIView animateWithDuration:1 animations:^{
        //1秒的过程中导航页隐藏、放大
        _guideScrollView.alpha = 0;
        _guideScrollView.transform = CGAffineTransformMakeScale(2.0, 2.0);
    } completion:^(BOOL finished) {
        //移除导航页 保证内存管理
        [_guideScrollView removeFromSuperview];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
//        [LoginServer showLoginVCWithBlock:^{
//            
//        }];

        //跳转登录页
    }];
    
    NSUserDefaults *defautls = [NSUserDefaults standardUserDefaults];
    //存储版本号更新
    NSString *AppV =[DeviceConfig appVersion];
    [defautls setValue:AppV forKey:GuidePageStartKey];
    [defautls synchronize];
}

- (void)showGuideInWindow{
#if 0
    //先拿到UIApplication对象 单例 在拿到AppDelegate对象 也是单例
    AppDelegate *app = (id)[[UIApplication sharedApplication] delegate];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [app.window addSubview:_guideScrollView];
#else
    //keyWindow 当前活跃的window
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[UIApplication sharedApplication].keyWindow addSubview:_guideScrollView];
#endif
    
}



@end
