
//MARK: - ----------------同宗活动详情页
class ActivityInfo: CommentTabVC {
    
    var model : ActivityModel?
    var headerView : ActInfoView?
    var baomingBtn = UIButton()
    var talkBtn = UIButton()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pinlunType = "3"
        self.infoId = self.model?.id
        
        self.requestforList()
        
        self.knavigationBar?.title = "活动详情"
        self.knavigationBar?.rightBarBtnItem = KNaviBarBtnItem.init(frame:  CGRect.init(x: 0, y: KStatusBarHeight, width: 44, height: 44), image: "share_white", hander: {  [weak self](sender) in
            self?.toShare()
        })
        
        let Hei = F_I6(place: 50) + KBottomStatusH/2

        baomingBtn = UIButton.init(frame: CGRect.init(x: 0, y: KScreenHeight-Hei, width: KScreenWidth/2, height: Hei))
        baomingBtn.setTitle("立即报名", for: .normal)
        baomingBtn.backgroundColor = UIColor.baseColor
        baomingBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.view.addSubview(baomingBtn)
        
        talkBtn = UIButton.init(frame: CGRect.init(x: KScreenWidth/2, y: KScreenHeight-Hei, width: KScreenWidth/2, height: Hei))
        talkBtn.setTitle("评论", for: .normal)
        talkBtn.backgroundColor = UIColor.baseColor
        talkBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        talkBtn.setImage(UIImage.init(named: "write"), for: .normal)
        self.view.addSubview(talkBtn)
        
        PLGlobalClass.setBtnStyle(baomingBtn, style: .imageLeft, space: 5)
        PLGlobalClass.setBtnStyle(talkBtn, style: .imageLeft, space: 5)
        
        let line = UIView.init(frame: CGRect.init(x: KScreenWidth/2, y: baomingBtn.top_sd + F_I6(place: 5), width: 1, height: Hei - F_I6(place: 10)))
        line.backgroundColor = UIColor.lineColor3
        self.view.addSubview(line)
        
        baomingBtn.handleEventTouchUpInside {[weak self] in
            if (self?.baomingBtn.isSelected)!{
                ClanAPI.requestForactivitycancelSignup(actid: self?.model?.id, result: { (result) in
                    if ((result.status) == "200"){
                        WFHudView.showMsg("取消报名成功", in: self?.view)//报名成功回调 - 刷详情
                        self?.requestForActivityInfo()
                    }else{
                        if (result.message.count>0){
                            WFHudView.showMsg(result.message, in: self?.view)
                        }else{
                            WFHudView.showMsg("取消报名失败", in: self?.view)
                        }
                    }
                })
                
            }else{
                let baoming = BaomingVC.init()
                baoming.model = self?.model
                baoming.callBlock(block: {
                    //报名成功回调 - 刷详情
                    self?.requestForActivityInfo()
                })
                self?.navigationController?.pushViewController(baoming, animated: true)
            }
        }
        
