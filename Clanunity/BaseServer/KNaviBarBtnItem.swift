//
//  KNaviBarBtnItem.swift
//  Clanunity
//
//  Created by wangyadong on 2018/1/29.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

import UIKit

@objc enum KNaviBarBtnItemStyle : Int{
    
    case Done = 0
    case Plain = 1
    case Right = 2
    case Left = 3
    case Bordered = 4
}
typealias ActiobBlock = (((_ sender:Any) -> Void)?)

class KNaviBarBtnItem: UIView {

    var button : UIButton = UIButton()
    private var actionBlock : ActiobBlock
    
    var enabled : Bool  = true{
        willSet{
            if newValue {
                self.isUserInteractionEnabled = true
                self.alpha = 1.0
            }else{
                self.isUserInteractionEnabled = false
                self.alpha = 0.3;
            }
        }
    };
    
    init(frame : CGRect , title : String!,hander:(((_ sender:Any) -> Void)?)) {
        super.init(frame : frame)
        let button = UIButton.init(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.setTitleColor(UIColor.white, for: .normal)
        button.bounds = self.bounds
        button.left_sd = 0
        button.top_sd = 0
        self.button = button
        self.addSubview(button)
        self.actionBlock = hander
        
        button.addTarget(self, action: #selector(handleTouchUp(sender:)), for: .touchCancel)
        button.addTarget(self, action: #selector(handleTouchUp(sender:)), for: .touchUpOutside)
        button.addTarget(self, action: #selector(handleTouchUp(sender:)), for: .touchDragOutside)
        button.addTarget(self, action: #selector(handleTouchUpInside(sender:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(handleTouchDown(sender:)), for: .touchDown)
        
        
    }
    init(frame : CGRect , image : String,hander:(((_ sender:Any) -> Void)?)) {
        super.init(frame : frame)
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage.init(named: image), for: .normal)
        button.setImage(UIImage.init(named: image), for: .highlighted)
        button.sizeToFit()
        button.bounds = self.bounds
        button.left_sd = 0
        button.top_sd = 0
        self.button = button
        self.addSubview(button)
        self.actionBlock = hander
        button.addTarget(self, action: #selector(handleTouchUp(sender:)), for: .touchCancel)
        button.addTarget(self, action: #selector(handleTouchUp(sender:)), for: .touchUpOutside)
        button.addTarget(self, action: #selector(handleTouchUp(sender:)), for: .touchDragOutside)
        button.addTarget(self, action: #selector(handleTouchUpInside(sender:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(handleTouchDown(sender:)), for: .touchDown)
    }
    func handleTouchDown(sender:UIButton) -> Void {
        sender.alpha = 0.3;
    }
    func handleTouchUp(sender:UIButton) -> Void {
        UIView.animate(withDuration: 0.25) {
            sender.alpha = 1.0;
        }
    }
    func handleTouchUpInside(sender:UIButton) -> Void {
        
        if self.actionBlock != nil {
            self.actionBlock!(sender)
        }
        UIView.animate(withDuration: 0.25) {
            sender.alpha = 1.0;
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
