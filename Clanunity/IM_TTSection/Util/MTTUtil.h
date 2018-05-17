//
//  MTTUtil.h
//  TeamTalk
//
//  Created by 宪法 on 15/6/18.
//  Copyright (c) 2015年 MoguIM. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MTTUtil : NSObject

#pragma mark - 拼音

+(char)pinyinFirstLetter:(unsigned short)hanzi;

+(char)getFirstChar:(const NSString *)str;

#pragma mark - loginOut

+(void)loginOut;

#pragma mark - show Alert

+(void)showAlertWithTitle:(NSString *)title message:(NSString *)message;

#pragma mark - OriginalID & sessionID

+(UInt32)changeIDToOriginal:(NSString *)sessionID;

/**
 配置id

 @param orignalID 原始id 数字
 @param sessionType 类型：1单聊/2群聊，如果是单聊前缀user_,如果是群聊前缀 group_
 @return 对应的id
 */
+(NSString *)changeOriginalToLocalID:(UInt32)orignalID SessionType:(int)sessionType;

#pragma mark - fiexed top

// 设置置顶
+(void)setFixedTop:(NSString *)sessionID;
// 获取置顶
+(NSArray *)getFixedTop;
// 移除置顶
+(void)removeFixedTop:(NSString *)sessionID;
// 检查置顶
+(BOOL)checkFixedTop:(NSString *)sessionID;

#pragma mark - new function

//是否使用签名功能
+(BOOL)isUseFunctionBubble;

//使用签名功能
+(void)useFunctionBubble;

#pragma mark - image trans

+(CGSize)sizeTrans:(CGSize)size;

#pragma mark - 气泡功能
+(NSString *)getBubbleTypeLeft:(BOOL)left;
+(void)setBubbleTypeLeft:(NSString *)bubbleType left:(BOOL)left;
#pragma mark - 图片发送预览时间记载
+(void)setLastPhotoTime:(NSDate *)date;
+(NSDate *)getLastPhotoTime;
#pragma mark - 抖动功能
+(void)setLastShakeTime:(NSDate *)date;
+(BOOL)ifCanShake;
#pragma mark - dbversion
+(void)setDBVersion:(NSInteger)version;
+(NSInteger)getDBVersion;
+(void)setLastDBVersion:(NSInteger)version;
+(NSInteger)getLastDBVersion;
#pragma mark - msfs
+(void)setMsfsUrl:(NSString*)url;
+(NSString*)getMsfsUrl;
@end
