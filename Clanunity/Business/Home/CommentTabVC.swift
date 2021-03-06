
//此页面内容：
//        1.表(section0的第一行 为最新评论标题  直接评论显示在section 子评论显示在row  tablefooterView显示空视图)
//        2.请求评论并显示
//        3.处理无评论时空页面展示
//        4.直接评论时的方法(子类“评论”按钮点击调用)
//        5.回复评论 回复子评论(子类不需要再处理回复评论)
//        6.直接评论时表自动滑动到评论显示的一行
//        7.分享字段属性创建

//继承该类后应该做的事：
//        1.赋值infoId，详情的id(必须)
//        2.赋值pinlunType，评论类型(必须)
//        3.详情一般展示在tableView的tableHeaderView(非必须)
//        **如果空视图显示不全，参照姓氏名人详情中重写emptyShow(show:)方法
//        其余视情况而定


import UIKit
import MJRefresh

//MARK: - ----------------带评论的详情页基类
class CommentTabVC: KBaseClanViewController,UITableViewDelegate,UITableViewDataSource {
    
    var tableView = UITableView()
    /// 页数
    var pno = 1
    /// 每页个数
    var pnu = 10
    var dynamicArr = [commentModel]() //评论Arr

    var footerview = UIView()

    var infoId : String?
    var pinlunType = "4"

    /// 分享标题
    var shareTitle : String?
    /// 分享图片url
    var shareImgUrl : String?
    /// 分享img
    var shareimg : String?
    /// 分享描述
    var shareDes : String?
    /// 分享链接
    var shareUrl : String?
    /// 是否是第一次评论
    var firstPinlun = true
    
    lazy var emptyView: EmptySwiftView = {
        let tempView = EmptySwiftView.showEmptyView(emptyPicName: "empty_comment", describe: "暂无评论，赶快抢个沙发吧！")
        tempView.centerX_sd = KScreenWidth/2.0
        return tempView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.maketableView()
    }
    
