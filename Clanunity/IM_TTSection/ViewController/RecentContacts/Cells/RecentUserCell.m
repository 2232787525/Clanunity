//
//  DDRecentUserCell.m
//  IOSDuoduo
//
//  Created by 独嘉 on 14-5-26.
//  Copyright (c) 2014年 dujia. All rights reserved.
//

#import "RecentUserCell.h"
#import "UIImageView+WebCache.h"
#import "NSDate+DDAddition.h"
#import "UIView+Addition.h"
#import "RuntimeStatus.h"
#import "MTTUserEntity.h"
#import "DDMessageModule.h"
#import "DDUserModule.h"
#import "MTTSessionEntity.h"
#import "DDGroupModule.h"
#import <QuartzCore/QuartzCore.h>
#import "MTTPhotosCache.h"
#import "MTTDatabaseUtil.h"
#import <Masonry/Masonry.h>
#import "MTTAvatarImageView.h"
#import "DDUserDetailInfoAPI.h"
@implementation RecentUserCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _avatarImageView = [MTTAvatarImageView new];
        [self.contentView addSubview:_avatarImageView];
        [_avatarImageView setClipsToBounds:YES];
        [_avatarImageView.layer setCornerRadius:4.0];
        [_avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50, 50));
            make.top.mas_equalTo(10);
            make.left.mas_equalTo(10);
        }];
        _avatarImageView.layer.borderColor = [UIColor cutLineColor].CGColor;
        _avatarImageView.layer.borderWidth = 0.5;
        
        _unreadMessageCountLabel = [UILabel new];
        [_unreadMessageCountLabel setBackgroundColor:RGB(242, 49, 54)];
        [_unreadMessageCountLabel setClipsToBounds:YES];
        [_unreadMessageCountLabel.layer setCornerRadius:9];
        [_unreadMessageCountLabel setTextColor:[UIColor whiteColor]];
        [_unreadMessageCountLabel setFont:systemFont(12)];
        [_unreadMessageCountLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:_unreadMessageCountLabel];
        [_unreadMessageCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(18, 18));
            make.top.mas_equalTo(2);
            make.right.equalTo(_avatarImageView.mas_right).offset(9);
        }];
        
        _shiledUnreadMessageCountLabel = [UILabel new];
        [_shiledUnreadMessageCountLabel setBackgroundColor:RGB(242, 49, 54)];
        [_shiledUnreadMessageCountLabel setClipsToBounds:YES];
        [_shiledUnreadMessageCountLabel.layer setCornerRadius:5];
        [_shiledUnreadMessageCountLabel setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:_shiledUnreadMessageCountLabel];
        [_shiledUnreadMessageCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(10, 10));
            make.top.mas_equalTo(6);
            make.right.equalTo(_avatarImageView.mas_right).offset(4);
        }];
        [_shiledUnreadMessageCountLabel setHidden:YES];
        
        _nameLabel = [UILabel new];
        _nameLabel.font = [UIFont boldSystemFontOfSize:16];
        _nameLabel.textColor = [UIColor textColor1];
        [self.contentView addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatarImageView.mas_right).offset(10);
            make.right.mas_equalTo(self.contentView).offset(-70);
            make.top.mas_equalTo(15);
            make.height.mas_equalTo(17);
        }];
        
        _dateLabel = [UILabel new];
        [_dateLabel setFont:systemFont(12)];
        _dateLabel.textColor = [UIColor textColor3];
        [_dateLabel setTextAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:_dateLabel];
        [_dateLabel setTextColor:RGB(170, 170, 170)];
        [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView).offset(-10);
            make.top.mas_equalTo(15);
            make.height.mas_equalTo(12);
            make.width.mas_equalTo(60);
        }];
        
        _shiledImageView = [UIImageView new];
        UIImage* shieldImg = [UIImage imageNamed:@"shielded"];
        [_shiledImageView setImage:shieldImg];
        [self.contentView addSubview:_shiledImageView];
        [_shiledImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(14, 14));
            make.right.mas_equalTo(self.contentView).offset(-10);
            make.top.mas_equalTo(_dateLabel.mas_bottom).offset(15);
        }];
        
        _lastmessageLabel = [UILabel new];
        [_lastmessageLabel setFont:systemFont(14)];
        [_lastmessageLabel setTextColor:[UIColor textColor2]];
        [self.contentView addSubview:_lastmessageLabel];
        [_lastmessageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_avatarImageView.mas_right).offset(10);
            make.right.mas_equalTo(self.contentView).offset(-70);
            make.top.mas_equalTo(_nameLabel.mas_bottom).offset(10);
            make.height.mas_equalTo(16);
        }];
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = RGB(244, 245, 246);
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected)
    {
        [_nameLabel setTextColor:[UIColor whiteColor]];
        [_lastmessageLabel setTextColor:[UIColor whiteColor]];
        [_dateLabel setTextColor:[UIColor whiteColor]];
    }
    else
    {
        [_nameLabel setTextColor:[UIColor blackColor]];
        [_lastmessageLabel setTextColor:RGB(135, 135, 135)];
        [_dateLabel setTextColor:RGB(135, 135, 135)];
    }
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated               // animate between regular and highlighted state
{
    if (highlighted && self.selected)
    {
        [_nameLabel setTextColor:[UIColor whiteColor]];
        [_lastmessageLabel setTextColor:[UIColor whiteColor]];
        [_dateLabel setTextColor:[UIColor whiteColor]];
    }
    else
    {
        [_nameLabel setTextColor:[UIColor blackColor]];
        [_lastmessageLabel setTextColor:RGB(135, 135, 135)];
        [_dateLabel setTextColor:RGB(135, 135, 135)];
    }
}

