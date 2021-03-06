//
//  PLGlobalClass.h
//  PlamLive
//
//  Created by wangyadong on 2016/10/31.
//  Copyright © 2016年 wangyadong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "XLVideoPlayer.h"


@class AttributeModel;
@interface PLGlobalClass : NSObject



typedef NS_OPTIONS(NSUInteger, ButtonEdgeInsetsStyleReferToImage) {
    ButtonEdgeInsetsStyleImageTop    = 0,// image在上，label在下
    ButtonEdgeInsetsStyleImageLeft  = 1,// image在左，label在右
    ButtonEdgeInsetsStyleImageBottom = 2,// image在下，label在上
    ButtonEdgeInsetsStyleImageRight  = 3,// image在右，label在左
};

typedef enum : NSUInteger {
    ShareThirdTypeWechat,
    ShareThirdTypeWechatCircle,
    ShareThirdTypeQQ,
    ShareThirdTypeQQZone,
} ShareThirdType;




/**
 计算文字所占label的大小
 */
+(CGSize)sizeWithText:(NSString*)text font:(UIFont*)fonnt width:(CGFloat)width height:(CGFloat)height;
/**
 *  给label的文本显示增加行间距
 *
 *  @param label      文本显示的label
 *  @param textString 显示的文本内容
 *  @param font       文本字体
 *  @param lineSpace  行间距
 *  @param width      文本显示给定的宽
 *
 *  @return 文本显示的size
 */
+(CGSize)sizeAttributeTextWithLineSpaceForLabel:(UILabel*)label textString:(NSString*)textString textFont:(UIFont*)font lineSpaceing:(CGFloat)lineSpace labelWidth:(CGFloat)width;

//设置行距的label

/**
 对一个label添加的行间距之后需要显示的label的size大小
和下面的paragraphForlabel 方法成对出现
 @param text 文字
 @param weight 固定宽
 @param fonts  字体大小
 @param lineSpace 行间距大小

 @return label的大小
 */
+(CGSize)sizeForParagraphWithText:(NSString*)text weight:(CGFloat)weight fontSize:(CGFloat)fonts lineSpacing:(CGFloat)lineSpace  numberline:(NSInteger)numberline;
//label，行间距

//TODO:对label设置行间距
/**
 对label设置行间距
和上面的sizeForParagraphWithText成对使用
 @param label     显示文本的label
 @param lineSpace 行家就
 */
+(void)paragraphForlabel:(UILabel*)label lineSpace:(CGFloat)lineSpace;



/**
 *  判断是否是手机号
 */
+ (BOOL)valiMobilePhone:(NSString *)mobile;


/**
 *  验证身份证号码是否正确的方法
 *
 *  @param IDNumber 传进身份证号码字符串
 *
 *  @return 返回YES或NO表示该身份证号码是否符合国家标准
 */
+ (BOOL)validateIdentityCard:(NSString *)IDNumber;

/**
 actionSheet
 
 @param titles      标题数组
 @param cancel      底部“取消”
 @param controller  显示VC
 @param titlesblock 回调index
 @param cancelBlock 取消回调
 */
+(void)alertActionSheetWithDefaultTitles:(NSArray*)titles cancelTitle:(NSString*)cancel forDelegate:(id)controller defaultActionBlock:(void (^)(NSInteger index))titlesblock cancelBlock:(void(^)())cancelBlock;
+(void)alertActionSheetWithTitle:(NSString*)title message:(NSString*)msg defaultTitles:(NSArray*)titles cancelTitle:(NSString*)cancel forDelegate:(id)controller defaultActionBlock:(void (^)(NSInteger index))titlesblock cancelBlock:(void(^)())cancelBlock;


/**
 便捷提示
 
 @param title <#title description#>
 @param message <#message description#>
 @param sureTitle <#sureTitle description#>
 @param cancelTitle <#cancelTitle description#>
 @param sure <#sure description#>
 @param cancel <#cancel description#>
 @param controller <#controller description#>
 */
+(void)aletWithTitle:(NSString *_Nullable)title Message:(NSString *_Nullable)message  sureTitle:(NSString*_Nullable)sureTitle CancelTitle:(NSString *_Nullable)cancelTitle SureBlock:(void(^_Nonnull)(void))sure andCancelBlock:(void(^_Nonnull)(void)) cancel andDelegate:(id _Nonnull )controller;




/**
 两个时间戳字符串，或NSDate之间的时间间隔
 
 @param timeOne   时间戳string，或者NSDate
 @param timeOther <#timeOther description#>
 
 @return 如果两个时间戳不合规格或者传nil会返回-1
 */
