//
//  NSString+MD5.h
//  TZS
//
//  Created by yandi on 14/12/9.
//  Copyright (c) 2014年 NongFuSpring. All rights reserved.
//


@interface NSString (MD5)

+ (NSString *)md5:(NSString *)originalStr;  //14e1b600b1fd579f47433b88e8d85291

+ (NSString *)CurrentTime1970;

//TODO:时间格式化 1小时内 **分钟前  1天内 **小时前 1天外
+ (NSString *)TimeToCurrentTime:(NSInteger)time;

+ (NSString *)CurrentTimeByStrHaveSecond:(BOOL)have;
/**
 *  当前剩余时间
 *
 *  剩余时间字符串(秒)
 *
 *  @return 返回剩余时间字符串
 */
+(NSString *)lessSecondToDay:(NSUInteger)seconds showSecond:(BOOL) show;

/**
 *  剩余多少秒
 *
 *  @param timeString1 到期时间
 *
 *  @return 到现在多少秒
 */
+ (NSInteger)intervalFromLastDate:(NSString *) timeString1  toTheDate:(NSString *) timeString2;
/**
 *  判断字符串是否是纯数字
 *
 *  @param string <#string description#>
 *
 *  @return <#return value description#>
 */
+(BOOL)isPureNumandCharacters:(NSString *)string;

/**
 字符串去首尾空格

 @param str 原始字符串

 @return 去掉首尾空格的字符串
 */
+(NSString*)trimString:(NSString*)str;


/**
 是否是中午
Valid
 @return 中文
 */
+(BOOL)isChinese;

///MARK: 日期转时间yyyy-MM-dd HH:mm
/**
 日期转时间
 Valid
 @return yyyy-MM-dd HH:mm
 */
+(NSString*)timeStringWithDate:(NSDate*)date;

///MARK: 日期转时间yyyy-MM-dd HH:mm:ss
/// 日期转时间
+(NSString*)timeStringyyyyMMddHHmmssWithDate:(NSDate*)date;

///MARK: 日期转时间 MM-dd
/// 日期转时间
+(NSString*)timeStringWithDateMMdd:(NSDate*)date;

///MARK: 日期转时间 HH:mm
/// 日期转时间
+(NSString*)timeStringWithDateHHmm:(NSDate*)date;

///MARK: 日期转时间 MM-dd HH:mm
/**
 日期转时间
 Valid
 @return MM-dd HH:mm
 */
+(NSString*)timeStringMMddHHmmWithDate:(NSDate*)date;

///MARK: 日期转时间 M月d日 HH:mm
/**
 日期转时间
 Valid
 @return M月d日 HH:mm
 */
+(NSString*)timeStringMdHHmmWithDate:(NSDate*)date;

/**
 日期转日期字符串
 Valid
 @return yyyy-HH-dd
 */
+(NSString*)dateStringWithDate:(NSDate*)date;

//MARK: NSString 转时间戳
/**
 NSString 转时间戳
 Valid
 @return 时间戳    
 */
+(NSString*)timestampWithString:(NSString*)datestr;


//MARK: data转时间戳
/**
data转时间戳
 Valid
 @return 时间戳
 */
+(NSString*)timestampWithDate:(NSDate*)date;


//MARK:图片地址格式化
///MARK: 图片地址格式化
+(NSString *)formatImageUrlWith:(NSString *)urlStr ifThumb:(BOOL)thumb thumb_W:(NSInteger)thumb_W;;

//MARK:去掉Html标签
/// 去掉Html标签
+(NSString *)filterHTML:(NSString *)html;


@end




