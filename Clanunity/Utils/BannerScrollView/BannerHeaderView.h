//
//  BannerHeaderView.h
//  EnergyConservationPark
//
//  Created by wangyadong on 16/6/15.
//  Copyright © 2016年 keanzhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDCycleScrollView.h"
#import "BannerModel.h"
@interface BannerHeaderView : UIView

@property(nonatomic,weak)SDCycleScrollView *cycleScrollView;


+(instancetype)bannerViewWithFrame:(CGRect)frame placeHolderImg:(UIImage*)placeImg;

-(void)adjustWhenControllerViewWillAppera;
@property(nonatomic,strong)NSArray * bannerUrlArray;

@property(nonatomic,copy)void(^bannerDidSelectItemAtIndex)(NSInteger index);
@end
