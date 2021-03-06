import MBProgressHUD

//MARK: - ----------------发布企业秀
class publicCompany: KBaseClanViewController,UITextViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UITableViewDelegate,UITableViewDataSource {
    let placeStr = "请输入正文"
    let placetitleStr = "请输入标题"
    var tableView = UITableView()
    
    var camera = UIButton.init()
    var pictureAlbum = UIButton.init()
    var line = UIView.init()
    var textInputView = UITextView()
    var titleInputView = UITextField.init()
    var imageBtnArr = Array<KButton>()
    var mediatype = "1" //1.无图; 2,单图; 3,多图; 4,视频
    var lastVC : Company?
    
    var footerView = UIView()
    var headerView = UIView ()
    var cover : PLMenuView?      //封面

    var companyNameView : PLMenuView? //详细地址
    
    var isCoverImage = false
    var hasCoverImage = false
    var hasVideo = false
    
    var rightImgBtn : KButton?

    
    var textnum = UILabel()
    
    var contentArr  : NSMutableArray = []
    var player : XLVideoPlayer?
    
    /// 弹窗
    var animation : LewPopupViewAnimationSlide?
    var alterV : msgAlterView?
    
    
    //MARK: - 懒加载
    lazy var pickerbg: UIView = {
        let tempView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight))
        tempView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
        return tempView
    }()
    lazy var picker: UIDatePicker = {
        let temppicker = UIDatePicker.init(frame: CGRect.init(x: (KScreenWidth-F_I6(place: 290))/2, y: F_I6(place: 170), width: F_I6(place: 290), height: F_I6(place: 270)))
        temppicker.backgroundColor = UIColor.white
        temppicker.minimumDate = NSDate() as Date
        temppicker.datePickerMode = .date
        
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 1))
        view.backgroundColor = UIColor.gray
        temppicker.addSubview(view)
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
    
    
    override func kBackBtnAction() {
        self.view.endEditing(true)
        if self.animation == nil{
            let animation = LewPopupViewAnimationSlide.init()
            animation.type = LewPopupViewAnimationSlideType.bottomBottom
            self.animation = animation
            
            let alterView = msgAlterView.init(frame: CGRect.init(x: 0, y: 0, width: F_I6(place: 251), height: 102), parentVC: self, dismiss: self.animation, title: "你确定放弃编辑")
            self.alterV = alterView
        }
    
        self.lew_presentPopupView(self.alterV, animation: self.animation, backgroundClickable: true)
        
        alterV?.btnClickBlock  = {[weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }    
    
    
    override func viewWillAppear(_ animated: Bool) {
        PLGlobalClass.setIQKeyboardToolBarEnable(true, distanceFromTextField: F_I6(place: 100))
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
        contentArr = NSMutableArray.init(capacity: 0)
        
        let publicItem = KNaviBarBtnItem.init(frame:  CGRect.init(x: KScreenWidth-44, y: KStatusBarHeight, width: 44, height: 44), title: "完成") { [weak self](sender) in
            self?.publicClick()
        }
        self.knavigationBar?.rightBarBtnItem = publicItem;
        self.scrollView()

        self.maketableView()
        
        //键盘弹出时
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoard(notification: )), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoard(notification: )), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //MARK: - tableView
    func maketableView(){
        
        self.tableView = UITableView.init(frame: CGRect.init(x: 0, y: KTopHeight, width: KScreenWidth, height: KScreenHeight - KTopHeight - F_I6(place: 50)), style: UITableViewStyle.grouped)
        self.tableView.backgroundColor = UIColor.bgColor2
        self.tableView.delegate=self
        self.tableView.dataSource=self
        self.view.addSubview(self.tableView)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView
        
        let camera = UIButton.init(frame: CGRect.init(x: 0, y: KScreenHeight-F_I6(place: 50), width: KScreenWidth/2, height: F_I6(place: 50)))
        camera.setTitle("相机", for: .normal)
        camera.backgroundColor = UIColor.baseColor
        camera.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.view.addSubview(camera)
        camera.setImage(UIImage.init(named: "camera"), for: .normal)
        self.camera = camera
        
        let pictureAlbum = UIButton.init(frame: CGRect.init(x: KScreenWidth/2, y: KScreenHeight-F_I6(place: 50), width: KScreenWidth/2, height: F_I6(place: 50)))
        pictureAlbum.setTitle("图片/视频", for: .normal)
        pictureAlbum.backgroundColor = UIColor.baseColor
        pictureAlbum.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        pictureAlbum.setImage(UIImage.init(named: "album"), for: .normal)
        self.view.addSubview(pictureAlbum)
        self.pictureAlbum = pictureAlbum
        
        PLGlobalClass.setBtnStyle(camera, style: .imageLeft, space: 5)
        PLGlobalClass.setBtnStyle(pictureAlbum, style: .imageLeft, space: 5)
        
        let line = UIView.init(frame: CGRect.init(x: KScreenWidth/2, y: camera.top_sd + F_I6(place: 5), width: 1, height: F_I6(place: 40)))
        line.backgroundColor = UIColor.lineColor3
        self.view.addSubview(line)
        self.line = line
        
        camera.handleEventTouchUpInside {[weak self] in
            self?.isCoverImage = false
            if self?.hasVideo == true{
                PLGlobalClass.openCameraIsAllowsEditing(false, videotape: false)
            }else{
                PLGlobalClass.openCameraIsAllowsEditing(false, videotape: true)
            }
        }
        
        pictureAlbum.handleEventTouchUpInside {[weak self] in
            self?.isCoverImage = false
            if self?.hasVideo == true{
                PLGlobalClass.openAlbumIsAllowsEditing(false, alsoShowVideo: false)
            }else{
                PLGlobalClass.openAlbumIsAllowsEditing(false, alsoShowVideo: true)
            }
        }
    }
    
    
    
    func scrollView(){
        
        headerView = UIView.init(frame: CGRect.init(x: 0, y: KTopHeight, width: KScreenWidth, height: KScreenHeight-KTopHeight-F_I6(place: 50)))
        headerView.backgroundColor = UIColor.white
        self.view.addSubview(self.headerView)
        
        cover = PLMenuView.init(frame: CGRect.init(x: 0, y: 1, width: KScreenWidth, height: F_I6(place: 77)), title: "上传封面", rightStr: "", rightimg: "createAdd", ifTimeDurding : false ,ifclick: false ,ifClassify : false)
        headerView.addSubview(cover!)
        cover?.textField.textAlignment = NSTextAlignment.right
        cover?.textField.addTarget(self, action: #selector(wordlimit(textField:)), for: UIControlEvents.editingChanged)
        
        rightImgBtn = KButton.init(frame: CGRect.init(x: (cover?.width_sd ?? 0)!-10-F_I6(place: 61), y: 0, width: F_I6(place: 61), height: F_I6(place: 61)), needMengban: false)
        rightImgBtn?.centerY_sd = (self.cover?.height_sd ?? 0)!/2
        cover?.textField.isUserInteractionEnabled = false
        rightImgBtn?.imageView?.contentMode = .scaleAspectFill
        rightImgBtn?.setImage(UIImage.init(named: "createAdd"), for: .normal)
        cover?.addSubview(rightImgBtn!)
        rightImgBtn?.handleEventTouchUpInside {[weak self] in
            self?.isCoverImage = true
            PLGlobalClass.uploadphotosIfAllowsEditing(false, alsoShowVideo: false)
        }
        cover?.rightImgView.removeFromSuperview()
        _ = cover?.addBottomLine(color: UIColor.cutLineColor)
        
        
        /// 企业名称
        self.companyNameView = PLMenuView.init(frame: CGRect.init(x: 0, y: (cover?.bottom_sd ?? 0)!, width: KScreenWidth, height: 50), title: "企业名称", rightStr: "", rightimg: "", ifTimeDurding : false, ifclick: false,ifClassify : false)
        self.headerView.addSubview(self.companyNameView!)
        self.companyNameView?.textField.textAlignment = NSTextAlignment.right
        self.companyNameView?.textField.delegate = self
        _ = self.companyNameView?.addBottomLine(color: UIColor.cutLineColor)
        
        //输入View
        titleInputView = UITextField.init(frame: CGRect.init(x: 10, y: (companyNameView?.bottom_sd ?? 0)!, width: KScreenWidth-20, height:  50))
        titleInputView.textColor = UIColor.textColor1
        titleInputView.font = UIFont.boldSystemFont(ofSize: 18)
        titleInputView.text = placetitleStr
        titleInputView.delegate = self
        titleInputView.tag = 12
        titleInputView.returnKeyType = .done
        self.headerView.addSubview(titleInputView)
        _ = titleInputView.addBottomLine(color: UIColor.cutLineColor)
        titleInputView.addTarget(self, action: #selector(wordlimit(textField:)), for: UIControlEvents.editingChanged)
        
//        textnum = UILabel.init(frame: CGRect.init(x:KScreenWidth - 12 - F_I6(place: 50) , y: 0, width: 50, height: 30))
//        textnum.text = "(0/20)"
//        textnum.font = UIFont.systemFont(ofSize: 12)
//
//        textnum.textAlignment = .right
//        textnum.centerY_sd = titleInputView.centerY_sd
//        self.headerView.addSubview(textnum)
        
        headerView.height_sd = titleInputView.bottom_sd
        
        
        footerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: F_I6(place: 300)))
        footerView.backgroundColor = UIColor.white
        
        
        //输入View
        textInputView = UITextView.init(frame: CGRect.init(x: 5, y: 10, width: KScreenWidth-10, height: F_I6(place: 130)))
        textInputView.textColor = UIColor.textColor1
        textInputView.font = UIFont.systemFont(ofSize: 16)
        textInputView.text = placeStr
        textInputView.delegate = self
        textInputView.tag = 13
        //不显示边框
        //textInputView.layer.cornerRadius = 5
        //textInputView.clipsToBounds = true
        //textInputView.layer.borderWidth = 1
        //textInputView.layer.borderColor = UIColor.cutLineColor.cgColor
        footerView.addSubview(textInputView)
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
        
        //界面偏移动画
        UIView.animate(withDuration: duration) {[weak self] in
            self?.camera.bottom_sd = kbRect.origin.y
            self?.pictureAlbum.bottom_sd = kbRect.origin.y
            self?.line.top_sd = (self?.camera.top_sd ?? 0)! + F_I6(place: 5)
        }
    }
    
    
    //MARK: - tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? TuwenCell
        if ((cell == nil)){
            cell = TuwenCell.init(style: .default, reuseIdentifier: "cell")
        }
        cell?.reloadPublicCell(model: contentArr[indexPath.row] as! TuwenModel )
        
        let tap = UITapGestureRecognizer.bk_recognizer {[weak self , weak cell] (tap, state, point) in
            if cell?.ImgDeleBtn.isHidden == true{
                let animation = CATransition.init()
                animation.type = kCATransitionFade
                animation.duration = 0.2
                cell?.ImgDeleBtn.layer.add(animation, forKey: nil)
                cell?.ImgDeleBtn.isHidden = false
            }else{
                let animation = CATransition.init()
                animation.type = kCATransitionFade
                animation.duration = 0.2
                cell?.ImgDeleBtn.layer.add(animation, forKey: nil)
                cell?.ImgDeleBtn.isHidden = true
            }
            self?.view.endEditing(true)
        }
        cell?.contentImg.addGestureRecognizer(tap as! UIGestureRecognizer)
        
        cell?.ImgDeleBtn.handleEventTouchUpInside(callback: {[weak self , weak cell] in
            if cell?.model?.type == "2"{
                self?.hasVideo = false
            }
            self?.contentArr.remove(cell!.model!)
            self?.tableView.reloadData()
        })
        cell?.contentTextView.tag = indexPath.row + 200
        cell?.contentTextView.delegate = self

        cell?.playBtn.handleEventTouchUpInside(callback: {[weak self , weak cell] in
            //点击cell的播放按钮播放
            self?.cellPlay(cell: cell!)
        })
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return TuwenCell.getCellHeigh(model: contentArr[indexPath.row] as! TuwenModel)
        return TuwenCell.getPublicCellHeigh(model: contentArr[indexPath.row] as! TuwenModel)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    
    //MARK: - 输入控制 键盘控制
    func wordlimit(textField : UITextField){
        PLGlobalClass.wordlimitWithtextField(textField, limitnum: 20)
//        let number = textField.text?.count ?? 0
//        textnum.text = "(" + String(describing: number) + "/20)"
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.text == placeStr){
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.tag == 13{
        }else{
            let index = textView.tag - 200
            
            if (index >= 0){
                
                let dic = contentArr[index]
                if dic is TuwenModel{
                    let model = dic as? TuwenModel
                    model?.content = textView.text
                }else if dic is NSDictionary{
                    let dicc = dic as? NSDictionary
                    dicc?.setValue(textView.text, forKey: "content")
                }
            }
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
            hasVideo = true
            //视频URL
            let moveUrl = info[UIImagePickerControllerMediaURL] as! URL
            let data = NSData.init(contentsOf: moveUrl)
            
            //相册消失
            picker.dismiss(animated: true, completion: nil)
            
            let ReferenceURL = info[UIImagePickerControllerReferenceURL] as? URL
            if ReferenceURL == nil{
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.label.text = "正在压缩视频"
                
                
                //拍的视频-要进行一次压缩
                PLGlobalClass.compressionVideo(withInputURL: moveUrl, blockHandler: {[weak self] session in
                    if self != nil{
                        if self?.view != nil{
                            hud.hide(animated: true)
                        }
                    }
                    let data2 = NSData.init(contentsOf: (session?.outputURL)!)
                    DispatchQueue.main.async(execute: {
                        self?.addaVideo(moveUrl: (session?.outputURL)!, data: data2! as Data)
                    })
                })
                
            }else{
                DispatchQueue.main.async(execute: {[weak self] in
                    self?.addaVideo(moveUrl: moveUrl,  data: data! as Data)
                })
            }
            
        }else{
            //拿到选择的图片
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            let qualitydata = PLGlobalClass.compressImageQuality(image)
            
            //相册消失
            picker.dismiss(animated: true, completion: nil)
            DispatchQueue.main.async(execute: { [weak self] in
                if ( self?.isCoverImage == true){
                    
                    self?.hasCoverImage = true
                    self?.rightImgBtn?.setImage(image, for:  .normal)
                    //上传
                    if self?.rightImgBtn != nil{
                        GlobalClass.requestToupdateFile(type: .IMG, realType: nil, files: [qualitydata!], imageBtn: (self?.rightImgBtn!)!)
                    }
                }else{
                    self?.addaImage(image: image, data: qualitydata!)
                }
            })
        }
    }
    
    //TODO:附件上传网络请求
    func requestToupdateFile(type: UpdateFileType ,realType: UpdateFileType? ,files:Array<Data>, model:TuwenModel?){

        let cell = self.tableView.cellForRow(at: IndexPath.init(row: self.contentArr.index(of: model!), section: 0)) as? TuwenCell
        
        var HUD = MBProgressHUD()
        if cell?.contentImg != nil{
            HUD = MBProgressHUD.showAdded(to: (cell?.contentImg)!, animated: true)
        }
        HUD.bezelView.style = .solidColor
        HUD.bezelView.backgroundColor = UIColor.clear
        HUD.isUserInteractionEnabled = false

        cell?.reUploadBtn.handleEventTouchUpInside(callback: {[weak self] in
            if realType == .VIDEP{
                if model?.imgcontent.count == 0{
                    self?.requestToupdateFile(type: .IMG , realType: realType , files: [(model?.videoImgData)!] , model: model)
                }
                if model?.content.count == 0{
                    self?.requestToupdateFile(type: .VIDEP , realType: realType , files: [(model?.videoData)!] , model: model)
                }
            }else{
                self?.requestToupdateFile(type: type , realType: realType , files: files , model: model)
            }
        })
        
        let animation = CATransition.init()
        animation.type = kCATransitionFade
        animation.duration = 0.2
        cell?.reUploadBtn.layer.add(animation, forKey: nil)
        cell?.reUploadBtn.isHidden = true
        
        ClanAPI.clanRequestPOST_Updatefile(type, files: files , progress: { (progress) in
        }, success: {[weak cell] (_, result ) in
            
            if (result is Dictionary<String,Any>){
                var dict = result as! Dictionary<String,Any>

                if (dict["data"] is Array<Dictionary<String,Any>>){
                    let arr = dict["data"] as! Array<Dictionary<String,Any>>
                    let uploadarr = uploadfilesModel.mj_objectArray(withKeyValuesArray: arr)

                    if model != nil{
                        let upload = uploadarr?.firstObject as? uploadfilesModel
                        if(model?.type == "2" && type == .IMG){
                            model?.imgcontent = (upload?.path)!
                        }else{
                            model?.content = (upload?.path)!
                        }
                    }
                }
            }else{
                let animation = CATransition.init()
                animation.type = kCATransitionFade
                animation.duration = 0.2
                cell?.reUploadBtn.layer.add(animation, forKey: nil)
                cell?.reUploadBtn.isHidden = false
            }
            
            if(realType == .VIDEP){
                if type == .VIDEP{
                    if (model?.imgcontent.count ?? 0) > 0 && cell?.contentImg != nil{
                        HUD.hide(animated: true)
                    }
                }
                if type == .IMG{
                    if (model?.content.count ?? 0) > 0  && cell?.contentImg != nil{
                        HUD.hide(animated: true)
                    }
                }
            }else if (cell?.contentImg != nil){
                HUD.hide(animated: true)
            }
        }, faile: {[weak cell]  (_, error) in
            if (cell?.contentImg != nil){
                HUD.hide(animated: true)
            }

            let animation = CATransition.init()
            animation.type = kCATransitionFade
            animation.duration = 0.2
            cell?.reUploadBtn.layer.add(animation, forKey: nil)
            cell?.reUploadBtn.isHidden = false
        })
    }
    
    //TODO:是否还可以继续上传附件
    func enclosureIfcanSelected(canselected: Bool) {
        if canselected{
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

    
    //TODO:添加一个视频
    func addaVideo(moveUrl:URL  ,data:Data ) {
        
        if self.textInputView.text?.count==0 || self.textInputView.text == placeStr{
        }else{
            let model = TuwenModel()
            model.type = "0"
            model.content = self.textInputView.text
            contentArr.add(model)
        }
        
        let model = TuwenModel()
        model.type = "2"
        model.img = PLGlobalClass.getImage(moveUrl)//缩略图
        model.videoUrl = moveUrl
        model.videoData = data
        model.videoImgData = UIImagePNGRepresentation(model.img!)!

        contentArr.insert(model, at: 0)
        textInputView.text = ""
        tableView.reloadData()
        
        let cell = self.tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? TuwenCell
        if cell != nil{
            tableView.scrollRectToVisible(CGRect.init(x: 0, y: (cell?.top_sd ?? 0)!, width: KScreenWidth, height: (cell?.height_sd ?? 0)! + F_I6(place: 130)), animated: true)
        }
        
        //视频
        self.requestToupdateFile(type: .VIDEP, realType: .VIDEP, files: [data],  model: model)
        //视频封面
        self.requestToupdateFile(type: .IMG, realType: .VIDEP, files:[model.videoImgData!],  model: model)
    }
    
    //TODO:添加一个图片
    func addaImage(image:UIImage ,data:Data ) {
        
        if self.textInputView.text?.count==0 || self.textInputView.text == placeStr{

        }else{
            let model = TuwenModel()
            model.type = "0"
            model.content = self.textInputView.text
            contentArr.add(model)
        }

        let model = TuwenModel()
        model.type = "1"
        model.img = image
        contentArr.add(model)
        
        textInputView.text = ""
        tableView.reloadData()
        
        tableView.scrollToRow(at: IndexPath.init(row: self.contentArr.count-1, section: 0), at: .top, animated: true)

        self.requestToupdateFile(type: .IMG, realType: nil, files: [data],  model: model)
    }
    
    //TODO:删除一个图片或视频，刷图片列表
    func reloadenclosureViewWithDeleteImageBtn(imageBtn : KButton ) {
        self.imageBtnArr.remove(at: self.imageBtnArr.index(of: imageBtn)!)
        imageBtn.removeFromSuperview()
        //可以继续上传附件
        self.enclosureIfcanSelected(canselected: true)
        self.reloadmediatype()
    }
    
    // MARK: - 功能
    func cellPlay(cell : TuwenCell){
        
        PLGlobalClass.theSinglePlayercallBack({[weak self , weak cell] (deleBtn, thePlayer , lable) in
            self?.player = thePlayer
            if (deleBtn is KNaviBarBtnItem){
                let dele = deleBtn as! KNaviBarBtnItem
                dele.button.handleEventTouchUpInside(callback: {
                    self?.player?.destroyPlayer()
                    //删除一个视频，刷图片列表
                    self?.contentArr.remove((cell?.model!)!)
                    self?.tableView.reloadData()
                })
            }
            self?.player?.videoUrl = cell?.model?.videoUrl
            self?.player?.player.play()
            self?.view.addSubview((self?.player!)!)
            self?.player?.addSubview(deleBtn as! UIView)
            self?.player?.addSubview(lable!)
            self?.player?.slider.valueChangeBlock = { (slider) -> () in
                lable?.text = self?.player?.progressLabel.text
            }
        })
    }
    
    func playerDestroy() {
        if (player != nil){
            player?.destroyPlayer()
            player = nil
        }
    }
    
    //刷新mediatype 除了视频之外的状态
    func reloadmediatype() {
        if (self.imageBtnArr.count<9){
            self.enclosureIfcanSelected(canselected: true)
            self.mediatype = "3"//多图 不能继续上传附件
            if(self.imageBtnArr.count == 1){
                self.mediatype = "2"//多图 不能继续上传附件
            }
            if(self.imageBtnArr.count == 0){
                self.mediatype = "1"//多图 不能继续上传附件
            }
        }else{
            self.mediatype = "3"//多图 不能继续上传附件
            self.enclosureIfcanSelected(canselected: false)
        }
    }
    
    //MARK: - 发布企业秀
    func publicClick() {
        self.view.endEditing(true)

        var coverpathStr = ""
        let covermodel = rightImgBtn?.attribute as? uploadfilesModel
        
        if self.hasCoverImage{
            if covermodel?.path.count ?? 0 > 0{
                coverpathStr = (covermodel?.path)!
            }else{
                WFHudView.showMsg("请等待封面上传完成", in: self.view)
                return
            }
        }else{
            WFHudView.showMsg("请上传封面", in: self.view)
            return
        }
        
        if self.companyNameView?.textField.text?.count == 0{
            WFHudView.showMsg("请填写企业名称", in: self.view)
            return
        }
        
        if self.titleInputView.text?.count==0{
            WFHudView.showMsg("请输入标题", in: self.view)
            return
        }
        
        if self.titleInputView.text == placetitleStr{
            WFHudView.showMsg("请输入标题", in: self.view)
            return
        }
        
        if contentArr.count == 0 && (self.textInputView.text.count==0 || self.textInputView.text == placeStr){
            WFHudView.showMsg("请输入正文", in: self.view)
            return
        }

        if self.textInputView.text?.count==0 || self.textInputView.text == placeStr{
        }else{
            let model = TuwenModel()
            model.type = "0"
            model.content = self.textInputView.text
            contentArr.add(model)
        }
        
        let contextArr : NSMutableArray = []
        var jsonStr = ""
        
        for model in contentArr  {

            if model is TuwenModel{
                let tuwen = model as? TuwenModel
                
                if (tuwen?.content.count ?? 0) > 0{
                    var dic = ["type":tuwen?.type,
                                "content":tuwen?.content]
                    if tuwen?.type == "2"{
                        if tuwen?.imgcontent.count == 0{
                            WFHudView.showMsg("视频封面正在上传中，请耐心等待", in: self.view)
                            return
                        }
                        dic["imgcontent"] = tuwen?.imgcontent
                    }
                    contextArr.add(dic)
                }else{
                    if tuwen?.type == "2"{
                        WFHudView.showMsg("视频正在上传中，请耐心等待", in: self.view)
                        return
                    }
                    if tuwen?.type == "1"{
                        WFHudView.showMsg("图片正在上传中，请耐心等待", in: self.view)
                        return
                    }
                }
            }
        }
        
        //转换为字典或者数组
        //- (id)mj_JSONObject;
        //转换为JSON 字符串
        //- (NSString *)mj_JSONString;
        jsonStr = contextArr.mj_JSONString()
        
        self.showGifView()

        ClanAPI.requestForSubmitenterprise(title: self.titleInputView.text ?? "", context: jsonStr , name: self.companyNameView?.textField.text ?? "", img: coverpathStr ) {[weak self] (result) in
            self?.hiddenGifView()


            if ((result.status) == "200"){
                WFHudView.showMsg("发布成功", in: self?.view)
                self?.navigationController?.popViewController(animated: true)
                self?.lastVC?.tableView.mj_header.beginRefreshing()
                
                GlobalClass.single_event(eventName: CUKey.UM_qyx_public)
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

//MARK: - ----------------图文model
class TuwenModel: KBaseModel {
    
    var type : String = ""       //0为文字，1为图片  2 视频
    var content : String = ""    //图片
    var img : UIImage?           //图片上传未完成时的本地图片
    var videoData : Data?        //要上传的视频
    var videoImgData : Data?     //要上传的视频封面

    var imgcontent : String = "" //视频封面图片
    var videoUrl : URL?          //本地视频播放时地址
}


//MARK: - ---------------图文cell
class TuwenCell: UITableViewCell,UITextViewDelegate {
    
    var row = 0
    /// 播放按钮
    var playBtn = UIButton()
    /// 重新上传按钮
    var reUploadBtn = UIButton()
    
    var contentTextView = UITextView()
    var contentImg = UIImageView()
    var ImgDeleBtn = UIButton()
    
    var model : TuwenModel?
    var HUD : MBProgressHUD?
    
    //MARK:加载企业秀详情时 加载model
    func reloadCell(model : TuwenModel){
        self.model = model
        
        let type = model.type
        let content = model.content
        let img = model.img

        if type == "0"{
            contentTextView.text = content
            contentTextView.height_sd = TuwenCell.gettextHeigh(text: content)
            contentImg.isHidden = true
            contentTextView.isHidden = false
        }else{
            contentTextView.isHidden = true
            contentImg.isHidden = false
            
            if model.type == "2"{
                contentImg.height_sd = (KScreenWidth-24)/4*3
                if img == nil{
                    contentImg.sd_setImage(with: URL.init(string: NSString.formatImageUrl(with: model.imgcontent, ifThumb: false, thumb_W: 0)), placeholderImage: UIImage.init(named: ImageDefault.imagePlace), options: .retryFailed)

                }else{
                    contentImg.image = img
                }
            }else{
                if img == nil{
                    let imageModel = String.getImageSize(urlStr: content)
                    self.contentImg.sd_setImage(with: URL.init(string: NSString.formatImageUrl(with:content, ifThumb: false, thumb_W: 0 )), placeholderImage: UIImage.init(named: ImageDefault.imagePlace), options: .retryFailed)

                    if imageModel != nil{
                        self.contentImg.height_sd = (imageModel?.heigh)!*(KScreenWidth - 24)/(imageModel?.width)!
                    }else{
                        self.contentImg.height_sd = (KScreenWidth-24)/4*3 + 10
                    }
                }else{
                    contentImg.image = img
                    contentImg.height_sd = PLGlobalClass.getImageHeight(withWidth: KScreenWidth-24, img: img)
                }
            }
            
            //上传动画
            if model.content.count == 0{
                if HUD == nil{
                    HUD = MBProgressHUD.showAdded(to: contentImg, animated: true)
                    HUD?.isUserInteractionEnabled = false
                    HUD?.bezelView.style = .solidColor
                    HUD?.bezelView.backgroundColor = UIColor.clear
                }else{
                    HUD?.show(animated: true)
                }
            }else{
                HUD?.hide(animated: true)
            }
        }
        
        playBtn.isHidden = true
        if type == "2"{
            playBtn.isHidden = false
        }
        
        ImgDeleBtn.isHidden = true
        ImgDeleBtn.centerY_sd = contentImg.centerY_sd
        playBtn.center = contentImg.center
    }
    
    class func getCellHeigh(model : TuwenModel) -> (CGFloat){
        
        let type = model.type
        let content = model.content
        let img = model.img
        if type == "0"{
            return TuwenCell.gettextHeigh(text: content) + 20
        }
        
        if type == "1"{
            if img == nil{
                let imageModel = String.getImageSize(urlStr: content)
                if imageModel != nil{
                    return (imageModel?.heigh)!*(KScreenWidth - 24)/(imageModel?.width)!  + 10
                }else{
                    return (KScreenWidth-24)/4*3 + 10
                }
            }
            return PLGlobalClass.getImageHeight(withWidth: KScreenWidth-24, img: img) + 10
        }else{
            return (KScreenWidth-24)/4*3 + 10
        }
    }
    
    //MARK:发布企业秀时 加载model
    func reloadPublicCell(model : TuwenModel){
        self.model = model
        
        let type = model.type
        let content = model.content
        let img = model.img
        
        if type == "0"{
            contentTextView.text = content
            contentTextView.height_sd = TuwenCell.gettextHeigh(text: content)
            contentImg.isHidden = true
            contentTextView.isHidden = false
        }else{
            contentTextView.isHidden = true
            contentImg.isHidden = false
            
            if model.type == "2"{
                contentImg.height_sd = (KScreenWidth-24)/4*3
                contentImg.image = img
            }else{
                contentImg.image = img
                contentImg.height_sd = PLGlobalClass.getImageHeight(withWidth: KScreenWidth-24, img: img)
            }
            
            //上传动画
            if model.content.count == 0{
                if HUD == nil{
                    HUD = MBProgressHUD.showAdded(to: contentImg, animated: true)
                    HUD?.bezelView.style = .solidColor
                    HUD?.bezelView.backgroundColor = UIColor.clear
                    HUD?.isUserInteractionEnabled = false
                }else{
                    HUD?.show(animated: true)
                }
            }else{
                HUD?.hide(animated: true)
            }
        }
        playBtn.isHidden = true
        ImgDeleBtn.isHidden = true
        ImgDeleBtn.centerY_sd = contentImg.centerY_sd
        playBtn.center = contentImg.center
        reUploadBtn.center = contentImg.center

        if type == "2"{
            playBtn.isHidden = false
            ImgDeleBtn.bottom_sd = contentImg.bottom_sd - 40
        }
        
    }
    
    class func getPublicCellHeigh(model : TuwenModel) -> (CGFloat){
        
        let type = model.type
        let content = model.content
        let img = model.img
        if type == "0"{
            return TuwenCell.gettextHeigh(text: content) + 20
        }
        
        if type == "1"{
            return PLGlobalClass.getImageHeight(withWidth: KScreenWidth-24, img: img) + 10
        }else{
            return (KScreenWidth-24)/4*3 + 10
        }
    }
    
    class func gettextHeigh(text : String) -> (CGFloat){
        
        let textView = UITextView.init(frame: CGRect.init(x: 5, y: 10, width: KScreenWidth-24, height: F_I6(place: 100)))
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = text
        return textView.contentSize.height
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentTextView = UITextView.init(frame: CGRect.init(x: 12, y: 10, width: KScreenWidth-24, height: F_I6(place: 100)))
        contentTextView.font = UIFont.systemFont(ofSize: 16)
        self.contentView.addSubview(contentTextView)
        
        contentImg = UIImageView.init(frame: CGRect.init(x: 12, y: 5, width: KScreenWidth-24, height: F_I6(place: 100)))
        self.contentView.addSubview(contentImg)
        contentImg.clipsToBounds = true
        contentImg.isUserInteractionEnabled = true
        contentImg.contentMode = .scaleAspectFill
        
        ImgDeleBtn = UIButton.init(frame: CGRect.init(x: F_I6(place: 80), y: F_I6(place: 80), width: KScreenWidth - 200, height: F_I6(place: 44)))
        ImgDeleBtn.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
        ImgDeleBtn.setTitle("删除", for: .normal)
        ImgDeleBtn.layer.cornerRadius = 5
        ImgDeleBtn.clipsToBounds = true
        ImgDeleBtn.centerX_sd = KScreenWidth/2
        self.contentView.addSubview(ImgDeleBtn)
        
        playBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 44, height: 44))
        self.contentView.addSubview(playBtn)
        playBtn.setImage(UIImage.init(named: "dyna_4_play"), for: .normal)
        playBtn.isHidden = true
        
        reUploadBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 48, height: 48))
        self.contentView.addSubview(reUploadBtn)
        reUploadBtn.setImage(UIImage.init(named: "dyna_4_play"), for: .normal)
        reUploadBtn.isHidden = true
        reUploadBtn.backgroundColor = UIColor.black
        reUploadBtn.setImage(UIImage.init(named: "report"), for: .normal)
        reUploadBtn.isUserInteractionEnabled = true
        reUploadBtn.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

