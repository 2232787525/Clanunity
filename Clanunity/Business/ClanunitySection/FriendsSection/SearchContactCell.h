//
//  SearchContactCell.h
//  Clanunity
//
//  Created by wangyadong on 2018/3/15.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectContactCell.h"
@class SearchAddFriendModel;
@interface SearchContactCell : UITableViewCell
@property(nonatomic,strong)MTTAvatarImageView *header;
@property(nonatomic,strong)UILabel *name;
@property(nonatomic,strong)UILabel *detial;
@property(nonatomic,strong)SearchAddFriendModel *model;

@end


@interface SearchAddFriendModel : MTTUserEntity
/**
 包含
 */
@property(nonatomic,copy)NSString *include;
/**
 0联系人，1群聊
 */
@property(nonatomic,assign)NSInteger type;


@end


@interface SearchContactKeyView : UIView
@property(nonatomic,strong)UIImageView *header;
@property(nonatomic,strong)UILabel *name;
@property(nonatomic,strong)UIButton *tapBtn;
@property(nonatomic,copy)void(^searchClickedBlock)(NSString*key);
@end

