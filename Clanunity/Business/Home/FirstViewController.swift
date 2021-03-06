//
//  FirstViewController.swift
//  Clanunity
//
//  Created by wangyadong on 2018/1/29.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//
//MARK: - ----------------首页

import UIKit
import MJRefresh

class FirstViewController: BaseTabVC,UITableViewDataSource {
    var lcBannerView = BannerHeaderView.init()
    var headerView = UIView.init()
    
    var thisSource = [sourceModel]()//图标icon 从资源文件取
    var bannerArr = [adBannerModel]() //广告图Arr
    var dynamicArr = [DynamicModel]() //动态Arr
    var lastOrCurrentPlayIndex = 0
    var lastPlayCell = 0
    var player : XLVideoPlayer?
    var lastContentOffset = CGPoint()
    
    var ancestorAlterV : BounceAlter?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        let ifNewMess = PLGlobalClass.getValueFromFile(CUKey.kStartupInfo, withKey: CUKey.kNewMessage) as? String
        if(ifNewMess == "1"){
            self.knavigationBar?.rightBarBtnItem?.button.setImage(UIImage.init(named: "notice_new"), for: .normal)
        }else{
            self.knavigationBar?.rightBarBtnItem?.button.setImage(UIImage.init(named: "notice"), for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.playerDestroy()
    }
    
    override func kNotifiLoginSuccess() {
        dynamicArr.removeAll()
        self.checkIfNull()
        self.tableView.mj_header.beginRefreshing()
        self.alter()
    }
    
    //MARK: - 加载页面 绘制UI
    override func viewDidLoad() {
        super.viewDidLoad()
        self.knavigationBar?.title = "同宗汇"
        self.view.backgroundColor = UIColor.bgColor2
        
        let model = UserServre.shareService.userClub
        print("首页 - 我的姓氏:" + (model?.club ?? "没有姓氏"))
        
        headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: F_I6(place: 222)))
        headerView.backgroundColor = UIColor.white
        
        let right = KNaviBarBtnItem.init(frame: CGRect.init(x: KScreenWidth-44, y: KStatusBarHeight, width: 44, height: 44), image: "notice") {[weak self] (sender) in
            let vc = NoticeList.init()
            self?.navigationController?.pushViewController(vc, animated: true)
            PLGlobalClass.write(toFile: CUKey.kStartupInfo, withKey: CUKey.kNewMessage, value: "0")
        }
        self.knavigationBar?.rightBarBtnItem = right;
        
        
        //TODO:发布按钮
        let btn = UIButton.init(frame: CGRect.init(x: F_I6(place: 298), y: KScreenHeight-F_I6(place: 46)-KBottomHeight-F_I6(place: 68), width: F_I6(place: 68), height: F_I6(place: 68)));
        btn.setBackgroundImage(UIImage.init(named: "publicDynamic"), for: .normal)
        self.view.addSubview(btn)
        btn.handleEventTouchUpInside {[weak self] in
            
            if APPDELEGATE.networkStatus == 0{
                WFHudView.showMsg(TextDefault.noNetWork, in: self?.view)
            }else{
                let vc = publicDynamic.init()
                vc.hidesBottomBarWhenPushed = true
                vc.lastVC = self
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        //判断版本是否要更新
        self.versionAlter()
        
        //判断是否寄思先祖
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.alter()
        }
    }
    
    
    //MARK: - View - 页面
    
    //MARK: 设置banner的数据
    func setBannerData(){
        
        
        DispatchQueue.main.async {[weak self] in
            self?.lcBannerView = BannerHeaderView.bannerView(withFrame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: F_I6(place: 150)), placeHolderImg: UIImage.init(named: "centerBgImg"))
            self?.headerView.addSubview((self?.lcBannerView)!)
        }
        
        
        
        //banner位图片请求
        ClanAPI.requestForgetBannerList(type: "1") {[weak self] (result) in
            print(result.data ?? "BannerList==nil")
            
            if (result.data is Array<Dictionary<String,Any>>){
                let arr = result.data as! Array<Dictionary<String,Any>>
                self?.bannerArr = adBannerModel.mj_objectArray(withKeyValuesArray: arr) as! [adBannerModel]
                
                var arrStr = [String]()
                for model in (self?.bannerArr)! {
                    arrStr.append(NSString.formatImageUrl(with: model.imgurl, ifThumb: false, thumb_W: 0))
                }
                DispatchQueue.main.async {
                    self?.lcBannerView.bannerUrlArray = arrStr
                    if (self?.thisSource.count==0){
                        self?.headerView.height_sd = (self?.lcBannerView.height_sd)!
                        self?.tableView.tableHeaderView = self?.headerView
                    }
                }
            }
        }
        
