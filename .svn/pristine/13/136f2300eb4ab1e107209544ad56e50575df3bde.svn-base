//
//  FreshApplyMsgListVC.h
//  Clanunity
//
//  Created by wangyadong on 2018/3/16.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import "KBaseClanViewController.h"
@class FreshApplyModel;
@interface FreshApplyMsgListVC : KBaseClanViewController
@property(nonatomic,copy)void(^friendFreshList)(void);
@end



@interface FreshApplyCell : UITableViewCell

@property(nonatomic,strong)UIImageView * header;
@property(nonatomic,strong)UILabel * name;
@property(nonatomic,strong)UIImageView *sex;
@property(nonatomic,strong)UIButton *status;
@property(nonatomic,strong)FreshApplyModel *model;
@property(nonatomic,copy)void(^acceptApplyBlock)(FreshApplyModel *model , FreshApplyCell *cell);


@end


@interface FreshApplyModel : KFriendModel


@property(nonatomic,assign)NSInteger teamid;

@property(nonatomic,copy)NSString * created;

/**
 申请人的id
 */
@property(nonatomic,copy)NSString * fuserid;

/**
 被申请的人
 */
@property(nonatomic,copy)NSString *tuserid;
@property(nonatomic,copy)NSString * remark;

/**
 这条数据的id
 */
@property(nonatomic,copy)NSString * id;
@property(nonatomic,copy)NSString * updated;

/**
 0待处理，1已添加，
 */
@property(nonatomic,assign)NSInteger status;














@end
