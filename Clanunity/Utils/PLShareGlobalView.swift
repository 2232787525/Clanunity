//
//  PLShareGlobalView.swift
//  PalmLive
//
//  Created by wangyadong on 2017/9/14.
//  Copyright © 2017年 zfy_srf. All rights reserved.
//

import UIKit
import MBProgressHUD
import MJRefresh

class PLShareGlobalView: UIView , TencentSessionDelegate  {
    func tencentDidLogin() {
        
    }
    
    func tencentDidNotLogin(_ cancelled: Bool) {
        
    }
    
    func tencentDidNotNetWork() {
        
    }
    
    
    static let shareInstance = PLShareGlobalView()
    
    private var bottomView = UIView()
    private var cancleButton = UIButton()
    private var scrollView = UIScrollView()
    private var shareClicked:(((_ shareType:ShareThirdType) -> Void)?)
     
    private init(){
        super.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight));
        self.backgroundColor = UIColor.init(white: 0, alpha: 0)
        self.isHidden = true
        self.bottomView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 180*kScreenScale + KBottomStatusH/2.0))
        self.bottomView.backgroundColor = UIColor.white
        self.addGuanjiaShareView()
        self.showShareItemView()
        self.addSubview(self.bottomView)
        self.bottomView.top_sd = KScreenHeight
        let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(self.close))
        self.addGestureRecognizer(tapGes)
    }

    func addGuanjiaShareView() -> Void {

        self.scrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: 44*kScreenScale, width: KScreenWidth, height: 90*kScreenScale))
        self.bottomView.addSubview(self.scrollView)
        self.cancleButton = UIButton.init(frame: CGRect.init(x: KScreenWidth - F_I6(place: 44), y: 0, width: 44*kScreenScale, height: 44*kScreenScale))
        self.cancleButton.setImage(UIImage.init(named: "close_2"), for: .normal)
        self.bottomView.addSubview(self.cancleButton)
        self.cancleButton.addTarget(self, action: #selector(self.close), for: UIControlEvents.touchUpInside)
    }
    
    func showShareItemView() -> Void {
        let shareArray = [["image":"share_weixin","title":"微信"],
                          ["image":"share_w_friend","title":"朋友圈"],
                          ["image":"share_qq","title":"QQ"],
                          ["image":"share_qzone","title":"QQ空间"]]
        let toleft = F_I6(place: 35)
        let betw = F_I6(place: 35)

        self.scrollView.removeAllSubviews()
        for index in 0 ..< shareArray.count {
            let imgView = UIImageView.init(frame: CGRect.init(x: toleft+CGFloat(index)*(50*kScreenScale+betw), y: 10.0*kScreenScale, width: 50.0*kScreenScale, height: 50.0*kScreenScale))
            imgView.image = UIImage.init(named: shareArray[index]["image"]!)
            
            let label = UILabel.init(frame: CGRect.init(x: imgView.left_sd-5*kScreenScale, y: imgView.bottom_sd+5*kScreenScale, width: imgView.width_sd+10*kScreenScale, height: 20*kScreenScale))
            label.text = shareArray[index]["title"]
            label.font = UIFont.systemFont(ofSize: 13)
            label.textColor = UIColor.textColor1
            label.textAlignment = .center
            self.bottomView.addSubview(label)
            
            self.scrollView.addSubview(imgView)
            self.scrollView.addSubview(label)
            let topView = UIView.init(frame: CGRect.init(x: (label.left_sd), y: imgView.top_sd, width: (label.width_sd), height: (label.bottom_sd)))
            topView.tag = 10086+index
            self.scrollView.addSubview(topView)
            
            let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(self.tapAction(tap:)))
            topView.addGestureRecognizer(tapGes)

            self.scrollView.contentSize = CGSize.init(width: (label.right_sd)+30, height: self.scrollView.height_sd)
        }
    }
    
    func tapAction(tap:UITapGestureRecognizer) -> Void {
        
        let tag = (tap.view?.tag)! - 10086
        if tag == 0 || tag == 1 {
            if WXApi.isWXAppInstalled() {
                if tag == 0 {
                    self.shareClicked!(ShareThirdTypeWechat)
                }else{
                    self.shareClicked!(ShareThirdTypeWechatCircle)
                }
            }else{
                UIApplication.shared.openURL(URL.init(string: WXApi.getWXAppInstallUrl())!)
            }
        }
        if tag == 2 || tag == 3 {
            
            if QQApiInterface.isQQInstalled() {
                if tag == 2 {
                    self.shareClicked!(ShareThirdTypeQQ)
                }else{
                    self.shareClicked!(ShareThirdTypeQQZone)
                }
            }else{
                UIApplication.shared.openURL(URL.init(string: QQApiInterface.getQQInstallUrl())!)
            }
        }
    }

    /// 关闭
    public func close() -> Void{
        UIView.animate(withDuration: 0.25, animations: { 
            self.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
            self.bottomView.top_sd = KScreenHeight
        }) { (finish:Bool) in
            if (finish){
                self.isHidden = true
                self.removeFromSuperview()
            }
        }
    }
    
    /// 显示View
    ///
    /// - Parameter block: <#block description#>
    public func showShareClicked(block:@escaping (_ shareType:ShareThirdType) ->()){
        self.isUserInteractionEnabled = true

        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.isHidden = false
            APPDELEGATE.window.addSubview(self!)
            self?.backgroundColor = UIColor.init(white: 0.2, alpha: 0.35)
            self?.bottomView.bottom_sd = KScreenHeight
        }
        self.shareClicked = block
    }
    
    ///分享到微信/朋友圈 ，message 分享的实体
    public func shareToWechat(scene: WXScene,message:WXMediaMessage) -> Void{
        
        let sendReq = SendMessageToWXReq.init()
        sendReq.bText = false
        //发送的目标场景，可以选择发送到会话(WXSceneSession)或者朋友圈(WXSceneTimeline)。 默认发送到会话。
        sendReq.scene = Int32(scene.rawValue)
        sendReq.message = message
        WXApi.send(sendReq)  //let ifsend =
        self.close()
    }
    
    ///分享到qq/QQ空间，objc分享实体
    public func shareToQQ(shareType:ShareThirdType,objc:QQApiObject) -> Void{
        //这句话获取QQ权限，非写不可
        let _ = TencentOAuth.init(appId: ThirdKey.QQAppId, andDelegate: self)
        let req = SendMessageToQQReq.init(content: objc)
        if (shareType == ShareThirdTypeQQ) {
            QQApiInterface.send(req)
        }else if (shareType == ShareThirdTypeQQZone){
            QQApiInterface.sendReq(toQZone: req)
        }
        self.close()
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///分享 sharetype:分享类型 1. 动态, 2. 活动
    class func toShare(sharetype : String?, targetid: String, shareTitle : String? , shareUrl : String?, shareImgUrl : String? , shareDes : String? , shareimg : String?) {
        
        APPDELEGATE.shareSucceedBlock = {
            if sharetype != nil{
                //QQ分享成功回调 - 服务器分享次数+1
                print("QQ分享成功回调 - 服务器分享次数+1")
                ClanAPI.requestForshare(sharetype: sharetype!, targetid: targetid) { (result) in
                }
            }
        }

        ThirdLoginManager.shareInstance().shareSucceedBlock = {
            if sharetype != nil{
                //微信分享成功回调 - 服务器分享次数+1
                print("微信分享成功回调 - 服务器分享次数+1")
                ClanAPI.requestForshare(sharetype: sharetype!, targetid: targetid) { (result) in
                }
            }
        }
        
        PLShareGlobalView.shareInstance.showShareClicked {(type) in
            
            PLShareGlobalView.shareInstance.isUserInteractionEnabled = false
            if type == ShareThirdTypeWechat || type == ShareThirdTypeWechatCircle{
                
                DispatchQueue.global().async(execute: {
                    
                    let message = WXMediaMessage.init()
                    
                    if shareTitle != nil && (shareTitle?.count)! > 50 {
                        let index : String.Index = String.Index.init(encodedOffset: 50)
                        let str : String = (shareTitle)!
                        message.title = String(str[..<index])
                    }else{
                        message.title = shareTitle
                    }
                    
                    if shareDes != nil && (shareDes?.count)! > 200 {
                        let index : String.Index = String.Index.init(encodedOffset: 200)
                        let str : String = (shareDes)!
                        message.description = String(str[..<index])
                    }else{
                        message.description = shareDes
                    }
                    if shareimg != nil{
                        message.thumbData = PLGlobalClass.compressImage(UIImage.init(named: (shareimg)!), toByte: 32000)
                        
                    }else if (shareImgUrl != nil && URL.init(string: (shareImgUrl!)) != nil && NSData.init(contentsOf: URL.init(string: (shareImgUrl!))!) != nil){
                        
                        let compressData = PLGlobalClass.compressImage(NSData.init(contentsOf: URL.init(string: (shareImgUrl!))!), toByte: 32000)
                        
                        if compressData != nil{
                            message.thumbData = compressData;
                        }
                    }
                    
                    let webObj = WXWebpageObject.init()
                    let url = shareUrl
                    
                    webObj.webpageUrl = url
                    message.mediaObject = webObj
                    
                    DispatchQueue.main.async {
                        PLShareGlobalView.shareInstance.shareToWechat(scene: type == ShareThirdTypeWechatCircle ? WXSceneTimeline : WXSceneSession, message: message);
                    }
                })
                
            }else{
                let url = URL.init(string: (shareUrl!))
                DispatchQueue.global().async {
                    var sharetitle : String?
                    var shareDess : String?
                    
                    if shareTitle != nil && (shareTitle?.count)! > 50 {
                        let index : String.Index = String.Index.init(encodedOffset: 50)
                        let str : String = (shareTitle)!
                        sharetitle = String(str[..<index])
                    }else{
                        sharetitle = (shareTitle)
                    }
                    if shareDes != nil && (shareDes?.count)! > 200 {
                        let index : String.Index = String.Index.init(encodedOffset: 200)
                        let str : String = (shareDes)!
                        shareDess = String(str[..<index])
                        
                    }else{
                        shareDess = (shareDes)
                    }
                    let obj : QQApiNewsObject = QQApiNewsObject.object(with: url, title:sharetitle, description: shareDess, previewImageURL: URL.init(string: shareImgUrl ?? "")) as! QQApiNewsObject
                    obj.shareDestType = ShareDestTypeQQ
                    DispatchQueue.main.async {
                        PLShareGlobalView.shareInstance.shareToQQ(shareType: type, objc: obj)
                    }
                }
            }
        }
    }
}


