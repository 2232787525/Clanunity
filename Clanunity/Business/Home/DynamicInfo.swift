import UIKit
import MJRefresh
//import SDWebImage

//MARK: - ----------------同宗动态详情页
class DynamicInfo: CommentTabVC {
    
    var ifCollect = false //是否是从我的收藏点进来
    var lastVC : PersonalVC? //我的收藏页面 用于返回时刷新上个页面
    var lastVC2 : FirstViewController? //我的收藏页面 用于返回时刷新上个页面

    
    var model : DynamicModel?
    var dynaid = ""
    var headerView : DynaInfoView?
    
    var zanBtn = UIButton()
    var talkBtn = UIButton()
    var shoucangBtn = UIButton()
    var player : XLVideoPlayer?

    
    override func viewDidDisappear(_ animated: Bool) {
        self.playerDestroy()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.knavigationBar?.title = "详情"
        self.pinlunType = "2"
        
        self.creatView()
    }
    
    func creatView(){
        
        self.infoId = self.model?.id
        
        self.requestforList()
        
        let Hei = F_I6(place: 50) + KBottomStatusH/2
        
        shoucangBtn = UIButton.init(frame: CGRect.init(x: 0, y: KScreenHeight-Hei, width: KScreenWidth/3, height: Hei))
        shoucangBtn.setTitle("收藏", for: .normal)
        shoucangBtn.backgroundColor = UIColor.baseColor
        shoucangBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        shoucangBtn.setImage(UIImage.init(named: "shoucang"), for: .normal)
        shoucangBtn.setImage(UIImage.init(named: "shoucang_selected"), for: .selected)
        
        self.view.addSubview(shoucangBtn)
        if model?.collect == "1"{
            shoucangBtn.isSelected = true
        }else{
            shoucangBtn.isSelected = false
        }
        
        talkBtn = UIButton.init(frame: CGRect.init(x: KScreenWidth/3, y: KScreenHeight-Hei, width: KScreenWidth/3, height: Hei))
        talkBtn.setTitle("评论", for: .normal)
        talkBtn.backgroundColor = UIColor.baseColor
        talkBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        talkBtn.setImage(UIImage.init(named: "talk_white"), for: .normal)
        self.view.addSubview(talkBtn)
        
        zanBtn = UIButton.init(frame: CGRect.init(x: KScreenWidth/3*2, y: KScreenHeight-Hei, width: KScreenWidth/3, height: Hei))
        zanBtn.setTitle("赞", for: .normal)
        zanBtn.setImage(UIImage.init(named: "like_white"), for: .normal)
        zanBtn.setImage(UIImage.init(named: "like_selected"), for: .selected)
        zanBtn.backgroundColor = UIColor.baseColor
        zanBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.view.addSubview(zanBtn)
        if model?.praise == "1"{
            zanBtn.isSelected = true
        }else{
            zanBtn.isSelected = false
        }
        
        
        PLGlobalClass.setBtnStyle(shoucangBtn, style: .imageLeft, space: 5)
        PLGlobalClass.setBtnStyle(talkBtn, style: .imageLeft, space: 5)
        PLGlobalClass.setBtnStyle(zanBtn, style: .imageLeft, space: 5)
        
        let line = UIView.init(frame: CGRect.init(x: KScreenWidth/3, y: talkBtn.top_sd + F_I6(place: 5), width: 1, height: Hei - F_I6(place: 10)))
        line.backgroundColor = UIColor.lineColor3
        self.view.addSubview(line)
        
        let line2 = UIView.init(frame: CGRect.init(x: KScreenWidth/3*2, y: talkBtn.top_sd + F_I6(place: 5), width: 1, height: Hei - F_I6(place: 10)))
        line2.backgroundColor = UIColor.lineColor3
        self.view.addSubview(line2)
        
        shoucangBtn.handleEventTouchUpInside {[weak self] in
            if (self?.shoucangBtn.isSelected)!{
                ClanAPI.requestForCancelcollect(targetid: (self?.model?.id)!, targettype: "2", result: { (result) in
                    if (result.status == "200"){
                        WFHudView.showMsg("取消收藏", in: self?.view)
                        self?.model?.collect = "0"
                        self?.shoucangBtn.isSelected = false
                        self?.lastVC?.collectDele = self?.model
                    }else{
                        WFHudView.showMsg(result.message ?? "取消收藏失败", in: self?.view)
                    }
                })
            }else{
                ClanAPI.requestForSubmitcollect(targetid: (self?.model?.id)!, targettype: "2", result: { (result) in
                    if (result.status == "200"){
                        WFHudView.showMsg("已收藏", in: self?.view)
                        self?.lastVC?.collectDele = nil
                        self?.model?.collect = "1"
                        self?.shoucangBtn.isSelected = true
                    }else{
                        WFHudView.showMsg(result.message ?? "收藏失败", in: self?.view)
                    }
                })
            }
        }
        
        
        talkBtn.handleEventTouchUpInside {
            self.requestForcomment()
        }
        
        zanBtn.handleEventTouchUpInside {[weak self] in
            if (self?.zanBtn.isSelected)!{
                ClanAPI.requestForCancelpraise(targetid: (self?.model?.id)!, targettype: "2", result: { (result) in
                    if (result.status == "200"){
                        self?.model?.praise = "0"
                        WFHudView.showMsg("点赞取消", in: self?.view)
                        self?.zanBtn.isSelected = false
                        if((self?.model?.praisecount ?? 0) > 0){
                            self?.model?.praisecount =  (self?.model?.praisecount)! - 1
                        }
                        self?.lastVC2?.tableView.reloadData()
                    }else{
                        WFHudView.showMsg(result.message ?? "点赞取消失败", in: self?.view)
                    }
                })
            }else{
                ClanAPI.requestForSubmitpraise(targetid: (self?.model?.id)!, targettype: "2", result: { (result) in
                    if (result.status == "200"){
                        self?.model?.praise = "1"
                        WFHudView.showMsg("点赞成功", in: self?.view)
                        self?.zanBtn.isSelected = true
                        self?.model?.praisecount =  (self?.model?.praisecount ?? 0) + 1
                        self?.lastVC2?.tableView.reloadData()

                    }else{
                        WFHudView.showMsg(result.message ?? "点赞失败", in: self?.view)
                    }
                })
            }
        }
    }
    
