//
//  KButton.swift
//  Clanunity
//
//  Created by bex on 2018/2/3.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

import UIKit

class KButton: UIButton {

    var attribute : Any?
    var mengban : UIView?
    var uploadfail : UIButton? //上传失败 重新上传按钮
    var littleFrame = CGRect.init()

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    init(frame: CGRect ,needMengban: Bool) {
        super.init(frame: frame)
        self.imageView?.contentMode = .scaleAspectFill
        
        if needMengban{
            let mengban = UIView.init(frame: CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height))
            mengban.backgroundColor = UIColor.black
            mengban.alpha = 0.8
            mengban.isUserInteractionEnabled = false
            self.addSubview(mengban)
            self.mengban = mengban
        }
        
        uploadfail = UIButton.init(frame: CGRect.init(x: frame.width/4, y: frame.width/4, width: frame.width/2, height: frame.height/2))
        uploadfail?.backgroundColor = UIColor.black
        uploadfail?.alpha = 0.8
        uploadfail?.setImage(UIImage.init(named: "report"), for: .normal)
        uploadfail?.isUserInteractionEnabled = true
        uploadfail?.isHidden = true
        self.addSubview(uploadfail!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

