//
//  XLVideoPlayer.h
//  XLVideoPlayer
//
//  Created by Shelin on 16/3/23.
//  Copyright © 2016年 GreatGate. All rights reserved.
//  https://github.com/ShelinShelin
//  博客：http://www.jianshu.com/users/edad244257e2/latest_articles

#import <UIKit/UIKit.h>
#import "XLSlider.h"
#import <AVFoundation/AVFoundation.h>

@class XLVideoPlayer;

typedef void (^VideoCompletedPlayingBlock) (XLVideoPlayer *videoPlayer);

@interface XLVideoPlayer : UIView

//播放结束回调
@property (nonatomic, copy) VideoCompletedPlayingBlock completedPlayingBlock;
@property (nonatomic, strong) XLSlider *slider;
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic, strong) UIButton *playOrPauseBtn;//播放暂停按钮
@property (nonatomic, strong) UIButton *zoomScreenBtn;//全屏按钮
@property (nonatomic, strong) UILabel *progressLabel; //播放时间显示

@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) NSLayoutConstraint *label1Left;
@property (nonatomic, strong) NSLayoutConstraint *label1Top;
@property (nonatomic, strong) NSLayoutConstraint *label1Bottom;
@property (nonatomic, strong) NSLayoutConstraint *label1Width;
@property (nonatomic, strong) UITapGestureRecognizer *tap;//点击播放器手势
@property (nonatomic, strong) UIView *superV;

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, assign) BOOL ifverticalScreen;//是否竖屏全屏 默认：0 横屏全屏

/**
 *  video url 视频路径
 */
@property (nonatomic, strong) NSURL *videoUrl;

/**
 *  play or pause
 */
- (void)playPause;

/**
 *  dealloc 销毁
 */
- (void)destroyPlayer;

/**
 *  在cell上播放必须绑定TableView、当前播放cell的IndexPath
 */
- (void)playerBindTableView:(UITableView *)bindTableView currentIndexPath:(NSIndexPath *)currentIndexPath;

/**
 *  在scrollview的scrollViewDidScroll代理中调用
 *
 *  @param support        是否支持右下角小窗悬停播放
 */
- (void)playerScrollIsSupportSmallWindowPlay:(BOOL)support;

//MARK:进度条和播放暂停按钮
- (void)setStatusBarHidden:(BOOL)hidden;

//MARK:切换全屏 小屏
- (void)actionFullScreen;

//MARK:竖屏全屏（只有竖屏全屏 没有横屏全屏）
-(void)verticalFullScreen;
@end
