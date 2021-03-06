//
//  KBaseTabbarViewController.swift
//  Clanunity
//
//  Created by wangyadong on 2018/1/29.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

import UIKit

class KBaseTabbarViewController: UITabBarController,UITabBarControllerDelegate {

    
    var firstNav : KNavigationController!
    var secondNav : KNavigationController!
    var thirdNav : KNavigationController!
    var first : FirstViewController!
    var second : ClanunityCenterVC!
    var third : MineVC!
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let tabFrame = self.tabBar.frame
        self.tabBar.frame = tabFrame;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.becomeFirstResponder()
        UIApplication.shared.applicationSupportsShakeToEdit = true
        
        self.delegate = self
        self.tabBar.tintColor = UIColor.white
    UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.lineColor1], for: .normal)
    UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.white], for: .selected)
        
        UITabBar.appearance().isTranslucent = false
                
        self.configTabbar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(kickOffUserNotification), name: NSNotification.Name.init(CUKey.DDNotificationUserKickouted), object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(logoutNotification), name: NSNotification.Name.init(CUKey.DDNotificationLogout), object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(signChangeNotification(notification:)), name: NSNotification.Name.init(CUKey.DDNotificationUserSignChanged), object: nil)
    
    }
    // MARK: - 退出登录和被踢登录 通知
    func kickOffUserNotification() ->Void{
        ClanServer.clearToken()
        UserServre.shareService.cacheClear();
       
        let logout = LogoutAPI.init()
        logout.request(with: nil, completion: { (any, error) in
        })
        MTTUtil.loginOut()
        let clientState = DDClientState.shareInstance()
        clientState?.userState = DDUserState.kickout
        UserDefaults.standard.set(false, forKey: "autologin")
        
        PLGlobalClass.alet(withTitle: "温馨提示", message: "你的账号在其他设备登录了", sureTitle: "确定", cancelTitle: nil, sureBlock: {
            PLGlobalClass.currentViewController().navigationController?.popToRootViewController(animated: true);
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // your code here
                LoginServer.share.showLoginVC(block: { (status) in
                })
                
            } 
            
        }, andCancel: {
        }, andDelegate: self)
      
    }
    
    
    
    func logoutNotification() -> Void{
        
        MTTUtil.loginOut()
        
    }
    func signChangeNotification(notification:Notification) -> Void{
        let notiDic = notification.object as! Dictionary<String,Any>
        let uid = notiDic["uid"]
        if uid != nil && (uid is String || uid is Int){
            print(uid ?? "")
            let uidStr = UInt("\(uid ?? "")")!
            let sessionID = MTTUserEntity.pbUserId(toLocalID: UInt(uidStr))
            
            DDUserModule.shareInstance().getUserForUserID(sessionID!, block: { (user) in
                user?.signature = "\(notiDic["sign"] ?? "")"
            })
            
        }
    }
    
    
    
    func configTabbar() -> Void{
        
        self.first = FirstViewController.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100));
        self.first.isRootVC = true
        self.firstNav = KNavigationController.init(rootViewController: self.first);
        
        self.second = ClanunityCenterVC.init()
        self.second.isRootVC = true;
        self.secondNav = KNavigationController.init(rootViewController: self.second)
        
        self.third = MineVC.init();
        self.third.isRootVC = true;
        self.thirdNav = KNavigationController.init(rootViewController: self.third)
        let viewControllers = [self.firstNav,self.secondNav,self.thirdNav];
        self.viewControllers = viewControllers as? [UIViewController];
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.baseColor2 , NSFontAttributeName : UIFont.systemFont(ofSize: 13)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.white , NSFontAttributeName : UIFont.systemFont(ofSize: 13)], for: .selected)
        
        for i in 0..<(self.tabBar.items?.count)! {
            let item :UITabBarItem = self.tabBar.items![i]
            item.imageInsets = UIEdgeInsetsMake(-4, 0, 4, 0)
            item.titlePositionAdjustment  = UIOffsetMake(0, -2);

            if i == 0 {
                item.title = "首页"
                item.image = UIImage.init(named: "tabbar-firstDeselected")?.withRenderingMode(.alwaysOriginal)
                item.selectedImage = UIImage.init(named: "tabbar-firstDeselected")
            }
            if i == 1{
                item.title = "宗亲汇"
                item.image = UIImage.init(named: "tabbar-secondDeselected")?.withRenderingMode(.alwaysOriginal)
                item.selectedImage = UIImage.init(named: "tabbar-secondDeselected")
            }
            if i == 2{
                item.title = "我的"
                item.image = UIImage.init(named: "tabbar-thirdDeselected")?.withRenderingMode(.alwaysOriginal)
                item.selectedImage = UIImage.init(named: "tabbar-thirdDeselected")
            }
        }
        self.selectedIndex = 0;

        self.tabBar.tintColor = UIColor.white
        
        let itemView = UIView.init(frame: CGRect.init(x: 0, y: 0, width:CGFloat( self.tabBar.bounds.size.width) / CGFloat((self.tabBar.items?.count)!), height: KBottomHeight));
        itemView.backgroundColor = UIColor.theme;
        if KBottomHeight > 49 {
            let bottom = UIView.init(frame: CGRect.init(x: 0, y: 0, width: itemView.width_sd, height: KBottomStatusH));
            bottom.bottom_sd = itemView.height_sd;
            bottom.backgroundColor = UIColor.white
            itemView.addSubview(bottom)
        }
        self.tabBar.selectionIndicatorImage = PLGlobalClass.image(with: itemView)
        
    }
    
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        //点击tabbar时刷新页面
        if viewController == self.firstNav{
            if self.first.pno != 1{
            }else{
                self.first.requestforList()
            }
        }else if viewController == self.secondNav{
            
        }else if viewController == self.thirdNav{
            if self.third.sectionView != nil{
                self.third.requestforList()
            }
        }
        return true
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
