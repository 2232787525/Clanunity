//
//  CULoginVC.swift
//  Clanunity
//
//  Created by 白bex on 2018/2/1.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

import UIKit
import MBProgressHUD

//MARK: - ----------------发布动态
class publicDynamic: KBaseClanViewController,UITextViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate {
    let placeStr = "来吧，尽情发挥吧..."
    let placetitleStr = "加个标题哟~"
    
    var camera = UIButton.init()
    var pictureAlbum = UIButton.init()
    var line = UIView.init()
    var addTitle = UIButton.init()
    var textInputView = UITextView()
    var titleInputView = UITextField.init()
    var EnclosureView = UIScrollView.init()
    var imageBtnArr = Array<KButton>()
    var mediatype = "1" //1.无图; 2,单图; 3,多图; 4,视频
    var lastVC : FirstViewController?
    
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        PLGlobalClass.setIQKeyboardToolBarEnable(true, distanceFromTextField: F_I6(place: 50))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        PLGlobalClass.setIQKeyboardToolBarEnable(false, distanceFromTextField: 0)
    }
    
    //MARK: - 加载页面 绘制UI
    override func viewDidLoad() {
        super.viewDidLoad()
        self.knavigationBar?.title = "发布"
        
        let publicItem = KNaviBarBtnItem.init(frame:  CGRect.init(x: KScreenWidth-44, y: KStatusBarHeight, width: 44, height: 44), title: "完成") { [weak self](sender) in
            self?.publicClick()
        }
        self.knavigationBar?.rightBarBtnItem = publicItem;
        
        self.createView()
        
        //键盘弹出时
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoard(notification: )), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoard(notification: )), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
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
            UIView.animate(withDuration: duration) {[weak self] in
                self?.camera.bottom_sd = kbRect.origin.y
                self?.pictureAlbum.bottom_sd = kbRect.origin.y
                self?.line.top_sd = (self?.camera.top_sd)! + F_I6(place: 5)
                self?.addTitle.top_sd = (self?.camera.top_sd)!-F_I6(place: 44)
            }
        }
    }

    //拍摄和相册选择按钮
    func createView(){
        let scrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: KTopHeight, width: KScreenWidth, height: KScreenHeight - KTopHeight))
        self.view.addSubview(scrollView)
        
        //输入View
        let titleView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 50))
        titleView.backgroundColor = UIColor.white
        scrollView.addSubview(titleView)
        
        titleInputView = UITextField.init(frame: CGRect.init(x: 10, y: 0, width: KScreenWidth-20, height: 50))
        titleInputView.textColor = UIColor.textColor1
        titleInputView.font = UIFont.boldSystemFont(ofSize: 18)
        titleInputView.text = placetitleStr
        titleInputView.delegate = self
        titleInputView.tag = 12
        scrollView.addSubview(titleInputView)
        titleInputView.isHidden = true
        titleInputView.addTarget(self, action: #selector(wordlimitTitle(withTf:)), for: UIControlEvents.editingChanged)
        _ = titleInputView.addBottomLine(color: UIColor.cutLineColor)
        
        //输入View
        textInputView = UITextView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: F_I6(place: 170)))
        textInputView.backgroundColor = UIColor.white
        textInputView.textColor = UIColor.textColor1
        textInputView.font = UIFont.systemFont(ofSize: 16)
        textInputView.text = placeStr
        textInputView.delegate = self
        textInputView.tag = 13
        scrollView.addSubview(textInputView)
        textInputView.textContainerInset = UIEdgeInsets.init(top: 10, left: 5, bottom: 10, right: 5)

        
        //附件View
        let EnclosureView = UIScrollView.init(frame: CGRect.init(x: 0, y: textInputView.bottom_sd, width: KScreenWidth, height: F_I6(place: 80)))
        EnclosureView.backgroundColor = UIColor.bgColor4
        scrollView.addSubview(EnclosureView)
        EnclosureView.showsVerticalScrollIndicator = false
        EnclosureView.showsHorizontalScrollIndicator = false
        EnclosureView.isHidden = true
        self.EnclosureView = EnclosureView
        
        
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
        
        let addTitle = UIButton.init(frame: CGRect.init(x: KScreenWidth-F_I6(place: 15)-F_I6(place: 78), y: camera.top_sd-F_I6(place: 44), width: F_I6(place: 78), height: F_I6(place: 26)))
        addTitle.setTitle("添加标题", for: .normal)
        addTitle.setTitle("隐藏标题", for: .selected)
        addTitle.backgroundColor = UIColor.baseColor
        addTitle.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        addTitle.layer.cornerRadius = addTitle.height_sd/2
        addTitle.clipsToBounds = true
        addTitle.handleEventTouchUpInside {[weak self,weak addTitle] in
            addTitle?.isSelected = !(addTitle?.isSelected)!
            //界面偏移动画
            UIView.animate(withDuration: 0.3) {
                if (addTitle?.isSelected)!{
                    self?.titleInputView.isHidden = false
                    self?.textInputView.top_sd = (self?.titleInputView.bottom_sd)!
                }else{
                    self?.titleInputView.isHidden = true
                    self?.textInputView.top_sd = (self?.titleInputView.top_sd)!
                }
                self?.EnclosureView.top_sd = (self?.textInputView.bottom_sd)!
            }
        }
        self.view.addSubview(addTitle)
        self.addTitle = addTitle
        
        
        camera.handleEventTouchUpInside {[weak self] in
            if self?.imageBtnArr.count==0{
                PLGlobalClass.openCameraIsAllowsEditing(false, videotape: true)
            }else{
                PLGlobalClass.openCameraIsAllowsEditing(false, videotape: false)
            }
        }
        
        pictureAlbum.handleEventTouchUpInside {[weak self] in
//            if self?.imageBtnArr.count==0{
//                PLGlobalClass.openAlbumIsAllowsEditing(false, alsoShowVideo: true)
//            }else{
//                PLGlobalClass.openAlbumIsAllowsEditing(false, alsoShowVideo: false)
//            }

            if (self?.imageBtnArr.count ?? 0) >= numDefault.knum_pickerPublic{
            }else{
                if self?.imageBtnArr.count==0{
                    
                    PLGlobalClass.openAlbumMultiSelection(withMaxNumber: numDefault.knum_pickerPublic, onlyPic: false, blockHandler: { (array) in
                        for assestModel in array!{
                            let model = assestModel as? ZLPhotoAssets
                            let image = model?.originImage
                            let qualitydata = PLGlobalClass.compressImageQuality(image)
                            //相册消失
                            DispatchQueue.main.async(execute: { [weak self] in
                                self?.addaImage(image: image!, data: qualitydata!)})
                        }
                    })
                }else{
                    PLGlobalClass.openAlbumMultiSelection(withMaxNumber: numDefault.knum_pickerPublic - (self?.imageBtnArr.count ?? 0), onlyPic: true, blockHandler: { (array) in
                        for assestModel in array!{
                            let model = assestModel as? ZLPhotoAssets
                            let image = model?.originImage
                            let qualitydata = PLGlobalClass.compressImageQuality(image)
                            //相册消失
                            DispatchQueue.main.async(execute: { [weak self] in
                                self?.addaImage(image: image!, data: qualitydata!)})
                        }
                    })
                }
            }
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
    
    //MARK: - UIImagePickerControllerDelegate选择好图片的回调
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if (info["UIImagePickerControllerMediaType"] as? String == "public.movie") {
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
                        hud.hide(animated: true)
                    }

                    let data2 = NSData.init(contentsOf: (session?.outputURL)!)
                    DispatchQueue.main.async(execute: {
                        self?.addaVideo(moveUrl: (session?.outputURL)!, data: data2!)
                    })
                })
                
            }else{
                DispatchQueue.main.async(execute: {[weak self] in
                    self?.addaVideo(moveUrl: moveUrl, data: data!)
                })
            }
        }else{
            //拿到选择的图片
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            let qualitydata = PLGlobalClass.compressImageQuality(image)
            
            //相册消失
            picker.dismiss(animated: true, completion: nil)

            DispatchQueue.main.async(execute: {[weak self] in
                self?.addaImage(image: image, data: qualitydata!)
            })
        }
    }
    
    //TODO:添加一个视频，刷EnclosureView
    func addaVideo(moveUrl:URL  ,data:NSData ) {
        let W = self.EnclosureView.height_sd-10
        let thumVideoImg = PLGlobalClass.getImage(moveUrl)//缩略图

        self.EnclosureView.removeAllSubviews()
        let img = PLGlobalClass.getImage(moveUrl)//缩略图
        let imageBtn = KButton.init(frame: CGRect.init(x: 16, y: 5, width: W, height: W), needMengban:false)
        imageBtn.setBackgroundImage(img, for: .normal)
        self.EnclosureView.addSubview(imageBtn)
        
        let delevideo = UIButton.init(frame: CGRect.init(x: W-14, y: 2, width: 12, height: 12))
        delevideo.setImage(UIImage.init(named: "close"), for: .normal)
        imageBtn.addSubview(delevideo)
        delevideo.handleEventTouchUpInside {[weak self,weak imageBtn] in
            //删除一个视频，刷图片列表
            self?.reloadenclosureViewWithDeleteImageBtn(imageBtn: imageBtn!)
        }
        
        self.EnclosureView.isHidden = false
        self.imageBtnArr.append(imageBtn)
        
        //不能继续上传附件
        enclosureIfcanSelected = false
        self.mediatype = "4"
        
        imageBtn.handleEventTouchUpInside(callback: {[weak self,weak imageBtn] in
            self?.view.endEditing(true)
            
            //TODO:播放器设置
            var player : XLVideoPlayer?
            PLGlobalClass.theSinglePlayercallBack({ (deleBtn, thePlayer , lable) in
                player = thePlayer
                if (deleBtn is KNaviBarBtnItem){
                    let dele = deleBtn as! KNaviBarBtnItem
                    dele.button.handleEventTouchUpInside(callback: {
                        player?.destroyPlayer()
                        //删除一个视频，刷图片列表
                        self?.reloadenclosureViewWithDeleteImageBtn(imageBtn: imageBtn!)
                    })
                }
                player?.videoUrl = moveUrl
                player?.player.play()
                self?.view.addSubview(player!)
                player?.addSubview(deleBtn as! UIView)
                player?.addSubview(lable!)
                player?.slider.valueChangeBlock = {(slider) -> () in
                    lable?.text = player?.progressLabel.text
                }
            })
        })
        
        //TODO:上传
        GlobalClass.requestToupdateFile(type: .VIDEP, realType: nil, files: [data as Data], imageBtn: imageBtn)
        //视频封面
        GlobalClass.requestToupdateFile(type: .IMG, realType: .VIDEP, files:[UIImagePNGRepresentation(thumVideoImg!)!], imageBtn: imageBtn)
        
    }
    
    //TODO:添加一个图片，刷EnclosureView
    func addaImage(image:UIImage ,data:Data ) {
        let W = self.EnclosureView.height_sd-10
        let count = self.imageBtnArr.count
        
        let imageBtn = KButton.init(frame: CGRect.init(x: 16 + (W + 5) * CGFloat(count), y: 5, width: W, height: W), needMengban:true)
        imageBtn.backgroundColor = UIColor.black
        imageBtn.imageView?.contentMode = .scaleAspectFill
        imageBtn.setImage(image, for:  .normal)
        
        let deleimage = UIButton.init(frame: CGRect.init(x: W-20, y: 0, width: 20, height: 20))
        deleimage.setImage(UIImage.init(named: "close"), for: .normal)
        imageBtn.addSubview(deleimage)
        deleimage.handleEventTouchUpInside(callback: {[weak self,weak imageBtn] in
            //删除一个图片，刷图片列表
            self?.reloadenclosureViewWithDeleteImageBtn(imageBtn: imageBtn!)
        })
        
        self.EnclosureView.addSubview(imageBtn)
        self.EnclosureView.isHidden = false
        self.EnclosureView.contentSize = CGSize.init(width: imageBtn.right_sd+16, height: self.EnclosureView.height_sd)
        self.imageBtnArr.append(imageBtn)
        
        self.reloadmediatype()
        
        let deleBtn = KNaviBarBtnItem.init(frame: CGRect.init(x: KScreenWidth-60, y: KStatusBarHeight, width: 44, height: 44), image: "deleteBig") { [weak self , weak imageBtn](sender) in
            //删除一个图片，刷图片列表
            self?.reloadenclosureViewWithDeleteImageBtn(imageBtn: imageBtn!)
        }
        let img = UIImage.init(named: "deleteBig")?.withRenderingMode(.alwaysOriginal)
        deleBtn.button.setImage(img, for: .normal)
        imageBtn.littleFrame = imageBtn.frame

        imageBtn.handleEventTouchUpInside(callback: {[weak self , weak imageBtn] in

            self?.view.endEditing(true)
            imageBtn?.isSelected = !(imageBtn?.isSelected)!
            imageBtn?.mengban?.alpha = 0
            if (imageBtn?.isSelected)!{
                //放大动画效果
                imageBtn?.frame = CGRect.init(x: (imageBtn?.littleFrame.origin.x)!  - (self?.EnclosureView.contentOffset.x)! , y: (self?.EnclosureView.top_sd)!+(imageBtn?.littleFrame.origin.y)!, width: (imageBtn?.littleFrame.width)!, height: (imageBtn?.littleFrame.height)!)

                self?.view.addSubview(imageBtn!)
                deleimage.removeFromSuperview()
                
                UIView.animate(withDuration: 0.3) {
                    imageBtn?.frame = CGRect.init(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight)
                    imageBtn?.addSubview(deleBtn)
                }
            }else{
                imageBtn?.mengban?.alpha = 1
                //缩小动画效果
                UIView.animate(withDuration: 0.3, animations: {
                    
                    imageBtn?.frame = CGRect.init(x: (imageBtn?.littleFrame.origin.x)! - (self?.EnclosureView.contentOffset.x)! , y: (self?.EnclosureView.top_sd)!+(imageBtn?.littleFrame.origin.y)!, width: (imageBtn?.littleFrame.width)!, height: (imageBtn?.littleFrame.height)!)

                    deleBtn.removeFromSuperview()
                    imageBtn?.addSubview(deleimage)
                }, completion: { (_) in
                    self?.EnclosureView.addSubview(imageBtn!)
                    imageBtn?.frame = (imageBtn?.littleFrame)!
                })
            }
        })
        
        //上传
        GlobalClass.requestToupdateFile(type: .IMG, realType: nil, files: [data as Data], imageBtn: imageBtn)
    }
    
    
    //TODO:删除一个图片或视频，刷图片列表
    func reloadenclosureViewWithDeleteImageBtn(imageBtn : KButton ) {
        self.imageBtnArr.remove(at: self.imageBtnArr.index(of: imageBtn)!)
        imageBtn.removeFromSuperview()
        //可以继续上传附件
        enclosureIfcanSelected = true
        
        let W = self.EnclosureView.height_sd-10
        if self.imageBtnArr.count>0{
            
            UIView.animate(withDuration: 0.3, animations: {[weak self] in
                for i in 0 ... (self?.imageBtnArr.count)!-1{
                    let imageBtn = self?.imageBtnArr[i]
                    imageBtn?.frame =  CGRect.init(x: 16 + (W + 5) * CGFloat(i), y: 5, width: W, height: W)
                    imageBtn?.littleFrame = (imageBtn?.frame)!

                    if i == (self?.imageBtnArr.count)!-1{
                        self?.EnclosureView.contentSize = CGSize.init(width: (imageBtn?.right_sd)!+16, height: (self?.EnclosureView.height_sd)!)
                    }
                }
            }, completion: { (_) in
            })
            self.EnclosureView.isHidden = false
        }else{
            self.EnclosureView.isHidden = true
        }
        self.reloadmediatype()
    }
    
    //刷新mediatype 除了视频之外的状态
    func reloadmediatype() {
        if (self.imageBtnArr.count<9){
            enclosureIfcanSelected = true
            self.mediatype = "3"//多图 不能继续上传附件
            if(self.imageBtnArr.count == 1){
                self.mediatype = "2"//多图 不能继续上传附件
            }
            if(self.imageBtnArr.count == 0){
                self.mediatype = "1"//多图 不能继续上传附件
            }
        }else{
            self.mediatype = "3"//多图 不能继续上传附件
            enclosureIfcanSelected = false
        }
    }
    
    //MARK: - 发布动态
    func publicClick() {
        
        
        var titleStr = ""
        if addTitle.isSelected{
            titleStr = self.titleInputView.text!
            if self.titleInputView.text == placetitleStr{
                titleStr = ""
            }
        }
        
        if self.textInputView.text.count==0{
            WFHudView.showMsg("请填写内容", in: self.view)
            return
        }
        if self.textInputView.text == placeStr{
            WFHudView.showMsg("请填写内容", in: self.view)
            return
        }
        
        var attachidStr = ""
        var attachpathStr = ""
        var videoimg = ""

        for imageBtn in self.imageBtnArr{
            let uploadmodel = imageBtn.attribute as? uploadfilesModel
            if (uploadmodel != nil){
                if uploadmodel!.id.count > 0{
                    if (attachidStr.count == 0) {
                        //第一次不拼接逗号
                        attachidStr.append(uploadmodel!.id)
                        attachpathStr.append(uploadmodel!.path)
                        
                        if attachpathStr.count == 0{
                            WFHudView.showMsg("请等待附件上传完成", in: self.view)
                            return
                        }
                        
                    }else{
                        attachidStr.append("," + uploadmodel!.id)
                        attachpathStr.append("," + uploadmodel!.path)
                        
                        if uploadmodel!.path.count == 0{
                            WFHudView.showMsg("请等待图片上传完成", in: self.view)
                            return
                        }
                    }
                }
            }else{
                WFHudView.showMsg("请等待附件上传完成", in: self.view)
                return
            }
        }

        let model = self.imageBtnArr.first?.attribute as? uploadfilesModel

        if (self.imageBtnArr.count == 1 && self.mediatype == "4" && (model?.videoImagePath == "" || model?.path == "" || model?.videoImagePath == nil || model?.path == nil)){
            WFHudView.showMsg("请等待视频上传完成", in: self.view)
            return
        }else{
            videoimg = model?.videoImagePath ?? ""
        }
        
        if (attachpathStr.count == 0){
            self.mediatype = "1"
        }
        
        self.showGifView()

        self.knavigationBar?.rightBarBtnItem?.isUserInteractionEnabled = false
        ClanAPI.requestForSubmitDynamic(title: titleStr, content: self.textInputView.text, mediatype: self.mediatype, attachid: attachidStr, attachpath: attachpathStr ,videoimg : videoimg) { [weak self] (result) in
            self?.knavigationBar?.rightBarBtnItem?.isUserInteractionEnabled = true
            self?.hiddenGifView()
            
            if ((result.status) == "200"){
                WFHudView.showMsg("发布成功", in: self?.view)
                self?.navigationController?.popViewController(animated: true)
                self?.lastVC?.tableView.mj_header.beginRefreshing()
                
                GlobalClass.single_event(eventName: CUKey.UM_dynamic_public)
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


//MARK: - ----------------附件上传返回信息model
class uploadfilesModel: KBaseModel {
    
    var videoImagePath : String = ""  //视频封面地址
    var path : String = ""  //附件地址 视频或图片
    var cdnpath : String = ""   //广告标题
    var id : String = "" //
}
