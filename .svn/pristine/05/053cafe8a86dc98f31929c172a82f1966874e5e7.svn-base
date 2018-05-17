//
//  KNavigationBar.swift
//  Clanunity
//
//  Created by wangyadong on 2018/1/29.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

import UIKit

class KNavigationBar: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
   
    private var cutLine : UIImageView!
    private var titleLab : UILabel!
    
    /// 左按钮 默认left_sd = 0;可自行调整
    var leftBarBtnItem : KNaviBarBtnItem?{
        willSet{
            if self.leftBarBtnItem != nil {
                self.leftBarBtnItem?.removeFromSuperview();
                self.leftBarBtnItem = nil;
            }
            if newValue != nil {
                newValue?.left_sd = 0;
                newValue?.bottom_sd = self.height_sd;
                self.addSubview(newValue!)
            }
        }
    }
    
    /// 右按钮 默认按钮的右边跟屏幕右边对齐right_sd = KScreenWidth;
    var rightBarBtnItem : KNaviBarBtnItem?{
        willSet{
            if self.rightBarBtnItem != nil {
                self.rightBarBtnItem?.removeFromSuperview();
                self.rightBarBtnItem = nil;
            }
            if newValue != nil {
                newValue?.right_sd = KScreenWidth;
                newValue?.bottom_sd = self.height_sd;
                self.addSubview(newValue!)
            }
        }
    }
    
    var title : String?{
        willSet{
            self.titleLab.isHidden = false
            self.titleLab.text = newValue
            self.titleView?.isHidden = true
        }
    }
    
    var titleView : UIView?{
        willSet {
            if self.titleView != nil {
                self.titleView?.isHidden = false
                self.titleView?.removeFromSuperview()
            }
            self.titleLab.isHidden = true
            self.addSubview(newValue!)
            newValue?.centerX_sd = self.centerX_sd
            newValue?.centerY_sd = KStatusBarHeight + 22
        }
    }
    
    var titleColor : UIColor?{
        willSet {
            self.titleLab.textColor = newValue
        }
        
    }
    
    public var cutlineColor : UIColor = UIColor.lineColor1{
        willSet{
            self.cutLine.backgroundColor = newValue;
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tintColor = UIColor.white;
        
        //let image = UIImage.init(named: "navigation_BG")
        //self.layer.contents = image?.cgImage
        self.backgroundColor = UIColor.baseColor
        
        self.cutLine = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: self.width_sd, height: 0.5));
        self.cutLine.bottom_sd = self.height_sd;
        self.cutLine.backgroundColor = UIColor.clear
        self.addSubview(self.cutLine)
        
        titleLab = UILabel.init(frame: CGRect.init(x: 44, y: KStatusBarHeight, width: self.width_sd-88, height: 44))
        titleLab?.font = UIFont.boldSystemFont(ofSize: 17)
        titleLab?.textAlignment = .center
        titleLab?.textColor = UIColor.white
        titleLab?.lineBreakMode = NSLineBreakMode.byTruncatingMiddle
        titleLab.adjustsFontSizeToFitWidth = true
        self.addSubview(titleLab!)
    }
    convenience init() {
        self.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: KTopHeight))
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
