//
//  PLGlobalClass.m
//  PlamLive
//
//  Created by wangyadong on 2016/10/31.
//  Copyright © 2016年 wangyadong. All rights reserved.
//

#import "PLGlobalClass.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+Utilities.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ZLPhotoPickerViewController.h"

@implementation PLGlobalClass


//计算文字所占区域大小
+(CGSize)sizeWithText:(NSString*)text font:(UIFont*)fonnt width:(CGFloat)width height:(CGFloat)height{
    NSDictionary *attribute = @{NSFontAttributeName: fonnt};
    
    CGSize size =[text boundingRectWithSize:CGSizeMake(width, height) options:
                  NSStringDrawingTruncatesLastVisibleLine |
                  NSStringDrawingUsesLineFragmentOrigin |
                  NSStringDrawingUsesFontLeading attributes:attribute
                                    context:nil].size;
    CGFloat w = 0.0;
    CGFloat h = 0.0;
    if (!isnan(size.width)) {
        w = size.width;
    }
    if (!isnan(size.height)) {
        h = size.height;
    }
    return CGSizeMake(w, h);
    
}

+(CGSize)sizeAttributeTextWithLineSpaceForLabel:(UILabel*)label textString:(NSString*)textString textFont:(UIFont*)font lineSpaceing:(CGFloat)lineSpace labelWidth:(CGFloat)width{
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:textString];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:lineSpace];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,textString.length)];
    label.attributedText = attributedString;
    label.numberOfLines = 0;
    label.font = font;
    //调节高度
    CGSize size = [label sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    
    CGFloat w = 0.0;
    CGFloat h = 0.0;
    if (!isnan(size.width)) {
        w = size.width;
    }
    if (!isnan(size.height)) {
        h = size.height;
    }
    return CGSizeMake(w, h);
    
}
+(CGSize)sizeForParagraphWithText:(NSString*)text weight:(CGFloat)weight fontSize:(CGFloat)fonts lineSpacing:(CGFloat)lineSpace numberline:(NSInteger)numberline{
    //调节高度
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpace];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.font = [UIFont systemFontOfSize:fonts];
    descLabel.numberOfLines = numberline;
    descLabel.attributedText = attributedString;
    CGSize size = [descLabel sizeThatFits:CGSizeMake(weight , MAXFLOAT)];
    CGFloat w = 0.0;
    CGFloat h = 0.0;
    if (!isnan(size.width)) {
        w = size.width;
    }
    if (!isnan(size.height)) {
        h = size.height;
    }
    return CGSizeMake(w, h);
}

+(void)paragraphForlabel:(UILabel*)label lineSpace:(CGFloat)lineSpace{
    lineSpace = [numDefault kRowspacing];
    //调节高度
    NSMutableAttributedString * attributedString ;
    if (label.attributedText){
        attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:label.attributedText];
    }else{
       attributedString = [[NSMutableAttributedString alloc] initWithString:label.text];
    }
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpace];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [label.text length])];
    [label setAttributedText:attributedString];
    label.lineBreakMode = NSLineBreakByTruncatingTail;

}

+ (BOOL)valiMobilePhone:(NSString *)mobile{
    if (IsEmptyStr(mobile) && mobile.length < 11)
    {
        return NO;
    }else{
        /**
         * 移动号段正则表达式
         */
        NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
        /**
         * 联通号段正则表达式
         */
        NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
        /**
         * 电信号段正则表达式
         */
        NSString *CT_NUM = @"^((133)|(153)|(177)|(173)|(18[0,1,9]))\\d{8}$";
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
        BOOL isMatch1 = [pred1 evaluateWithObject:mobile];
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
        BOOL isMatch2 = [pred2 evaluateWithObject:mobile];
        NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
        BOOL isMatch3 = [pred3 evaluateWithObject:mobile];
        
        if (isMatch1 || isMatch2 || isMatch3) {
            return YES;
        }else{
            return NO;
        }
    }

}
+(void)alertActionSheetWithTitle:(NSString*)title message:(NSString*)msg defaultTitles:(NSArray*)titles cancelTitle:(NSString*)cancel forDelegate:(id)controller defaultActionBlock:(void (^)(NSInteger index))titlesblock cancelBlock:(void(^)())cancelBlock{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: title.length>0?title:nil                                                                             message: msg.length>0?msg:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSInteger i = 0; i < titles.count; i++) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:titles[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            titlesblock(i);
            
        }];
        [alertController addAction:action];
    }
    [alertController addAction:[UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        cancelBlock();
    }]];
    
    [controller presentViewController:alertController animated:YES completion:nil];
}

+(void)alertActionSheetWithDefaultTitles:(NSArray*)titles cancelTitle:(NSString*)cancel forDelegate:(id)controller defaultActionBlock:(void (^)(NSInteger index))titlesblock cancelBlock:(void(^)())cancelBlock{
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil                                                                             message: nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSInteger i = 0; i < titles.count; i++) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:titles[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            titlesblock(i);
        }];
        [alertController addAction:action];
    }
    [alertController addAction:[UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        cancelBlock();
    }]];
    
    [controller presentViewController:alertController animated:YES completion:nil];
}


+(void)aletWithTitle:(NSString *)title Message:(NSString *)message  sureTitle:(NSString*)sureTitle CancelTitle:(NSString *)cancelTitle SureBlock:(void(^)())sure andCancelBlock:(void(^)()) cancel andDelegate:(id)controller{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (cancelTitle && cancelTitle.length > 0) {
        [alert addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (cancel) {
                cancel();
            }
        }]];
    }
    
   
    
    if (sureTitle && sureTitle.length> 0) {
        [alert addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (sure) {
                sure();
            }
        }]];
    }
    [controller presentViewController:alert animated:YES completion:nil];
    
}


