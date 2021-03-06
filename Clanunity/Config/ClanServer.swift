//
//  ClanServer.swift
//  Clanunity
//
//  Created by wangyadong on 2018/1/30.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//


//MARK:这个方法作为工具方法使用

import UIKit

//MARK: - token保存和读取
class ClanServer: NSObject {

    /// 获取token,如果登录了有toke，没有就是0
    class var token : String{
        let user = UserDefaults.standard
        let token = user.value(forKey: "Clanunity-login-Token")
        
        if token != nil && token is String && (token as! String).count > 0{
            return token as! String
        }
        return "0"
    }
    
    /// 保存token
    ///
    /// - Parameter value: token
    class func savetoken(value:String) -> Void{
        let user = UserDefaults.standard
        user.set(value, forKey: "Clanunity-login-Token")
        user.synchronize()
    }
    
    class func clearToken() ->Void {
        let user = UserDefaults.standard
        user.set(nil, forKey: "Clanunity-login-Token")
        user.synchronize()
    }
    
}

typealias LoginResult = (((_ status:Int) -> Void)?)

class LoginServer: NSObject {
    
    static let share : LoginServer = {
        let service = LoginServer.init();
        return service;
    }()
    private var loginResult : LoginResult?
    
    /// 是否登录：通过token判断，yes登录，no没有登录
    var islogin : Bool{
        if ClanServer.token == "0"{
            return false
        }else{
           return true;
        }
    }
    
    func loginFinish(status:Int) -> Void {
        NotificationCenter.default.post(Notification.init(name: Notification.Name.init(rawValue: CUKey.kNotifiCompleteUserinfo), object: nil, userInfo: nil));
        APPDELEGATE.loginIM()
        if self.loginResult != nil {
            self.loginResult!!(status)
        }
        self.loginResult = nil;
    }
    func showLoginCompleteInfo(block:((_ status:Int) -> Void)?) -> Void{
        
        if self.loginResult == nil{
            self.loginResult = block
        }
        if APPDELEGATE.window.rootViewController == nil {
            print("root == nil");
            let logVC = ClanLoginManagerVC.init()
            logVC.currentIndex = LoginPage.Club;
            let loginNav = KNavigationController.init(rootViewController: logVC)
            APPDELEGATE.window.rootViewController = loginNav;
        }else{

            if PLGlobalClass.currentViewController() is ClanLoginManagerVC{
                return;
            }
            let logVC = ClanLoginManagerVC.init()
            logVC.currentIndex = LoginPage.Club;
            let loginNav = KNavigationController.init(rootViewController: logVC)
            
            APPDELEGATE.window.rootViewController?.present(loginNav, animated: true, completion: {
            })
//            PLGlobalClass.currentViewController().present(loginNav, animated: true, completion: {
//            })
        }
    }
    
    
    func showLoginVC(block:((_ status:Int) -> Void)?) -> Void{
        
        if self.loginResult == nil{
            self.loginResult = block
        }
        if APPDELEGATE.window.rootViewController == nil {
            print("root == nil");
            let logVC = ClanLoginManagerVC.init()
            logVC.currentIndex = LoginPage.Login;
            let loginNav = KNavigationController.init(rootViewController: logVC)
            APPDELEGATE.window.rootViewController = loginNav;
        }else{
            
            if PLGlobalClass.currentViewController() is ClanLoginManagerVC{
                return;
            }
            let logVC = ClanLoginManagerVC.init()
            logVC.currentIndex = LoginPage.Login;
            let loginNav = KNavigationController.init(rootViewController: logVC)
            
            APPDELEGATE.window.rootViewController?.present(loginNav, animated: true, completion: {
//            PLGlobalClass.currentViewController().present(loginNav, animated: true, completion: {
            })
           
        }
    }
    
    
}

//MARK: - 用户信息存储和读取
class UserServre: NSObject {
    
