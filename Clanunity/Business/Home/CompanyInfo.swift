

//MARK: - ----------------企业秀详情页
class CompanyInfo: CommentTabVC {

    var model : CompanyModel?
    var headerView : CompanyInfoView?
    var pinlun = UIButton()
    var player : XLVideoPlayer?
    var bottomView : UIView?
    
    override func viewDidDisappear(_ animated: Bool) {
        self.playerDestroy()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pinlunType = "7"
        self.infoId = self.model?.id
        
        self.requestforList()
        
        self.knavigationBar?.title = "详细内容"
        self.knavigationBar?.rightBarBtnItem = KNaviBarBtnItem.init(frame:  CGRect.init(x: 0, y: KStatusBarHeight, width: 44, height: 44), image: "share_white", hander: {  [weak self](sender) in
            self?.toShare()
        })
        
        pinlun = UIButton.init(frame: CGRect.init(x: 0, y: KScreenHeight-F_I6(place: 49), width: KScreenWidth, height: F_I6(place: 49)))
        pinlun.setBackgroundImage(UIImage.init(named: "pinglun_bg"), for: .normal)
        pinlun.backgroundColor = UIColor.white
        self.view.addSubview(pinlun)
        
        pinlun.handleEventTouchUpInside {[weak self] in
            self?.requestForcomment()
        }
    }
    
    //MARK: - tableView
    override func maketableView(){
        
        super.maketableView()
        
        self.headerView = CompanyInfoView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: CompanyInfoView.getViewHeight()))
        headerView?.model = self.model
        self.tableView.tableHeaderView = self.headerView
        