+(NSAttributedString *)attributedStringCombinationFirstPart:(AttributeModel *)firstModel anotherPart:(AttributeModel *)secondModel{
    firstModel.text = firstModel.text.length > 0 ? firstModel.text : @"";
    secondModel.text = secondModel.text.length > 0 ? secondModel.text : @"";

    UILabel *lb = nil;
    lb.textColor = nil;
    NSInteger str1Num = [firstModel.text length];
    NSString * linkStr = [NSString stringWithFormat:@"%@%@",firstModel.text,secondModel.text];
    NSInteger strNum = [linkStr length];
    NSMutableAttributedString *linkedString = [[NSMutableAttributedString alloc] initWithString:linkStr];
    if (firstModel.textFont != nil) {
        [linkedString addAttribute:NSFontAttributeName value:firstModel.textFont range:NSMakeRange(0,str1Num)];
    }
    if (firstModel.textColor != nil) {
        [linkedString addAttribute:NSForegroundColorAttributeName value:firstModel.textColor range:NSMakeRange(0,str1Num)];
    }
//
    if (secondModel.textColor != nil) {
        [linkedString addAttribute:NSFontAttributeName value:secondModel.textFont range:NSMakeRange(str1Num,strNum-str1Num)];
    }
    if (secondModel.textFont != nil) {
        [linkedString addAttribute:NSForegroundColorAttributeName value:secondModel.textColor range:NSMakeRange(str1Num,strNum-str1Num)];
    }
    
//    return [PLGlobalClass attributedStringWithColorOneStr:firstModel.text andColorOne:firstModel.textColor andFontOne:firstModel.textFont andColorTwoStr:secondModel.text andColorTwo:secondModel.textColor andFontTwo:secondModel.textFont];
    
    return linkedString;
}

+(NSAttributedString *)attributedStringWithColorOneStr:(NSString *)oneStr andColorOne:(UIColor *)colorOne andFontOne:(UIFont*)fontOne andColorTwoStr:(NSString *)twoStr andColorTwo:(UIColor *)colorTwo andFontTwo:(UIFont*)fontTwo{
    NSMutableAttributedString *hintString=[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@",oneStr,twoStr]];
    NSRange range1=[[hintString string]rangeOfString:oneStr];
    [hintString addAttribute:NSForegroundColorAttributeName value:colorOne range:range1];
    [hintString addAttribute:NSFontAttributeName value:fontOne range:range1];
    //
    NSRange range2=[[hintString string]rangeOfString:twoStr];
    [hintString addAttribute:NSForegroundColorAttributeName value:colorTwo range:range2];
    [hintString addAttribute:NSFontAttributeName value:fontTwo range:range2];

    return hintString;
}



/**设置btn图片和文字的排列类型 **/
/**0-image在上 lable在下 1-image在左 lable在右**/
/**2-image在下 lable在上 3-image在右 lable在左**/
/**space 图片和文字间距 一般写2**/
+(void)setBtnStyle:(UIButton *)btn style:(ButtonEdgeInsetsStyleReferToImage)style space:(float)space
{
    CGFloat imageWith = btn.imageView.frame.size.width;
    CGFloat imageHeight = btn.imageView.frame.size.height;
    CGFloat labelWidth = 0.0;
    CGFloat labelHeight = 0.0;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        // 由于iOS8中titleLabel的size为0，用下面的这种设置
        labelWidth = btn.titleLabel.intrinsicContentSize.width;
        labelHeight = btn.titleLabel.intrinsicContentSize.height;
    } else {
        labelWidth = btn.titleLabel.frame.size.width;
        labelHeight = btn.titleLabel.frame.size.height;
    }
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets labelEdgeInsets = UIEdgeInsetsZero;
    
    switch (style) {
        case ButtonEdgeInsetsStyleImageTop:
            imageEdgeInsets = UIEdgeInsetsMake(-labelHeight-space, 0, 0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight-space, 0);
            break;
        case ButtonEdgeInsetsStyleImageLeft:
            if (btn.contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeft){
                imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
                labelEdgeInsets = UIEdgeInsetsMake(0, 2*space, 0, -2*space);
            }else{
                imageEdgeInsets = UIEdgeInsetsMake(0, -space, 0, space);
                labelEdgeInsets = UIEdgeInsetsMake(0, space, 0, -space);
            }
            break;
        case ButtonEdgeInsetsStyleImageBottom:
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight-space, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(-imageHeight-space, -imageWith, 0, 0);
            break;
        case ButtonEdgeInsetsStyleImageRight:
            if (btn.contentHorizontalAlignment == UIControlContentHorizontalAlignmentRight){
                imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth, 0, -labelWidth);
                labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith-2*space, 0, imageWith+2*space);
            }else{
                imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth+space, 0, -labelWidth-space);
                labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith-space, 0, imageWith+space);
            }
            break;
        default:
            break;
    }
    btn.titleEdgeInsets = labelEdgeInsets;
    btn.imageEdgeInsets = imageEdgeInsets;
}

