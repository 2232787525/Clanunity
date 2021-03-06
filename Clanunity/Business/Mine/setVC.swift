import UIKit
import MJRefresh



//MARK: - ----------------个人资料
class setVC: KBaseClanViewController,UITableViewDelegate,UITableViewDataSource {
    
    var ifEdit =  false
    var user :  UserModel?
    var tableView = UITableView()
    var cacheNum = ""

    /// 弹窗
    var animation : LewPopupViewAnimationSlide?
    var alterV : msgAlterView?
    
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    func reloadTable(){
        user = UserServre.shareService.userModel
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.knavigationBar?.cutlineColor = UIColor.clear
        self.knavigationBar?.title = "设置"
        
        self.maketableView()
        
        let  filePath1 =  NSHomeDirectory().appending("/Library/Caches")
        let  filePath2 =  NSHomeDirectory().appending("/tmp")

        DispatchQueue.global().async { [weak self] in
            self?.cacheNum = PLClearCacheTool.getCacheSize(withFilePath: filePath1, path2: filePath2)
            DispatchQueue.main.async {
                self?.reloadTable()
            }
        }
        
        GlobalClass.requestAuthType(callBack: { [weak self] (authType) in
            self?.reloadTable()
        })
    }
    
    //MARK: - tableView
    func maketableView(){
        self.tableView = UITableView.init(frame: CGRect.init(x: 0, y: KTopHeight, width: KScreenWidth, height: KScreenHeight-KTopHeight), style: UITableViewStyle.plain)
        self.tableView.backgroundColor = UIColor.bgColor2
        tableView.separatorColor = UIColor.cutLineColor
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        self.tableView.delegate=self
        self.tableView.dataSource=self
        self.view.addSubview(tableView)
        tableView.tableHeaderView = UIView.init()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 7
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? SetCell
        if (cell == nil){
            cell = SetCell.init(style: .default, reuseIdentifier: "cell")
        }
        
        let cellview  = cell?.cellview
        
        if indexPath.section == 0{
            switch indexPath.row{
            case 0 :
                cellview?.titleLabel.text = "手机号修改"
                var str = user?.username
                if str?.count == 11{
                    str?.replaceSubrange(Range.init(NSRange.init(location: 3, length: 4), in: str!)!, with: "****")
                }
                cellview?.showLabel.text = str
                cell?.accessoryType = .disclosureIndicator
                cellview?.showLabel.right_sd = KScreenWidth - 35
                break
                
            case 1:
                cellview?.titleLabel.text = "QQ绑定"
                cellview?.showLabel.text = "未绑定"
                
                if user?.thirdUsers.count ?? 0 > 0{
                    for third in (user?.thirdUsers)!{
                        let thi = third as? ThirdUser
                        if thi?.usertype == 3{
                            cellview?.showLabel.text = "已绑定"
                            cell?.thirdmodel = thi
                            break
                        }
                    }
                }
                break
                
            case 2:
                cellview?.titleLabel.text = "微信绑定"
                cellview?.showLabel.text = "未绑定"
                
                if user?.thirdUsers.count ?? 0 > 0{
                    for third in (user?.thirdUsers)!{
                        let thi = third as? ThirdUser
                        if thi?.usertype == 2{
                            cellview?.showLabel.text = "已绑定"
                            cell?.thirdmodel = thi
                            break
                        }
                    }
                }
                break
                
            case 3:
                cellview?.titleLabel.text = "消息通知"
                let closeNotice = PLGlobalClass.getValueFromFile(CUKey.kStartupInfo, withKey: CUKey.kStartupInfo_CloseNotice) as? Bool
                if closeNotice == true{
                    cellview?.showLabel.text = "关"
                }else{
                    cellview?.showLabel.text = "开"
                }
                
                cellview?.showLabel.textColor = UIColor.baseColor
                cell?.accessoryType = .disclosureIndicator
                cellview?.showLabel.right_sd = KScreenWidth - 35
                break
                
            case 4:
                cellview?.titleLabel.text = "关于我们"
                cellview?.showLabel.text = ""
                cell?.accessoryType = .disclosureIndicator
                cellview?.showLabel.right_sd = KScreenWidth - 35
                break
                
            case 5:
                cellview?.titleLabel.text = "用户协议"
                cellview?.showLabel.text = ""
                cell?.accessoryType = .disclosureIndicator
                cellview?.showLabel.right_sd = KScreenWidth - 35
                break
                
            case 6:
                cellview?.titleLabel.text = "实名认证"
                cell?.accessoryType = .disclosureIndicator
                cellview?.showLabel.text = ""
                cellview?.showLabel.right_sd = KScreenWidth - 35

                if (user?.authtype ?? 0) == 0{
                    cell?.accessoryType = .disclosureIndicator
                }else if (user?.authtype ?? 0) == 1{
                    cellview?.showLabel.text = "已认证"
                    cell?.accessoryType = .none
                    cellview?.showLabel.right_sd = KScreenWidth - 12
                }else{
                    cell?.accessoryType = .none
                    cellview?.showLabel.text = "正在审核"
                    cellview?.showLabel.right_sd = KScreenWidth - 12
                }
                break
            default: break
            }
        }
            
        if indexPath.section == 1{
            switch indexPath.row{
            case 0 :
                cellview?.titleLabel.text = "清除缓存"
                cellview?.showLabel.textColor = UIColor.baseColor
                cellview?.showLabel.text = cacheNum
                break
                
            case 1:
                cellview?.titleLabel.text = "当前版本"
                cellview?.showLabel.textColor = UIColor.baseColor
                cellview?.showLabel.text = "V" + DeviceConfig.appVersion
                break
                
            case 2:
                cellview?.titleLabel.text = "退出登录"
                cellview?.showLabel.text = ""
                break
    
            default: break
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return F_I6(place: 44)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as? SetCell

        if indexPath.section == 0{
            switch indexPath.row{
            case 0 :
                //TODO:手机号修改
                let vc = ChangePhoneVC.init()
                vc.lastVC = self
                self.navigationController?.pushViewController(vc, animated: true)
                break
                
            case 1:
                //TODO:QQ绑定解绑
                if cell?.thirdmodel != nil{
                    self.requestForDeletThird(third: (cell?.thirdmodel)!, alterTitle: "你确定解绑QQ?")
                }else{
                    self.showGifView()
                    ThirdLoginManager.shareInstance().thirdQQLogin(resultBlock: {[weak self] (type, msg, result) in
                        if type == 1{
                            var openid : String = ""
                            let headimg : String?
                            if result != nil{
                                let dic = result as! Dictionary<String,String>
                                openid = dic["openid"]!;
                                headimg = dic["headimg"];
                            }
                            self?.requestForThirdLogin(type: 3, info:openid)
                        }else{
                            self?.hiddenGifView()
                            WFHudView.showMsg(msg ?? "QQ授权失败", in: self?.view)
                        }
                    })
                }
                break
                
            case 2:
                //TODO:微信绑定解绑
                if cell?.thirdmodel != nil{
                    self.requestForDeletThird(third: (cell?.thirdmodel)!, alterTitle: "你确定解绑微信?")
                }else{
                    ThirdLoginManager.shareInstance().thirdWeChatLogin { [weak self] (type, msg, result) in
                        if type == 1{
                            self?.requestForThirdLogin(type: 2, info: result! as! String);
                        }else{
                            self?.hiddenGifView()
                            WFHudView.showMsg(msg ?? "微信授权失败", in: self?.view)
                        }
                    }
                }
                break
                
            case 3:
                //TODO:消息通知
                let vc = SetMessageVC.init()
                vc.lastVC = self
                self.navigationController?.pushViewController(vc, animated: true)
                break
                
            case 4:
                //TODO:关于我们
                let vc = webVC.init()
                vc.loadWebURLSring(ClanAPI.H5_aboutUs)
                vc.titleStr = "关于我们"
                self.navigationController?.pushViewController(vc, animated: true)
                break
                
            case 5:
                //TODO:用户协议
                let vc = webVC.init()
                vc.loadWebURLSring(ClanAPI.H5_agreement)
                vc.titleStr = "协议"
                self.navigationController?.pushViewController(vc, animated: true)
                break
                
            case 6:
                //TODO:实名认证
                if cell?.cellview.showLabel.text == ""{
                    let vc = CertiVC.init()
                    vc.lastVC = self
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                break
            default: break
            }
        }
        
        if indexPath.section == 1{
            switch indexPath.row{
            case 0 :
                //TODO:清除缓存
                self.clearCatch(alterTitle: "清除"+cacheNum+"缓存" )
                break
            case 1:

                //TODO:版本更新
                let dic = PLGlobalClass.getValueFromFile(CUKey.kStartupInfo, withKey: CUKey.kStartupInfo) as? Dictionary<String, Any>
                let version = dic!["version"] as? String
                if version == DeviceConfig.appVersion{
                    WFHudView.showMsg("已经是最新版本", in: self.view)
                }else{
                    self.setAlter()
                    self.alterV?.infoLab.text = "发现新版本" + (version ?? "")
                    self.lew_presentPopupView(self.alterV, animation: self.animation, backgroundClickable: true)
                    alterV?.btnClickBlock  = {
                        let str = "http://itunes.apple.com/app/id1340881105"
                        UIApplication.shared.openURL(URL.init(string: str)!)
                    }
                }
                break
                
            case 2:
                //TODO:退出登录
                GlobalClass.logout()
                break
                
            default: break
            }
        }
    }
    
    
    ///   - type:  2-微信登陆；3- QQ登陆
    ///   - codeOpenid: 微信对应code，qq对应openid
    func requestForThirdLogin(type:Int,info:String) -> Void{
        //网络请求
        ClanAPI.requestForBindThirdLogin(usertype: type, codeOpenid: info)
        {[weak self] (result) in
            self?.hiddenGifView()
            
            if result.status == "200"{
                //登录成功
                let thi = ThirdUser.init()
                thi.openid = info
                thi.usertype = type
                
                self?.user?.thirdUsers.add(thi)
                UserServre.shareService.cacheSaveRefresh()
                self?.tableView.reloadData()
                WFHudView.showMsg(result.message ?? "绑定成功", in: self?.view)
            }else{
                WFHudView.showMsg(result.message ?? "绑定失败", in: self?.view)
            }
        }
    }
    
    func requestForDeletThird(third:ThirdUser,alterTitle:String) -> Void{
        //解绑
        self.setAlter()
        self.alterV?.infoLab.text = alterTitle
        self.lew_presentPopupView(self.alterV, animation: self.animation, backgroundClickable: true)
        
        alterV?.btnClickBlock  = {[weak self] in
            self?.showGifView()
            //网络请求
            ClanAPI.requestForDeleteThirdLogin(openid: third.openid){[weak self , weak third](result) in
                self?.hiddenGifView()
                if result.status == "200"{
                    //解绑成功
                    self?.user?.thirdUsers.remove(third!)
                    UserServre.shareService.userModel = self?.user
                    UserServre.shareService.cacheSaveRefresh()
                    self?.tableView.reloadData()
                    WFHudView.showMsg(result.message ?? "解绑成功", in: self?.view)
                }else{
                    WFHudView.showMsg(result.message ?? "解绑失败", in: self?.view)
                }
            }
        }
    }
    
    func clearCatch(alterTitle:String) -> Void{
        
        if cacheNum == "0.00M"{
            WFHudView.showMsg("没有需要清理的缓存", in: self.view)
        }else{
            self.setAlter()
            
            self.alterV?.infoLab.text = alterTitle
            self.lew_presentPopupView(self.alterV, animation: self.animation, backgroundClickable: true)
            
            alterV?.btnClickBlock  = { [weak self] in
                PLClearCacheTool.cleanCache({
                    WFHudView.showMsg("清除成功", in: self?.view)
                    self?.cacheNum = "0.00M"
                    self?.tableView.reloadData()
                })
            }
        }
    }
    
    func setAlter(){
        if self.animation == nil{
            let animation = LewPopupViewAnimationSlide.init()
            animation.type = LewPopupViewAnimationSlideType.bottomBottom
            self.animation = animation
            
            let alterView = msgAlterView.init(frame: CGRect.init(x: 0, y: 0, width: F_I6(place: 251), height:  102), parentVC: self, dismiss: self.animation, title: "")
            self.alterV = alterView
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



//MARK: - ----------------更改手机号
class ChangePhoneVC: KBaseClanViewController,UITextFieldDelegate {
    
    var header  = PersonalHeaderView()
    var ifFront = false
    var frontBtn = UIButton()
    var backsideBtn = UIButton()
    var lastVC : setVC?

    
    //MARK: - 加载页面 绘制UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.knavigationBar?.cutlineColor = UIColor.clear
        self.knavigationBar?.title = "更改手机号"
        let user = UserServre.shareService.userModel
        
        let tfTelephone = UITextField.init(frame: CGRect.init(x: 10, y: KTopHeight + F_I6(place: 5), width: KScreenWidth-20, height: F_I6(place: 47)))
        tfTelephone.placeholder = "请输入手机号"
        tfTelephone.textColor = UIColor.textColor2
        tfTelephone.font = UIFont.systemFont(ofSize: 12)
        tfTelephone.setValue(UIColor.textColor2, forKeyPath: "_placeholderLabel.textColor")
        tfTelephone.keyboardType = .numberPad
        tfTelephone.returnKeyType = .done
        tfTelephone.delegate = self
        self.view.addSubview(tfTelephone)
        tfTelephone.addTarget(self, action: #selector(wordlimitTelephone(withTf:)), for: UIControlEvents.editingChanged)
        
        let tfcode = UITextField.init(frame: CGRect.init(x: tfTelephone.left_sd, y: tfTelephone.bottom_sd, width: KScreenWidth - F_I6(place: 100), height:F_I6(place: 47)))
        tfcode.placeholder = "请输入验证码"
        tfcode.textColor = UIColor.textColor2
        tfcode.font = UIFont.systemFont(ofSize: 12)
        tfcode.keyboardType = .numberPad
        tfcode.returnKeyType = .done
        tfcode.delegate = self
        self.view.addSubview(tfcode)
        tfcode.setValue(UIColor.textColor2, forKeyPath: "_placeholderLabel.textColor")
        
        let getcodeBtn = UIButton.init(frame: CGRect.init(x: KScreenWidth-F_I6(place: 90), y: 0, width: F_I6(place: 75), height: F_I6(place: 25)))
        getcodeBtn.setBackgroundImage(UIImage.init(named: "btnBG"), for: UIControlState.normal)
        getcodeBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        getcodeBtn.setTitle("获取验证码", for: UIControlState.normal)
        getcodeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        getcodeBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        self.view.addSubview(getcodeBtn)
        getcodeBtn.centerY_sd = tfcode.centerY_sd
        
        getcodeBtn.handleEventTouchUpInside {[weak self , weak getcodeBtn , weak tfTelephone] in
            
            if tfTelephone?.text == user?.username{
                WFHudView.showMsg("不能改为当前手机号", in: self?.view)
                return
            }
            
            if (tfTelephone?.text?.count ?? 0) == 11 {
                getcodeBtn?.isUserInteractionEnabled = false
                ClanAPI.requestForsmscode(username: (tfTelephone?.text!)!, result: { (result) in
                    if ((result.status) == "200"){
                        WFHudView.showMsg("短信已发送", in: self?.view)
                    }
                })
                
                PLGlobalClass.queryGCD(withTimeout: 60, handleChangeCountdownBlock: { (timeStr) in
                    getcodeBtn?.setTitle("\(timeStr)"+"s", for: UIControlState.normal)
                    
                }, handleStopCountdownBlock: { (timeStr) in
                    getcodeBtn?.setTitle("获取验证码", for: UIControlState.normal)
                    getcodeBtn?.isUserInteractionEnabled = true
                })
            }else{
                WFHudView.showMsg("请输入正确的手机号", in: self?.view)
                return
            }
        }
        
        let line1 = UILabel.init(frame: CGRect.init(x: 0, y: tfTelephone.bottom_sd, width: KScreenWidth, height: 0.5))
        line1.backgroundColor = UIColor.cutLineColor
        self.view.addSubview(line1)
        
        let line2 = UILabel.init(frame: CGRect.init(x: 0, y: tfcode.bottom_sd, width: line1.width_sd, height: 0.5))
        line2.backgroundColor = UIColor.cutLineColor
        self.view.addSubview(line2)
        
        //TODO:更改手机号
        let nextBtn = UIButton.init(frame: CGRect.init(x: F_I6(place: 107), y: F_I6(place: 393) + KTopHeight, width: F_I6(place: 160), height: 44))
        nextBtn.setBackgroundImage(UIImage.init(named: "BG"), for: UIControlState.normal)
        nextBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        nextBtn.setTitle("确   定", for: UIControlState.normal)
        nextBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        nextBtn.layer.cornerRadius = 5
        nextBtn.clipsToBounds = true

        self.view.addSubview(nextBtn)
        nextBtn.handleEventTouchUpInside {[weak self , weak tfTelephone , weak tfcode ] in
            
            if tfTelephone?.text == user?.username{
                WFHudView.showMsg("不能改为当前手机号", in: self?.view)
                return
            }
            
            if (tfTelephone?.text!.count != 11){
                WFHudView.showMsg("请输入11位手机号", in: self?.view)
                return
            }
            if (tfcode?.text!.count == 0){
                WFHudView.showMsg("请输入验证码", in: self?.view)
                return
            }
            
            self?.showGifView()

            ClanAPI.requestForChangeUsername(newPhone: (tfTelephone?.text!)!, smscode: (tfcode?.text!)!, result: { (result) in
                
                self?.hiddenGifView()
                if ((result.status) == "200"){
                    WFHudView.showMsg("修改成功，请重新登录", in: self?.view)
                    GlobalClass.logout()
                }else{
                    if (result.message.count>0){
                        WFHudView.showMsg(result.message, in: self?.view)
                    }else{
                        WFHudView.showMsg("登录失败", in: self?.view)
                    }
                }
            })
        }
        
        let str = "当前手机号为" + (user?.username)!
        
        let strArr =  [str,"更换手机号后，当前账户信息以及享有的权益均保持不变","更换成功后请使用新手机号登录","30天内只能修改一次手机号"]
        
        var bottom = F_I6(place: 139) + KTopHeight
        //四行字
        for i in 0...3{
            let point = UIImageView.init(frame: CGRect.init(x: 12, y: 0, width:4 , height: 4))
            point.image = UIImage.init(named: "littlePoint")
            self.view.addSubview(point)
            
            let lab = UILabel.init(frame: CGRect.init(x: 24, y: bottom, width:KScreenWidth - 48 , height: 20))
            lab.text = strArr[i]
            lab.numberOfLines = 0
            self.view.addSubview(lab)
            if i == 0{
                lab.font = UIFont.systemFont(ofSize: 15)
                lab.textColor = UIColor.textColor1
                point.top_sd = bottom + 5.5
            }else{
                lab.font = UIFont.systemFont(ofSize: 12)
                lab.textColor = UIColor.textColor2
                point.top_sd = bottom + 4
            }
            
            lab.sizeToFit()
            lab.width_sd = KScreenWidth - 48
            bottom = lab.bottom_sd + 24
        }
    }
    

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


//MARK: - ----------------消息通知
class SetMessageVC: KBaseClanViewController {
    
    var header  = PersonalHeaderView()
    var ifFront = false
    var frontBtn = UIButton()
    var backsideBtn = UIButton()
    var lastVC : setVC?
    
    override func kBackBtnAction() {
        super.kBackBtnAction()
        self.lastVC?.reloadTable()
    }

    //MARK: - 加载页面 绘制UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.knavigationBar?.cutlineColor = UIColor.clear
        self.knavigationBar?.title = "消息通知"
        self.view.backgroundColor = UIColor.cutLineColor
        
        let view = TitleAndText.init(frame: CGRect.init(x: 0, y: KTopHeight+6, width: KScreenWidth, height: F_I6(place:44)))
        view.titleLabel.text = "消息免打扰"
        view.backgroundColor = UIColor.white
        self.view.addSubview(view)
        
        let seleSwitch =  UISwitch.init(frame: .init(x: KScreenWidth-25-44, y: 0, width: 0, height: 0))
        seleSwitch.centerY_sd = F_I6(place: 22)
        view.addSubview(seleSwitch)
        seleSwitch.onTintColor = UIColor.baseColor
        seleSwitch.addTarget(self, action: #selector(messageset(swi:)), for: .touchUpInside)
        
        let closeNotice = PLGlobalClass.getValueFromFile(CUKey.kStartupInfo, withKey: CUKey.kStartupInfo_CloseNotice) as? Bool
        if closeNotice == true{
            seleSwitch.isOn = false
        }else{
            seleSwitch.isOn = true
        }
        
        let strArr =  ["推送消息可在消息中心查看"]
        
        var bottom = view.bottom_sd + 10
        //字
        for i in 0...strArr.count-1{
            let point = UIImageView.init(frame: CGRect.init(x: 12, y: 0, width:4 , height: 4))
            point.image = UIImage.init(named: "littlePoint")
            self.view.addSubview(point)
            
            let lab = UILabel.init(frame: CGRect.init(x: 24, y: bottom, width:KScreenWidth - 48 , height: 20))
            lab.text = strArr[i]
            lab.numberOfLines = 0
            self.view.addSubview(lab)

            lab.font = UIFont.systemFont(ofSize: 12)
            lab.textColor = UIColor.textColor2
            point.top_sd = bottom + 4
            
            lab.sizeToFit()
            lab.width_sd = KScreenWidth - 48
            bottom = lab.bottom_sd + 24
        }
        
    }
    
    func messageset(swi : UISwitch){
        if swi.isOn{
            APPDELEGATE.registerNotfication()
            PLGlobalClass.write(toFile: CUKey.kStartupInfo, withKey: CUKey.kStartupInfo_CloseNotice, value: false)
            ClanAPI.requestForupdateDeviceToken(result: { (result) in
                
            })
        }else{
            UIApplication.shared.unregisterForRemoteNotifications()
            PLGlobalClass.write(toFile: CUKey.kStartupInfo, withKey: CUKey.kStartupInfo_CloseNotice, value: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}




//MARK: - ----------------实名认证页
class CertiVC: KBaseClanViewController {
    
    var header  = PersonalHeaderView()
    var ifFront = false
    var frontBtn : KButton?
    var backsideBtn : KButton?
    var lastVC : setVC?

    //MARK: - 加载页面 绘制UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.knavigationBar?.cutlineColor = UIColor.clear
        self.knavigationBar?.title = "实名认证"
        
        frontBtn = KButton.init(frame: CGRect.init(x: F_I6(place: 27), y: F_I6(place: 90), width: F_I6(place: 320), height: F_I6(place: 158)), needMengban: false)
        frontBtn?.setImage(UIImage.init(named: "add_circle"), for: .normal)
        frontBtn?.layer.cornerRadius = 5
        frontBtn?.clipsToBounds = true
        frontBtn?.backgroundColor = UIColor.baseColor
        self.view.addSubview(frontBtn!)
        
        backsideBtn = KButton.init(frame: CGRect.init(x: F_I6(place: 27), y: (frontBtn?.bottom_sd)! + F_I6(place: 17), width: F_I6(place: 320), height: F_I6(place: 158)), needMengban: false)
        backsideBtn?.setImage(UIImage.init(named: "add_circle"), for: .normal)
        backsideBtn?.layer.cornerRadius = 5
        backsideBtn?.clipsToBounds = true
        backsideBtn?.backgroundColor = UIColor.baseColor
        self.view.addSubview(backsideBtn!)
        
        let nextBtn = UIButton.init(frame: CGRect.init(x: F_I6(place: 97), y: F_I6(place: 470), width: F_I6(place: 180), height: F_I6(place: 48)))
        nextBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        nextBtn.backgroundColor = UIColor.baseColor
        nextBtn.setTitle("完   成", for: UIControlState.normal)
        nextBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        self.view.addSubview(nextBtn)
        
        let lab1 = UILabel.init(frame: CGRect.init(x: F_I6(place: 19), y: F_I6(place: 18), width: (frontBtn?.width_sd)! - F_I6(place: 38), height: F_I6(place: 20)))
        lab1.text = "身份证正面"
        lab1.textColor = UIColor.white
        frontBtn?.addSubview(lab1)
        
        let lab2 = UILabel.init(frame: CGRect.init(x: F_I6(place: 19), y: F_I6(place: 18), width: (frontBtn?.width_sd)! - F_I6(place: 38), height: F_I6(place: 20)))
        lab2.text = "身份证背面"
        lab2.textColor = UIColor.white
        backsideBtn?.addSubview(lab2)
        
        frontBtn?.handleEventTouchUpInside {[weak self] in
            self?.ifFront = true
            PLGlobalClass.openCameraIsAllowsEditing(false, videotape: false)
        }
        backsideBtn?.handleEventTouchUpInside {[weak self] in
            self?.ifFront = false
            PLGlobalClass.openCameraIsAllowsEditing(false, videotape: false)
        }
        
        nextBtn.handleEventTouchUpInside {[weak self] in
            self?.requestForAuth()
        }
    }
    
    func requestForAuth(){
        var idfrontStr = ""
        var idbackStr = ""
        
        
        let idfrontModel = self.frontBtn?.attribute as? uploadfilesModel
        
        if idfrontModel?.path.count ?? 0 > 0{
            idfrontStr = (idfrontModel?.path)!
        }else{
            WFHudView.showMsg("请上传身份证正面图", in: self.view)
            return
        }
        
        let idbackModel = self.backsideBtn?.attribute as? uploadfilesModel
        
        if idbackModel?.path.count ?? 0 > 0{
            idbackStr = (idbackModel?.path)!
        }else{
            WFHudView.showMsg("请上传身份证反面图", in: self.view)
            return
        }
        
        ClanAPI.requestForauth(idfrontimg: idfrontStr, idbackimg: idbackStr) {[weak self] (result) in
            if ((result.status) == "1"){
                WFHudView.showMsg("提交成功", in: self?.view)
                
                //认证类型 0为认证 1 已认证 其他 审核中
                let user = UserServre.shareService.userModel
                user?.authtype = 2
                UserServre.shareService.cacheSaveRefresh()
                self?.navigationController?.popViewController(animated: true)
                self?.lastVC?.reloadTable()
            }else{
                WFHudView.showMsg(result.message ?? "认证失败", in: self?.view)
            }
        }
    }
    
    
    //MARK: - UIImagePickerControllerDelegate选择好图片的回调
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if (info["UIImagePickerControllerMediaType"] as? String == "public.movie") {
        }else{
            //拿到选择的图片
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            let qualitydata = PLGlobalClass.compressImageQuality(image)
            
            //相册消失
            picker.dismiss(animated: true) {
                DispatchQueue.main.async(execute: {
                    if ( self.ifFront == true){
                        self.frontBtn?.setImage(image, for: .normal)
                        GlobalClass.requestToupdateFile(type: .IMG, realType: nil, files: [qualitydata!], imageBtn: self.frontBtn!)
                    }else{
                        self.backsideBtn?.setImage(image, for: .normal)
                        GlobalClass.requestToupdateFile(type: .IMG, realType: nil, files: [qualitydata!], imageBtn: self.backsideBtn!)
                    }
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}




//MARK: - ----------------设置cell
class SetCell: UITableViewCell {
    
    var cellview = TitleAndTextField()
    
    var thirdmodel : ThirdUser?{
        didSet {
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        cellview = TitleAndTextField.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: F_I6(place: 44)))
        cellview.titleLabel.font = UIFont.systemFont(ofSize: 15)
        cellview.showLabel.font = UIFont.systemFont(ofSize: 14)
        cellview.titleLabel.textColor = UIColor.textColor1
        cellview.showLabel.isUserInteractionEnabled = false
        cellview.tag = 13
        self.contentView.addSubview(cellview)
        
        cellview.showLabel.height_sd = 15
        cellview.showLabel.centerY_sd = cellview.titleLabel.centerY_sd
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

