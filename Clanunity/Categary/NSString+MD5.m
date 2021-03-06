//
//  NSString+MD5.m
//  TZS
//
//  Created by yandi on 14/12/9.
//  Copyright (c) 2014年 NongFuSpring. All rights reserved.
//

#import "NSString+MD5.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (MD5)
+ (NSString *)md5:(NSString *)originalStr {
    //    CC_MD5_CTX md5;
    //    CC_MD5_Init (&md5);
    //    CC_MD5_Update (&md5, [originalStr UTF8String], (CC_LONG)[originalStr length]);
    //    
    //    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    //    CC_MD5_Final (digest, &md5);
    //    NSString *s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
    //                   digest[0],  digest[1],
    //                   digest[2],  digest[3],
    //                   digest[4],  digest[5],
    //                   digest[6],  digest[7],
    //                   digest[8],  digest[9],
    //                   digest[10], digest[11],
    //                   digest[12], digest[13],
    //                   digest[14], digest[15]];
    //    return s;
    
    const char *cStr = [originalStr UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
    
}



+(NSString*)CurrentTime1970{
    
    NSDate *date = [NSDate date];
    NSTimeInterval time  = date.timeIntervalSince1970;
    NSString *timeStr = [NSString stringWithFormat:@"%.f",time];
    return timeStr;
    
}



+(NSString*)TimeToCurrentTime:(NSInteger)time{
    
    NSInteger giveTime = time ;
    NSInteger returnTime ;
    NSInteger  mm      = 60;       //分
    NSInteger  hh      = mm * 60;  // 时
    NSInteger  dd      = hh * 24 ; // 天
    NSInteger  MM      = dd * 30;  // 月
    NSInteger  yy      = MM * 12;  // 年
    
    if (giveTime < mm) {
        return [NSString stringWithFormat:@"%ld秒前",(long)giveTime];//秒
    }else if(mm       <= giveTime && giveTime<hh){
        returnTime  = giveTime / mm ;
        return [NSString stringWithFormat:@"%ld分钟前",(long)returnTime];//分
    }else if (hh      <= giveTime && giveTime < dd){
        returnTime     =  giveTime /hh;
        return [NSString stringWithFormat:@"%ld小时前",(long)returnTime];
    }else if (dd      <= giveTime && giveTime < MM){
        returnTime     = giveTime / dd ;
        return [NSString stringWithFormat:@"%ld天前",(long)returnTime];
    }else if (MM      <= giveTime && giveTime < yy){
        returnTime     = giveTime / MM ;
        return [NSString stringWithFormat:@"%ld月前",(long)returnTime];
    }else if (yy <= giveTime){
        returnTime    = giveTime / yy ;
        return [NSString stringWithFormat:@"%ld年前",(long)returnTime];
    }
    return @"0秒前";
}



+(NSString*)CurrentTimeByStrHaveSecond:(BOOL)have{
    NSDate *date = [NSDate date];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];//格式化
    if (have) {
//        hh 小时，mm 分钟，ss 秒
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    }else{
        [df setDateFormat:@"yyyy-MM-dd"];
    }
    
    NSString * nowTimeStr = [df stringFromDate:date];
    
    return nowTimeStr;
}


+(NSString *)lessSecondToDay:(NSUInteger)seconds showSecond:(BOOL) show {
    
    NSUInteger day  = (NSUInteger)seconds/(24*3600);
    NSUInteger hour = (NSUInteger)(seconds%(24*3600))/3600;
    NSUInteger min  = (NSUInteger)(seconds%(3600))/60;
    NSUInteger second = (NSUInteger)(seconds%60);
    
    NSString *time;
    
    if (day ==0) {
        if (show) {
            time = [NSString stringWithFormat:@"%lu时%lu分%lu秒",(unsigned long)hour,(unsigned long)min,(unsigned long)second];
            if (hour == 0) {
                time = [NSString stringWithFormat:@"%lu分%lu秒",(unsigned long)min,(unsigned long)second];
            }
        }else
        {
            time = [NSString stringWithFormat:@"%lu时%lu分",(unsigned long)hour,(unsigned long)min];
            if (hour == 0) {
                time = [NSString stringWithFormat:@"%lu分",(unsigned long)min];
            }
        }
    }else
    {
        if (show) {
            time = [NSString stringWithFormat:@"%lu天%lu时%lu分%lu秒 ",(unsigned long)day,(unsigned long)hour,(unsigned long)min,(unsigned long)second];
        }else
        {
            time = [NSString stringWithFormat:@"%lu天%lu时%lu分",(unsigned long)day,(unsigned long)hour,(unsigned long)min];
        }
        
    }
    
    
    return time;
}


