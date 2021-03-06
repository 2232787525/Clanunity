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
class AncestorsList: BaseTabVC,UITableViewDataSource {
    
    var ifZongci = false
    var shoupin = ""  //首拼
    var pinlunType = "4"  //


    var dynamicArr = [AncestorsModel]() //动态Arr
    override lazy var emptyView: EmptySwiftView = {

        let empty = EmptySwiftView.showEmptyView(emptyPicName: ImageDefault.emptyPlace2, describe: "此姓" + (self.knavigationBar?.title ?? "") + "暂未录入")
        empty.centerX_sd = KScreenWidth/2.0
        return empty
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GlobalClass.single_event(eventName: CUKey.UM_xsmr)
    }

    //MARK: - tableView
    override func maketableView(){
        super.maketableView()
        
        if pinlunType == "6"{

        }else{
            tableView.separatorStyle = .none
        }
        tableView.height_sd = KScreenHeight-KTopHeight
        self.tableView.dataSource=self
        emptyView.top_sd = KScreenHeight/2 - 150

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dynamicArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (ifZongci){
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? AncestorsCell
            if (!(cell != nil)){
                cell = AncestorsCell.init(style: .default, reuseIdentifier: "cell")
            }
            cell?.model = dynamicArr[indexPath.row]
            cell?.row = indexPath.row
            return cell!
        }else{
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? AncestorsCell2
            if (!(cell != nil)){
                cell = AncestorsCell2.init(style: .default, reuseIdentifier: "cell")
            }
            cell?.model = dynamicArr[indexPath.row]
            cell?.row = indexPath.row
            return cell!
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (ifZongci){
            return AncestorsCell.getCellHeigh(model: dynamicArr[indexPath.row])
        }else{
            return AncestorsCell2.getCellHeigh(model: dynamicArr[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let info = AncestorsInfo.init()
        info.model = self.dynamicArr[indexPath.row]
        info.pinlunType = self.pinlunType
        self.navigationController?.pushViewController(info, animated: true)
    }
    
    // MARK: - Https网络请求
    override func requestforList(){
        
        ClanAPI.requestForjsxz(name: shoupin, pagenum: pno, pagesize: pnu) {[weak self] (result) in
            self?.hiddenGifView()
            
            if self != nil{
                self?.tableView.mj_header.endRefreshing()
                self?.tableView.mj_footer.endRefreshing()
                
                if (result.status == "200"){
                    if ((result.data != nil) && (result.data is Dictionary<String,Any>)){
                        let dic = result.data as! Dictionary<String,Any>
                        
                        let resArr = AncestorsModel.mj_objectArray(withKeyValuesArray: dic["list"]) as! [AncestorsModel]
                        
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
                        }else{
                            if ( (self?.pno)! > 1){
                                self?.pno = (self?.pno)! - 1
                            }
                        }
                    }
                }else{
                    if self?.pno==1{
    //                    self?.dynamicArr.removeAll()
                        self?.tableView.mj_footer.isHidden = true
                    }
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
    
    override func emptyShow(show:Bool){
        if show{
            if APPDELEGATE.networkStatus == 0{
                emptyView.describeLabel?.text = "请检查您的网络"
            }else{
                emptyView.describeLabel?.text = "此姓" + (self.knavigationBar?.title ?? "") + "暂未录入"
            }
            footerview.height_sd = KScreenHeight/2 + 100
        }else{
            footerview.height_sd = 0
        }
    }
    
    func gotoPublicClick() {
        
        let publicVC = publicActivity.init()
        self.navigationController?.pushViewController(publicVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


//MARK: - ----------------线下宗祠cell
class AncestorsCell: UITableViewCell {
    
    var row = 0
    /// 标题
    var titleLab = UILabel()
    /// 标题
    var contentLab = UILabel()
    /// 图片1
    var imageV = UIImageView()
    
    var bottomLine = UIView()

    
    var model : AncestorsModel?{
        didSet {

            self.titleLab.text = model?.title
            self.contentLab.text = model?.intro
            self.contentLab.height_sd = AncestorsCell2.getcontentHeigh(model: model!)
            PLGlobalClass.paragraphForlabel(contentLab, lineSpace: 5)
            contentLab.lineBreakMode = .byTruncatingTail

            if (model?.themeimg.count ?? 0) > 0{
                let imgUrl = NSString.formatImageUrl(with: self.model?.themeimg, ifThumb: true, thumb_W: 0)
                self.imageV.sd_setImage(with: URL.init(string: imgUrl!), placeholderImage: UIImage.init(named: ImageDefault.imagePlace), options: .retryFailed)
                self.imageV.isHidden = false
                self.contentLab.top_sd = self.imageV.bottom_sd + 2
            }else{
                self.imageV.isHidden = true
                self.contentLab.top_sd = self.titleLab.bottom_sd + 2
            }
            bottomLine.bottom_sd = AncestorsCell.getCellHeigh(model: model!)
        }
    }
    
    class func getCellHeigh(model : AncestorsModel) -> (CGFloat){
        
        if (model.themeimg.count) > 0{
            return F_I6(place: 220) + AncestorsCell2.getcontentHeigh(model: model)
        }else{
            return F_I6(place:50) + AncestorsCell2.getcontentHeigh(model: model)
        }
    }
    
    class func getcontentHeigh(model : AncestorsModel) -> (CGFloat){
        
        var titleHei = 0.0
        if model.context.count>0{
            let size = PLGlobalClass.sizeForParagraph(withText: model.intro, weight: KScreenWidth - 24, fontSize: UIFont.systemFont(ofSize: 14).pointSize, lineSpacing: 5, numberline: 2)
            titleHei = Double(size.height)+10
        }
        return CGFloat(titleHei)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLab = UILabel.init(frame: CGRect.init(x: 12, y: F_I6(place: 15), width: KScreenWidth - 12 * 2, height:F_I6(place: 26)))
        titleLab.font = UIFont.boldSystemFont(ofSize: 16)
        titleLab.textColor = UIColor.textColor1
        titleLab.isUserInteractionEnabled = false
        titleLab.numberOfLines = 1
        self.contentView.addSubview(titleLab)
        
        imageV = UIImageView.init(frame: CGRect.init(x: titleLab.left_sd, y:titleLab.bottom_sd + F_I6(place: 10), width: F_I6(place: 350), height:F_I6(place: 160)))
        imageV.contentMode = .scaleAspectFill
        imageV.clipsToBounds = true
        self.contentView.addSubview(imageV)
        
        contentLab = UILabel.init(frame: CGRect.init(x: titleLab.left_sd, y: imageV.bottom_sd+F_I6(place: 2), width: titleLab.width_sd, height:F_I6(place: 26)))
        contentLab.font = UIFont.systemFont(ofSize: 14)
        contentLab.textColor = UIColor.textColor1
        contentLab.isUserInteractionEnabled = false
        contentLab.numberOfLines = 2
        self.contentView.addSubview(contentLab)
        
        bottomLine = self.addBottomLine(color: UIColor.cutLineColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



//MARK: - ----------------姓氏名人 姓氏源流cell
class AncestorsCell2: UITableViewCell {
    
    var row = 0

    /// 标题
    var titleLab = UILabel()
    
    /// 标题
    var contentLab = UILabel()
    
    /// 图片1
    var imageV = UIImageView()
    var bottomLine = UIView()

    var model : AncestorsModel?{
        didSet {
            
            if (model?.themeimg.count ?? 0) > 0{
                let imgUrl = NSString.formatImageUrl(with: self.model?.themeimg, ifThumb: true, thumb_W: 0)
                self.imageV.sd_setImage(with: URL.init(string: imgUrl!), placeholderImage: UIImage.init(named: ImageDefault.imagePlace), options: .retryFailed)
                self.imageV.isHidden = false
                self.titleLab.width_sd = KScreenWidth - 36 - F_I6(place: 75)
                self.contentLab.width_sd = self.titleLab.width_sd
            }else{
                self.titleLab.width_sd = KScreenWidth - 24
                self.contentLab.width_sd = self.titleLab.width_sd
                self.imageV.isHidden = true
            }
            //Lable加载html富文本
            //do {
            //    let attrString = try NSMutableAttributedString.init(data: (model?.context.data(using: String.Encoding.unicode))!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
            //    self.contentLab.attributedText = attrString;
            //
            //}catch{
            //    print(error)
            //}
            self.titleLab.text = model?.title
            self.contentLab.text = model?.intro
            self.contentLab.height_sd = AncestorsCell2.getcontentHeigh(model: model!)
            PLGlobalClass.paragraphForlabel(contentLab, lineSpace: 5)
            contentLab.lineBreakMode = .byTruncatingTail
            
            bottomLine.bottom_sd = AncestorsCell2.getCellHeigh(model: model!)
        }
    }
    
    class func getCellHeigh(model : AncestorsModel) -> (CGFloat){
        if (model.themeimg.count) > 0{
            return F_I6(place: 103)
        }else{
            return F_I6(place:50) + AncestorsCell2.getcontentHeigh(model: model)
        }
    }
    
    class func getcontentHeigh(model : AncestorsModel) -> (CGFloat){
        
        var width = KScreenWidth - 24
        if (model.themeimg.count) > 0{
            width = KScreenWidth - 36 - F_I6(place: 75)
        }else{
            width = KScreenWidth - 24
        }
        
        var titleHei = 0.0
        if model.context.count>0{
            let size = PLGlobalClass.sizeForParagraph(withText: model.intro, weight: width, fontSize: UIFont.systemFont(ofSize: 14).pointSize, lineSpacing: 5, numberline: 2)
            titleHei = Double(size.height)+10
        }
        return CGFloat(titleHei)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLab = UILabel.init(frame: CGRect.init(x: 12, y: F_I6(place: 15), width: KScreenWidth - 12 * 2, height:F_I6(place: 26)))
        titleLab.font = UIFont.boldSystemFont(ofSize: 16)
        titleLab.textColor = UIColor.textColor1
        titleLab.isUserInteractionEnabled = false
        titleLab.numberOfLines = 1
        self.contentView.addSubview(titleLab)
        
        contentLab = UILabel.init(frame: CGRect.init(x: titleLab.left_sd, y: titleLab.bottom_sd+F_I6(place: 2), width: titleLab.left_sd, height:F_I6(place: 26)))
        contentLab.font = UIFont.systemFont(ofSize: 14)
        contentLab.textColor = UIColor.textColor1
        contentLab.isUserInteractionEnabled = false
        contentLab.numberOfLines = 2
        self.contentView.addSubview(contentLab)
        
        imageV = UIImageView.init(frame: CGRect.init(x: F_I6(place: 286), y: F_I6(place: 10), width: F_I6(place: 75), height:F_I6(place: 87)))
        imageV.contentMode = .scaleAspectFill
        imageV.clipsToBounds = true
        self.contentView.addSubview(imageV)
        bottomLine = self.addBottomLine(color: UIColor.cutLineColor)
        bottomLine.left_sd = 12
        bottomLine.width_sd = KScreenWidth-24
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



//MARK: - ----------------宗亲动态model
class AncestorsModel: KBaseModel {
    
    /// 创建日期
    var createtime : String = ""
    var themeimg : String = ""    //封面图
    var clubName : String = "" //姓名
    var club : String = ""      //姓
    var context : String = ""      //富文本
    /// 浏览数
    var viewcount : NSInteger = 0
    /// 点赞数
    var praisecount : NSInteger = 0
    var id : String = "" //id
    var state : String = ""
    var title : String = ""
    var type : String = ""
    var intro : String = "" //简介 去掉h5样式后

    //    override static func mj_objectClassInArray() -> [AnyHashable : Any]! {
    //        return ["imgs": String.self]
    ////        return ["imgs": imgModel.self]
    //    }
}
