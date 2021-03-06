//
//  KView.swift
//  Clanunity
//
//  Created by bex on 2018/2/7.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

import UIKit

class KView: NSObject {

}


//MARK: - 上边图片 下边文字
class ImgAndLabView: UIView {
    var ImgView = UIImageView()
    var titleLab = UILabel()
    var btn = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        var img_W = frame.size.width > frame.size.height ? (frame.size.height-20-10) :  (frame.size.width-20-10);
        
        if (img_W>F_I6(place: 40)) {
            img_W = F_I6(place: 40)
        }else{
        }
        
        let btwToTop = (frame.size.height-img_W-20-5)/2
        self.backgroundColor = UIColor.clear
        //左图
        let ImgView = UIImageView.init(frame: CGRect.init(x: 12, y: btwToTop, width: img_W, height: img_W))
        self.addSubview(ImgView)
        self.ImgView = ImgView
        
        let titleLab = UILabel.init(frame: CGRect.init(x: 0, y: self.ImgView.bottom_sd + 5, width: frame.size.width, height: 20))
        titleLab.font = UIFont.systemFont(ofSize: 15)
        titleLab.textColor = UIColor.textColor1
        titleLab.textAlignment = .center
        self.addSubview(titleLab)
        self.titleLab = titleLab
        self.ImgView.centerX_sd = frame.size.width/2;
        
        btn = UIButton.init(frame: frame)
        self.addSubview(btn)
        btn.left_sd = 0
        btn.top_sd = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
