import UIKit
import MJRefresh



//MARK: - ----------------投诉页面
class ComplaintVC: KBaseClanViewController {
    
    var reasonArr = NSMutableArray.init(capacity: 0)
    var picBtnArr = NSMutableArray.init(capacity: 0)

    
    var ifPerson = true  //是否是投诉个人
    var selectIndex = 0
    var whiteView1 = UIView()
    var whiteView2 = UIView()
    var scroll = UIScrollView()
    var addBtn = UIButton()
    var nextBtn = UIButton()
    var agreement = UIButton()
    var complaintId = "" //投诉id，投诉人传人的id，投诉群传群的id

    /// 弹窗
    lazy var animation : LewPopupViewAnimationSlide = {
        let anima = LewPopupViewAnimationSlide.init()
        anima.type = LewPopupViewAnimationSlideType.bottomBottom
        return anima
    }()
    lazy var alterV : msgAlterView = {
        let alterView = msgAlterView.init(frame: CGRect.init(x: 0, y: 0, width: F_I6(place: 251), height: 102), parentVC: self, dismiss: self.animation, title: "投诉成功")
        alterView?.btnArr = ["确定"]
        alterView?.btnClickBlock = {[weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        return alterView!
    }()
    
    
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.knavigationBar?.cutlineColor = UIColor.clear
        self.knavigationBar?.title = "投诉"
        var type = "1"
        
//        self.setAlter()
        
        if ifPerson == true{
            reasonArr = NSMutableArray.init(array: ["发布不适当内容对我造成骚扰","存在欺诈骗钱行为","此账号可能被盗用","其他"])
            type = "1"
        }else{
            reasonArr = NSMutableArray.init(array: ["群成员存在赌博行为","群成员存在欺诈骗钱行为","群成员发布不适当的信息对我造成骚扰","群成员传播谣言信息","其他"])
            type = "2"
        }
        
        scroll = UIScrollView.init(frame: CGRect.init(x: 0, y: KTopHeight, width: KScreenWidth, height: KScreenHeight - KTopHeight))
        scroll.backgroundColor = UIColor.bgColor5
        self.view.addSubview(scroll)
        
        whiteView1 = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 60))
        whiteView1.backgroundColor = UIColor.white
        scroll.addSubview(whiteView1)
        
        whiteView2 = UIView.init(frame: CGRect.init(x: 0, y: 70, width: KScreenWidth, height: 114))
        whiteView2.backgroundColor = UIColor.white
        scroll.addSubview(whiteView2)
        
        addBtn = UIButton.init(frame: CGRect.init(x: 12 , y: 45, width: 50, height: 50))
        addBtn.setImage(UIImage.init(named: "createAdd"), for:  .normal)
        whiteView2.addSubview(addBtn)
        addBtn.handleEventTouchUpInside {[weak self] in
            
            PLGlobalClass.openAlter(withMaxNumber: 3 - (self?.picBtnArr.count ?? 0) , blockHandler: { (array) in
                for assestModel in array!{
                    let model = assestModel as? ZLPhotoAssets
                    let image = model?.originImage
                    let qualitydata = PLGlobalClass.compressImageQuality(image)
                    if qualitydata != nil && image != nil{
                        
                        self?.addaImage(image: image!, data: qualitydata!)
                    }
                }
            })
        }
        
        let lab = UILabel.init(frame: CGRect.init(x: 12, y: 0, width: KScreenWidth-24, height: 44))
        lab.text = "投诉原因:"
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textColor = UIColor.textColor1
        scroll.addSubview(lab)
        
        let lab2 = UILabel.init(frame: CGRect.init(x: 12, y: 0, width: KScreenWidth-24, height: 44))
        lab2.text = "图片证据"
        lab2.font = UIFont.systemFont(ofSize: 14)
        lab2.textColor = UIColor.textColor1
        whiteView2.addSubview(lab2)
        
        self.reloadReson()
        