//TODO:使用GCD方式实现倒计时功能
+ (dispatch_source_t)queryGCDWithTimeout:(NSInteger)Timeout
              handleChangeCountdownBlock:(HandleChangeCountdownBlock)handleChangeCountdownBlock
                handleStopCountdownBlock:(HandleStopCountdownBlock)handleStopCountdownBlock
{
    __block NSInteger timeout = Timeout-1;//倒计时时间
    dispatch_queue_t queue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_source_t _timer =dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0,0, queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL,0),1.0 * NSEC_PER_SEC,0);//每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout <=0){//倒计时结束，关闭
            //取消
            dispatch_source_cancel(_timer);
            //回到主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置界面的按钮显示根据自己需求设置
                if (handleStopCountdownBlock){
                    handleStopCountdownBlock(nil);
                }
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示根据自己需求设置
                //第一次不回调
                if (handleChangeCountdownBlock){
                    handleChangeCountdownBlock(timeout);
                }
            });
            timeout--;
        }
    });
    //启动
    dispatch_resume(_timer);
    return _timer;
}


//MARK: - -----------------数据存储-----------------

//TODO:将字典、数组、字符串、NSDate等七种可存储数据对象写入沙盒
+(void)writeToFile:(NSString *)plistName withKey:(NSString *)key value:(id )objcid;
{
    NSLock *theLock = [[NSLock alloc] init];
    [theLock lock];
    NSString *address = [NSString stringWithFormat:@"/%@.plist",plistName];
    NSString *ss= [NSHomeDirectory() stringByAppendingString:@"/Library/Preferences"];
    ss = [NSString stringWithFormat:@"%@%@",ss,address];
    NSMutableDictionary *logDic = [[NSMutableDictionary alloc]initWithContentsOfFile:ss];
    if (!logDic) {
        logDic = [NSMutableDictionary dictionary];
    }
    id newDict = [self changeType:objcid];
    [logDic setObject:newDict forKey:key];

    //将dvsToken存入本地推送日志在的 device token.plist里
    BOOL ifSucess = [logDic writeToFile:ss atomically:YES];
    NSLog(@"存储路径%@  key:%@ 存储是否成功：%d",plistName,key,ifSucess);
    [theLock unlock];
}

//TODO:从沙盒读取数据
+(id)getValueFromFile:(NSString *)plistName withKey:(NSString *)key;
{
    NSString *address = [NSString stringWithFormat:@"/%@.plist",plistName];
    NSString *ss= [NSHomeDirectory() stringByAppendingString:@"/Library/Preferences"];
    ss = [NSString stringWithFormat:@"%@%@",ss,address];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:ss];

    return [dic objectForKey:key];
}

//TODO:获取当前页面
+(UIViewController*) currentViewController {
    UIViewController* viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [PLGlobalClass findBestViewController:viewController];
}

//将NSDictionary中的Null类型的项目转化成@""
+(NSDictionary *)nullDic:(NSDictionary *)myDic
{
    NSArray *keyArr = [myDic allKeys];
    NSMutableDictionary *resDic = [[NSMutableDictionary alloc]init];
    for (int i = 0; i < keyArr.count; i ++)
    {
        id obj = [myDic objectForKey:keyArr[i]];
        
        obj = [self changeType:obj];
        
        [resDic setObject:obj forKey:keyArr[i]];
    }
    return resDic;
}

//将NSArray中的Null类型的项目转化成@""
+(NSArray *)nullArr:(NSArray *)myArr
{
    NSMutableArray *resArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < myArr.count; i ++)
    {
        id obj = myArr[i];
        
        obj = [self changeType:obj];
        
        [resArr addObject:obj];
    }
    return resArr;
}

//将NSString类型的原路返回
+(NSString *)stringToString:(NSString *)string
{
    return string;
}

//将Null类型的项目转化成@""
+(NSString *)nullToString
{
    return @"";
}

//主要方法
//类型识别:将所有的NSNull类型转化成@""
+(id)changeType:(id)myObj
{
    if ([myObj isKindOfClass:[NSDictionary class]])
    {
        return [self nullDic:myObj];
    }
    else if([myObj isKindOfClass:[NSArray class]])
    {
        return [self nullArr:myObj];
    }
    else if([myObj isKindOfClass:[NSString class]])
    {
        return [self stringToString:myObj];
    }
    else if([myObj isKindOfClass:[NSNull class]])
    {
        return [self nullToString];
    }
    else
    {
        return myObj;
    }
}



+(UIViewController*) findBestViewController:(UIViewController*)vc {
    
    if (vc.presentedViewController) {
        return [self findBestViewController:vc.presentedViewController];
        
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.topViewController];
        else
            return vc;
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.selectedViewController];
        else
            return vc;
    } else {
        return vc;
    }
}


//MARK: - -----------------日期时间 字符串-----------------
//TODO: NSDate 转时间戳
+(NSString*)timestampWithDate:(NSDate*)date{
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]*1000];//时间戳
    return timeSp;
}

//TODO: NSString 转NSDate
+(NSDate*)dateWithtimeStr:(NSString*)datestr;{
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *data = [dateFormat dateFromString:datestr];
    return data;
}

//TODO: NSDate 跟当前时间比
+(NSInteger)ComparenowdateWith:(NSDate *)date;
{
    NSDate *nowdate = [NSDate date];
    if(date.timeIntervalSinceReferenceDate < nowdate.timeIntervalSinceReferenceDate){
        return -1;
    }else if(date.timeIntervalSinceReferenceDate ==  nowdate.timeIntervalSinceReferenceDate){
        return 0;
    }else{
        return 1;
    }
}



+(void)setIQKeyboardToolBarEnable:(BOOL)enable DistanceFromTextField:(CGFloat)DistanceFromTextField;{
    IQKeyboardManager *iqManager = [IQKeyboardManager sharedManager];
    iqManager.enableAutoToolbar = enable;//工具栏
    if (DistanceFromTextField == 0){
        iqManager.keyboardDistanceFromTextField = 10 ;
    }else{
        iqManager.keyboardDistanceFromTextField = DistanceFromTextField;
    }
}

