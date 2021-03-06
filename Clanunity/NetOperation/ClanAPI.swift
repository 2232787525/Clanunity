//
//  ClanAPI.swift
//  Clanunity
//
//  Created by wangyadong on 2018/1/31.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

import UIKit
import MJExtension

/// 编译环境
///
/// - Release: 外网，线上环境
/// - Dev: 内网，测试环境
/// - Bug: 单机测试环境
enum BuildType : Int8 {
    case Release = 1//外网
    case Dev = 2//内网·
    case Bug = 3//bug
    case Test = 4//测试外网
}

/// 请求类型
///
/// - GET: get请求
/// - POST: post请求
enum RequestMethod : Int8{
    case GET = 0
    case POST = 1
}


/// 上传文件类型
///
/// - IMG: 图片
/// - VIDEP: 视频
/// - AMR: 语音
enum UpdateFileType : Int8{
    case IMG = 0
    case VIDEP = 1
    case AMR = 2
}


class ClanAPI: NSObject {
    
    //MARK: 基础配置
    /// 编译环境
    class var buildType: BuildType {
        return BuildType.Release//切换编译环境
    }
    
    /// 域名
    class var DomainName : String{
        
        switch ClanAPI.buildType{
        case .Release :
            return "http://api.tzhhx.com";
        case .Dev :
            return "http://192.168.1.192:9997";
        case .Bug:
            return "http://192.168.1.22:8080";
        case .Test:
            return "http://wapi.tzhhx.com";
        }
    }
    
    /// teamTalk IM域名
    class var IMDomainName : String {
        switch ClanAPI.buildType{
        case .Release :
            return "http://47.95.223.107";
        case .Dev :
            return "http://47.95.223.107";
        case .Bug:
            return "http://47.95.223.107";
        case .Test:
            return "http://47.95.223.107";
        }
    }
    
    //附件的域名
    class var resourceName : String{
        return "http://cdn.tzhhx.com/";
    }
    
    //H5域名
    class var H5UserName : String{
        switch ClanAPI.buildType{
        case .Release :
            return "http://tzhh5.tzhhx.com";
        case .Dev :
            return "http://192.168.1.192:9997";
        case .Bug:
            return "http://47.95.223.107";
        case .Test:
            return "http://wtzhh5.tzhhx.com";
        }
    }
    
    //郝志华本地
    class var H5HZH : String{
        return "http://192.168.1.153:8020/tzh/";
    }
    
    //活动分享-子链接  前面拼接H5域名
    class var H5Share_activity : String{
        return "/tzh/actives.html?actid=";
    }
    //寄思先祖分享-子链接  前面拼接H5域名
    class var H5Share_zongCi : String{
        return "/tzh/zongCi.html?id="; //classid   1姓氏名人 2姓氏源流 3线下宗祠
    }
    //企业秀分享-子链接  前面拼接H5域名
    class var H5Share_qiYe : String{
        return "/tzh/qiYe.html?id=";
    }
    //协议-子链接  前面拼接H5域名
    class var H5_agreement : String{
        return "/tzh/agreement.html";
    }
    //关于我们-子链接  前面拼接H5域名
    class var H5_aboutUs : String{
        return "/tzh/aboutUs.html";
    }
    
    //协议-子链接  前面拼接H5域名
    class var H5_complaintToKnow : String{
        return "/tzh/complaintToKnow.html";
    }

    //聊天大厅websocket-子链接  
    class var H5_chatRoomWebsocket : String{
        return "/h5_websocket/index.html?username=";
    }
    
    
    /// 域名+ 项目名 + 业务路径接口
    ///
    /// - Parameter url: 业务路径接口
    /// - Returns: 请求接口
    class func URL_Link(url:String) -> String{
        return ClanAPI.DomainName + "/tzh" + url.trim
    }
    
    /// 返回判断是否有网络
    class func checkNetWork() -> Bool{
        
        if (APPDELEGATE.networkStatus == 0){
            return false
        }
        return true
    }
    
    /// 封装的请求
    ///
    /// - Parameters:
    ///   - method: 请求类型
    ///   - parameters: 参数字典
    ///   - urlString: 业务接口
    ///   - success: 成功
    ///   - faile: 失败
    class func clanRequest(method:RequestMethod,  parameters:Dictionary<String,Any>?,bunissUrl urlString:String,success:@escaping SuccessfulHandle,faile:@escaping FailedHandle) -> Void{
        
        
        if method == .GET {
            NetworkService.shareService.GET_request(parameters: parameters, businessURL: ClanAPI.URL_Link(url: urlString), successBlock: { (task, response) in
                
                if (response is Dictionary<String, Any>){
                    let resDic = response as! Dictionary<String,Any>!
                    let status = resDic!["status"] as? String
                    if  status == "309"{
                        
                        LoginServer.share.showLoginCompleteInfo(block: { (status) in
                            print("总接口 - 309 - 登录成功")
                        })
                        
                    }else if (status == "401"){
                        //未登录 跳登录页面
                        LoginServer.share.showLoginVC(block: { (status) in
                        })
                    }else{
                    }
                    success(task,response)
                }else{
                    success(task,response)
                }
            }, failureBlock: { (task, error) in
                faile(task,error)
            })
        }else if method == .POST{
            
            NetworkService.shareService.POST_request(parameters: parameters, url: ClanAPI.URL_Link(url: urlString), success: { (task, response) in
                if (response is Dictionary<String, Any>){
                    let resDic = response as! Dictionary<String,Any>!
                    let code = resDic!["status"] as? String
                    
                    if (code == "401"){
                        //未登录 跳登录页面
                        LoginServer.share.showLoginVC(block: { (status) in
                        })
                    }else{
                        success(task,response)
                    }
                }else{
                    success(task,response)
                }
            }, faile: { (task, error) in
                faile(task,error)
            })
        }
    }
    
    
    /// 上传文件的接口
    ///
    /// - Parameters:
    ///   - fileType: 文件类型
    ///   - files: 文件数组
    ///   - progress: 进度
    ///   - success: 成功
    ///   - faile: 失败
    class func clanRequestPOST_Updatefile(_ fileType:UpdateFileType,files:Array<Data>,progress:@escaping ProgressHandle,success:@escaping SuccessfulHandle,faile:@escaping FailedHandle) {
        