#pragma mark - public
- (void)setName:(NSString*)name
{
    if (!name)
    {
        [_nameLabel setText:@""];
    }
    else
    {
        [_nameLabel setText:name];
    }
}

- (void)setTimeStamp:(NSUInteger)timeStamp
{
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSString* dateString = [PLGlobalClass chatListFormatStringWithDate:date];
    [_dateLabel setText:dateString];
    
    //NSString* dateString = [date transformToFuzzyDate];
}

- (void)setLastMessage:(NSString*)message
{
    if (!message)
    {
        [_lastmessageLabel setText:@"."];
    }
    else
    {
        [_lastmessageLabel setText:message];
    }
}

- (void)setAvatar:(NSString*)avatar
{
    [[_avatarImageView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(UIView*)obj removeFromSuperview];
    }];
    
    NSURL* avatarURL = [NSURL URLWithString:avatar];
    UIImage* placeholder = [UIImage imageNamed:@"user_placeholder"];
    [_avatarImageView sd_setImageWithURL:avatarURL placeholderImage:placeholder];
}

- (void)setShiledUnreadMessage
{
    [self.unreadMessageCountLabel setHidden:YES];
    [self.shiledUnreadMessageCountLabel setHidden:NO];
}

- (void)setUnreadMessageCount:(NSUInteger)messageCount
{
    if (messageCount == 0)
    {
        [self.unreadMessageCountLabel setHidden:YES];
    }
    else if (messageCount < 10)
    {
        [self.unreadMessageCountLabel setHidden:NO];
        CGPoint center = self.unreadMessageCountLabel.center;
        NSString* title = [NSString stringWithFormat:@"%li",messageCount];
        [self.unreadMessageCountLabel setText:title];
        [self.unreadMessageCountLabel setWidth:16];
        [self.unreadMessageCountLabel setCenter:center];
        [self.unreadMessageCountLabel.layer setCornerRadius:8];
    }
    else if (messageCount < 99)
    {
        [self.unreadMessageCountLabel setHidden:NO];
        CGPoint center = self.unreadMessageCountLabel.center;
        NSString* title = [NSString stringWithFormat:@"%li",messageCount];
        [self.unreadMessageCountLabel setText:title];
        [self.unreadMessageCountLabel setWidth:25];
        [self.unreadMessageCountLabel setCenter:center];
        [self.unreadMessageCountLabel.layer setCornerRadius:8];
    }
    else
    {
        [self.unreadMessageCountLabel setHidden:NO];
        CGPoint center = self.unreadMessageCountLabel.center;
        NSString* title = @"99+";
        [self.unreadMessageCountLabel setText:title];
        [self.unreadMessageCountLabel setWidth:34];
        [self.unreadMessageCountLabel setCenter:center];
        [self.unreadMessageCountLabel.layer setCornerRadius:8];
    }
}


