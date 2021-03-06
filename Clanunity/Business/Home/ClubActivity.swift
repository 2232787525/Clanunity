//
//  CULoginVC.swift
//  Clanunity
//
//  Created by 白bex on 2018/2/1.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

import UIKit
import MJRefresh

//MARK: - ----------------同宗活动列表页
class ClubActivity: BaseTabVC,UITableViewDataSource {
    

    var dynamicArr = [ActivityModel]() //动态Arr
    var draging = false
    
    var needLoadArr = NSMutableArray()
    
    override lazy var emptyView: EmptySwiftView = {
        let tempView = EmptySwiftView.showEmptyView(emptyPicName: "empty_activity", describe: "君暂无活动，赶快发布吧！")
        tempView.centerX_sd = KScreenWidth/2.0
        return tempView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GlobalClass.single_event(eventName: CUKey.UM_activity)
        
        self.knavigationBar?.title = "同宗活动"
        self.knavigationBar?.rightBarBtnItem = KNaviBarBtnItem.init(frame:  CGRect.init(x: 0, y: KStatusBarHeight, width: 44, height: 44), title: "发布") { [weak self](sender) in
            if APPDELEGATE.networkStatus == 0{
                WFHudView.showMsg(TextDefault.noNetWork, in: self?.view)
            }else{
                GlobalClass.requestAuthType(callBack: { (authType) in
                    
                    if authType == 1{
                        self?.gotoPublicClick()
                    }else if authType == 0{
                        self?.alterV.infoLab.text = "您还未实名认证"
                        self?.alterV.btn.setTitle("认证", for: .normal)
                        self?.lew_presentPopupView(self?.alterV, animation: self?.animation, backgroundClickable: true)
                        
                        self?.alterV.btnClickBlock  = {
                            let vc = CertiVC.init()
                            self?.navigationController?.pushViewController(vc, animated: true)
                        }
                    }else{
                        self?.alterV.infoLab.text = "您的实名认证正在审核中"
                        self?.alterV.btn.setTitle("完成", for: .normal)
                        
                        self?.lew_presentPopupView(self?.alterV, animation: self?.animation, backgroundClickable: true)
                        self?.alterV.btnClickBlock  = {
                        }
                    }
                })
            }
        }
    }