        talkBtn.handleEventTouchUpInside {[weak self] in
            self?.requestForcomment()
        }
    }
    
    //MARK: - tableView
    override func maketableView(){
        super.maketableView()
        
        let basehei = F_I6(place: 243) + 176 + MemberView.ViewHeight() + 44 + 10 + ActInfoView.gettextHeigh(actmodel:self.model!) + 20
        self.headerView = ActInfoView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: basehei))
        self.tableView.tableHeaderView = self.headerView
        
        let gesture = UITapGestureRecognizer.bk_recognizer {[weak self] (tap, state, point) in
            let signVC = SignupUsersVC.init()
            signVC.userList = (self?.model?.signupusers)!
            self?.navigationController?.pushViewController(signVC, animated: true)
        }
        headerView?.baomingtitle?.rightLab.addGestureRecognizer(gesture as! UIGestureRecognizer)
        
        headerView?.callBlock(block: {[weak self] (hei) in
            self?.headerView?.height_sd = hei
            self?.tableView.tableHeaderView = self?.headerView
        })
        
        self.requestForActivityInfo()
        headerView?.model = self.model!
    }
    
    func reloadHeaderView(actimodel : ActivityModel){

        DispatchQueue.main.async {[weak self] in
            for view in (self?.headerView?.memberView?.subviews)!{
                if view is MemberView{
                    view.removeFromSuperview()
                }
            }
            self?.headerView?.memberViewModel = actimodel
        }
        
        let date = PLGlobalClass.dateWithtimeStr(model?.signupstarttime)
        let result = PLGlobalClass.comparenowdate(with: date)

        let enddate = PLGlobalClass.dateWithtimeStr(model?.signupendtime)
        let endresult = PLGlobalClass.comparenowdate(with: enddate)
        
        if actimodel.isend == true{
            baomingBtn.setTitle("活动已结束", for: .normal)
            baomingBtn.isUserInteractionEnabled = false
        }else if( result == 1) {
            baomingBtn.setTitle("报名未开始", for: .normal)
            baomingBtn.isUserInteractionEnabled = false
        }else if actimodel.issignup {
            baomingBtn.setTitle("取消报名", for: .normal)
            baomingBtn.isUserInteractionEnabled = true
            baomingBtn.isSelected = true
        }else if( endresult == -1) {
            baomingBtn.setTitle("报名已结束", for: .normal)
            baomingBtn.isUserInteractionEnabled = false
        }else{
            baomingBtn.setTitle("立即报名", for: .normal)
            baomingBtn.isUserInteractionEnabled = true
            baomingBtn.isSelected = false
        }
    }
    
    func requestForActivityInfo(){
        if  self.model?.id.count == 0{
            return
        }
        ClanAPI.requestForActivityInfo(actid: (self.model?.id)!) {[weak self] (result) in
            if (result.status == "200"){
                if ((result.data != nil) && (result.data is Dictionary<String,Any>)){
                    
                    let tempModel =
                        ActivityModel.mj_object(withKeyValues: result.data)
                    self?.model = tempModel
                    self?.reloadHeaderView(actimodel: (self?.model!)!)
                }
            }
        }
    }

    override func emptyShow(show:Bool){
        if show{
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 180, 0);
            footerview.height_sd = 180
        }else{
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
            footerview.height_sd = 0
        }
    }
    // MARK: - 分享
    override func toShare() {

        self.shareTitle = self.model?.content
        self.shareUrl = ClanAPI.H5UserName + ClanAPI.H5Share_activity + (self.model?.id ?? "")
        self.shareImgUrl = NSString.formatImageUrl(with: model?.themeimg, ifThumb: true, thumb_W: 0)
        
        PLShareGlobalView.toShare(sharetype : "2", targetid : (self.model?.id)!,  shareTitle: self.shareTitle, shareUrl: self.shareUrl, shareImgUrl: self.shareImgUrl, shareDes: "来自同宗汇", shareimg: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



//MARK: - ----------------同宗活动报名页
class BaomingVC: KBaseClanViewController{
    typealias successBlock = ()->()
    var block:successBlock?
    
    func callBlock(block:successBlock?) {
        self.block = block
    }
    
    var titleLab = UILabel()
    var activityView =  UILabel()
    var addressView =  UILabel()
    var model : ActivityModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.knavigationBar?.title = "活动报名"
        self.createView()
    }
    
    func createView() {
        let titleView = UIView.init(frame: CGRect.init(x: 0, y: KTopHeight, width: KScreenWidth, height:F_I6(place: 60)))
        titleView.backgroundColor = UIColor.white
        self.view.addSubview(titleView)
        
        titleLab = UILabel.init(frame: CGRect.init(x: 12, y: 0, width: KScreenWidth - 12 * 2, height:F_I6(place: 61)))
        titleLab.font = UIFont.boldSystemFont(ofSize: 15)
        titleLab.textColor = UIColor.textColor1
        titleLab.numberOfLines = 0
        titleLab.backgroundColor = UIColor.white
        titleLab.text = model?.title
        titleView.addSubview(titleLab)
        
        
        let starDate = PLGlobalClass.dateWithtimeStr(model?.starttime)
        let endDate = PLGlobalClass.dateWithtimeStr(model?.endtime)
        
        let starstr = NSString.timeMMddHHmm(with: starDate)
        let endstr = NSString.timeMMddHHmm(with: endDate)
        
        
        activityView = UILabel.init(frame: CGRect.init(x: 12, y: titleLab.bottom_sd, width: KScreenWidth - 12 * 2, height:F_I6(place: 25)))
        activityView.font = UIFont.systemFont(ofSize: 12)
        activityView.textColor = UIColor.textColor2
        activityView.numberOfLines = 0
        activityView.backgroundColor = UIColor.white
        activityView.text = starstr! + "   至   " + endstr!
        titleView.addSubview(activityView)
        
        
        addressView = UILabel.init(frame: CGRect.init(x: 12, y: activityView.bottom_sd, width: KScreenWidth - 12 * 2, height:F_I6(place: 40)))
        addressView.font = UIFont.systemFont(ofSize: 12)
        addressView.textColor = UIColor.textColor2
        addressView.numberOfLines = 0
        addressView.backgroundColor = UIColor.white
        addressView.text = model?.address
        titleView.addSubview(addressView)
        titleView.height_sd = addressView.bottom_sd
        
        
        let line = UIView.init(frame: CGRect.init(x: 0, y: titleView.bottom_sd, width: KScreenWidth, height: 5))
        line.backgroundColor = UIColor.cutLineColor
        self.view.addSubview(line)

        let queren = IconAndInput.init(frame: CGRect.init(x: 0, y: line.bottom_sd, width: KScreenWidth, height: 44))
        queren.iconImageView.image = UIImage.init(named: "")
        queren.inputV.font = UIFont.systemFont(ofSize: 16)
        queren.inputV.text = "确认信息"
        queren.inputV.left_sd = 10
        queren.inputV.isUserInteractionEnabled = false
        self.view.addSubview(queren)
        
        
        let nameView = IconAndInput.init(frame: CGRect.init(x: 0, y: queren.bottom_sd, width: KScreenWidth, height: 44))
        nameView.iconImageView.image = UIImage.init(named: "user_icon")
        
        let user = UserServre.shareService.userModel
        let userclub = UserServre.shareService.userClub
        nameView.inputV.text = (userclub?.club ?? "") + (user?.realname ?? "")
        nameView.inputV.isUserInteractionEnabled = false
        self.view.addSubview(nameView)
        
        let phoneView = IconAndInput.init(frame: CGRect.init(x: 0, y: nameView.bottom_sd, width: KScreenWidth, height: 44))
        phoneView.iconImageView.image = UIImage.init(named: "phone_icon")
        phoneView.inputV.keyboardType = .numberPad
        phoneView.inputV.placeholder = "请输入您的手机号"
        phoneView.inputV.addTarget(self, action: #selector(wordlimitTelephone(withTf:)), for: .editingChanged)
        self.view.addSubview(phoneView)
        
        //确定按钮
        let nextBtn = UIButton.init(frame: CGRect.init(x: F_I6(place: 13), y: phoneView.bottom_sd + F_I6(place: 66), width: F_I6(place: 350), height: 44))
        nextBtn.backgroundColor = UIColor.baseColor
        nextBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        nextBtn.setTitle("确   定", for: UIControlState.normal)
        nextBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        self.view.addSubview(nextBtn)
        nextBtn.layer.cornerRadius = 5
        nextBtn.clipsToBounds = true
        nextBtn.handleEventTouchUpInside {[weak self] in
            print("报名 网络请求")
            
            if phoneView.inputV.text?.count != 11 {
                WFHudView.showMsg("请填写11位手机号", in: self?.view)
            }else{
                ClanAPI.requestForactivitySignup(name: nameView.inputV.text!, phone: phoneView.inputV.text!, actid: self?.model?.id, claim: nil, result: { (result) in
                    
                    if ((result.status) == "200"){
                        WFHudView.showMsg("报名成功", in: self?.view)
                    self?.navigationController?.popViewController(animated: true)
                        if let block  =  self?.block {
                            block()
                        }
                    }else{
                        if (result.message.count>0){
                            WFHudView.showMsg(result.message, in: self?.view)
                        }else{
                            WFHudView.showMsg("报名失败", in: self?.view)
                        }
                    }
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: - ----------------参与人员列表
class SignupUsersVC: KBaseClanViewController,UITableViewDelegate,UITableViewDataSource{
    
    var tableView = UITableView()
    var userList = [SignupUserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createView()
    }
    
    func createView() {
        
        self.tableView = UITableView.init(frame: CGRect.init(x: 0, y: KTopHeight, width: KScreenWidth, height: KScreenHeight - KTopHeight), style: UITableViewStyle.plain)
        self.tableView.backgroundColor = UIColor.white
        self.tableView.delegate=self
        self.tableView.dataSource=self
        tableView.separatorStyle = .none
        self.view.addSubview(self.tableView)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 1))
        tableView.tableHeaderView = view
        let view2 = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 1))
        tableView.tableFooterView = view2
        
        /// 自动关闭估算高度，不想估算那个，就设置那个即可
        self.tableView.estimatedRowHeight = 0
        self.tableView.estimatedSectionHeaderHeight = 0
        self.tableView.estimatedSectionFooterHeight = 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return F_I6(place: 70)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? UserListCell
        if (cell == nil){
            cell = UserListCell.init(style: .default, reuseIdentifier: "cell")
        }
        cell?.usermodel = userList[indexPath.row]
        return cell!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



//MARK: - ----------------同宗活动详情View
class ActInfoView: UIView {
    typealias heiBlock = (_ hei : CGFloat)->()
    var block:heiBlock?
    
    /// 图片1
    var themimg = UIImageView()
    /// 标题
    var titleLab = UILabel()
    var baomingView : TitleAndText?
    var activityView : TitleAndText?
    var addressView : TitleAndText?
    var businessView : TitleAndText?
    var baomingtitle : PLMenuView? //已报名一行

    var memberView : UIView?
    
    var infoTitle = UILabel()
    var infoView = UIView()
    var infoLab = UILabel()
    /// 底部“最新评论”View
//    var bottomView = UIView()
    
    func callBlock(block:heiBlock?) {
        self.block = block
    }
    
    var model : ActivityModel?{
        didSet {
            let imgUrl = NSString.formatImageUrl(with: model?.themeimg, ifThumb: false, thumb_W: 0)
            
            self.themimg.sd_setImage(with: URL.init(string: imgUrl!), placeholderImage: UIImage.init(named: ImageDefault.imagePlace), options: .retryFailed)
            self.titleLab.text = model?.title
            
            let starDate = PLGlobalClass.dateWithtimeStr(model?.starttime)
            let endDate = PLGlobalClass.dateWithtimeStr(model?.endtime)
            
            let starstr = NSString.timeMMddHHmm(with: starDate)
            let endstr = NSString.timeMMddHHmm(with: endDate)
            
            let signstarDate = PLGlobalClass.dateWithtimeStr(model?.signupstarttime)
            let signendDate = PLGlobalClass.dateWithtimeStr(model?.signupendtime)
            
            let signstarstr = NSString.timeMMddHHmm(with: signstarDate)
            let signendstr = NSString.timeMMddHHmm(with: signendDate)
            
            self.activityView?.showLabel.text = starstr! + "   至   " + endstr!
            self.baomingView?.showLabel.text = signstarstr! + "   至   " + signendstr!
            
            self.addressView?.showLabel.text = model?.address
            self.businessView?.showLabel.text = model?.business
            
            baomingtitle?.titleLab.text = "已报名人数（" +  String(describing: model!.signupusers.count) + "/"   + (model?.persons)! + ")"
            
            DispatchQueue.main.async {[weak self] in
                for view in (self?.memberView?.subviews)!{
                    if view is MemberView{
                        view.removeFromSuperview()
                    }
                }
            }
            
            //成员列表
            self.memberViewModel = model
            
            //文字高度自适应
            infoLab.text = model?.content
            let titleHei = ActInfoView.gettextHeigh(actmodel:model!)
            
            infoLab.height_sd = CGFloat(titleHei)
            PLGlobalClass.paragraphForlabel(infoLab, lineSpace: 5)
            infoLab.lineBreakMode = .byTruncatingTail
            
            let bottom = infoLab.bottom_sd + 10
            infoView.height_sd = bottom
            
            if (model?.imgs.count == 0){
                if let block  =  self.block {
                    block(infoView.height_sd  + self.infoView.top_sd)
                }
            }else{
                self.createImage(index: 0, bottom: bottom)
            }
        }
    }
    
    //只刷新报名人数 报名头像
    var memberViewModel : ActivityModel?{
        didSet {
            baomingtitle?.titleLab.text = "已报名人数（" +  String(describing: memberViewModel!.signupusers.count) + "/"   + (memberViewModel?.persons)! + ")"
            
            //成员列表
            if (memberViewModel?.signupusers.count ?? 0) > 6{
                baomingtitle?.rightLab.isHidden = false
                baomingtitle?.rightLab.text = "更多"
                for i in 0 ... 5
                {
                    let  signmodel = (memberViewModel?.signupusers)![i]
                    let member = MemberView.init(frame: CGRect.init(x: 12 + (MemberView.HeaderSize() + MemberView.HeaderBetw()) * CGFloat(i)  , y: (baomingtitle?.bottom_sd)!, width: MemberView.HeaderSize(), height: MemberView.ViewHeight()))
                        let imgUrl = NSString.formatImageUrl(with: signmodel.headimg, ifThumb: true, thumb_W: 0)
                    member.headImageView.sd_setImage(with: URL.init(string: imgUrl!), placeholderImage: UIImage.init(named: ImageDefault.headerPlace), options: .retryFailed)
                    
                    member.nickNameLabel.text = signmodel.name
                    memberView?.addSubview(member)
                }
                memberView?.height_sd = MemberView.ViewHeight() + (baomingtitle?.height_sd ?? 0) + 10
            }else{
                baomingtitle?.rightLab.isHidden = true
                baomingtitle?.rightLab.text = ""
                if (memberViewModel?.signupusers.count == 0){
                    memberView?.height_sd = baomingtitle?.height_sd ?? 0
                }else{
                for i in 0 ... (memberViewModel?.signupusers.count)!-1
                {
                    let  signmodel = (memberViewModel?.signupusers)![i]
                    let member = MemberView.init(frame: CGRect.init(x: 12 + (MemberView.HeaderSize() + MemberView.HeaderBetw()) * CGFloat(i)  , y: (baomingtitle?.bottom_sd)!, width: MemberView.HeaderSize(), height: MemberView.ViewHeight()))
                        let imgUrl = NSString.formatImageUrl(with: signmodel.headimg, ifThumb: true, thumb_W: 0)
                    member.headImageView.sd_setImage(with: URL.init(string: imgUrl!), placeholderImage: UIImage.init(named: ImageDefault.headerPlace), options: .retryFailed)
                    member.nickNameLabel.text = signmodel.name
                    memberView?.addSubview(member)
                }
                memberView?.height_sd = MemberView.ViewHeight() + (baomingtitle?.height_sd ?? 0) + 10
                }
            }
            
            //详情在报名人数下面
            infoView.top_sd = (memberView?.bottom_sd)!
            //刷新详情的高度
            if let block  =  self.block {
                block(infoView.height_sd  + self.infoView.top_sd)
            }
        }
    }
    
    
    //MARK:动态加载网络图片
    func createImage(index : Int, bottom : CGFloat){
        var newbottom = bottom
        
        let imgV = UIImageView.init(frame: CGRect.init(x: 12, y: bottom, width: KScreenWidth-24, height: 0))
        imgV.contentMode = .scaleAspectFill
        imgV.clipsToBounds = true
        newbottom = imgV.bottom_sd + 12
        self.infoView.height_sd = newbottom
        self.infoView.addSubview(imgV)
        imgV.sd_setImage(with: URL.init(string: NSString.formatImageUrl(with: (model?.imgs[index])!, ifThumb: false, thumb_W: 0)), placeholderImage: UIImage.init(named: ImageDefault.imagePlace), options: .retryFailed)

        
        DispatchQueue.global().async {[weak self] in
            let imageModel = String.getImageSize(urlStr: (self?.model?.imgs[index])!)
            if imageModel != nil{

                DispatchQueue.main.async {
                    imgV.height_sd = (imageModel?.heigh)! * (KScreenWidth - 24) / (imageModel?.width)!
                    newbottom = imgV.bottom_sd + 12
                    self?.infoView.height_sd = newbottom
                    if index == (self?.model?.imgs.count)!-1{
                        if let block  =  self?.block {
                            block((self?.infoView.height_sd)! + (self?.infoView.top_sd)!)
                        }
                    }else{
                        if let block  =  self?.block {
                            block((self?.infoView.height_sd)! + (self?.infoView.top_sd)!)
                        }
                        self?.createImage(index: index+1, bottom: newbottom)
                    }
                }

            }else{
                DispatchQueue.main.async {
                    imgV.height_sd = (KScreenWidth-24)/4*3
                    newbottom = imgV.bottom_sd + 12
                    self?.infoView.height_sd = newbottom
                    if index == (self?.model?.imgs.count)!-1{
                        if let block  =  self?.block {
                            block((self?.infoView.height_sd)! + (self?.infoView.top_sd)!)
                        }
                    }else{
                        if let block  =  self?.block {
                            block((self?.infoView.height_sd)! + (self?.infoView.top_sd)!)
                        }
                        self?.createImage(index: index+1, bottom: newbottom)
                    }
                }
            }
        }
    }
    
    class func gettextHeigh(actmodel:ActivityModel) -> (CGFloat){
        
        return PLGlobalClass.getTextHeight(withStr: actmodel.content, labWidth: KScreenWidth - 12 * 2, fontSize: 16, numberLines: 0, lineSpacing: 5)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        themimg = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height:F_I6(place: 182)))
        themimg.contentMode = .scaleAspectFill
        themimg.clipsToBounds = true
        self.addSubview(themimg)
        
        let titleView = UIView.init(frame: CGRect.init(x: 0, y: themimg.bottom_sd, width: KScreenWidth, height:80))
        titleView.backgroundColor = UIColor.white
        self.addSubview(titleView)
        _ = titleView.addBottomLine(color: UIColor.cutLineColor)
        
        titleLab = UILabel.init(frame: CGRect.init(x: 12, y: 0, width: KScreenWidth - 12 * 2, height:80))
        titleLab.font = UIFont.boldSystemFont(ofSize: 18)
        titleLab.textColor = UIColor.textColor1
        titleLab.numberOfLines = 0
        titleLab.backgroundColor = UIColor.clear
        titleLab.text = "fjewiogworuewogjeiogjierghireahiweiqtyie"
        titleView.addSubview(titleLab)
        
        baomingView = TitleAndText.init(frame: CGRect.init(x: 0, y: (titleView.bottom_sd), width: KScreenWidth, height: 60))
        baomingView?.titleLabel.text = "报名时间"
        baomingView?.showLabel.text = "2018/03/04 至 2018/04/12"
        self.addSubview(baomingView!)
        _ = baomingView?.addBottomLine(color: UIColor.cutLineColor)


        activityView = TitleAndText.init(frame: CGRect.init(x: 0, y: (baomingView?.bottom_sd)!, width: KScreenWidth, height: 60))
        activityView?.titleLabel.text = "活动时间"
        activityView?.showLabel.text = "2018/03/04 至 2018/04/12"
        self.addSubview(activityView!)
        _ = activityView?.addBottomLine(color: UIColor.cutLineColor)

        addressView = TitleAndText.init(frame: CGRect.init(x: 0, y: (activityView?.bottom_sd)! + 1, width: KScreenWidth, height: 60))
        addressView?.titleLabel.text = "地址"
        addressView?.showLabel.text = "fhdkshggaigjeiorgj"
        self.addSubview(addressView!)
        _ = addressView?.addBottomLine(color: UIColor.cutLineColor)

        businessView = TitleAndText.init(frame: CGRect.init(x: 0, y: (addressView?.bottom_sd)! + 1, width: KScreenWidth, height: 60))
        businessView?.titleLabel.text = "主办方"
        businessView?.showLabel.text = "fhdks"
        self.addSubview(businessView!)
        _ = businessView?.addBottomLine(color: UIColor.cutLineColor)

        memberView = UIView.init(frame: CGRect.init(x: 0, y: (businessView?.bottom_sd)! + 1, width: KScreenWidth, height: MemberView.ViewHeight() + (baomingtitle?.height_sd ?? 0) + 10))
        memberView?.backgroundColor = UIColor.white
        self.addSubview(memberView!)
        
        baomingtitle = PLMenuView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 80), title: "已报名人数（0/0）", rightStr: "更多", rightimg: "", ifTimeDurding: false, ifclick: false, ifClassify: false)
        baomingtitle?.textField.removeFromSuperview()
        baomingtitle?.titleLab.width_sd = KScreenWidth - F_I6(place: 44) - 12 - 12
        baomingtitle?.titleLab.font = UIFont.boldSystemFont(ofSize: 18)
        baomingtitle?.rightLab.isUserInteractionEnabled = true
        baomingtitle?.rightLab.width_sd = F_I6(place: 44)
        baomingtitle?.rightLab.right_sd = KScreenWidth-12
        baomingtitle?.rightLab.height_sd = 44
        baomingtitle?.rightLab.centerY_sd = 22
        memberView?.addSubview(baomingtitle!)
        
        //活动内容 图文
        infoView = UIView.init(frame: CGRect.init(x: 0, y: (memberView?.bottom_sd)!, width: KScreenWidth, height: 0))
        infoView.backgroundColor = UIColor.white
        self.addSubview(infoView)
        
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 5))
        view.backgroundColor = UIColor.bgColor5
        infoView.addSubview(view)
        
        infoTitle = UILabel.init(frame: CGRect.init(x: 12, y: view.bottom_sd, width: KScreenWidth - 12*2, height: F_I6(place: 50)))
        infoTitle.text = "活动详情"
        infoTitle.font = UIFont.boldSystemFont(ofSize: 18)
        infoTitle.textColor = UIColor.black
        _ = infoTitle.addBottomLine(color: UIColor.cutLineColor)
        infoView.addSubview(infoTitle)
        
        infoLab = UILabel.init(frame: CGRect.init(x: 12, y: infoTitle.bottom_sd + 15, width: KScreenWidth - 12 * 2, height:F_I6(place: 61)))
        infoLab.font = UIFont.systemFont(ofSize: 16)
        infoLab.textColor = UIColor.textColor1
        infoLab.numberOfLines = 0
        infoLab.backgroundColor = UIColor.white
        infoLab.text = "fjewiogworuewogjeiogjierghireahiweiqtyie"
        infoView.addSubview(infoLab)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - ----------------标题和文字
class TitleAndText: UIView {
    
    var titleLabel = UILabel()
    
    var showLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        titleLabel = UILabel.init(frame: CGRect.init(x: 12, y: 0, width: 80, height: self.height_sd))
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = UIColor.textColor2
        self.addSubview(titleLabel)
        
        showLabel = UILabel.init(frame: CGRect.init(x: titleLabel.right_sd+10, y: 0, width: KScreenWidth-self.titleLabel.right_sd-10-12, height: self.height_sd))
        showLabel.font = UIFont.systemFont(ofSize: 15)
        showLabel.textColor = UIColor.textColor1
        showLabel.numberOfLines = 0
        self.addSubview(showLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - ----------------标题和文字输入
class TitleAndTextField: UIView {
    
    var titleLabel = UILabel()
    
    var showLabel = UITextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        titleLabel = UILabel.init(frame: CGRect.init(x: 12, y: 0, width: 80, height: self.height_sd))
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textColor = UIColor.textColor2
        self.addSubview(titleLabel)
        
        showLabel = UITextField.init(frame: CGRect.init(x: titleLabel.right_sd+10, y: 0, width: KScreenWidth-self.titleLabel.right_sd-10-12, height: self.height_sd))
        showLabel.font = UIFont.systemFont(ofSize: 13)
        showLabel.textColor = UIColor.textColor2
        showLabel.textAlignment = .right
        self.addSubview(showLabel)
        
        self.addBottomLine(color: UIColor.cutLineColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - ----------------用户头像View 上面头像下面昵称
class MemberView: UIView {
    typealias clickBlock = ()->()
    var clickblock:clickBlock?

    var headImageView = UIImageView()
    var nickNameLabel = UILabel()
    var btn = UIButton()
    var noShowUserInfo = false
    
    func callBlock(block:clickBlock?) {
        self.clickblock = block
    }

    class func HeaderSize() -> (CGFloat){
        return F_I6(place: 50)
    }
    
    class func HeaderBetw() -> (CGFloat){
        let W = Int(self.HeaderSize())
        let count = 6
        let betw = (Int(KScreenWidth) - 12*2 - W*count)/(count-1)
        return CGFloat(betw)
    }
    
    class func ViewHeight() -> (CGFloat){
        return MemberView.HeaderSize() + CGFloat(5) + F_I6(place: 30)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        headImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: MemberView.HeaderSize(), height: MemberView.HeaderSize()))
        headImageView.backgroundColor = UIColor.clear
        self.addSubview(headImageView)
        headImageView.layer.cornerRadius = 5
        headImageView.layer.borderWidth = 0.5
        headImageView.layer.borderColor = UIColor.cutLineColor.cgColor
        headImageView.clipsToBounds = true
        
        nickNameLabel = UILabel.init(frame: CGRect.init(x: headImageView.left_sd, y: headImageView.bottom_sd+5, width: MemberView.HeaderSize(), height: F_I6(place: 30)))
        nickNameLabel.font = UIFont.systemFont(ofSize: 13)
        nickNameLabel.textColor = UIColor.textColor1
        nickNameLabel.textAlignment = .center
        nickNameLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(nickNameLabel)
        
        btn = UIButton.init(frame: headImageView.frame)
        self.addSubview(btn)
        btn.handleEventTouchUpInside {[weak self] in
            if (self?.noShowUserInfo)!{
                
            }else{
                if let block  =  self?.clickblock {
                    block()
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - ----------------左边icon 右边输入框
class IconAndInput: UIView {
//    typealias clickBlock = ()->()
//    var clickblock:clickBlock?
    
    var iconImageView = UIImageView()
    var inputV = UITextField()
    
    
    class func iconW() -> (CGFloat){
        return F_I6(place: 20)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        iconImageView = UIImageView.init(frame: CGRect.init(x: 10, y: (frame.height-IconAndInput.iconW())/2, width: IconAndInput.iconW(), height: IconAndInput.iconW()))
        iconImageView.backgroundColor = UIColor.clear
        iconImageView.contentMode = .center
        self.addSubview(iconImageView)
        
        inputV = UITextField.init(frame: CGRect.init(x: iconImageView.right_sd + 20, y: 0, width: frame.width - iconImageView.right_sd - 20, height: frame.height))
        inputV.font = UIFont.systemFont(ofSize: 15)
        inputV.textColor = UIColor.textColor1
        inputV.adjustsFontSizeToFitWidth = true
        self.addSubview(inputV)
        
        let line = UIView.init(frame: CGRect.init(x: 0, y: frame.height-0.5, width: frame.width, height: 0.5))
        line.backgroundColor = UIColor.cutLineColor
        self.addSubview(line)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - ----------------左边头像 右边两行文字 下面的文字带小图标,(小图标写成按钮)
class UserList: UIView {

    
    var leftImageView = UIImageView()//左边图片
    var iconbtn = UIButton()//第二行文字前面小图标

    var text1 = UILabel() //第一行文字
    var text2 = UILabel() //第二行文字
    
    class func iconW() -> (CGFloat){
        return 20
    }
    
    init(frame: CGRect, headerToTop : CGFloat , headerW : CGFloat) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
//        let headerW = frame.height - CGFloat(2*headerToTop)
//        let headerW = CGFloat(38)

        
        leftImageView = UIImageView.init(frame: CGRect.init(x: CGFloat(10), y: CGFloat(headerToTop), width: headerW, height: headerW))
        leftImageView.backgroundColor = UIColor.clear
        leftImageView.contentMode = .scaleAspectFill
        leftImageView.clipsToBounds = true
        self.addSubview(leftImageView)
        
        leftImageView.layer.cornerRadius = 2
        leftImageView.layer.borderColor = UIColor.cutLineColor.cgColor
        leftImageView.layer.borderWidth = 0.5
        leftImageView.clipsToBounds = true
        
        text1 = UILabel.init(frame: CGRect.init(x: leftImageView.right_sd + 10, y: leftImageView.top_sd, width: frame.width - leftImageView.right_sd - 10 - F_I6(place: 50) , height: headerW/2))
        text1.font = UIFont.systemFont(ofSize: 15)
        text1.textColor = UIColor.textColor1
        self.addSubview(text1)
        
        
        iconbtn = UIButton.init(frame: CGRect.init(x: text1.left_sd, y: text1.bottom_sd, width: headerW/2, height: headerW/2))
        iconbtn.setImage(UIImage.init(named: "phone_icon_orange"), for: .normal)
        iconbtn.setTitleColor(UIColor.textColor2, for: .normal)
        iconbtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(iconbtn)
        
        
        text2 = UILabel.init(frame: CGRect.init(x: iconbtn.right_sd + 5, y: text1.bottom_sd, width: frame.width - iconbtn.right_sd - F_I6(place: 50) , height: headerW/2))
        text2.font = UIFont.systemFont(ofSize:12)
        text2.textColor = UIColor.textColor2
        self.addSubview(text2)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        let headerW = frame.height
        
        leftImageView = UIImageView.init(frame: CGRect.init(x: CGFloat(10), y: 0, width: headerW, height: headerW))
        leftImageView.backgroundColor = UIColor.clear
        leftImageView.contentMode = .center
        self.addSubview(leftImageView)
        
        text1 = UILabel.init(frame: CGRect.init(x: leftImageView.right_sd + 10, y: leftImageView.top_sd, width: frame.width - leftImageView.right_sd - 10 - F_I6(place: 50) , height: headerW/2))
        text1.font = UIFont.systemFont(ofSize: 14)
        text1.textColor = UIColor.textColor1
        self.addSubview(text1)
        
        
        iconbtn = UIButton.init(frame: CGRect.init(x: text1.left_sd, y: text1.bottom_sd, width: headerW/2, height: headerW/2))
        iconbtn.setImage(UIImage.init(named: "phone_icon"), for: .normal)
        self.addSubview(iconbtn)
        
        
        text2 = UILabel.init(frame: CGRect.init(x: iconbtn.right_sd + 5, y: text1.bottom_sd, width: headerW/2 - iconbtn.right_sd - F_I6(place: 50) , height: headerW/2))
        text2.font = UIFont.systemFont(ofSize: 12)
        text2.textColor = UIColor.textColor2
        self.addSubview(text2)
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - ----------------用户列表cell
class UserListCell: UITableViewCell {
    
    var userView : UserList?//左边图片
    var usermodel : SignupUserModel?{
        didSet {
            let str = UserServre.shareService.userClub?.club

            self.userView?.leftImageView.sd_setImage(with: URL.init(string: NSString.formatImageUrl(with: usermodel?.headimg, ifThumb: true, thumb_W: 80)), placeholderImage: UIImage.init(named: ImageDefault.headerPlace), options: .retryFailed)
            self.userView?.text1.text = str! + (usermodel?.clubname ?? "") + (usermodel?.realname ?? "")
            self.userView?.text2.text = usermodel?.phone ?? ""
            self.userView?.iconbtn.setImage(UIImage.init(named: "phone_icon_orange"), for: .normal)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        userView = UserList.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: F_I6(place: 70)), headerToTop: F_I6(place: 15) )
        
        userView = UserList.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: F_I6(place: 70)), headerToTop: F_I6(place: 15), headerW: F_I6(place: 40))

        
        self.contentView.addSubview(userView!)
        let line = userView?.addBottomLine(color: .cutLineColor)
        line?.left_sd = 12
        line?.width_sd = KScreenWidth - 24
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - ----------------活动参与人员model
class SignupUserModel: KBaseModel {
    
    var actid : String = ""  //动态id
    var claim : String = ""   //
    var clubname : String = "" //
    var created : String = ""  //动态id
    var gender : String = ""   //
    var headimg : String = "" //
    var id : String = ""  //动态id
    var name : String = ""   //
    var phone : String = "" //
    var realname : String = ""  //动态id
    var status : String = ""   //
    var userid : String = "" //
    var username : String = "" //
}


