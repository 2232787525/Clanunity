//
//  CULoginVC.swift
//  Clanunity
//
//  Created by 白bex on 2018/2/1.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

import UIKit
import MJRefresh

//MARK: - ----------------消息通知列表页
class NoticeList: BaseTabVC,UITableViewDataSource {
    
    var dynamicArr = [NoticeModel]()
    
    override lazy var emptyView: EmptySwiftView = {
        let tempView = EmptySwiftView.showEmptyView(emptyPicName: "empty_activity", describe: "暂无通知")
        tempView.centerX_sd = KScreenWidth/2.0
        return tempView
    }()
    
    override func kBackBtnAction() {
        if self.navigationController == nil{
            self.dismiss(animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.bgColor5
        self.knavigationBar?.title = "消息通知"
        tableView.separatorStyle = .none
        self.reloadTableViewWithNewData()
        emptyView.centerY_sd = tableView.height_sd/2 - 20
    }

    public func reloadTableViewWithNewData(){
        DispatchQueue.global().async { [weak self] in
//            let arr = NoticeModel.getData()

            let arr = NoticeModel.searchDataOrWhere(["type":1,"username":UserServre.shareService.userModel.username])
            if arr == nil{
            }else{
                self?.dynamicArr = (arr?.reversed())!
            }
            DispatchQueue.main.async {
                self?.checkIfNull()
            }
        }
    }
    
    func checkIfNull(){
        self.tableView.reloadData()
        self.tableView.mj_header.endRefreshing()
        if self.dynamicArr.count == 0{
            self.emptyShow(show: true)
        }else{
            self.emptyShow(show: false)
        }
    }
    
    override func emptyShow(show:Bool){
        if show{
            footerview.height_sd = tableView.height_sd
        }else{
            footerview.height_sd = 0
        }
    }
    
    //MARK: - tableView
    override func maketableView(){
        super.maketableView()
        tableView.height_sd = KScreenHeight-KTopHeight
        tableView.dataSource=self
    }
    
    //MARK: - tableView
    override func settableView(){
        self.tableView.backgroundColor = UIColor.bgColor5
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
        emptyView.top_sd = KScreenWidth/2-100
        footerview.clipsToBounds = true
        tableView.tableFooterView = footerview
        
        let mjheader = MJRefreshGifHeader.init {
            self.reloadTableViewWithNewData()
        }
        GlobalClass.setMjHeader(mjheader: mjheader!)
        tableView.mj_header = mjheader
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dynamicArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? NoticeCell
        if (!(cell != nil)){
            cell = NoticeCell.init(style: .default, reuseIdentifier: "cell")
        }
        cell?.model = self.dynamicArr[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return F_I6(place: 103)
        return NoticeCell.getCellHeigh(model: dynamicArr[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = self.dynamicArr[indexPath.row]
        if model.type == 2{
            
            self.showGifView()
            //请求详情
            ClanAPI.requestForDynamicInfo(dyid: model.id, result: {[weak self] (result) in
                self?.hiddenGifView()
                if (result.status == "200"){
                    
                    let infoVC = DynamicInfo.init()
                    infoVC.model = DynamicModel.mj_object(withKeyValues: result.data)
                    self?.navigationController?.pushViewController(infoVC, animated: true)
                }else{
                    WFHudView.showMsg(result.message, in: self?.view)
                }
            })
        }
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


//MARK: - ----------------同宗活动cell
class NoticeCell: UITableViewCell {
    
    /// 标题
    var titleLab = UILabel()
    /// 内容
    var contentLab = UILabel()
    /// 时间
    var timeLab = UILabel()
    var whiteView = UIView()
    
    var model : NoticeModel?{
        didSet {
            if model?.type == 2{
                titleLab.text = "动态消息"
            }else{
                titleLab.text = "系统消息"
            }
            contentLab.text = model?.alert
            
            contentLab.height_sd = NoticeCell.gettextHei(model: model!)
            whiteView.height_sd = contentLab.bottom_sd
            PLGlobalClass.paragraphForlabel(contentLab, lineSpace: 5)
            
            let date = PLGlobalClass.dateWithtimeStr(model!.date)
            let str = NSString.timeMdHHmm(with: date)
            timeLab.text = str
        }
    }
    
    class func gettextHei(model : NoticeModel)-> (CGFloat){
        return PLGlobalClass.getTextHeight(withStr: model.alert, labWidth: KScreenWidth - 12 * 2, fontSize:F_I6(place:13), numberLines: 0, lineSpacing: 5) + 10
    }
    
    class func getCellHeigh(model : NoticeModel) -> (CGFloat){
        return F_I6(place: 61) + self.gettextHei(model:model)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        timeLab = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height:F_I6(place: 31) ))
        timeLab.backgroundColor = UIColor.bgColor5
        timeLab.textAlignment = .center
        timeLab.font = UIFont.boldSystemFont(ofSize:F_I6(place:12))
        timeLab.textColor = UIColor.textColor2
        self.contentView.addSubview(timeLab)
        
        whiteView = UIView.init(frame: CGRect.init(x: 0, y: timeLab.bottom_sd, width: KScreenWidth, height: F_I6(place: 72)))
        whiteView.backgroundColor = UIColor.white
        self.contentView.addSubview(whiteView)
        
        titleLab = UILabel.init(frame: CGRect.init(x: 12, y: 0, width: KScreenWidth - 12 * 2, height:F_I6(place: 30)))
        titleLab.font = UIFont.boldSystemFont(ofSize:F_I6(place:15))
        titleLab.textColor = UIColor.textColor1
        titleLab.isUserInteractionEnabled = false
//        titleLab.numberOfLines = 1
        whiteView.addSubview(titleLab)
        
        contentLab = UILabel.init(frame: CGRect.init(x: 12, y: titleLab.bottom_sd, width: KScreenWidth - 12 * 2, height:F_I6(place: 42)))
        contentLab.font = UIFont.boldSystemFont(ofSize:F_I6(place:13))
        contentLab.textColor = UIColor.textColor2
        contentLab.numberOfLines = 0
        whiteView.addSubview(contentLab)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