+(NSInteger)timesIntervalOne:(id)timeOne other:(id)timeOther;
/**字符串 带颜色 */

+(NSAttributedString*)attributedStringCombinationFirstPart:(AttributeModel*)firstModel anotherPart:(AttributeModel*)secondModel;





//TODO:使用GCD方式实现倒计时功能
typedef void(^HandleStopCountdownBlock)(NSInteger stopTime);
typedef void(^HandleChangeCountdownBlock)(NSInteger changeTime);
/**NSInteger
 *  GCD定时器（倒计时）
 *  param   Timeout                         倒计时开始时间
 *  param   handleChangeCountdownBlock      倒计时时间改变回调
 *  param   handleStopCountdownBlock        倒计时时间停止回调
 */
+ (dispatch_source_t _Nullable )queryGCDWithTimeout:(NSInteger)Timeout
                         handleChangeCountdownBlock:(HandleChangeCountdownBlock _Nullable )handleChangeCountdownBlock
                           handleStopCountdownBlock:(HandleStopCountdownBlock _Nullable )handleStopCountdownBlock;


//MARK: - -----------------IQKeyboard(swift里掉不到 所以写在这儿)-----------------

+(void)setIQKeyboardToolBarEnable:(BOOL)enable DistanceFromTextField:(CGFloat)DistanceFromTextField;
+(void)useIQKeyboard:(BOOL)use;



//MARK: - -----------------数据存储-----------------

//TODO:将字典、数组、字符串、NSDate等七种可存储数据对象写入沙盒
/**
 将字典、数组、字符串、NSDate等七种可存储数据对象写入沙盒
 
 @param objcid 要存储的数据对象
 @param plistName 要存储到的plist文件名称
 */
+(void)writeToFile:(NSString *)plistName withKey:(NSString *)key value:(id )objcid;

+(id)getValueFromFile:(NSString *)plistName withKey:(NSString *)key;

//TODO:获取当前的VC
+(UIViewController*) currentViewController;




//MARK: - -----------------日期时间 字符串-----------------
//TODO: NSDate 转时间戳
+(NSString*)timestampWithDate:(NSDate*)date;
//TODO: NSString 转NSDate
+(NSDate*)dateWithtimeStr:(NSString*)datestr;
//TODO: NSDate 跟当前时间比
+(NSInteger)ComparenowdateWith:(NSDate *)date;

//TODO:textField/textView字符串长度的限制及截取
///textField/textView字符串长度的限制及截取
+(void)wordlimitWithtextField:(id)textField limitnum:(NSInteger)limitnum;

//TODO:检查日期是不是今天
+(BOOL)ifToday:(NSDate *)thedate;

//TODO:日期跟今天比较 0 今天  -1今天以前  1今天以后
+(NSInteger)compareTodayWith:(NSDate *)thedate;


//TODO:两个时间戳字符串，或NSDate之间的时间间隔
/**
 两个时间戳字符串，或NSDate之间的时间间隔
 @return 如果两个时间戳不合规格或者传nil会返回-1
 */
+(NSInteger)timesIntervalOne:(id)timeOne other:(id)timeOther;

//TODO:动态日期显示格式化 1小时内 **分钟前 1天内 **小时前  1天外 MM-dd
+(NSString *)dynamicFormatStringWithDate:(NSDate *)date;

//TODO:聊天消息列表显示格式化  1天内 **:**  1天外 MM月dd日
+(NSString *)chatListFormatStringWithDate:(NSDate *)date;

//TODO:计算年龄
+ (NSInteger)ageWithDateOfBirth:(NSDate *)date;





//MARK: - -----------------网络图片 图片-----------------
//TODO:SDWebImage下载图片
+(void)downloadImageWithurl:(NSString *)url callBack:(void(^)(UIImage *image))completion;

//TODO:颜色转图片
+ (UIImage *)imageWithColor:(UIColor *)color;

//TODO:绘制一定大小的 - 颜色转图片
/// 绘制一定大小的 - 颜色转图片
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *) imageWithView:(UIView *)view;
//TODO:改变图片颜色
/// 改变图片颜色
+ (UIImage *)changeimage:(UIImage *)image WithColor:(UIColor *)color;

//TODO:获取图片的详细信息
/// 获取图片名字、唯一标示UTI、路径url
+(void)getDetailInfo:(NSURL*)referenceURL;

//TODO:获取视频缩略图
/// 获取视频缩略图
+(UIImage *)getImage:(NSURL *)videoURL;

