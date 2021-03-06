//
//  CULoginVC.swift
//  Clanunity
//
//  Created by 白bex on 2018/2/1.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

import UIKit
import MJRefresh

//MARK: - ----------------企业秀列表页
class Company: BaseTabVC,UITableViewDataSource {
    
    var dynamicArr = [CompanyModel]() //动态Arr
    
    override lazy var emptyView: EmptySwiftView = {
        let tempView = EmptySwiftView.showEmptyView(emptyPicName: "empty_company", describe: "君暂无内容，赶快发布吧！")
        tempView.centerX_sd = KScreenWidth/2.0
        return tempView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GlobalClass.single_event(eventName: CUKey.UM_qyx)
        
        self.knavigationBar?.title = "企业秀"
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
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? CompanyCell
        if (!(cell != nil)){
            cell = CompanyCell.init(style: .default, reuseIdentifier: "cell")
        }
        cell?.model = dynamicArr[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CompanyCell.getCellHeigh(model: dynamicArr[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let info = CompanyInfo.init()
        info.model = self.dynamicArr[indexPath.row]
        self.navigationController?.pushViewController(info, animated: true)
        //调详情接口 - 目的 增加阅读量
        ClanAPI.requestForenterprise(id: info.model?.id ?? "", result: { (_) in
        })
    }
    
    // MARK: - Https网络请求
    override func requestforList(){
        ClanAPI.requestForEnterpriseList(pagenum: pno, pagesize: pnu) {[weak self] (result) in
            self?.hiddenGifView()
            
            if self != nil{
                
                self?.tableView.mj_header.endRefreshing()
                self?.tableView.mj_footer.endRefreshing()
                
                if (result.status == "200"){
                    if ((result.data != nil) && (result.data is Dictionary<String,Any>)){
                        let dic = result.data as! Dictionary<String,Any>
                        let resArr = CompanyModel.mj_objectArray(withKeyValuesArray: dic["list"]) as? [CompanyModel]
                        
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
                                    PLGlobalClass.write(toFile: "huancun", withKey: "qiye" + (UserServre.shareService.userClub?.id ?? ""), value: dic["list"])
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
            
            var resArr = [CompanyModel]()
            let arr =  PLGlobalClass.getValueFromFile("huancun", withKey: "qiye" + (UserServre.shareService.userClub?.id ?? ""))
            if arr != nil{
                resArr = CompanyModel.mj_objectArray(withKeyValuesArray: arr) as![CompanyModel]
            }
            
//            CompanyModel.mj_objectArray(withKeyValuesArray: arr) as! [CompanyModel]
//            let jsonString = KFileManager.cacheText(withFileName: CUKey.catch_Qiye + (UserServre.shareService.userClub?.id ?? "")) as NSString?
//            let jsonArray = jsonString?.mj_JSONObject()
//            let resArr = CompanyModel.mj_objectArray(withKeyValuesArray: jsonArray) as? [CompanyModel]
            
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
    
    override func emptyShow(show:Bool){
        if show{
            if APPDELEGATE.networkStatus == 0{
                emptyView.describeLabel?.text = "请检查您的网络"
            }else{
                emptyView.describeLabel?.text = "君暂无内容，赶快发布吧！"
            }
            footerview.height_sd = KScreenHeight/2 + 100
        }else{
            footerview.height_sd = 0
        }
    }
    
    func gotoPublicClick() {
        let publicVC = publicCompany.init()
        publicVC.lastVC = self
        self.navigationController?.pushViewController(publicVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


//MARK: - ----------------企业秀cell
class CompanyCell: UITableViewCell {
    var companyView = CompanyView()
    var bottomLine = UIView()
    
    var model : CompanyModel?{
        didSet {
            companyView.model = model
        }
    }
    
    class func getCellHeigh(model : CompanyModel) -> (CGFloat){
        return F_I6(place: 115)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        companyView = CompanyView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: F_I6(place: 115)))
        self.contentView.addSubview(companyView)
        
        bottomLine = companyView.addBottomLine(color: UIColor.cutLineColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - ----------------企业秀View
class CompanyView: UIView {
    
    var headView = UserList()
    
    /// 点赞按钮
    var likeBtn = UIButton()
    /// 浏览数
    var viewBtn = UIButton()
    
    var contentLab = UILabel()
    
    
    
    var model : CompanyModel?{
        didSet {
            
            var con : Any?
            
            if (model?.isapp == true){
                if model?.conJSONObject == nil{
                    /**解析**/
                    let str = model?.context as NSString?
                    con = str?.mj_JSONObject()
                    
                    if (con is NSArray){
                        let arr = con as? NSArray
                        for  tuwen  in arr!{
                            if tuwen is NSArray{
                                
                                var temparr = TuwenModel.mj_objectArray(withKeyValuesArray: tuwen) as? [TuwenModel]
                                if (temparr?.count ?? 0) > 0{
                                    for i in 0 ... temparr!.count-1{
                                        let model = temparr![i]
                                        if model.type == "2" && i == 0{break}
                                        if model.type == "2"{
                                            temparr?.remove(at: i)
                                            temparr?.insert(model, at: 0)
                                            break
                                        }
                                    }
                                }
                                model?.conJSONObject = temparr

//                                model?.conJSONObject = TuwenModel.mj_objectArray(withKeyValuesArray: tuwen) as? [TuwenModel]
                                break
                            }
                            if tuwen is NSDictionary{
                                var temparr = TuwenModel.mj_objectArray(withKeyValuesArray: arr) as? [TuwenModel]
                                if (temparr?.count ?? 0) > 0{
                                    for i in 0 ... temparr!.count-1{
                                        let model = temparr![i]
                                        if model.type == "2" && i == 0{break}
                                        if model.type == "2"{
                                            temparr?.remove(at: i)
                                            temparr?.insert(model, at: 0)
                                            break
                                        }
                                    }
                                }
                                model?.conJSONObject = temparr
                                
//                                model?.conJSONObject = TuwenModel.mj_objectArray(withKeyValuesArray: arr) as? [TuwenModel]
                                break
                            }
                        }
                    }
                }
                /**数据显示**/
                self.contentLab.text = ""
                if (model?.conJSONObject?.count ?? 0) > 0{
                    for tuwen in (model?.conJSONObject)! {
                        if tuwen.type == "0"{
                            self.contentLab.text = tuwen.content
                            break
                        }
                    }
                }
                
            }else{
                /**数据显示**/
                self.contentLab.text = NSString.filterHTML(model?.context ?? "")
            }
            PLGlobalClass.paragraphForlabel(self.contentLab, lineSpace: 5)
            contentLab.lineBreakMode = .byTruncatingTail
            
            self.headView.text1.text = model?.title;
            
            if model?.createtime.count ?? 0  > 10{
                let index1 = model?.createtime.index((model?.createtime.startIndex)!, offsetBy: 10)
                self.headView.text2.text = model?.createtime.substring(to: index1!)
            }else{
                self.headView.text2.text = model?.createtime
            }
            
            self.viewBtn.setTitle(model?.viewcount, for: .normal)
            self.likeBtn.setTitle(String(describing: model!.praisecount), for: .normal)
            
            let imgUrl = NSString.formatImageUrl(with: model?.img, ifThumb: true, thumb_W: 100)
            self.headView.leftImageView.sd_setImage(with: URL.init(string: imgUrl!), placeholderImage: UIImage.init(named: ImageDefault.imagePlace), options: .retryFailed)
            
            likeBtn.handleEventTouchUpInside {[weak self] in
                if (self?.likeBtn.isSelected)!{
                    print("取消赞")
                    ClanAPI.requestForCancelpraise(targetid: (self?.model?.id)!, targettype: "7", result: { (result) in
                        if (result.status == "200"){
                            self?.likeBtn.isSelected = false
                            self?.model?.praise = "0"
                            self?.model!.praisecount = (self?.model!.praisecount)!-1
                            self?.likeBtn.setTitle( String((self?.model!.praisecount)!), for: .normal)
                        }else{
                            WFHudView.showMsg("取消失败", in: self)
                        }
                    })
                }else{
                    print("点赞")
                    ClanAPI.requestForSubmitpraise(targetid: (self?.model?.id)!, targettype: "7", result: { (result) in
                        if (result.status == "200"){
                            self?.model?.praise = "1"
                            self?.model!.praisecount = (self?.model!.praisecount)!+1
                            self?.likeBtn.isSelected = true
                            self?.likeBtn.setTitle( String((self?.model!.praisecount)!), for: .normal)
                            
                        }else{
                            WFHudView.showMsg("点赞失败", in: self)
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        headView = UserList.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: F_I6(place: 115)), headerToTop: F_I6(place: 15))
        
        headView = UserList.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: F_I6(place: 115)), headerToTop: F_I6(place: 15), headerW: 80)

        
        self.addSubview(headView)
        
        headView.text1.height_sd = F_I6(place: 20)
        headView.text1.width_sd = F_I6(place: 170)
        headView.text1.font = UIFont.boldSystemFont(ofSize: 15)
        
        headView.text2.right_sd = headView.width_sd - 12
        headView.text2.top_sd = headView.text1.top_sd
        headView.text2.textAlignment = .right
        headView.text2.height_sd = headView.text1.height_sd
        headView.iconbtn.removeFromSuperview()
        
        contentLab = UILabel.init(frame: CGRect.init(x: headView.text1.left_sd , y:F_I6(place: 40) , width: F_I6(place: 266), height:F_I6(place: 45)))
        contentLab.font = UIFont.systemFont(ofSize: 14)
        contentLab.textColor = UIColor.textColor1
        contentLab.isUserInteractionEnabled = false
        contentLab.numberOfLines = 2
        headView.addSubview(contentLab)
        
        viewBtn = UIButton.init(frame: CGRect.init(x: headView.text1.left_sd , y: F_I6(place: 85), width:F_I6(place: 60), height:F_I6(place: 20)))
        headView.addSubview(viewBtn)
        viewBtn.setImage(UIImage.init(named: "viewCount"), for: .normal)
        viewBtn.setTitleColor(UIColor.textColor2, for: .normal)
        viewBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        viewBtn.contentHorizontalAlignment = .left
        PLGlobalClass.setBtnStyle(viewBtn, style: .imageLeft, space: 2)
        viewBtn.isUserInteractionEnabled = false
        
        likeBtn = UIButton.init(frame: CGRect.init(x: viewBtn.right_sd , y: viewBtn.top_sd, width: F_I6(place: 60), height: viewBtn.height_sd))
        headView.addSubview(likeBtn)
        likeBtn.setImage(UIImage.init(named: "dyna_3_like"), for: .normal)
        likeBtn.setImage(UIImage.init(named: "like_brown_little"), for: .selected)
        
        likeBtn.setTitleColor(UIColor.textColor2, for: .normal)
        likeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        likeBtn.contentHorizontalAlignment = .left
        PLGlobalClass.setBtnStyle(likeBtn, style: .imageLeft, space: 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




//MARK: - ----------------企业秀model
class CompanyModel: KBaseModel {
    
    var img : String = ""    //封面图
    
    var gender : String = ""      //性别
    var headimg : String = ""     //头像
    var clubid : String = ""      //姓氏id
    var examine : String = ""
    var accountid : String = ""
    var isapp : Bool = false      //是否是从手机端发布
    
    /// 标题
    var title : String = ""
    /// 内容
    var context : String = ""
    //    /// 内容
    var conJSONObject : [TuwenModel]?
    
    //    var conJSONObject : Any?
    
    var id : String = "" //id
    
    var name : String = "" //公司名称
    
    /// 点赞数
    var praise : String = ""
    /// 点赞数
    var praisecount : NSInteger = 0
    /// 浏览数
    var viewcount : String = ""
    /// 评论数
    var commentcount : String = ""
    /// 分享数
    var sharecount : String = ""
    
    /// 创建日期
    var createtime : String = ""
    var updatetime : String = ""
    var status : String = ""
    var taccount : UserModel?
    
    //    var tAccount : Dictionary<String, Any>?
    
    override static func mj_objectClassInArray() -> [AnyHashable : Any]! {
        //        var conJSONObject : [TuwenModel]?
        return ["conJSONObject": TuwenModel.self]
        
    }
}

