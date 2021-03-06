//
//  CULoginVC.swift
//  Clanunity
//
//  Created by 白bex on 2018/2/1.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

import UIKit


//MARK: - ----------------登录基础UI 通用UI
class CULoginbaseVC: KBaseClanViewController,UITextFieldDelegate {

    var loginBGView = UIImageView.init()
    var textInputBGView = UIImageView.init()
    var line1 = UILabel.init()
    var line2 = UILabel.init()
    var Lab1 = UILabel.init()
    var tfTelephone = UITextField.init()
    var tfcode = UITextField.init()
    var nextBtn = UIButton.init()
    
    /// 按钮点击事件 btnType 返回传0，下一步传1,登录完成回到首页传2， tonext下一个页面的page，info如果有传值
    var loginButtonClicked : (((_ btnType : LoginBtnType,_ toNext:LoginPage,_ info:Any?) -> Void)?)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.knavigationBar?.isHidden = false;
        self.knavigationBar?.layer.contents = nil;
        self.knavigationBar?.backgroundColor = UIColor.clear
        self.knavigationBar?.cutlineColor = UIColor.clear
        
        //输入View  “textInputBGView”
        let textInputBGView = UIImageView.init(image: UIImage.init(named: "textInputBG"))
        textInputBGView.frame = CGRect.init(x: F_I6(place:28) , y: F_I6(place:185), width: F_I6(place:320), height: F_I6(place:170))
        textInputBGView.isUserInteractionEnabled = true
        self.view.addSubview(textInputBGView)
        
        let line1 = UILabel.init(frame: CGRect.init(x: F_I6(place:32), y: F_I6(place:68), width: F_I6(place:255), height: 0.5))
        line1.backgroundColor = UIColor.cutLineColor
        textInputBGView.addSubview(line1)
        
        let line2 = UILabel.init(frame: CGRect.init(x: line1.left_sd, y: F_I6(place:120), width: line1.width_sd, height: 0.5))
        line2.backgroundColor = UIColor.cutLineColor
        textInputBGView.addSubview(line2)
        
        //背景图片
        let loginBGView = UIImageView.init(image: UIImage.init(named: "loginBG"))
        loginBGView.frame = CGRect.init(x: F_I6(place:195) , y: F_I6(place:20), width: KScreenWidth - F_I6(place:195), height: F_I6(place:205))
        self.view.addSubview(loginBGView)
        
        //输入View  “textInputBGView”
        let Lab1 = UILabel.init(frame: CGRect.init(x: line1.left_sd, y: 0, width: 0, height: 0))
        Lab1.text = "+86"
        Lab1.textColor = UIColor.textColor1
        Lab1.font = UIFont.boldSystemFont(ofSize: 16)
        textInputBGView.addSubview(Lab1)
        Lab1.sizeToFit()
        Lab1.height_sd = 32
        Lab1.bottom_sd = line1.top_sd
        
        let tfTelephone = UITextField.init(frame: CGRect.init(x: Lab1.right_sd+10, y: Lab1.top_sd, width: line1.width_sd-Lab1.width_sd-10, height: Lab1.height_sd+2))
        tfTelephone.placeholder = "请输入手机号"
        tfTelephone.textColor = UIColor.textColor2
        tfTelephone.font = UIFont.systemFont(ofSize: 16)
        tfTelephone.setValue(UIColor.textColor2, forKeyPath: "_placeholderLabel.textColor")
        tfTelephone.keyboardType = .numberPad
        tfTelephone.returnKeyType = .done
        tfTelephone.delegate = self
        textInputBGView.addSubview(tfTelephone)
        
        let tfcode = UITextField.init(frame: CGRect.init(x: line2.left_sd, y: line2.top_sd-tfTelephone.height_sd+2, width: F_I6(place:255) - F_I6(place: 75) - 20, height:tfTelephone.height_sd))
        tfcode.placeholder = "请输入验证码"
        tfcode.textColor = UIColor.textColor2
        tfcode.font = UIFont.systemFont(ofSize: 16)
        tfcode.keyboardType = .numberPad
        tfcode.returnKeyType = .done
        tfcode.delegate = self
        textInputBGView.addSubview(tfcode)
        tfcode.setValue(UIColor.textColor2, forKeyPath: "_placeholderLabel.textColor")
        
        //登录按钮
        let nextBtn = UIButton.init(frame: CGRect.init(x: F_I6(place: 33), y: F_I6(place: 404), width: F_I6(place: 310), height: 44))
        nextBtn.setBackgroundImage(UIImage.init(named: "BG"), for: UIControlState.normal)
        nextBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        nextBtn.setTitle("登   录", for: UIControlState.normal)
        nextBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        self.view.addSubview(nextBtn)
        nextBtn.layer.cornerRadius = 5
        nextBtn.clipsToBounds = true
        
        self.loginBGView = loginBGView
        self.textInputBGView = textInputBGView
        self.line1 = line1
        self.line2 = line2
        self.Lab1 = Lab1
        self.tfTelephone = tfTelephone
        self.tfcode = tfcode
        self.nextBtn = nextBtn
        //同意协议 协议页面
        //下一步按钮
        //第三方登录View
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: - ----------------登录页面
class CULoginVC: CULoginbaseVC {
    var getcodeBtn = UIButton.init()
    var agreeBtn = UIButton.init()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        ClanServer.clearToken();
        UserServre.shareService.cacheClear();
        PLGlobalClass.setIQKeyboardToolBarEnable(true, distanceFromTextField: F_I6(place: 20))
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.knavigationBar?.leftBarBtnItem = nil
        