    //MARK: - tableView
    override func maketableView(){
        super.maketableView()
        
        headerView = DynaInfoView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: DynaInfoView.getViewHeigh(model: model!, numofLines: 0) + 10))
        headerView?.playBtn.handleEventTouchUpInside(callback: {
            self.cellPlay()
        })
        
        let gestap = UITapGestureRecognizer.bk_recognizer {[weak self] (_, _, _) in
            
            if self?.model?.username == UserServre.shareService.userModel.username{
                let vc = MyInfoVC.init()
                self?.navigationController?.pushViewController(vc, animated: true)
            }else{
                let vc = StrangerOrFriendVC.init()
                vc.username = self?.model?.username
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        headerView?.header.isUserInteractionEnabled = true
        headerView?.header.addGestureRecognizer(gestap as! UIGestureRecognizer)
        
        headerView?.model = model
        tableView.tableHeaderView = headerView
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
    
    // MARK: - 功能
    func cellPlay(){
        
        if(self.model?.attachpath.count == 0 && self.model?.imgs.count == 0){
            WFHudView.showMsg("视频找不到了哦\n 看看其他吧", in: self.view)
            return;
        }
        
        self.playerDestroy()
        
        player = XLVideoPlayer.init()
        
        player?.completedPlayingBlock = { (player) -> () in
            self.playerDestroy()
        }
        
        if self.model?.attachpath.count ?? 0 > 0{
            player?.videoUrl = NSURL.init(string:  NSString.formatImageUrl(with: self.model?.attachpath, ifThumb: false, thumb_W: 0))! as URL
        }else{
            player?.videoUrl = NSURL.init(string:  NSString.formatImageUrl(with: self.model?.imgs[0], ifThumb: false, thumb_W: 0))! as URL
        }

        player?.frame = (headerView?.image1.frame)!

        player?.player.play()
        player?.superV = headerView
        //在cell上加载播放器
        headerView?.addSubview(player!)
        
        if (player?.height_sd ?? 0) > (player?.width_sd ?? 0){
            player?.ifverticalScreen = true
        }else{
            player?.ifverticalScreen = false
        }
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



//MARK: - ----------------宗亲动态View（详情）
class DynaInfoView: UIView {
    
    var row = 0
    /// 播放按钮
    var playBtn = UIButton()
    /// 发布时间
    var time = UILabel()
    /// 发布者
    var name = UILabel()
    /// 头像
    var header = UIImageView()
    /// 标题
    var biaotiL = UILabel()
    /// 内容
    var titleL = UILabel()
    /// 图片1
    var image1 = UIImageView()
    /// 图片2
    var image2 = UIImageView()
    /// 图片3
    var image3 = UIImageView()
    /// 置顶图标或性别图标
    var gender = UIButton()
    
    var model : DynamicModel?{
        didSet {
            self.playBtn.isHidden = true
            self.image3.isHidden = true
            self.gender.isHidden = true

            self.biaotiL.text = model?.title
            self.biaotiL.height_sd = DynaInfoView.getBiaotiHeigh(model: model!)
            PLGlobalClass.paragraphForlabel(self.biaotiL, lineSpace: 5)
            
            if model!.title.count > 0{
                self.titleL.top_sd = self.biaotiL.bottom_sd + 15
            }else{
                self.titleL.top_sd = header.bottom_sd + 15
            }
            
            if model?.nickname.count ?? 0 > 0{
                self.name.text = model!.nickname
            }else{
                self.name.text = (model?.clubname ?? "") + (model?.realname ?? "")
            }
            
            let date = PLGlobalClass.dateWithtimeStr(model?.created)
            self.time.text = PLGlobalClass.dynamicFormatString(with: date)

            self.titleL.text = model?.content

            self.header.sd_setImage(with: URL.init(string: NSString.formatImageUrl(with: model?.headimg, ifThumb: true, thumb_W: 80)), placeholderImage: UIImage.init(named: ImageDefault.headerPlace), options: .retryFailed)
            
            self.titleL.height_sd = DynaInfoView.getTextHeigh(model: model!, numofLines: 0)
            PLGlobalClass.paragraphForlabel(self.titleL, lineSpace: 5)
            titleL.lineBreakMode = .byTruncatingTail

            if model?.mediatype=="4"{//视频

                self.image1.isHidden = false
                self.image2.isHidden = true
                
                self.playBtn.isHidden = false

                
                let imageModel = String.getImageSize(urlStr: (model?.videoimg ?? ""))
                if imageModel != nil{
                    self.image1.height_sd = (imageModel?.heigh)! * (KScreenWidth - 24) / (imageModel?.width)!
                }else{
                    //没有宽高信息 按宽图处理
                    self.image1.height_sd = F_I6(place: 157)
                }
                
                self.image1.sd_setImage(with: URL.init(string: NSString.formatImageUrl(with: (model?.videoimg ?? ""), ifThumb: false, thumb_W: 0)), placeholderImage: UIImage.init(named: ImageDefault.imagePlace), options: .retryFailed)
                
                self.playBtn.center = self.image1.center

                self.image1.width_sd = KScreenWidth - 24
            
            }else if model?.mediatype=="2"{//单图
                self.image1.isHidden = false
                self.image2.isHidden = true
                self.image1.isUserInteractionEnabled = true
                
                if model?.imgs.count ?? 0 > 0{
                    let imgUrl = NSString.formatImageUrl(with: model?.imgs[0], ifThumb: true, thumb_W: 0)
                    
                    
                    let imageModel = String.getImageSize(urlStr: (model?.imgs[0])!)
                    if imageModel != nil{
                        image1.height_sd = (imageModel?.heigh)! * (KScreenWidth - 24) / (imageModel?.width)!
                    }else{
                        //没有宽高信息 按宽图处理
                        image1.height_sd = F_I6(place: 157)
                    }
                    
                    self.image1.sd_setImage(with: URL.init(string: imgUrl!), placeholderImage: UIImage.init(named: ImageDefault.imagePlace), options: .retryFailed)
                    self.image1.width_sd = KScreenWidth - 24

                    self.image1.width_sd = KScreenWidth - 24
                    
                    let tap = UITapGestureRecognizer.bk_recognizer(handler: {[weak self] (tap, state, point) in
                        PLGlobalClass.imgTapClicked(0, imageArr: [(self?.model?.imgs[0])!])
                    })
                    image1.addGestureRecognizer(tap as! UIGestureRecognizer)
                }else{
                    self.image1.height_sd = 0
                }
                
            }else if model?.mediatype=="3"{//多图
                self.image1.isHidden = true
                self.image2.isHidden = true
            
                let H = F_I6(place: 99)
                let W = F_I6(place: 114)
                let toTop = titleL.bottom_sd + 20
                let toLeft = (header.left_sd)
                let HAndBew = H + F_I6(place: 5)
                let WAndBew = W + F_I6(place:  5)
                
                if (model?.imgs.count ?? 0) > 0{
                    for index in 0 ... (model?.imgs.count)!-1{
                        
                        let X = CGFloat(index%3) * WAndBew + toLeft
                        let Y = CGFloat(index/3) * HAndBew + toTop
                        
                        let image = UIImageView.init(frame: CGRect.init(x:X, y: Y, width: W, height:H))
                        image.contentMode = .scaleAspectFill
                        image.clipsToBounds = true
                        self.addSubview(image)
                        image.tag = index
                        image.isUserInteractionEnabled = true
                        
                        let imgUrl = NSString.formatImageUrl(with: model?.imgs[index], ifThumb: true, thumb_W: 150)
                        image.sd_setImage(with: URL.init(string: imgUrl!), placeholderImage: UIImage.init(named: ImageDefault.imagePlace), options: .retryFailed)
                        
                        
                        let tap = UITapGestureRecognizer.bk_recognizer(handler: {[weak self] (tap, state, point) in
                            PLGlobalClass.imgTapClicked(index, imageArr: self?.model?.imgs)
                        })
                        image.addGestureRecognizer(tap as! UIGestureRecognizer)
                    }
                }
                
            }else{//无图
                self.image1.isHidden = true
                self.image2.isHidden = true
            }
            
            if model?.mediatype=="1"{//无图
            }else{
                self.image1.top_sd = self.titleL.bottom_sd + 20
                self.image2.top_sd = self.image1.top_sd
                
                if model?.mediatype == "4"{
                    self.playBtn.center = self.image1.center
                }
            }
        }
    }
    
    //详情的高度
    class func getViewHeigh(model : DynamicModel , numofLines : NSInteger) -> (CGFloat){
        
        let titleHei = DynaInfoView.getTextHeigh(model: model ,numofLines: numofLines)
        var biaotiHei = DynaInfoView.getBiaotiHeigh(model: model)
        if biaotiHei > 0{
            biaotiHei = biaotiHei + 15
        }
        var imgHei = CGFloat(0)
        
        let baseHei = F_I6(place: 31 ) + 25 + 10 + 43 + CGFloat(titleHei) + biaotiHei

        
        if model.mediatype=="4"{//视频
            
            let imageModel = String.getImageSize(urlStr: (model.videoimg ))
            if imageModel != nil{
                imgHei = (imageModel?.heigh)! * (KScreenWidth - 24) / (imageModel?.width)!
            }else{//没有宽高信息 按宽图处理
                imgHei = F_I6(place: 157)
            }
            return baseHei +  imgHei + 10
        
        }else if model.mediatype=="2"{//单图
            
            if model.imgs.count > 0{
                let imageModel = String.getImageSize(urlStr: (model.imgs[0]))
                if imageModel != nil{
                    imgHei = (imageModel?.heigh)! * (KScreenWidth - 24) / (imageModel?.width)!
                }else{//没有宽高信息 按宽图处理
                    imgHei = F_I6(place: 157)
                }
                return baseHei +  imgHei + 10
            }else{
                return baseHei
            }
        }else if model.mediatype=="3"{//多图
            if (model.imgs.count%3 > 0){
                return baseHei + 5 + CGFloat(model.imgs.count/3 + 1)*F_I6(place: 104) + 5
            }else{
                return baseHei + CGFloat(model.imgs.count/3)*F_I6(place: 104) + 5
            }
        }else{//无图
            return baseHei
        }
    }
    
    class func getTextHeigh(model : DynamicModel , numofLines : NSInteger) -> (CGFloat){
        return PLGlobalClass.getTextHeight(withStr: model.content, labWidth: KScreenWidth - 12 * 2, fontSize: 16, numberLines: numofLines, lineSpacing: 5)
    }
    
    
    class func getBiaotiHeigh(model : DynamicModel ) -> (CGFloat){
        return PLGlobalClass.getTextHeight(withStr: model.title, labWidth: KScreenWidth - 12 * 2, fontSize: 18, numberLines: 0, lineSpacing: 5)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        header = UIImageView.init(frame: CGRect.init(x: 12, y: F_I6(place: 20), width: 43 , height:43))
        header.layer.cornerRadius = 2
        header.clipsToBounds = true
        header.layer.borderWidth = 0.5
        header.layer.borderColor = UIColor.cutLineColor.cgColor
        self.addSubview(header)
        
        name = UILabel.init(frame: CGRect.init(x: header.right_sd + 10, y: header.top_sd + F_I6(place: 2), width: 50, height: header.height_sd/2))
        name.font = UIFont.systemFont(ofSize: 15)
        name.textColor = UIColor.textColor1
        self.addSubview(name)
        
        gender = UIButton.init(frame: CGRect.init(x: 12, y: 12, width:  17 , height:12))
        gender.setImage(UIImage.init(named: "gender_man"), for: .normal)
        self.addSubview(gender)
        gender.centerY_sd = name.centerY_sd
        
        time = UILabel.init(frame: CGRect.init(x: name.left_sd, y: name.bottom_sd + F_I6(place: 5), width: 200, height: F_I6(place: 15)))
        time.font = UIFont.systemFont(ofSize: 12)
        time.textColor = UIColor.textColor2
        self.addSubview(time)
        
        biaotiL = UILabel.init(frame: CGRect.init(x: header.left_sd, y: header.bottom_sd+F_I6(place: 25), width: KScreenWidth - header.left_sd * 2, height:F_I6(place: 40)))
        biaotiL.font = UIFont.boldSystemFont(ofSize: 18)
        biaotiL.textColor = UIColor.textColor1
        biaotiL.isUserInteractionEnabled = false
        biaotiL.numberOfLines = 0
        self.addSubview(biaotiL)
        
        titleL = UILabel.init(frame: CGRect.init(x: header.left_sd, y: header.bottom_sd+F_I6(place: 18), width: KScreenWidth - header.left_sd * 2, height:F_I6(place: 37)))
        titleL.font = UIFont.systemFont(ofSize: 16)
        titleL.textColor = UIColor.textColor1
        titleL.isUserInteractionEnabled = false
        titleL.numberOfLines = 0
        self.addSubview(titleL)
        
        image1 = UIImageView.init(frame: CGRect.init(x: header.left_sd, y: titleL.bottom_sd+F_I6(place: 16), width: F_I6(place: 115), height:F_I6(place: 81)))
        image1.contentMode = .scaleAspectFill
        image1.clipsToBounds = true
        self.addSubview(image1)
        
        image2 = UIImageView.init(frame: CGRect.init(x: image1.right_sd + 2, y: titleL.bottom_sd+F_I6(place: 16), width: F_I6(place: 115), height:F_I6(place: 81)))
        image2.contentMode = .scaleAspectFill
        image2.clipsToBounds = true
        self.addSubview(image2)
        
        image3 = UIImageView.init(frame: CGRect.init(x: image2.right_sd + 2, y: titleL.bottom_sd+F_I6(place: 16), width:F_I6(place: 115), height:F_I6(place: 81)))
        image3.contentMode = .scaleAspectFill
        image3.clipsToBounds = true
        self.addSubview(image3)
        
        playBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: F_I6(place: 40), height: F_I6(place: 40)))
        self.addSubview(playBtn)
        playBtn.setImage(UIImage.init(named: "dyna_4_play"), for: .normal)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}





//MARK: - ----------------宗亲动态cell(首页列表)
class dongtaiCell: UITableViewCell {
    
    var row = 0
    /// 播放按钮
    var playBtn = UIButton()
    /// 点赞按钮
    var likeBtn = UIButton()
    /// 分享按钮
    var shareBtn = UIButton()
    /// 评论按钮
    var talkBtn = UIButton()
    /// 置顶图标或性别图标
    var gender = UIButton()
    /// 发布时间
    var time = UILabel()
    /// 发布者
    var name = UILabel()
    /// 头像
    var header = UIImageView()
    /// 标题
    var title = UILabel()
    /// 图片1
    var image1 = UIImageView()
    /// 图片2
    var image2 = UIImageView()
    /// 图片3
    var image3 = UIImageView()
    /// 内容View
    var infoView =  DynaInfoView()
    
    var model : DynamicModel?{
        didSet {
            self.playBtn.isHidden = true
            
            self.name.text = (model?.clubname ?? "") + (model?.realname ?? "")
            if model?.created.count ?? 0  > 10{
                let date = PLGlobalClass.dateWithtimeStr(model?.created)
                self.time.text = PLGlobalClass.dynamicFormatString(with: date)
                
            }else{
                self.time.text = model?.created
            }
            
            self.title.text = model?.content
            
            //DynaInfoView作为cell时的高度
            self.infoView.height_sd = dongtaiCell.getCellHeigh(model: model!)
            
            self.talkBtn.setTitle(String(describing: model!.commentcount), for: .normal)
            self.likeBtn.setTitle(String(describing: model!.praisecount), for: .normal)
//            likeBtn.handleEventTouchUpInside {
//                if self.likeBtn.isSelected{
//                    print("取消赞")
//                    ClanAPI.requestForCancelpraise(targetid: (self.model?.id)!, targettype: "2", result: { (result) in
//                        if (result.status == "200"){
//                            self.likeBtn.isSelected = false
//                            self.model?.praise = "0"
//                            self.model!.praisecount = self.model!.praisecount-1
//                            self.likeBtn.setTitle( String(self.model!.praisecount), for: .normal)
//                        }else{
//                        }
//                    })
//                }else{
//                    print("点赞")
//                    ClanAPI.requestForSubmitpraise(targetid: (self.model?.id)!, targettype: "2", result: { (result) in
//                        if (result.status == "200"){
//                            self.model?.praise = "1"
//                            self.likeBtn.isSelected = true
//                            self.model!.praisecount = self.model!.praisecount+1
//                            self.likeBtn.setTitle( String(self.model!.praisecount), for: .normal)
//
//                        }else{
//                        }
//                    })
//                }
//            }
            
            if model?.praise == "1"{
                self.likeBtn.isSelected = true
            }else{
                self.likeBtn.isSelected = false
            }
            
            self.header.sd_setImage(with: URL.init(string: NSString.formatImageUrl(with: model?.headimg, ifThumb: true, thumb_W: 80)), placeholderImage: UIImage.init(named: ImageDefault.headerPlace), options: .retryFailed)
            
            var titleHei = CGFloat(0)
            
            PLGlobalClass.paragraphForlabel(self.title, lineSpace: 5)
            self.title.lineBreakMode = .byTruncatingTail

            let size = PLGlobalClass.sizeForParagraph(withText: model?.content, weight: self.title.width_sd, fontSize: self.title.font.pointSize, lineSpacing: 5, numberline: 2)
            titleHei = size.height
            self.title.height_sd = titleHei
            
            self.name.sizeToFit()
            self.name.height_sd = header.height_sd/2
            self.gender.left_sd = self.name.right_sd + 10
            self.gender.centerY_sd = self.name.centerY_sd
            if model?.gender == "1"{
                self.gender.setImage(UIImage.init(named:"gender_man") , for: .normal)
            }else{
                self.gender.setImage(UIImage.init(named:"gender_woman"), for: .normal)
            }
            
            if model?.mediatype=="4"{//视频
                self.image1.isHidden = false
                self.image2.isHidden = true
                self.image3.isHidden = true
                self.playBtn.isHidden = false

                //没有宽高信息 按宽图处理
                self.image1.width_sd = F_I6(place: 351)
                self.image1.height_sd = F_I6(place: 157)
                self.image1.sd_setImage(with: URL.init(string: NSString.formatImageUrl(with: (model?.videoimg ?? ""), ifThumb: false, thumb_W: 0)), placeholderImage: UIImage.init(named: ImageDefault.imagePlace), options: .retryFailed)
                
                self.playBtn.center = self.image1.center

            }else if model?.mediatype=="2"{//单图
                self.image1.isHidden = false
                self.image2.isHidden = true
                self.image3.isHidden = true
                
                if model?.imgs.count ?? 0 > 0{
                    let imgUrl = NSString.formatImageUrl(with: model?.imgs[0], ifThumb: false, thumb_W: 0)
                    self.image1.sd_setImage(with: URL.init(string: imgUrl!), placeholderImage: UIImage.init(named: ImageDefault.imagePlace), options: .retryFailed)
                    self.image1.width_sd = F_I6(place: 127)
                    self.image1.height_sd = F_I6(place: 157)
                }else{
                    self.image1.height_sd = 0
                }
               
            }else if model?.mediatype=="3"{//多图
                self.image1.isHidden = false
                self.image2.isHidden = false
                self.image3.isHidden = false

                if model?.imgs.count == 0{
                    self.image3.isHidden = true
                    self.image2.isHidden = true
                    self.image3.isHidden = true
                    self.image1.isHidden = true
                    self.image1.height_sd = 0
                }else{
                    if model?.imgs.count == 2{
                        self.image3.isHidden = true
                    }else if model?.imgs.count == 1{
                        self.image3.isHidden = true
                        self.image2.isHidden = true
                    }
                    var imgUrl1 = ""
                    var imgUrl2 = ""
                    var imgUrl3 = ""
                    
                    if (model?.imgs != nil && model!.imgs.count>0){
                        imgUrl1 = NSString.formatImageUrl(with: model?.imgs[0], ifThumb: true, thumb_W: 150)
                        if model!.imgs.count > 1{
                            imgUrl2 = NSString.formatImageUrl(with: model?.imgs[1], ifThumb: true, thumb_W: 150)
                        }
                        if model!.imgs.count > 2{
                            imgUrl3 = NSString.formatImageUrl(with: model?.imgs[2], ifThumb: true, thumb_W: 150)
                        }
                    }
                    
                    self.image1.sd_setImage(with: URL.init(string: imgUrl1), placeholderImage: UIImage.init(named: ImageDefault.imagePlace), options: .retryFailed)
                    self.image2.sd_setImage(with: URL.init(string: imgUrl2), placeholderImage: UIImage.init(named: ImageDefault.imagePlace), options: .retryFailed)
                    self.image3.sd_setImage(with: URL.init(string: imgUrl3), placeholderImage: UIImage.init(named: ImageDefault.imagePlace), options: .retryFailed)
                    self.image1.width_sd = self.image2.width_sd
                    self.image1.height_sd = self.image2.height_sd
                }
            }else{//无图
                self.image1.isHidden = true
                self.image2.isHidden = true
                self.image3.isHidden = true
            }
            
            if model?.mediatype=="1" || (self.image1.isHidden == true){//无图
                talkBtn.top_sd = self.title.bottom_sd + 5
            }else{
                self.image1.top_sd = self.title.bottom_sd+10
                self.image2.top_sd = self.image1.top_sd
                self.image3.top_sd = self.image1.top_sd
                
                talkBtn.top_sd = self.image1.bottom_sd  + 5
                if model?.mediatype == "4"{
                    self.playBtn.center = self.image1.center
                }
            }
            likeBtn.top_sd = talkBtn.top_sd
            shareBtn.top_sd = talkBtn.top_sd
        }
    }

    
//TODO:新版收藏样式
    var collModel : DynamicModel?{
        didSet {
            self.playBtn.isHidden = true
            name.top_sd = F_I6(place: 20)
            if collModel?.nickname.count ?? 0 > 0{
                self.name.text = collModel!.nickname
            }else{
                self.name.text = (collModel?.clubname ?? "") + (collModel?.realname ?? "")
            }
            self.name.sizeToFit()
            self.name.left_sd = 12
            
            time.centerY_sd = name.centerY_sd
            time.left_sd = name.right_sd + 10
            
            if collModel?.created.count ?? 0  > 10{
                
                let date = PLGlobalClass.dateWithtimeStr(collModel?.created)
                self.time.text = PLGlobalClass.dynamicFormatString(with: date)
                
            }else{
                self.time.text = collModel?.created
            }
            
            title.text = collModel?.content
            title.height_sd =  F_I6(place: 102 - 14 - 23)
            title.left_sd = 12
            title.top_sd = name.bottom_sd + F_I6(place: 5)
            PLGlobalClass.paragraphForlabel(title, lineSpace: 5)
            
            self.infoView.height_sd = dongtaiCell.getCellHeigh(collmodel: collModel!)
            
            self.header.sd_setImage(with: URL.init(string: NSString.formatImageUrl(with: collModel?.headimg, ifThumb: true, thumb_W: 80)), placeholderImage: UIImage.init(named: ImageDefault.headerPlace), options: .retryFailed)
            
            
            image1.left_sd = F_I6(place: 276)
            image1.top_sd = F_I6(place: 22)
            self.image1.width_sd = F_I6(place: 87)
            self.image1.height_sd = F_I6(place: 109)
            
            playBtn.center = image1.center
            playBtn.isUserInteractionEnabled = false
            
            if collModel?.imgs.count == 0{
                self.image1.isHidden = true
                title.width_sd = KScreenWidth - 24

            }else if collModel?.mediatype == "4"{
                self.image1.isHidden = false
                
                let imgUrl = NSString.formatImageUrl(with: collModel?.videoimg, ifThumb: true, thumb_W: 150)
                
                image1.sd_setImage(with: URL.init(string: imgUrl!), placeholderImage: UIImage.init(named: ImageDefault.imagePlace), options: .retryFailed)
                
                title.width_sd = KScreenWidth - 24 - F_I6(place: 87) - 18
                playBtn.isHidden = false

            }else{
                self.image1.isHidden = false

                let imgUrl = NSString.formatImageUrl(with: collModel?.imgs[0], ifThumb: true, thumb_W: 150)
                image1.sd_setImage(with: URL.init(string: imgUrl!), placeholderImage: UIImage.init(named: ImageDefault.imagePlace), options: .retryFailed)

                title.width_sd = KScreenWidth - 24 - F_I6(place: 87) - 18
            }
            
            self.talkBtn.setImage(nil, for: .normal)
            self.likeBtn.setImage(nil, for: .normal)
            self.talkBtn.setTitle("评论 " + String(collModel?.commentcount ?? 0) + " · ", for: .normal)
            self.likeBtn.setTitle("点赞 " + String(collModel!.praisecount), for: .normal)
            
            self.talkBtn.titleLabel?.sizeToFit()
            self.talkBtn.width_sd = (self.talkBtn.titleLabel?.width_sd)!
            
            self.likeBtn.titleLabel?.sizeToFit()
            self.likeBtn.width_sd = (self.likeBtn.titleLabel?.width_sd)!
            
            self.talkBtn.left_sd = 12
            self.talkBtn.top_sd = F_I6(place: 102)
            self.likeBtn.top_sd = self.talkBtn.top_sd
            self.likeBtn.left_sd = self.talkBtn.right_sd
            
            self.talkBtn.isUserInteractionEnabled = false
            self.likeBtn.isUserInteractionEnabled = false
            
            PLGlobalClass.setBtnStyle(talkBtn, style: .imageLeft, space: 0)
            PLGlobalClass.setBtnStyle(likeBtn, style: .imageLeft, space: 0)
        }
    }
    
    //TODO:动态列表高度
    class func getCellHeigh(model : DynamicModel) -> (CGFloat){
        
        var titleHei = CGFloat(0)
        titleHei = PLGlobalClass.getTextHeight(withStr: model.content, labWidth: KScreenWidth - 24, fontSize: 16, numberLines: 2, lineSpacing: 5)
        var imgHei = CGFloat(0)
        let baseHei = F_I6(place: 102) + 25 + 12 + CGFloat(titleHei)
        
        if model.mediatype=="4"{//视频
            imgHei = F_I6(place: 157)
            return baseHei + imgHei + F_I6(place:10)
            
        }else if model.mediatype=="2"{//单图
            
            if model.imgs.count > 0{
                imgHei = F_I6(place: 157)
                return baseHei + imgHei + F_I6(place:10)
            }
            return baseHei  + F_I6(place:10)
            
        }else if model.mediatype=="3"{//多图
            if model.imgs.count > 0{
                model.cellHei = baseHei + F_I6(place: 81) + F_I6(place:10)
                return baseHei + F_I6(place: 81) + F_I6(place:10)
            }else{
                model.cellHei = baseHei  + F_I6(place:10)
                return baseHei  + F_I6(place:10)
            }
        }else{//无图
            model.cellHei = baseHei
            return baseHei
        }
    }
    
    //TODO:收藏高度
    class func getCellHeigh(collmodel : DynamicModel) -> (CGFloat){

        return F_I6(place: 146)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        infoView =  DynaInfoView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: F_I6(place: 20)))
        infoView.titleL.numberOfLines = 2
        infoView.biaotiL.removeFromSuperview()
        self.contentView.addSubview(infoView)
        
        self.title = infoView.titleL
        self.name = infoView.name
        self.gender = infoView.gender
        self.image1 = infoView.image1
        self.image2 = infoView.image2
        self.image3 = infoView.image3
        self.header = infoView.header
        self.time = infoView.time
        self.playBtn = infoView.playBtn
        
        talkBtn = UIButton.init(frame: CGRect.init(x: F_I6(place: 220) , y: infoView.bottom_sd + 15, width:F_I6(place: 60), height:F_I6(place: 44)))
        self.contentView.addSubview(talkBtn)
        talkBtn.setImage(UIImage.init(named: "dyna_1_talk"), for: .normal)
        talkBtn.setTitleColor(UIColor.textColor2, for: .normal)
        talkBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        PLGlobalClass.setBtnStyle(talkBtn, style: .imageLeft, space: 5)
        talkBtn.isUserInteractionEnabled = false
        
        likeBtn = UIButton.init(frame: CGRect.init(x: F_I6(place: 300), y: image1.bottom_sd + 15, width: F_I6(place: 60), height: F_I6(place: 44)))
        self.contentView.addSubview(likeBtn)
        likeBtn.setImage(UIImage.init(named: "dyna_3_like"), for: .normal)
        likeBtn.setImage(UIImage.init(named: "like_brown"), for: .selected)
        likeBtn.setTitleColor(UIColor.textColor2, for: .normal)
        likeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        PLGlobalClass.setBtnStyle(likeBtn, style: .imageLeft, space: 5)

        likeBtn.isUserInteractionEnabled = false
        playBtn.isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for subView in self.subviews{
            let subViewName = NSStringFromClass(subView.classForCoder)
            if subViewName == "UITableViewCellDeleteConfirmationView"{
                subView.backgroundColor = UIColor.color(hexString: "D50C0B")
                subView.subviews.first?.backgroundColor = UIColor.color(hexString: "D50C0B")
            }
        }
    }
}

