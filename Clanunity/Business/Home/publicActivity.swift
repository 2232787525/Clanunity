
//MARK: - ----------------发布同宗活动
class publicActivity: KBaseClanViewController,UITextViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate {
    let placeStr = "编辑活动内容"
    let placetitleStr = "添加标题"
    
    var camera = UIButton.init()
    var pictureAlbum = UIButton.init()
    var line = UIView.init()
    var addTitle = UIButton.init()
    var textInputView = UITextView()
    var titleInputView = UITextField.init()
    var EnclosureView = UIScrollView.init()
    var imageBtnArr = Array<KButton>()
    var mediatype = "1" //1.无图; 2,单图; 3,多图; 4,视频
    var lastVC : ClubActivity?
    var rightImgBtn : KButton?
    
    var scrollV = UIScrollView ()
    var cover : PLMenuView?      //封面
    var baomingView : PLMenuView?    //报名日期view
    var activityView : PLMenuView?   //活动日期view
    var numOfPeopleView : PLMenuView?//人数
    var helpView : PLMenuView?       //协助商
    var addressView : PLMenuView?    //地图选点
    var addressDetailView : PLMenuView? //详细地址
    
    var activityDate : NSDate?       //活动开始date
    var activityEndDate : NSDate?    //活动结束date
    var baomingDate : NSDate?        //报名开始date
    var baomingEndDate : NSDate?     //报名结束date
    var isCoverImage = false
    var hasCoverImage = false
    
    var chooseAddressView : activityAddressView?      //选择地址view
    
//    var chooseAddressView : UIView?      //选择地址view
    let btnBetw = Float(F_I6(place: 4))
    
    var enclosureIfcanSelected : Bool = true{
        didSet {
            if enclosureIfcanSelected{
                self.camera.isUserInteractionEnabled = true
                self.pictureAlbum.isUserInteractionEnabled = true
                self.camera.alpha = 1
                self.pictureAlbum.alpha = 1
            }else{
                self.camera.isUserInteractionEnabled = false
                self.pictureAlbum.isUserInteractionEnabled = false
                self.camera.alpha = 0.5
                self.pictureAlbum.alpha = 0.5
            }
        }
    }
    