        lcBannerView.bannerDidSelectItemAtIndex = {[weak self] (index) -> () in
            if((self?.bannerArr.count ?? 0) > index){
                let model = self?.bannerArr[index]
                if model?.type == 0{
                    //内链
                }else{
                    //外链
                    if((self?.bannerArr[index].url.count ?? 0) > 0){
                        //TODO:轮播图跳转
                        let vc = webVC.init()
                        vc.loadWebURLSring((self?.bannerArr[index].url)!)
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
    
    //MARK: 设置Icon的数据
    func setIconData() {
        let severversion = PLGlobalClass.getValueFromFile(CUKey.kSourceSave, withKey: CUKey.kServerSourceVersion) as? String ?? ""
        let sourceversion = PLGlobalClass.getValueFromFile(CUKey.kSourceSave, withKey: CUKey.kCurrentSourceVersion) as? String ?? ""
        
        if severversion == sourceversion{
            let source = PLGlobalClass.getValueFromFile(CUKey.kSourceSave, withKey: CUKey.kSourceSave)
            
            if ( source != nil && source is Dictionary<String, Any> ){
                
                let sourceDic = source as! Dictionary<String, Any>
                let sourceArr = sourceModel.mj_objectArray(withKeyValuesArray: sourceDic["list"]) as! [sourceModel]
                for sourceModel in sourceArr{
                    if (sourceModel.img_type == "1"){
                        thisSource.append(sourceModel)
                    }
                }
                if (thisSource.count==0){//请求
                    self.requestForResource()
                }else{
                    DispatchQueue.main.async {[weak self] in
                        self?.reloadIcon()
                    }
                }
                
            }else{//请求
                self.requestForResource()
            }
        }else{
            self.requestForResource()
        }
    }
    
    //MARK:按照数据 创建icon
    func reloadIcon() {
        
        
        let W = Int(F_I6(place:60))
        let imgW = Int(F_I6(place:49))
        let H = Int(F_I6(place:74))//F_I6(place: 56)   62
        let toTop = 14//8
        let toLeft = Int(F_I6(place:52))//8
        
        let count = thisSource.count
        let betw = (Int(KScreenWidth) - toLeft*2 - W*count)/(count-1)
        
        for view in (self.headerView.subviews){
            if (view is ImgAndLabView){
                view.removeFromSuperview()
            }
        }
        
        for i in 0...thisSource.count-1{
            
            let icon = ImgAndLabView.init(frame: CGRect.init(x: toLeft+(i%count)*(W+betw), y: Int(lcBannerView.bottom_sd) + toTop + (i/count)*(H+toTop), width: W, height: H))
            
            
            var imageDef = ImageDefault.imagePlace
            let sourcemodel = thisSource[i]
            
            if (sourcemodel.img_go == "0"){
                imageDef = "firsticon_1"
            }else if(sourcemodel.img_go == "1"){
                imageDef = "firsticon_2"
            }
            else if(sourcemodel.img_go == "3"){
                imageDef = "firsticon_4"
            }
            
            icon.ImgView.sd_setImage(with: URL.init(string: NSString.formatImageUrl(with: sourcemodel.img_url, ifThumb: false, thumb_W: 0)), placeholderImage: UIImage.init(named: imageDef), options: .retryFailed)
            
            icon.titleLab.text = sourcemodel.img_title
            
            icon.ImgView.left_sd = 0
            icon.ImgView.top_sd = 0
            icon.ImgView.width_sd = CGFloat(imgW)
            icon.ImgView.height_sd = CGFloat(imgW)
            icon.ImgView.centerX_sd = CGFloat(W/2)
            
            icon.titleLab.font = UIFont.systemFont(ofSize: 15)
            icon.titleLab.top_sd = icon.ImgView.bottom_sd+5
            icon.titleLab.sizeToFit()
            icon.titleLab.centerX_sd = icon.ImgView.centerX_sd
            
            headerView.addSubview(icon)
            icon.btn.handleEventTouchUpInside(callback: {[weak self] in
                //0 同宗活动列表  1 寄思先祖 2 同宗公益 3 企业秀
                if (sourcemodel.img_go == "0"){
                    let activity = ClubActivity.init()
                    activity.hidesBottomBarWhenPushed = true
                    self?.navigationController?.pushViewController(activity, animated: true)
                }else if (sourcemodel.img_go == "1"){
                    let ancestors = Ancestors.init()
                    ancestors.hidesBottomBarWhenPushed = true
                    self?.navigationController?.pushViewController(ancestors, animated: true)
                }else if (sourcemodel.img_go == "2"){
                    //                    let activity = clubActivity.init()
                    //                    activity.hidesBottomBarWhenPushed = true
                    //                    self.navigationController?.pushViewController(activity, animated: true)
                }else if (sourcemodel.img_go == "3"){
                    let company = Company.init()
                    company.hidesBottomBarWhenPushed = true
                    self?.navigationController?.pushViewController(company, animated: true)
                }
            })
            
            
            if i==0{
                headerView.height_sd = icon.bottom_sd+F_I6(place: 14)
                tableView.tableHeaderView = headerView
            }
        }
    }
    
    func gotoNoticeVC() {
        
    }
    
    //MARK: - tableView
    override func maketableView(){
        
        super.maketableView()
        
        tableView.height_sd = KScreenHeight-KTopHeight-KBottomHeight
        tableView.dataSource=self
        
        let mjheader = MJRefreshGifHeader.init {[weak self] in
            self?.pno=1;
            self?.requestforList()
            if (self?.bannerArr.count == 0){
                self?.setBannerData()
            }
            if (self?.thisSource.count == 0){
                self?.setIconData()
            }
        }
        GlobalClass.setMjHeader(mjheader: mjheader!)
        tableView.mj_header = mjheader
        
        
        self.pno=1;
        if (self.bannerArr.count == 0){
            self.setBannerData()
        }
        if (self.thisSource.count == 0){
            self.setIconData()
        }
        
        emptyView.top_sd = 20
        emptyView.describeLabel?.text = "暂无动态，赶快去发布吧！"
        emptyView.picName = ImageDefault.emptyPlace2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dynamicArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? dongtaiCell
        if (!(cell != nil)){
            cell = dongtaiCell.init(style: .default, reuseIdentifier: "cell")
        }
        cell?.model = dynamicArr[indexPath.row]
        cell?.row = indexPath.row
        
        //        DispatchQueue.main.async {
        //            for view in (cell?.contentView.subviews)! {
        //                if (view is XLVideoPlayer ) {
        //                    let player = view as! XLVideoPlayer
        //                    player.destroyPlayer()
        //                }
        //            }
        //        }
        
        //        cell?.playBtn.handleEventTouchUpInside(callback: {
        //            self.lastOrCurrentPlayIndex = indexPath.row;
        //            //点击cell的播放按钮播放
        //            self.cellPlay(cell: cell!)
        //        })
        
        let gestap = UITapGestureRecognizer.bk_recognizer {[weak self] (_, _, _) in
            if cell?.model?.username == UserServre.shareService.userModel.username{
                let vc = MyInfoVC.init()
                self?.navigationController?.pushViewController(vc, animated: true)
            }else{
                let vc = StrangerOrFriendVC.init()
                vc.username = cell?.model?.username
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        cell?.header.isUserInteractionEnabled = true
        cell?.header.addGestureRecognizer(gestap as! UIGestureRecognizer)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = dynamicArr[indexPath.row]
        if model.cellHei ?? 0 > 0 {
            return dynamicArr[indexPath.row].cellHei
        }
        return dongtaiCell.getCellHeigh(model: dynamicArr[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = UIColor.bgColor5
        if (section==0){
            let whiteView = UIView.init(frame: CGRect.init(x: 0, y: F_I6(place: 5), width: KScreenWidth, height: F_I6(place: 50)))
            whiteView.backgroundColor = UIColor.white
            view.addSubview(whiteView)
            
            let lab = UILabel.init(frame: CGRect.init(x: 12, y: 0, width: 200, height: whiteView.height_sd))
            lab.font = UIFont.boldSystemFont(ofSize: 20)
            lab.textColor = UIColor.textColor1
            lab.text = "同宗动态"
            whiteView.addSubview(lab)
            
//            设置字间距
//            let attributedString = NSMutableAttributedString.init(string: "同宗动态", attributes: [NSKernAttributeName : 4])
//            lab.attributedText = attributedString
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return F_I6(place: 56)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let infoVC = DynamicInfo.init()
        infoVC.model = dynamicArr[indexPath.row]
        infoVC.lastVC2 = self
        self.navigationController?.pushViewController(infoVC, animated: true)
    }
    
    // MARK: - Https网络请求
    func requestForResource(){
        ClanAPI.requestForgetResource {[weak self] (result) in
            
            if result.status == "200"{
                //资源存储
                PLGlobalClass.write(toFile: CUKey.kSourceSave, withKey: CUKey.kSourceSave, value: result.data)
                //资源版本号存储
                PLGlobalClass.write(toFile: CUKey.kSourceSave, withKey: CUKey.kCurrentSourceVersion, value: result.version)
                
                if ((result.data != nil) && (result.data is Dictionary<String,Any>)){
                    let dic = result.data as! Dictionary<String,Any>
                    self?.thisSource = sourceModel.mj_objectArray(withKeyValuesArray: dic["list"]) as! [sourceModel]
                    DispatchQueue.main.async {
                        self?.reloadIcon()
                    }
                }
            }
        }
    }
    
    override func requestforList(){
        ClanAPI.requestForDynamicList(pagenum: pno, pagesize: pnu) { [weak self] (result) in
            
            if self != nil{
                self?.hiddenGifView()
                self?.tableView.mj_header.endRefreshing()
                self?.tableView.mj_footer.endRefreshing()
                
                if (result.status == "200"){
                    if ((result.data != nil) && (result.data is Dictionary<String,Any>)){
                        let dic = result.data as! Dictionary<String,Any>
                        
                        let resArr = DynamicModel.mj_objectArray(withKeyValuesArray: dic["list"]) as! [DynamicModel]
                        
                        if (resArr.count) < (self?.pnu)! {
                            self?.tableView.mj_footer.isHidden = true
                        }else{
                            self?.tableView.mj_footer.isHidden = false
                        }
                        if ((resArr.count) > 0){
                            if( (self?.pno)! > 1){
                                self?.dynamicArr = (self?.dynamicArr)! + resArr
                            }else{
                                self?.dynamicArr = resArr
                                let array = dic["list"] as? NSArray
                                if (self?.dynamicArr.count ?? 0) > 0{
                                    KFileManager.cacheDefineFile(with: array?.mj_JSONString(), fileName: CUKey.catch_Dynatimic)
                                }
                            }
                        }else{
                            if ((self?.pno)! > 1){
                                self?.pno = (self?.pno)! - 1
                            }
                        }
                        if self?.dynamicArr.count == 0{
                            self?.tableView.mj_footer.isHidden = true
                        }else{
                            self?.tableView.separatorStyle = .singleLine
                        }
                    }
                }else{
                    if ( (self?.pno)! > 1){
                        self?.pno = (self?.pno)! - 1
                        self?.tableView.separatorStyle = .singleLine
                    }
                }
                self?.checkIfNull()
               
            }
        }
    }
    
    func checkIfNull(){
        
        if self.dynamicArr.count == 0{
            let jsonString = KFileManager.cacheText(withFileName: CUKey.catch_Dynatimic) as NSString?
            let jsonArray = jsonString?.mj_JSONObject()
            let resArr = DynamicModel.mj_objectArray(withKeyValuesArray: jsonArray) as? [DynamicModel]
            
            if resArr == nil || resArr?.count == 0{
                self.emptyShow(show: true)
            }else{
                self.dynamicArr = resArr!
                self.emptyShow(show: false)
                self.tableView.mj_footer.isHidden = false
            }
        }else{
            self.emptyShow(show: false)
        }
        self.tableView.reloadData()
        
    }
    
    override func emptyShow(show:Bool){
        if show{
            if APPDELEGATE.networkStatus == 0 {
                emptyView.describeLabel?.text = "请检查您的网络"
            }else{
                emptyView.describeLabel?.text = "暂无动态，赶快去发布吧！"
            }
            footerview.height_sd = 280
        }else{
            footerview.height_sd = 0
        }
    }
    
    // MARK: - 功能
    func cellPlay(cell : dongtaiCell){
        
        if(cell.model?.attachpath.count == 0){
            WFHudView.showMsg("视频找不到了哦\n 看看其他吧", in: self.view)
            return;
        }
        
        let path = NSIndexPath.init(row: cell.row, section: 0)
        self.playerDestroy()
        
        player = XLVideoPlayer.init()
        
        player?.completedPlayingBlock = { (player) -> () in
            self.playerDestroy()
        }
        
        player?.videoUrl = NSURL.init(string:  NSString.formatImageUrl(with: cell.model?.attachpath, ifThumb: false, thumb_W: 0))! as URL
        player?.playerBindTableView(self.tableView, currentIndexPath: path as IndexPath!)
        player?.frame = cell.image1.bounds
        player?.player.play()
        
        //在cell上加载播放器
        cell.contentView.addSubview(player!)
        
        player?.left_sd = cell.image1.left_sd;
        player?.top_sd = cell.image1.top_sd;
        
        self.lastOrCurrentPlayIndex = cell.row;
        self.lastPlayCell = cell.row;
    }
    
    func playerDestroy() {
        if (player != nil){
            player?.destroyPlayer()
            player = nil
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset;
        if (!(player != nil)) {
            return;
        }
        
        let path = NSIndexPath.init(row: self.lastPlayCell, section: 0)
        let rectInTableView = self.tableView.rectForRow(at:path as IndexPath)
        let rect = self.tableView.convert(rectInTableView, to: self.tableView.superview)
        if (rect.origin.y < -(rect.size.height*0.3)||rect.origin.y > (self.tableView.height_sd-(rect.size.height*0.3))) {
            self.playerDestroy()
        }
    }
    
    
    
    //TODO:寄思先祖弹窗
    func alter() {
        
        var dic = PLGlobalClass.getValueFromFile(CUKey.kAncestor, withKey: UserServre.shareService.userModel.username) as? Dictionary<String, Any>
        
        let altertime = dic?[CUKey.kAncestor_altertime]
        if (altertime is Date && PLGlobalClass.ifToday(altertime as! Date)){
            return
        }
        
        let time = dic?[CUKey.kAncestor_time]
        if (time is Date && PLGlobalClass.ifToday(time as! Date)){
        }else{
            animation.type = LewPopupViewAnimationSlideType.topTop
            
            if self.ancestorAlterV == nil{
                ancestorAlterV = BounceAlter.init(frame:CGRect.init(x: 0, y: F_I6(place: 116), width: F_I6(place: 263), height:F_I6(place: 326)), parentVC: self, dismiss: self.animation)
                ancestorAlterV?.btnClickBlock = {() -> () in
                    let ancestors = Ancestors.init()
                    ancestors.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(ancestors, animated: true)
                }
            }
            
            if dic == nil{
                dic = [CUKey.kAncestor_altertime:Date()]
            }else{
                dic![CUKey.kAncestor_altertime] = Date()
            }
            
            PLGlobalClass.write(toFile: CUKey.kAncestor, withKey: UserServre.shareService.userModel.username, value: dic)
            self.lew_presentPopupView(self.ancestorAlterV, animation: self.animation, backgroundClickable: true)
        }
    }
    
    //TODO:版本更新弹窗
    func versionAlter() {
        let altertime = PLGlobalClass.getValueFromFile(CUKey.kStartupInfo, withKey: CUKey.kStartupInfo_versionAlterTime)
        if (altertime is Date && PLGlobalClass.ifToday(altertime as! Date)){
            return
        }
        
        let dic = PLGlobalClass.getValueFromFile(CUKey.kStartupInfo, withKey: CUKey.kStartupInfo) as? Dictionary<String, Any>
        if dic == nil{
            return
        }else{
            let version = dic!["version"] as? String
            if version == DeviceConfig.appVersion{
            }else{
                self.setAlter()
                self.alterV.infoLab.text = "发现新版本" + (version ?? "")
                self.lew_presentPopupView(self.alterV, animation: self.animation, backgroundClickable: true)
                PLGlobalClass.write(toFile: CUKey.kStartupInfo, withKey: CUKey.kStartupInfo_versionAlterTime, value: Date())
            }
        }
    }
    
    //版本更新弹窗设置
    func setAlter(){
        alterV.btn.setTitle("更新", for: .normal)
        alterV.btncancle.setTitle("下次再说", for: .normal)
        
        alterV.btnClickBlock  = {
            let str = "http://itunes.apple.com/app/id1340881105"
            UIApplication.shared.openURL(URL.init(string: str)!)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


//MARK: - ----------------资源model
class imgModel: KBaseModel {
    
    var dynamicid : String = ""  //动态id
    var imgpath : String = ""   //
    var id : String = "" //
}

//MARK: - ----------------资源文件model
class sourceModel: KBaseModel {
    
    var img_type : String = ""  //0为整体背景，1为首页，2为我的页面
    var img_app : String = ""   //:1为安卓，2为IOS,3为其他
    var img_version : String = "" //图片版本
    var img_url : String = "" //图片地址
    var created : String = ""
    var img_go : String = ""  //图片跳转地址，为APP内的跳转
    var ordernum : String = "" //手机号
    var id : String = "" //id
    var img_title : String = "" //图片标题
}

//MARK: - ----------------广告位model
class adBannerModel: KBaseModel {
    
    var type = 0; //0内链  1外链
    var imgurl : String = ""  //图片地址
    var adname : String = ""   //广告标题
    var adconfigid : String = "" //
    var adtext : String = "" //
    var created : String = ""
    var updated : String = ""  //图片跳转地址，为APP内的跳转
    var url : String = "" //跳转地址
    var id : String = "" //id
    var status : String = "" //图片标题
}