//MARK: - ----------------宗亲动态model
class DynamicModel: KBaseModel {
    
    var cellHei = CGFloat(0)    //cell高度存储 避免多次计算

    var attachpath : String = ""    //附件地址
    var currposition : String = ""  //0为整体背景，1为首页，2为我的页面
    /// 创建日期
    var created : String = ""
    var videoimg : String = "" //图片版本
    var thumVideoImg : UIImage?//视频封面图片缓存

    var lon : String = "" //图片地址
    /// 点赞数
    var praisecount : NSInteger = 0
    /// 动态标题
    var title : String = ""
    var type : String = "" //手机号
    var userid : String = "" //id
    /// 动态内容
    var content : String = ""
    var amrurl : String = ""   //:1为安卓，2为IOS,3为其他
    var headimg : String = ""   //:1为安卓，2为IOS,3为其他
    /// 评论数
    var commentcount : NSInteger = 0
    /// 分享数
    var sharecount : String = ""
    var lati : String = ""  //图片跳转地址，为APP内的跳转
    var viewrange : String = "" //手机号
    var id : String = "" //id
    var status : String = "" //图片标题
    var clubname : String = "" //姓
    var realname : String = "" //名
    var nickname : String = "" //姓名
    var username : String = "" //手机号 跳转个人信息页 使用
    var gender : String = ""//性别
    
    /// 动态图片
    var imgs = [String]()
    /// 展示类型： 1.无图; 2,单图; 3,多图; 4,视频
    var mediatype : String = ""
    var praise : String = "" //是否已点赞
    var collect : String = "" //是否已收藏
    var targetid : String = "" //如果是收藏列表 这个就是收藏的动态id
    var targetstatus = 1 //如果改动态存在，是1  不存在（已删除 是0）

    //    override static func mj_objectClassInArray() -> [AnyHashable : Any]! {
    //        return ["imgs": String.self]
    ////        return ["imgs": imgModel.self]
    //    }
    
}


//MARK: - ----------------图片model
class ImgSizeModel: KBaseModel {
    
    var width = CGFloat(0)    //图片宽度
    var heigh = CGFloat(0)    //图片高度    
    //    override static func mj_objectClassInArray() -> [AnyHashable : Any]! {
    //        return ["imgs": String.self]
    ////        return ["imgs": imgModel.self]
    //    }
}