        self.tfTelephone.addTarget(self, action: #selector(wordlimit11(textField:)), for: UIControlEvents.editingChanged)
        
        getcodeBtn = UIButton.init(frame: CGRect.init(x: line2.right_sd-100, y: line2.top_sd-28-8, width: 100, height: 28))
        getcodeBtn.setBackgroundImage(UIImage.init(named: "btnBG"), for: UIControlState.normal)
        getcodeBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        getcodeBtn.setTitle("获取验证码", for: UIControlState.normal)
        getcodeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        getcodeBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        self.textInputBGView.addSubview(getcodeBtn)
        
        tfcode.centerY_sd = getcodeBtn.centerY_sd
        
        getcodeBtn.handleEventTouchUpInside {[weak self] in
            if APPDELEGATE.networkStatus == 0{
                WFHudView.showMsg(TextDefault.noNetWork, in: self?.view)
            }else{
                if self?.tfTelephone.text?.count == 11 {
                    self?.getcodeBtn.isUserInteractionEnabled = false
                    ClanAPI.requestForsmscode(username: (self?.tfTelephone.text!)!, result: { (result) in
                        if ((result.status) == "200"){
                            WFHudView.showMsg("短信已发送", in: self?.view)
                        }
                    })
                    
                    PLGlobalClass.queryGCD(withTimeout: 60, handleChangeCountdownBlock: { (timeStr) in
                        self?.getcodeBtn.setTitle("\(timeStr)"+"s", for: UIControlState.normal)
                        self?.getcodeBtn.width_sd = F_I6(place: 80)
                        self?.getcodeBtn.right_sd = (self?.line2.right_sd)!;
                        
                    }, handleStopCountdownBlock: { (timeStr) in
                        self?.getcodeBtn.setTitle("获取验证码", for: UIControlState.normal)
                        self?.getcodeBtn.isUserInteractionEnabled = true
                        self?.getcodeBtn.width_sd = F_I6(place: 75)
                        self?.getcodeBtn.right_sd = (self?.line2.right_sd)!;
                    })
                }else{
                    WFHudView.showMsg("请输入正确的手机号", in: self?.view)
                }
            }
        }
        
        //同意协议 协议页面
        agreeBtn = UIButton.init(frame: CGRect.init(x: textInputBGView.left_sd+10, y: textInputBGView.bottom_sd+3, width: F_I6(place: 50), height: F_I6(place: 24)))
        agreeBtn.setImage(UIImage.init(named: "fang_noselected"), for: UIControlState.normal)
        agreeBtn.setImage(UIImage.init(named: "fang_selected"), for: UIControlState.selected)
        agreeBtn.setTitleColor(UIColor.textColor2, for: UIControlState.normal)
        agreeBtn.setTitle("同意", for: UIControlState.normal)
        agreeBtn.titleLabel?.font = UIFont.systemFont(ofSize:14)
        agreeBtn.titleLabel?.sizeToFit()
        agreeBtn.width_sd = (agreeBtn.titleLabel?.width_sd)!+14+10
        agreeBtn.isSelected = true
        self.view.addSubview(agreeBtn)
        PLGlobalClass.setBtnStyle(agreeBtn, style: ButtonEdgeInsetsStyleReferToImage.imageLeft, space: 3)
        agreeBtn.handleEventTouchUpInside {[weak self] in
            self?.agreeBtn.isSelected = !(self?.agreeBtn.isSelected)!;
        }
        
        let agreement = UIButton.init(frame: CGRect.init(x: agreeBtn.right_sd, y: agreeBtn.top_sd, width:80, height: agreeBtn.height_sd))
        agreement.setTitleColor(UIColor.baseColor, for: UIControlState.normal)
        agreement.setTitle("《同宗汇协议》", for: UIControlState.normal)
        agreement.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        agreement.titleLabel?.sizeToFit()
        agreement.width_sd = (agreement.titleLabel?.width_sd)!
        self.view.addSubview(agreement)
        agreement.handleEventTouchUpInside {[weak self] in
            if APPDELEGATE.networkStatus == 0{
                WFHudView.showMsg(TextDefault.noNetWork, in: self?.view)
            }else{
                let vc = webVC.init()
                vc.loadWebURLSring(ClanAPI.H5_agreement)
                vc.titleStr = "协议"
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        nextBtn.handleEventTouchUpInside {[weak self] in
            if APPDELEGATE.networkStatus == 0{
                WFHudView.showMsg(TextDefault.noNetWork, in: self?.view)
            }else{
                
                if self?.agreeBtn.isSelected == false{
                    WFHudView.showMsg("必须同意协议才能登录", in: self?.view)
                    return
                }

                if (self?.tfTelephone.text!.count != 11){
                    WFHudView.showMsg("请输入11位手机号", in: self?.view)
                    return
                }
                if (self?.tfcode.text!.count == 0){
                    WFHudView.showMsg("请输入验证码", in: self?.view)
                    return
                }
                
                self?.showGifView()
                
                ClanAPI.requestForLogin(username: (self?.tfTelephone.text!)!, smscode: (self?.tfcode.text!)!, result: { (result) in
                    if ((result.status) == "200"){
                        print(result.data ?? "No data");
                        if (result.data != nil && result.data is [String:Any?]){
                            let user = UserModel.mj_object(withKeyValues: result.data)
                            //登录成功就可以拿到token，保存token
                            if (user!.token.count > 0){
                                ClanServer.savetoken(value: (user?.token)!)
                            }
                            UserServre.shareService.userModel = user!
                            if (user?.club != nil){
                                let clubModel = ClubModel.mj_object(withKeyValues: user?.club)
                                UserServre.shareService.userClub = clubModel
                            }
                            UserServre.shareService.cacheSaveRefresh()
                            
                            if UserServre.shareService.userClub == nil{//没有完善资料
                                /*完善17335010034用户信息 姓、名*/
                                self?.loginButtonClicked!(LoginBtnType.Next,LoginPage.Club,nil);
                            }else{
                                //登录成功 + 已经完善资料
                                self?.loginButtonClicked!(LoginBtnType.finish,LoginPage.UnKnow,nil);
                            }
                            WFHudView.showMsg("登录成功", in: self?.view)
                        }else{
                            WFHudView.showMsg("result.data为空", in: self?.view)
                        }
                    }else{
                        if (result.message.count>0){
                            WFHudView.showMsg(result.message, in: self?.view)
                        }else{
                            WFHudView.showMsg("登录失败", in: self?.view)
                        }
                    }
                    self?.hiddenGifView()
                })
            }
        }
        
        //第三方登录View
        let thirdLab = UILabel.init(frame: CGRect.init(x: 0, y: F_I6(place: 528), width: KScreenWidth, height: 12))
        thirdLab.text = "使用其他方式登录"
        thirdLab.textColor = UIColor.textColor1
        thirdLab.font = UIFont.systemFont(ofSize: 12)
        self.view.addSubview(thirdLab)
        thirdLab.textAlignment = NSTextAlignment.center
        
        let QQlogin = UIButton.init(frame: CGRect.init(x: F_I6(place: 121), y: F_I6(place: 580), width: F_I6(place: 53), height: F_I6(place: 53)))
        QQlogin.setBackgroundImage(UIImage.init(named: "QQ"), for: UIControlState.normal)
        QQlogin.setTitleColor(UIColor.white, for: UIControlState.normal)
        QQlogin.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        self.view.addSubview(QQlogin)
        QQlogin.handleEventTouchUpInside {[weak self] in
            if APPDELEGATE.networkStatus == 0{
                WFHudView.showMsg(TextDefault.noNetWork, in: self?.view)
            }else{
                ThirdLoginManager.shareInstance().thirdQQLogin(resultBlock: { (type, msg, result) in
                    self?.hiddenGifView()
                    print("+++result1" )
                    if type == 1{
                        
                        var openid : String = ""
                        var headimg : String?
                        
                        if result != nil{
                            let dic = result as! Dictionary<String,String>
                            openid = dic["openid"]!;
                            headimg = dic["headimg"];
                        }
                        //openid，headimg
                        self?.requestForThirdLogin(type: 3, info:openid , headImg: headimg)
                    }else{
                        WFHudView.showMsg(msg ?? "获取QQ授权信息失败", in: self?.view)
                    }
                })
            }
        }
        
        let WeChatlogin = UIButton.init(frame: CGRect.init(x: F_I6(place: 200), y: QQlogin.top_sd, width: F_I6(place: 53), height: F_I6(place: 53)))
        WeChatlogin.setBackgroundImage(UIImage.init(named: "WeChat"), for: UIControlState.normal)
        WeChatlogin.setTitleColor(UIColor.white, for: UIControlState.normal)
        WeChatlogin.titleLabel?.font = UIFont.systemFont(ofSize:17)
        self.view.addSubview(WeChatlogin)
        WeChatlogin.handleEventTouchUpInside {[weak self] in
            if APPDELEGATE.networkStatus == 0{
                WFHudView.showMsg(TextDefault.noNetWork, in: self?.view)
            }else{
                //第三方登录 获取到的数据
                ThirdLoginManager.shareInstance().thirdWeChatLogin {(type, msg, result) in
                    self?.hiddenGifView()

                    if type == 1{
                        //微信只能拿到code
                        self?.requestForThirdLogin(type: 2, info: result! as! String, headImg: "");
                    }else{
                        WFHudView.showMsg(msg ?? "获取微信授权信息失败", in: self?.view)
                    }
                }
            }
        }
    }
    
    //MARK: 输入控制 键盘控制
    func wordlimit11(textField : UITextField){
        PLGlobalClass.wordlimitWithtextField(textField, limitnum: 11)
    }
    

    /// 第三方登录
    /// - Parameters:
    ///   - type: 1-直接注册； 2-微信登陆；3- QQ登陆
    ///   - codeOpenid: 微信对应code，qq对应openid
    ///   - headImg: qq传头像
    func requestForThirdLogin(type:Int,info:String,headImg:String?) -> Void{
        //网络请求
        self.showGifView()
        
        ClanAPI.requestForThirdLogin(usertype: type, codeOpenid: info, headImg: headImg) { [weak self](result) in
            self?.hiddenGifView()
            
            if result.status == "308"{
                WFHudView.showMsg("微信授权失败", in: self?.view);
            }else if result.status == "306"{ //还未绑定手机号
                var head : String?;
                var openid : String?
                
                if result.data != nil{
                    let data = result.data! as! Dictionary<String,Any?>
                    openid = data["openid"] as? String;
                    //微信的话是请求返回的
                    if type == 2{
                        head = (data["headimg"] as? String)
                    }else{
                        //qq是第三方自己获取的
                        head = headImg
                    }
                }
                self?.loginButtonClicked!(LoginBtnType.Next,LoginPage.Bind,["type":type, "head":head ?? "" ,"openid" : openid ?? ""]);
                
            }else if result.status == "200"{
                //登录成功
                if (result.data != nil && result.data is [String:Any?]){
                    let user = UserModel.mj_object(withKeyValues: result.data)
                    //登录成功就可以拿到token，保存token
                    if (user!.token.count > 0){
                        ClanServer.savetoken(value: (user?.token)!)
                    }
                    UserServre.shareService.userModel = user!
                    if (user?.club != nil){
                        let clubModel = ClubModel.mj_object(withKeyValues: user?.club)
                        UserServre.shareService.userClub = clubModel
                    }
                    UserServre.shareService.cacheSaveRefresh()
                    
                    if UserServre.shareService.userClub == nil{//没有完善资料
                        /*完善17335010034用户信息 姓、名*/
                        self?.loginButtonClicked!(LoginBtnType.Next,LoginPage.Club,nil)
                    }else{
                        //登录成功 + 已经完善资料
                        self?.loginButtonClicked!(LoginBtnType.finish,LoginPage.UnKnow,nil)
                    }
                }else{
                    WFHudView.showMsg("服务器数据返回错误", in: self?.view);
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: - ----------------设置姓名页
class CULoginSetNameVC: CULoginbaseVC {
    var Lab2 = UILabel.init()
    var surnameModel = ClubModel.init()
    var name : String = ""

    var rightarrow = UIButton.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.knavigationBar?.isHidden = false;
        self.knavigationBar?.layer.contents = nil;
        self.knavigationBar?.backgroundColor = UIColor.clear
        self.knavigationBar?.cutlineColor = UIColor.clear
        
        self.knavigationBar?.leftBarBtnItem = KNaviBarBtnItem.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44), image: "left_back_blackicon", hander: { [weak self](sender) in
            //返回上个页面登录页面
            self?.loginButtonClicked!(LoginBtnType.Back,LoginPage.UnKnow,nil)
        })
        
        Lab1.text = "姓"
        tfTelephone.placeholder = "请选择您的姓氏(选择后不可修改)"
        tfcode.placeholder = "请输入您的名字"
        Lab1.textAlignment = NSTextAlignment.center
        tfTelephone.left_sd = Lab1.right_sd+5
        tfTelephone.right_sd = line1.right_sd - F_I6(place: 7)
        tfTelephone.delegate = self
        tfTelephone.adjustsFontSizeToFitWidth = true
        let Lab2 = UILabel.init(frame: CGRect.init(x: Lab1.left_sd, y: 0, width: Lab1.width_sd, height: Lab1.height_sd))
        Lab2.text = "名"
        Lab2.textColor = Lab1.textColor
        Lab2.font = Lab1.font
        textInputBGView.addSubview(Lab2)
        Lab2.bottom_sd = line2.top_sd
        Lab2.textAlignment = NSTextAlignment.center
        self.Lab2 = Lab2

        tfcode.left_sd = tfTelephone.left_sd
        tfcode.width_sd = tfTelephone.width_sd
        tfcode.keyboardType = .default
        
        nextBtn.setTitle("下一步", for: UIControlState.normal)
        nextBtn.handleEventTouchUpInside {[weak self] in
            
            if (self?.tfTelephone.text!.count == 0){
                WFHudView.showMsg("请选择您的姓氏", in: self?.view)
                return
            }
            if (self?.tfcode.text!.count == 0){
                WFHudView.showMsg("请填写您的名字", in: self?.view)
                return
            }
            self?.name = (self?.tfcode.text!)!
            self?.loginButtonClicked!(LoginBtnType.Next,LoginPage.Address,["name":(self?.name)!,"model":self?.surnameModel ?? ClubModel.init()])
        }
        
        let rightarrow = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: F_I6(place: 7), height: F_I6(place: 13)))
        rightarrow.setImage(UIImage.init(named: "rightArrow"), for: .normal)
        self.textInputBGView.addSubview(rightarrow)
        rightarrow.right_sd = line1.right_sd
        rightarrow.centerY_sd = tfTelephone.centerY_sd
        rightarrow.handleEventTouchUpInside {[weak self] () -> Void in
            print("选择姓氏页面")
            let vc = CULoginSetclubVC.init()
            vc.surnameModel = self?.surnameModel
            self?.fatherSuperVC.navigationController?.pushViewController(vc, animated: true)
        }
        self.rightarrow = rightarrow
    }
    
    //MARK: 输入控制 键盘控制
    func wordlimit11(textField : UITextField){ }//不限制字数
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField  == tfTelephone{
            print("选择姓氏页面")
            let vc = CULoginSetclubVC.init()
            vc.surnameModel = surnameModel
            self.fatherSuperVC.navigationController?.pushViewController(vc, animated: true)
            return false
        }else{
            return true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if  surnameModel.club.count > 0 {
            tfTelephone.text = surnameModel.club
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: - ----------------设置地址和性别
class CULoginSetAddressVC: CULoginSetNameVC {
    
    var prov = ChinaCityModel()
    var city = ChinaCityModel()
    var area = ChinaCityModel()
    var lab = UILabel.init()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.tfcode.text ?? " no tfcode")
        print(self.tfTelephone.text ?? " no address")
       
        
        self.knavigationBar?.leftBarBtnItem = KNaviBarBtnItem.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44), image: "left_back_blackicon", hander: { [weak self](sender) in
            
            self?.loginButtonClicked!(LoginBtnType.Back,LoginPage.UnKnow,nil)
        })
        

        Lab1.text = "地址"
        Lab1.sizeToFit()
        Lab2.text = "性别"
        Lab2.sizeToFit()
        
        tfTelephone.placeholder = "请选择您的地址"
        tfcode.placeholder = ""
        tfcode.isUserInteractionEnabled = false
        
        tfTelephone.bottom_sd = line1.top_sd
        tfTelephone.left_sd = Lab1.right_sd+15
        tfTelephone.width_sd = line1.right_sd-F_I6(place: 7)-tfTelephone.left_sd
        Lab1.centerY_sd = tfTelephone.centerY_sd
        
        rightarrow.handleEventTouchUpInside {[weak self] in
            
            print("选择地址页面")
            let vc = CUchooseAddressVC.init()
            vc.prov = self?.prov
            vc.city = self?.city
            vc.area = self?.area
            self?.fatherSuperVC.navigationController?.pushViewController(vc, animated: true)
        }
        
        let lab = UILabel.init(frame: tfTelephone.frame)
        self.textInputBGView.addSubview(lab)
        lab.backgroundColor = UIColor.white
        lab.textColor = tfTelephone.textColor
        lab.font = tfTelephone.font
        lab.numberOfLines = 0
        lab.isHidden = true
        self.lab = lab
        
        nextBtn.setTitle("完   成", for: UIControlState.normal)
        
        let manBtn = UIButton.init(frame: CGRect.init(x: Lab2.right_sd+20, y: 0, width: F_I6(place: 50), height: F_I6(place: 30)+2))
        manBtn.setImage(UIImage.init(named: "noselected"), for: UIControlState.normal)
        manBtn.setImage(UIImage.init(named: "selected"), for: UIControlState.selected)
        manBtn.setTitleColor(UIColor.textColor2, for: UIControlState.normal)
        manBtn.setTitle("男", for: UIControlState.normal)
        manBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        manBtn.isSelected = true
        self.textInputBGView.addSubview(manBtn)
        PLGlobalClass.setBtnStyle(manBtn, style: ButtonEdgeInsetsStyleReferToImage.imageLeft, space: 5)
        manBtn.bottom_sd = line2.top_sd
        Lab2.centerY_sd = manBtn.centerY_sd
        
        
        let womanBtn = UIButton.init(frame: CGRect.init(x: manBtn.right_sd+15, y: manBtn.top_sd, width: manBtn.width_sd, height: manBtn.height_sd))
        womanBtn.setImage(UIImage.init(named: "noselected"), for: UIControlState.normal)
        womanBtn.setImage(UIImage.init(named: "selected"), for: UIControlState.selected)
        womanBtn.setTitleColor(UIColor.textColor2, for: UIControlState.normal)
        womanBtn.setTitle("女", for: UIControlState.normal)
        womanBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.textInputBGView.addSubview(womanBtn)
        PLGlobalClass.setBtnStyle(womanBtn, style: ButtonEdgeInsetsStyleReferToImage.imageLeft, space: 5)
        womanBtn.handleEventTouchUpInside {
            womanBtn.isSelected = true
            manBtn.isSelected = false
        }
        
        manBtn.handleEventTouchUpInside {
            manBtn.isSelected = true
            womanBtn.isSelected = false
        }
        
        nextBtn.handleEventTouchUpInside {[weak self] in
            if APPDELEGATE.networkStatus == 0{
                WFHudView.showMsg(TextDefault.noNetWork, in: self?.view)
            }else{
                
                if ((lab.text == nil) || lab.text!.count <= 0 || self?.area.id == 0){
                    WFHudView.showMsg("请选择您的地址", in: self?.view)
                    return
                }
                
                var gender = "1"
                if (manBtn.isSelected){
                    gender = "1"
                }else if (womanBtn.isSelected){
                    gender = "0"
                }
                
                ClanAPI.requestForsaveUserBaseInfo(clubid: (self?.surnameModel.id)!, name: (self?.name)!, gender: gender, address: lab.text!, provid: "\((self?.prov.id)!)", cityid: "\((self?.city.id)!)", areaid: "\((self?.area.id)!)", result: { (result) in
                    if ((result.status) == "200"){
                        print("跳首页-欢迎回家！")
                        //保存用户信息
                        let model = UserServre.shareService.userModel
                        model?.address = lab.text!
                        model?.areadress = ["provid":"\((self?.prov.id)!)",
                            "cityid":"\((self?.city.id)!)",
                            "areaid":"\((self?.area.id)!)"]
                        model?.realname = (self?.name)!
                        //赋值用户信息
                        UserServre.shareService.userModel = model
                        //赋值 姓氏信息
                        UserServre.shareService.userClub = self?.surnameModel
                        UserServre.shareService.cacheSaveRefresh()
                        //进首页
                        self?.loginButtonClicked!(LoginBtnType.finish,LoginPage.UnKnow,nil)
                    }else{
                        if (result.message.count > 0){
                            WFHudView.showMsg(result.message, in: self?.view)
                        }else{
                            WFHudView.showMsg("请求失败", in: self?.view)
                        }
                    }
                })
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        tfTelephone.text = nil;

        if  area.areaname.count > 0 {
            tfTelephone.text = prov.areaname + city.areaname + area.areaname
            
            lab.isHidden = false
            lab.text = tfTelephone.text
            lab.sizeToFit()
            lab.width_sd = tfTelephone.width_sd
            lab.bottom_sd = line1.top_sd-1
            lab.centerY_sd = Lab1.centerY_sd
            
            if (tfTelephone.text!.count>0){
                tfTelephone.text = ""
                tfTelephone.placeholder = ""
            }
        }
    }
    
    override func wordlimit11(textField : UITextField){ }//不限制字数
    
    override func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
            print("选择地址页面")
            let vc = CUchooseAddressVC.init()
            vc.prov = prov
            vc.city = city
            vc.area = area
            self.fatherSuperVC.navigationController?.pushViewController(vc, animated: true)
            return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



//MARK: - ----------------选择姓氏页面
class CULoginSetclubVC: KBaseClanViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextFieldDelegate {

    var headerView : UICollectionReusableView? = nil
    var searchBGView = UIView.init()
    var surnameModel : ClubModel?
    var surnameArr : [ClubModel]?//加载的姓氏列表
    var surnameFirstArr : [ClubModel]?//第一次请求的姓氏列表

    var emptyBG = UIView.init()
    var surnameCollection : UICollectionView?
    var searchtf = UITextField.init()
    var sendBtn = UIButton.init()
    
    lazy var emptyView: EmptySwiftView = {
        let tempView = EmptySwiftView.showEmptyView(emptyPicName: "empty1", describe: "您的姓氏还不在其中")
        tempView.centerX_sd = KScreenWidth/2.0
        return tempView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.knavigationBar?.title = "所有姓氏"
        self.knavigationBar?.titleColor = UIColor.textColor1
        self.knavigationBar?.layer.contents = nil
        self.knavigationBar?.cutlineColor = UIColor.clear
        self.knavigationBar?.backgroundColor = UIColor.white
        
        self.knavigationBar?.leftBarBtnItem = self.createBackItem("left_back_blackicon")
        
        self.searchView()
        self.SurnameView()
        self.getSurname(keyword: "")
    }
    
    //搜索框
    func searchView() {
        let searchBGView = UIView.init(frame: CGRect.init(x: 0, y: KTopHeight, width: KScreenWidth, height: 40))
        searchBGView.backgroundColor = UIColor.bgColor2
        self.view.addSubview(searchBGView)
        
        let searchView = UIView.init(frame: CGRect.init(x: F_I6(place: 12), y: 2, width: KScreenWidth-F_I6(place: 24), height: 40-4))
        searchView.backgroundColor = UIColor.bgColor
        searchView.layer.cornerRadius = searchView.height_sd/2;
        searchView.clipsToBounds = true
        searchBGView.addSubview(searchView)
        
        let searchicon = UIImageView.init(frame: CGRect.init(x: 14, y: (searchView.height_sd-19)/2, width: 19, height: 19))
        searchicon.image = UIImage.init(named: "sousuo")
        searchView.addSubview(searchicon)
        
        let searchtf = UITextField.init(frame: CGRect.init(x: searchicon.right_sd+20, y: 0, width: searchView.width_sd-40-searchicon.right_sd, height: searchView.height_sd))
        searchtf.placeholder = "请输入您的姓氏"
        searchtf.textColor = UIColor.textColor3
        searchtf.font = UIFont.systemFont(ofSize: 15)
        searchtf.setValue(UIColor.textColor2, forKeyPath: "_placeholderLabel.textColor")
        searchView.addSubview(searchtf)
        searchtf.delegate = self
        searchtf.returnKeyType = UIReturnKeyType.search
        searchtf.clearButtonMode = UITextFieldViewMode.whileEditing
        self.searchtf = searchtf
        self.searchBGView = searchBGView
    }
    
    //姓氏列表
    func SurnameView() {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize.init(width: F_I6(place: 64), height: F_I6(place: 25))
        //设置滚动方向
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8//最小行间距
        layout.minimumInteritemSpacing = 7//最小item间距

        layout.sectionInset = UIEdgeInsetsMake(10, 12, 29, 12)//设置senction的内边距
        
        let surnameCollection = UICollectionView.init(frame: CGRect.init(x: 0, y: searchBGView.bottom_sd, width: KScreenWidth, height: KScreenHeight-searchBGView.bottom_sd), collectionViewLayout: layout)
        surnameCollection.register(SurnameCell.self, forCellWithReuseIdentifier: "cell")
        surnameCollection.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        surnameCollection.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "footer")
        
        surnameCollection.showsHorizontalScrollIndicator = false;
        surnameCollection.showsVerticalScrollIndicator = false;
        surnameCollection.backgroundColor = UIColor.white
        
        surnameCollection.delegate = self
        surnameCollection.dataSource = self
        self.view.addSubview(surnameCollection)
        self.surnameCollection = surnameCollection
        
        let emptyBG = UIView.init(frame: CGRect.init(x: 0, y: surnameCollection.top_sd, width: surnameCollection.width_sd, height: surnameCollection.height_sd))
        emptyBG.backgroundColor = UIColor.white
        emptyBG.addSubview(self.emptyView)
        emptyView.top_sd = F_I6(place: 50)
        self.view.addSubview(emptyBG)
        self.emptyBG = emptyBG
        self.emptyBG.isHidden = true
        //登录按钮
        let sendBtn = UIButton.init(frame: CGRect.init(x: F_I6(place: 107), y: emptyView.bottom_sd + 30, width: F_I6(place: 160), height: 44))
        sendBtn.setBackgroundImage(UIImage.init(named: "BG"), for: UIControlState.normal)
        sendBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        sendBtn.setTitle("申请提交", for: UIControlState.normal)
        sendBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        emptyBG.addSubview(sendBtn)
        sendBtn.layer.cornerRadius = 5
        sendBtn.clipsToBounds = true
        sendBtn.layer.cornerRadius = 5
        sendBtn.clipsToBounds = true
        self.sendBtn = sendBtn
        
        //TODO:提交新姓氏
        sendBtn.handleEventTouchUpInside {[weak self , weak sendBtn] in
            
            if APPDELEGATE.networkStatus == 0{
                WFHudView.showMsg(TextDefault.noNetWork, in: self?.view)
            }else{
                self?.showGifView()
                
                ClanAPI.requestForSubmitClum(club: (self?.searchtf.text!)!, result: { (result) in
                    self?.hiddenGifView()

                    if result.status == "302" || (result.status) == "200"{
                        self?.sendBtn.setTitle("审核中", for: UIControlState.normal)
                        self?.sendBtn.isUserInteractionEnabled = false
                        self?.sendBtn.backgroundColor = UIColor.bgColor3
                        self?.sendBtn.setBackgroundImage(UIImage.init(named: ""), for: UIControlState.normal)
                        self?.emptyView.describeLabel?.text = "您的姓氏正在审核中"
                    }else{
                        sendBtn?.setTitle("申请提交", for: UIControlState.normal)
                        WFHudView.showMsg("提交失败", in: self?.view)
                    }
                    if ((result.status) == "200"){
                        WFHudView.showMsg("提交成功\n24小时内静等通知", in: self?.view)
                    }
                })
            }
        }
    }
    
    //MARK:姓氏请求/搜索姓氏接口
    func getSurname( keyword: String) {
        self.showGifView()
        ClanAPI.requestForSurnameList(pagenum: 1, pagesize: 100, keyword: keyword) {[weak self] (result) in
            
            if APPDELEGATE.networkStatus == 0{
                WFHudView.showMsg(TextDefault.noNetWork, in: self?.view)
            }else{
                self?.hiddenGifView()
                if result.data != nil && result.data is Dictionary<String,Any>{
                    var dic = result.data! as! Dictionary<String , Any>
                    let arr = dic["list"] as? Array<ClubModel>
                    
                    if (arr != nil && arr!.count > 0){
                        if (keyword.count>0){//搜索结果
                            self?.surnameArr = arr
                        }else{//常用姓氏列表
                            self?.surnameFirstArr = arr
                            self?.surnameArr = self?.surnameFirstArr
                        }
                        self?.surnameCollection?.reloadData()
                    }else{
                        if (keyword.count>0){
                            if result.status == "302"{
                                self?.sendBtn.setTitle("审核中", for: UIControlState.normal)
                                self?.sendBtn.isUserInteractionEnabled = false
                                self?.sendBtn.backgroundColor = UIColor.bgColor3
                                self?.sendBtn.setBackgroundImage(UIImage.init(named: ""), for: UIControlState.normal)
                                self?.emptyView.describeLabel?.text = "您的姓氏正在审核中"
                            }else{
                                self?.sendBtn.isUserInteractionEnabled = true
                                self?.sendBtn.setBackgroundImage(UIImage.init(named: "BG"), for: UIControlState.normal)
                                self?.sendBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
                                self?.sendBtn.setTitle("申请提交", for: UIControlState.normal)
                                self?.emptyView.describeLabel?.text = "您的姓氏还不在其中"
                            }
                            self?.emptyBG.isHidden = false
                            self?.searchtf.resignFirstResponder()
                        }
                    }
                }else{
                    if (keyword.count>0){
                        if result.status == "302"{
                            self?.sendBtn.setTitle("审核中", for: UIControlState.normal)
                            self?.sendBtn.isUserInteractionEnabled = false
                            self?.sendBtn.backgroundColor = UIColor.bgColor3
                            self?.sendBtn.setBackgroundImage(UIImage.init(named: ""), for: UIControlState.normal)
                            self?.emptyView.describeLabel?.text = "您的姓氏正在审核中"
                        }else{
                            self?.sendBtn.isUserInteractionEnabled = true
                            self?.sendBtn.setBackgroundImage(UIImage.init(named: "BG"), for: UIControlState.normal)
                            self?.sendBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
                            self?.sendBtn.setTitle("申请提交", for: UIControlState.normal)
                            self?.emptyView.describeLabel?.text = "您的姓氏还不在其中"
                        }
                        self?.emptyBG.isHidden = false
                        self?.searchtf.resignFirstResponder()
                    }else{
                        if (result.message.count>0){
                            WFHudView.showMsg(result.message, in: self?.view)
                        }
                    }
                }
            }
        }
    }
    
    //textfield代理
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if  (textField.text != nil) && textField.text!.count > 0 {
            self.getSurname(keyword: textField.text!)
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.emptyBG.isHidden = true
        return true
    }
    
    //collectionView代理
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.surnameArr?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = surnameArr![indexPath.row]
        
        //指针传值 传给设置姓名页面
        surnameModel?.club = model.club
        surnameModel?.club_qp = model.club_qp
        surnameModel?.club_sx = model.club_sx
        surnameModel?.id = model.id
        surnameModel?.updated = model.updated
        surnameModel?.created = model.created
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SurnameCell
        cell.model = surnameArr?[indexPath.row]
        return cell;
    }
    
    //返回section个数
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
        return CGSize(width: KScreenWidth, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let reusableview:UICollectionReusableView!
        
        if kind == UICollectionElementKindSectionHeader{
            headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
            if(headerView != nil){
                let lab = UILabel.init(frame: CGRect.init(x: 12, y: 0, width: KScreenWidth-24, height: 40))
                lab.text = "常见姓氏"
                lab.textColor = UIColor.textColor1
                headerView?.addSubview(lab)
            }
            return headerView!
        }else{
            reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath)
//            reusableview.backgroundColor = UIColor.green
            return reusableview!
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//姓氏colllectionCell
class SurnameCell: UICollectionViewCell{
    var lab = UILabel()
    var model : ClubModel?{
        willSet {//之前用的是didSet，为什么？
            lab.text = newValue?.club
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        lab = UILabel.init()
        lab.text = ""
        lab.textColor = UIColor.textColor1
        lab.font = UIFont.systemFont(ofSize: 15)
        lab.adjustsFontSizeToFitWidth = true
        lab.textAlignment = NSTextAlignment.center
        lab.layer.cornerRadius = 5
        lab.clipsToBounds = true
        lab.layer.borderColor = UIColor.textColor3.cgColor
        lab.layer.borderWidth = 1
        self.addSubview(lab)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lab.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



//MARK: - ----------------选择地区页面
class CUchooseAddressVC: KBaseClanViewController,UITableViewDelegate,UITableViewDataSource {
    
    var searchBGView = UIView.init()
    var surnameModel : ClubModel?
    var emptyBG = UIView.init()
    var list : Array<ChinaCityModel>? = nil
    var tableView = UITableView.init()
    var headerview = UIView.init()
    var prov : ChinaCityModel?
    var city : ChinaCityModel?
    var area : ChinaCityModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.knavigationBar?.title = "地址"
        self.knavigationBar?.leftBarBtnItem = self.createBackItem("left_back_blackicon")
        //导航栏背景颜色要设其他纯色，需要先设.layer.contents为空，因为默认使用.layer.contents属性设置了导航栏背景图片
        self.knavigationBar?.layer.contents = nil
        self.knavigationBar?.backgroundColor = UIColor.white
        self.knavigationBar?.titleColor = UIColor.textColor1
        self.maketableView()
    }
    
    func maketableView(){
        let headerview = UIView.init(frame: CGRect.init(x: 0, y: KTopHeight, width: KScreenWidth, height: 40))
        headerview.backgroundColor = UIColor.bgColor2
        self.view.addSubview(headerview)
        
        let whiteView = UIView.init(frame: CGRect.init(x: 0, y: 4, width: KScreenWidth, height: headerview.height_sd-8))
        whiteView.backgroundColor = UIColor.white
        headerview.addSubview(whiteView)
        self.headerview = headerview
        self.getAreaData()
        
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y:headerview.bottom_sd, width: KScreenWidth, height: KScreenHeight-headerview.bottom_sd), style: UITableViewStyle.plain)
        tableView.delegate=self
        tableView.dataSource=self
        tableView.sectionHeaderHeight = 0.01;
        tableView.sectionFooterHeight = 0.01;
        self.view.addSubview(tableView)
        self.tableView = tableView
    }
    
    //地区按钮
    func makeAreaBtn(){
        for i in 0...3{
            let btn = KButton.init(frame: CGRect.init(x: 0+50*i, y: 4, width: 50, height: Int(headerview.height_sd-8)), needMengban:false)
            if i == 0 {
                btn.setTitle("全国", for: .normal)
                btn.titleLabel?.font = UIFont.systemFont(ofSize:15)
                btn.isHidden = false
                btn.attribute = list
                tableView.reloadData()
            }else{
                btn.setTitle("", for: .normal)
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
                btn.isHidden = true
            }
            btn.setTitleColor(UIColor.textColor1, for:.normal)
            self.headerview.addSubview(btn)
            btn.tag = i + 100
            btn.handleEventTouchUpInside {[weak self,weak btn] in
                if (btn?.attribute != nil && btn?.attribute is ChinaCityModel){
                    let model = btn?.attribute as! ChinaCityModel
                    
                    self?.list = ChinaCityModel.searchDataWhere(["parentid":model.id])
                    self?.tableView.reloadData()
                }else{
                    self?.list = ChinaCityModel.searchDataWhere(["level":"1"])
                    self?.tableView.reloadData()
                }
                for i in (btn?.tag)!...103{
                    let btnfor: KButton = (self?.headerview.viewWithTag(i) as? KButton)!
                    do {
                        if (btnfor.tag > (btn?.tag)!){
                            btnfor.isHidden = true
                        }
                    }
                }
            }
        }
    }
    
    //按钮位置自适应
    func makeBtnFrame(tag : Int) {
        let btn = headerview.viewWithTag(tag-1) as? KButton
        var X = btn?.right_sd
        
        for i in tag ... 3+100{
            let btnfor = headerview.viewWithTag(i) as? KButton
            if (i==tag){

                btnfor?.titleLabel?.sizeToFit()
                btnfor?.width_sd = (btnfor?.titleLabel?.width_sd)!+10
                if ((btnfor?.right_sd)!>KScreenWidth){
                    if (i<103){
                        //不是最后一个按钮 缩小按钮给后一个留空间
                        btnfor?.width_sd = (KScreenWidth - X!)/2
                    }else{
                        //最后一个按钮，右边顶到头就行了
                        btnfor?.width_sd = KScreenWidth-5-(btn?.right_sd)!;
                    }
                }else{
                    if ((btnfor?.width_sd)! > KScreenWidth/3){
                        btnfor?.width_sd = KScreenWidth/3;
                    }
                }
                X = btnfor?.right_sd
            }else{
                btnfor?.left_sd = X!
            }
        }
    }
    
    //获取地区数据
    func getAreaData() {
        
        list = ChinaCityModel.searchDataWhere(["level":"1"])
        if list != nil && list!.count > 0 {
            self.makeAreaBtn()
        }else{
            self.showGifView()
            let jsonData = NSData.init(contentsOfFile: Bundle.main.path(forResource: "city", ofType: "json")!)
            let arr = jsonData?.mj_JSONObject()
            let array = ChinaCityModel.mj_objectArray(withKeyValuesArray: arr)

            //存数据成功 存数据库是为了搜索时方便
            ChinaCityModel.insert(with: array as! [ChinaCityModel])
            self.hiddenGifView()
            self.list = ChinaCityModel.searchDataWhere(["level":"1"])
            self.makeAreaBtn()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? addressCell
        if (cell == nil){
            cell = addressCell.init(style: UITableViewCellStyle.value1, reuseIdentifier: "cell")
        }

        let model = list![indexPath.row]
        cell?.model = model
        if (model.level<3){
            cell?.accessoryType = .disclosureIndicator
        }else{
            cell?.accessoryType = .none
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! addressCell
        let model = cell.model
        let level = model?.level ?? 0
        let btn = headerview.viewWithTag(100+level) as? KButton
        btn?.attribute = model
        btn?.isHidden = false
        if (model!.level  >= 3) {
            btn?.setTitle(model?.areaname ?? "\(level)", for: .normal)
            self.kBackBtnAction()
        } else {
            btn?.setTitle((model?.areaname ?? "\(level)") + " >" , for: .normal)
            list = ChinaCityModel.searchDataWhere(["parentid":model!.id])
            tableView.reloadData()
        }
        self.makeBtnFrame(tag: (btn?.tag)!)
    }
    
    override func kBackBtnAction() {
        let btn = headerview.viewWithTag(103) as? KButton
        let btn1 = headerview.viewWithTag(101) as? KButton
        
        if ((btn1 != nil) && (btn1?.isHidden == false) && (btn != nil) && (btn?.isHidden)!) {//按钮1显示 按钮3不显示 则不允许返回
            WFHudView.showMsg("地址要求选择到区", in: self.view)
        } else {
            for i in 101 ... 3+100{
                let btnfor = headerview.viewWithTag(i) as? KButton
                let model = btnfor?.attribute as? ChinaCityModel
                
                if (model != nil){
                    switch (i) {
                    case 101:
                        prov?.id = model!.id
                        prov?.areaname = model!.areaname
                        prov?.level = model!.level
                        prov?.parentid = model!.parentid
                        break;
                    case 102:
                        city?.id = model!.id
                        city?.areaname = model!.areaname
                        city?.level = model!.level
                        city?.parentid = model!.parentid
                        break;
                    case 103:
                        area?.id = model!.id
                        area?.areaname = model!.areaname
                        area?.level = model!.level
                        area?.parentid = model!.parentid
                        break;
                    default: break
                    }
                }
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
}

//姓氏colllectionCell
class addressCell: UITableViewCell{
    var lab = UILabel()
    var model : ChinaCityModel?{
        didSet {
            self.textLabel?.text = model?.areaname
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CULoginThirdBindVC : CULoginVC{
    
    /// 2微信，3qq
    var thirdType = 0;
    
    /// qq/微信的openid
    var openid:String?
    /// 头像
    var headUrl:String?
    
    override func viewWillAppear(_ animated: Bool) {
        self.tfTelephone.text = ""
        self.tfcode.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.knavigationBar?.title = "绑定手机号"
        self.knavigationBar?.titleColor = UIColor.textColor1;
        self.loginBGView.isHidden = true;
        self.knavigationBar?.isHidden = false;
        self.knavigationBar?.layer.contents = nil;
        self.knavigationBar?.backgroundColor = UIColor.white
        self.knavigationBar?.cutlineColor = UIColor.clear
        self.nextBtn.setTitle("登    录", for: .normal);
        let thirdTopView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 100))
        thirdTopView.backgroundColor = UIColor.white
        thirdTopView.top_sd = self.nextBtn.bottom_sd;
        thirdTopView.height_sd = KScreenHeight-self.nextBtn.bottom_sd;
        self.view.addSubview(thirdTopView);
        
        
        self.knavigationBar?.leftBarBtnItem = KNaviBarBtnItem.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44), image: "left_back_blackicon", hander: { [weak self](sender) in
            //返回上个页面登录页面
            self?.loginButtonClicked!(LoginBtnType.Back,LoginPage.UnKnow,nil)
        })
        
        self.nextBtn.handleEventTouchUpInside { [weak self] in
            if APPDELEGATE.networkStatus == 0{
                WFHudView.showMsg(TextDefault.noNetWork, in: self?.view)
            }else{
                if self?.agreeBtn.isSelected == false{
                    WFHudView.showMsg("必须同意协议才能登录", in: self?.view)
                    return
                }
                
                if (self?.tfTelephone.text!.count == 0){
                    WFHudView.showMsg("手机号不能为空", in: self?.view)
                    return
                }
                if (self?.tfcode.text!.count == 0){
                    WFHudView.showMsg("请输入验证码", in: self?.view)
                    return
                }
                ClanAPI.requestForBind(username: (self?.tfTelephone.text)!, smscode: (self?.tfcode.text)!, usertype: (self?.thirdType)!, openid: self?.openid, headimg: self?.headUrl, result: { (result) in
                    WFHudView.showMsg(result.message, in: self?.view)
                    print(result.data ?? "no data");
                    if result.status == "200"{
                        
                        if result.data != nil && result.data is [String:Any?] {
                            let resultDic = result.data as! [String:Any?]
                            let user = UserModel.mj_object(withKeyValues: resultDic)
                            //保存token
                            ClanServer.savetoken(value: (user?.token)!);
                            UserServre.shareService.userModel = user!;
                            
                            if user?.club != nil{
                                let clubModel = ClubModel.mj_object(withKeyValues: user?.club)
                                UserServre.shareService.userClub = clubModel
                            }
                            UserServre.shareService.cacheSaveRefresh()
                            if UserServre.shareService.userClub == nil{
                               //完善信息->去选地址-选姓氏
                                self?.loginButtonClicked!(LoginBtnType.Next,LoginPage.Club,nil)
                            }else{
                                //登录成功
                                self?.loginButtonClicked!(LoginBtnType.finish,LoginPage.UnKnow,nil)
                            }
                        }
                    }else{
                        //没有绑定成功
                        WFHudView.showMsg("绑定失败", in: self?.view)
                    }
                })
            }
        }
    }
    
    deinit {
        print("dealloc")
    }
}