    //MARK: - tableView
    func maketableView(){
        
        self.tableView = UITableView.init(frame: CGRect.init(x: 0, y: KTopHeight, width: KScreenWidth, height: KScreenHeight - KTopHeight - F_I6(place: 50)), style: UITableViewStyle.grouped)
        self.tableView.backgroundColor = UIColor.white
        self.tableView.delegate=self
//        self.tableView.dataSource=self
        self.view.addSubview(self.tableView)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .none

        let mjheader = MJRefreshGifHeader.init {[weak self] in
            self?.pno=1;
            self?.requestforList()
        }
        GlobalClass.setMjHeader(mjheader: mjheader!)
        tableView.mj_header = mjheader

        self.tableView.mj_footer = MJRefreshAutoNormalFooter{ [weak self] in
            self?.pno = (self?.pno)! + 1
            self?.requestforList()
        }
        self.tableView.mj_footer.isHidden = true

 
        //tableView.mj_header.beginRefreshing()
        
        footerview = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 0))
        footerview.addSubview(emptyView)
        emptyView.top_sd = 40
        footerview.clipsToBounds = true
        tableView.tableFooterView = footerview
        
        /// 自动关闭估算高度，不想估算那个，就设置那个即可
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }
        return (dynamicArr[section-1] as AnyObject).children.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            var cell = tableView.dequeueReusableCell(withIdentifier: "titlecell")
            if (cell == nil){
                cell = UITableViewCell.init(style: .default, reuseIdentifier: "titlecell")
                
                let bottomView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: F_I6(place: 55)))
                bottomView.backgroundColor = UIColor.white
                
                let fengeView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: F_I6(place: 5)))
                fengeView.backgroundColor = UIColor.bgColor5
                bottomView.addSubview(fengeView)
                
                let pinglunLab = UILabel.init(frame: CGRect.init(x: 12, y: fengeView.bottom_sd, width: KScreenWidth-12*2, height: F_I6(place: 50)))
                pinglunLab.text = "最新评论"
                pinglunLab.font = UIFont.boldSystemFont(ofSize: 18)
                bottomView.addSubview(pinglunLab)
                
                let line = UIView.init(frame: CGRect.init(x: pinglunLab.left_sd, y: (bottomView.height_sd)-0.5, width: pinglunLab.width_sd, height: 0.5))
                line.backgroundColor = UIColor.cutLineColor
                bottomView.addSubview(line)
                cell?.contentView.addSubview(bottomView)
            }
            return cell!
        }
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if (!(cell != nil)){
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
            
            let replyView = commentreplyView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 0))
            replyView.tag = 200
            cell?.contentView.addSubview(replyView)
        }
        
        let replyView = cell?.contentView.viewWithTag(200) as? commentreplyView
        let model = dynamicArr[indexPath.section-1].children[indexPath.row]
        if model.commentid == dynamicArr[indexPath.section-1].id{
            model.needShowTouser = false
        }else{
            model.needShowTouser = true
        }
        replyView?.model = model
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return F_I6(place: 55)
        }
        
        return commentreplyView.gettextHeigh(model: dynamicArr[indexPath.section-1].children[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0.01
        }
        return commentheaderView.getCellHeigh(model : dynamicArr[section-1])
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("动态列表刷新")
        if dynamicArr.count > 0{
            footerview.height_sd = 30
        }else{
            footerview.height_sd = 0
        }
        return dynamicArr.count + 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section==0 && indexPath.row == 0{
        }else{
            self.requestforSubmitComment(model: self.dynamicArr[indexPath.section-1].children[indexPath.row], sectionmodel: self.dynamicArr[indexPath.section-1], isRow: true)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            return UIView.init()
        }
        
        let str = "header"
        let model = self.dynamicArr[section-1]
        
        var headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: str)
        if headerView == nil{
            headerView = UITableViewHeaderFooterView.init(reuseIdentifier: str)
            let userView = commentheaderView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: commentheaderView.getCellHeigh(model : model)))
            userView.tag = 100
            userView.userView.iconbtn.left_sd = F_I6(place: 280)
            userView.likeBtn.left_sd = F_I6(place: 320)
            userView.likeBtn.centerY_sd = userView.userView.iconbtn.centerY_sd
            headerView?.contentView.addSubview(userView)
        }
        
        let userView = headerView?.contentView.viewWithTag(100) as? commentheaderView
        userView?.model = dynamicArr[section-1]
        userView?.height_sd = commentheaderView.getCellHeigh(model : model)
        userView?.userView.iconbtn.handleEventTouchUpInside(callback: {[weak self] in

            self?.requestforSubmitComment(model: (self?.dynamicArr[section-1])!, sectionmodel: (self?.dynamicArr[section-1])!, isRow: false)
        })
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        return view
    }
    
    
    // MARK: - Https网络请求
    func requestforList(){
        ClanAPI.requestForcommentList(pagenum: pno, pagesize: pnu, targetid: (self.infoId ?? "")!, targettype: self.pinlunType, result: {[weak self] (result) in
            
            if self != nil{
                DispatchQueue.main.async {
                    if (self == nil){}else{
                        if(self?.tableView.dataSource == nil){
                            self?.tableView.dataSource = self
                        }
                        
                        self?.tableView.mj_header.endRefreshing()
                        self?.tableView.mj_footer.endRefreshing()
                        
                        if (result.status == "200"){
                            if ((result.data != nil) && (result.data is Dictionary<String,Any>)){
                                let dic = result.data as! Dictionary<String,Any>
                                let arr = dic["list"]
                                let resArr = commentModel.mj_objectArray(withKeyValuesArray: arr) as! [commentModel]
                                
                                if ((resArr.count) < (self?.pnu)!) {
                                    self?.tableView.mj_footer.isHidden = true
                                }else{
                                    self?.tableView.mj_footer.isHidden = false
                                }
                                if ((resArr.count) > 0){
                                    if( (self?.pno)! > 1){
                                        self?.dynamicArr = (self?.dynamicArr)! + resArr
                                    }else{
                                        self?.dynamicArr = resArr
                                    }
                                }else if ( (self?.pno)! > 1){
                                    self?.pno = (self?.pno)! - 1
                                }
                            }
                        }else if self?.pno == 1{
                        }
                        
                        self?.tableView.reloadData()
                        if self?.dynamicArr.count == 0{
                            self?.emptyShow(show: true)
                        }else{
                            self?.emptyShow(show: false)
                        }
                    }
                }
            }
        })
    }
    
    func emptyShow(show:Bool){
        if show{
            footerview.height_sd = 180
        }else{
            footerview.height_sd = 0
        }
        tableView.tableFooterView = footerview
    }
    
    //TODO: - 请求详情
    func requestforDetail(){
    }
    
    //TODO:直接评论
    func requestForcomment(){
        if APPDELEGATE.networkStatus == 0{
            WFHudView.showMsg(TextDefault.noNetWork, in: self.view)
            return
        }
        if firstPinlun == true{
            commentInputView.shareInstance().inputView.ifReadTheText = false
            firstPinlun = false

        }else{
            commentInputView.shareInstance().inputView.ifReadTheText = true
        }
        commentInputView.shareInstance().showcommentViewWithmsg("写下您优质的评论...", ifSingleType: true,  sendText: {[weak self] (text) in
            print("发布评论")
            ClanAPI.requestForSubmitcomment(targetid: (self?.infoId!)!, content: text, targettype: (self?.pinlunType)!, touserid: nil, parentid: nil, commentid: nil, result: { (result) in
                if (result.status == "200"){
                    if ((result.data != nil) && (result.data is Dictionary<String,Any>)){
                        let comment = commentModel.mj_object(withKeyValues: result.data)
                        
                        var dic = comment?.fromuser
                        if dic == nil{
                            dic = [:]
                        }
                        dic!["headimg"] = UserServre.shareService.userModel.headimg
                        dic!["realname"] = UserServre.shareService.userModel.realname
                        dic!["username"] = UserServre.shareService.userModel.username
                        comment?.fromuser = dic
                        
                        self?.dynamicArr.insert(comment!, at: 0)
                        WFHudView.showMsg("评论成功", in: self?.view)
                        
                        self?.emptyShow(show: false)
                        self?.tableView.reloadData()
                        
                        self?.scrollToComment()
                    }else{
                        WFHudView.showMsg(result.message ?? "服务器返回错误", in: self?.view)
                    }
                }else{
                    WFHudView.showMsg(result.message ?? "评论失败", in: self?.view)
                }
            })
        })
    }
    
    func scrollToComment(){
        tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
    }
    
    //TODO:回复评论
    //isRow 是否是对子评论进行回复  false对评论回复  true对评论下面的小评论回复
    func requestforSubmitComment(model : commentModel ,sectionmodel : commentModel , isRow : Bool)
    {
        if APPDELEGATE.networkStatus == 0{
            WFHudView.showMsg(TextDefault.noNetWork, in: self.view)
            return
        }
        let str = UserServre.shareService.userClub?.club
        commentInputView.shareInstance().inputView.ifReadTheText = false
        
        var commentid : String?
        if isRow == false{
            commentid = sectionmodel.id
        }
        
        commentInputView.shareInstance().showcommentViewWithmsg("回复" + (str ?? "") + (model.fromuser?["realname"] as? String ?? ""), ifSingleType: true,  sendText: {[weak self] (text) in


            ClanAPI.requestForSubmitcomment(targetid: (self?.infoId!)!, content: text, targettype: "1", touserid: model.userid, parentid: sectionmodel.id, commentid: commentid, result: { (result) in
            
//            ClanAPI.requestForSubmitcomment(targetid: (self?.infoId!)!, content: text, targettype: "1", touserid: model.userid, parentid: model.id, result: { (result) in

            
                if (result.status == "200"){
                    if ((result.data != nil) && (result.data is Dictionary<String,Any>)){
                        let comment = commentModel.mj_object(withKeyValues: result.data)
                        var dic = comment?.fromuser
                        if dic == nil{
                            dic = [:]
                        }
                        dic!["headimg"] = UserServre.shareService.userModel.headimg
                        dic!["realname"] = UserServre.shareService.userModel.realname
                        comment?.fromuser = dic
                        
                        if isRow == false{
                            model.children.insert(comment!, at: 0)
                        }else{
                            sectionmodel.children.insert(comment!, at: 0)
                        }
                        comment?.touser = [String:Any]()
                        comment?.touser!["realname"] = (model.fromuser?["realname"] as? String ?? "")
                        
                        
                        self?.tableView.reloadData()
                        self?.emptyShow(show:false)
                        
                        WFHudView.showMsg("回复成功", in: self?.view)
                    }else{
                        WFHudView.showMsg(result.message ?? "服务器返回错误", in: self?.view)
                    }
                }else{
                    WFHudView.showMsg(result.message ?? "回复失败", in: self?.view)
                }
            })
        })
    }

    func toShare() {
        print("分享")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



