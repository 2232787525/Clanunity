//
//  AppHelper.swift
//  Clanunity
//
//  Created by wangyadong on 2018/1/30.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

//MARK:这个类可以放一些全局的不跟项目耦合的工具方法

import UIKit

class AppHelper: NSObject {
/*
    //TODO: 获取当前页面
    ///获取当前页面
    class var currentViewController : UIViewController?{
        
        let root  = UIApplication.shared.keyWindow?.rootViewController
        if root != nil{
            return AppHelper.findBestVC(viewController: root!)
        }
        return nil
        
    }
    
    class func findBestVC(viewController : UIViewController) -> UIViewController? {
        if viewController.parent != nil {
            return AppHelper.findBestVC(viewController:viewController.parent!)
        }else if viewController is UISplitViewController{
            let svc = viewController as! UISplitViewController
            if svc.viewControllers.count > 0{
                return AppHelper.findBestVC(viewController:svc.viewControllers.last!)
            }
            return viewController
            
        }else if viewController is UINavigationController{
            let nvc = viewController as! UINavigationController
            if nvc.viewControllers.count > 0{
                return AppHelper.findBestVC(viewController: nvc.topViewController!)
            }
            return viewController
            
        }else if viewController is UITabBarController{
            let tabVC = viewController as! UITabBarController
          if tabVC.viewControllers != nil && tabVC.viewControllers!.count > 0{
            return AppHelper.findBestVC(viewController: tabVC.viewControllers![tabVC.selectedIndex])
            }
            return viewController
        }
        
        return viewController
    }
*/
    
    
    
}