    var userModel : UserModel! = UserModel.init()
    var userClub : ClubModel?
    
    static let shareService : UserServre = {
        let service = UserServre.init();
        return service;
    }()
    
    /// 更新数据
    func cacheSaveRefresh() -> Void {
        
        let jsonStr = self.userModel.mj_JSONString()
        //更新缓存
        if jsonStr != nil {
            KFileManager.cacheDefineFile(with: jsonStr!, fileName: "K_User_Data")
        }else{
            //清空缓存
            KFileManager.deleteDefineCache(withName: "K_User_Data")
        }
        //更新姓氏缓存
        if self.userClub != nil && (self.userClub?.mj_JSONString()) != nil {
             KFileManager.cacheDefineFile(with: (self.userClub!.mj_JSONString())!, fileName: "K_User_Club")
        }else{
            //清空缓存
            KFileManager.deleteDefineCache(withName: "K_User_Club")
        }
        
    }
    
    /// 清空数据
    func cacheClear() -> Void {
        KFileManager.deleteDefineCache(withName: "K_User_Data")
        self.userModel = UserModel.init()
        KFileManager.deleteDefineCache(withName: "K_User_Club")
        self.userClub = nil;
    }
    
    override init() {
        super.init()
        //初始用户信息
        let userJson = KFileManager.cacheText(withFileName: "K_User_Data")
        if userJson != nil {
            let user  = NSString.init(string: userJson!).mj_JSONObject()
            if user != nil {
                let userModel = UserModel.mj_object(withKeyValues: user!)
                self.userModel = userModel
            }
        }
        //初始信息信息
        let clubJson = KFileManager.cacheText(withFileName: "K_User_Club")
        if clubJson != nil {
            let club  = NSString.init(string: clubJson!).mj_JSONObject()
            if club != nil {
                let clubModel = ClubModel.mj_object(withKeyValues: club!)
                self.userClub = clubModel
            }
        }
        
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground, object: nil, queue: nil) { (note) in
            print("UIApplicationDidEnterBackground")
            self.cacheSaveRefresh()
         
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidFinishLaunching, object: nil, queue: nil) { (note) in
        }
    }
}

//MARK: - 用户model
/// 用户model
class UserModel: KBaseModel {
    var nickname : String = ""
    var headimg : String = ""
    var username : String = "" //手机号
    var realname : String = "" //名字
    var token : String = ""//判断登录不需要用这个token
    var club : Dictionary<String,Any>? //
    var address : String = ""  //地址字符串
    var areadress :Dictionary<String,Any>? //地址id 省、市、区
    
    var age : String = ""  //地址
    var authtype : NSInteger = 0  //认证类型 0未认证 1 已认证 其他 审核中
    var bgimg : String = ""  //
    var birthday : String = ""  //生日
    var clubid : String = ""  //姓氏id
    var createtd : String = ""  //注册时间
    var email : String = ""  //邮箱
    var gender : String = ""  //性别
    var honorlevel : String = ""  //荣誉等级
    var id : String = ""  //用户id
    var idcard : String = ""  //
    var integral : String = ""  //金钱
    var interest : String = ""  //
    var level : String = ""  //等级
    var mobilephone : String = ""  //手机号
    var paypassword : String = ""  //支付密码
    var signature : String = ""  //签名
    var status : String = ""  //
    var tclub : ClubModel?
    var updated : String = ""
    var useragent : String = ""
    var usercode : String = ""
    var usertype : NSInteger = 0
    var teamid = -1
    
    //个人资料用到
    var job : String = ""
    var speciality : String = ""
    var registerString : String = ""
    var userid : String = "" //获取个人信息返回

    //第三方账号信息
    var thirdUsers = NSMutableArray()
    
    //判断是否是好友
    var isfriend : NSInteger = 0
    
    override class func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
        return [AnyHashable("registerString"):"register"]
    }
    
    override static func mj_objectClassInArray() -> [AnyHashable : Any]! {
        return ["thirdUsers": ThirdUser.self]
    }
}