        NetworkService.shareService.sessionManager.requestSerializer.timeoutInterval = 30.0
        
        var mime = UpdateFileMimeType.IMG
        if fileType == UpdateFileType.VIDEP {
            mime = UpdateFileMimeType.VIDEP
        }
        if fileType == UpdateFileType.AMR {
            mime = UpdateFileMimeType.AMR
        }
        NetworkService.shareService.POST_UpdateFile(parameters: nil, url: ClanAPI.URL_Link(url: "/api/attachment/uploadfiles"), files:files, mimeType: mime, progress: { (pros) in
            progress(pros)
        }, success: { (task, any) in
            NetworkService.shareService.sessionManager.requestSerializer.timeoutInterval = 8.0

            if (any is Dictionary<String, Any>){
                let resDic = any as! Dictionary<String,Any>!
                let code = resDic!["status"] as? String
                
                if (code == "401"){
                    //未登录 跳登录页面
                    LoginServer.share.showLoginVC(block: { (status) in
                        print("clanRequestPOST_Updatefile - 401- 登录成功")
                    })
                    
                }else{
                }
                success(task,any)
            }else{
                success(task,any)
            }
        }) { (task, error) in
            NetworkService.shareService.sessionManager.requestSerializer.timeoutInterval = 8.0

            faile(task,error)
        }
    }
    
    
    
