import UIKit
import MJRefresh

//MARK: - ----------------用户信息页
class PersonalVC: BaseTabVC,UITableViewDataSource {
    
    //传值 model
    var userid :  String?
    var username :  String?
    var user :  UserModel?
    
    //UI
    var header =  PersonalHeaderView()
    var sectionView : UIView?
    
    //播放相关
    var lastOrCurrentPlayIndex = 0
    var lastPlayCell = 0
    var player : XLVideoPlayer?
    var lastContentOffset = CGPoint()
    
    //收藏与动态区分
    var collectBtn = UIButton()
    var dynaBtn = UIButton()
    var collectArr = NSMutableArray.init(capacity: 0) //收藏Arr
    var dynaArr = NSMutableArray.init(capacity: 0) //动态Arr
    var dataArray = NSMutableArray.init(capacity: 0) //表数据Arr
    
    var collectPno = 1
    var dynaPno = 1
    var baseview = UIView()
    
    var collectDele : DynamicModel?
    
    //MARK: - 懒加载
    override lazy var emptyView: EmptySwiftView = {
        let tempView = EmptySwiftView.showEmptyView(emptyPicName: "empty_collect", describe: "君暂无内容，赶快发布吧！")
        tempView.centerX_sd = KScreenWidth/2.0
        return tempView
    }()
    
    
    //MARK: - VC - 页面
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if ClanServer.token != "0"{
            self.requestForUserInfo()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.collectDele == nil{
            
        }else{
            self.dataArray.remove(self.collectDele!)
            self.checkIfNull()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUser()
        self.view.backgroundColor = UIColor.white
        header = PersonalHeaderView.init(frame: CGRect.init(x: 0, y: KTopHeight, width: KScreenWidth, height: PersonalHeaderView.getViewHeigh()))
        
        tableView.tableHeaderView = header
        self.knavigationBar?.cutlineColor = UIColor.clear
        self.knavigationBar?.title = ""
    }
    
    //MARK: - tableView
    override func maketableView(){
        
        baseview = UIView.init(frame: CGRect.init(x: 0, y: KTopHeight, width: KScreenWidth, height: F_I6(place: 148)))
        baseview.backgroundColor = UIColor.baseColor
        self.view.addSubview(baseview)
        
        self.tableView = UITableView.init(frame: CGRect.init(x: 0, y: KTopHeight, width: KScreenWidth, height: KScreenHeight - KTopHeight), style: UITableViewStyle.plain)
        tableView.backgroundColor = UIColor.clear
        self.settableView()
        
        self.tableView.dataSource=self
        let mjheader = MJRefreshGifHeader.init { [weak self] in
            if (self?.collectBtn.isSelected)!{
                self?.collectPno=1;
            }else{
                self?.dynaPno=1;
            }
            self?.requestforList()
        }
        GlobalClass.setMjHeader(mjheader: mjheader!)
        tableView.mj_header = mjheader
        self.tableView.mj_footer = MJRefreshAutoNormalFooter{ [weak self] in
            if (self?.collectBtn.isSelected)!{
                self?.collectPno = (self?.collectPno)! + 1;
            }else{
                self?.dynaPno = (self?.dynaPno)! + 1;
            }
            self?.requestforList()
        }
        tableView.mj_footer.isHidden = true

        
        if self.isKind(of: StrangerOrFriendVC.classForCoder()){
            self.requestforList()
        }
    }
    
    //MARK: - tableView
    override func settableView(){
        self.tableView.delegate=self
        self.view.addSubview(self.tableView)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorColor = UIColor.cutLineColor
        tableView.separatorInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        
        /// 自动关闭估算高度，不想估算那个，就设置那个即可
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        
        footerview = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 0))
        footerview.addSubview(emptyView)
        emptyView.top_sd = 40
        footerview.clipsToBounds = true
        tableView.tableFooterView = footerview
    }
    
    func makeSectionView(){
        sectionView = UIView.init()
        sectionView?.backgroundColor = UIColor.white
        
        collectBtn = UIButton.init(frame: CGRect.init(x: 0  , y: 0, width: KScreenWidth/2, height: 44))
        collectBtn.setTitle("我的收藏", for: .normal)
        collectBtn.setTitleColor(UIColor.textColor1, for: .normal)
        collectBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        sectionView?.addSubview(collectBtn)
        
        dynaBtn = UIButton.init(frame: CGRect.init(x: KScreenWidth/2  , y: 0, width: KScreenWidth/2, height: 44))
        dynaBtn.setTitle("我的动态", for: .normal)
        dynaBtn.setTitleColor(UIColor.textColor1, for: .normal)
        dynaBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        sectionView?.addSubview(dynaBtn)
        
        let line2 = UIView.init(frame: CGRect.init(x: 0, y: 44-0.5, width: KScreenWidth, height: 0.5))
        line2.backgroundColor = UIColor.cutLineColor
        sectionView?.addSubview(line2)
        
        let line = UIView.init(frame: CGRect.init(x: 0  , y:44-2 , width: KScreenWidth/2, height: 2))
        line.backgroundColor = UIColor.baseColor
        sectionView?.addSubview(line)
        
        collectBtn.isSelected = true
        
        collectBtn.handleEventTouchUpInside(callback: { [weak self] in
            if (self?.collectBtn.isSelected)! == true{
            }else{
                self?.emptyShow(show: false)
                
                self?.playerDestroy()
                self?.collectBtn.isSelected = true
                self?.dynaBtn.isSelected = false
                
                if self?.collectArr.count == 0{
                    self?.showGifView()
                    self?.requestforList()
                }else{
                    self?.dataArray = (self?.collectArr)!
                    self?.checkIfNull()
                }
                UIView.animate(withDuration: 0.3, animations: {
                    line.left_sd = 0
                })
            }
        })
        
        dynaBtn.handleEventTouchUpInside(callback: { [weak self] in
            if (self?.dynaBtn.isSelected)! == true{
                
            }else{
                self?.emptyShow(show: false)
                
                self?.dynaBtn.isSelected = true
                self?.collectBtn.isSelected = false
                
                if self?.dynaArr.count == 0{
                    self?.showGifView()
                    self?.requestforList()
                }else{
                    self?.dataArray = (self?.dynaArr)!
                    self?.checkIfNull()
                }
                
                UIView.animate(withDuration: 0.3, animations: {
                    line.left_sd = KScreenWidth/2
                })
            }
        })
        
        self.requestforList()
    }
    
    func setUser(){
        user = UserServre.shareService.userModel
        username = UserServre.shareService.userModel.username
    }
    
    func reloadHeaderView(){
        
        header.headerImageV.sd_setImage(with: URL.init(string: NSString.formatImageUrl(with: user?.headimg, ifThumb: true, thumb_W: 0)), placeholderImage: UIImage.init(named: ImageDefault.headerPlace), options: .retryFailed)
        header.text1.text = user?.nickname ?? ""
        header.text2.text = user?.job ?? ""
    }
    
    
    override func kNotifiLoginSuccess() {
        self.collectArr.removeAllObjects()
        self.dynaArr.removeAllObjects()
        self.tableView.reloadData()
        
        self.tableView.mj_header.beginRefreshing()
        user = UserServre.shareService.userModel
        username = UserServre.shareService.userModel.username
    }
    
    
    //MARK:空页面展示
    func checkIfNull(){
        self.tableView.reloadData()
        if self.dataArray.count == 0{
            self.emptyShow(show: true)
        }else{
            self.emptyShow(show: false)
        }
        if (self.dataArray.count) < (self.pnu){
            self.tableView.mj_footer.isHidden = true
        }else if (self.dataArray.count) % (self.pnu) == 0{
            self.tableView.mj_footer.isHidden = false
        }else{
            self.tableView.mj_footer.isHidden = true
        }
    }
    
    override func emptyShow(show:Bool){
        if show{
            
            if APPDELEGATE.networkStatus == 0{
                emptyView.describeLabel?.text = "请检查您的网络"
            }else{
                if collectBtn.isSelected{
                    emptyView.describeLabel?.text = "君暂无收藏"
                }else{
                    emptyView.describeLabel?.text = "暂无动态，赶快去发布吧！"
                }
            }
            if collectBtn.isSelected{
                emptyView.picName = "empty_collect"
            }else{
                emptyView.picName = ImageDefault.emptyPlace2
            }
            footerview.height_sd = KScreenHeight - KTopHeight - KStatusBarHeight - 44 - header.height_sd
        }else{
            footerview.height_sd = 0
        }
        
        emptyView.centerY_sd = footerview.height_sd/2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if collectBtn.isSelected{
            var cell = tableView.dequeueReusableCell(withIdentifier: "collcell") as? dongtaiCell
            if (!(cell != nil)){
                cell = dongtaiCell.init(style: .default, reuseIdentifier: "collcell")
                
                cell?.image2.removeFromSuperview()
                cell?.image3.removeFromSuperview()
                cell?.gender.removeFromSuperview()
                //                cell?.talkBtn.removeFromSuperview()
                //                cell?.likeBtn.removeFromSuperview()
                cell?.header.removeFromSuperview()
                cell?.name.font = UIFont.systemFont(ofSize: 15)
                cell?.name.textColor = UIColor.baseColor
                cell?.time.textColor = UIColor.textColor2
                cell?.time.font = cell?.name.font
            }
            cell?.collModel = dataArray[indexPath.row] as? DynamicModel
            return cell!
        }else{
            
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? dongtaiCell
            if (!(cell != nil)){
                cell = dongtaiCell.init(style: .default, reuseIdentifier: "cell")
            }
            cell?.model = dataArray[indexPath.row] as? DynamicModel
            cell?.row = indexPath.row
            //            DispatchQueue.main.async {
            //                for view in (cell?.contentView.subviews)! {
            //                    if (view is XLVideoPlayer ) {
            //                        let player = view as! XLVideoPlayer
            //                        player.destroyPlayer()
            //                    }
            //                }
            //            }
            
            //            cell?.playBtn.handleEventTouchUpInside(callback: { [weak self , weak cell] in
            //                self?.lastOrCurrentPlayIndex = indexPath.row;
            //                //点击cell的播放按钮播放
            //                self?.cellPlay(cell: cell!)
            //            })
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if collectBtn.isSelected{
            return dongtaiCell.getCellHeigh(collmodel: dataArray[indexPath.row] as! DynamicModel)
        }else{
            return dongtaiCell.getCellHeigh(model: dataArray[indexPath.row] as! DynamicModel)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if sectionView == nil{
            self.makeSectionView()
        }
        return sectionView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if collectBtn.isSelected{
            
            let model = dataArray[indexPath.row] as? DynamicModel
            
            if model?.targetstatus == 0{
                WFHudView.showMsg("该动态已删除", in: self.view)
            }else{
                let infoVC = DynamicInfo.init()
                infoVC.model =  model
                infoVC.model?.id = (infoVC.model?.targetid)!
                infoVC.model?.collect = "1"
                infoVC.ifCollect = true
                infoVC.lastVC = self
                self.navigationController?.pushViewController(infoVC, animated: true)
            }
        }else{
            let infoVC = DynamicInfo.init()
            infoVC.model = dataArray[indexPath.row] as? DynamicModel
            self.navigationController?.pushViewController(infoVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            //删除
            if collectBtn.isSelected{
                self.deleCollect(model: self.dataArray[indexPath.row] as! DynamicModel)
            }else{
                self.deleMyDynamic(model: self.dataArray[indexPath.row] as! DynamicModel)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    //TODO:滑动停止播放 滑动改变title
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y >= header.text2.bottom_sd + 5{
            self.knavigationBar?.title = user?.nickname ?? ""
        }else{
            self.knavigationBar?.title = ""
        }
        
        if scrollView.contentOffset.y < 0{
            baseview.height_sd = -scrollView.contentOffset.y
        }else{
            baseview.height_sd = 0
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
    
    
    //MARK: - 网络请求
    //TODO:请求用户信息
    func requestForUserInfo(){
        if username == nil || username?.count == 0{
            WFHudView.showMsg("参数缺失", in: self.view)
            
            //延时执行-Swift
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        ClanAPI.requestForAccount(username:username ?? "") { [weak self] (result) in
            if result.status == "200"{
                let usermodel = UserModel.mj_object(withKeyValues: result.data)
                if self?.user == nil{
                    self?.user = usermodel
                }else{
                    self?.user?.headimg = (usermodel?.headimg)!
                    self?.user?.gender = (usermodel?.gender)!
                    self?.user?.job = (usermodel?.job)!
                    self?.user?.birthday = (usermodel?.birthday)!
                    self?.user?.speciality = (usermodel?.speciality)!
                    self?.user?.interest = (usermodel?.interest)!
                    self?.user?.registerString = (usermodel?.registerString)!
                    self?.user?.nickname = (usermodel?.nickname)!
                    self?.user?.realname = (usermodel?.realname)!
                }
            }else{
                //                WFHudView.showMsg("获取用户信息失败", in: self?.view)
            }
            self?.reloadHeaderView()
        }
    }
    
    //TODO:请求列表
    override func requestforList(){
        
        if collectBtn.isSelected{
            dataArray = collectArr
            self.requestforCollect()
        }else{
            dataArray = dynaArr
            self.requestforDyna()
        }
    }
    
    //TODO:获取我的收藏
    func requestforCollect(){
        print("请求收藏")
        ClanAPI.requestForCollect(pagenum: collectPno, pagesize: pnu) {[weak self] (result) in
            
            if self != nil{
            
                self?.hiddenGifView()
                self?.tableView.mj_header.endRefreshing()
                self?.tableView.mj_footer.endRefreshing()
                
                if (result.status == "200"){
                    if ((result.data != nil) && (result.data is Dictionary<String,Any>)){
                        let dic = result.data as! Dictionary<String,Any>
                        
                        let resArr = DynamicModel.mj_objectArray(withKeyValuesArray: dic["list"]) as! [DynamicModel]
                        
                        if ((resArr.count) < (self?.pnu)!) {
                            self?.tableView.mj_footer.isHidden = true
                        }else{
                            self?.tableView.mj_footer.isHidden = false
                        }
                        if ((resArr.count) > 0){
                            if( (self?.collectPno)! > 1){
                            }else{
                                self?.dataArray.removeAllObjects()
                            }
                            self?.dataArray.addObjects(from: resArr)
                        }else{

                            if ( (self?.collectPno)! > 1){
                                self?.collectPno = (self?.collectPno)! - 1
                            }else{
                                self?.dataArray.removeAllObjects()
                            }
                        }
                    }else{
                        if self?.collectPno == 1 || (self?.dataArray.count == 1){
                            self?.dataArray.removeAllObjects()
                            self?.tableView.mj_footer.isHidden = true
                        }
                    }
                }else{
                    if self?.collectPno == 1 || (self?.dataArray.count == 1){
                        self?.dataArray.removeAllObjects()
                        self?.tableView.mj_footer.isHidden = true
                    }
                }
                self?.checkIfNull()
            }
        }
    }
    
    //TODO:获取我的动态
    func requestforDyna(){
        print("请求动态")
        ClanAPI.requestForuserDynamic(username: username ?? "", pagenum: dynaPno, pagesize: pnu){[weak self] (result) in
            
            if self != nil{
                self?.hiddenGifView()
                self?.tableView.mj_header.endRefreshing()
                self?.tableView.mj_footer.endRefreshing()
                
                if (result.status == "200"){
                    if ((result.data != nil) && (result.data is Dictionary<String,Any>)){
                        let dic = result.data as! Dictionary<String,Any>
                        
                        let resArr = DynamicModel.mj_objectArray(withKeyValuesArray: dic["list"]) as! [DynamicModel]
                        
                        if ((resArr.count) < (self?.pnu)!) {
                            self?.tableView.mj_footer.isHidden = true
                        }else{
                            self?.tableView.mj_footer.isHidden = false
                        }
                        if ((resArr.count) > 0){
                            if( (self?.dynaPno)! > 1){
                            }else{
                                self?.dataArray.removeAllObjects()
                            }
                            self?.dataArray.addObjects(from: resArr)
                            
                        }else{
                            if ( (self?.dynaPno)! > 1){
                                self?.dynaPno = (self?.dynaPno)! - 1
                            }
                        }
                    }else{
                        if self?.dynaPno == 1 || (self?.dataArray.count == 1){
                            self?.dataArray.removeAllObjects()
                            self?.tableView.mj_footer.isHidden = true
                        }
                    }
                    
                }else{
                    if self?.dynaPno == 1 || (self?.dataArray.count == 1){
                        self?.dataArray.removeAllObjects()
                    }
                    if self?.dataArray.count == 0{
                        self?.tableView.mj_footer.isHidden = true
                    }
                }
                
                self?.checkIfNull()
            }
        }
    }
    
    //TODO:取消收藏
    func deleCollect(model: DynamicModel){
        ClanAPI.requestForCancelcollect(targetid: model.targetid, targettype: "2") { [weak self] (result) in
            if result.status == "200"{
                self?.dataArray.remove(model)
                self?.checkIfNull()
                WFHudView.showMsg("取消收藏", in: self?.view)
            }else{
                print("取消收藏失败")
            }
        }
    }
    
    //TODO:删除动态
    func deleMyDynamic(model: DynamicModel){
        
        ClanAPI.requestForCancelDynamic(id: model.id) {[weak self] (result) in
            if result.status == "200"{
                self?.dataArray.remove(model)
                self?.checkIfNull()
                WFHudView.showMsg("删除成功", in: self?.view)
            }else{
                print("删除失败")
            }
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
        
        player?.completedPlayingBlock = {[weak self] (player) -> () in
            self?.playerDestroy()
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
}


//MARK: - ----------------个人资料
class UserInfoVC: KBaseClanViewController {
    
    var ifEdit =  false
    var hasEdit =  false

    var header = IconAndInput()
    var name = TitleAndTextField()
    var gender = TitleAndTextField()
    var birthday = TitleAndTextField()
    var job = TitleAndTextField()
    var registered  = TitleAndTextField()
    var specialty = TitleAndTextField()
    var interest = TitleAndTextField()
    
    var manBtn = UIButton()
    var womanBtn = UIButton()
    
    var rightImgBtn : KButton?
    var hasCoverImage = false
    var hasChangeBirth = false
    
    var user :  UserModel?
    /// 弹窗
    var animation : LewPopupViewAnimationSlide?
    var alterV : msgAlterView?
    
    lazy var pickerbg: UIView = {
        let tempView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight))
        tempView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
        return tempView
    }()
    lazy var picker: UIDatePicker = {
        let temppicker = UIDatePicker.init(frame: CGRect.init(x: (KScreenWidth-F_I6(place: 290))/2, y: F_I6(place: 170), width: F_I6(place: 290), height: F_I6(place: 270)))
        temppicker.backgroundColor = UIColor.white
        temppicker.maximumDate = NSDate() as Date
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
        if ifEdit == true && hasEdit == true{
            
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
            
        }else{
            super.kBackBtnAction()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        PLGlobalClass.setIQKeyboardToolBarEnable(true, distanceFromTextField: F_I6(place: 50))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        PLGlobalClass.setIQKeyboardToolBarEnable(false, distanceFromTextField: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.knavigationBar?.cutlineColor = UIColor.clear
        self.knavigationBar?.title = "个人资料"
        
        self.createSubView()
    }
    
    func createSubView(){
        let scrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: KTopHeight, width: KScreenWidth, height: KScreenHeight - KTopHeight))
        self.view.addSubview(scrollView)
        
        header = IconAndInput.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: F_I6(place: 84)))
        header.inputV.text = "头像"
        header.inputV.left_sd = 12
        header.inputV.width_sd = F_I6(place: 200)
        header.iconImageView.height_sd = F_I6(place: 45)
        header.iconImageView.width_sd = F_I6(place: 45)
        header.iconImageView.layer.cornerRadius = F_I6(place: 45)/2
        header.iconImageView.clipsToBounds = true
        header.iconImageView.right_sd = KScreenWidth-12
        header.iconImageView.centerY_sd = header.height_sd/2
        header.inputV.isUserInteractionEnabled = false
        scrollView.addSubview(header)
        
        rightImgBtn = KButton.init(frame: header.iconImageView.frame, needMengban: false)
        rightImgBtn?.handleEventTouchUpInside(callback: {
            PLGlobalClass.uploadphotosIfAllowsEditing(true, alsoShowVideo: false)
        })
        rightImgBtn?.layer.cornerRadius = (rightImgBtn?.width_sd)!/2
        rightImgBtn?.clipsToBounds = true
        rightImgBtn?.layer.borderWidth = 0.5
        rightImgBtn?.layer.borderColor = UIColor.cutLineColor.cgColor
        header.addSubview(rightImgBtn!)
        
        let club = TitleAndTextField.init(frame: CGRect.init(x: 0, y: header.bottom_sd, width: KScreenWidth, height: F_I6(place: 46)))
        club.titleLabel.text = "姓氏"
        club.showLabel.text = UserServre.shareService.userClub?.club
        club.titleLabel.font = UIFont.systemFont(ofSize: 15)
        club.showLabel.font = UIFont.systemFont(ofSize: 14)
        club.titleLabel.textColor = UIColor.textColor1
        club.showLabel.isUserInteractionEnabled = false
        scrollView.addSubview(club)
        
        
        name = TitleAndTextField.init(frame: CGRect.init(x: 0, y: club.bottom_sd, width: KScreenWidth, height: F_I6(place: 46)))
        name.titleLabel.text = "名字"
        name.showLabel.text = "名字"
        name.titleLabel.font = UIFont.systemFont(ofSize: 15)
        name.showLabel.font = UIFont.systemFont(ofSize: 14)
        name.titleLabel.textColor = UIColor.textColor1
        scrollView.addSubview(name)
        
        gender = TitleAndTextField.init(frame: CGRect.init(x: 0, y: name.bottom_sd, width: KScreenWidth, height: F_I6(place: 46)))
        gender.titleLabel.text = "性别"
        gender.showLabel.text = ""
        gender.showLabel.isUserInteractionEnabled = false
        gender.titleLabel.font = UIFont.systemFont(ofSize: 15)
        gender.showLabel.font = UIFont.systemFont(ofSize: 14)
        gender.titleLabel.textColor = UIColor.textColor1
        scrollView.addSubview(gender)
        
        manBtn = UIButton.init(frame: CGRect.init(x: KScreenWidth - F_I6(place: 130), y: 0, width: F_I6(place: 50), height: gender.height_sd))
        manBtn.setImage(UIImage.init(named: "noselected_big"), for: UIControlState.normal)
        manBtn.setImage(UIImage.init(named: "selected_big"), for: UIControlState.selected)
        manBtn.setTitleColor(UIColor.textColor2, for: UIControlState.normal)
        manBtn.setTitle("男", for: UIControlState.normal)
        manBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        manBtn.isSelected = true
        gender.addSubview(manBtn)
        PLGlobalClass.setBtnStyle(manBtn, style: ButtonEdgeInsetsStyleReferToImage.imageLeft, space: 5)
        
        
        womanBtn = UIButton.init(frame: CGRect.init(x: KScreenWidth - F_I6(place: 60), y: 0, width: manBtn.width_sd, height: manBtn.height_sd))
        womanBtn.setImage(UIImage.init(named: "noselected_big"), for: UIControlState.normal)
        womanBtn.setImage(UIImage.init(named: "selected_big"), for: UIControlState.selected)
        womanBtn.setTitleColor(UIColor.textColor2, for: UIControlState.normal)
        womanBtn.setTitle("女", for: UIControlState.normal)
        womanBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        gender.addSubview(womanBtn)
        PLGlobalClass.setBtnStyle(womanBtn, style: ButtonEdgeInsetsStyleReferToImage.imageLeft, space: 5)
        womanBtn.handleEventTouchUpInside {[weak self] in
            if self?.womanBtn.isSelected == true{
            }else{
                self?.hasEdit = true
                self?.womanBtn.isSelected = true
                self?.manBtn.isSelected = false
            }
        }
        
        manBtn.handleEventTouchUpInside {[weak self] in
            if self?.manBtn.isSelected == true{
            }else{
                self?.hasEdit = true
                self?.manBtn.isSelected = true
                self?.womanBtn.isSelected = false
            }
        }
        
        birthday = TitleAndTextField.init(frame: CGRect.init(x: 0, y: gender.bottom_sd, width: KScreenWidth, height: F_I6(place: 46)))
        birthday.titleLabel.text = "生日"
        birthday.showLabel.text = "9/9"
        birthday.showLabel.isUserInteractionEnabled = false
        birthday.titleLabel.font = UIFont.systemFont(ofSize: 15)
        birthday.showLabel.font = UIFont.systemFont(ofSize: 14)
        birthday.titleLabel.textColor = UIColor.textColor1
        scrollView.addSubview(birthday)
        let tap = UITapGestureRecognizer.bk_recognizer {[weak self] (_, _, _) in
            self?.pickerShow()
        }
        birthday.addGestureRecognizer(tap as! UIGestureRecognizer)
        
        
        job = TitleAndTextField.init(frame: CGRect.init(x: 0, y: birthday.bottom_sd, width: KScreenWidth, height: F_I6(place: 46)))
        job.titleLabel.text = "行业"
        job.showLabel.text = "设计师"
        job.titleLabel.font = UIFont.systemFont(ofSize: 15)
        job.showLabel.font = UIFont.systemFont(ofSize: 14)
        job.titleLabel.textColor = UIColor.textColor1
        scrollView.addSubview(job)
        
        registered  = TitleAndTextField.init(frame: CGRect.init(x: 0, y: job.bottom_sd, width: KScreenWidth, height: F_I6(place: 46)))
        registered.titleLabel.text = "户籍"
        registered.showLabel.text = "山西省太原市"
        registered.titleLabel.font = UIFont.systemFont(ofSize: 15)
        registered.showLabel.font = UIFont.systemFont(ofSize: 14)
        registered.titleLabel.textColor = UIColor.textColor1
        scrollView.addSubview(registered)
        
        specialty = TitleAndTextField.init(frame: CGRect.init(x: 0, y: registered.bottom_sd, width: KScreenWidth, height: F_I6(place: 46)))
        specialty.titleLabel.text = "特长"
        specialty.showLabel.text = "唱歌"
        specialty.titleLabel.font = UIFont.systemFont(ofSize: 15)
        specialty.showLabel.font = UIFont.systemFont(ofSize: 14)
        specialty.titleLabel.textColor = UIColor.textColor1
        scrollView.addSubview(specialty)
        
        interest = TitleAndTextField.init(frame: CGRect.init(x: 0, y: specialty.bottom_sd, width: KScreenWidth, height: F_I6(place: 46)))
        interest.titleLabel.text = "兴趣"
        interest.showLabel.text = "跳舞"
        interest.titleLabel.font = UIFont.systemFont(ofSize: 15)
        interest.showLabel.font = UIFont.systemFont(ofSize: 14)
        interest.titleLabel.textColor = UIColor.textColor1
        scrollView.addSubview(interest)
        
        scrollView.contentSize = CGSize.init(width: KScreenWidth, height: interest.bottom_sd + 30)
        
        name.showLabel.isUserInteractionEnabled = ifEdit
        job.showLabel.isUserInteractionEnabled = ifEdit
        registered.showLabel.isUserInteractionEnabled = ifEdit
        specialty.showLabel.isUserInteractionEnabled = ifEdit
        interest.showLabel.isUserInteractionEnabled = ifEdit
        gender.isUserInteractionEnabled = ifEdit
        rightImgBtn?.isUserInteractionEnabled = ifEdit
        birthday.isUserInteractionEnabled = ifEdit
        
        if ifEdit{
            if user?.birthday.count ?? 0 > 0{
                if user?.birthday.count ?? 0  > 10{
                    let index1 = user?.birthday.index((user?.birthday.startIndex)!, offsetBy: 10)
                    birthday.showLabel.text = user?.birthday.substring(to: index1!)
                }else{
                    birthday.showLabel.text = user?.birthday
                }
            }else{
                birthday.showLabel.text = ""
            }
            
            self.knavigationBar?.title = "编辑资料"
            let publicItem = KNaviBarBtnItem.init(frame:  CGRect.init(x: KScreenWidth-44, y: KStatusBarHeight, width: 44, height: 44), title: "完成") { [weak self](sender) in
                self?.requestForUpdateInfo()
            }
            self.knavigationBar?.rightBarBtnItem = publicItem;
            
            birthday.showLabel.placeholder = "请选择你的出生日期"
            job.showLabel.placeholder = "请输入您的行业"
            registered.showLabel.placeholder = "请输入您的户籍"
            specialty.showLabel.placeholder = "请输入您的特长"
            interest.showLabel.placeholder = "请输入您的兴趣"
        }else{
            if user?.birthday.count ?? 0 > 0{
                let date = PLGlobalClass.dateWithtimeStr(user?.birthday)
                let age = PLGlobalClass.age(withDateOfBirth: date)
                birthday.showLabel.text = String(age) + "岁"
            }else{
                birthday.showLabel.text = ""
            }
            self.knavigationBar?.title = "个人资料"
        }
        
        
        name.showLabel.text = user?.realname
        job.showLabel.text = user?.job
        registered.showLabel.text = user?.registerString
        specialty.showLabel.text = user?.speciality
        interest.showLabel.text = user?.interest
        rightImgBtn?.sd_setImage(with: URL.init(string: NSString.formatImageUrl(with: user?.headimg, ifThumb: true, thumb_W: 0)), for: .normal, placeholderImage: UIImage.init(named: ImageDefault.headerPlace), options: .retryFailed)
        
        if user?.gender == "1"{
            manBtn.isSelected = true
            womanBtn.isSelected = false
        }else{
            manBtn.isSelected = false
            womanBtn.isSelected = true
        }
        
        name.showLabel.addTarget(self, action: #selector(setHasEdit), for: .editingChanged)
        job.showLabel.addTarget(self, action: #selector(setHasEdit), for: .editingChanged)
        registered.showLabel.addTarget(self, action: #selector(setHasEdit), for: .editingChanged)
        specialty.showLabel.addTarget(self, action: #selector(setHasEdit), for: .editingChanged)
        interest.showLabel.addTarget(self, action: #selector(setHasEdit), for: .editingChanged)
    }
    
    func setHasEdit(){
        hasEdit = true;
    }
    
    //TODO: 日期选择器
    func pickerShow () {//活动时间 2    3 活动结束时间  4报名截止时间
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
        self.quxiaoBtn.alpha=1;
        self.queding.alpha=1;
        self.view.endEditing(true)
    }
    
    /**日历选择区消失 并改变开始结束时间的值 */
    func pickerHide(btn : UIButton) -> Void { //3 ->4  4->2  2->3
        hasEdit = true
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.3, animations: {[weak self] () in
            self?.picker.alpha=0
            self?.pickerbg.alpha=0
            self?.quxiaoBtn.alpha=0
            self?.queding.alpha=0
        })
        let str = NSString.dateString(with: self.picker.date)
        birthday.showLabel.text = str
        hasChangeBirth = true
    }
    
    //MARK:修改用户信息
    func requestForUpdateInfo(){
        
        if hasEdit == false{
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        var headimg = ""
        var birthStr = ""
        var genderStr = ""
        
        let covermodel = rightImgBtn?.attribute as? uploadfilesModel
        if self.hasCoverImage{
            if covermodel?.path.count ?? 0 > 0{
                headimg = (covermodel?.path)!
            }else{
                WFHudView.showMsg("请等待头像上传完成", in: self.view)
                return
            }
        }
        
        if (hasChangeBirth == true){
            birthStr = NSString.timestamp(with: birthday.showLabel.text)
        }
        
        if manBtn.isSelected == true{
            genderStr = "1"
        }else{
            genderStr = "0"
        }
        
        if (name.showLabel.text?.count ?? 0) == 0{
            WFHudView.showMsg("名字不能为空", in: self.view)
            return
        }
        
        ClanAPI.requestForUpdateAccount(realname: name.showLabel.text!,job: job.showLabel.text!,register: registered.showLabel.text!,speciality: specialty.showLabel.text!,interest: interest.showLabel.text!,gender: genderStr,birthday: birthStr,headimg: headimg){[weak self] (result) in
            if result.status == "200"{
                WFHudView.showMsg("修改成功", in: self?.view)
                self?.navigationController?.popViewController(animated: true)
            }else{
                print("修改失败")
            }
        }
    }
    
    //MARK: - UIImagePickerControllerDelegate选择好图片的回调
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        hasEdit = true
        if (info["UIImagePickerControllerMediaType"] as? String == "public.movie") {
        }else{
            //拿到选择的图片
            var image = info[UIImagePickerControllerEditedImage] as! UIImage
            let qualitydata = PLGlobalClass.compressImageQuality(image)
            
            //相册消失
            picker.dismiss(animated: true) { [weak self] in
                DispatchQueue.main.async(execute: {
                    
                    self?.hasCoverImage = true
                    self?.rightImgBtn?.setImage(image, for:  .normal)
                    
                    GlobalClass.requestToupdateFile(type: .IMG, realType: nil, files: [qualitydata!], imageBtn: (self?.rightImgBtn!)!)
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


//MARK: - ----------------用户的headerView
class PersonalHeaderView: UIView {
    
    var headerImageV =  UIImageView()
    ///第一行文字 名称
    var text1 = UILabel()
    ///第二行文字 职业
    var text2 = UILabel()
    
    typealias clickBlock = (Int)->()
    var block:clickBlock?
    
    func btnclickBlock(block:clickBlock?) {
        self.block = block
    }
    
    var btnArr : [String]?{
        didSet {
            
            if btnArr?.count ?? 0 > 0 {
                let toLeft = (self.width_sd - CGFloat(btnArr!.count) * F_I6(place: 82)) / CGFloat(btnArr!.count + 1)
                
                //+20
                for index in 0 ... btnArr!.count - 1{
                    var btn = self.viewWithTag(100 + index) as? UIButton
                    if btn == nil{
                        btn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: F_I6(place: 82), height: F_I6(place: 28)))
                        btn?.layer.borderWidth = 1
                        btn?.layer.borderColor = UIColor.white.cgColor
                        btn?.setTitleColor(UIColor.white, for: .normal)
                        btn?.layer.cornerRadius = 3
                        btn?.clipsToBounds = true
                        self.addSubview(btn!)
                        
                        if self.text2.text?.count == 0{
                            btn?.top_sd = self.text2.bottom_sd
                        }else{
                            btn?.top_sd = self.text2.bottom_sd + F_I6(place: 20)
                        }
                        btn?.titleLabel?.font = UIFont.systemFont(ofSize: 15)
                    }
                    
                    btn?.tag = 100 + index
                    btn?.left_sd = toLeft + CGFloat(index) * (F_I6(place: 82) + toLeft)
                    btn?.setTitle(btnArr?[index], for: .normal)
                    
                    btn?.handleEventTouchUpInside(callback: { [weak self] in
                        if let block  =  self?.block {
                            block(index)
                        }
                    })
                }
                
            }else{
                for view in self.subviews{
                    if view.tag >= 100{
                        view.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    var model : commentModel?{
        didSet {
        }
    }
    
    class func getViewHeigh() -> (CGFloat){
        return F_I6(place: 148)
    }
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.backgroundColor = UIColor.baseColor
        
        let headerW = F_I6(place: 68)
        
        headerImageV = UIImageView.init(frame: CGRect.init(x: 0 , y: F_I6(place: 7), width: headerW, height: headerW))
        headerImageV.contentMode = .scaleAspectFill
        headerImageV.layer.cornerRadius = headerW/2
        headerImageV.clipsToBounds = true
        headerImageV.layer.borderWidth = 0.5
        headerImageV.layer.borderColor = UIColor.cutLineColor.cgColor
        self.addSubview(headerImageV)
        headerImageV.image = UIImage.init(named: ImageDefault.headerPlace)
        headerImageV.centerX_sd = self.width_sd/2
        
        text1 = UILabel.init(frame: CGRect.init(x: 0, y: headerImageV.bottom_sd + F_I6(place: 8), width: frame.width , height: F_I6(place: 20)))
        text1.font = UIFont.systemFont(ofSize: 15)
        text1.textColor = UIColor.white
        text1.textAlignment = .center
        self.addSubview(text1)
        
        text2 = UILabel.init(frame: CGRect.init(x: 0, y: text1.bottom_sd + F_I6(place: 5), width: frame.width , height: F_I6(place: 20)))
        text2.font = UIFont.systemFont(ofSize: 12)
        text2.textColor = UIColor.white
        text2.textAlignment = .center
        self.addSubview(text2)
        
        text1.text = ""
        text2.text = ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

