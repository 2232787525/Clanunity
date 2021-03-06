//
//  ChatBaseSuperVC.m
//  Clanunity
//
//  Created by wangyadong on 2018/4/20.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

#import "ChatBaseSuperVC.h"
#import "MTTDatabaseUtil.h"


@interface ChatBaseSuperVC ()

@property(nonatomic,strong)NSMutableDictionary *userTeamID_Username;

@end

@implementation ChatBaseSuperVC

-(NSMutableDictionary *)userTeamID_Username{
    if (_userTeamID_Username == nil) {
        _userTeamID_Username = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _userTeamID_Username;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[PlayerManager sharedManager] stopPlaying];
}
- (void)handleWillShowKeyboard:(NSNotification *)notification
{
}
- (void)handleWillHideKeyboard:(NSNotification *)notification
{
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createRightMember];
    // Do any additional setup after loading the view.
}
#pragma mark - makeTable
-(UITableView *)tableView{
    if (_tableView == nil) {
        
        UITableView *tab = [[UITableView alloc] initWithFrame:CGRectMake(0, KTopHeight,KScreenWidth,KScreenHeight-KTopHeight-DDINPUT_MIN_HEIGHT) style:UITableViewStylePlain];
//        tab.delegate = self;
//        tab.dataSource = self;
        tab.backgroundColor = [UIColor whiteColor];
        tab.separatorStyle = UITableViewCellSeparatorStyleNone;
        if ([tab respondsToSelector:@selector(setSeparatorInset:)]) {
            [tab setSeparatorInset:UIEdgeInsetsZero];
        }
        //ios8
        if ([tab respondsToSelector:@selector(setLayoutMargins:)]) {
            [tab setLayoutMargins:UIEdgeInsetsZero];
        }
        
        
        _tableView = tab;
    }
    return _tableView;
}
- (void)p_tapOnTableView:(UIGestureRecognizer*)sender{
    
}

#pragma mark - 右按钮设置-群/好友
-(void)createRightMember{
    
    NSString *icon = @"";
    if (self.module.MTTSessionEntity.sessionType == SessionTypeSessionTypeGroup) {
        icon = @"groupChatIcon";
    }else if (self.module.MTTSessionEntity.sessionType == SessionTypeSessionTypeSingle){
        icon = @"singleChatIcon";
    }
    WeakSelf
    self.knavigationBar.rightBarBtnItem = [[KNaviBarBtnItem alloc] initWithFrame:CGRectMake(0, 0, 44, 44) image:icon hander:^(id _Nonnull sender) {
        ChatMembersDetialVC * memberVC = [[ChatMembersDetialVC alloc] init];
        
        if (self.module.MTTSessionEntity.sessionType == SessionTypeSessionTypeGroup) {
            memberVC.singleChat = NO;
            MTTGroupEntity *groupModel = [[MTTGroupEntity alloc] init];
            groupModel.objID = weakSelf.module.MTTSessionEntity.sessionID;
            groupModel.notice = self.notice;
            groupModel.id =  (NSInteger)[MTTUtil changeIDToOriginal:weakSelf.module.MTTSessionEntity.sessionID];
            [groupModel setGroupUserIds:[NSMutableArray arrayWithArray:weakSelf.module.MTTSessionEntity.sessionUsers]];
            groupModel.isShield =weakSelf.module.MTTSessionEntity.isShield;
            groupModel.name = weakSelf.module.MTTSessionEntity.name;
            memberVC.groupModel = groupModel;
            
            [memberVC setDeletetResult:^(MTTGroupEntity * _Nonnull group) {
                [self kBackBtnAction];
            }];
        }else if (self.module.MTTSessionEntity.sessionType == SessionTypeSessionTypeSingle){
            memberVC.singleChat = YES;
            MTTUserEntity *user = [[MTTUserEntity alloc] init];
            user.teamid = (NSInteger)[MTTUtil changeIDToOriginal:weakSelf.module.MTTSessionEntity.sessionID];
            user.realname = weakSelf.module.MTTSessionEntity.name;
            memberVC.singleModel = user;
        }
        [weakSelf.navigationController pushViewController:memberVC animated:YES];
        
    }];
}



#pragma mark PrivateAPI

