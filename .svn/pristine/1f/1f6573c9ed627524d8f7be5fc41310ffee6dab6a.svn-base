//
//  DDMessageSendManager.h
//  Duoduo
//
//  Created by 独嘉 on 14-3-30.
//  Copyright (c) 2015年 MoguIM All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTTMessageEntity.h"
@class MTTSessionEntity;
typedef void(^DDSendMessageCompletion)(MTTMessageEntity* message,NSError* error);

typedef NS_ENUM(NSUInteger, MessageType)
{
    AllString,
    HasImage
};

@class MTTMessageEntity;
@interface DDMessageSendManager : NSObject
@property (nonatomic,readonly)dispatch_queue_t sendMessageSendQueue;
@property (nonatomic,readonly)NSMutableArray* waitToSendMessage;
+ (instancetype)instance;

/**
 *  发送消息
 *
 *  @param content 发送内容，是富文本
 *  @param session 所属的会话
 */
//- (void)sendMessage:(NSAttributedString*)content forSession:(MTTSessionEntity*)session success:(void(^)(NSString* sendedContent))success  failure:(void(^)(NSString*))failure;

/**
 发送消息

 @param message 消息内容
 @param isGroup 是否是群聊
 @param session 会话ID
 @param completion 完成发送消息
 @param block 失败
 */
- (void)sendMessage:(MTTMessageEntity *)message isGroup:(BOOL)isGroup Session:(MTTSessionEntity*)session completion:(DDSendMessageCompletion)completion Error:(void(^)(NSError *error))block;


/**
 发送消息

 @param voice 语音
 @param filePath 文件路径
 @param sessionID id
 @param isGroup 是否是群聊
 @param msg 消息
 @param session session
 @param completion 回调
 */
- (void)sendVoiceMessage:(NSData*)voice filePath:(NSString*)filePath forSessionID:(NSString*)sessionID isGroup:(BOOL)isGroup Message:(MTTMessageEntity *)msg Session:(MTTSessionEntity*)session completion:(DDSendMessageCompletion)completion;
@end