    //MARK:业务接口--网络请求
    //MARK: - --------------登录系列--------------
    //MARK:启动接口
    /// 启动接口
    ///
    /// - Parameter result:
    public class func requestForStartup(result:@escaping ResultHandle) -> Void{
        ClanAPI.clanRequest(method: .POST, parameters: nil, bunissUrl: "/api/main/startup", success: { (task, any) in
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "", message: "", isOk: false, isError: true))
        }
    }
    
    
    //4714
    //MARK:获取短信验证码
    /// 获取短信验证码
    ///
    /// - Parameter result:
    public class func requestForsmscode(username : String , result:@escaping ResultHandle) -> Void{
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        
        var parameter : [String : Any]
        parameter = ["username":username]
        ClanAPI.clanRequest(method: .GET, parameters: parameter, bunissUrl: "/api/sms", success: { (task, any) in
            
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "", message: "", isOk: false, isError: true))
        }
    }
    
    //MARK:手机验证码登录接口
    /// 手机验证码登录接口
    ///
    /// - Parameter result:
    public class func requestForLogin(username : String, smscode : String,result:@escaping ResultHandle) -> Void{
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        var parameter : [String : Any]
        parameter = ["username":username,"smscode":smscode,"deviceToken":APPDELEGATE.deviceToken ]
        
        ClanAPI.clanRequest(method: .POST, parameters: parameter, bunissUrl: "/api/login", success: { (task, any) in
            
            //            - key : thirdUsers
            //            - key : openid
            //            - value : 5EEE5053AA293A2D33E21EB6D30EB3B2
            //            - key : usertype
            //            - value : 3
            
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
            
        }) { (task,error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    //MARK: 绑定手机
    ///绑定手机
    /// - Parameters:
    ///   - username: 手机号
    ///   - smscode: 验证码
    ///   - usertype: 2微信，3qq
    ///   - openid: openid
    ///   - headimg: 头像
    ///   - result: 结果
    public class func requestForBind(username:String,smscode:String,usertype:Int,openid:String?,headimg:String?,result:@escaping ResultHandle) -> Void{
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        
        var par = [String:Any]()
        par["username"] = username
        par["smscode"] = smscode
        par["usertype"] = usertype
        par["openid"] = openid ?? ""
        par["headimg"] = headimg ?? ""
        
        ClanAPI.clanRequest(method: .POST, parameters: par, bunissUrl: "/api/thirdlogin/submit", success: { (task, response) in
            
            if (response != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: response!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "请求失败", isOk: false, isError: true))
            }
        }) { (task, error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    
    //MARK: 更改手机号
    ///更改手机号
    /// - Parameters:
    ///   - username: 手机号
    ///   - smscode: 验证码
    ///   - result:
    class func requestForChangeUsername(newPhone:String,smscode:String,result:@escaping ResultHandle) -> Void{
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        
        var par = [String:Any]()
        par["newPhone"] = newPhone
        par["smscode"] = smscode
        
        ClanAPI.clanRequest(method: .POST, parameters: par, bunissUrl: "/api/account/changeUsername", success: { (task, response) in
            
            if (response != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: response!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "请求失败", isOk: false, isError: true))
            }
        }) { (task, error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    
    //MARK:上传姓氏和地址接口
    /// 上传姓氏和地址接口
    ///
    /// - Parameter result:
    public class func requestForsaveUserBaseInfo(clubid : String, name : String, gender : String, address : String,  provid : String,  cityid : String,  areaid : String,result:@escaping ResultHandle) -> Void{
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        
        var parameter : [String : Any]
        parameter = ["clubid":clubid,
                     "name":name,
                     "provid":provid,
                     "cityid":cityid,
                     "areaid":areaid,
                     "gender":gender,
                     "address":address]
        
        ClanAPI.clanRequest(method: .POST, parameters: parameter, bunissUrl: "/api/login/saveUserBaseInfo", success: { (task, any) in
            
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "0", message: "没有数据", isOk: false, isError: true))
            }
            
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "0", message: "", isOk: false, isError: true))
        }
    }
    
    
    //MARK:获取地址数据列表
    /// 获取地址数据列表
    ///
    /// - Parameter result:
    public class func requestForAreaList(result:@escaping ResultHandle) -> Void{
        ClanAPI.clanRequest(method: .GET, parameters: nil, bunissUrl: "/api/main/getAllAreaList", success: { (task, any) in
            
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "", message: "", isOk: false, isError: true))
        }
    }
    
    //MARK:获取姓氏接口
    /// 获取姓氏接口(搜索姓氏接口)
    ///
    /// - Parameter result:
    public class func requestForSurnameList(pagenum : Int,pagesize : Int, keyword : String, result:@escaping ResultHandle) -> Void{
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        
        var parameter : [String : Any]
        parameter = [:]
        if (keyword.count == 0){
            parameter["pagenum"] = pagenum
            parameter["pagesize"] = pagesize
        }else{
            parameter["keyword"] = keyword
        }
        
        ClanAPI.clanRequest(method: .GET, parameters: parameter, bunissUrl: "/api/main/getClubPage", success: { (task, any) in
            
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                
                if ((model != nil) && (model!.data != nil)){
                    if (model?.data is Dictionary<String, Any>){
                        
                        var dic = model!.data! as! Dictionary<String , Any>
                        let arr = dic["list"] as! Array<Dictionary<String,Any>>
                        
                        let array = ClubModel.mj_objectArray(withKeyValuesArray: arr)
                        dic["list"] = array
                        model?.data = dic
                    }
                }
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "", message: "", isOk: false, isError: true))
        }
    }
    
    //MARK:提交姓氏接口
    /// 提交姓氏接口
    ///
    /// - Parameter result:
    public class func requestForSubmitClum(club : String, result:@escaping ResultHandle) -> Void{
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        
        let parameter = ["club":club]
        
        ClanAPI.clanRequest(method: .POST, parameters: parameter, bunissUrl: "/api/main/submitClub", success: { (task, any) in
            
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
            
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "", message: "", isOk: false, isError: true))
        }
    }
    
    
    //MARK:第三方登录
    /// 第三方登录
    ///
    /// - Parameters:
    ///   - usertype: 1-直接注册； 2-微信登陆；3- QQ登陆
    ///   - codeOpenid: 2对应code，3对应openid
    ///   -headImg qq的情况下传headimg
    ///   - result: 结果
    public class func requestForThirdLogin(usertype:Int,codeOpenid:String,headImg:String?,result:@escaping ResultHandle) -> Void{
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        
        var par = [String:Any]()
        par["usertype"] = usertype;
        if usertype == 2 {
            par["code"] = codeOpenid
        }else if usertype == 3{
            par["openid"] = codeOpenid
        }
        par["deviceToken"] = APPDELEGATE.deviceToken
        
        ClanAPI.clanRequest(method: .POST, parameters: par, bunissUrl: "/api/thirdlogin", success: { (task, response) in
            
            print(response ?? "no data");
            result(ClanAPIResult.mj_object(withKeyValues: response!));
        }) { (task, error) in
            print(error);
            result(ClanAPIResult.initResult(status: "0", message: "网络连接失败", isOk: false, isError: true, nil));
        }
    }
    
    //MARK:绑定第三方账号
    /// 绑定第三方账号
    ///
    /// - Parameters:
    ///   - usertype:  2-微信登陆；3- QQ登陆
    ///   - codeOpenid: 2对应code，3对应openid
    ///   -headImg qq的情况下传headimg
    ///   - result: 结果
    public class func requestForBindThirdLogin(usertype:Int,codeOpenid:String,result:@escaping ResultHandle) -> Void{
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        
        var par = [String:Any]()
        par["usertype"] = usertype;
        if usertype == 2 {
            par["code"] = codeOpenid
        }else if usertype == 3{
            par["openid"] = codeOpenid
        }
        ClanAPI.clanRequest(method: .POST, parameters: par, bunissUrl: "/api/account/bindThirdAccount", success: { (task, response) in
            
            print(response ?? "no data");
            result(ClanAPIResult.mj_object(withKeyValues: response!));
        }) { (task, error) in
            print(error);
            result(ClanAPIResult.initResult(status: "0", message: "网络连接失败", isOk: false, isError: true, nil));
        }
    }
    
    //MARK:解绑第三方账号
    /// 解绑第三方账号
    ///
    /// - Parameters:
    ///   - usertype:  2-微信登陆；3- QQ登陆
    ///   - codeOpenid: 2对应code，3对应openid
    ///   -headImg qq的情况下传headimg
    ///   - result: 结果
    public class func requestForDeleteThirdLogin(openid:String,result:@escaping ResultHandle) -> Void{
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        
        var par = [String:Any]()
        par["openid"] = openid;
        
        ClanAPI.clanRequest(method: .POST, parameters: par, bunissUrl: "/api/account/deleteThirdAccount", success: { (task, response) in
            
            print(response ?? "no data");
            result(ClanAPIResult.mj_object(withKeyValues: response!));
        }) { (task, error) in
            print(error);
            result(ClanAPIResult.initResult(status: "0", message: "网络连接失败", isOk: false, isError: true, nil));
        }
    }
    
    
    //MARK:实名认证
    /// 实名认证
    ///
    /// - Parameters:
    ///   - usertype:  2-微信登陆；3- QQ登陆
    ///   - codeOpenid: 2对应code，3对应openid
    ///   -headImg qq的情况下传headimg
    ///   - result: 结果
    public class func requestForauth(idfrontimg:String,idbackimg:String, result:@escaping ResultHandle) -> Void{
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        
        var par = [String:Any]()
        par["idfrontimg"] = idfrontimg;
        par["idbackimg"] = idbackimg;
        
        ClanAPI.clanRequest(method: .POST, parameters: par, bunissUrl: "/api/account/auth", success: { (task, response) in
            print(response ?? "" , "实名认证返回信息");
            result(ClanAPIResult.mj_object(withKeyValues: response!));
        }) { (task, error) in
            print(error);
            result(ClanAPIResult.initResult(status: "0", message: "网络连接失败", isOk: false, isError: true, nil));
        }
        
    }
    
    //MARK:手机验证码登录接口
    /// 手机验证码登录接口
    ///
    /// - Parameter result:
    public class func requestForupdateDeviceToken(result:@escaping ResultHandle) -> Void{
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        
        var parameter : [String : Any]
        parameter = ["deviceToken":APPDELEGATE.deviceToken]
        
        ClanAPI.clanRequest(method: .POST, parameters: parameter, bunissUrl: "/api/account/updateDeviceToken", success: { (task, any) in
            
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
            
        }) { (task,error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    //4714
    //MARK:获取实名认证状态
    /// 获取实名认证状态
    ///
    /// - Parameter result:
    public class func requestForAuthStatus(result:@escaping ResultHandle) -> Void{
        ClanAPI.clanRequest(method: .GET, parameters: nil, bunissUrl: "/api/account/getAuthStatus", success: { (task, any) in
            
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "", message: "", isOk: false, isError: true))
        }
    }
    
    //MARK: --------------IM系列 --------------
    public class func requestIMfoLogin(result:@escaping ResultHandle) -> Void{
        
        NetworkService.shareService.GET_request(parameters: nil, businessURL: ClanAPI.IMDomainName+"/msg_server", successBlock: { (task, res) in
            print(res ?? "IMfoLogin no data");
            do {
                let dic = try JSONSerialization.jsonObject(with: res as! Data, options: JSONSerialization.ReadingOptions.mutableContainers)
                print(dic)
                result(ClanAPIResult.initResult(status: "1", message: "", isOk: true, isError: false, dic))
            }catch{
                print(error)
            }
        }) { (task, error) in
            result(ClanAPIResult.initResult(status: "0", message: "失败", isOk: true, isError: false, error))
        }
    }
    
    
    //MARK: 创建群接口
    ///
    /// - Parameters:
    ///   - members: 群成员 fuserid id, 用逗号隔开
    ///   - result: 结果
    public class func requestForCreateGroup(members:String,result:@escaping ResultHandle) -> Void{
        
        ClanAPI.clanRequest(method: .POST, parameters: ["members":members], bunissUrl: "/api/group/create", success: { (task, response) in
            
            if (response != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: response!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
            
        }) { (task, error) in
            result(ClanAPIResult.faileResult());
        }
    }
    //MARK: 我的群列表
    
    /// 获取我的群列表
    ///
    /// - Parameter result:结果回调
    public class func requestForMyGroupList(result:@escaping ResultHandle) -> Void{
        
        ClanAPI.clanRequest(method: .GET, parameters: nil, bunissUrl: "/api/group", success: { (task, response) in
            if (response != nil){
                let model = ClanAPIResult.mj_object(withKeyValues: response!);
                result(model!);
            }else{
                result(ClanAPIResult.initResult(status: "0", message: "没有数据", isOk: false, isError: true))
            }
            
            
        }) { (task, error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    //MARK: 根据teamtalk的groupid获取群信息
    /// 根据teamtalk的groupid获取群信息
    ///
    /// - Parameters:
    ///   - ttGroupid: 群id
    ///   - result: 结果
    public class func requestForGroupInfo(ttGroupid:Int,result:@escaping ResultHandle) -> Void{
        
        ClanAPI.clanRequest(method: .GET, parameters: ["groupid":ttGroupid], bunissUrl: "/api/group/groupinfo", success: { (task, response) in
            result(ClanAPIResult.successResult(response: response))
        }) { (task, error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    /// 删除群成员
    ///
    /// - Parameters:
    ///   - groupid: 群id
    ///   - userid: 用户id
    ///   - result: 结果
    public class func requestForDeleteMember(groupid:Int,userid:Int,result:@escaping ResultHandle) -> Void{
        ClanAPI.clanRequest(method: .GET, parameters: ["groupid":groupid,"teamid":userid], bunissUrl: "/api/group/deleteMember", success: { (task, response) in
            result(ClanAPIResult.successResult(response: response))
        }) { (task, error) in
            result(ClanAPIResult.faileResult())
        }
        
    }
    
    
    
    /// 群公告详情
    ///
    /// - Parameters:
    ///   - ttGroupid: 群id
    ///   - result: 结果
    public class func requestForGroupPublicNotice(ttGroupid:Int,result:@escaping ResultHandle) -> Void{
        
        ClanAPI.clanRequest(method: .GET, parameters: ["groupid":ttGroupid], bunissUrl: "/api/group/noticeDetail", success: { (task, response) in
            result(ClanAPIResult.successResult(response: response))
        }) { (task, error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    
    /// 发布群公告
    ///
    /// - Parameters:
    ///   - groupid: 群id
    ///   - content: 内容
    ///   - result: 结果
    public class func requestForPublicGroupNotice(groupid:Int,content:String,result:@escaping ResultHandle) -> Void{
        ClanAPI.clanRequest(method: .GET, parameters: ["groupid":groupid,"content":content], bunissUrl: "/api/group/notice", success: { (task, response) in
            result(ClanAPIResult.successResult(response: response))
        }) { (task, error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    
    //MARK: 根据teamtalk的userid获取个人信息
    /// 根据teamtalk的userid获取个人信息
    ///
    /// - Parameters:
    ///   - groupid: 群id
    ///   - result: 结果
    public class func requestForUserInfo(ttUserid:Int,result:@escaping ResultHandle) -> Void{
        
        ClanAPI.clanRequest(method: .GET, parameters: ["teamid":ttUserid], bunissUrl: "/api/group/userInfo", success: { (task, response) in
            result(ClanAPIResult.successResult(response: response))
        }) { (task, error) in
            result(ClanAPIResult.faileResult())
        }
    }
    //MARK: 搜索
    /// 搜索
    ///
    /// - Parameters:
    ///   - searchkey: 关键字
    ///   - result: 搜索结果
    public class func requestForSearchFriendGroup(searchkey:String,result:@escaping ResultHandle) -> Void{
        ClanAPI.clanRequest(method: .GET, parameters: ["keywords":searchkey], bunissUrl: "/api/group/search", success: { (task, response) in
            result(ClanAPIResult.successResult(response: response))
        }) { (task, error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    
    
    //MARK: 通过手机号 搜索好友
    ///
    /// - Parameters:
    ///   - phone: 手机号
    ///   - result: 结果
    public class func requestForSearchFriend(phone:String,result:@escaping ResultHandle) ->Void{
        ClanAPI.clanRequest(method: .POST, parameters: ["phone":phone], bunissUrl: "/api/friend/searchByPhone", success: { (task, response) in
            if (response != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: response!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "0", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task, error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    //MARK: 申请添加好友
    ///
    /// - Parameters:
    ///   - remark: 备注可不填
    ///   - friendid: 好友id
    ///   - result: 结果
    public class func requestForApplyForAddFriend(remark:String?,friendid:String,result:@escaping ResultHandle) ->Void{
        ClanAPI.clanRequest(method: .POST, parameters: ["friendid":friendid,"remark":remark ?? ""], bunissUrl: "/api/friend/addFriend", success: { (task, response) in
            if (response != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: response!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "0", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task, error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    //MARK:删除好友
    ///
    /// - Parameters:
    ///   - friendid: 好友id
    ///   - result: 结果
    public class func requestForDeleteFriend(friendid:String,result:@escaping ResultHandle) ->Void{
        ClanAPI.clanRequest(method: .POST, parameters: ["friendid":friendid], bunissUrl: "/api/friend/delete", success: { (task, response) in
            if (response != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: response!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "0", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task, error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    //MARK: 好友申请列表
    ///
    /// - Parameter result: 结果
    public class func requestForFriendsApplyList(page:Int,pageSize:Int,result:@escaping ResultHandle) ->Void{
        ClanAPI.clanRequest(method: .GET, parameters:["pagenum":page,"pagesize":pageSize], bunissUrl: "/api/friend/applyList", success: { (task, response) in
            if (response != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: response!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "0", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task, error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    
    /// 修改用户状态
    ///
    /// - Parameters:
    ///   - userid: 用户id
    ///   - status: 状态1接受，2拒绝
    ///   - result: 结果
    public class func requestForFriendsUpdateAppleStatus(userid:String,status:Int,result:@escaping ResultHandle) ->Void{
        ClanAPI.clanRequest(method: .POST, parameters:["id":userid,"status":status], bunissUrl: "/api/friend/updateAppleStatus", success: { (task, response) in
            if (response != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: response!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "0", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task, error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    /// 我的好友列表
    ///
    /// - Parameter result: 结果
    public class func requestForMyFriendList(page:Int,pageSize:Int, result:@escaping ResultHandle) ->Void{
        ClanAPI.clanRequest(method: .GET, parameters:["pagenum":page,"pagesize":pageSize], bunissUrl: "/api/friend", success: { (task, response) in
            if (response != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: response!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "0", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task, error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    public class func requestForChatRoomFull(areaid:String,result:@escaping ResultHandle) ->Void{
        ClanAPI.clanRequest(method: .GET, parameters:["areaid":areaid], bunissUrl: "/api/chatroom/onlinenum", success: { (task, response) in
            if (response != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: response!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "0", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task, error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    
    //MARK: - --------------首页--------------
    //MARK:资源接口
    /// 资源接口
    ///
    /// - Parameter result:
    public class func requestForgetResource(result:@escaping ResultHandle) -> Void{
        
        ClanAPI.clanRequest(method: .GET, parameters: nil, bunissUrl: "/api/main/getResource", success: { (task, any) in
            
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "", message: "", isOk: false, isError: true))
        }
    }
    
    //MARK:banner广告接口
    /// banner广告接口
    ///
    /// - Parameter result:
    public class func requestForgetBannerList(type : String,result:@escaping ResultHandle) -> Void{
        
        var parameter : [String : Any]
        parameter = ["type":type]
        
        ClanAPI.clanRequest(method: .GET, parameters: parameter, bunissUrl: "/api/main/getBannerList", success: { (task, any) in
            
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "", message: "", isOk: false, isError: true))
        }
    }
    
    //MARK: - --------------同宗动态--------------
    
    //MARK:首页动态列表
    /// 首页动态列表
    ///
    /// - Parameter result:
    public class func requestForDynamicList(pagenum : Int,pagesize : Int,result:@escaping ResultHandle) -> Void{
        
        if pagesize == 0 {
            return
        }
        
        var parameter : [String : Any]
        parameter = ["pagenum":pagenum,
                     "pagesize":pagesize]
        
        ClanAPI.clanRequest(method: .GET, parameters: parameter, bunissUrl: "/api/dynamic", success: { (task, any) in
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "0", message: "请求失败", isOk: false, isError: true))
        }
    }
    
    
    
    
    
    //MARK:发布动态
    /// 发布动态
    ///
    /// - Parameter result:
    public class func requestForSubmitDynamic(title : String, content : String, mediatype : String, attachid : String, attachpath : String, videoimg : String, result:@escaping ResultHandle) -> Void{
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        
        var parameter : [String : Any]
        parameter = [:]
        
        if (title.count > 0){
            parameter["title"] = title
        }
        parameter["content"] = content
        
        if (attachid.count > 0){
            parameter["attachid"] = attachid
        }
        if (attachpath.count > 0){
            parameter["attachpath"] = attachpath
        }
        parameter["mediatype"] = mediatype
        parameter["videoimg"] = videoimg
        
        ClanAPI.clanRequest(method: .POST, parameters: parameter, bunissUrl: "/api/dynamic/submit", success: { (task, any) in
            
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
            
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "", message: "", isOk: false, isError: true))
        }
    }
    
    //    username: String,
    //MARK:获取某人的动态列表
    /// 获取某人的动态列表
    ///
    /// - Parameter result:
    public class func requestForuserDynamic(username:String, pagenum : Int,pagesize : Int,result:@escaping ResultHandle) -> Void{
        
        var parameter : [String : Any]
        parameter = ["pagenum":pagenum,
                     "pagesize":pagesize]
        if username.count > 0{
            parameter["username"] = username
        }
        
        ClanAPI.clanRequest(method: .GET, parameters: parameter, bunissUrl: "/api/dynamic/userDynamic", success: { (task, any) in
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "0", message: "请求失败", isOk: false, isError: true))
        }
    }
    
    
    
    //MARK:删除我的动态
    /// 删除我的动态
    ///
    /// - Parameter result:
    public class func requestForCancelDynamic(id : String,  result:@escaping ResultHandle) -> Void{
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        
        var parameter : [String : Any]
        parameter = [:]
        
        parameter["id"] = id
        
        ClanAPI.clanRequest(method: .POST, parameters: parameter, bunissUrl: "/api/dynamic/delete", success: { (task, any) in
            
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
            
        }) { (task,error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    //MARK:动态详情
    /// 动态详情
    ///
    /// - Parameter result:
    public class func requestForDynamicInfo(dyid : String, result:@escaping ResultHandle) -> Void{
        
        
        var parameter : [String : Any]
        parameter = ["id":dyid]
        
        ClanAPI.clanRequest(method: .GET, parameters: parameter, bunissUrl: "/api/dynamic/getDynamicDetail", success: { (task, any) in
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "", message: "", isOk: false, isError: true))
        }
    }
    
    //MARK: - --------------用户相关--------------
    //MARK:获取用户资料
    /// 获取用户资料
    ///
    /// - Parameter result:
    public class func requestForAccount(username:String, result:@escaping ResultHandle) -> Void{
        
        var parameter : [String : Any]
        parameter = [:]
        
        parameter["username"] = username
        
        ClanAPI.clanRequest(method: .GET, parameters: parameter, bunissUrl: "/api/account", success: { (task, any) in
            
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "", message: "", isOk: false, isError: true))
        }
    }
    
    //MARK:修改个人资料
    /// 修改个人资料
    ///
    /// - Parameter result:
    public class func requestForUpdateAccount(realname:String, job:String,register:String,speciality:String,interest:String,gender:String,birthday:String,headimg:String, result:@escaping ResultHandle) -> Void{
        
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        var parameter : [String : Any]
        parameter = [:]
        
        parameter["realname"] = realname
        parameter["job"] = job
        parameter["register"] = register
        parameter["speciality"] = speciality
        parameter["interest"] = interest
        parameter["gender"] = gender
        
        if headimg.count > 0{
            parameter["headimg"] = headimg
        }
        if birthday.count > 0{
            parameter["birthday"] = birthday
        }
        
        ClanAPI.clanRequest(method: .GET, parameters: parameter, bunissUrl: "/api/account/updateUserInfo", success: { (task, any) in
            
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "", message: "", isOk: false, isError: true))
        }
    }
    
    
    //MARK: - --------------同宗活动--------------
    //MARK:发布同宗活动
    /// 发布同宗活动
    ///
    /// - Parameter result:
    public class func requestForSubmitActivity(title : String, content : String, attachid : String, attachpath : String, themeimg : String, address : String, business : String, persons : String, starttime : String,   endtime : String, signupstarttime : String, signupendtime: String ,  result:@escaping ResultHandle) -> Void{
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        
        var parameter : [String : Any]
        parameter = [:]
        
        if (title.count > 0){
            parameter["title"] = title   //活动标题
        }
        parameter["content"] = content   //活动内容
        parameter["themeimg"] = themeimg //活动封面图
        parameter["address"] = address   //活动地址
        parameter["business"] = business //活动赞助商
        parameter["persons"] = persons   //活动人数
        parameter["starttime"] = starttime//活动开始日期
        parameter["endtime"] = endtime   //活动结束日期
        parameter["signupstarttime"] = signupstarttime //活动报名开始日期
        parameter["signupendtime"] = signupendtime //活动报名结束日期
        
        if (attachid.count > 0){
            parameter["attachid"] = attachid //活动内容图片附件id
        }
        if (attachpath.count > 0){
            parameter["attachpath"] = attachpath//活动内容图片附件路径
        }
        ClanAPI.clanRequest(method: .POST, parameters: parameter, bunissUrl: "/api/activity/submit", success: { (task, any) in
            
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
            
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "", message: "", isOk: false, isError: true))
        }
    }
    
    //MARK:同宗活动列表
    /// 同宗活动列表
    ///
    /// - Parameter result:
    public class func requestForActivityList(pagenum : Int,pagesize : Int,result:@escaping ResultHandle) -> Void{
        var parameter : [String : Any]
        parameter = ["pagenum":pagenum,
                     "pagesize":pagesize]
        print("请求同宗活动列表")
        ClanAPI.clanRequest(method: .GET, parameters: parameter, bunissUrl: "/api/activity", success: { (task, any) in
            
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "", message: "", isOk: false, isError: true))
        }
    }
    
    //MARK:同宗活动详情
    /// 同宗活动详情
    ///
    /// - Parameter result:
    public class func requestForActivityInfo(actid : String, result:@escaping ResultHandle) -> Void{
        var parameter : [String : Any]
        parameter = ["actid":actid]
        
        ClanAPI.clanRequest(method: .GET, parameters: parameter, bunissUrl: "/api/activity/detail", success: { (task, any) in
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "", message: "", isOk: false, isError: true))
        }
    }
    
    //MARK: 活动报名
    ///活动报名
    public class func requestForactivitySignup(name:String,phone:String,actid:String?,claim:String?,result:@escaping ResultHandle) -> Void{
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        var par = [String:Any]()
        par["name"] = name
        par["phone"] = phone
        par["actid"] = actid
        par["claim"] = claim
        
        
        ClanAPI.clanRequest(method: .GET, parameters: par, bunissUrl: "/api/activity/signup", success: { (task, any) in
            
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "请求失败", isOk: false, isError: true))
            }
        }) { (task, error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    //MARK: 活动取消报名
    ///活动取消报名
    public class func requestForactivitycancelSignup(actid:String?,result:@escaping ResultHandle) -> Void{
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        var par = [String:Any]()
        par["actid"] = actid
        
        ClanAPI.clanRequest(method: .GET, parameters: par, bunissUrl: "/api/activity/cancelSignup", success: { (task, any) in
            
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "请求失败", isOk: false, isError: true))
            }
        }) { (task, error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    
    //MARK: - --------------企业秀--------------
    //MARK:发布企业秀
    /// 发布企业秀
    /// result
    /// - Parameter result:
    public class func requestForSubmitenterprise(title : String, context : Any, name : String, img : String ,  result:@escaping ResultHandle) -> Void{
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        var parameter : [String : Any]
        parameter = [:]
        
        parameter["title"] = title        //标题
        parameter["context"] = context    //内容
        parameter["img"] = img            //企业封面图
        parameter["name"] = name          //企业名称
        print(parameter)
        
        
        ClanAPI.clanRequest(method: .POST, parameters: parameter, bunissUrl: "/api/enterprise/submit", success: { (task, any) in
            
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
            
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "", message: "", isOk: false, isError: true))
        }
    }
    
    //MARK:企业秀列表
    /// 企业秀列表
    ///
    /// - Parameter result:
    public class func requestForEnterpriseList(pagenum : Int,pagesize : Int,result:@escaping ResultHandle) -> Void{
        var parameter : [String : Any]
        parameter = ["pagenum":pagenum,
                     "pagesize":pagesize]
        
        ClanAPI.clanRequest(method: .GET, parameters: parameter, bunissUrl: "/api/enterprise", success: { (task, any) in
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "", message: "", isOk: false, isError: true))
        }
    }
    
    
    //MARK:企业秀详情
    /// 企业秀详情
    ///
    /// - Parameter result:
    public class func requestForenterprise(id : String, result:@escaping ResultHandle) -> Void{
        var parameter : [String : Any]
        parameter = ["id":id]
        
        ClanAPI.clanRequest(method: .GET, parameters: parameter, bunissUrl: "/api/enterprise/detail", success: { (task, any) in
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "", message: "", isOk: false, isError: true))
        }
    }
    
    
    //MARK: - --------------评论--------------
    
    //MARK:评论列表
    /// 评论列表
    /// targettype: 1. 回复评论 ;2. 动态评论 ;3. 活动评论  4.姓氏名人 5. 姓氏源流  6.线下宗祠  7.企业秀
    /// - Parameter result:
    public class func requestForcommentList(pagenum : Int,pagesize : Int,targetid : String,targettype : String, result:@escaping ResultHandle) -> Void{
        
        var parameter : [String : Any]
        parameter = ["pagenum":pagenum,
                     "pagesize":pagesize,
                     "targetid" :targetid,
                     "targettype":targettype
        ]
        
        ClanAPI.clanRequest(method: .GET, parameters: parameter, bunissUrl: "/api/comment", success: { (task, any) in
            print(any)
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "", message: "", isOk: false, isError: true))
        }
    }
    
    //MARK:发表评论
    /// 发表评论
    ///
    /// - Parameter result:// 1.回复评论 ;2. 动态评论 ;3. 活动评论  4.姓氏名人 5.姓氏源流 6.线下宗祠 7.企业秀
    public class func requestForSubmitcomment(targetid : String, content : String, targettype : String, touserid : String?, parentid : String?, commentid:String? , result:@escaping ResultHandle) -> Void{
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        var parameter : [String : Any]
        parameter = [:]
        
        parameter["content"] = content      //评论内容
        parameter["targetid"] = targetid    //评论目标内容ID
        parameter["targettype"] = targettype// 1.回复评论 ;2. 动态评论 ;3. 活动评论
        parameter["touserid"] = touserid    //回复用户id
        parameter["parentid"] = parentid    //回复评论id (一级评论id)
        parameter["commentid"] = commentid  //回复评论id (回复哪个评论传哪个评论的id)

        ClanAPI.clanRequest(method: .POST, parameters: parameter, bunissUrl: "/api/comment/submit", success: { (task, any) in
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
            
        }) { (task,error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    //MARK: - --------------点赞--------------
    //MARK:点赞
    /// 点赞
    ///
    /// - Parameter result:// 1. 回复评论 ;2. 动态评论 ;3. 活动评论  4.姓氏名人 5. 姓氏源流  6.线下宗祠  7.企业秀
    public class func requestForSubmitpraise(targetid : String,  targettype : String , result:@escaping ResultHandle) -> Void{
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        var parameter : [String : Any]
        parameter = [:]
        
        parameter["targetid"] = targetid    //评论目标内容ID
        parameter["targettype"] = targettype//  1. 回复评论 ;2. 动态评论 ;3. 活动评论  4.姓氏名人 5. 姓氏源流  6.线下宗祠  7.企业秀
        
        ClanAPI.clanRequest(method: .POST, parameters: parameter, bunissUrl: "/api/praise/submit", success: { (task, any) in
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task,error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    //MARK:取消点赞
    /// 取消点赞
    ///
    /// - Parameter result:// 1.回复评论 ;2. 动态评论 ;3. 活动评论  4. 企业秀
    public class func requestForCancelpraise(targetid : String,  targettype : String , result:@escaping ResultHandle) -> Void{
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        var parameter : [String : Any]
        parameter = [:]
        
        parameter["targetid"] = targetid    //评论目标内容ID
        parameter["targettype"] = targettype// 1.评论 ;2. 动态 ;3. 活动  4. 企业秀
        
        ClanAPI.clanRequest(method: .POST, parameters: parameter, bunissUrl: "/api/praise/cancel", success: { (task, any) in
            
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
            
        }) { (task,error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    
    //MARK: - --------------收藏--------------
    //MARK:收藏
    /// 收藏
    ///
    /// - Parameter result:// 1.回复评论 ;2. 动态评论 ;3. 活动评论
    public class func requestForSubmitcollect(targetid : String,  targettype : String , result:@escaping ResultHandle) -> Void{
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        var parameter : [String : Any]
        parameter = [:]
        
        parameter["targetid"] = targetid    //评论目标内容ID
        parameter["targettype"] = targettype// 1.评论 ;2. 动态 ;3. 活动
        
        ClanAPI.clanRequest(method: .POST, parameters: parameter, bunissUrl: "/api/collect/submit", success: { (task, any) in
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task,error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    //MARK:取消收藏
    /// 取消收藏
    ///
    /// - Parameter result:
    public class func requestForCancelcollect(targetid : String,  targettype : String , result:@escaping ResultHandle) -> Void{
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        var parameter : [String : Any]
        parameter = [:]
        
        parameter["targetid"] = targetid
        parameter["targettype"] = targettype
        
        ClanAPI.clanRequest(method: .POST, parameters: parameter, bunissUrl: "/api/collect/cancel", success: { (task, any) in
            
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
            
        }) { (task,error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    //MARK:我的收藏列表
    /// 我的收藏列表
    ///
    /// - Parameter result:
    public class func requestForCollect(pagenum : Int,pagesize : Int,result:@escaping ResultHandle) -> Void{
        
        var parameter : [String : Any]
        parameter = ["pagenum":pagenum,
                     "pagesize":pagesize]
        
        ClanAPI.clanRequest(method: .GET, parameters: parameter, bunissUrl: "/api/collect", success: { (task, any) in
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "0", message: "请求失败", isOk: false, isError: true))
        }
    }
    
    //MARK: - --------------投诉--------------

    //MARK:投诉
    /// 投诉
    public class func requestForSubmitComplaint(type : String, content : String, imgs : String?, targetid : String?, groupid : String?, result:@escaping ResultHandle) -> Void{
        if ClanAPI.checkNetWork() == false{
            result(ClanAPIResult.initResult(status: "", message: "暂无网络", isOk: false, isError: true))
            return
        }
        var parameter : [String : Any]
        parameter = [:]
        
        parameter["content"] = content      //投诉内容
        parameter["type"] = type            //投诉类型 1.个人 2. 群
        parameter["imgs"] = imgs            //投诉图片
        
        
        if type == "1"{
            parameter["targetid"] = targetid    //投诉对象
        }else{
            parameter["groupid"] = groupid      //群id
        }
        
        ClanAPI.clanRequest(method: .POST, parameters: parameter, bunissUrl: "/api/complaint/_submit", success: { (task, any) in
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
            
        }) { (task,error) in
            result(ClanAPIResult.faileResult())
        }
    }
    
    //MARK: - --------------分享--------------
    
    //MARK:分享
    /// 分享
    /// sharetype: 分享类型 1. 动态, 2. 活动
    /// - Parameter result:
    public class func requestForshare(sharetype : String,targetid : String, result:@escaping ResultHandle) -> Void{
        var parameter : [String : Any]
        parameter = ["sharetype":sharetype,
                     "targetid":targetid,
        ]
        
        ClanAPI.clanRequest(method: .GET, parameters: parameter, bunissUrl: "/api/share", success: { (task, any) in
            
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "", message: "", isOk: false, isError: true))
        }
    }
    
    
    //MARK: - --------------聊天--------------
    
    //MARK:获取聊天室
    /// 获取聊天室
    public class func requestForchatroom(result:@escaping ResultHandle) -> Void{
        
        ClanAPI.clanRequest(method: .GET, parameters: nil, bunissUrl: "/api/chatroom/rooms", success: { (task, any) in
            
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "", message: "", isOk: false, isError: true))
        }
    }
    
    
    //MARK: - --------------寄思先祖--------------
    //MARK:寄思先祖列表
    /// 寄思先祖列表
    public class func requestForjsxz(name : String , pagenum : Int,pagesize : Int , result:@escaping ResultHandle) -> Void{
        
        ClanAPI.clanRequest(method: .GET, parameters: nil, bunissUrl: "/api/send_thanks/" + name , success: { (task, any) in
            
            if (any != nil) {
                let model = ClanAPIResult.mj_object(withKeyValues: any!)
                result(model!)
            }else{
                result(ClanAPIResult.initResult(status: "", message: "没有数据", isOk: false, isError: true))
            }
        }) { (task,error) in
            result(ClanAPIResult.initResult(status: "", message: "", isOk: false, isError: true))
        }
    }
    
}



/// 接口请求结果模型
@objc class ClanAPIResult: NSObject {
    
    /// 数据
    var data : Any?
    /// 是否错误
    var isError : NSNumber! = NSNumber.init(value: true)
    /// 接口是否错误 0接口错误 1接口正确，但请求结果不一定正确 isOk不能作为结果结果正确与否的判断
    var isOk : NSNumber! = NSNumber.init(value: false)
    /// 信息
    var message : String! = ""
    /// 版本号 可能是资源版本或者app本身的版本
    var version : String! = ""
    
    //200成功 300业务异常 301数据为空 302数据已存在 303验证码错误 304验证码无效 305参数错误 309无姓氏 400请求失败 401用户未登录 500服务器错误
    /// 状态
    var status : String! = ""
    
    /// 其他数据，视情况而定
    var other : Any?
    
    override init() {
        super.init()
    }
    class func initResult(status:String = "0",message:String="",isOk:Bool = false,isError:Bool = true,_ data:Any? = nil) ->ClanAPIResult{
        let result = ClanAPIResult.init()
        result.status = status
        result.isError = NSNumber.init(value: isError)
        result.isError = NSNumber.init(value: isOk)
        result.message = message
        result.data = data
        return result;
    }
    class func faileResult() -> ClanAPIResult{
        return ClanAPIResult.initResult(status: "0", message: "网络加载失败", isOk: false, isError: true, nil);
    }
    class func noNectWorkResult() -> ClanAPIResult{
        return ClanAPIResult.initResult(status: "0", message: "暂无网络", isOk: false, isError: true, nil);
    }
    class func successResult(response:Any?) -> ClanAPIResult{
        if (response != nil) {
            let model = ClanAPIResult.mj_object(withKeyValues: response!)
            return (model!)
        }else{
            return ClanAPIResult.initResult(status: "0", message: "没有数据", isOk: false, isError: true)
        }
    }
    
    
}

