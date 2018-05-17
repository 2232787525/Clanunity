//
//  DDContactsCell.h
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-08-22.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTTGroupEntity.h"
#import "MTTAvatarImageView.h"
#import <Masonry/Masonry.h>

@interface DDContactsCell : UITableViewCell
@property(strong)MTTAvatarImageView *avatar;
@property(strong)UILabel *nameLabel;
@property(nonatomic,strong)UIImageView * gender;
@property(nonatomic,strong)UILabel *newfriend;
@property(nonatomic,strong)UIImageView *rightArrow;
@property(nonatomic,strong)UIView *redPoint;

-(void)setCellContent:(NSString *)avater Name:(NSString *)name;
-(void)setGroupAvatar:(MTTGroupEntity*)group;
@end