+ (NSInteger)intervalFromLastDate:(NSString *)timeString1  toTheDate:(NSString *) timeString2
{
        NSDateFormatter *date=[[NSDateFormatter alloc] init];
        [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *d1=[date dateFromString:timeString1];
        NSTimeInterval late1=[d1 timeIntervalSince1970];
        NSDate *d2=[date dateFromString:timeString2];
        NSTimeInterval late2=[d2 timeIntervalSince1970];
        NSTimeInterval cha=late2-late1;
        return cha;
}

+(BOOL)isPureNumandCharacters:(NSString *)string
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if(string.length > 0)
    {
        return NO;
    }
    return YES;
}

+(NSString*)trimString:(NSString*)str{
    NSString *tmp = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [tmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

+(BOOL)isChinese
{
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}

///MARK: 日期转时间yyyy-MM-dd HH:mm
/// 日期转时间
+(NSString*)timeStringWithDate:(NSDate*)date{
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString* timeStr=[dateFormat stringFromDate:date];
    return timeStr;
}

///MARK: 日期转时间yyyy-MM-dd HH:mm:ss
/// 日期转时间
+(NSString*)timeStringyyyyMMddHHmmssWithDate:(NSDate*)date{
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* timeStr=[dateFormat stringFromDate:date];
    return timeStr;
}

///MARK: 日期转时间 MM-dd
/// 日期转时间
+(NSString*)timeStringWithDateMMdd:(NSDate*)date{
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MM-dd"];
    NSString* timeStr=[dateFormat stringFromDate:date];
    return timeStr;
}

///MARK: 日期转时间 HH:mm
/// 日期转时间
+(NSString*)timeStringWithDateHHmm:(NSDate*)date{
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"HH:mm"];
    NSString* timeStr=[dateFormat stringFromDate:date];
    return timeStr;
}

///MARK: 日期转时间 MM-dd HH:mm
+(NSString*)timeStringMMddHHmmWithDate:(NSDate*)date;{
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"M-d HH:"];
    NSString* timeStr=[dateFormat stringFromDate:date];
    
    [dateFormat setDateFormat:@"mm"];
    NSString* minutStr=[dateFormat stringFromDate:date];
    
    return [NSString stringWithFormat:@"%@%@",timeStr ,[minutStr stringByReplacingCharactersInRange:NSMakeRange(1, 1) withString:@"0"]];
}

///MARK: 日期转时间 M月d日 HH:mm
+(NSString*)timeStringMdHHmmWithDate:(NSDate*)date;{
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"M月d日 HH:mm"];
    NSString* timeStr=[dateFormat stringFromDate:date];
    return timeStr;
}

///MARK: 日期转日期字符串
+(NSString*)dateStringWithDate:(NSDate*)date{
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString* timeStr=[dateFormat stringFromDate:date];
    return timeStr;
}

//MARK: 时间转时间戳
+(NSString*)timestampWithString:(NSString*)datestr;{
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:datestr];
    
    return [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]*1000];//时间戳
}

//MARK: data转时间戳
+(NSString*)timestampWithDate:(NSDate*)date;{
    return [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]*1000];//时间戳
}

///MARK: 图片地址格式化
/// thumb:是否取缩略图  thumb_W：缩略图的宽度    //头像 80  单图0（默认300）  多图150
+(NSString *)formatImageUrlWith:(NSString *)urlStr ifThumb:(BOOL)thumb thumb_W:(NSInteger)thumb_W;{
    if ([urlStr containsString:@"http"]){
        return urlStr;
    }else{
        if ([urlStr length] > 0){
            NSString * str = [NSString stringWithFormat:@"%@%@", [ClanAPI resourceName],urlStr];
            UIImage *img = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:str];
            
            if (img != nil){
                return str;
            }
            
            if (thumb){
                if (thumb_W == 0){
                    thumb_W = 300;
                }
                str = [NSString stringWithFormat:@"%@%@%@%ld", [ClanAPI resourceName],urlStr,@"?x-oss-process=image/resize,w_",(long)thumb_W];
            }else{
                str = [NSString stringWithFormat:@"%@%@", [ClanAPI resourceName],urlStr];
            }
            return str;
        }
        return @"";
    }
}

///MARK: 去掉Html标签
+(NSString *)filterHTML:(NSString *)html
{
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        [scanner scanUpToString:@"<" intoString:nil];
        [scanner scanUpToString:@">" intoString:&text];
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    return html;
}



@end
