//
//  KNavigationConfig.swift
//  Clanunity
//
//  Created by wangyadong on 2018/1/29.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

import Foundation

extension UIViewController{
    
   private struct RuntimeKey {
        static let kNaviHidden = UnsafeRawPointer.init(bitPattern: "kNaviHidden".hashValue)
        static let kNaviBarItem = UnsafeRawPointer.init(bitPattern: "kNaviBarItem".hashValue)
        static let kNaviBarView = UnsafeRawPointer.init(bitPattern: "kNaviBarView".hashValue)
        static let kRootVC = UnsafeRawPointer.init(bitPattern: "kRootVC".hashValue)
    }
    
    var knavigationBar : KNavigationBar?{
        get{
            return objc_getAssociatedObject(self, UIViewController.RuntimeKey.kNaviBarView) as? KNavigationBar
        }
        set{
            objc_setAssociatedObject(self, UIViewController.RuntimeKey.kNaviBarView, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var knavigationBarHidden : Bool{
        get{
            return ((objc_getAssociatedObject(self, UIViewController.RuntimeKey.kNaviHidden) != nil) as NSNumber).boolValue
        }set{
            objc_setAssociatedObject(self, UIViewController.RuntimeKey.kNaviHidden, NSNumber.init(value: newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    var isRootVC : Bool{
        get{
            return ((objc_getAssociatedObject(self, UIViewController.RuntimeKey.kRootVC) != nil) as NSNumber).boolValue
        }set{
            objc_setAssociatedObject(self, UIViewController.RuntimeKey.kRootVC, NSNumber.init(value: newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    func knavigationBar(hidden:Bool,animation:Bool) -> Void {
        if hidden {
            if animation{
                UIView.animate(withDuration: 0.25, animations: {
                    self.knavigationBar?.top_sd = -KTopHeight;
                    self.knavigationBar?.layoutIfNeeded()
                    
                    for  view in (self.knavigationBar?.subviews)!{
                        view.alpha = 0.0
                    }
                }, completion: { (finish) in
                    self.knavigationBarHidden = true
                })
            }else{
                self.knavigationBar?.layoutIfNeeded()
                self.knavigationBarHidden = true;
                self.knavigationBar?.top_sd = -KTopHeight
            }
            
        }else{
            if animation{
                UIView.animate(withDuration: 0.25, animations: {
                    self.knavigationBar?.top_sd = 0;
                    self.knavigationBar?.layoutIfNeeded()
                    
                    for  view in (self.knavigationBar?.subviews)!{
                        view.alpha = 1.0
                    }
                }, completion: { (finish) in
                    self.knavigationBarHidden = false
                })
            }else{
                self.knavigationBar?.layoutIfNeeded()
                self.knavigationBarHidden = false;
                self.knavigationBar?.top_sd = 0
            }
        }
    }
    
    func createBackItem(_ img:String?) -> KNaviBarBtnItem {
        //left_back_blackicon
      let left = KNaviBarBtnItem.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44), image: img ?? "left_white_blackicon") { [weak self](sender) in
        self?.kBackBtnAction();
        }
        
        return left
    }
    
    func kBackBtnAction() -> Void {
        if ((self.navigationController?.popViewController(animated: true)) == nil) {
            self.dismiss(animated: true, completion: {
            })
        }
    }
}
