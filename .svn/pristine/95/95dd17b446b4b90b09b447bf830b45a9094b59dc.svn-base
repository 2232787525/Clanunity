//
//  PLSocialView.h
//  PalmLive
//
//  Created by bex on 2017/8/16.
//  Copyright © 2017年 bex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupView.h"//弹窗


#pragma mark - 寄思先祖弹窗
@interface JisiAlterView : PopupView
@property(nonatomic,retain)UIImageView *bgImage;
@property(nonatomic,assign)NSInteger type; //0 上香  1 贡品   2 鲜花  3 行礼
@property(nonatomic,retain)NSArray * thingsArr; //0 上香  1 贡品   2 鲜花  3 行礼
@property(nonatomic,copy)void(^ _Nullable selectedIndexBlock)(NSInteger);
@end


#pragma mark - 寄思先祖 弹窗商品cell
@interface GoodsCell : UICollectionViewCell
@property(nonatomic,strong)UIImageView * imageView;
@property(nonatomic,strong)UIButton * tipbtn;
@end


#pragma mark - 提示框 两个按钮
@interface msgAlterView : PopupView
@property(nonatomic,retain)UILabel  *infoLab;//提示信息
@property(nonatomic,retain)UIButton *btn;
@property(nonatomic,retain)UIButton *btncancle;
@property(nonatomic,retain)UIImageView *bgImage;
@property(nonatomic,copy)void(^ _Nullable btnClickBlock)();
@property(nonatomic,strong)NSArray *btnArr;

-(instancetype)initWithFrame:(CGRect)frame parentVC:(UIViewController *)parentVC dismissAnimation:(id<LewPopupAnimation>)animation title:(NSString *)str;
@end


@interface BounceAlter : PopupView
@property(nonatomic,retain)UILabel  *infoLab;//提示信息
@property(nonatomic,retain)UIButton *btn;
@property(nonatomic,retain)UIButton *btncancle;
@property(nonatomic,retain)UIImageView *bgImage;
@property(nonatomic,copy)void(^ _Nullable btnClickBlock)();

@end


@interface BounceVC : UIViewController
@end


#pragma mark - 申请加入弹窗
@interface PLjiaruAlterView : PopupView
@property(nonatomic,retain)UIButton *jiarubtn;
@property(nonatomic,retain)UITextField *textField;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,assign)NSInteger btnTag;
@property(nonatomic,retain)UILabel  *infoLab;//提示信息
@property(nonatomic,retain)UIButton *closebtn; //取消按钮
@property(nonatomic,retain)UIImageView *titleImage;
@end


#pragma mark - 邀请码填写弹窗
@interface PLInvertAlterView : PLjiaruAlterView
@property(nonatomic,assign)NSInteger numOfWordLimit;
@end


#pragma mark - 左边绿色竖线 右边文字
@interface PLLineAndLabView : UIView
@property(nonatomic,retain)UIView  *lineView;//左线
@property(nonatomic,retain)UILabel *titleLab;//标题
@end