//        self.requestForActivityInfo()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            if self.model?.isapp == true{
                return model?.conJSONObject?.count ?? 0
            }
            return 1
        }
        if section == 1{
            return 1
        }
        return dynamicArr[section-2].children.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0{

            var cell = tableView.dequeueReusableCell(withIdentifier: "Infocell") as? TuwenInfoCell
            if (cell == nil){
                cell = TuwenInfoCell.init(style: .default, reuseIdentifier: "Infocell")
                cell?.contentTextView.layer.borderColor = UIColor.clear.cgColor
                cell?.contentTextView.isUserInteractionEnabled = false
            }

            DispatchQueue.main.async {
                for view in (cell?.contentView.subviews)! {
                    if (view is XLVideoPlayer ) {
                        let player = view as! XLVideoPlayer
                        player.destroyPlayer()
                    }
                }
            }

            cell?.playBtn.handleEventTouchUpInside(callback: {[weak self , weak cell] in
                //点击cell的播放按钮播放
                self?.cellPlay(cell: cell!)
            })

            if self.model?.isapp == true{
                cell?.reloadCell(model: (model?.conJSONObject![indexPath.row])!)
            }else{
                cell?.reloadCell(str: (model?.context)!)
            }
            cell?.selectionStyle = .none
            return cell!

        }
        if indexPath.section == 1{

            var cell = tableView.dequeueReusableCell(withIdentifier: "titlecell")
            if (cell == nil){
                cell = UITableViewCell.init(style: .default, reuseIdentifier: "titlecell")

                bottomView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: F_I6(place: 55)))
                bottomView?.backgroundColor = UIColor.white

                let fengeView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: F_I6(place: 5)))
                fengeView.backgroundColor = UIColor.bgColor5
                bottomView?.addSubview(fengeView)
                
                let pinglunLab = UILabel.init(frame: CGRect.init(x: 12, y: fengeView.bottom_sd, width: KScreenWidth-12*2, height: F_I6(place: 50)))
                pinglunLab.text = "最新评论"
                pinglunLab.font = UIFont.boldSystemFont(ofSize: 18)
                bottomView?.addSubview(pinglunLab)

                let line = UIView.init(frame: CGRect.init(x: pinglunLab.left_sd, y: (bottomView?.height_sd)!-0.5, width: pinglunLab.width_sd, height: 0.5))
                line.backgroundColor = UIColor.cutLineColor
                bottomView?.addSubview(line)
                cell?.contentView.addSubview(bottomView!)
            }
            return cell!
        }
        else{
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            if (cell == nil){
                cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")

                let replyView = commentreplyView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 0))
                replyView.tag = 200
                cell?.contentView.addSubview(replyView)
            }

            let replyView = cell?.contentView.viewWithTag(200) as? commentreplyView
            replyView?.model = dynamicArr[indexPath.section-2].children[indexPath.row]
            return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            if self.model?.isapp == true{
                return TuwenCell.getCellHeigh(model: (model?.conJSONObject![indexPath.row])!)
            }else{
                return TuwenInfoCell.getTextViewHei(text: model?.context ?? "")
            }
        }
        if indexPath.section == 1{
            return F_I6(place: 55)
        }
        return commentreplyView.gettextHeigh(model: dynamicArr[indexPath.section-2].children[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0.01
        }
        if section == 1{
            return 0.01
        }
        return commentheaderView.getCellHeigh(model : dynamicArr[section-2])
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0{
            return F_I6(place: 44)
        }
        return 0.01
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dynamicArr.count + 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            return UIView.init()
        }
        if section == 1{
            return UIView.init()
        }
        
        let str = "header"
        let model = self.dynamicArr[section-2]
        
        var headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: str)
        if headerView == nil{
            headerView = UITableViewHeaderFooterView.init(reuseIdentifier: str)
            let userView = commentheaderView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: commentheaderView.getCellHeigh(model : model)))
            userView.tag = 100
            userView.likeBtn.isHidden = true
            headerView?.contentView.addSubview(userView)
        }
        
        let userView = headerView?.contentView.viewWithTag(100) as? commentheaderView
        userView?.model = dynamicArr[section-2]
        
        userView?.userView.iconbtn.handleEventTouchUpInside(callback: {[weak self] in
            self?.requestforSubmitComment(model: (self?.dynamicArr[section-2])!, sectionmodel: (self?.dynamicArr[section-2])!, isRow: false)
        })
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0{
            let footerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: F_I6(place: 44)))
            footerView.backgroundColor = UIColor.white
            
            headerView?.viewBtn.top_sd = F_I6(place: 10)
            headerView?.likeBtn.top_sd = F_I6(place: 10)
            
            headerView?.viewBtn.left_sd = F_I6(place: 12)
            headerView?.likeBtn.left_sd = (headerView?.viewBtn.right_sd)!

            footerView.addSubview((headerView?.viewBtn)!)
            footerView.addSubview((headerView?.likeBtn)!)
            
            return footerView
        }
        return UIView.init()
    }
    
    //TODO:企业秀详情数据
    func requestForActivityInfo(){
        if  self.model?.id.count == 0{
            return
        }
        ClanAPI.requestForActivityInfo(actid: (self.model?.id)!) {[weak self] (result) in
            if (result.status == "200"){
                if ((result.data != nil) && (result.data is Dictionary<String,Any>)){
                    //刷新详情数据
                    self?.model =
                        CompanyModel.mj_object(withKeyValues: result.data)
                }
            }
        }
    }

    override func scrollToComment(){
        let sectionView = self.tableView.headerView(forSection: 2)
        if sectionView != nil{
            self.tableView.scrollRectToVisible((sectionView?.frame)!, animated: true)
        }else if(self.model?.conJSONObject?.count ?? 0 > 0){
            tableView.scrollToRow(at: IndexPath.init(row: 0, section: 1), at: UITableViewScrollPosition.top, animated: true)
        }else{
            //滑到底部
        }
    }
    
    // MARK: - 分享
    override func toShare() {
        self.shareTitle = self.model?.title
        self.shareUrl = ClanAPI.H5UserName + ClanAPI.H5Share_qiYe + (self.model?.id ?? "")
        self.shareImgUrl = NSString.formatImageUrl(with: model?.img, ifThumb: false, thumb_W: 0)
        
        PLShareGlobalView.toShare(sharetype : "2", targetid : (self.model?.id)!,  shareTitle: self.shareTitle, shareUrl: self.shareUrl, shareImgUrl: self.shareImgUrl, shareDes: "来自同宗汇", shareimg: nil)
    }
    
    // MARK: - 功能
    func cellPlay(cell : TuwenInfoCell){
        
        if(cell.model?.content.count == 0){
            WFHudView.showMsg("视频找不到了哦\n 看看其他吧", in: self.view)
            return;
        }
        
        self.playerDestroy()
        
        player = XLVideoPlayer.init()
        player?.completedPlayingBlock = {[weak self] (player) -> () in
            self?.playerDestroy()
        }
        
        player?.videoUrl = NSURL.init(string:  NSString.formatImageUrl(with: cell.model?.content, ifThumb: false, thumb_W: 0))! as URL
        
        player?.superV = cell.contentView

        player?.frame = cell.contentImg.bounds
        player?.player.play()
        
        player?.ifverticalScreen = false
        //在cell上加载播放器
        cell.contentView.addSubview(player!)
        
        player?.left_sd = cell.contentImg.left_sd;
        player?.top_sd = cell.contentImg.top_sd;
    }
    
    func playerDestroy() {
        if (player != nil){
            player?.destroyPlayer()
            player = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


//MARK: - ----------------企业秀详情headerView
class CompanyInfoView: CompanyView {
    var text3 = UILabel()
    
    override var model : CompanyModel?{
        didSet {
            super.model = model
            
            let imgUrl = NSString.formatImageUrl(with: model?.taccount?.headimg, ifThumb: false, thumb_W: 0)
            headView.leftImageView.sd_setImage(with: URL.init(string: imgUrl!), placeholderImage: UIImage.init(named: ImageDefault.headerPlace), options: .retryFailed)

            contentLab.text = model?.taccount?.nickname ?? ""
            
            text3.text = model?.name ?? ""
            
            contentLab.sizeToFit()
            
            text3.sizeToFit()
            
            contentLab.centerY_sd = headView.leftImageView.centerY_sd
            
            headView.text2.centerY_sd = headView.leftImageView.centerY_sd
            
            text3.centerY_sd = headView.leftImageView.centerY_sd
            
            text3.left_sd = contentLab.right_sd + 10
            
            headView.text2.left_sd = text3.right_sd + 10
        }
    }
    
    class func getViewHeight()->(CGFloat){
        return F_I6(place: 70)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        headView.height_sd = frame.size.height
        
        headView.text1.left_sd = 12
        headView.text1.width_sd = KScreenWidth - 24

        headView.leftImageView.bounds = CGRect.init(x: 0, y: 0, width: F_I6(place: 20), height: F_I6(place: 20))
        headView.leftImageView.layer.cornerRadius = F_I6(place: 10)
        headView.leftImageView.clipsToBounds = true

        headView.leftImageView.top_sd = headView.text1.bottom_sd + F_I6(place: 5)
        headView.leftImageView.left_sd = headView.text1.left_sd

        text3 = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 12))
        text3.left_sd = headView.leftImageView.right_sd + F_I6(place: 6)
        text3.numberOfLines = 1
        text3.textColor = UIColor.baseColor
        text3.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(text3)
        
        contentLab.left_sd = headView.leftImageView.right_sd + F_I6(place: 6)
        contentLab.width_sd = F_I6(place: 150)
        contentLab.numberOfLines = 1
        contentLab.textColor = UIColor.textColor2
        contentLab.font = UIFont.systemFont(ofSize: 12)
        
        headView.text2.left_sd = contentLab.right_sd
        headView.text2.centerY_sd = contentLab.centerY_sd
        headView.text2.textAlignment = .left
        headView.text2.font = UIFont.systemFont(ofSize: 12)
        
        likeBtn.removeFromSuperview()
        viewBtn.removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - ---------------详情图文cell
class TuwenInfoCell: TuwenCell {
    
    var contentLab = UILabel()
    var contextView = UITextView()

    
    override func reloadCell(model : TuwenModel){
        super.reloadCell(model: model)
        contextView.isHidden = true
        
        if model.type == "0"{
            contentLab.text = model.content
            PLGlobalClass.paragraphForlabel(contentLab, lineSpace: 5)
            contentLab.lineBreakMode = .byTruncatingTail

            contentLab.height_sd = TuwenCell.gettextHeigh(text: model.content)
        }else{
            contentLab.text = ""
        }
    }
    
    func reloadCell(str : String){
        contentLab.isHidden = true
        contentImg.isHidden = true
        ImgDeleBtn.isHidden = true

        //Lable加载html富文本
        do {
            let attrString = try NSMutableAttributedString.init(data: (str.data(using: String.Encoding.unicode))!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
            self.contextView.attributedText = attrString;
            self.contextView.height_sd = TuwenInfoCell.getTextViewHei(text: str)
        }catch{
        }
    }
    
    class func getTextViewHei(text : String) -> (CGFloat){
        let contextView = UITextView.init(frame: CGRect.init(x: 12, y: 10, width: KScreenWidth-24, height: F_I6(place: 100)))
        contextView.font = UIFont.systemFont(ofSize: 14)
        
        //Lable加载html富文本
        do {
            let attrString = try NSMutableAttributedString.init(data: (text.data(using: String.Encoding.unicode))!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
            contextView.attributedText = attrString;
            
        }catch{
        }
        return contextView.contentSize.height
    }
    
    override class func gettextHeigh(text : String) -> (CGFloat){
        
        return PLGlobalClass.getTextHeight(withStr: text, labWidth: KScreenWidth - 12 * 2, fontSize: 14, numberLines: 0, lineSpacing: 5)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentTextView.removeFromSuperview()
        
        contentLab = UILabel.init(frame: CGRect.init(x: 12, y: 10, width: KScreenWidth-24, height: F_I6(place: 100)))
        contentLab.font = UIFont.systemFont(ofSize: 14)
        contentLab.textColor = UIColor.textColor1
        contentLab.numberOfLines = 0
        self.contentView.addSubview(contentLab)
        
        contextView = UITextView.init(frame: CGRect.init(x: 12, y: 10, width: KScreenWidth-24, height: F_I6(place: 100)))
        contextView.font = UIFont.systemFont(ofSize: 14)
        contextView.textColor = UIColor.textColor1
        contextView.isUserInteractionEnabled = false
        self.contentView.addSubview(contextView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