class GlobalClass: NSObject {

    //MARK: - 多处请求封装 - 请求复杂结果封装
    //TODO:附件上传 封装
    class func requestToupdateFile(type: UpdateFileType ,realType: UpdateFileType? ,files:Array<Data>, imageBtn:KButton){
        
        //重新上传
        imageBtn.uploadfail?.handleEventTouchUpInside(callback: { [weak imageBtn] in
            self.requestToupdateFile(type: type, realType: realType, files: files, imageBtn: imageBtn!)
        })
        
        let HUD = MBProgressHUD.showAdded(to: imageBtn, animated: true)
        HUD.bezelView.style = .solidColor
        HUD.bezelView.backgroundColor = UIColor.clear
        HUD.isUserInteractionEnabled = false
        imageBtn.mengban?.removeFromSuperview()
        imageBtn.uploadfail?.isHidden = true
        
        ClanAPI.clanRequestPOST_Updatefile(type, files: files , progress: { (progress) in
        }, success: { (_, result ) in
            HUD.hide(animated: true)
            
            if (result is Dictionary<String,Any>){
                let dic = result as! Dictionary<String,Any>
                
                if (dic["data"] is Array<Dictionary<String,Any>>){
                    let arr = dic["data"] as! Array<Dictionary<String,Any>>
                    let uploadarr = uploadfilesModel.mj_objectArray(withKeyValuesArray: arr)
                    let uploadModel = uploadarr?.firstObject as? uploadfilesModel
                    
                    let model = imageBtn.attribute as? uploadfilesModel
                    if model == nil{
                        if realType == .VIDEP && type == .IMG{
                            uploadModel?.videoImagePath = (uploadModel?.path)!
                            uploadModel?.path = ""
                            imageBtn.attribute = uploadModel
                        }else{
                            imageBtn.attribute = uploadModel
                        }
                    }else{
                        if type == .VIDEP{
                            model?.path = (uploadModel?.path)!
                        }
                        if type == .IMG{
                            model?.videoImagePath = (uploadModel?.path)!
                        }
                    }
                }
            }
        }, faile: { (_, error) in
            HUD.hide(animated: true)
            imageBtn.uploadfail?.isHidden = false
            print("上传附件失败")
        })
    }
    
