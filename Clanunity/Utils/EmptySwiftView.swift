//
//  EmptySwiftView.swift
//  PalmLive
//
//  Created by wangyadong on 2017/9/14.
//  Copyright © 2017年 zfy_srf. All rights reserved.
//

import UIKit

class EmptySwiftView: UIView {

   
    
    /// 空太图view
    ///
    /// - Parameters:
    ///   - emptyPicName: 图片的名字，传空就是默认的weijiaru
    ///   - describe: 图片下面的文字描述
    /// - Returns: 空太图
    class func showEmptyView(emptyPicName:String?,describe:String?) -> EmptySwiftView {
        let  empty = EmptySwiftView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100), describe: describe, picName: emptyPicName)
        return empty
    }
    
    private var describe : String?
//    private var picName =  String()
    
    var picName = String(){
        didSet {
            let img = UIImage.init(named: self.picName)
            imgView?.image = img
            imgView?.width_sd = kScreenScale * (img?.size.width)!
            imgView?.height_sd =  kScreenScale * (img?.size.height)!
            imgView?.centerX_sd = (describeLabel?.centerX_sd)!
            describeLabel?.top_sd = (imgView?.bottom_sd ?? 0) + 15
            self.height_sd = (describeLabel?.bottom_sd)! + 20
        }
    }
    
    
    var describeLabel : UILabel?
    var imgView : UIImageView?

    private init(frame: CGRect,describe:String?,picName:String?) {
        super.init(frame: frame)
        
        if describe != nil {
            self.describe = describe
        }
        if picName == nil {
            self.picName = "empty1"
        }else{
            self.picName = picName!
        }
        
        imgView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100));
        let img = UIImage.init(named: self.picName)
        imgView?.image = img
        imgView?.width_sd = kScreenScale * (img?.size.width)!
        imgView?.height_sd =  kScreenScale * (img?.size.height)!
        self.addSubview(imgView!)
        self.height_sd = (imgView?.bottom_sd)!
        self.width_sd = (imgView?.width_sd)!
        if self.describe != nil {
            let desLb = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth*0.8, height: 100))
            desLb.text = describe
            desLb.font = UIFont.systemFont(ofSize: 15)
            desLb.textColor = UIColor.textColor1
            desLb.textAlignment = .center
            desLb.numberOfLines = 0
            let h = PLGlobalClass.size(withText: desLb.text, font: desLb.font, width: (desLb.width_sd), height: CGFloat(MAXFLOAT)).height
            desLb.height_sd = h
            desLb.top_sd = (imgView?.bottom_sd ?? 0) + 15
            self.addSubview(desLb)
            self.height_sd = (desLb.bottom_sd) + 20
            self.width_sd = (desLb.width_sd)
            desLb.centerX_sd = self.width_sd/2.0
            if self.describeLabel == nil {
                self.describeLabel = desLb
            }
            
        }
        imgView?.centerX_sd = self.width_sd/2.0

    }
    
    public func describetextColor(color:UIColor?) -> Void{
    
        if self.describeLabel != nil && color != nil{
            self.describeLabel?.textColor = color
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
 

}