//MARK: - 姓氏model
/// 姓氏model
class ClubModel: KBaseModel{
    var id : String = ""
    var club :String = ""
    var club_qp :String = "" //姓氏全拼
    var club_sx :String = "" //姓氏简拼
    var updated :String = ""
    var created :String = ""
}

//MARK: - 第三方model
/// 第三方model
class ThirdUser: KBaseModel{
    var openid : String = ""
    var usertype :NSInteger = 0 //3 QQ   2 微信
}

//MARK: - 全局的一些字符串，可以是 通知的key，缓存的key,最好以小写k开头

/// 全局的一些字符串，可以是 通知的key，缓存的key,最好以小写k开头
class CUKey: NSObject {
    
    /// 通知： 完善信息成功
    class var kNotifiCompleteUserinfo : String{
        return "kNotifiCompleteUserinfo"
    }
    class var kLoginSuccess : String {
        return "kLoginSuccess"
    }
    class var kLogoutSuccess : String {
        return "kLogoutSuccess"
    }

    
    //MARK: - List本地缓存
    /// 首页动态列表
    class var catch_Dynatimic : String {
        return "catch_Dynatimic"
    }
    /// 活动列表
    class var catch_Activity : String {
        return "catch_Activity"
    }
    /// 企业秀列表
    class var catch_Qiye : String {
        return "catch_Qiye"
    }
    
    
    //MARK: - 数据存储key及文件名
    //TODO:资源数据
    class var kSourceSave : String {
        return "kSourceSave"
    }
    /// 本地资源数据versionkey
    class var kCurrentSourceVersion : String {
        return "kCurrentSourceVersion"
    }
    /// 服务器端的资源versionkey
    class var kServerSourceVersion : String {
        return "kServerSourceVersion"
    }
    
    //TODO:启动接口返回数据
    /// 启动接口返回数据
    class var kStartupInfo : String {
        return "kStartupInfo"
    }
    
    //TODO:是否有新消息
    /// 是否有新消息
    class var kNewMessage : String {
        return "kNewMessage"
    }
    
    //TODO: 是否关闭推送
    /// 是否关闭推送
    class var kStartupInfo_CloseNotice : String {
        return "kStartupInfo_CloseNotice"
    }
    
    //TODO:首页自动弹窗——版本更新弹窗时间
    /// 首页自动弹窗——版本更新弹窗时间
    class var kStartupInfo_versionAlterTime : String {
        return "kStartupInfo_versionAlterTime"
    }

    //TODO:寄思先祖数据存储文件
    /// 寄思先祖数据存储文件
    class var kAncestor : String {
        return "kAncestor"
    }
    /// 寄思先祖数据-香key
    class var kAncestor_xiang : String {
        return "kAncestor_xiang"
    }
    /// 寄思先祖数据-贡品key
    class var kAncestor_gongpin : String {
        return "kAncestor_gongpin"
    }
    /// 寄思先祖数据-花key
    class var kAncestor_hua : String {
        return "kAncestor_hua"
    }
    /// 寄思先祖数据-时间key
    class var kAncestor_time : String {
        return "kAncestor_time"
    }
    /// 寄思先祖数据-时间key
    class var kAncestor_altertime : String {
        return "kAncestor_altertime"
    }
    
    //TODO: 系统消息存储文件
    /// 系统消息存储文件
    class var knotice_file : String {
        return "knotice_file"
    }

    
    class var kPlaceHead: String {
        return "user_placeholder"
    }
    