//TODO:获取网络视频缩略图
/// 获取网络视频缩略图
+(UIImage *)gethttpVideoImage:(NSString *)videoURLStr;


/**压缩图片,可以传图片的nsdata，或者Uiimage */
+ (NSData *)compressImage:(id)img toByte:(NSUInteger)maxLength;

//TODO:压缩图片到一定大小
+ (NSData *)compressImageQuality:(UIImage *)image;

//TODO:宽一定 按比例求网络图片的高度
+(void)getImageHeightWithWidth:(CGFloat)width url:(NSString *)url img:(UIImage *)img callBack:(void(^)(CGFloat hei , UIImage *image))completion;

//TODO:宽一定 按比例求图片的高度
+(CGFloat)getImageHeightWithWidth:(CGFloat)width img:(UIImage *)img;




//MARK: - -----------------相册拍照视频-----------------

//TODO:点击图片放大查看
///点击图片放大查看
+(void)imgTapClicked:(NSInteger )index imageArr:(NSArray *)imageArr;

//MARK:打开弹窗： - 选图片、拍照（全单选）
+(void)UploadphotosIfAllowsEditing:(BOOL)allowsEditing alsoShowVideo:(BOOL)showVideo;

//MARK:打开弹窗： - 选图片、视频
+(void)openAlbumMultiSelectionWithMaxNumber:(NSInteger)MaxNumber onlyPic:(BOOL)onlyPic blockHandler:(void (^)(NSArray*))picArray;

//MARK:打开弹窗： - 选图片、拍照
+(void)openAlterWithMaxNumber:(NSInteger)MaxNumber blockHandler:(void (^)(NSArray*))picArray;


//TODO:打开相册选一个视频
+(void)openAlbumChooseVideo;

//TODO:打开相机拍一张图片 参数allowsEditing,YES时切成正方形 NO时不处理图片
/// 打开相机拍一张图片 参数allowsEditing,YES时切成正方形 NO时不处理图片
+(void)openCameraIsAllowsEditing:(BOOL)allowsEditing videotape:(BOOL)withVideo;;

//TODO:打开相册选一张图片 参数allowsEditing,YES时切成正方形 NO时不处理图片
/// 打开相册选一张图片 参数allowsEditing,YES时切成正方形 NO时不处理图片 获取选择的图片需要实现代理方法<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
+(void)openAlbumIsAllowsEditing:(BOOL)allowsEditing alsoShowVideo:(BOOL)showVideo;




//TODO:打开相册选多张图片  - ZLPhotoPickerViewController
/// 打开相册选一张图片
+(void)openAlbumWithMaxNumber:(NSInteger)MaxNumber alsoShowVideo:(BOOL)showVideo blockHandler:(void (^)(NSArray*))picArray;




//MARK: - -----------------视频播放-----------------
//TODO:发布视频时，点击播放相册视频的自定义UI的播放器（XLVideoPlayer）
/// 播放器显示播放时间 和删除按钮 点击播放器销毁播放器
+(void)theSinglePlayercallBack:(void(^)(id  deleBtn,XLVideoPlayer * player,UILabel *lab))completion;

//TODO:压缩视频
+ (void)compressionVideoWithInputURL:(NSURL*)inputURL blockHandler:(void (^)(AVAssetExportSession*))handler;;





//MARK: - -----------------view lable button-----------------

//TODO:求lable的高度
/// 求lable的高度
+(CGFloat)getTextHeightWithStr:(NSString *)str labWidth:(CGFloat)labwidth fontSize:(CGFloat)fontsize numberLines:(NSInteger)numlines lineSpacing:(CGFloat)linespacing;

//TODO:给View加任意条边框线
/// 给View加任意条边框线

+ (void)setBorderWithView:(UIView *)view top:(BOOL)top left:(BOOL)left bottom:(BOOL)bottom right:(BOOL)right borderColor:(UIColor *)color borderWidth:(CGFloat)width;

//TODO:设置btn图片和文字的排列类型
/// 设置btn图片和文字的排列类型
/**0-image在上 lable在下 1-image在左 lable在右**/
/**2-image在下 lable在上 3-image在右 lable在左**/
/**space 图片和文字间距 一般写2**/
+(void)setBtnStyle:(UIButton *_Nonnull)btn style:(ButtonEdgeInsetsStyleReferToImage)style space:(float)space;

@end





@interface AttributeModel : NSObject

@property(nonatomic,copy)NSString * text;
@property(nonatomic,strong)UIFont * textFont;
@property(nonatomic,strong)UIColor * textColor;
@end




