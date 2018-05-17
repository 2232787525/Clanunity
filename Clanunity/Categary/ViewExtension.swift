//
//  ViewExtension.swift
//  Clanunity
//
//  Created by wangyadong on 2018/1/29.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

import UIKit

// MARK: - View的类别扩展
extension UIView {
    
    /**
     视图坐标
     */
    var origion_sd : CGPoint{
        get{
            return self.frame.origin;
        }set{
            var newFrame = self.frame
            newFrame.origin = newValue;
            self.frame = newFrame;
        }
    }
    /**
     视图大小
     */
    var size_sd : CGSize{
        get{
            return self.frame.size;
        }set{
            var newFrame = self.frame
            newFrame.size = newValue;
            self.frame = newFrame;
        }
    }
    
    /**
     x坐标
     */
    var left_sd : CGFloat{
        get{
            return self.frame.origin.x
        }
        set{
            if newValue.isNaN {
                var tempFrame = self.frame;
                tempFrame.origin.x = 0.0;
                self.frame = tempFrame;
            }else{
                var tempFrame = self.frame;
                tempFrame.origin.x = newValue;
                self.frame = tempFrame;
            }
            
        }
    }
    /**
     y坐标
     */
    var top_sd : CGFloat{
        get{
            return self.frame.origin.y;
        }set{
            if top_sd.isNaN {
                var tempFrame = self.frame;
                tempFrame.origin.y = 0.0;
                self.frame = tempFrame;
            }else{
                var tempFrame = self.frame;
                tempFrame.origin.y = newValue;
                self.frame = tempFrame;
            }
        }
    }
    /**
     宽
     */
    var width_sd : CGFloat{
        get{
            return self.frame.size.width;
        }set{
            var tempFrame = self.frame;
            if newValue.isNaN {
                tempFrame.size.width = 0.0;
            }else{
                tempFrame.size.width = newValue
            }
            self.frame = tempFrame;
        }
    }
    /**
     高
     */
    var height_sd : CGFloat{
        get{
            return self.frame.size.height;
        }set{
            var tempFrame = self.frame;
            if newValue.isNaN {
                tempFrame.size.height = 0.0;
            }else{
                tempFrame.size.height = newValue
            }
            self.frame = tempFrame;
        }
    }
    
    var right_sd : CGFloat{
        get{
            return self.frame.origin.x + self.frame.size.width;
        }set{
            var tempFrame = self.frame;
            if newValue.isNaN {
                tempFrame.origin.x = 0.0 - tempFrame.size.width;
            }else{
                tempFrame.origin.x = newValue - tempFrame.size.width
            }
            self.frame = tempFrame;
        }
        
    }
    var bottom_sd : CGFloat{
        get{
            return self.frame.origin.y + self.frame.size.height;
        }set{
            var tempFrame = self.frame;
            if newValue.isNaN {
                tempFrame.origin.y = 0.0 - tempFrame.size.height;
            }else{
                tempFrame.origin.y = newValue - tempFrame.size.height
            }
            self.frame = tempFrame;
        }
    }
    var centerX_sd : CGFloat{
        get{
            return self.center.x;

        }set{
            var newCenter = self.center;
            newCenter.x = newValue;
            self.center = newCenter;
        }
    }
    
    var centerY_sd : CGFloat {
        get{
            return self.center.y;
        }
        set{
            var newCenter = self.center
            newCenter.y = newValue
            self.center = newCenter;
        }
    }
    
    func viewController() -> UIViewController? {
        var next = self.next
        while next != nil {
            if next is UIViewController{
                return (next as! UIViewController)
            }
            next = next?.next
        }
        return nil
    }
    
    
    func removeAllSubviews() -> Void {
        while self.subviews.count > 0 {
            let child = self.subviews.last
            if child is UIImageView{
                let childImg = child as! UIImageView
                childImg.image = nil
            }
            child?.removeFromSuperview()
        }
    }
    
    func addBottomLine(color : UIColor) -> (UIView) {
        let line = UIView.init(frame: CGRect.init(x: 0, y: self.height_sd-0.5, width: self.width_sd, height: 0.5))
        line.backgroundColor = color
        self.addSubview(line)
        
        return line
    }
}



// MARK: - button的类别扩展
extension UIButton{
    
    typealias ActionBlock = ((() ->Void)?)
    
    private struct RuntimeBtnKey {
        static let KBtnOverview = UnsafeRawPointer.init(bitPattern: "KBtnOverview".hashValue)
    }
    
    
    func handleControl(event:UIControlEvents ,callbackAction block: ActionBlock) -> Void{
        objc_setAssociatedObject(self, UIButton.RuntimeBtnKey.KBtnOverview, block, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        self.addTarget(self, action: #selector(callActionBlock(sender:)), for: event)
    }
    func handleEventTouchUpInside(callback block:ActionBlock) -> Void {
        objc_setAssociatedObject(self, UIButton.RuntimeBtnKey.KBtnOverview, block, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        self.addTarget(self, action: #selector(callActionBlock(sender:)), for: .touchUpInside)
    }
    
    func callActionBlock(sender:Any) -> Void {
        let block = objc_getAssociatedObject(self, UIButton.RuntimeBtnKey.KBtnOverview);
        if block != nil && block is ActionBlock {
            let actionBlock = block as! ActionBlock
            actionBlock!()
        }
    }
}

// MARK: - UILabel的类别扩展
extension UILabel{
    
    class func label (text:String,font:UIFont?,textColor:UIColor?, textAlignment:NSTextAlignment)-> UILabel {
        let label = UILabel.init()
        label.sizeToFit()
        label.text = text
        label.font = font == nil ? UIFont.systemFont(ofSize: 15) : font!
        label.textColor = textColor == nil ? UIColor.black : textColor!
        label.textAlignment = textAlignment
        return label;
    }
    class func label(frame:CGRect,text:String?,font:UIFont?,textColor:UIColor?, textAlignment:NSTextAlignment) -> UILabel {
        let label = UILabel.init()
        label.sizeToFit()
        label.text = text
        label.font = font == nil ? UIFont.systemFont(ofSize: 15) : font!
        label.textColor = textColor == nil ? UIColor.black : textColor!
        label.textAlignment = textAlignment
        label.frame = frame
        return label
    }
}


extension UIImageView{
    
    
     /// 充满，图片正常显示多出部分切割
     func imgViewAspectFill() {
        self.contentMode = UIViewContentMode.scaleAspectFill;
        self.clipsToBounds = true;
        self.contentScaleFactor = UIScreen.main.scale;
    }
}

extension UITableView{
    func adjustEstimatedHeight() -> Void {
        if #available(iOS 11.0,*) {
            self.estimatedRowHeight = 0;
            self.estimatedSectionFooterHeight = 0;
            self.estimatedSectionHeaderHeight = 0;
        }
    }
}