+(void)useIQKeyboard:(BOOL)use;{
    IQKeyboardManager *iqManager = [IQKeyboardManager sharedManager];
    iqManager.enable = use;
}


//TODO:textField字符串长度的限制及截取
///textField字符串长度的限制及截取
+(void)wordlimitWithtextField:(id)textField limitnum:(NSInteger)limitnum {
    
    if ([textField isKindOfClass:[UITextField class]]){
        UITextField *tf = (UITextField *)textField;
        NSInteger num = [tf.text length];
        if (num > limitnum){
            tf.text = [tf.text substringToIndex:limitnum];
        }
    }
    
    if([textField isKindOfClass:[UITextView class]]){
        UITextField *tfv = (UITextField *)textField;
        NSInteger num = [tfv.text length];
        if (num > limitnum){
            tfv.text = [tfv.text substringToIndex:limitnum];
        }
    }
    
}

//TODO:检查日期和今天的关系 -1今天以前 1今天以后 0今天
//+(int)compeartheDateWithToday:(NSDate *)thedate;
//{
//
//        NSDateComponents *currentcomponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
//        NSInteger currentDay= [currentcomponents day];
//
//        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:thedate];
//        NSInteger day= [components day];
//
//        if (day < currentDay) {
//            return -1;
//        }
//        if (day == currentDay) {
//            return 0;
//        }
//        return 1;
//
//}

//TODO:检查日期是不是今天
+(BOOL)ifToday:(NSDate *)thedate;{
    NSTimeInterval now= [[NSDate date] timeIntervalSince1970]*1;
    NSInteger today = now / (24*3600);
    
    NSTimeInterval theInter= [thedate timeIntervalSince1970]*1;
    NSInteger yestoday = theInter / (24*3600);
    
    NSInteger iDiff = today - yestoday;
    
    if(iDiff == 0) {
        return 1;
    }
    return 0;
}

//TODO:检查日期是不是今天
+(NSInteger)compareTodayWith:(NSDate *)thedate;{
    NSTimeInterval now= [[NSDate date] timeIntervalSince1970]*1;
    NSInteger today = now / (24*3600);
    
    NSTimeInterval theInter= [thedate timeIntervalSince1970]*1;
    NSInteger theday = theInter / (24*3600);
    
    NSInteger iDiff = today - theday;
    if(iDiff == 0) {
        return 0;
    }else if (iDiff > 0){
        return -1;
    }else{
        return 1;
    }
    
    
    //    //传入的时间
    //    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:thedate];
    //    NSInteger theDateYear  = [components1 year];
    //    NSInteger theDateMonth = [components1 month];
    //    NSInteger theDateDay   = [components1 day];
    //
    //
    //    //当前时间
    //    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    //    NSInteger currentDateYear  = [components2 year];
    //    NSInteger currentDateMonth = [components2 month];
    //    NSInteger currentDateDay   = [components2 day];
    //
    //
    //    if (theDateYear == currentDateYear && theDateDay == currentDateDay && theDateMonth == currentDateMonth){
    //        return 0;
    //    }
    //    if (theDateYear<currentDateYear){
    //        return -1;
    //    }
    //    if (theDateYear>currentDateYear){
    //        return 1;
    //    }
    //    if (theDateMonth<currentDateMonth){
    //        return -1;
    //    }
    //    if (theDateMonth>currentDateMonth){
    //        return 1;
    //    }
    //    if (theDateDay<currentDateDay){
    //        return -1;
    //    }
    //    if (theDateDay>currentDateDay){
    //        return 1;
    //    }
    //    return 0;
}

+(NSString *)dynamicFormatStringWithDate:(NSDate *)date{
    if ( [self compareTodayWith:date] == 0){
        //今天 时间格式化  1小时内显示几分钟前   1小时以上显示几小时前
        //        +(NSInteger)timesIntervalOne:(id)timeOne other:(id)timeOther{
        
        NSInteger second1 = [self timesIntervalOne:[NSDate date] other:date];
        if (second1 < 3600){
            if (second1 < 60){
                return [NSString stringWithFormat:@"1分钟前"];
            }
            return [NSString stringWithFormat:@"%ld分钟前",second1/60];
        }else{
            return [NSString stringWithFormat:@"%ld小时前",second1/3600];
        }
        NSLog(@"现在的时间-显示的时间 %ld",second1);
    }else{
        return [NSString timeStringWithDateMMdd:date];
    }
    return @"";
}

//TODO:聊天消息列表显示格式化  1天内 **:**  1天外 MM月dd日
+(NSString *)chatListFormatStringWithDate:(NSDate *)date;{
    if ( [self compareTodayWith:date] == 0){
        return [NSString timeStringWithDateHHmm:date];
    }else{
        return [NSString timeStringWithDateMMdd:date];
    }
    return @"";
}

+(NSInteger)timesIntervalOne:(id)timeOne other:(id)timeOther{
    NSDate *dateOne = nil;
    NSDate *dateOther = nil;
    NSInteger interval = -1;
    //
    if ([timeOne isKindOfClass:[NSDate class]]) {
        dateOne = (NSDate*)timeOne;
    }else if([timeOne isKindOfClass:[NSString class]] &&[NSString isPureNumandCharacters:(NSString*)timeOne]){
        dateOne = [NSDate dateWithTimeIntervalSince1970:[(NSString*)timeOne integerValue]];
    }
    //
    if ([timeOther isKindOfClass:[NSDate class]]) {
        dateOther = (NSDate*)timeOther;
    }else if([timeOther isKindOfClass:[NSString class]]&&[NSString isPureNumandCharacters:(NSString*)timeOne]){
        dateOther =[NSDate dateWithTimeIntervalSince1970:[(NSString*)timeOther integerValue]];
    }
    //
    if (dateOne != nil && dateOther != nil) {
        interval = (NSInteger)[dateOne timeIntervalSinceDate:dateOther];
    }
    
    return interval;
}

