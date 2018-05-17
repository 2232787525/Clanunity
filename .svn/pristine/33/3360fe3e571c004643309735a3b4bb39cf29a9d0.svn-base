//
//  DataTypeExtension.swift
//  Clanunity
//
//  Created by wangyadong on 2018/2/27.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//


/// 时间日期格式
///
/// - YMD: yyyy-MM-dd
/// - Y_M_D: yyyy/M/d
/// - YMD_Chinese: yyyy年M月d日
/// - HHmm: HH:mm
/// - Md_HM: MM.dd HH:mm
/// - MD_HM: MM-dd HH:mm
/// - YMDHM: yyyy-MM-dd HH:mm
/// - YMDHMS: yyyy.MM.dd HH:mm:ss
/// - YMDHM_Chinese: yyyy年M月d日 H:mm
/// - YMD_Point: yyyy.M.d
/// - MD: MM-dd
enum TimeFormatter : String {
    
    case YMD = "yyyy-MM-dd"
    case Y_M_D = "yyyy/M/d"
    case YMD_Chinese = "yyyy年M月d日"
    case HHmm = "HH:mm"
    case Md_HM = "MM.dd HH:mm"
    case MD_HM = "MM-dd HH:mm"
    case YMDHM = "yyyy-MM-dd HH:mm"
    case YMDHMS = "yyyy.MM.dd HH:mm:ss"
    case YMDHM_Chinese = "yyyy年M月d日 H:mm"
    case YMD_Point = "yyyy.M.d"
    case MD = "MM-dd"
    
}


// MARK: - 数据类型的扩展
import Foundation


extension String{
    
    /// 去除空格
    var trim : String{
        get{
            let temp = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines);
            return temp.trimmingCharacters(in: CharacterSet.whitespaces)
        }set{}
    }
    
    /// 13位时间戳
    ///
    /// - Returns: 时间戳字符串
    static func timestamp() -> String {
        let nowDate = Date.init(timeIntervalSinceNow: TimeInterval.init(0))
        let interval = nowDate.timeIntervalSince1970 * 1000
        let stamp = String.init(format: "%.f", interval)
        return stamp
    }
    
    /// 时间戳转时间显示
    ///
    /// - Parameter formater: 类型
    /// - Returns: 显示时间
    func timeFormater(_ formater:TimeFormatter) -> String{
        if Int(self) == nil {
            return self
        }
        let interval = Int(self)!/1000
        let date = Date.init(timeIntervalSince1970: TimeInterval(interval))
        let dateformat = DateFormatter.init()
        dateformat.dateFormat = formater.rawValue
        return dateformat.string(from: date)
    }
    
    /// yyyy-MM-dd
    var timestampYMD : String{
        get{
            return self.timeFormater(.YMD)
        }set{}
    }
    /// yyyy/M/d
    var timestampY_M_D : String{
        get{
            return self.timeFormater(.Y_M_D)
        }set{}
    }
    /// MM-dd
    var timestampMD : String{
        get{
            return self.timeFormater(.MD)
        }set{}
    }
    
    /// MM.dd HH:mm
    var timestampMd_HM : String{
        get{
            return self.timeFormater(.Md_HM)
        }set{}
    }
    /// MM-dd HH:mm
    var timestampMD_HM : String{
        get{
            return self.timeFormater(.MD_HM)
        }set{}
    }
    
    /// yyyy年M月d日
    var timestampYMD_Chinese : String{
        get{
            return self.timeFormater(.YMD_Chinese)
        }set{}
    }
    /// yyyy年M月d日
    var timestampHHmm : String{
        get{
            return self.timeFormater(.HHmm)
        }set{}
    }
    /// yyyy-MM-dd HH:mm
    var timestampYMDHM : String{
        get{
            return self.timeFormater(.YMDHM)
        }set{}
    }
    /// yyyy.MM.dd HH:mm:ss
    var timestampYMDHMS : String{
        get{
            return self.timeFormater(.YMDHMS)
        }set{}
    }
    /// yyyy.M.d
    var timestampYMD_Point : String{
        get{
            return self.timeFormater(.YMD_Point)
        }set{}
    }
   
    /// 从String中截取出参数
    var urlParameters: [String: AnyObject]? {
        // 截取是否有参数
        guard let urlComponents = NSURLComponents(string: self), let queryItems = urlComponents.queryItems else {
            return nil
        }
        // 参数字典
        var parameters = [String: AnyObject]()
        
        // 遍历参数
        queryItems.forEach({ (item) in
            
            // 判断参数是否是数组
            if let existValue = parameters[item.name], let value = item.value {
                // 已存在的值，生成数组
                if var existValue = existValue as? [String] {
                    
                    existValue.append(value)
                } else {
//                    parameters[item.name] = [existValue, value]
                }
                
            } else {
                
                parameters[item.name] = item.value as AnyObject
            }
        })
        
        return parameters
    }
    
    static func getImageSize(urlStr : String) ->  (ImgSizeModel?) {
        let arr = urlStr.components(separatedBy: "_")
        if arr.count <= 1{
            return nil
        }
        let str2 = arr.last
        
        let arr2 = str2?.components(separatedBy: "X")
        
        if arr2?.count == 2{
            let model = ImgSizeModel.init()
            model.width = CGFloat(Double(arr2?.first ?? "0")!)
            
            if arr2?.last?.count ?? 0 > 0 {
                let str = (arr2?.last)!
                let arr3 = str.components(separatedBy: ".")
                model.heigh = CGFloat(Double(arr3.first ?? "0")!)
            }
            return model
        }
        return nil
    }

}

extension NSString{
    
    /// 剔除字符串
    var trim : NSString{
        get{
            let selfStr  = String.init(self)
           return NSString.init(string: selfStr);
        }set{}
    }
    
    
    /// 13位时间戳字符串
    ///
    /// - Returns: 字符串
    class func timestamp() -> String {
        let nowDate = Date.init(timeIntervalSinceNow: TimeInterval.init(0))
        let interval = nowDate.timeIntervalSince1970 * 1000
        let stamp = String.init(format: "%.f", interval)
        return stamp
    }
    /// yyyy-MM-dd
    var timestampYMD : String{
        get{
            let selfStr = String.init(self)
            return selfStr.timestampYMD
        }set{}
    }
 
}


extension NSArray{
    
    /// 充满，图片正常显示多出部分切割
    class func cdi_imagesWithGif(gifNameInBoundle : String) -> (NSMutableArray) {
        
        let fileUrl = Bundle.main.url(forResource: gifNameInBoundle, withExtension: "gif")
        
        let gifSource = CGImageSourceCreateWithURL(fileUrl! as CFURL, nil)
        
        
        
        let gifCount = CGImageSourceGetCount(gifSource!)
        
        let frames = NSMutableArray.init(capacity: 0)
        
        for i in 0...gifCount - 1{
            let imageRef = CGImageSourceCreateImageAtIndex(gifSource!, i, nil)
            let image = UIImage.init(cgImage: imageRef!)
            if i%2 == 0{
                frames.add(image)
            }
        }
        return frames
    }
}

