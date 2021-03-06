//
//  NetworkService.swift
//  Clanunity
//
//  Created by wangyadong on 2018/1/30.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

import UIKit
import AFNetworking


typealias SuccessfulHandle = ((_ task: URLSessionDataTask, _ responseAny:Any?) -> Void)
typealias FailedHandle = ((_ task: URLSessionDataTask?, _ error:Error) -> Void)

typealias ProgressHandle = ((_ downloadProgress: Progress) -> Void)

typealias ResultHandle = ((_ result: ClanAPIResult) -> Void)




/// 上传文件类型
///
/// - IMG: 图片
/// - VIDEP: 视频
/// - AMR: 语音
enum UpdateFileMimeType : String{
    case IMG = "image/jpeg"
    case VIDEP = "video/quicktime"
    case AMR = "amr"
}



class NetworkService: NSObject {
    
    static let shareService : NetworkService = {
        let service = NetworkService();
        service.sessionManager.securityPolicy = service.configSecurityPolicy(manager: service.sessionManager)
        return service;
    }()
    
    lazy var sessionManager : AFHTTPSessionManager = {
        let manager = AFHTTPSessionManager.init()
        manager.requestSerializer.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        manager.requestSerializer.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
       
        let sysVerson = DeviceConfig.systemVersion
        var phoneModel = DeviceConfig.iphoneModel
        
        let userAgent = DeviceConfig.appDisplayName + " " + DeviceConfig.appVersion + " " + "(ios/" + sysVerson + " " + phoneModel + ")"

        manager.requestSerializer.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        manager.requestSerializer.timeoutInterval = 8.0
        manager.responseSerializer = AFJSONResponseSerializer.init(readingOptions: JSONSerialization.ReadingOptions.init(rawValue: 0))
        manager.responseSerializer.acceptableContentTypes = NSSet.init(objects: "text/html","application/json","text/json","text/javascript") as? Set<String>
        
        return manager
    }()
    func configSecurityPolicy(manager:AFHTTPSessionManager) -> AFSecurityPolicy {
        let cerPath = Bundle.main.path(forResource: "server", ofType: "cer")
        var cerData : NSData?
        if cerPath != nil{
            cerData = NSData.init(contentsOfFile: cerPath!)
        }
        var cerSet : NSSet?
        if cerData != nil{
            cerSet = NSSet.init(objects: cerData ?? NSData())
        }
        let securityPolicy = AFSecurityPolicy.init(pinningMode: AFSSLPinningMode.certificate)
        //客户端是否信任非法证书
        securityPolicy.allowInvalidCertificates = true
        //是否在证书域字段中验证域名
        securityPolicy.validatesDomainName = false
        if cerSet != nil{
            securityPolicy.pinnedCertificates = cerSet as? Set<Data>
        }
        return securityPolicy;
    }
    public func POST_request(parameters:Dictionary<String,Any>?,url:String,success:@escaping SuccessfulHandle,faile:@escaping FailedHandle ) -> Void{
        
        self.registerRequestHeader();
        self.sessionManager.post(url, parameters: parameters, progress: { (down:Progress) in
        }, success: { (task : URLSessionDataTask, responseAny : Any?) in
            success(task,responseAny)
        }) { (task : URLSessionDataTask?, error : Error) in
            faile(task,error)
        }
    
    }
    
   
    public func POST_UpdateFile(parameters:Dictionary<String,Any>?,url:String,files:Array<Data>,mimeType:UpdateFileMimeType,progress:@escaping ProgressHandle,success:@escaping SuccessfulHandle,faile:@escaping FailedHandle) -> Void{
        
        self.registerRequestHeader();
        self.sessionManager.post(url, parameters:parameters , constructingBodyWith: { (formData:AFMultipartFormData) in
            
            for (index,temp) in files.enumerated(){
                
                if mimeType == UpdateFileMimeType.IMG{
                    formData.appendPart(withFileData: temp, name: "imagefile", fileName: ("imagefile"+String(index)+".jpg"), mimeType: "image/jpeg")
                }else if mimeType == UpdateFileMimeType.VIDEP{
                    
                    formData.appendPart(withFileData: temp, name: "videofile", fileName: "videofile"+String(index)+".MP4", mimeType: "video/quicktime")
                }else{
                    formData.appendPart(withFileData: temp, name: "amrfile", fileName: "amrfile"+String(index)+".amr", mimeType: "amr")
                }

            }
    
        }, progress: { (uploadProgress:Progress) in
            progress(uploadProgress)
        }, success: { (task : URLSessionDataTask, responseAny : Any?) in
            success(task,responseAny)
        }) { (task : URLSessionDataTask?, error : Error) in
            faile(task,error)
        }
    }
    public func GET_request(parameters : Dictionary<String,Any>?,
                            businessURL url:String,
                            successBlock success:@escaping SuccessfulHandle,
                            failureBlock faile:@escaping FailedHandle) -> Void {
        self.registerRequestHeader()
        //连接
        var urlString = ""
        urlString = url+"?"+self.configureGETParameters(dic: parameters)

        let unsafeP=urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet(charactersIn:"`#%^{}\"[]|\\<> ").inverted)