//TODO:计算年龄
+ (NSInteger)ageWithDateOfBirth:(NSDate *)date;
{
    // 出生日期转换 年月日
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    NSInteger brithDateYear  = [components1 year];
    NSInteger brithDateDay   = [components1 day];
    NSInteger brithDateMonth = [components1 month];
    
    // 获取系统当前 年月日
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    NSInteger currentDateYear  = [components2 year];
    NSInteger currentDateDay   = [components2 day];
    NSInteger currentDateMonth = [components2 month];
    
    // 计算年龄
    NSInteger iAge = currentDateYear - brithDateYear - 1;
    if ((currentDateMonth > brithDateMonth) || (currentDateMonth == brithDateMonth && currentDateDay >= brithDateDay)) {
        iAge++;
    }
    
    return iAge;
}

//MARK: - -----------------网络图片 图片-----------------
//TODO:SDWebImage下载图片
+(void)downloadImageWithurl:(NSString *)url callBack:(void(^)(UIImage *image))completion;
{
    NSString *imgUrl = [NSString formatImageUrlWith:url ifThumb:false thumb_W:80];
    
    [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:imgUrl] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        UIImage *eimage = [image normalizedImage];
        completion(eimage);
    }];
}

//TODO:颜色转图片
+ (UIImage *)imageWithColor:(UIColor *)color {
    //颜色转换为背景图片
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//TODO:绘制一定大小的 - 颜色转图片
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;{
    //准备绘制环境
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(context, 209.0/255, 169.0/255, 113.0/255, 1);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    
    //获取该绘图中的图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

//改变图片颜色
+ (UIImage *)changeimage:(UIImage *)image WithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextClipToMask(context, rect, image.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//TODO:获取图片的详细信息
+(void)getDetailInfo:(NSURL*)referenceURL{
    __block NSString* imageFileName;
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:referenceURL
                   resultBlock:^(ALAsset *myasset){
                       ALAssetRepresentation *representation = [myasset defaultRepresentation];
                       imageFileName = [representation filename];
                       NSLog(@"图片路径名：%@",imageFileName);
                       NSLog(@"图片UTI：%@",[representation UTI]);
                       NSLog(@"图片URL：%@",[representation url]);
                   }
                  failureBlock:nil];
}


//TODO:获取视频缩略图
+(UIImage *)getImage:(NSURL *)videoURL
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    
    CGImageRelease(image);
    
    return thumb;
    
}

//TODO:获取网络视频缩略图
/// 获取网络视频缩略图
+(UIImage *)gethttpVideoImage:(NSString *)videoURLStr;{
    
    NSURL * videoURL = [NSURL URLWithString:[NSString formatImageUrlWith:videoURLStr ifThumb:false thumb_W:80] ];
    
    MPMoviePlayerController *iosMPMovie = [[MPMoviePlayerController alloc]initWithContentURL:videoURL];
    iosMPMovie.shouldAutoplay = NO;
    UIImage *thumbnail = [iosMPMovie thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionNearestKeyFrame];
    
    return thumbnail;
}


//MARK: - -----------------相册拍照视频-----------------

//MARK:打开弹窗： - 选图片、拍照（全单选）
+(void)UploadphotosIfAllowsEditing:(BOOL)allowsEditing alsoShowVideo:(BOOL)showVideo{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"选择照片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //相机
    [alert addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openCameraIsAllowsEditing:allowsEditing videotape:NO];
    }]];
    
    //相册
    [alert addAction:[UIAlertAction actionWithTitle:@"从相册上传" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openAlbumIsAllowsEditing:allowsEditing alsoShowVideo:showVideo];
    }]];
    //取消
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    //推出视图控制器
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        [self currentViewController].modalPresentationStyle=UIModalPresentationOverCurrentContext;
    }
    [[self currentViewController] presentViewController:alert animated:YES completion:nil];
}

//MARK:打开弹窗： - 选图片、视频  图片多选
+(void)openAlbumMultiSelectionWithMaxNumber:(NSInteger)MaxNumber onlyPic:(BOOL)onlyPic blockHandler:(void (^)(NSArray*))picArray;{
    
    if (onlyPic){
        [self openAlbumWithMaxNumber:MaxNumber alsoShowVideo:false blockHandler:^(NSArray * assets) {
            picArray(assets);
        }];
    }else{
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"选择图片或视频" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        //相机
        [alert addAction:[UIAlertAction actionWithTitle:@"图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self openAlbumWithMaxNumber:MaxNumber alsoShowVideo:false blockHandler:^(NSArray * assets) {
                picArray(assets);
            }];
        }]];
        
        //视频
        [alert addAction:[UIAlertAction actionWithTitle:@"视频" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self openAlbumChooseVideo];
        }]];
        
        //取消
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        //推出视图控制器
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
            [self currentViewController].modalPresentationStyle=UIModalPresentationOverCurrentContext;
        }
        
        [[self currentViewController] presentViewController:alert animated:YES completion:nil];
    }
}