    //MARK: - tableView
    override func maketableView(){
        super.maketableView()
        
        tableView.height_sd = KScreenHeight-KTopHeight
        tableView.dataSource=self
        
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 0.01))
        tableView.tableHeaderView = view
        
        emptyView.top_sd = KScreenHeight/2 - 150
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dynamicArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? ActivityCell
        if (cell == nil){
            cell = ActivityCell.init(style: .default, reuseIdentifier: "cell")
            cell?.selectionStyle = .none
        }
        cell?.model = dynamicArr[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ActivityCell.getCellHeigh(model: dynamicArr[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let info = ActivityInfo.init()
        info.model = self.dynamicArr[indexPath.row]
        self.navigationController?.pushViewController(info, animated: true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.draging = true
    }
    
    
    
    override func emptyShow(show:Bool){
        if show{
            if APPDELEGATE.networkStatus == 0{
                emptyView.describeLabel?.text = "请检查您的网络"
            }else{
                emptyView.describeLabel?.text = "君暂无活动，赶快发布吧！"
            }

            footerview.height_sd = KScreenHeight/2 + 100
        }else{
            footerview.height_sd = 0
        }
    }
    
    // MARK: - Https网络请求
    override func requestforList(){
        
        ClanAPI.requestForActivityList(pagenum: pno, pagesize: pnu) {[weak self] (result) in
            self?.hiddenGifView()
            if self != nil{
                self?.tableView.mj_header.endRefreshing()
                self?.tableView.mj_footer.endRefreshing()
                
                if (result.status == "200"){
                    if ((result.data != nil) && (result.data is Dictionary<String,Any>)){
                        let dic = result.data as! Dictionary<String,Any>
                        
                        let resArr = ActivityModel.mj_objectArray(withKeyValuesArray: dic["list"]) as? [ActivityModel]
                        
                        if ((resArr?.count ?? 0) < (self?.pnu)!) {
                            self?.tableView.mj_footer.isHidden = true
                        }else{
                            self?.tableView.mj_footer.isHidden = false
                        }
                        if ((resArr?.count ?? 0) > 0){
                            if( (self?.pno)! > 1){
                                self?.dynamicArr = (self?.dynamicArr)! + resArr!
                            }else{
                                self?.dynamicArr = resArr!
                                if (self?.dynamicArr.count ?? 0) > 0{
                                    PLGlobalClass.write(toFile: "huancun", withKey: "huodong" + (UserServre.shareService.userClub?.id ?? ""), value: dic["list"])
                                }
                            }
                        }else{
                            self?.loadPno()
                        }
                    }else{
                        self?.loadPno()
                    }
                }else{
                    self?.loadPno()
                }
                self?.checkIfNull()
            }
        }
    }
    

    
    func checkIfNull(){
        if self.dynamicArr.count == 0{
            
            var resArr = [ActivityModel]()
            let arr =  PLGlobalClass.getValueFromFile("huancun", withKey: "huodong" + (UserServre.shareService.userClub?.id ?? ""))
            if arr != nil{
                resArr = ActivityModel.mj_objectArray(withKeyValuesArray: arr) as! [ActivityModel]
            }
            
            if resArr.count == 0{
                self.emptyShow(show: true)
            }else{
                self.dynamicArr = resArr
                self.emptyShow(show: false)
                self.tableView.mj_footer.isHidden = false
            }
            
        }else{
            self.emptyShow(show: false)
        }
        self.tableView.reloadData()
    }
    
    func gotoPublicClick() {
        let publicVC = publicActivity.init()
        publicVC.lastVC = self
        self.navigationController?.pushViewController(publicVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("接收到内存警告")
    }
}


//MARK: - ----------------同宗活动cell
class ActivityCell: UITableViewCell {
    
    var row = 0
    /// 点赞按钮
    var likeBtn = UIButton()
    /// 分享按钮
    var shareBtn = UIButton()
    /// 评论按钮
    var talkBtn = UIButton()
    /// 发布者
    var name = UILabel()
    /// 标题
    var title = UILabel()
    /// 图片1
    var image1 = UIImageView()
    /// 图片1
    var endLab = UILabel()
    
    //异步绘制cell 新增属性
    var drawed = false
    var drawColorFlag = NSInteger.init(0)

    
    var model : ActivityModel?{
        didSet {
            
            if (model?.isend == true) {
                self.endLab.isHidden = false
            }else{
                self.endLab.isHidden = true
            }
            
            let attrString = NSMutableAttributedString.init(string: "主办方：", attributes: [NSForegroundColorAttributeName:UIColor.textColor1])
            
            let str = (model?.clubname ?? "") + (model?.realname ?? "")
            attrString.append(NSAttributedString.init(string: (model?.business ?? str) , attributes: [NSForegroundColorAttributeName:UIColor.textColor5]))
            self.name.attributedText = attrString;
    
            self.title.text = model?.title
            
            self.talkBtn.setTitle(model?.commentcount, for: .normal)
            self.shareBtn.setTitle(model?.sharecount, for: .normal)
            self.likeBtn.setTitle(String(describing: model!.praisecount), for: .normal)
            
            PLGlobalClass.paragraphForlabel(self.title, lineSpace: 5)
            self.title.lineBreakMode = .byTruncatingTail
            title.height_sd = ActivityCell.gettextHei(model:model!)
            
            let imgUrl = NSString.formatImageUrl(with: model?.themeimg, ifThumb: true , thumb_W: 300)
            self.image1.sd_setImage(with: URL.init(string: imgUrl!), placeholderImage: UIImage.init(named: ImageDefault.imagePlace), options: .retryFailed)
        
            //视频
            self.image1.top_sd = self.title.bottom_sd  + 8
            self.image1.width_sd = F_I6(place: 351)
            self.image1.height_sd = F_I6(place: 133)
            
            endLab.top_sd = image1.top_sd
            endLab.left_sd = image1.left_sd
            
            name.top_sd = self.image1.bottom_sd
            shareBtn.centerY_sd = name.centerY_sd
            likeBtn.centerY_sd = name.centerY_sd
            talkBtn.centerY_sd = name.centerY_sd
            
            likeBtn.handleEventTouchUpInside {[weak self] in
                if (self?.likeBtn.isSelected)!{
                    ClanAPI.requestForCancelpraise(targetid: (self?.model?.id)!, targettype: "3", result: { (result) in
                        if (result.status == "200"){
                            self?.likeBtn.isSelected = false
                            self?.model?.praise = "0"
                            self?.model!.praisecount = (self?.model!.praisecount)!-1
                            self?.likeBtn.setTitle( String((self?.model!.praisecount)!), for: .normal)
                        }
                    })
                }else{
                    ClanAPI.requestForSubmitpraise(targetid: (self?.model?.id)!, targettype: "3", result: { (result) in
                        if (result.status == "200"){
                            self?.model?.praise = "1"
                            self?.model!.praisecount = (self?.model!.praisecount)!+1
                            self?.likeBtn.isSelected = true
                            self?.likeBtn.setTitle( String((self?.model!.praisecount)!), for: .normal)
                        }
                    })
                }
            }
            if model?.praise == "1"{
                self.likeBtn.isSelected = true
            }else{
                self.likeBtn.isSelected = false
            }
        }
    }
    
    func draw(){
        if drawed == true{
            return
        }
        let flag = drawColorFlag
        drawed = true
        DispatchQueue.global().async {[weak self] in
            if self != nil{
                let rect = CGRect.init(x: 0, y: 0, width: KScreenWidth, height: ActivityCell.getCellHeigh(model: (self?.model)!))
                UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
                let context = UIGraphicsGetCurrentContext()
                UIColor.white.set()
                context?.fill(rect)
            }
        }
    }
    
    class func gettextHei(model : ActivityModel)-> (CGFloat){
        if model.textHei == nil{
            model.textHei = PLGlobalClass.getTextHeight(withStr: model.title, labWidth: KScreenWidth - 12 * 2, fontSize:UIFont.boldSystemFont(ofSize:F_I6(place:15)).pointSize, numberLines: 0, lineSpacing: 5)
        }
        return model.textHei!
    }
    
    class func getCellHeigh(model : ActivityModel) -> (CGFloat){
        
        if model.cellHei == nil{
            model.cellHei = F_I6(place: 198) + self.gettextHei(model:model)
        }
        return model.cellHei!
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        title = UILabel.init(frame: CGRect.init(x: 12, y: 10, width: KScreenWidth - 12 * 2, height:F_I6(place: 51)))
        title.font = UIFont.boldSystemFont(ofSize:F_I6(place:15))
        title.textColor = UIColor.textColor1
        title.isUserInteractionEnabled = false
        title.numberOfLines = 2
        self.contentView.addSubview(title)
        
        image1 = UIImageView.init(frame: CGRect.init(x: title.left_sd, y: title.bottom_sd, width: F_I6(place: 351), height:F_I6(place: 133)))
        image1.contentMode = .scaleAspectFill
        image1.clipsToBounds = true
        self.contentView.addSubview(image1)
        
        endLab = UILabel.init(frame: CGRect.init(x: title.left_sd, y: title.bottom_sd, width: F_I6(place: 351), height:F_I6(place: 133)))
        endLab.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
        endLab.text = "活动已结束"
        endLab.textAlignment = .center
        endLab.font = UIFont.boldSystemFont(ofSize:F_I6(place:18))
        endLab.textColor = UIColor.white
        self.contentView.addSubview(endLab)
        
        name = UILabel.init(frame: CGRect.init(x: title.left_sd, y: image1.bottom_sd, width: 0, height: F_I6(place: 46)))
        name.font = UIFont.systemFont(ofSize: 14)
        name.textColor = UIColor.textColor1
        self.contentView.addSubview(name)
        
        shareBtn = UIButton.init(frame: CGRect.init(x: KScreenWidth-10-F_I6(place:60*3 ) , y: image1.bottom_sd, width:F_I6(place: 60), height:F_I6(place: 32)))
        self.contentView.addSubview(shareBtn)
        shareBtn.setImage(UIImage.init(named: "dyna_2_share"), for: .normal)
        shareBtn.setTitleColor(UIColor.textColor2, for: .normal)
        shareBtn.titleLabel?.font = UIFont.systemFont(ofSize:12)
        PLGlobalClass.setBtnStyle(shareBtn, style: .imageLeft, space: 2)
        shareBtn.isUserInteractionEnabled = false
        
        talkBtn = UIButton.init(frame: CGRect.init(x: KScreenWidth-10-F_I6(place:60*2 ), y: image1.bottom_sd, width:F_I6(place: 60), height:F_I6(place: 32)))
        self.contentView.addSubview(talkBtn)
        talkBtn.setImage(UIImage.init(named: "dyna_1_talk"), for: .normal)
        talkBtn.setTitleColor(UIColor.textColor2, for: .normal)
        talkBtn.titleLabel?.font = UIFont.systemFont(ofSize:12)
        PLGlobalClass.setBtnStyle(talkBtn, style: .imageLeft, space: 2)
        talkBtn.isUserInteractionEnabled = false
        
        likeBtn = UIButton.init(frame: CGRect.init(x: KScreenWidth-10-F_I6(place:60), y: image1.bottom_sd, width: F_I6(place: 60), height: F_I6(place: 32)))
        self.contentView.addSubview(likeBtn)
        likeBtn.setImage(UIImage.init(named: "dyna_3_like"), for: .normal)
        likeBtn.setImage(UIImage.init(named: "like_brown"), for: .selected)

        likeBtn.setTitleColor(UIColor.textColor2, for: .normal)
        likeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        PLGlobalClass.setBtnStyle(likeBtn, style: .imageLeft, space: 2)
        
        name.width_sd = KScreenWidth - shareBtn.left_sd - title.left_sd
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



//MARK: - ----------------宗亲动态model
class ActivityModel: KBaseModel {
    
    var themeimg : String = ""    //封面图
    var gender : String = ""      //性别
    var headimg : String = ""     //头像
    var clubid : String = ""      //姓氏id
    var isapp : Bool = false      //是否是从手机端发布
    var starttime : String = ""   //开始时间
    var endtime : String = ""     //结束时间
    var signupstarttime : String = ""   //报名开始时间
    var signupendtime : String = ""     //报名结束时间
    
    var isend : Bool = false   //是否已结束
    var issignup : Bool = false   //是否已报名
    
    /// 标题
    var title : String = ""
    var userid : String = "" //id
    /// 内容
    var content : String = ""
    var attachid : String = ""      //附件ID
    var attachpath : String = ""    //附件地址
    var signupusers = [SignupUserModel]()//已报名的用户
    var id : String = "" //id
    /// 动态图片
    var imgs = [String]()
    var business : String = ""  //主办方
    
    var clubname : String = "" //姓
    var realname : String = "" //名
    var persons : String = ""  //报名人数
    
    /// 点赞数
    var praise : String = ""
    /// 点赞数
    var praisecount : NSInteger = 0
    /// 评论数
    var commentcount : String = ""
    /// 分享数
    var sharecount : String = ""
    /// 创建日期
    var created : String = ""
    var updated : String = ""
    var status : String = ""
    var username : String = ""
    var tAccount : Dictionary<String, Any>?
    var address : String = ""
    
    var textHei : CGFloat?
    var cellHei : CGFloat?
    var themeimg_img : UIImage?//封面图

    
    override static func mj_objectClassInArray() -> [AnyHashable : Any]! {
//            return ["imgs": String.self]
        return ["signupusers": SignupUserModel.self]
    }
    

    
    
    
    //    override static func mj_objectClassInArray() -> [AnyHashable : Any]! {
    //        return ["imgs": String.self]
    ////        return ["imgs": imgModel.self]
    //    }
}
