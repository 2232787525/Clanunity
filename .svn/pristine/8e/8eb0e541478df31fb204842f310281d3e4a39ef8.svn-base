//
//  ClanLoginManagerVC.swift
//  Clanunity
//
//  Created by wangyadong on 2018/3/5.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

import UIKit

@objc enum LoginPage : Int{
    case UnKnow = 10000
    case Login = 0
    case Bind = 1
    case Club = 2
    case Address = 3
}

@objc enum LoginBtnType : Int{
    case Back = 0
    case Next = 1
    case finish = 2
}

class ClanLoginManagerVC: KBaseClanViewController ,UIPageViewControllerDataSource,UIPageViewControllerDelegate {

    private var pageController : UIPageViewController?
    private var controllers : Array<KNavigationController>?
    private var willIndex : LoginPage = LoginPage.UnKnow;
    public var currentIndex : LoginPage = LoginPage.UnKnow;
    //登录
    var loginVC : CULoginVC?
    //绑定手机号
    var bindVC : CULoginThirdBindVC?
    //完善姓氏
    var completeClub : CULoginSetNameVC?
    //完善地址
    var completeAddree : CULoginSetAddressVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.knavigationBar?.isHidden = true;
        if self.currentIndex == LoginPage.UnKnow {
            self.currentIndex = LoginPage.Login;
        }
        self.loadPageControll()
    }
    func loadPageControll() -> Void {
        
        if self.pageController == nil{
            let option = [UIPageViewControllerOptionSpineLocationKey:NSNumber.init(value:UIPageViewControllerSpineLocation.mid.rawValue)]
            let pageCller = UIPageViewController.init(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal, options: option)
            pageCller.view.frame = CGRect.init(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight)
            pageCller.view.backgroundColor = UIColor.black
            self.pageController = pageCller
            //登录页APPDELEGATE.gotoTabbarVC()

            if self.loginVC == nil {
                let login = CULoginVC.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight))
                login?.fatherSuperVC = self;
                self.loginVC = login
            }
            let loginNav = KNavigationController.init(rootViewController:self.loginVC!)
            //绑定页
            if self.bindVC == nil {
                let bind = CULoginThirdBindVC.init(frame:CGRect.init(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight))
                bind?.fatherSuperVC = self;
                self.bindVC = bind
            }
            let bindNav = KNavigationController.init(rootViewController:self.bindVC!);
            
            //姓氏
            if self.completeClub == nil {
                let club = CULoginSetNameVC.init(frame:CGRect.init(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight))
                club?.fatherSuperVC = self;
                self.completeClub = club
            }
            let clubNav = KNavigationController.init(rootViewController:self.completeClub!);
            //地址
            if self.completeAddree == nil {
                let Addree = CULoginSetAddressVC.init(frame:CGRect.init(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight))
                Addree?.fatherSuperVC = self;
                self.completeAddree = Addree
            }
            let addreeNav = KNavigationController.init(rootViewController:self.completeAddree!);

            if self.controllers == nil {
                self.controllers = [loginNav,bindNav,clubNav,addreeNav]
            }
            
            pageCller.setViewControllers([(self.controllers?[self.currentIndex.rawValue])!], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
            pageCller.dataSource = nil;
            pageCller.delegate = self;
        }
        self.pageController?.view.backgroundColor = UIColor.white
        self.addChildViewController(self.pageController!)
        self.view.addSubview((self.pageController?.view)!)
        
        
        self.loginVC?.loginButtonClicked = {[weak self] (type,next,info) -> Void in
            
            if next != LoginPage.UnKnow{//跳转到下一个页面
            
                if next == LoginPage.Bind{
                    if info != nil && info is [String:Any]{
                        print(info!)
                        let infoDic = info as! [String:Any]
                        self?.bindVC?.thirdType = infoDic["type"] as! Int
                        self?.bindVC?.headUrl = (infoDic["head"] as! String)
                        self?.bindVC?.openid = (infoDic["openid"] as! String)
                    }
                    
                }
                
                self?.pageForwardChange(LoginPage.Login,next: next)
            }
            if type == LoginBtnType.finish {
                LoginServer.share.loginFinish(status: 1);
                APPDELEGATE.gotoTabbarVC()
            }
            
        }
        self.bindVC?.loginButtonClicked = {[weak self] (type,next,info) -> Void in
            if next != LoginPage.UnKnow{//跳转到下一个页面
                self?.pageForwardChange(LoginPage.Bind,next: next)
            }
            if type == LoginBtnType.finish {
                LoginServer.share.loginFinish(status: 1);
                APPDELEGATE.gotoTabbarVC()
            }
            if type == LoginBtnType.Back {
                //返回到登录页面重新登录
                self?.pageForwardChange(LoginPage.Bind,next: LoginPage.Login)
            }
        }
        
        self.completeClub?.loginButtonClicked = {[weak self] (type,next,info) -> Void in
            if next != LoginPage.UnKnow{//跳转到下一个页面
                let dic = info as! Dictionary<String,Any>
                self?.completeAddree?.surnameModel = dic["model"] as! ClubModel
                self?.completeAddree?.name = dic["name"] as! String
                self?.pageForwardChange(LoginPage.Club,next: next)
            }
            if type == LoginBtnType.Back {
                //返回到登录页面重新登录
                self?.pageForwardChange(LoginPage.Club,next: LoginPage.Login)
            }
        }

        self.completeAddree?.loginButtonClicked = {[weak self] (type,next,info) -> Void in
            if next != LoginPage.UnKnow{//跳转到下一个页面
                self?.pageForwardChange(LoginPage.Address, next: next)
            }
            if type == LoginBtnType.Back {
                //返回到完善姓氏页面
                self?.pageForwardChange(LoginPage.Address,next: LoginPage.Club)
            }
            if type == LoginBtnType.finish {
                LoginServer.share.loginFinish(status: 1);
                APPDELEGATE.gotoTabbarVC()
            }
        }
    }
    
    func pageForwardChange(_ currentPage:LoginPage,next:LoginPage) -> Void {
        self.pageController?.dataSource = self;
        
        if next.rawValue > currentPage.rawValue {
            self.pageController?.setViewControllers([(self.controllers?[next.rawValue])!], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: { [weak self](finished) in
                if finished == true{
                    DispatchQueue.main.async {
                        self?.pageController?.dataSource = nil
                        self?.currentIndex = next;
                    }
                }
            })
        }else{
            self.pageController?.setViewControllers([(self.controllers?[next.rawValue])!], direction: UIPageViewControllerNavigationDirection.reverse, animated: true, completion: { [weak self](finished) in
                if finished == true{
                    DispatchQueue.main.async {
                        self?.pageController?.dataSource = nil
                        self?.currentIndex = next;
                    }
                }
            })
        }
    }
    
    //MARK: - UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var index = self.indexOfViewController(viewController: viewController)
        if index == NSNotFound || index == 0 {
            return nil
        }
        index -= 1
        return self.viewControllerAtIndex(index: index)
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        var index = self.indexOfViewController(viewController: viewController)
        if index == NSNotFound || index == (self.controllers?.count)!-1 {
            return nil
        }
        index += 1
        return self.viewControllerAtIndex(index: index)
    }
    //MARK: - UIPageViewControllerDelegate
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let index = self.indexOfViewController(viewController: pendingViewControllers[0])
        let page : LoginPage = LoginPage.init(rawValue: index)!;
        self.willIndex = page;
    }
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed == true {
            self.currentIndex = self.willIndex
        }
    }
    
    //MARK: - UIPageViewController辅助方法
    func viewControllerAtIndex(index:NSInteger) -> UIViewController? {
        if ((self.controllers?.count)! == 0 || index >= (self.controllers?.count)!){
            return nil
        }
        return self.controllers?[index]
    }
    
    func indexOfViewController(viewController : UIViewController) -> NSInteger {
        return (self.controllers?.index(of: viewController as! KNavigationController)!)!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