//MARK:打开弹窗： - 选图片、拍照  图片多选
+(void)openAlterWithMaxNumber:(NSInteger)MaxNumber blockHandler:(void (^)(NSArray*))picArray;{
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"选择图片或拍照" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    //相机
    [alert addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openCameraIsAllowsEditing:NO videotape:NO];
    }]];
    
    //相册
    [alert addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openAlbumWithMaxNumber:MaxNumber alsoShowVideo:false blockHandler:^(NSArray * assets) {
            picArray(assets);
        }];
    }]];
    
    //取消
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    //推出视图控制器
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        [self currentViewController].modalPresentationStyle=UIModalPresentationOverCurrentContext;
    }
    
    [[self currentViewController] presentViewController:alert animated:YES completion:nil];
}


//TODO:打开相机拍一张图片 参数allowsEditing,YES时切成正方形 NO时不处理图片 参数withVideo,YES时可以摄像 NO时只能拍照
//选出的图片切割成方形PrincessCut
+(void)openCameraIsAllowsEditing:(BOOL)allowsEditing videotape:(BOOL)withVideo;{
    //判断有无相机设备
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        __block UIImagePickerController * picker = [[UIImagePickerController alloc]init];
        
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];//读取设备授权状态
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
            
            [PLGlobalClass aletWithTitle:@"未获得授权使用摄像头" Message:@"请在 设置-隐私-相机中打开" sureTitle:@"知道了" CancelTitle:nil SureBlock:^{
                [picker removeFromParentViewController];
            } andCancelBlock:^{
            } andDelegate:[self currentViewController]];
            return;
        }
        //访问相机
        //访问相机
        //实例化
        
        //设置图片来源，相机或者相册
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;

        if(withVideo){
            picker.mediaTypes = @[(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie];
            picker.videoQuality = UIImagePickerControllerQualityType640x480;
            picker.videoMaximumDuration = 10;
        }
        //设置后续是否可编辑
        picker.allowsEditing = allowsEditing;
        //设置代理
        
        
        
        
        picker.delegate = [self currentViewController];
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
            [self currentViewController].modalPresentationStyle=UIModalPresentationOverCurrentContext;
        }
        [[self currentViewController] presentViewController:picker animated:YES completion:nil];
    }else{
        [WFHudView  showMsg:@"未开启相机" inView:[self currentViewController].view];
    }
}

//TODO:打开相册选一张图片 参数allowsEditing,YES时切成正方形 NO时不处理图片
+(void)openAlbumIsAllowsEditing:(BOOL)allowsEditing alsoShowVideo:(BOOL)showVideo;{
    
    __block UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied){
        //无权限
        [PLGlobalClass aletWithTitle:@"未获得访问相册授权" Message:@"请在 设置-同宗汇-照片中打开" sureTitle:@"知道了" CancelTitle:nil SureBlock:^{
            [picker removeFromParentViewController];
        } andCancelBlock:^{
        } andDelegate:[self currentViewController]];
        return;
    }
    //访问相册
    //访问相机
    //实例化
    
    //设置图片来源，相机或者相册
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;//图片分组列表
//    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//collectionView
    if (showVideo){
        picker.mediaTypes = @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage];
    }
    
    //picker.mediaTypes = @[MPMediaTypeAny];
    //设置后续是否可编辑
    picker.allowsEditing = allowsEditing;
    //设置代理
    picker.delegate = [self currentViewController];
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        [self currentViewController].modalPresentationStyle=UIModalPresentationOverCurrentContext;
    }
    [[self currentViewController] presentViewController:picker animated:YES completion:nil];
}


//TODO:打开相册选一个视频
+(void)openAlbumChooseVideo{
    
    __block UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied){
        //无权限
        [PLGlobalClass aletWithTitle:@"未获得访问相册授权" Message:@"请在 设置-同宗汇-照片中打开" sureTitle:@"知道了" CancelTitle:nil SureBlock:^{
            [picker removeFromParentViewController];
        } andCancelBlock:^{
        } andDelegate:[self currentViewController]];
        return;
    }
    //访问相册
    //访问相机
    //实例化
    
    //设置图片来源，相机或者相册
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;//图片分组列表
    picker.mediaTypes = @[(NSString *)kUTTypeMovie];
    //设置代理
    picker.delegate = [self currentViewController];
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        [self currentViewController].modalPresentationStyle=UIModalPresentationOverCurrentContext;
    }
    [[self currentViewController] presentViewController:picker animated:YES completion:nil];
}









//TODO:打开相册选多张图片 只能选图片 - ZLPhotoPickerViewController - 代码拷贝自掌方圆“发布活动”
/// 打开相册选一张图片
+(void)openAlbumWithMaxNumber:(NSInteger)MaxNumber alsoShowVideo:(BOOL)showVideo blockHandler:(void (^)(NSArray*))picArray;
{
    UIViewController *vc = [self currentViewController];
    [vc.view endEditing:YES];
    ZLPhotoPickerViewController * pickerVc = [[ZLPhotoPickerViewController alloc]init];
    pickerVc.maxCount = MaxNumber;
    pickerVc.status = PickerViewShowStatusSavePhotos;
    
    if (showVideo == true){
        pickerVc.photoStatus = PickerPhotoStatusAllVideoAndPhotos;
    }else{
        pickerVc.photoStatus = PickerPhotoStatusPhotos;
    }
    pickerVc.topShowPhotoPicker = false;
    pickerVc.isShowCamera = false;
    pickerVc.callBack = ^(NSArray<ZLPhotoAssets *> *assets) {
        picArray(assets);
    };
    [pickerVc showPickerVc:vc];
}