    //MARK: - 懒加载
    lazy var pickerbg: UIView = {
        let tempView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight))
        tempView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
        return tempView
    }()
    lazy var picker: UIDatePicker = {
        
        var width = F_I6(place: 290)
        if KScreenWidth <= 320 {
            width = 300
        }
        
        let temppicker = UIDatePicker.init(frame: CGRect.init(x: (KScreenWidth-width)/2, y: F_I6(place: 170), width: width, height: F_I6(place: 270)))
        temppicker.backgroundColor = UIColor.white
        temppicker.minimumDate = NSDate() as Date
//        temppicker.datePickerMode = .date
        temppicker.datePickerMode = .dateAndTime
        temppicker.minuteInterval = 10
        
        return temppicker
    }()
    lazy var quxiaoBtn: UIButton = {
        let tempBtn = UIButton.init(frame: CGRect.init(x: (KScreenWidth-F_I6(place: 290))/2, y: F_I6(place: 170), width: 80, height: 40))
        tempBtn.setTitle("取消", for: UIControlState.normal)
        tempBtn.setTitleColor(UIColor.textColor1, for: UIControlState.normal)
        tempBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        return tempBtn
    }()
    lazy var queding: UIButton = {
        let tempBtn = UIButton.init(frame: CGRect.init(x: (KScreenWidth-F_I6(place: 290))/2 + F_I6(place: 290) - 80, y: F_I6(place: 170), width: 80, height: 40))
        tempBtn.setTitle("确定", for: UIControlState.normal)
        tempBtn.setTitleColor(UIColor.baseColor, for: UIControlState.normal)
        tempBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        return tempBtn
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        PLGlobalClass.setIQKeyboardToolBarEnable(true, distanceFromTextField: F_I6(place: 50))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        PLGlobalClass.setIQKeyboardToolBarEnable(false, distanceFromTextField: 0)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - 加载页面 绘制UI
    override func viewDidLoad() {
        super.viewDidLoad()
        self.knavigationBar?.title = "发布"
        
        let publicItem = KNaviBarBtnItem.init(frame:  CGRect.init(x: KScreenWidth-44, y: KStatusBarHeight, width: 44, height: 44), title: "完成") { [weak self](sender) in
            self?.publicClick()
        }
        self.knavigationBar?.rightBarBtnItem = publicItem;
        self.scrollView()
        //键盘弹出时
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoard(notification: )), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoard(notification: )), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func scrollView(){
        
        self.scrollV = UIScrollView.init(frame: CGRect.init(x: 0, y: KTopHeight, width: KScreenWidth, height: KScreenHeight-KTopHeight-F_I6(place: 50)))
        self.scrollV.keyboardDismissMode = UIScrollViewKeyboardDismissMode.init(rawValue: 2)!
        self.scrollV.backgroundColor = UIColor.bgColor5
        self.scrollV.showsVerticalScrollIndicator = false
        self.scrollV.showsHorizontalScrollIndicator = false
        self.view.addSubview(self.scrollV)
        
        /// 封面
        self.cover = PLMenuView.init(frame: CGRect.init(x: 0, y: 1, width: KScreenWidth, height: F_I6(place: 77)), title: "上传封面", rightStr: "", rightimg: "createAdd", ifTimeDurding : false ,ifclick: false ,ifClassify : false)
        self.scrollV.addSubview(self.cover!)
        self.cover?.textField.textAlignment = NSTextAlignment.right
        _ = self.cover?.addBottomLine(color: UIColor.cutLineColor)
        
        rightImgBtn = KButton.init(frame: CGRect.init(x: (self.cover?.width_sd)!-10-F_I6(place: 61), y: 0, width: F_I6(place: 61), height: F_I6(place: 61)), needMengban: false)
        rightImgBtn?.centerY_sd = (self.cover?.height_sd)!/2
        self.cover?.textField.isUserInteractionEnabled = false
        rightImgBtn?.imageView?.contentMode = .scaleAspectFill
        rightImgBtn?.setImage(UIImage.init(named: "createAdd"), for: .normal)
        self.cover?.addSubview(rightImgBtn!)
        rightImgBtn?.handleEventTouchUpInside {[weak self] in
            self?.isCoverImage = true
            PLGlobalClass.uploadphotosIfAllowsEditing(false, alsoShowVideo: false)
        }
        self.cover?.rightImgView.removeFromSuperview()
        
        
        /// 所在地区
        self.addressView = PLMenuView.init(frame: CGRect.init(x: 0, y: (self.cover?.bottom_sd)!, width: KScreenWidth, height: 50), title: "所在地区", rightStr: "请选择", rightimg: "rightArrow", ifTimeDurding : false, ifclick: true,ifClassify : false)
        self.scrollV.addSubview(self.addressView!)
        self.addressView?.rightLab.frame = (self.addressView?.textField.frame)!
        self.addressView?.rightLab.numberOfLines = 0
        self.addressView?.rightLab.textColor = UIColor.textColor3

        self.addressView?.textField.isUserInteractionEnabled = false
        self.addressView?.textField.textAlignment = NSTextAlignment.right
        _ = self.addressView?.addBottomLine(color: UIColor.cutLineColor)

        self.addressDetailView = PLMenuView.init(frame: CGRect.init(x: 0, y: (addressView?.bottom_sd)!, width: KScreenWidth, height: 50), title: "活动地址", rightStr: "", rightimg: "", ifTimeDurding : false, ifclick: false,ifClassify : false)
        self.scrollV.addSubview(self.addressDetailView!)
        self.addressDetailView?.textField.textAlignment = NSTextAlignment.right
        self.addressDetailView?.textField.addTarget(self, action: #selector(wordlimitTitle(withTf:)), for: UIControlEvents.editingChanged)
        self.addressDetailView?.textField.delegate = self
        _ = self.addressDetailView?.addBottomLine(color: UIColor.cutLineColor)

        
        self.baomingView = PLMenuView.init(frame: CGRect.init(x: 0, y: (self.addressDetailView?.bottom_sd)!, width: KScreenWidth, height: 50), title: "报名时间", rightStr: "", rightimg: "",ifTimeDurding : true, ifclick: false,ifClassify : false)
        self.scrollV.addSubview(self.baomingView!)
        self.baomingView?.timeBtn1.tag = 1
        self.baomingView?.timeBtn1.addTarget(self, action: #selector(pickerShow(timeBtn:)), for: UIControlEvents.touchUpInside)
        _ = self.baomingView?.addBottomLine(color: UIColor.cutLineColor)

        
        self.baomingView?.timeBtn2.tag = 2
        self.baomingView?.timeBtn2.addTarget(self, action: #selector(pickerShow(timeBtn:)), for: UIControlEvents.touchUpInside)
        
        self.activityView = PLMenuView.init(frame: CGRect.init(x: 0, y: (baomingView?.bottom_sd)! , width: KScreenWidth, height: 50), title: "活动时间", rightStr: "", rightimg: "",ifTimeDurding : true, ifclick: false,ifClassify : false)
        self.scrollV.addSubview(activityView!)
        activityView?.timeBtn1.tag = 3
        activityView?.timeBtn1.addTarget(self, action: #selector(pickerShow(timeBtn:)), for: UIControlEvents.touchUpInside)
        activityView?.timeBtn2.tag = 4
        activityView?.timeBtn2.addTarget(self, action: #selector(pickerShow(timeBtn:)), for: UIControlEvents.touchUpInside)
        _ = self.activityView?.addBottomLine(color: UIColor.cutLineColor)

        
        self.numOfPeopleView = PLMenuView.init(frame: CGRect.init(x: 0, y: (activityView?.bottom_sd)!, width: KScreenWidth, height: 50), title: "报名人数", rightStr: "", rightimg: "", ifTimeDurding : false, ifclick: false,ifClassify : false)
        self.numOfPeopleView?.textField.keyboardType = UIKeyboardType.numberPad
        self.numOfPeopleView?.textField.addTarget(self, action: #selector(strToIntStr(textField:)), for: UIControlEvents.editingDidEnd)
        self.numOfPeopleView?.textField.textAlignment = NSTextAlignment.right
        self.scrollV.addSubview(self.numOfPeopleView!)
        self.numOfPeopleView?.textField.addTarget(self, action: #selector(wordlimitNumOfPeople(withTf:)), for: UIControlEvents.editingChanged)
        _ = self.numOfPeopleView?.addBottomLine(color: UIColor.cutLineColor)

        
        self.helpView = PLMenuView.init(frame: CGRect.init(x: 0, y: (self.numOfPeopleView?.bottom_sd)!, width: KScreenWidth, height: 50), title: "主办方", rightStr: "", rightimg: "", ifTimeDurding : false, ifclick: false,ifClassify : false)
        self.helpView?.textField.textAlignment = NSTextAlignment.right
        self.scrollV.addSubview(self.helpView!)
        self.helpView?.textField.addTarget(self, action: #selector(wordlimitTitle(withTf:)), for: UIControlEvents.editingChanged)
        self.helpView?.textField.delegate = self

        
        //输入View
        let titleView = UIView.init(frame: CGRect.init(x: 0, y: (self.helpView?.bottom_sd)! + 5.0, width: KScreenWidth, height: 50))
        titleView.backgroundColor = UIColor.white
        self.scrollV.addSubview(titleView)
        
        titleInputView = UITextField.init(frame: CGRect.init(x: 10, y: 0, width: KScreenWidth-20, height: 50))
        titleInputView.textColor = UIColor.textColor1
        titleInputView.font = UIFont.boldSystemFont(ofSize: 18)
        titleInputView.text = placetitleStr
        titleInputView.delegate = self
        titleInputView.tag = 12
        titleInputView.returnKeyType = .done
        titleView.addSubview(titleInputView)
        titleInputView.addTarget(self, action: #selector(wordlimitTitle(withTf:)), for: UIControlEvents.editingChanged)
        _ = titleInputView.addBottomLine(color: UIColor.cutLineColor)

        
        //输入View
        textInputView = UITextView.init(frame: CGRect.init(x: 0, y: titleView.bottom_sd, width: KScreenWidth, height: F_I6(place: 150)))
        if (titleView.bottom_sd+F_I6(place: 80)+F_I6(place: 50) + self.scrollV.top_sd + F_I6(place: 150) > KScreenHeight){
            textInputView.height_sd = F_I6(place: 150)
        }else{
            textInputView.height_sd = KScreenHeight - titleView.bottom_sd - 0.5 - F_I6(place: 80) - F_I6(place: 50) - self.scrollV.top_sd
        }
        textInputView.backgroundColor = UIColor.white
        textInputView.textColor = UIColor.textColor1
        textInputView.font = UIFont.systemFont(ofSize: 16)
        textInputView.text = placeStr
        textInputView.delegate = self
        textInputView.tag = 13
        self.scrollV.addSubview(textInputView)
        textInputView.textContainerInset = UIEdgeInsets.init(top: 10, left: 5, bottom: 10, right: 5)

        //附件View
        let EnclosureView = UIScrollView.init(frame: CGRect.init(x: 0, y: textInputView.bottom_sd, width: KScreenWidth, height: F_I6(place: 80)))
        EnclosureView.backgroundColor = UIColor.white
        self.scrollV.addSubview(EnclosureView)
        EnclosureView.showsVerticalScrollIndicator = false
        EnclosureView.showsHorizontalScrollIndicator = false
        self.EnclosureView = EnclosureView
        
        if (EnclosureView.bottom_sd>self.scrollV.height_sd){
            self.scrollV.contentSize = CGSize.init(width: KScreenWidth, height: EnclosureView.bottom_sd)
        }else{
            self.scrollV.contentSize = CGSize.init(width: KScreenWidth, height: self.scrollV.height_sd+1)
        }
        
        let camera = UIButton.init(frame: CGRect.init(x: 0, y: KScreenHeight-F_I6(place: 50), width: KScreenWidth/2, height: F_I6(place: 50)))
        camera.setTitle("相机", for: .normal)
        camera.backgroundColor = UIColor.baseColor
        camera.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.view.addSubview(camera)
        camera.setImage(UIImage.init(named: "camera"), for: .normal)
        self.camera = camera
        
        let pictureAlbum = UIButton.init(frame: CGRect.init(x: KScreenWidth/2, y: KScreenHeight-F_I6(place: 50), width: KScreenWidth/2, height: F_I6(place: 50)))
        pictureAlbum.setTitle("图片", for: .normal)
        pictureAlbum.backgroundColor = UIColor.baseColor
        pictureAlbum.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        pictureAlbum.setImage(UIImage.init(named: "album"), for: .normal)
        self.view.addSubview(pictureAlbum)
        self.pictureAlbum = pictureAlbum
        
        PLGlobalClass.setBtnStyle(camera, style: .imageLeft, space: btnBetw)
        PLGlobalClass.setBtnStyle(pictureAlbum, style: .imageLeft, space: btnBetw)
        
        let line = UIView.init(frame: CGRect.init(x: KScreenWidth/2, y: camera.top_sd + F_I6(place: 5), width: 1, height: F_I6(place: 40)))
        line.backgroundColor = UIColor.lineColor3
        self.view.addSubview(line)
        self.line = line
        
        camera.handleEventTouchUpInside {[weak self] in
            self?.isCoverImage = false
            PLGlobalClass.openCameraIsAllowsEditing(false, videotape: false)
        }
        
        pictureAlbum.handleEventTouchUpInside {[weak self] in
            
            if (self?.imageBtnArr.count ?? 0) >= numDefault.knum_pickerPublic{
                
            }else{
                //多选的pickerView
                self?.isCoverImage = false
                PLGlobalClass.openAlbum(withMaxNumber: numDefault.knum_pickerPublic - (self?.imageBtnArr.count ?? 0), alsoShowVideo: false, blockHandler: { (array) in
                    for assestModel in array!{
                        let model = assestModel as? ZLPhotoAssets
                        let image = model?.originImage
                        let qualitydata = PLGlobalClass.compressImageQuality(image)
                        //相册消失
                        DispatchQueue.main.async(execute: { [weak self] in
                            self?.addaImage(image: image!, data: qualitydata!)})
                    }
                })
                
                //单选的pickerView
//                PLGlobalClass.openAlbumIsAllowsEditing(false, alsoShowVideo: false)
            }
        }
        
        self.addressView?.clickbtn?.handleEventTouchUpInside(callback: {[weak self] in
            
            self?.view.endEditing(true)
            
            if (self?.chooseAddressView == nil){
                self?.chooseAddressView = activityAddressView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight))
                self?.view.addSubview((self?.chooseAddressView)!)
                
                self?.chooseAddressView?.callBlock(block: { (addStr) in
                    self?.addressView?.rightLab.text = addStr                    
                })
            }
            
            UIView.animate(withDuration: 0.2, animations: {
                self?.chooseAddressView?.isHidden = false
            })
        })
    }
    
    //MARK: - Action - 动作 方法
    func pickerShow (timeBtn : UIButton) {//活动时间 2    3 活动结束时间  4报名截止时间
        //报名开始1  报名结束2  活动开始3  活动结束4
        self.view.endEditing(true)
        self.view.addSubview(self.pickerbg)
        self.view.addSubview(self.picker)
        self.view.addSubview(self.quxiaoBtn)
        self.view.addSubview(self.queding)
        self.quxiaoBtn.handleEventTouchUpInside(callback: {
            [weak self] () in
            UIView.animate(withDuration: 0.3, animations: {
                self?.picker.alpha=0
                self?.quxiaoBtn.alpha=0
                self?.queding.alpha=0
                self?.pickerbg.alpha=0
            })
        })
        self.queding.addTarget(self, action: #selector(pickerHide(btn:)), for: UIControlEvents.touchUpInside)
        self.picker.alpha=1;
        self.pickerbg.alpha=1;
        self.queding.tag = timeBtn.tag;
        self.quxiaoBtn.alpha=1;
        self.queding.alpha=1;
        self.view.endEditing(true)
    }
    
    /**日历选择区消失 并改变开始结束时间的值 */
    func pickerHide(btn : UIButton) -> Void { //3 ->4  4->2  2->3
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.3, animations: {[weak self] () in
            self?.picker.alpha=0
            self?.pickerbg.alpha=0
            self?.quxiaoBtn.alpha=0
            self?.queding.alpha=0
        })
//        let str = NSString.dateString(with: self.picker.date)
        
        let str = NSString.timeMMddHHmm(with: self.picker.date)

        if btn.tag == 1 {
            if( self.baomingEndDate == nil){
                self.baomingDate = self.picker.date as NSDate
                self.baomingView?.timeBtn1.setTitle(str!, for: UIControlState.normal)
            }else{
                if (self.picker.date.timeIntervalSinceReferenceDate <   (self.baomingEndDate?.timeIntervalSinceReferenceDate)!){
                    self.baomingDate = self.picker.date as NSDate
                    self.baomingView?.timeBtn1.setTitle(str!, for: UIControlState.normal)

                }else{
                    WFHudView.showMsg("报名结束时间不能小于开始时间", in: self.view)
                }
            }
            PLGlobalClass.setBtnStyle((self.baomingView?.timeBtn1)!, style: ButtonEdgeInsetsStyleReferToImage.imageRight, space: btnBetw)
            
        }else if btn.tag == 2 {
            if( self.baomingDate == nil){
                if(self.activityEndDate != nil){
                    if ( self.picker.date.timeIntervalSinceReferenceDate <=   (self.activityEndDate?.timeIntervalSinceReferenceDate)!){
                        self.baomingEndDate = self.picker.date as NSDate
                        self.baomingView?.timeBtn2.setTitle(str!, for: UIControlState.normal)
                    }else{
                        WFHudView.showMsg("活动结束时间不能小于报名时间", in: self.view)
                    }
                }else{
                    self.baomingEndDate = self.picker.date as NSDate
                    self.baomingView?.timeBtn2.setTitle(str!, for: UIControlState.normal)
                }
            }else{
                if ( self.picker.date.timeIntervalSinceReferenceDate <=   (self.baomingDate?.timeIntervalSinceReferenceDate)!){
                    WFHudView.showMsg("报名结束时间不能小于开始时间", in: self.view)
                }else if(self.activityEndDate != nil){
                    if ( self.picker.date.timeIntervalSinceReferenceDate <=   (self.activityEndDate?.timeIntervalSinceReferenceDate)!){
                        self.baomingEndDate = self.picker.date as NSDate
                        self.baomingView?.timeBtn2.setTitle(str!, for: UIControlState.normal)
                    }else{
                        WFHudView.showMsg("活动结束时间不能小于报名时间", in: self.view)
                    }
                }else{
                    self.baomingEndDate = self.picker.date as NSDate
                    self.baomingView?.timeBtn2.setTitle(str!, for: UIControlState.normal)
                }
            }
            PLGlobalClass.setBtnStyle((self.baomingView?.timeBtn2)!, style: ButtonEdgeInsetsStyleReferToImage.imageRight, space: btnBetw)
        }else if btn.tag == 3 {
            if( self.activityEndDate == nil){
                self.activityDate = self.picker.date as NSDate
                self.activityView?.timeBtn1.setTitle(str!, for: UIControlState.normal)
            }else{
                if (self.picker.date.timeIntervalSinceReferenceDate <   (self.activityEndDate?.timeIntervalSinceReferenceDate)!){
                    self.activityDate = self.picker.date as NSDate
                    self.activityView?.timeBtn1.setTitle(str!, for: UIControlState.normal)
                }else{
                    WFHudView.showMsg("活动结束时间不能小于开始时间", in: self.view)
                }
            }
            PLGlobalClass.setBtnStyle((self.activityView?.timeBtn1)!, style: ButtonEdgeInsetsStyleReferToImage.imageRight, space: btnBetw)

        }else if(btn.tag == 4){
            if !(self.activityDate != nil){
                WFHudView.showMsg("请先选择活动时间", in: self.view)
            }else if ( self.picker.date.timeIntervalSinceReferenceDate <=   (self.activityDate?.timeIntervalSinceReferenceDate)!){
                WFHudView.showMsg("活动结束时间不能小于开始时间", in: self.view)
            }else if (self.baomingEndDate != nil){
                if(self.picker.date.timeIntervalSinceReferenceDate <=   (self.baomingEndDate?.timeIntervalSinceReferenceDate)!){
                    WFHudView.showMsg("活动结束时间不能小于报名时间", in: self.view)
                }else{
                    self.activityEndDate = self.picker.date as NSDate
                    self.activityView?.timeBtn2.setTitle(str!, for: UIControlState.normal)
                }
            }else{
                self.activityEndDate = self.picker.date as NSDate
                self.activityView?.timeBtn2.setTitle(str!, for: UIControlState.normal)
            }
            PLGlobalClass.setBtnStyle((self.activityView?.timeBtn2)!, style: ButtonEdgeInsetsStyleReferToImage.imageRight, space: btnBetw)
        }
    }
    
    
    
    //键盘的出现
    func keyBoard(notification: Notification){
        //获取userInfo
        let kbInfo = notification.userInfo
        //获取键盘的size
        let kbRect = (kbInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        //键盘的y偏移量
        //键盘弹出的时间
        let duration = kbInfo?[UIKeyboardAnimationDurationUserInfoKey] as!Double
        
        if enclosureIfcanSelected == true{
        //界面偏移动画
            UIView.animate(withDuration: duration) {[weak self, kbRect] in
                self?.camera.bottom_sd = kbRect.origin.y
                self?.pictureAlbum.bottom_sd = kbRect.origin.y
                self?.line.top_sd = (self?.camera.top_sd)! + F_I6(place: 5)
                self?.addTitle.top_sd = (self?.camera.top_sd)!-F_I6(place: 44)
            }
        }
    }
    
    
    //MARK: - 输入控制 键盘控制

    
    func strToIntStr(textField : UITextField){
        let num = Int((textField.text)!)
        if (num == nil){
            textField.text = "0"
        }else{
            textField.text = String(num!)
        }
    }
    
    func strToFloatStr(textField : UITextField){
        let num = Double((textField.text)!)
        if (num == nil){
            textField.text = "0"
        }else{
            let textf = String(format: "%.1f", num!)
            textField.text = textf
        }
    }
    
    //MARK: - 输入框代理方法
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.text == placeStr){
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text == ""){
            textView.text = placeStr
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField.text == placetitleStr){
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text == ""){
            textField.text = placetitleStr
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    //MARK: - UIImagePickerControllerDelegate选择好图片的回调
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if (info["UIImagePickerControllerMediaType"] as? String == "public.movie") {
        }else{
            //拿到选择的图片
            let image = info[UIImagePickerControllerOriginalImage] as? UIImage
            if image != nil{
                let qualitydata = PLGlobalClass.compressImageQuality(image)
                picker.dismiss(animated: true, completion: nil)
                //相册消失
                DispatchQueue.main.async(execute: { [weak self] in
                    if ( self?.isCoverImage == true){
                        self?.hasCoverImage = true
                        self?.rightImgBtn?.setImage(image, for:  .normal)
                        GlobalClass.requestToupdateFile(type: .IMG, realType: nil, files: [qualitydata!], imageBtn: (self?.rightImgBtn!)!)
                    }else{
                        self?.addaImage(image: image!, data: qualitydata!)
                    }
                })
            }else{
                WFHudView.showMsg("图片有误", in: PLGlobalClass.currentViewController().view)
            }
        }
    }
    
    //TODO:添加一个图片，刷EnclosureView
    func addaImage(image:UIImage ,data:Data ) {
        let W = self.EnclosureView.height_sd-10
        let count = self.imageBtnArr.count
        
        let imageBtn = KButton.init(frame: CGRect.init(x: 16 + (W + 5) * CGFloat(count), y: 5, width: W, height: W), needMengban:true)
        imageBtn.backgroundColor = UIColor.black
        imageBtn.imageView?.contentMode = .scaleAspectFill
        imageBtn.setImage(image, for:  .normal)
        
        let deleimage = UIButton.init(frame: CGRect.init(x: W - 35, y: 0, width: 35, height: 35))
        deleimage.setImage(UIImage.init(named: "close_1"), for: .normal)
        imageBtn.addSubview(deleimage)
        deleimage.handleEventTouchUpInside(callback: {[weak self,weak imageBtn] in
            //删除一个图片，刷图片列表
            self?.reloadenclosureViewWithDeleteImageBtn(imageBtn: imageBtn!)
        })
        
        self.EnclosureView.addSubview(imageBtn)
        self.EnclosureView.contentSize = CGSize.init(width: imageBtn.right_sd+16, height: self.EnclosureView.height_sd)
        self.imageBtnArr.append(imageBtn)
        self.scrollV.scrollRectToVisible(self.EnclosureView.frame, animated: true)
        self.reloadmediatype()
        
        let deleBtn = KNaviBarBtnItem.init(frame: CGRect.init(x: KScreenWidth-60, y: KStatusBarHeight, width: 44, height: 44), image: "deleteBig") { [weak self,weak imageBtn](sender) in
            //删除一个图片，刷图片列表
            self?.reloadenclosureViewWithDeleteImageBtn(imageBtn: imageBtn!)
        }
        let img = UIImage.init(named: "deleteBig")?.withRenderingMode(.alwaysOriginal)
        deleBtn.button.setImage(img, for: .normal)
        imageBtn.littleFrame = imageBtn.frame
        imageBtn.handleEventTouchUpInside(callback: {[weak self,weak imageBtn] in

            self?.view.endEditing(true)
            imageBtn?.isSelected = !(imageBtn?.isSelected)!
            if ((imageBtn?.isSelected)!){
                //放大动画效果
                imageBtn?.frame = CGRect.init(x: (imageBtn?.littleFrame.origin.x)!, y: (self?.EnclosureView.top_sd)!+(imageBtn?.littleFrame.origin.y)!, width: (imageBtn?.littleFrame.width)!, height: (imageBtn?.littleFrame.height)!)
                self?.view.addSubview(imageBtn!)
                deleimage.removeFromSuperview()
                
                UIView.animate(withDuration: 0.3) {
                    imageBtn?.frame = CGRect.init(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight)
                    imageBtn?.addSubview(deleBtn)
                }
            }else{
                //缩小动画效果
                UIView.animate(withDuration: 0.3, animations: {
                    imageBtn?.frame = CGRect.init(x: (imageBtn?.littleFrame.origin.x)!, y: (self?.EnclosureView.top_sd)!+(imageBtn?.littleFrame.origin.y)!, width: (imageBtn?.littleFrame.width)!, height: (imageBtn?.littleFrame.height)!)
                    deleBtn.removeFromSuperview()
                    imageBtn?.addSubview(deleimage)
                }, completion: { (_) in
                    self?.EnclosureView.addSubview(imageBtn!)
                    imageBtn?.frame = (imageBtn?.littleFrame)!
                })
            }
        })
        GlobalClass.requestToupdateFile(type: .IMG, realType: nil, files: [data], imageBtn: imageBtn)
    }
    
    
    //TODO:删除一个图片或视频，刷图片列表
    func reloadenclosureViewWithDeleteImageBtn(imageBtn : KButton ) {
        self.imageBtnArr.remove(at: self.imageBtnArr.index(of: imageBtn)!)
        imageBtn.removeFromSuperview()
        //可以继续上传附件
        self.enclosureIfcanSelected = true
        
        let W = self.EnclosureView.height_sd-10
        if self.imageBtnArr.count>0{
            
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                for i in 0 ... (self?.imageBtnArr.count)!-1{
                    let imageBtn = self?.imageBtnArr[i]
                    imageBtn?.frame =  CGRect.init(x: 16 + (W + 5) * CGFloat(i), y: 5, width: W, height: W)
                    imageBtn?.littleFrame = (imageBtn?.frame)!
                    if i == (self?.imageBtnArr.count)!-1{
                        self?.EnclosureView.contentSize = CGSize.init(width: imageBtn!.right_sd+16, height: (self?.EnclosureView.height_sd)!)
                    }
                }
            }, completion: { (_) in
            })
        }
        self.reloadmediatype()
    }
    
    //刷新mediatype 除了视频之外的状态
    func reloadmediatype() {
        if (self.imageBtnArr.count<9){
            self.enclosureIfcanSelected = true
            self.mediatype = "3"//多图 不能继续上传附件
            if(self.imageBtnArr.count == 1){
                self.mediatype = "2"//多图 不能继续上传附件
            }
            if(self.imageBtnArr.count == 0){
                self.mediatype = "1"//多图 不能继续上传附件
            }
        }else{
            self.mediatype = "3"//多图 不能继续上传附件
            self.enclosureIfcanSelected = false
        }
    }
    
    //MARK: - 发布动态
    func publicClick() {
        
        if self.titleInputView.text?.count==0{
            WFHudView.showMsg("请填写活动标题", in: self.view)
            return
        }
        
        if self.titleInputView.text == placetitleStr{
            WFHudView.showMsg("请填写活动标题", in: self.view)
            return
        }
        
        if self.textInputView.text.count==0{
            WFHudView.showMsg("请填写内容", in: self.view)
            return
        }
        if self.textInputView.text == placeStr{
            WFHudView.showMsg("请填写内容", in: self.view)
            return
        }
        
        var coverIdStr = ""
        var coverpathStr = ""
        let covermodel = self.rightImgBtn?.attribute as? uploadfilesModel
        if (covermodel != nil){
            if covermodel!.id.count > 0{
                //第一次不拼接逗号
                coverIdStr.append(covermodel!.id)
                coverpathStr.append(covermodel!.path)
            }
        }else{
            if hasCoverImage == true{
                WFHudView.showMsg("封面正在上传中", in: self.view)
                return
            }
            WFHudView.showMsg("请上传封面", in: self.view)
            return
        }
  
        if self.addressView?.rightLab.text?.count == 0{
            WFHudView.showMsg("请选择所在地区", in: self.view)
            return
        }
        
        if self.addressView?.rightLab.text == "请选择"{
            WFHudView.showMsg("请选择所在地区", in: self.view)
            return
        }
        
        if self.addressDetailView?.textField.text?.count == 0{
            WFHudView.showMsg("请填写活动详细地址", in: self.view)
            return
        }
        
        if self.helpView?.textField.text?.count == 0{
            WFHudView.showMsg("请填写主办方", in: self.view)
            return
        }
        
        if ((self.numOfPeopleView?.textField.text?.count)! <= 0 || self.numOfPeopleView?.textField.text == "0") {
            WFHudView.showMsg("参与人数要求大于0", in: self.view)
            return;
        }
        if ((self.activityView?.timeBtn1.titleLabel?.text?.count)! <= 0 || (self.activityDate == nil)) {
            WFHudView.showMsg("请确定活动开始时间", in: self.view)
            return;
        }
        
        if ((self.activityView?.timeBtn2.titleLabel?.text?.count)! <= 0 ||  (self.activityEndDate == nil) ) {
            WFHudView.showMsg("请确定活动结束时间", in: self.view)
            return;
        }

        if ((self.baomingView?.timeBtn1.titleLabel?.text?.count)! <= 0 || (self.baomingDate == nil)) {
            WFHudView.showMsg("请确定报名开始时间", in: self.view)
            return;
        }
        if ((self.baomingView?.timeBtn2.titleLabel?.text?.count)! <= 0 || (self.baomingEndDate == nil)) {
            WFHudView.showMsg("请确定报名截止时间", in: self.view)
            return;
        }
        
        let activityStr = PLGlobalClass.timestamp(with: self.activityDate!as Date)
        let activityEndStr = PLGlobalClass.timestamp(with: self.activityEndDate!as Date)
        let baomingEndStr = PLGlobalClass.timestamp(with: self.baomingEndDate! as Date)
        let baomingBeginStr = PLGlobalClass.timestamp(with: self.baomingDate! as Date!)
        
        var attachidStr = ""
        var attachpathStr = ""
        for imageBtn in self.imageBtnArr{
            let uploadmodel = imageBtn.attribute as? uploadfilesModel
            if (uploadmodel != nil){
                if uploadmodel!.id.count > 0{
                    if ( uploadmodel!.path.count > 0){
                        if (attachidStr.count == 0) {
                            //第一次不拼接逗号
                            attachidStr.append(uploadmodel!.id)
                            attachpathStr.append(uploadmodel!.path)
                        }else{
                            attachidStr.append("," + uploadmodel!.id)
                            attachpathStr.append("," + uploadmodel!.path)
                        }
                    }else{
                        WFHudView.showMsg("图片正在上传中", in: self.view)
                        return;
                    }
                }else{
                    WFHudView.showMsg("图片正在上传中", in: self.view)
                    return;
                }
            }else{
                WFHudView.showMsg("图片正在上传中", in: self.view)
                return;
            }
        }
        
        let addressStr = (self.addressView?.rightLab.text ?? "") + (self.addressDetailView?.textField.text ?? "")
        
        self.showGifView()

        ClanAPI.requestForSubmitActivity(
            title: self.titleInputView.text!,
            content: self.textInputView.text,
            attachid: attachidStr,
            attachpath: attachpathStr,
            themeimg: coverpathStr,
            address: addressStr,
            business: (self.helpView?.textField.text)!,
            persons: (self.numOfPeopleView?.textField.text)!,
            starttime: activityStr!,
            endtime: activityEndStr!,
            signupstarttime: baomingBeginStr!,
            signupendtime: baomingEndStr!) {[weak self] (result) in
                
                self?.hiddenGifView()

                if ((result.status) == "200"){
                    WFHudView.showMsg("发布成功", in: self?.view)
                    self?.navigationController?.popViewController(animated: true)
                    self?.lastVC?.tableView.mj_header.beginRefreshing()
                    
                    GlobalClass.single_event(eventName: CUKey.UM_activity_public)
                }else{
                    if (result.message.count>0){
                        WFHudView.showMsg(result.message, in: self?.view)
                    }else{
                        WFHudView.showMsg("发布失败", in: self?.view)
                    }
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK:- ---------------- 菜单
class PLMenuView: UIView , UITextFieldDelegate{
    
    var title = ""
    var rightStr = "" //右边是否显示单位
    var rightimg = "" //右边是否显示小图标
    var rightImgView = UIImageView()
    var ifTimeDurding = false //时间间隔
    var ifClassify = false //分类
    var ifclick = false
    var textField = UITextField()
    var timeBtn1 = UIButton()
    var timeBtn2 = UIButton()
    var clickbtn : KButton?
    var funcItemsArray : Array<Any> = Array()
    var titleLab = UILabel()
    var rightLab = UILabel()
    
    init(frame : CGRect , title : String! , rightStr : String!, rightimg : String!, ifTimeDurding : Bool, ifclick : Bool ,ifClassify : Bool ) {
        super.init(frame : frame)
        self.title = title //左侧标题
        self.rightStr = rightStr //textField输完后的单位 没有传 @“”
        self.rightimg = rightimg //右侧小图标 没有传 @“”
        self.ifTimeDurding = ifTimeDurding //是否填写时间间隔  ...至...
        self.ifclick = ifclick //是否需要整行可以点击
        self.ifClassify = ifClassify //是否是分类 右边四个分类的按钮
        self.makeView(frame : frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeView(frame: CGRect) {
        self.backgroundColor = UIColor.white
        let titleLab = UILabel.init(frame: CGRect.init(x: 10, y: 0, width: frame.width/5, height: frame.height))
        titleLab.text = self.title
        titleLab.font = UIFont.systemFont(ofSize: 15)
        titleLab.textColor = UIColor.black
        self.addSubview(titleLab)
        self.titleLab = titleLab
        
        self.textField = UITextField.init(frame: CGRect.init(x: titleLab.right_sd, y: 0, width: frame.width - titleLab.right_sd - 10, height: frame.height))
        self.textField.font = UIFont.systemFont(ofSize: 14)
        self.textField.textColor = UIColor.textColor3
        self.textField.delegate = self
        self.textField.returnKeyType =  .done
        self.addSubview(self.textField)
        
        var rightLab = UILabel.init()
        if( self.rightStr.count > 0 ){
            
            rightLab = UILabel.init(frame: CGRect.init(x: frame.width-30, y: 0, width: 20, height: frame.height))
            rightLab.text = rightStr
            rightLab.font = UIFont.systemFont(ofSize: 12)
            rightLab.textAlignment = NSTextAlignment.right
            rightLab.textColor = UIColor.black
            self.addSubview(rightLab)
            self.textField.width_sd = frame.width - titleLab.right_sd - 30
            rightLab.sizeToFit()
            rightLab.right_sd = self.width_sd-10
            rightLab.centerY_sd = self.height_sd/2
            self.rightLab = rightLab
        }
        
        if ( self.rightimg.count > 0){
            
            let rightImg = UIImageView.init(frame: CGRect.init(x: frame.width-25, y: 0, width: 15, height: frame.height))
            rightImg.image = UIImage.init(named: rightimg)
            rightImg.contentMode = UIViewContentMode.center
            self.addSubview(rightImg)
            self.rightImgView = rightImg
            self.textField.width_sd = frame.width - titleLab.right_sd - 30
            if( self.rightStr.count > 0 ){
                rightLab.sizeToFit()
                rightLab.right_sd = rightImg.left_sd-10
                rightLab.centerY_sd = rightImg.centerY_sd
            }
            rightImg.clipsToBounds = true
        }
        
        if(self.ifTimeDurding){
            self.timeBtn1 = UIButton.init(frame: CGRect.init(x:  frame.width - F_I6(place: 95)*2 - F_I6(place: 55) - 12, y: 0, width: F_I6(place: 95), height: 22))
            self.timeBtn1.setTitle("请选择时间", for: UIControlState.normal)
            self.timeBtn1.layer.borderWidth = 1
            self.timeBtn1.layer.borderColor = UIColor.cutLineColor.cgColor
            self.timeBtn1.layer.cornerRadius = 3
            self.timeBtn1.clipsToBounds = true
            self.timeBtn1.setImage(UIImage.init(named: "triangle_down"), for: .normal)
            self.timeBtn1.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            self.timeBtn1.setTitleColor(UIColor.textColor3, for: UIControlState.normal)
            self.timeBtn1.titleLabel?.adjustsFontSizeToFitWidth = true
            self.timeBtn1.titleLabel?.textAlignment = NSTextAlignment.center
            self.addSubview(self.timeBtn1)

            
            let middleLab = UILabel.init(frame: CGRect.init(x: self.timeBtn1.right_sd, y: 0, width: F_I6(place: 55), height: frame.height))
            middleLab.text = "至"
            middleLab.font = UIFont.systemFont(ofSize: 12)
            middleLab.textColor = UIColor.textColor3
            middleLab.textAlignment = NSTextAlignment.center
            self.addSubview(middleLab)
            
            self.timeBtn2 = UIButton.init(frame: CGRect.init(x: middleLab.right_sd, y: 0, width: F_I6(place: 95), height: 22))
            self.timeBtn2.setTitle("请选择时间", for: UIControlState.normal)
            self.timeBtn2.layer.borderWidth = 1
            self.timeBtn2.layer.borderColor = UIColor.cutLineColor.cgColor
            self.timeBtn2.setImage(UIImage.init(named: "triangle_down"), for: .normal)
            self.timeBtn2.layer.cornerRadius = 3
            self.timeBtn2.clipsToBounds = true

            
            self.timeBtn2.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            self.timeBtn2.setTitleColor(UIColor.textColor3, for: UIControlState.normal)
            self.timeBtn2.titleLabel?.textAlignment = NSTextAlignment.center
            self.timeBtn2.titleLabel?.adjustsFontSizeToFitWidth = true
            self.addSubview(self.timeBtn2)
           
            self.timeBtn1.centerY_sd = self.height_sd/2
            self.timeBtn2.centerY_sd = self.height_sd/2
            
            PLGlobalClass.setBtnStyle(self.timeBtn1, style: .imageRight, space: 2)
            PLGlobalClass.setBtnStyle(self.timeBtn2, style: .imageRight, space: 2)
            
            self.textField.removeFromSuperview()
        }
        
        if(ifClassify){
            self.textField.removeFromSuperview()
        }
        
        self.clickbtn = KButton.init(frame: self.textField.frame, needMengban: false)
        if(self.ifclick){
            self.addSubview(self.clickbtn!)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}


//MARK: - ----------------设置地址UI自定义
class activityAddressView: UIView , UITableViewDelegate , UITableViewDataSource {
    
    var list : Array<ChinaCityModel>? = nil
    var tableView = UITableView.init()
    var headerview = UIView.init()
    var prov : ChinaCityModel?
    var city : ChinaCityModel?
    var area : ChinaCityModel?
    
    typealias textBlock = (String)->()
    var block:textBlock?
    
//    private static let sharedInstance = activityAddressView()
//    class var shareAddress: activityAddressView {
//
//        let btn : KButton? = sharedInstance.viewWithTag(100) as? KButton
//        btn?.sendActions(for: .touchUpInside)
//        return sharedInstance
//    }
    
    func callBlock(block:textBlock?) {
        self.block = block
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
        let title = UILabel.init(frame: CGRect.init(x: 0, y: F_I6(place: 214), width: KScreenWidth, height: 43))
        title.textColor = UIColor.black
        title.font = UIFont.systemFont(ofSize: 16)
        title.text = "所在地区"
        title.backgroundColor = UIColor.white
        title.textAlignment = .center
        self.addSubview(title)
        
        let closeBtn = UIButton.init(frame: CGRect.init(x: KScreenWidth-26-13, y: title.top_sd + (43-26)/2, width: 26, height: 26))
        closeBtn.setImage(UIImage.init(named: "close_1"), for: .normal)
        self.addSubview(closeBtn)
        
        self.maketableView()
        
        self.headerview.top_sd = title.bottom_sd
        self.tableView.top_sd = self.headerview.bottom_sd
        self.tableView.height_sd = KScreenHeight - self.headerview.bottom_sd
        
        closeBtn.handleEventTouchUpInside(callback: { [weak self] in
            UIView.animate(withDuration: 0.2, animations: {
                self?.isHidden = true
            })
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //地区按钮
    func makeAreaBtn(){
        for i in 0...3{
            let btn = KButton.init(frame: CGRect.init(x:Int(F_I6(place: 61))*i, y: 4, width: Int(F_I6(place: 61)), height: Int(headerview.height_sd-8)), needMengban:false)
            
            if i == 0 {
                PLGlobalClass.setBorderWith(btn, top: false, left: false, bottom: true, right: false, borderColor: UIColor.baseColor, borderWidth: 2)
                btn.setTitle("请选择", for: .normal)
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
                btn.isHidden = false
                btn.attribute = list
                tableView.reloadData()
                btn.setTitleColor(UIColor.baseColor, for:.normal)
            }else{
                btn.setTitle("", for: .normal)
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
                btn.isHidden = true
                btn.setTitleColor(UIColor.textColor1, for:.normal)
                
                let lineView = UIView.init(frame: CGRect.init(x: 0, y: btn.height_sd-2, width: 0, height: 2))
                lineView.backgroundColor = UIColor.baseColor
                btn.addSubview(lineView)
                lineView.tag = i+200
            }
            self.headerview.addSubview(btn)
            btn.tag = i + 100
            
            btn.handleEventTouchUpInside {[weak self, weak btn] in
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
            
//            btn.handleEventTouchUpInside {[weak btn] in
//                if (btn?.attribute != nil && btn?.attribute is ChinaCityModel){
//                    let model = btn?.attribute as! ChinaCityModel
//
//                    self.list = ChinaCityModel.searchDataWhere(["parentid":model.id])
//                    self.tableView.reloadData()
//                }else{
//                    self.list = ChinaCityModel.searchDataWhere(["level":"1"])
//                    self.tableView.reloadData()
//                }
//                for i in (btn?.tag)!...103{
//                    let btnfor: KButton = (self.headerview.viewWithTag(i) as? KButton)!
//                    do {
//                        if (btnfor.tag > (btn?.tag)!){
//                            btnfor.isHidden = true
//                        }
//                    }
//                }
//            }
        }
    }
    
    //按钮位置自适应
    func makeBtnFrame(tag : Int) {
        let btn = headerview.viewWithTag(tag-1) as? KButton
        let X = (btn?.right_sd)! + 10
        for i in tag ... 3+100{
            let btnfor = headerview.viewWithTag(i) as? KButton
            if (i==tag){
                btnfor?.titleLabel?.sizeToFit()
                btnfor?.width_sd = (btnfor?.titleLabel?.width_sd)!+10
                if ((btnfor?.right_sd)!>KScreenWidth){
                    if (i<103){
                        //不是最后一个按钮 缩小按钮给后一个留空间
                        btnfor?.width_sd = (KScreenWidth - X)/2
                    }else{
                        //最后一个按钮，右边顶到头就行了
                        btnfor?.width_sd = KScreenWidth-5-(btn?.right_sd)!;
                    }
                }else{
                    if ((btnfor?.width_sd)! > KScreenWidth/3){
                        btnfor?.width_sd = KScreenWidth/3;
                    }
                }
                btnfor?.left_sd = X
                let lineView = btnfor?.viewWithTag(((btnfor?.tag)! + 100))
                lineView?.width_sd = (btnfor?.width_sd)!
            }
        }
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
            btn?.setTitle((model?.areaname ?? "\(level)"), for: .normal)
            list = ChinaCityModel.searchDataWhere(["parentid":model!.id])
            tableView.reloadData()
            if (list?.count == 0){
                self.kBackBtnAction()
            }
        }
        self.makeBtnFrame(tag: (btn?.tag)!)
    }
    
    func kBackBtnAction() {
        var addressStr = ""
        for i in 101 ... 3+100{
            let btnfor = headerview.viewWithTag(i) as? KButton
            let model = btnfor?.attribute as? ChinaCityModel
            if ( btnfor?.isHidden == false){
                if(model != nil){
                    addressStr.append(model!.areaname)
                }
            }
        }
        if let block  =  self.block {
            block(addressStr)
        }
        UIView.animate(withDuration: 0.2) {[weak self] in
            self?.isHidden = true
        }
    }
    
    func maketableView(){
        let headerview = UIView.init(frame: CGRect.init(x: 0, y: KTopHeight, width: KScreenWidth, height: 40))
        headerview.backgroundColor = UIColor.bgColor2
        self.addSubview(headerview)
        
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
        self.addSubview(tableView)
        self.tableView = tableView
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
    
    //获取地区数据
    func getAreaData() {
        
        list = ChinaCityModel.searchDataWhere(["level":"1"])
        if list != nil && list!.count > 0 {
            self.makeAreaBtn()
        }else{
         
            let jsonData = NSData.init(contentsOfFile: Bundle.main.path(forResource: "city", ofType: "json")!)
            let arr = jsonData?.mj_JSONObject()
            let array = ChinaCityModel.mj_objectArray(withKeyValuesArray: arr)
            
            //存数据成功 存数据库是为了搜索时方便
            ChinaCityModel.insert(with: array as! [ChinaCityModel])
            self.list = ChinaCityModel.searchDataWhere(["level":"1"])
            self.makeAreaBtn()
        }
    }
}



//MARK: - ----------------设置地址UI自定义
class activityAddressVC: CUchooseAddressVC {
    typealias textBlock = (String)->()
    var block:textBlock?
    
    private static let sharedInstance = activityAddressVC()
    class var shareAddress: activityAddressVC {
        
        let btn : KButton? = sharedInstance.view.viewWithTag(100) as? KButton
        btn?.sendActions(for: .touchUpInside)
        
        return sharedInstance
    }
    
    func callBlock(block:textBlock?) {
        self.block = block
    }
    
    override func viewDidLoad() {
        self.maketableView()
    }
    
    //地区按钮
    override func makeAreaBtn(){
        for i in 0...3{
            let btn = KButton.init(frame: CGRect.init(x:Int(F_I6(place: 61))*i, y: 4, width: Int(F_I6(place: 61)), height: Int(headerview.height_sd-8)), needMengban:false)

            if i == 0 {
                PLGlobalClass.setBorderWith(btn, top: false, left: false, bottom: true, right: false, borderColor: UIColor.baseColor, borderWidth: 2)
                btn.setTitle("请选择", for: .normal)
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
                btn.isHidden = false
                btn.attribute = list
                tableView.reloadData()
                btn.setTitleColor(UIColor.baseColor, for:.normal)
            }else{
                btn.setTitle("", for: .normal)
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
                btn.isHidden = true
                btn.setTitleColor(UIColor.textColor1, for:.normal)

                let lineView = UIView.init(frame: CGRect.init(x: 0, y: btn.height_sd-2, width: 0, height: 2))
                lineView.backgroundColor = UIColor.baseColor
                btn.addSubview(lineView)
                lineView.tag = i+200
            }
            self.headerview.addSubview(btn)
            btn.tag = i + 100

            btn.handleEventTouchUpInside {[weak btn] in
                if (btn?.attribute != nil && btn?.attribute is ChinaCityModel){
                    let model = btn?.attribute as! ChinaCityModel

                    self.list = ChinaCityModel.searchDataWhere(["parentid":model.id])
                    self.tableView.reloadData()
                }else{
                    self.list = ChinaCityModel.searchDataWhere(["level":"1"])
                    self.tableView.reloadData()
                }
                for i in (btn?.tag)!...103{
                    let btnfor: KButton = (self.headerview.viewWithTag(i) as? KButton)!
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
    override func makeBtnFrame(tag : Int) {
        let btn = headerview.viewWithTag(tag-1) as? KButton
        let X = (btn?.right_sd)! + 10
         for i in tag ... 3+100{
            let btnfor = headerview.viewWithTag(i) as? KButton
            if (i==tag){
                btnfor?.titleLabel?.sizeToFit()
                btnfor?.width_sd = (btnfor?.titleLabel?.width_sd)!+10
                if ((btnfor?.right_sd)!>KScreenWidth){
                    if (i<103){
                        //不是最后一个按钮 缩小按钮给后一个留空间
                        btnfor?.width_sd = (KScreenWidth - X)/2
                    }else{
                        //最后一个按钮，右边顶到头就行了
                        btnfor?.width_sd = KScreenWidth-5-(btn?.right_sd)!;
                    }
                }else{
                    if ((btnfor?.width_sd)! > KScreenWidth/3){
                        btnfor?.width_sd = KScreenWidth/3;
                    }
                }
                btnfor?.left_sd = X
                let lineView = btnfor?.viewWithTag(((btnfor?.tag)! + 100))
                lineView?.width_sd = (btnfor?.width_sd)!
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            btn?.setTitle((model?.areaname ?? "\(level)"), for: .normal)
            list = ChinaCityModel.searchDataWhere(["parentid":model!.id])
            tableView.reloadData()
            if (list?.count == 0){
                self.kBackBtnAction()
            }
        }
        self.makeBtnFrame(tag: (btn?.tag)!)
    }
    
    override func kBackBtnAction() {
        var addressStr = ""
        for i in 101 ... 3+100{
            let btnfor = headerview.viewWithTag(i) as? KButton
            let model = btnfor?.attribute as? ChinaCityModel
            if ( btnfor?.isHidden == false){
                if(model != nil){
                    addressStr.append(model!.areaname)
                }
            }
        }
        if let block  =  self.block {
            block(addressStr)
        }
        UIView.animate(withDuration: 0.2) {[weak self] in
            self?.view.isHidden = true
        }
    }
}
