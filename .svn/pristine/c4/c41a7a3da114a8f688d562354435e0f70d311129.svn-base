////
//  KNavigationController.swift
//  Clanunity
//
//  Created by wangyadong on 2018/1/29.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

import UIKit

class KNavigationController: UINavigationController,UINavigationControllerDelegate,UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.isNavigationBarHidden = true;
        self.delegate = self
        // 禁止系统原来的滑动返回手势，防止手势冲突
        self.interactivePopGestureRecognizer?.isEnabled = true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    // 是否开始触发手势，如果是根控制器就不触发手势
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 判断下当前控制器是否是根控制器
        return self.topViewController != self.viewControllers.first
    }
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        self.configureNavigationBar(viewController: viewController)
        if viewController.isRootVC == false{
            viewController.hidesBottomBarWhenPushed = true;
        }
        super.pushViewController(viewController, animated: animated)
    }
    func configureNavigationBar(viewController:UIViewController) -> Void {
        if viewController.knavigationBar == nil {
            viewController.knavigationBar = KNavigationBar.init()
        }
        //
        if viewController.knavigationBar?.leftBarBtnItem == nil && !viewController.isRootVC {
            viewController.knavigationBar?.leftBarBtnItem = viewController.createBackItem(nil)
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController.knavigationBar != nil{
            viewController.view.bringSubview(toFront: viewController.knavigationBar!)
        }
    }
    override var shouldAutorotate: Bool{
        if (self.topViewController?.responds(to: #selector(getter: self.shouldAutorotate)))! {
            return (self.topViewController?.shouldAutorotate)!
        }
        return false;
    }
   
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        if (self.topViewController?.responds(to: #selector(getter: self.supportedInterfaceOrientations)))! {
            return (self.topViewController?.supportedInterfaceOrientations)!
        }
        return UIInterfaceOrientationMask.portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        if (self.topViewController?.responds(to: #selector(getter: self.preferredInterfaceOrientationForPresentation)))! {
            return (self.topViewController?.preferredInterfaceOrientationForPresentation)!
        }
        return UIInterfaceOrientation.portrait
    }
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
