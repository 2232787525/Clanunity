//
//  ColorExtension.swift
//  Clanunity
//
//  Created by wangyadong on 2018/1/30.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

import Foundation

extension UIColor{
    
    //MARK: - 颜色设置方法

    /// 色值
    ///
    /// - Parameter hex:色值 0Xffffff 或 #000000
    /// - Returns: 颜色
    class func color(hexString hex:String) -> UIColor{
        return UIColor.color(hexString: hex, alpha: 1);
    }
    class func color(hexString hex:String,alpha:CGFloat = 1) -> UIColor {
        var cString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        if cString.count < 6 {
            return UIColor.clear
        }
        if cString.hasPrefix("0X") {
            cString = String(cString[String.Index.init(encodedOffset: 2)...])
        }
        
        if cString.hasPrefix("#") {
            cString = String(cString[String.Index.init(encodedOffset: 1)...])
        }
        if cString.count != 6 {
            return UIColor.clear
        }
        let rString = String(cString[String.Index.init(encodedOffset: 0)..<String.Index.init(encodedOffset: 2)])
        let gString = String(cString[String.Index.init(encodedOffset: 2)..<String.Index.init(encodedOffset: 4)])
        let bString = String(cString[String.Index.init(encodedOffset: 4)..<String.Index.init(encodedOffset: 6)])
        var r : CUnsignedInt = 0,g : CUnsignedInt = 0,b : CUnsignedInt = 0;

        Scanner.init(string: rString!).scanHexInt32(&r)
        Scanner.init(string: gString!).scanHexInt32(&g)
        Scanner.init(string: bString!).scanHexInt32(&b)
        return UIColor.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: alpha)
    }
    
    class func color(hexVale:Int,alpha:CGFloat = 1) -> UIColor {
        return UIColor.init(red: CGFloat((hexVale & 0xFF0000) >> 16)/255.0,
                            green: CGFloat((hexVale & 0xff00) >> 8)/255.0,
                            blue: CGFloat(hexVale & 0xff)/255.0,
                            alpha: alpha)
    }
    
    /// 色值颜色
    ///
    /// - Parameter hexVale: 色值
    /// - Returns: 颜色
    class func color(hexVale:Int) -> UIColor {
        return UIColor.init(red: CGFloat((hexVale & 0xFF0000) >> 16)/255.0,
                            green: CGFloat((hexVale & 0xff00) >> 8)/255.0,
                            blue: CGFloat(hexVale & 0xff)/255.0,
                            alpha: 1.0)
    }
    
    //MARK: - 项目色值设置
    /**
     灰色背景
     */
    class var bgGreyColor : UIColor{
        return UIColor.color(hexString: "#f5f5f5")
    }
    
    /**
     分割线的颜色
     */
    class var cutLineColor : UIColor{
        return UIColor.color(hexString: "#DFDFDF")
    }
    
    /// 基础色 棕色系 D1A971
    class var baseColor : UIColor{
        return UIColor.color(hexString: "#D1A971")
    }
    
    /// 基础色 棕色系 8D5506
    class var baseColor2 : UIColor{
        return UIColor.color(hexString: "#8D5506")
    }
    
    /// 背景颜色1 ffffff
    class var bgColor : UIColor{
        return UIColor.color(hexString: "#ffffff")
    }
    
    /// 背景颜色2 eeeeee
    class var bgColor2: UIColor {
        return UIColor.color(hexString: "#eeeeee")
    }
    
    
    
    /// 背景颜色3 d9d9d9
    class var bgColor3: UIColor {
        return UIColor.color(hexString: "#d9d9d9")
    }
    
    /// 背景颜色4 f3f3f3
    class var bgColor4: UIColor {
        return UIColor.color(hexString: "#f3f3f3")
    }
    
    /// 背景颜色5 f5f5f5
    class var bgColor5: UIColor {
        return UIColor.color(hexString: "#f5f5f5")
    }
    
    /// 主题色值
    class var theme: UIColor {
        return UIColor.color(hexString: "#D1A971")
    }
    
    /// 分割线颜色9E825E
    class var lineColor1: UIColor {
        return UIColor.color(hexString: "#9E825E")
    }
    
    
    /// 分割线颜色A58559
    class var lineColor3: UIColor {
        return UIColor.color(hexString: "#A58559")
    }
    
    /// 线条颜色535353
    class var lineColor4: UIColor {
        return UIColor.color(hexString: "#535353")
    }
    
    
    /// 文字色值333333
    class var textColor1: UIColor {
        return UIColor.color(hexString: "#333333")
    }
    /// 文字色值666666
    class var textColor2: UIColor {
        return UIColor.color(hexString: "#666666")
    }
    ///文字色值999999
    class var textColor3: UIColor {
        return UIColor.color(hexString: "#999999")
    }
    ///文字色值dfdfdf
    class var textColor4: UIColor {
        return UIColor.color(hexString: "#dfdfdf")
    }
    ///文字色值727CB9
    class var textColor5: UIColor {
        return UIColor.color(hexString: "#727CB9")
    }
    
    
}




import UIKit

struct Theme {
    static var ThemeBlue : UIColor = UIColor.baseColor
}
