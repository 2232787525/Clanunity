//
//  ChatBaseSuperVC.h
//  Clanunity
//
//  Created by wangyadong on 2018/4/20.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import "KBaseClanViewController.h"
#import "JSMessageInputView.h"
#import "DDChatBaseCell.h"
#import "DDChatTextCell.h"
#import "DDChatVoiceCell.h"
#import "DDPromptCell.h"
#import "DDEmotionCell.h"
#import "DDChatImageCell.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "ChattingModule.h"
#import "PlayerManager.h"
#import "UnAckMessageManager.h"



@interface ChatBaseSuperVC : KBaseClanViewController<TTTAttributedLabelDelegate,PlayingDelegate>



/**
 群聊才传
 */
@property(nonatomic,copy)NSString * notice;

@property(nonatomic,strong)JSMessageInputView *chatInputView;
@property(nonatomic,strong) UITableView *tableView;

@property(nonatomic,strong)ChattingModule* module;

-(void)createRightMember;
- (void)p_tapOnTableView:(UIGestureRecognizer*)sender;


- (void)handleWillShowKeyboard:(NSNotification *)notification;
- (void)handleWillHideKeyboard:(NSNotification *)notification;



#pragma mark PrivateAPI
- (UITableViewCell*)p_textCell_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath message:(MTTMessageEntity*)message;
- (UITableViewCell*)p_voiceCell_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath message:(MTTMessageEntity*)message;
- (UITableViewCell*)p_promptCell_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath message:(DDPromptEntity*)prompt;
- (UITableViewCell*)p_emotionCell_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath message:(MTTMessageEntity*)message;
- (UITableViewCell*)p_imageCell_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath message:(MTTMessageEntity*)message;

@end




typedef NS_ENUM(NSUInteger, DDBottomShowComponent)
{
    DDInputViewUp                       = 1,
    DDShowKeyboard                      = 1 << 1,
    DDShowEmotion                       = 1 << 2,
    DDShowUtility                       = 1 << 3
};

typedef NS_ENUM(NSUInteger, DDBottomHiddComponent)
{
    DDInputViewDown                     = 14,
    DDHideKeyboard                      = 13,
    DDHideEmotion                       = 11,
    DDHideUtility                       = 7
};
//

typedef NS_ENUM(NSUInteger, DDInputType)
{
    DDVoiceInput,
    DDTextInput
};

typedef NS_ENUM(NSUInteger, PanelStatus)
{
    
    VoiceStatus,
    TextInputStatus,
    EmotionStatus,
    ImageStatus
};

#define DDINPUT_MIN_HEIGHT          44.0f
#define DDINPUT_HEIGHT              self.chatInputView.size.height
#define DDINPUT_BOTTOM_FRAME        CGRectMake(0, KScreenHeight - self.chatInputView.height,KScreenWidth,self.chatInputView.height)
#define DDINPUT_TOP_FRAME           CGRectMake(0, KScreenHeight - self.chatInputView.height  - 216, KScreenWidth, self.chatInputView.height)
#define DDUTILITY_FRAME             CGRectMake(0, KScreenHeight -216, KScreenWidth, 216)
#define DDEMOTION_FRAME             CGRectMake(0,KScreenHeight -216, KScreenWidth, 280)
#define DDCOMPONENT_BOTTOM          CGRectMake(0, KScreenHeight, KScreenWidth, 216)