    //TODO:实名认证判断
    class func requestAuthType(callBack : @escaping (NSInteger) -> ()) -> (){
        
        let authtype = UserServre.shareService.userModel.authtype //0未认证 1 已认证 其他 审核中
        if authtype == 1{
            callBack(1)
            return
        }
        ClanAPI.requestForAuthStatus { (result) in
            if (result.data == nil){
                callBack(0)
            }else{
                let authtype = result.data as? NSInteger
                let model = UserServre.shareService.userModel
                model?.authtype = authtype!
                UserServre.shareService.cacheSaveRefresh()
                callBack(authtype!)
            }
        }
    }
    
    //MARK: - 登出
    //TODO:登出
    class func logout(){
        PLGlobalClass.currentViewController().navigationController?.popToRootViewController(animated: false)
        ClanServer.clearToken()
        UserServre.shareService.cacheClear();
        LoginServer.share.showLoginVC(block: { (status) in
        })
        
        let logout = LogoutAPI.init()
        logout.request(with: nil, completion: { (any, error) in
        })
        MTTNotification.post(CUKey.DDNotificationLogout, userInfo: nil, object: nil)
        //self.deleteNoticeData()
    }

    //批量删除消息（通过搜索条件删除消息列表）
    class func deleteNoticeData(){
        DispatchQueue.global().async {
            
            let arr = NoticeModel.searchDataWhere(["type" : "2"])
            if arr == nil{}else{
                KDBManager.share().queue.inTransaction({ (db, roolback) in
                    for model in arr!{
                        NoticeModel.deleteTable(withDB: db, primaryKeyId: model.d)
                    }
                })
            }
        }
    }

