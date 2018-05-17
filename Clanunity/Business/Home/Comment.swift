import UIKit

//MARK: - ----------------直接评论View
class commentheaderView: UIView {
    /// 标题
    var titleL = UILabel()
    var userView =  UserList()
    /// 点赞按钮
    var likeBtn = UIButton()
    
    var model : commentModel?{
        didSet {
            let str = UserServre.shareService.userClub?.club
            
            userView.text1.text = str! + ((model?.fromuser?["realname"] as? String) ?? "")
            
            let date = PLGlobalClass.dateWithtimeStr(model?.created)
            userView.text2.text = PLGlobalClass.dynamicFormatString(with: date)
            
            let imgUrl = NSString.formatImageUrl(with: model?.fromuser?["headimg"] as? String, ifThumb: true, thumb_W: 0)
            userView.leftImageView.sd_setImage(with: URL.init(string: imgUrl!), placeholderImage: UIImage.init(named: ImageDefault.headerPlace), options: .retryFailed)
            
            self.titleL.text = model?.content
            self.titleL.height_sd = commentheaderView.gettextHeigh(model: model!)
            PLGlobalClass.paragraphForlabel(self.titleL, lineSpace: 5)
            self.titleL.lineBreakMode = .byTruncatingTail
            
            self.likeBtn.setTitle(String(describing: model!.praisecount), for: .normal)
            
            if model?.praise == "1"{
                likeBtn.isSelected = true
            }else{
                likeBtn.isSelected = false
            }
            
            likeBtn.handleEventTouchUpInside {[weak self] in
                if (self?.likeBtn.isSelected)!{
                    print("取消赞")
                    ClanAPI.requestForCancelpraise(targetid: (self?.model?.id)!, targettype: "1", result: { (result) in
                        if (result.status == "200"){
                            self?.likeBtn.isSelected = false
                            self?.model?.praise = "0"
                            self?.model!.praisecount = (self?.model!.praisecount)!-1
                            self?.likeBtn.setTitle( String((self?.model!.praisecount)!), for: .normal)
                        }
                    })
                }else{
                    print("点赞")
                    ClanAPI.requestForSubmitpraise(targetid: (self?.model?.id)!, targettype: "1", result: { (result) in
                        if (result.status == "200"){
                            self?.model?.praise = "1"
                            self?.likeBtn.isSelected = true
                            self?.model!.praisecount = (self?.model!.praisecount)!+1
                            self?.likeBtn.setTitle( String((self?.model!.praisecount)!), for: .normal)
                        }
                    })
                }
            }
        }
    }
    
    class func getCellHeigh(model : commentModel) -> (CGFloat){
        return F_I6(place: 30) + 50 + 15 + commentheaderView.gettextHeigh(model: model)
    }
    
