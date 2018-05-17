//
//  DeviceConfig.swift
//  Clanunity
//
//  Created by wangyadong on 2018/1/30.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

//MARK:设备配置相关的东西，基本在这个类中，如果有部分不可用swift的可以在DeviceConfigure中添加
import UIKit

class DeviceConfig: NSObject {

    
    /// 设备id，uuid
    class var deviceID : String? {
        
        let user = UserDefaults.standard
        let uuid = user.object(forKey: "Device_UUID");
        if uuid == nil{
            let keychain = DeviceKeychain.getIDFV()
            user.set(keychain, forKey: "Device_UUID");
            user.synchronize()
            return keychain
        }
        return (uuid is String) == true ? (uuid as! String) : nil
    }
    
    /// app中文名
    class var appDisplayName : String {
        var appName = ""
        if Bundle.main.infoDictionary?["CFBundleDisplayName"] != nil{
            appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as! String
        }
        return appName
    }
    
    /// app版本号
    class var appVersion : String {
        var appV = ""
        if Bundle.main.infoDictionary?["CFBundleShortVersionString"] != nil{
            appV = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        }
        return appV
    }
    
    /// 系统版本
    class var systemVersion : String {
        return UIDevice.current.systemVersion
    }

    
    /// iphone型号，iphone4，5，6，7，8
    class var iphoneModel : String {
        var phoneModel = ""
        if IPhoneDevice()?.rawValue != nil {
            phoneModel = (IPhoneDevice()?.rawValue)!
        }
        return phoneModel;
    }
    
    /// 设备型号，iphone，ipad，iTouch
    class var model:String {
        return UIDevice.current.model;
    }
    
    
    
}