    //MARK: - 加载动画封装
    //TODO:小鱼加载动画
    class func customProgressHUD(view : UIView ) {
        MBProgressHUD.hide(for: view, animated: true)
        let hud = MBProgressHUD.showAdded(to: view , animated: true)
        hud.mode = .customView
        let img = UIImageView.init(image: UIImage.sd_animatedGIFNamed("jiazai-"))
        hud.customView = img
        hud.isUserInteractionEnabled = false
        hud.bezelView.color = UIColor.clear
    }
    
    //TODO:小鱼下拉加载动画设置
    class func setMjHeader(mjheader:MJRefreshGifHeader){
        //        let arr = NSArray.cdi_imagesWithGif(gifNameInBoundle: "加载=")
        var arr = [Any]()
        for i in 0...25{
            arr.append(UIImage.init(named: "2_" + String(i*4))!)
        }
        mjheader.setImages(arr , for: .willRefresh)
        mjheader.setImages(arr , for: .pulling)
        //隐藏字
        mjheader.lastUpdatedTimeLabel.isHidden = true
        // 隐藏状态
        mjheader.stateLabel.isHidden = true
        mjheader.setImages(arr , for: .refreshing)
    }
    
    
    //TODO:友盟统计事件
    class func single_event(eventName:String){
        MobClick.event(eventName)
    }
}