    class func gettextHeigh(model:commentModel) -> (CGFloat){
        return PLGlobalClass.getTextHeight(withStr: model.content, labWidth: KScreenWidth - 12 * 2, fontSize: 16  , numberLines: 0, lineSpacing: 5)
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        userView = UserList.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 30+30 + 10), headerToTop: 25, headerW: 38)

        self.addSubview(userView)
        userView.height_sd = frame.size.height
        userView.backgroundColor = UIColor.clear
        
        userView.text2.left_sd = userView.text1.left_sd
        userView.text2.top_sd = userView.text1.bottom_sd + 2
        
        userView.iconbtn.setImage(UIImage.init(named: ""), for: .normal)
        userView.iconbtn.setTitle("回复", for: .normal)
        userView.iconbtn.width_sd = 40
        userView.iconbtn.height_sd = 40
        
        userView.iconbtn.right_sd = userView.right_sd-10
        userView.iconbtn.centerY_sd = userView.leftImageView.centerY_sd
        
        likeBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: F_I6(place: 60), height: F_I6(place: 32)))
        userView.addSubview(likeBtn)
        likeBtn.setImage(UIImage.init(named: "dyna_3_like"), for: .normal)
        likeBtn.setImage(UIImage.init(named: "like_brown"), for: .selected)
        likeBtn.setTitleColor(UIColor.textColor2, for: .normal)
        likeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        PLGlobalClass.setBtnStyle(likeBtn, style: .imageLeft, space: 2)
        
        titleL = UILabel.init(frame: CGRect.init(x: 12, y: userView.leftImageView.bottom_sd + 15, width: KScreenWidth - 12 * 2, height:0))
        titleL.font = UIFont.systemFont(ofSize:16)
        titleL.textColor = UIColor.textColor2
        titleL.isUserInteractionEnabled = false
        titleL.numberOfLines = 0
        self.addSubview(titleL)
        
        
        let gestap = UITapGestureRecognizer.bk_recognizer {[weak self] (_, _, _) in
            if self?.model?.fromuser == nil{
                //                WFHudView.showMsg("缺少参数", in: self)
                return
            }else{
                if self?.model?.fromuser!["username"] as? String == UserServre.shareService.userModel.username{
                    let vc = MyInfoVC.init()
                    PLGlobalClass.currentViewController().navigationController?.pushViewController(vc, animated: true)
                }else{
                    let vc = StrangerOrFriendVC.init()
                    vc.username = self?.model?.fromuser!["username"] as? String
                    PLGlobalClass.currentViewController().navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        userView.leftImageView.isUserInteractionEnabled = true
        userView.leftImageView.addGestureRecognizer(gestap as! UIGestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - ----------------回复评论View
class commentreplyView: UIView {
    /// 标题
    var titleView = UIView()
    var titleL = UILabel()
    
    var model : commentModel?{
        didSet {
            //             headimg = "<null>";     id = 52032c73bc7c4d;     realname = "\U78ca";     username
            self.titleView.height_sd = commentreplyView.gettextHeigh(model: model!)
            self.height_sd = self.titleView.height_sd
            self.titleL.height_sd = self.titleView.height_sd - 16
            
            let str = UserServre.shareService.userClub?.club
            
            let fromusername = str! + ((model?.fromuser?["realname"] as? String) ?? "")
            let tousername = str! + ((model?.touser?["realname"] as? String) ?? "")
            
            let attrString = NSMutableAttributedString.init(string: fromusername, attributes: [NSForegroundColorAttributeName:UIColor.textColor5])
            
            if model?.needShowTouser == true{
                attrString.append(NSAttributedString.init(string: "回复" , attributes: [NSForegroundColorAttributeName:UIColor.textColor2]))
                
                attrString.append(NSAttributedString.init(string: tousername , attributes: [NSForegroundColorAttributeName:UIColor.textColor5]))
            }
            attrString.append(NSAttributedString.init(string: "：" , attributes: [NSForegroundColorAttributeName:UIColor.textColor5]))
            
            let content = (model?.content ?? "")
            
            attrString.append(NSAttributedString.init(string: content , attributes: [NSForegroundColorAttributeName:UIColor.textColor2]))
            self.titleL.attributedText = attrString;
            PLGlobalClass.paragraphForlabel(self.titleL, lineSpace: 2)
            self.titleL.lineBreakMode = .byTruncatingTail
        }
    }
    
    class func gettextHeigh(model:commentModel) -> (CGFloat){
        
        let str = UserServre.shareService.userClub?.club
        let fromusername = str! + ((model.fromuser?["realname"] as? String) ?? "")
        let tousername = str! + ((model.touser?["realname"] as? String) ?? "")
        
        if model.needShowTouser == true{
            return PLGlobalClass.getTextHeight(withStr: fromusername + "回复: " + tousername + model.content, labWidth: KScreenWidth - 12 * 2, fontSize:16, numberLines: 0, lineSpacing: 2) + 17
        }else{
            return PLGlobalClass.getTextHeight(withStr: fromusername + ": ", labWidth: KScreenWidth - 12 * 2, fontSize:16, numberLines: 0, lineSpacing: 2) + 17
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        titleView = UIView.init(frame: CGRect.init(x: 12, y: 0, width: KScreenWidth-12*2, height: 0))
        titleView.backgroundColor = UIColor.bgColor5
        self.addSubview(titleView)
        
        titleL = UILabel.init(frame: CGRect.init(x: 12, y: 9, width: titleView.width_sd - 12 * 2, height:0))
        titleL.font = UIFont.systemFont(ofSize:16)
        titleL.textColor = UIColor.textColor2
        titleL.isUserInteractionEnabled = false
        titleL.numberOfLines = 0
        titleView.addSubview(titleL)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - ----------------评论model
class commentModel: KBaseModel {
    
    var children = [commentModel]()//子评论
    
    var commentid : String = ""  //回复评论的评论id
    
    var commentcount : String = ""   //
    var content : String = "" //
    var created : String = ""  //动态id
    
    var fromuser  : Dictionary<String, Any>? //发表该评论的人 headimg = "<null>";     id = 52032c73bc7c4d;     realname = "\U78ca";     username = 13994073247;
    var parentid : String = "" //回复评论id
    /// 评论id
    var id : String = ""
    /// 评论目标id （动态id 活动id 等内容的id）
    var targetid : String = ""
    /// 评论类型 1. 回复评论; 2. 动态评论 ;3. 活动评论
    var targettype : String = ""
    /// 该条评论的评论对象字典
    var touser : Dictionary<String, Any>?
    /// 评论对象id
    var touserid : String = ""
    var updated : String = ""  //更新时间
    /// 用户id
    var userid : String = ""
    var praise : String = "" //是否已点赞
    /// 点赞数
    var praisecount : NSInteger = 0
    var needShowTouser = false

    
    override static func mj_objectClassInArray() -> [AnyHashable : Any]! {
        return ["children": commentModel.self]
    }
}