        nextBtn = UIButton.init(frame: CGRect.init(x: 12, y: F_I6(place: 404), width: KScreenWidth-24, height: 44))
        nextBtn.setBackgroundImage(UIImage.init(named: "BG"), for: UIControlState.normal)
        nextBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        nextBtn.setTitle("提   交", for: UIControlState.normal)
        nextBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        scroll.addSubview(nextBtn)
        nextBtn.layer.cornerRadius = 5
        nextBtn.clipsToBounds = true
        nextBtn.handleEventTouchUpInside {[weak self] in
            self?.nextBtn.isUserInteractionEnabled = false
            
            var attachpathStr = ""
            
            for btn in (self?.picBtnArr)!{
                let imageBtn = btn as? KButton
                let uploadmodel = imageBtn?.attribute as? uploadfilesModel
                if (uploadmodel != nil){
                    if uploadmodel!.id.count > 0{
                        if (attachpathStr.count == 0) {
                            //第一次不拼接逗号
                            attachpathStr.append(uploadmodel!.path)
                            if attachpathStr.count == 0{
                                WFHudView.showMsg("请等待附件上传完成", in: self?.view)
                                self?.nextBtn.isUserInteractionEnabled = true
                                return
                            }
                        }else{
                            attachpathStr.append("," + uploadmodel!.path)
                            if uploadmodel!.path.count == 0{
                                WFHudView.showMsg("请等待图片上传完成", in: self?.view)
                                self?.nextBtn.isUserInteractionEnabled = true
                                return
                            }
                        }
                    }
                }else{
                    WFHudView.showMsg("请等待附件上传完成", in: self?.view)
                    self?.nextBtn.isUserInteractionEnabled = true
                    return
                }
            }
            
            ClanAPI.requestForSubmitComplaint(type: type, content:self?.reasonArr[self?.selectIndex ?? 0] as! String , imgs: attachpathStr, targetid: self?.complaintId, groupid: self?.complaintId, result: { (result) in
                
                self?.nextBtn.isUserInteractionEnabled = true
                if result.status == "200"{
                    print("弹框提示成功")
                    
                    self?.lew_presentPopupView(self?.alterV, animation: self?.animation, backgroundClickable: true)
//                    alterV?.btnClickBlock  = {
//                        let str = "http://itunes.apple.com/app/id1340881105"
//                        UIApplication.shared.openURL(URL.init(string: str)!)
//                    }
                    
                }else{
                    WFHudView.showMsg("投诉失败", in: self?.view)
                }
            })
        }
        