    //MARK: - UM友盟埋点key
    ///同宗活动页
    class var UM_activity : String {
        return "UM_activity"
    }
    ///发布同宗活动
    class var UM_activity_public : String {
        return "UM_activity_public"
    }
    ///寄思先祖页
    class var UM_jisi : String {
        return "UM_jisi"
    }
    ///姓氏名人页
    class var UM_xsmr : String {
        return "UM_xsmr"
    }
    ///企业秀页
    class var UM_qyx : String {
        return "UM_qyx"
    }
    ///发布企业秀页面
    class var UM_qyx_public : String {
        return "UM_qyx_public"
    }
    ///发布动态页面
    class var UM_dynamic_public : String {
        return "UM_dynamic_public"
    }
    

    //MARK: - 推送key
    class var DDNotificationLogout: String {
        return "Notification_user_logout"
    }
    class var DDNotificationUserLoginFailure: String {
        return "Notification_user_login_failure"
    }
    class var DDNotificationUserReloginSuccess: String {
        return "Notification_user_relogin_success"
    }
    class var DDNotificationUserOffline: String {
        return "Notification_user_off_line"
    }
    class var DDNotificationUserKickouted: String {
        return "Notification_user_kick_out"
    }
    class var DDNotificationUserSignChanged: String {
        return "Notification_user_sign_changed"
    }
    class var DDNotificationPCLoginStatusChanged: String {
        return "Notification_pc_login_status_changed"
    }
    class var DDNotificationUserInitiativeOffline: String {
        return "Notification_user_initiative_Offline"
    }
    class var DDNotificationReloadTheRecentContacts: String {
        return "Notification_reload_recent_contacts"
    }
    class var DDNotificationReceiveMessage: String {
        return "Notification_receive_message"
    }
    class var DDNotificationReceiveP2PShakeMessage: String {
        return "Notification_receive_P2P_Shake_message"
    }
    class var DDNotificationReceiveP2PInputingMessage: String {
        return "Notifictaion_receive_P2P_Inputing_message"
    }
    class var DDNotificationReceiveP2PStopInputingMessage: String {
        return "Notification_receive_P2P_StopInputing_message"
    }
    class var DDNotificationLoadLocalGroupFinish: String {
        return "Notification_local_group"
    }
    class var DDNotificationRecentContactsUpdate: String {
        return "Notification_RecentContactsUpdate"
    }
    class var MTTNotificationSessionShieldAndFixed: String {
        return "Notification_SessionShieldAndFixed"
    }
    class var ReloginSuccess : String{
        return "Notification_ReloginSuccess";
    }
    
    /// SessionModule 注册通知，发送消息成功
    class var SentMessageSuccessfull : String{
        return "Notification_SentMessageSuccessfull"
    }
    
    ///group_ 群前置
    class var GROUP_PRE : String{
        return "group_"
    }
    class var TT_DEFAULT_PSD : String{
        return "123456"
    }
    
}

//MARK: - 第三方key
class ThirdKey : NSObject{
    class var WeXAppId : String {
        return "wx85c752c2b9fd1176"
    }
    class var WeXAppSecret : String {
        return "0d1491d11344048235d396e1142d6b03"
    }
    class var QQAppId : String {
        return "1106744398"
    }
    class var QQAppKey : String {
        return "bp1TZ9S9QZvoU7S1"
    }
    
    class var UMAppKey : String {
        return "5aa1edf8f43e485022000085"
    }

}


//MARK: - 默认的一些占位图片
class ImageDefault : NSObject{
    class var imagePlace : String {
        return "img_place"
    }
    
    class var headerPlace : String {
        return "user_placeholder"
    }
    
    class var emptyPlace : String {
        return "empty1"
    }
    class var emptyPlace2 : String {
        return "empty2"
    }
}

//MARK: - 默认的一些提示语
class TextDefault : NSObject{
    class var noNetWork : String {
        return "暂无网络"
    }
}

//MARK: - 默认的一些数字 ：最大可以发多少张图片 视频的长度 等等
class numDefault : NSObject{
    class var knum_pickerPublic : NSInteger {
        return 9
    }
    class var kRowspacing : NSInteger {
        return 5
    }
    class var knum_biaoti : NSInteger {
        return 30
    }
}