- (UITableViewCell*)p_textCell_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath message:(MTTMessageEntity*)message
{
    static NSString* identifier = @"DDChatTextCellIdentifier";
    DDChatBaseCell* cell = (DDChatBaseCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[DDChatTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.contentLabel.delegate = self;
    }
    cell.session =self.module.MTTSessionEntity;
    NSString* myUserID = [RuntimeStatus instance].user.objID;
    if ([message.senderId isEqualToString:myUserID])
    {
        [cell setLocation:DDBubbleRight];
    }
    else
    {
        [cell setLocation:DDBubbleLeft];
    }
    
    if (![[UnAckMessageManager instance] isInUnAckQueue:message] && message.state == DDMessageSending && [message isSendBySelf]) {
        message.state=DDMessageSendFailure;
    }
    [[MTTDatabaseUtil instance] updateMessageForMessage:message completion:^(BOOL result) {
        
    }];
    
    [cell setContent:message];
    __weak DDChatTextCell* weakCell = (DDChatTextCell*)cell;
    cell.sendAgain = ^{
        [weakCell showSending];
        [weakCell sendTextAgain:message];
    };
    
    return cell;
}


- (UITableViewCell*)p_voiceCell_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath message:(MTTMessageEntity*)message
{
    static NSString* identifier = @"DDVoiceCellIdentifier";
    DDChatBaseCell* cell = (DDChatBaseCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell)
    {
        cell = [[DDChatVoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.session =self.module.MTTSessionEntity;
    NSString* myUserID = [RuntimeStatus instance].user.objID;
    if ([message.senderId isEqualToString:myUserID])
    {
        [cell setLocation:DDBubbleRight];
    }
    else
    {
        [cell setLocation:DDBubbleLeft];
    }
    [cell setContent:message];
    __weak DDChatVoiceCell* weakCell = (DDChatVoiceCell*)cell;
    [(DDChatVoiceCell*)cell setTapInBubble:^{
        //播放语音
        if ([[PlayerManager sharedManager] playingFileName:message.msgContent]) {
            [[PlayerManager sharedManager] stopPlaying];
        }else{
            NSString* fileName = message.msgContent;
            [[PlayerManager sharedManager] playAudioWithFileName:fileName delegate:self];
            [message.info setObject:@(1) forKey:DDVOICE_PLAYED];
            [weakCell showVoicePlayed];
            [[MTTDatabaseUtil instance] updateMessageForMessage:message completion:^(BOOL result) {
            }];
        }
        
    }];
    
    [(DDChatVoiceCell*)cell setEarphonePlay:^{
        //听筒播放
        NSString* fileName = message.msgContent;
        [[PlayerManager sharedManager] playAudioWithFileName:fileName playerType:DDEarPhone delegate:self];
        [message.info setObject:@(1) forKey:DDVOICE_PLAYED];
        [weakCell showVoicePlayed];
        
        [[MTTDatabaseUtil instance] updateMessageForMessage:message completion:^(BOOL result) {
            
        }];
        
    }];
    
    [(DDChatVoiceCell*)cell setSpeakerPlay:^{
        //扬声器播放
        NSString* fileName = message.msgContent;
        [[PlayerManager sharedManager] playAudioWithFileName:fileName playerType:DDSpeaker delegate:self];
        [message.info setObject:@(1) forKey:DDVOICE_PLAYED];
        [weakCell showVoicePlayed];
        [[MTTDatabaseUtil instance] updateMessageForMessage:message completion:^(BOOL result) {
            
        }];
        
    }];
    [(DDChatVoiceCell *)cell setSendAgain:^{
        //重发
        [weakCell showSending];
        [weakCell sendVoiceAgain:message];
    }];
    return cell;
}
#pragma mark PlayingDelegate
- (void)playingStoped{
    NSLog(@"语音播放结束");
}

- (UITableViewCell*)p_promptCell_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath message:(DDPromptEntity*)prompt
{
    static NSString* identifier = @"DDPromptCellIdentifier";
    DDPromptCell* cell = (DDPromptCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[DDPromptCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString* promptMessage = prompt.message;
    [cell setprompt:promptMessage];
    return cell;
}
- (UITableViewCell*)p_emotionCell_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath message:(MTTMessageEntity*)message
{
    static NSString* identifier = @"DDEmotionCellIdentifier";
    DDEmotionCell* cell = (DDEmotionCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[DDEmotionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.session =self.module.MTTSessionEntity;
    NSString* myUserID =[RuntimeStatus instance].user.objID;
    if ([message.senderId isEqualToString:myUserID])
    {
        [cell setLocation:DDBubbleRight];
    }
    else
    {
        [cell setLocation:DDBubbleLeft];
    }
    
    [cell setContent:message];
    __weak DDEmotionCell* weakCell = cell;
    
    [cell setSendAgain:^{
        [weakCell sendTextAgain:message];
        
    }];
    
    [cell setTapInBubble:^{
        
    }];
    return cell;
}

- (UITableViewCell*)p_imageCell_tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath message:(MTTMessageEntity*)message
{
    static NSString* identifier = @"DDImageCellIdentifier";
    DDChatImageCell* cell = (DDChatImageCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[DDChatImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.session =self.module.MTTSessionEntity;
    NSString* myUserID =[RuntimeStatus instance].user.objID;
    if ([message.senderId isEqualToString:myUserID])
    {
        [cell setLocation:DDBubbleRight];
    }
    else
    {
        [cell setLocation:DDBubbleLeft];
    }
    
    [[MTTDatabaseUtil instance] updateMessageForMessage:message completion:^(BOOL result) {
        
    }];
    [cell setContent:message];
    __weak DDChatImageCell* weakCell = cell;
    
    [cell setSendAgain:^{
        [weakCell sendImageAgain:message];
        
    }];
    
    [cell setTapInBubble:^{
        NSString *tapOriginUrl =  message.msgContent;
        tapOriginUrl = [tapOriginUrl stringByReplacingOccurrencesOfString:DD_MESSAGE_IMAGE_PREFIX withString:@""];
        tapOriginUrl = [tapOriginUrl stringByReplacingOccurrencesOfString:DD_MESSAGE_IMAGE_SUFFIX withString:@""];
        NSURL* tapUrl = [NSURL URLWithString:tapOriginUrl];
        NSMutableArray *photos = [[NSMutableArray alloc]init];
        [self.module.showingMessages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[MTTMessageEntity class]])
            {
                MTTMessageEntity* message = (MTTMessageEntity*)obj;
                NSURL* allImgUrl;
                if(message.msgContentType == DDMessageTypeImage){
                    NSString* urlString = message.msgContent;
                    urlString = [urlString stringByReplacingOccurrencesOfString:DD_MESSAGE_IMAGE_PREFIX withString:@""];
                    urlString = [urlString stringByReplacingOccurrencesOfString:DD_MESSAGE_IMAGE_SUFFIX withString:@""];
                    if([urlString rangeOfString:@"\"local\" : "].length >0){
                        NSData* data = [urlString dataUsingEncoding:NSUTF8StringEncoding];
                        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        allImgUrl = [NSURL URLWithString:dic[@"url"]];
                    }else{
                        allImgUrl = [NSURL URLWithString:urlString];
                    }
                    if(allImgUrl){//改了，改成了[url absoluteString]，之前是直接url
                        [photos addObject:[allImgUrl absoluteString]];
                    }
                }
            }
        }];
        NSInteger tapIndex = 0;
        if ([photos containsObject:[tapUrl absoluteString]]) {
           tapIndex = [photos indexOfObject:[tapUrl absoluteString]];
        }
        
        [PLGlobalClass imgTapClicked:tapIndex imageArr:photos];
        return ;
        DDChatImagePreviewViewController *preViewControll = [DDChatImagePreviewViewController new];
        NSMutableArray *array = [NSMutableArray array];
        [photos enumerateObjectsUsingBlock:^(NSURL *obj, NSUInteger idx, BOOL *stop) {
            [array addObject:[MWPhoto photoWithURL:obj]];
        }];
        preViewControll.photos=array;
        preViewControll.index=[photos indexOfObject:tapUrl];
        
        [self presentViewController:preViewControll animated:YES completion:NULL];
    }];
    
    [cell setPreview:cell.tapInBubble];
    
    return cell;
}
- (ChattingModule*)module
{
    if (!_module)
    {
        _module = [[ChattingModule alloc] init];
    }
    return _module;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