        agreement = UIButton.init(frame: CGRect.init(x: (KScreenWidth-80)/2, y: KScreenHeight-KTopHeight-65, width:80, height: 44))
        agreement.setTitleColor(UIColor.orange, for: UIControlState.normal)
        agreement.setTitle("投诉须知", for: UIControlState.normal)
        agreement.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        scroll.addSubview(agreement)
        agreement.handleEventTouchUpInside {[weak self] in
            if APPDELEGATE.networkStatus == 0{
                WFHudView.showMsg(TextDefault.noNetWork, in: self?.view)
            }else{
                let vc = webVC.init()
                vc.loadWebURLSring(ClanAPI.H5_complaintToKnow)
                vc.titleStr = "投诉须知"
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    
    func reloadReson(){
        
        let H = 44
        
        if reasonArr.count > 0{
            for i in 0 ... reasonArr.count-1{
                let reson = reasonArr[i]
                
                if reson is String{
                    let str = reson as! String
                    
                    let btn = UIButton.init(frame: CGRect.init(x: 12, y: 44 + H*i, width: Int(KScreenWidth-24), height:H))
                    
                    btn.setImage(UIImage.init(named: "noselected_big"), for: UIControlState.normal)
                    btn.setImage(UIImage.init(named: "selected_big"), for: UIControlState.selected)
                    btn.setTitleColor(UIColor.textColor1, for: UIControlState.normal)
                    btn.setTitle(str, for: UIControlState.normal)
                    btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                    if i == 0{
                        btn.isSelected = true
                    }else{
                        btn.isSelected = false
                    }
                    btn.tag = 200 + i
                    scroll.addSubview(btn)
                    btn.contentHorizontalAlignment = .left
                    PLGlobalClass.setBtnStyle(btn, style: ButtonEdgeInsetsStyleReferToImage.imageLeft, space: 5)
                    
                    whiteView1.height_sd = btn.bottom_sd
                    whiteView2.top_sd = whiteView1.bottom_sd + 5
                    nextBtn.top_sd = whiteView2.bottom_sd + 35

                    if whiteView2.bottom_sd + 80 > KScreenHeight-KTopHeight{
                        if whiteView2.bottom_sd + 40 > KScreenHeight-KTopHeight{
                            agreement.top_sd =  nextBtn.bottom_sd + 35
                        }else{
                            agreement.top_sd =  KScreenHeight-KTopHeight-65
                        }
                    }
                    
                    btn.handleEventTouchUpInside(callback: {[weak self] in
                        self?.selectIndex = i
                        
                        for  j in 0 ... (self?.reasonArr.count ?? 0) - 1{
                            let view = self?.view.viewWithTag(200 + j) as? UIButton
                            if j == self?.selectIndex{
                                view?.isSelected = true
                            }else{
                                view?.isSelected = false
                            }
                        }
                    })
                }
            }
        }
    }
    
    
    //TODO:添加一个图片，刷EnclosureView
    func addaImage(image:UIImage ,data:Data ) {
        let W = CGFloat(50)
        let count = picBtnArr.count
        
        let imageBtn = KButton.init(frame: CGRect.init(x: 12 + (W + 5) * CGFloat(count), y: 45, width: W, height: W), needMengban:true)
        imageBtn.backgroundColor = UIColor.black
        imageBtn.imageView?.contentMode = .scaleAspectFill
        imageBtn.setImage(image, for:  .normal)
        
//        let deleimage = UIButton.init(frame: CGRect.init(x: W-20, y: 0, width: 20, height: 20))
//        deleimage.setImage(UIImage.init(named: "close"), for: .normal)
//        imageBtn.addSubview(deleimage)
//        deleimage.handleEventTouchUpInside(callback: {[weak self,weak imageBtn] in
//            //删除一个图片，刷图片列表
//            self?.reloadenclosureViewWithDeleteImageBtn(imageBtn: imageBtn!)
//        })
        
        whiteView2.addSubview(imageBtn)
        picBtnArr.add(imageBtn)
        
        if picBtnArr.count >= 3{
            addBtn.isHidden = true
        }else{
            addBtn.isHidden = false
            addBtn.left_sd = 12 + (W + 5) * CGFloat(picBtnArr.count)
        }
        
//        let deleBtn = KNaviBarBtnItem.init(frame: CGRect.init(x: KScreenWidth-60, y: KStatusBarHeight, width: 44, height: 44), image: "deleteBig") { [weak self , weak imageBtn](sender) in
//            //删除一个图片，刷图片列表
//            self?.reloadenclosureViewWithDeleteImageBtn(imageBtn: imageBtn!)
//        }
//        let img = UIImage.init(named: "deleteBig")?.withRenderingMode(.alwaysOriginal)
//        deleBtn.button.setImage(img, for: .normal)
//        imageBtn.littleFrame = imageBtn.frame
//
//        imageBtn.handleEventTouchUpInside(callback: {[weak self , weak imageBtn] in
//
//            self?.view.endEditing(true)
//            imageBtn?.isSelected = !(imageBtn?.isSelected)!
//            imageBtn?.mengban?.alpha = 0
//            if (imageBtn?.isSelected)!{
//                //放大动画效果
//                imageBtn?.frame = CGRect.init(x: (imageBtn?.littleFrame.origin.x)!  - (self?.EnclosureView.contentOffset.x)! , y: (self?.EnclosureView.top_sd)!+(imageBtn?.littleFrame.origin.y)!, width: (imageBtn?.littleFrame.width)!, height: (imageBtn?.littleFrame.height)!)
//
//                self?.view.addSubview(imageBtn!)
//                deleimage.removeFromSuperview()
//
//                UIView.animate(withDuration: 0.3) {
//                    imageBtn?.frame = CGRect.init(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight)
//                    imageBtn?.addSubview(deleBtn)
//                }
//            }else{
//                imageBtn?.mengban?.alpha = 1
//                //缩小动画效果
//                UIView.animate(withDuration: 0.3, animations: {
//
//                    imageBtn?.frame = CGRect.init(x: (imageBtn?.littleFrame.origin.x)! - (self?.EnclosureView.contentOffset.x)! , y: (self?.EnclosureView.top_sd)!+(imageBtn?.littleFrame.origin.y)!, width: (imageBtn?.littleFrame.width)!, height: (imageBtn?.littleFrame.height)!)
//
//                    deleBtn.removeFromSuperview()
//                    imageBtn?.addSubview(deleimage)
//                }, completion: { (_) in
//                    self?.EnclosureView.addSubview(imageBtn!)
//                    imageBtn?.frame = (imageBtn?.littleFrame)!
//                })
//            }
//        })
        
        //上传
        GlobalClass.requestToupdateFile(type: .IMG, realType: nil, files: [data as Data], imageBtn: imageBtn)
    }
    
//    func setAlter(){
//        if self.animation == nil{
//            let animation = LewPopupViewAnimationSlide.init()
//            animation.type = LewPopupViewAnimationSlideType.bottomBottom
//            self.animation = animation
//
//            let alterView = msgAlterView.init(frame: CGRect.init(x: 0, y: 0, width: F_I6(place: 251), height:  102), parentVC: self, dismiss: self.animation, title: "投诉成功")
//            self.alterV = alterView
//            alterView?.btnArr = ["确定"]
//        }
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



////MARK: - ----------------更改手机号
//class ChangePhoneVC: KBaseClanViewController,UITextFieldDelegate {
//    
//    var header  = PersonalHeaderView()
//    var ifFront = false
//    var frontBtn = UIButton()
//    var backsideBtn = UIButton()
//    var lastVC : setVC?
//
//    
//    //MARK: - 加载页面 绘制UI
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        self.knavigationBar?.cutlineColor = UIColor.clear
//        self.knavigationBar?.title = "更改手机号"
//        let user = UserServre.shareService.userModel
//        
//        let tfTelephone = UITextField.init(frame: CGRect.init(x: 10, y: KTopHeight + F_I6(place: 5), width: KScreenWidth-20, height: F_I6(place: 47)))
//        tfTelephone.placeholder = "请输入手机号"
//        tfTelephone.textColor = UIColor.textColor2
//        tfTelephone.font = UIFont.systemFont(ofSize: 12)
//        tfTelephone.setValue(UIColor.textColor2, forKeyPath: "_placeholderLabel.textColor")
//        tfTelephone.keyboardType = .numberPad
//        tfTelephone.returnKeyType = .done
//        tfTelephone.delegate = self
//        self.view.addSubview(tfTelephone)
//        tfTelephone.addTarget(self, action: #selector(wordlimitTelephone(withTf:)), for: UIControlEvents.editingChanged)
//        
//        let tfcode = UITextField.init(frame: CGRect.init(x: tfTelephone.left_sd, y: tfTelephone.bottom_sd, width: KScreenWidth - F_I6(place: 100), height:F_I6(place: 47)))
//        tfcode.placeholder = "请输入验证码"
//        tfcode.textColor = UIColor.textColor2
//        tfcode.font = UIFont.systemFont(ofSize: 12)
//        tfcode.keyboardType = .numberPad
//        tfcode.returnKeyType = .done
//        tfcode.delegate = self
//        self.view.addSubview(tfcode)
//        tfcode.setValue(UIColor.textColor2, forKeyPath: "_placeholderLabel.textColor")
//        
//        let getcodeBtn = UIButton.init(frame: CGRect.init(x: KScreenWidth-F_I6(place: 90), y: 0, width: F_I6(place: 75), height: F_I6(place: 25)))
//        getcodeBtn.setBackgroundImage(UIImage.init(named: "btnBG"), for: UIControlState.normal)
//        getcodeBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
//        getcodeBtn.setTitle("获取验证码", for: UIControlState.normal)
//        getcodeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
//        getcodeBtn.titleLabel?.adjustsFontSizeToFitWidth = true
//        self.view.addSubview(getcodeBtn)
//        getcodeBtn.centerY_sd = tfcode.centerY_sd
//        
//        getcodeBtn.handleEventTouchUpInside {[weak self , weak getcodeBtn , weak tfTelephone] in
//            
//            if tfTelephone?.text == user?.username{
//                WFHudView.showMsg("不能改为当前手机号", in: self?.view)
//                return
//            }
//            
//            if (tfTelephone?.text?.count ?? 0) == 11 {
//                getcodeBtn?.isUserInteractionEnabled = false
//                ClanAPI.requestForsmscode(username: (tfTelephone?.text!)!, result: { (result) in
//                    if ((result.status) == "200"){
//                        WFHudView.showMsg("短信已发送", in: self?.view)
//                    }
//                })
//                
//                PLGlobalClass.queryGCD(withTimeout: 60, handleChangeCountdownBlock: { (timeStr) in
//                    getcodeBtn?.setTitle("\(timeStr)"+"s", for: UIControlState.normal)
//                    
//                }, handleStopCountdownBlock: { (timeStr) in
//                    getcodeBtn?.setTitle("获取验证码", for: UIControlState.normal)
//                    getcodeBtn?.isUserInteractionEnabled = true
//                })
//            }else{
//                WFHudView.showMsg("请输入正确的手机号", in: self?.view)
//                return
//            }
//        }
//        
//        let line1 = UILabel.init(frame: CGRect.init(x: 0, y: tfTelephone.bottom_sd, width: KScreenWidth, height: 0.5))
//        line1.backgroundColor = UIColor.cutLineColor
//        self.view.addSubview(line1)
//        
//        let line2 = UILabel.init(frame: CGRect.init(x: 0, y: tfcode.bottom_sd, width: line1.width_sd, height: 0.5))
//        line2.backgroundColor = UIColor.cutLineColor
//        self.view.addSubview(line2)
//        
//        //TODO:更改手机号
//        let nextBtn = UIButton.init(frame: CGRect.init(x: F_I6(place: 107), y: F_I6(place: 393) + KTopHeight, width: F_I6(place: 160), height: 44))
//        nextBtn.setBackgroundImage(UIImage.init(named: "BG"), for: UIControlState.normal)
//        nextBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
//        nextBtn.setTitle("确   定", for: UIControlState.normal)
//        nextBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
//        nextBtn.layer.cornerRadius = 5
//        nextBtn.clipsToBounds = true
//
//        self.view.addSubview(nextBtn)
//        nextBtn.handleEventTouchUpInside {[weak self , weak tfTelephone , weak tfcode ] in
//            
//            if tfTelephone?.text == user?.username{
//                WFHudView.showMsg("不能改为当前手机号", in: self?.view)
//                return
//            }
//            
//            if (tfTelephone?.text!.count != 11){
//                WFHudView.showMsg("请输入11位手机号", in: self?.view)
//                return
//            }
//            if (tfcode?.text!.count == 0){
//                WFHudView.showMsg("请输入验证码", in: self?.view)
//                return
//            }
//            
//            self?.showGifView()
//
//            ClanAPI.requestForChangeUsername(newPhone: (tfTelephone?.text!)!, smscode: (tfcode?.text!)!, result: { (result) in
//                
//                self?.hiddenGifView()
//                if ((result.status) == "200"){
//                    WFHudView.showMsg("修改成功，请重新登录", in: self?.view)
//                    GlobalClass.logout()
//                }else{
//                    if (result.message.count>0){
//                        WFHudView.showMsg(result.message, in: self?.view)
//                    }else{
//                        WFHudView.showMsg("登录失败", in: self?.view)
//                    }
//                }
//            })
//        }
//        
//        let str = "当前手机号为" + (user?.username)!
//        
//        let strArr =  [str,"更换手机号后，当前账户信息以及享有的权益均保持不变","更换成功后请使用新手机号登录","30天内只能修改一次手机号"]
//        
//        var bottom = F_I6(place: 139) + KTopHeight
//        //四行字
//        for i in 0...3{
//            let point = UIImageView.init(frame: CGRect.init(x: 12, y: 0, width:4 , height: 4))
//            point.image = UIImage.init(named: "littlePoint")
//            self.view.addSubview(point)
//            
//            let lab = UILabel.init(frame: CGRect.init(x: 24, y: bottom, width:KScreenWidth - 48 , height: 20))
//            lab.text = strArr[i]
//            lab.numberOfLines = 0
//            self.view.addSubview(lab)
//            if i == 0{
//                lab.font = UIFont.systemFont(ofSize: 15)
//                lab.textColor = UIColor.textColor1
//                point.top_sd = bottom + 5.5
//            }else{
//                lab.font = UIFont.systemFont(ofSize: 12)
//                lab.textColor = UIColor.textColor2
//                point.top_sd = bottom + 4
//            }
//            
//            lab.sizeToFit()
//            lab.width_sd = KScreenWidth - 48
//            bottom = lab.bottom_sd + 24
//        }
//    }
//    
//
//    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
//}
//
//
////MARK: - ----------------消息通知
//class SetMessageVC: KBaseClanViewController {
//    
//    var header  = PersonalHeaderView()
//    var ifFront = false
//    var frontBtn = UIButton()
//    var backsideBtn = UIButton()
//    var lastVC : setVC?
//    
//    override func kBackBtnAction() {
//        super.kBackBtnAction()
//        self.lastVC?.reloadTable()
//    }
//
//    //MARK: - 加载页面 绘制UI
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        self.knavigationBar?.cutlineColor = UIColor.clear
//        self.knavigationBar?.title = "消息通知"
//        self.view.backgroundColor = UIColor.cutLineColor
//        
//        let view = TitleAndText.init(frame: CGRect.init(x: 0, y: KTopHeight+6, width: KScreenWidth, height: F_I6(place:44)))
//        view.titleLabel.text = "消息免打扰"
//        view.backgroundColor = UIColor.white
//        self.view.addSubview(view)
//        
//        let seleSwitch =  UISwitch.init(frame: .init(x: KScreenWidth-25-44, y: 0, width: 0, height: 0))
//        seleSwitch.centerY_sd = F_I6(place: 22)
//        view.addSubview(seleSwitch)
//        seleSwitch.onTintColor = UIColor.baseColor
//        seleSwitch.addTarget(self, action: #selector(messageset(swi:)), for: .touchUpInside)
//        
//        let closeNotice = PLGlobalClass.getValueFromFile(CUKey.kStartupInfo, withKey: CUKey.kStartupInfo_CloseNotice) as? Bool
//        if closeNotice == true{
//            seleSwitch.isOn = false
//        }else{
//            seleSwitch.isOn = true
//        }
//        
//        let strArr =  ["推送消息可在消息中心查看"]
//        
//        var bottom = view.bottom_sd + 10
//        //字
//        for i in 0...strArr.count-1{
//            let point = UIImageView.init(frame: CGRect.init(x: 12, y: 0, width:4 , height: 4))
//            point.image = UIImage.init(named: "littlePoint")
//            self.view.addSubview(point)
//            
//            let lab = UILabel.init(frame: CGRect.init(x: 24, y: bottom, width:KScreenWidth - 48 , height: 20))
//            lab.text = strArr[i]
//            lab.numberOfLines = 0
//            self.view.addSubview(lab)
//
//            lab.font = UIFont.systemFont(ofSize: 12)
//            lab.textColor = UIColor.textColor2
//            point.top_sd = bottom + 4
//            
//            lab.sizeToFit()
//            lab.width_sd = KScreenWidth - 48
//            bottom = lab.bottom_sd + 24
//        }
//        
//    }
//    
//    func messageset(swi : UISwitch){
//        if swi.isOn{
//            APPDELEGATE.registerNotfication()
//            PLGlobalClass.write(toFile: CUKey.kStartupInfo, withKey: CUKey.kStartupInfo_CloseNotice, value: false)
//            ClanAPI.requestForupdateDeviceToken(result: { (result) in
//                
//            })
//        }else{
//            UIApplication.shared.unregisterForRemoteNotifications()
//            PLGlobalClass.write(toFile: CUKey.kStartupInfo, withKey: CUKey.kStartupInfo_CloseNotice, value: true)
//        }
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
//}
//
//
//
//
////MARK: - ----------------实名认证页
//class CertiVC: KBaseClanViewController {
//    
//    var header  = PersonalHeaderView()
//    var ifFront = false
//    var frontBtn : KButton?
//    var backsideBtn : KButton?
//    var lastVC : setVC?
//
//    //MARK: - 加载页面 绘制UI
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        self.knavigationBar?.cutlineColor = UIColor.clear
//        self.knavigationBar?.title = "实名认证"
//        
//        frontBtn = KButton.init(frame: CGRect.init(x: F_I6(place: 27), y: F_I6(place: 90), width: F_I6(place: 320), height: F_I6(place: 158)), needMengban: false)
//        frontBtn?.setImage(UIImage.init(named: "add_circle"), for: .normal)
//        frontBtn?.layer.cornerRadius = 5
//        frontBtn?.clipsToBounds = true
//        frontBtn?.backgroundColor = UIColor.baseColor
//        self.view.addSubview(frontBtn!)
//        
//        backsideBtn = KButton.init(frame: CGRect.init(x: F_I6(place: 27), y: (frontBtn?.bottom_sd)! + F_I6(place: 17), width: F_I6(place: 320), height: F_I6(place: 158)), needMengban: false)
//        backsideBtn?.setImage(UIImage.init(named: "add_circle"), for: .normal)
//        backsideBtn?.layer.cornerRadius = 5
//        backsideBtn?.clipsToBounds = true
//        backsideBtn?.backgroundColor = UIColor.baseColor
//        self.view.addSubview(backsideBtn!)
//        
//        let nextBtn = UIButton.init(frame: CGRect.init(x: F_I6(place: 97), y: F_I6(place: 470), width: F_I6(place: 180), height: F_I6(place: 48)))
//        nextBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
//        nextBtn.backgroundColor = UIColor.baseColor
//        nextBtn.setTitle("完   成", for: UIControlState.normal)
//        nextBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
//        self.view.addSubview(nextBtn)
//        
//        let lab1 = UILabel.init(frame: CGRect.init(x: F_I6(place: 19), y: F_I6(place: 18), width: (frontBtn?.width_sd)! - F_I6(place: 38), height: F_I6(place: 20)))
//        lab1.text = "身份证正面"
//        lab1.textColor = UIColor.white
//        frontBtn?.addSubview(lab1)
//        
//        let lab2 = UILabel.init(frame: CGRect.init(x: F_I6(place: 19), y: F_I6(place: 18), width: (frontBtn?.width_sd)! - F_I6(place: 38), height: F_I6(place: 20)))
//        lab2.text = "身份证背面"
//        lab2.textColor = UIColor.white
//        backsideBtn?.addSubview(lab2)
//        
//        frontBtn?.handleEventTouchUpInside {[weak self] in
//            self?.ifFront = true
//            PLGlobalClass.openCameraIsAllowsEditing(false, videotape: false)
//        }
//        backsideBtn?.handleEventTouchUpInside {[weak self] in
//            self?.ifFront = false
//            PLGlobalClass.openCameraIsAllowsEditing(false, videotape: false)
//        }
//        
//        nextBtn.handleEventTouchUpInside {[weak self] in
//            self?.requestForAuth()
//        }
//    }
//    
//    func requestForAuth(){
//        var idfrontStr = ""
//        var idbackStr = ""
//        
//        
//        let idfrontModel = self.frontBtn?.attribute as? uploadfilesModel
//        
//        if idfrontModel?.path.count ?? 0 > 0{
//            idfrontStr = (idfrontModel?.path)!
//        }else{
//            WFHudView.showMsg("请上传身份证正面图", in: self.view)
//            return
//        }
//        
//        let idbackModel = self.backsideBtn?.attribute as? uploadfilesModel
//        
//        if idbackModel?.path.count ?? 0 > 0{
//            idbackStr = (idbackModel?.path)!
//        }else{
//            WFHudView.showMsg("请上传身份证反面图", in: self.view)
//            return
//        }
//        
//        ClanAPI.requestForauth(idfrontimg: idfrontStr, idbackimg: idbackStr) {[weak self] (result) in
//            if ((result.status) == "1"){
//                WFHudView.showMsg("提交成功", in: self?.view)
//                
//                //认证类型 0为认证 1 已认证 其他 审核中
//                let user = UserServre.shareService.userModel
//                user?.authtype = 2
//                UserServre.shareService.cacheSaveRefresh()
//                self?.navigationController?.popViewController(animated: true)
//                self?.lastVC?.reloadTable()
//            }else{
//                WFHudView.showMsg(result.message ?? "认证失败", in: self?.view)
//            }
//        }
//    }
//    
//    
//    //MARK: - UIImagePickerControllerDelegate选择好图片的回调
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        
//        if (info["UIImagePickerControllerMediaType"] as? String == "public.movie") {
//        }else{
//            //拿到选择的图片
//            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
//            let qualitydata = PLGlobalClass.compressImageQuality(image)
//            
//            //相册消失
//            picker.dismiss(animated: true) {
//                DispatchQueue.main.async(execute: {
//                    if ( self.ifFront == true){
//                        self.frontBtn?.setImage(image, for: .normal)
//                        GlobalClass.requestToupdateFile(type: .IMG, realType: nil, files: [qualitydata!], imageBtn: self.frontBtn!)
//                    }else{
//                        self.backsideBtn?.setImage(image, for: .normal)
//                        GlobalClass.requestToupdateFile(type: .IMG, realType: nil, files: [qualitydata!], imageBtn: self.backsideBtn!)
//                    }
//                })
//            }
//        }
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
//}
//
//
//
//
////MARK: - ----------------设置cell
//class SetCell: UITableViewCell {
//    
//    var cellview = TitleAndTextField()
//    
//    var thirdmodel : ThirdUser?{
//        didSet {
//        }
//    }
//    
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        
//        cellview = TitleAndTextField.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: F_I6(place: 44)))
//        cellview.titleLabel.font = UIFont.systemFont(ofSize: 15)
//        cellview.showLabel.font = UIFont.systemFont(ofSize: 14)
//        cellview.titleLabel.textColor = UIColor.textColor1
//        cellview.showLabel.isUserInteractionEnabled = false
//        cellview.tag = 13
//        self.contentView.addSubview(cellview)
//        
//        cellview.showLabel.height_sd = 15
//        cellview.showLabel.centerY_sd = cellview.titleLabel.centerY_sd
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}