//TODO:发布视频时，点击播放相册视频的自定义UI的播放器（XLVideoPlayer）
/// 播放器显示播放时间 和删除按钮 点击播放器销毁播放器
+(void)theSinglePlayercallBack:(void(^)(id  deleBtn,XLVideoPlayer * player,UILabel *lab))completion;{
    XLVideoPlayer * player = [[XLVideoPlayer alloc]init];
    player.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
    player.completedPlayingBlock = ^(XLVideoPlayer *videoPlayer) {
    };
    [player.slider removeFromSuperview];
    [player.playOrPauseBtn removeFromSuperview];
    [player.zoomScreenBtn removeFromSuperview];
    [player.progressLabel removeFromSuperview];
    [player removeGestureRecognizer:player.tap];
    
    __block XLVideoPlayer *play = player;
    player.tap = [[UITapGestureRecognizer alloc]bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        [play destroyPlayer];
    }];
    [player addGestureRecognizer:player.tap];
    
    
    KNaviBarBtnItem * deleBtn = [[KNaviBarBtnItem alloc] initWithFrame:CGRectMake(KScreenWidth-60, KStatusBarHeight, 44, 44) image:@"deleteBig" hander:^(id _Nonnull sender) {

   }];
    UIImage *thumb = [UIImage imageNamed:@"deleteBig"];
    thumb =[thumb imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [deleBtn.button setImage:thumb forState:(UIControlStateNormal)];
    
    UILabel * lab = [[UILabel alloc] initWithFrame:(CGRectMake(0, deleBtn.top_sd, KScreenWidth, deleBtn.height_sd))];
    lab.font = [UIFont systemFontOfSize:24];
    lab.textColor = [UIColor whiteColor];
    lab.backgroundColor = [UIColor clearColor];
    lab.textAlignment = NSTextAlignmentCenter;

    if (completion){
        completion(deleBtn,player,lab);
    }
}

//TODO:压缩视频
+ (void)compressionVideoWithInputURL:(NSURL*)inputURL blockHandler:(void (^)(AVAssetExportSession*))handler;{
    
    NSLog(@"压缩前大小 %f MB",[self fileSize:inputURL]);
    // 创建AVAsset对象
    AVAsset* asset = [AVAsset assetWithURL:inputURL];
    /*
     创建AVAssetExportSession对象
     压缩的质量
     AVAssetExportPresetLowQuality 最low的画质最好不要选择实在是看不清楚
     AVAssetExportPresetMediumQuality 使用到压缩的话都说用这个
     AVAssetExportPresetHighestQuality 最清晰的画质
     */
    AVAssetExportSession * session = [[AVAssetExportSession alloc]
                                      initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    //优化网络
    session.shouldOptimizeForNetworkUse = YES;
    //转换后的格式
    //拼接输出文件路径 为了防止同名 可以根据日期拼接名字 或者对名字进行MD5加密
    NSString* path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
                      stringByAppendingPathComponent:@"hello.mp4"];
    //判断文件是否存在，如果已经存在删除
    [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
    //设置输出路径
    session.outputURL = [NSURL fileURLWithPath:path];
    //设置输出类型 这里可以更改输出的类型 具体可以看文档描述
    session.outputFileType = AVFileTypeMPEG4;
    [session exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"%@",[NSThread currentThread]);
        //压缩完成
        if(session.status==AVAssetExportSessionStatusCompleted) {
            //在主线程中刷新UI界面，弹出控制器通知用户压缩完成
            dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"导出完成");
            NSURL * CompressURL = session.outputURL;
            NSLog(@"压缩完毕,压缩后大小 %f MB",[self fileSize:CompressURL]);
            handler(session);
        });
    }
     }];
}

//TODO:获取本地文件大小
+ (CGFloat)fileSize:(NSURL *)path
{
    return [[NSData dataWithContentsOfURL:path] length]/1024.00 /1024.00;
}


//TODO:给View加任意条边框线
+ (void)setBorderWithView:(UIView *)view top:(BOOL)top left:(BOOL)left bottom:(BOOL)bottom right:(BOOL)right borderColor:(UIColor *)color borderWidth:(CGFloat)width
{
    if (top) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (left) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (bottom) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, view.frame.size.height - width, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (right) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(view.frame.size.width - width, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
}


/**压缩图片,可以传图片的nsdata，或者Uiimage */
+ (NSData *)compressImage:(id)img toByte:(NSUInteger)maxLength{
    // Compress by quality
    CGFloat compression = 1;
    NSData *data = nil;
    if ([img isKindOfClass:[NSData class]]) {
        data = img;
    }else if ([img isKindOfClass:[UIImage class]]){
        data = UIImageJPEGRepresentation(img, compression);
    }
    if (data.length < maxLength) return data;
    
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    UIImage *resultImage = [UIImage imageWithData:data];
    if (data.length < maxLength) return data;
    
    // Compress by size
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, compression);
    }
    return data;
}

/////压缩图片
//+ (NSData *)imageCompressToData:(UIImage *)image{
//    NSData *data=UIImageJPEGRepresentation(image, 1.0);
//    if (data.length>300*1024) {
//        if (data.length>1024*1024) {//1M以及以上
//            data=UIImageJPEGRepresentation(image, 0.1);
//        }else if (data.length>512*1024) {//0.5M-1M
//            data=UIImageJPEGRepresentation(image, 0.5);
//        }else if (data.length>300*1024) {//0.25M-0.5M
//            data=UIImageJPEGRepresentation(image, 0.9);
//        }
//    }
//    UIImage *resultImage = [UIImage imageWithData:data];
//    return data;
//}


