//
//  DDContactsCell.m
//  IOSDuoduo
//
//  Created by Michael Scofield on 2014-08-22.
//  Copyright (c) 2014 dujia. All rights reserved.
//

#import "DDContactsCell.h"
#import "UIImageView+WebCache.h"
#import "MTTGroupEntity.h"
#import "DDUserModule.h"
#import "UIView+Addition.h"
#import "DDGroupModule.h"
#import "MTTAvatarImageView.h"
@implementation DDContactsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.avatar = [[MTTAvatarImageView alloc] init];
        [self.contentView addSubview:self.avatar];
        [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50, 50));
            make.centerY.equalTo(self.contentView);
            make.left.mas_equalTo(12);
        }];
        [self.avatar setContentMode:UIViewContentModeScaleAspectFill];
        [self.avatar setClipsToBounds:YES];
        [self.avatar.layer setCornerRadius:4.0];
        self.avatar.layer.borderColor = [UIColor cutLineColor].CGColor;
        self.avatar.layer.borderWidth = 0.5;
        self.nameLabel = [UILabel new];
        [self.contentView addSubview:self.nameLabel];
        self.nameLabel.textColor = [UIColor textColor1];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatar.mas_right).offset(10);
            make.right.mas_equalTo(10);
            make.height.mas_equalTo(20);
            make.top.mas_equalTo(self.avatar.mas_top).offset(0);
        }];
        [self.nameLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
        
    
        self.gender = [[UIImageView alloc] init];
        [self.contentView addSubview:self.gender];
        [self.gender mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(17, 12));
            make.left.mas_equalTo(self.nameLabel.mas_left).offset(0);
            make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(8);
        }];
        
//        UILabel *bottomLine = [UILabel new];
//        [self.contentView addSubview:bottomLine];
//        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(10);
//            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-0.5);
//            make.right.mas_equalTo(0);
//            make.height.mas_equalTo(0.5);
//        }];
//        [bottomLine setBackgroundColor:RGB(229, 229, 229)];
        
        
        self.newfriend = [UILabel labelWithText:@"新朋友" font:[UIFont systemFontOfSize:15] textColor:[UIColor textColor1] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.newfriend];
        [self.newfriend mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12);
            make.width.mas_equalTo(100);
            make.centerY.equalTo(self.contentView);
            make.height.mas_equalTo(20);
            
        }];
        self.newfriend.hidden = YES;
        self.rightArrow = [[UIImageView alloc] init];
        self.rightArrow.image = [UIImage imageNamed:@"right_Arrowicon"];
        [self.contentView addSubview:self.rightArrow];
        [self.rightArrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-12);
            make.size.mas_equalTo(CGSizeMake(12, 22));
            make.centerY.equalTo(self.contentView);
        }];
        self.rightArrow.hidden = YES;
        
        self.redPoint = [[UIView alloc] init];
        [self.contentView addSubview:self.redPoint];
        self.redPoint.layer.masksToBounds = YES;
        self.redPoint.layer.cornerRadius = 5;
        self.redPoint.backgroundColor = [UIColor redColor];
        [self.redPoint mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.rightArrow.mas_left).offset(-3);
            make.centerY.equalTo(self.contentView);
            make.width.mas_equalTo(10);
            make.height.mas_equalTo(10);
        }];
        self.redPoint.hidden = YES;
        
        
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = RGB(244, 245, 246);
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setCellContent:(NSString *)avatar Name:(NSString *)name
{
    self.nameLabel.text=name;
    UIImage* placeholder = [UIImage imageNamed:@"user_placeholder"];    
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:placeholder];
}

- (void)setGroupAvatar:(MTTGroupEntity *)group
{
    NSMutableArray *ids = [[NSMutableArray alloc]init];
    NSMutableArray *avatars = [[NSMutableArray alloc]init];
    NSArray* data = [[group.groupUserIds reverseObjectEnumerator] allObjects];
    if(data.count>=9){
        for (int i=0; i<9; i++) {
            [ids addObject:[data objectAtIndex:i]];
        }
    }else{
        for (int i=0;i<data.count;i++) {
            [ids addObject:[data objectAtIndex:i]];
        }
    }
    [ids enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString* userID = (NSString*)obj;
        [[DDUserModule shareInstance] getUserForUserID:userID Block:^(MTTUserEntity *user) {
            if (user)
            {
                NSString* avatarTmp = [user getAvatarUrl];
                [avatars addObject:avatarTmp];
            }
        }];
    }];
    
    [self.avatar setAvatar:[avatars componentsJoinedByString:@";"] group:1];
}

@end
