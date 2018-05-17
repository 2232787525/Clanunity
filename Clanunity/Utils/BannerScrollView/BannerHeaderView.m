//
//  BannerHeaderView.m
//  EnergyConservationPark
//
//  Created by wangyadong on 16/6/15.
//  Copyright © 2016年 keanzhu. All rights reserved.
//

#import "BannerHeaderView.h"

@interface BannerHeaderView ()<SDCycleScrollViewDelegate>

@property(nonatomic,strong)SDCycleScrollView * sdCycleView;

@property(nonatomic,strong)UIImage * placeHolderImage;

@end

@implementation BannerHeaderView



+(instancetype)bannerViewWithFrame:(CGRect)frame placeHolderImg:(UIImage *)placeImg{
    BannerHeaderView * banner = [[BannerHeaderView alloc] initWithFrame:frame sdCyclePlaceImg:placeImg];
    return banner;
}

-(instancetype)initWithFrame:(CGRect)frame sdCyclePlaceImg:(UIImage*)placeImg{
    self = [super initWithFrame:frame];
    if (self) {
        self.placeHolderImage = placeImg;
        self.sdCycleView = [SDCycleScrollView cycleScrollViewWithFrame:self.bounds delegate:self placeholderImage:self.placeHolderImage];
        [self addSubview:self.sdCycleView];
        self.sdCycleView.currentPageDotColor = [UIColor  colorWithHexString:@"333333"];
        self.sdCycleView.pageDotColor = [UIColor colorWithHexString:@"8B8782"];
        self.sdCycleView.backgroundColor = [UIColor whiteColor];
        self.sdCycleView.bannerImageViewContentMode =UIViewContentModeScaleAspectFill;
         self.sdCycleView.autoScrollTimeInterval = 4;
        self.sdCycleView.autoScroll = NO;//禁止
    }
    return self;
}
-(void)setBannerUrlArray:(NSArray *)bannerUrlArray{
    self.sdCycleView.imageURLStringsGroup = bannerUrlArray;
    if (bannerUrlArray.count > 1) {
        self.sdCycleView.autoScroll = YES;
    }
}

/** 点击图片回调 */
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    if (self.bannerDidSelectItemAtIndex) {
        self.bannerDidSelectItemAtIndex(index);
    }
}

/** 图片滚动回调 */
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index{
    
}
-(void)adjustWhenControllerViewWillAppera{
    [self.sdCycleView adjustWhenControllerViewWillAppera];
}

@end