        self.sessionManager.get(unsafeP!, parameters: nil, progress: { (down:Progress) in
        }, success: { (task : URLSessionDataTask, responseAny : Any?) in
            success(task,responseAny);
        }) { (task : URLSessionDataTask?, error : Error) in
            faile(task,error);
        }
        
    }
    
    func configureGETParameters(dic:Dictionary<String,Any>?) -> String {
        //解析 公共参数
        var urlParString = String()
        for item in self.configureCommonParamaters() {
            urlParString = urlParString + "\(item.key)=\(item.value)" + "&"
        }
        if dic != nil {
            for item in dic!{
                urlParString = urlParString + "\(item.key)=\(item.value)" + "&"
            }
        }
        if urlParString[urlParString.index(before: urlParString.endIndex)] == "&" {
            urlParString.remove(at: urlParString.index(before: urlParString.endIndex))
        }
        return urlParString;
    }
    
    
    public func registerRequestHeader() -> Void {
        let common = self.configureCommonParamaters();
        var commonJson = ""
        
        if JSONSerialization.isValidJSONObject(common) == true{
            let jsonData : Data = try! JSONSerialization.data(withJSONObject: common, options: [])
            commonJson = String.init(data: jsonData as Data, encoding: .utf8)!
        }
        self.sessionManager.requestSerializer.setValue(commonJson, forHTTPHeaderField: "API-Common");
        self.sessionManager.requestSerializer.setValue(ClanServer.token, forHTTPHeaderField: "API-Token")
    }
    
    // MARK: - 配置公共参数
    private func configureCommonParamaters() -> Dictionary<String,Any>{
        
        //设备品牌
        let d_brand_deviceBrand = DeviceConfig.model
        //设备编号
        var d_code_deviceIdentifier = DeviceConfig.deviceID
        //设备型号
        let d_model_deviceModel = DeviceConfig.iphoneModel
        
        //设备版本号平台及版本
        let d_platform_deviceVersion = DeviceConfig.systemVersion
        //APP 版本号
        var v_code_AppVersion = ""
        if Bundle.main.infoDictionary?["CFBundleShortVersionString"] != nil {
            v_code_AppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        }
        
        if d_code_deviceIdentifier == nil && d_model_deviceModel == "Simulator" {
            d_code_deviceIdentifier = "BE17FAD0-10086-42F6-9A9F-1109A871F48A"
        }
        
        let nc_netStatus = DeviceConfigure.networkingStates()
        
        let cmpmsDic : Dictionary<String,Any> =  ["iiod" : 1,
                                                  "d_brand" : d_brand_deviceBrand,
                                                  "d_platform" : d_platform_deviceVersion,
                                                  "d_model" : d_model_deviceModel,
                                                  "d_code" : d_code_deviceIdentifier ?? String(),
                                                  "v_code" : v_code_AppVersion,
                                                  "nc" : nc_netStatus ?? "" ,
                                                  "API-Token" : ClanServer.token
        ]
        return cmpmsDic
    }
}