-(void)setShowSession:(MTTSessionEntity *)session
{
    [self setName:session.name];
    
    NSString *msgcont = @"";
    if ([session.lastMsg isKindOfClass:[NSString class]]) {
        if ([session.lastMsg rangeOfString:DD_MESSAGE_IMAGE_PREFIX].location != NSNotFound) {
            NSArray *array = [session.lastMsg componentsSeparatedByString:DD_MESSAGE_IMAGE_PREFIX];
            NSString *string = [array lastObject];
            if ([string rangeOfString:DD_MESSAGE_IMAGE_SUFFIX].location != NSNotFound) {
                msgcont = @"[图片]";
                [self setLastMessage:@"[图片]"];
            }else{
                msgcont = string;
                [self setLastMessage:string];
            }
            
        }else if ([session.lastMsg hasSuffix:@".spx"])
        {
            msgcont = @"[语音]";
            [self setLastMessage:@"[语音]"];
        }
        else{
            msgcont = session.lastMsg;
            [self setLastMessage:session.lastMsg];
            
        }
    }
    
    if (session.sessionType == SessionTypeSessionTypeSingle) {
        [_avatarImageView setBackgroundColor:[UIColor clearColor]];
        
        [[DDUserModule shareInstance] getUserForUserID:session.sessionID Block:^(MTTUserEntity *user) {
            [[_avatarImageView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [(UIView*)obj removeFromSuperview];
            }];
            [_avatarImageView setImage:nil];
            
            [self setAvatar:[user getAvatarUrl]];
        }];
    }else{
        [_avatarImageView setBackgroundColor:RGB(228, 227, 230)];
        [_avatarImageView setImage:nil];
        [_avatarImageView removeAllSubviews];
        WeakSelf;
        [[DDGroupModule instance] getGroupInfogroupID:session.sessionID completion:^(MTTGroupEntity *group) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.avatarImageView setGroupAvatars:group.imgArray];
            });
//            if (weakSelf.reloadCell) {
//                weakSelf.reloadCell(0);
//            }
        }];
        
        
         
        NSLog(@"lastmsg_id : %@ ==> %@",@(session.lastMsgID),session.lastMsg);
        if (session.sessionType == SessionTypeSessionTypeGroup) {
            if (session.lastFromUserNickname.length == 0) {
                if (session.lastFromUserId) {
                    // 获取签名
                    DDUserDetailInfoAPI *request = [DDUserDetailInfoAPI new];
                    NSMutableArray *array = [[NSMutableArray alloc]init];
                    [array addObject:@(session.lastFromUserId)];
                    [request requestWithObject:array Completion:^(NSArray *response, NSError *error) {
                        if(response){
                            NSLog(@"=======>>>> %@,%@",[(MTTUserEntity*)response[0] nick],[(MTTUserEntity*)response[0] nickname]);
                            session.lastFromUserNickname =[(MTTUserEntity*)response[0] nick];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf setLastMessage:[NSString stringWithFormat:@"%@:%@",session.lastFromUserNickname,msgcont]];
                            });

                        }
                    }];
                }
            }else{
                [self setLastMessage:[NSString stringWithFormat:@"%@:%@",session.lastFromUserNickname,msgcont]];
            }
        }
        
        
        
    }
    [self.shiledUnreadMessageCountLabel setHidden:YES];
    [self setUnreadMessageCount:session.unReadMsgCount];
    [self.shiledImageView setHidden:YES];
    if(session.isGroup){
        MTTGroupEntity *group = [[DDGroupModule instance] getGroupByGId:session.sessionID];
        if (group) {
            if(group.isShield){
                if(session.unReadMsgCount){
                    [self setShiledUnreadMessage];
                }
                [self.shiledImageView setHidden:NO];
            }
        }
    }
    [self setTimeStamp:session.timeInterval];
    if(session.unReadMsgCount)
    {
        //实时获取未读消息从接口
    }
}


-(UIImage *)getImageFromView:(UIView *)orgView{
    CGSize s = orgView.bounds.size;
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    [orgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
