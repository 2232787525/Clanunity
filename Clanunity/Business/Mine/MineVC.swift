//
//  SecondViewController.swift
//  Clanunity
//
//  Created by wangyadong on 2018/1/29.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

import UIKit
import MJRefresh


//MARK: - 陌生人或好友VC-不能编辑资料，能查看资料 是好友就发起聊天 不是好友就添加好友
class StrangerOrFriendVC: PersonalVC {
    
    var notPOPWhenDelete = false
    
    var deleteFriendBack : ((() -> Void)?)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.height_sd = F_I6(place: 190)
        tableView.tableHeaderView = header
        header.headerImageV.isUserInteractionEnabled = false
    }
    
    override func setUser(){
    }
    
    override func reloadHeaderView(){
        
        super.reloadHeaderView()
        if (user?.isfriend ?? 0) == 1{//是好友
            let right = KNaviBarBtnItem.init(frame: CGRect.init(x: KScreenWidth-44, y: KStatusBarHeight, width: 44, height: 44), image: "friend_more") {[weak self] (sender) in
                self?.moreAlter()
            }
            self.knavigationBar?.rightBarBtnItem = right;
            
            header.btnArr = ["查看资料","发起聊天"]
            header.btnclickBlock {[weak self] (index) in
                if index == 0{
                    let vc = UserInfoVC.init()
                    vc.ifEdit = false
                    vc.user = self?.user
                    self?.navigationController?.pushViewController(vc, animated: true)
                    
                }else if index == 1{
                    let arr = self?.navigationController?.viewControllers
                    
                    for vc in arr!{
                        if(vc.isKind(of: ChattingMainViewController.classForCoder())){
                            
                            if self?.user?.teamid != nil && (self?.user?.teamid)! > 0{
                                print(ChattingMainViewController.shareInstance().phoneNumber)
                                
                                let userid  = (self?.user?.teamid)!
                                let Uuserid = UInt.init(NSNumber.init(value: userid))
                                let mttsection = MTTSessionEntity.init(sessionID: MTTUserEntity.pbUserId(toLocalID: Uuserid), type: SessionType.sessionTypeSingle)
                                mttsection?.setSessionName(self?.user?.nickname)
                                ChattingMainViewController.shareInstance().showChattingContent(forSession: mttsection)
                            }
                            self?.navigationController?.popToViewController(vc, animated: true)
                            break
                        }
                    }
                    
                    if self?.user?.teamid != nil && (self?.user?.teamid)! > 0{
                        let userid  = (self?.user?.teamid)!
                        let Uuserid = UInt.init(NSNumber.init(value: userid))
                        let mttsection = MTTSessionEntity.init(sessionID: MTTUserEntity.pbUserId(toLocalID: Uuserid), type: SessionType.sessionTypeSingle)
                        mttsection?.setSessionName(self?.user?.nickname)
                        ChattingMainViewController.shareInstance().showChattingContent(forSession: mttsection)
                        self?.navigationController?.pushViewController(ChattingMainViewController.shareInstance(), animated: true)
                    }
                }
            }
        }else{//不是好友
            let right = KNaviBarBtnItem.init(frame: CGRect.init(x: KScreenWidth-44, y: KStatusBarHeight, width: 44, height: 44), image: "report") {[weak self] (sender) in
                self?.report()
            }
            self.knavigationBar?.rightBarBtnItem = right;
            
            header.btnArr = ["查看资料","加好友"]
            header.btnclickBlock {[weak self] (index) in
                if index == 0{
                    let vc = UserInfoVC.init()
                    vc.ifEdit = false
                    vc.user = self?.user
                    self?.navigationController?.pushViewController(vc, animated: true)
                    
                }else if index == 1{
                    self?.addfriend()
                }
            }
        }
    }
    
    func moreAlter(){
        let alert = UIAlertController.init(title:nil  , message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction.init(title: "删除", style: .default, handler: {[weak self] (action) in
            //删除好友
            self?.alterV = msgAlterView.init(frame: CGRect.init(x: 0, y: 0, width: F_I6(place: 251), height: F_I6(place: 156)), parentVC: self, dismiss: self?.animation, title: "")
            
            self?.alterV.infoLab.text = "删除好友\n将好友" + (self?.header.text1.text ?? "") + "删除，将同时删除与该好友的聊天记录"
            PLGlobalClass.paragraphForlabel(self?.alterV.infoLab, lineSpace: 3)
            
            self?.alterV.bgImage.image = nil
           

            self?.alterV.infoLab.numberOfLines = 0
            self?.alterV.infoLab.textAlignment = .left
            self?.alterV.infoLab.font = UIFont.systemFont(ofSize: 15)
            self?.alterV.btn.setTitle("确定", for: .normal)
            self?.alterV.btn.setTitleColor(UIColor.orange, for: .normal)
            self?.lew_presentPopupView(self?.alterV, animation: self?.animation, backgroundClickable: true)
            
            self?.alterV.btnClickBlock  = {
                self?.deletefriend()
            }
        }))
        
        alert.addAction(UIAlertAction.init(title: "投诉", style: .default, handler: {[weak self] (action) in
            //投诉页面
            self?.report()
        }))
        
        alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { (action) in
            //取消
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //TODO:举报
    func report(){
        
        if (user?.userid.count ?? 0) > 0{
            let vc = ComplaintVC.init()
            vc.complaintId = (user?.userid ?? "")
            vc.ifPerson = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //TODO:加好友
    func addfriend(){
        self.showGifView()
        if self.user?.userid == nil || (self.user?.userid.count ?? 0) == 0{
            WFHudView.showMsg("缺少参数userid", in: self.view)
            return
        }
        ClanAPI.requestForApplyForAddFriend(remark: nil, friendid: (self.user?.userid)!, result: {[weak self] (result) in
            self?.hiddenGifView()
            if result.status == "200"{
                WFHudView.showMsg(result.message, in: self?.view)
            }else{
                WFHudView.showMsg(result.message ?? "发送好友请求失败", in: self?.view)
            }
        })
    }
    
    //TODO:删除好友
    func deletefriend(){
        
        self.showGifView()
        
        ClanAPI.requestForDeleteFriend(friendid: (self.user?.userid)!, result: {[weak self] (result) in
            self?.hiddenGifView()
            if result.status == "200"{
                WFHudView.showMsg(result.message, in: self?.view)
                if ((self?.deleteFriendBack) != nil){
                    self?.deleteFriendBack!()
                }
                if (self?.notPOPWhenDelete == true){
                    self?.user?.isfriend = 0
                    self?.reloadHeaderView()
                }else{
                    //返回到根视图
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            }else{
                WFHudView.showMsg(result.message ?? "删除好友失败", in: self?.view)
            }
        })
    }
    
    override func emptyShow(show:Bool){
        emptyView.picName = ImageDefault.emptyPlace2
        emptyView.top_sd = 10
        if show{
            if APPDELEGATE.networkStatus == 0{
                emptyView.describeLabel?.text = "请检查您的网络"
            }else{
                emptyView.describeLabel?.text = "他还没有发布动态"
            }
            footerview.height_sd = KScreenHeight - KTopHeight - header.height_sd
        }else{
            footerview.height_sd = 0
        }
        emptyView.centerY_sd = footerview.height_sd/2
    }
    
    //TODO:滑动停止播放 滑动改变title
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        var bianjie = F_I6(place: 0)
        if header.text2.text?.count == 0{
            bianjie = header.text2.bottom_sd + F_I6(place: 30)
        }else{
            bianjie = header.text2.bottom_sd + F_I6(place: 50)
        }
        
        if scrollView.contentOffset.y >= bianjie{
            self.knavigationBar?.title = user?.nickname ?? ""
        }else{
            self.knavigationBar?.title = ""
        }
        
        if scrollView.contentOffset.y < 0{
            baseview.height_sd = -scrollView.contentOffset.y + 20
        }else{
            baseview.height_sd = 20
        }
        
        self.lastContentOffset = scrollView.contentOffset;
        if (!(player != nil)) {
            return;
        }
        
        let path = NSIndexPath.init(row: self.lastPlayCell, section: 0)
        let rectInTableView = self.tableView.rectForRow(at:path as IndexPath)
        let rect = self.tableView.convert(rectInTableView, to: self.tableView.superview)
        if (rect.origin.y < -(rect.size.height*0.3)||rect.origin.y > (self.tableView.height_sd-(rect.size.height*0.4))) {
            self.playerDestroy()
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: - 我的信息VC- 不能设置
class MyInfoVC: PersonalVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO:跳转编辑资料页
        header.headerImageV.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.bk_recognizer {[weak self] (_, _, _) in
            let vc = UserInfoVC.init()
            vc.user = self?.user
            vc.ifEdit = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        header.headerImageV.addGestureRecognizer(tap as! UIGestureRecognizer)
        header.headerImageV.isUserInteractionEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


//MARK: - 我的VC
class MineVC: MyInfoVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let right = KNaviBarBtnItem.init(frame: CGRect.init(x: KScreenWidth-44, y: KStatusBarHeight, width: 44, height: 44), image: "set_icon") {[weak self] (sender) in
            print("设置")
            let vc = setVC.init()
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        self.knavigationBar?.rightBarBtnItem = right;
        
        tableView.height_sd = KScreenHeight - KTopHeight - KBottomHeight
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