//TODO:压缩图片到一定大小
+ (NSData *)compressImageQuality:(UIImage *)image{
    //先修正图片方向再压缩
    UIImage * image2 = [image normalizedImage];
    NSData *data=UIImageJPEGRepresentation(image2, 1.0);

    if (image.size.width > 500){
        CGSize size = CGSizeMake(500, image.size.height * 500 / image.size.width);
    
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        image2 = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(image2, 1.0);
    }

    
    if (data.length>80*1024) {
        if (data.length>1024*1024) {//1M以及以上
            data=UIImageJPEGRepresentation(image2, 0.05);
        }else if (data.length>512*1024) {//0.5M-1M
            data=UIImageJPEGRepresentation(image2, 0.2);
        }else if (data.length>300*1024) {//0.25M-0.5M
            data=UIImageJPEGRepresentation(image2, 0.5);
        }else{
            data=UIImageJPEGRepresentation(image2, 0.6);
        }
    }
    
    NSLog(@"图片压缩后大小 ： %d k",data.length/1024);
    
    return data;
}


//TODO:宽一定 按比例求网络图片的高度
+(void)getImageHeightWithWidth:(CGFloat)width url:(NSString *)url img:(UIImage *)img callBack:(void(^)(CGFloat hei , UIImage *image))completion;
{
    if (img == nil){
        NSString *imgUrl = [NSString formatImageUrlWith:url ifThumb:false thumb_W:80];
//        SDWebImageProgressiveDownload
        [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:imgUrl] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            CGSize size=image.size;
            if (size.width != 0){
                completion(width/size.width*size.height,image);
            }else{
                completion(size.height,image);
            }
        }];
    }else{
        
        completion( [self getImageHeightWithWidth:width img:img] , img);
    }
}

//TODO:宽一定 按比例求图片的高度
+(CGFloat)getImageHeightWithWidth:(CGFloat)width img:(UIImage *)img;{
    CGSize size = img.size;
    
    if (size.width != 0){
        return  width/size.width*size.height;
    }else{
        return  size.height;
    }
}





//TODO:点击图片放大查看
///点击图片放大查看
+(void)imgTapClicked:(NSInteger )index imageArr:(NSArray *)imageArr {
    
    NSMutableArray *photos = [[NSMutableArray alloc]initWithCapacity:0];
    
    for (int i=0; i<imageArr.count; i++) {
        [photos addObject:[NSString formatImageUrlWith:imageArr[i] ifThumb:false thumb_W:80]];
    }
    
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:(UIStatusBarAnimationFade)];
    UIView *maskView = [[UIView alloc]initWithFrame:(CGRectMake(0, 0, KScreenWidth, KScreenHeight))];
    maskView.backgroundColor = [UIColor blackColor];
    [APPDELEGATE.window addSubview:maskView];
    
    YMShowImageView *ymImgView = [[YMShowImageView alloc]initWithFrame:UIScreen.mainScreen.bounds byClick:index appendArray:photos ImageType:CarCirclImageType];
    
    [ymImgView show:maskView didFinish:^{
        [UIView animateWithDuration:0.3 animations:^{
            ymImgView.alpha = 0;
            maskView.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished){
                [ymImgView removeFromSuperview];
                [maskView removeFromSuperview];
            }
        }];
        [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:(UIStatusBarAnimationFade)];
    }];
}





//TODO:求lable的高度
+(CGFloat)getTextHeightWithStr:(NSString *)str labWidth:(CGFloat)labwidth fontSize:(CGFloat)fontsize numberLines:(NSInteger)numlines lineSpacing:(CGFloat)linespacing{

    if ([str length]>0){
        linespacing = [numDefault kRowspacing];
        CGSize size = [PLGlobalClass sizeForParagraphWithText:str weight:labwidth fontSize:fontsize lineSpacing:linespacing numberline:numlines];
        return size.height;
    }
    return 0;
}



/**
 *  验证身份证号码是否正确的方法
 *
 *  @param IDNumber 传进身份证号码字符串
 *
 *  @return 返回YES或NO表示该身份证号码是否符合国家标准
 */
+ (BOOL)validateIdentityCard:(NSString *)IDNumber
{
    
    if ([NSString trimString:IDNumber].length != 18) {
        return NO;
    }
    
    NSMutableArray *IDArray = [NSMutableArray array];
    // 遍历身份证字符串,存入数组中
    for (int i = 0; i < 18; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [IDNumber substringWithRange:range];
        [IDArray addObject:subString];
    }
    // 系数数组
    NSArray *coefficientArray = [NSArray arrayWithObjects:@"7", @"9", @"10", @"5", @"8", @"4", @"2", @"1", @"6", @"3", @"7", @"9", @"10", @"5", @"8", @"4", @"2", nil];
    // 余数数组
    NSArray *remainderArray = [NSArray arrayWithObjects:@"1", @"0", @"X", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2", nil];
    // 每一位身份证号码和对应系数相乘之后相加所得的和
    int sum = 0;
    for (int i = 0; i < 17; i++) {
        int coefficient = [coefficientArray[i] intValue];
        int ID = [IDArray[i] intValue];
        sum += coefficient * ID;
    }
    // 这个和除以11的余数对应的数
    NSString *str = remainderArray[(sum % 11)];
    // 身份证号码最后一位
    NSString *string = [IDNumber substringFromIndex:17];
    // 如果这个数字和身份证最后一位相同,则符合国家标准,返回YES
    if ([str isEqualToString:string]) {
        return YES;
    } else {
        return NO;
    }
}



@end


@implementation AttributeModel



@end
