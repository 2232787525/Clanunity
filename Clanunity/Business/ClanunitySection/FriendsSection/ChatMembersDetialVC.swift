//
//  ChatMembersDetialVC.swift
//  Clanunity
//
//  Created by wangyadong on 2018/3/27.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

import UIKit
import MBProgressHUD
class ChatMembersDetialVC: KBaseClanViewController,UITableViewDelegate,UITableViewDataSource{

    var deletetResult : (((MTTGroupEntity) -> Void)?)
    
    var tableView : UITableView!
    //群聊 群model
    var groupModel : MTTGroupEntity?
    
    /// 单聊 个人model
    var singleModel : MTTUserEntity?
    
    var dataArray = Array<MemberDetialCellModel>()
    
    /// 0单聊，1群聊
    var singleChat : Bool = true;
    //单聊数组中就放一个model，群聊数组是多个model
    var memberData = Array<MTTUserEntity>()
    var headerView = MemberDetialHeaderView();
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeTableView()

        if self.singleChat == true {
            self.knavigationBar?.title = "聊天信息"
            self.loadSingleChatUserInfo(userid: (self.singleModel?.teamid)!)
        }else{
            self.knavigationBar?.title = "群聊信息"
            self.loadGroupChatUserList(groupid: (self.groupModel?.id)!)
   
        }
       self.tableView.reloadData()
        // Do any additional setup after loading the view.
    }

    func loadSectionData() -> Void {
        if self.singleChat == true {
            self.knavigationBar?.title = "聊天信息"

            self.dataArray.append(MemberDetialCellModel.loadModel(type: 0, left: "投诉", nil, false,.Complaint))
        }else{
            self.knavigationBar?.title = "群聊信息"
            
            self.dataArray.append(MemberDetialCellModel.loadModel(type: 1, left: "群名称", self.groupModel?.name, true,.GroupName))
            self.dataArray.append(MemberDetialCellModel.loadModel(type: 1, left: "群公告", self.groupModel?.notice, false,.Publicnotice))

            self.dataArray.append(MemberDetialCellModel.loadModel(type: 0, left: "投诉", nil, false,.Complaint))
        }
        self.tableView.reloadData()
    }
    
    func makeTableView() -> Void {
        
        self.tableView = UITableView.init(frame: CGRect.init(x: 0, y: KTopHeight, width: KScreenWidth, height: KScreenHeight-KTopHeight), style: .grouped);
        self.tableView.separatorColor = UIColor.cutLineColor;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.adjustEstimatedHeight()
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.layoutMargins = UIEdgeInsets.zero
        //注册cell
        self.tableView.register(MemberDetialCell.self, forCellReuseIdentifier: MemberDetialCell.reuseIdentifier)
        self.view .addSubview(self.tableView);

    }
    func loadHeaderFooter() -> Void{

        self.headerView = MemberDetialHeaderView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 1))

        if self.singleChat == true {
            self.memberData = [self.singleModel!];
            self.headerView.groupid = MTTUserEntity.pbUserId(toLocalID: UInt((self.singleModel?.teamid)!))
        }else{
            self.memberData = (self.groupModel?.users)!;
            self.headerView.groupid = self.groupModel?.objID
            self.headerView.groupCreaterid = self.groupModel?.tuserid;
            
            //如果当前用户是群主
            if UserServre.shareService.userModel.teamid == self.groupModel?.tuserid{
                let add = MTTUserEntity.init()
                add.addDelete = 11;
                self.memberData.append(add)
                let delete = MTTUserEntity.init()
                delete.addDelete = 33;
                self.memberData.append(delete);
                
            }else{
                let add = MTTUserEntity.init()
                add.addDelete = 11;
                self.memberData.append(add)
            }
        }
        self.headerView.loadMemberData(singleChat:self.singleChat , data: self.memberData)
        self.tableView.tableHeaderView = self.headerView
        self.headerView.changeHei = {
            self.tableView.tableHeaderView = self.headerView
        }
        
        
        if self.singleChat == false && UserServre.shareService.userModel.teamid != self.groupModel?.tuserid{
            //当前是群聊，并且当前用户不是群主
            let footer = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 150))
            let deleteBtn = UIButton.init(frame: CGRect.init(x: 12, y: 60, width:KScreenWidth-24 , height: 44))
            deleteBtn.backgroundColor = UIColor.theme
            deleteBtn.layer.cornerRadius = 4;
            deleteBtn.setTitleColor(UIColor.white, for: .normal)
            deleteBtn.setTitle("返回", for: .normal)
            deleteBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            footer.addSubview(deleteBtn)
            self.tableView.tableFooterView = footer
            
            deleteBtn.handleEventTouchUpInside(callback: {
                print(self.groupModel?.objID ?? "")
                print(self.groupModel?.groupCreatorId ?? "")

                self.kBackBtnAction();//不退出了，直接返回
                return;
                
                ClanAPI.requestForDeleteMember(groupid:(self.groupModel?.id)! , userid: UserServre.shareService.userModel.teamid, result: {[weak self] (result) in
                    if result.status == "200"{
                        let group = MTTGroupEntity.mj_object(withKeyValues: result.data)
                        self?.groupModel?.id = (group?.id)!
                        
                        self?.groupModel?.name = group?.name;
                        self?.groupModel?.tuserid = (group?.tuserid)!;
                        self?.groupModel?.userid = group?.userid;
                        self?.groupModel?.users = group?.users;
                        var createrIndex = -1;
                        if self?.groupModel?.users != nil{
                            for (idx,Item) in (self?.groupModel?.users?.enumerated())!{
                                Item.headimg = NSString.formatImageUrl(with: Item.headimg, ifThumb: true, thumb_W: 80);
                                if Item.teamid == (self?.groupModel?.tuserid)!{
                                    createrIndex = idx
                                }
                            }
                            if createrIndex != -1{
                                var groupUsers = (group?.users)!
                                groupUsers.remove(at: createrIndex)
                                groupUsers.insert((group?.users![createrIndex])!, at: 0)
                                self?.groupModel?.users = groupUsers;
                            }
                        }
                        self?.loadSectionData()
                        self?.loadHeaderFooter()
                        self?.loadGroupNotice()
                        self?.kBackBtnAction()
                        if ((self?.deletetResult) != nil){
                            self?.deletetResult!((self?.groupModel)!)
                        }
                          
                    }else{
                        
                        WFHudView.showMsg(result.message, in: self?.view);
                    }
                    
                })
            })
        }
    }
    
    
    //MARK: - tableDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = self.dataArray[indexPath.row];
        return model.cellHeight;
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil;
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MemberDetialCell.reuseIdentifier) as! MemberDetialCell
        cell.model = self.dataArray[indexPath.row]        
        return cell;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.dataArray[indexPath.row];
        if model.infoCell == .Complaint {
            //投诉
            if self.singleChat == true{
                //投诉个人
                if (self.singleModel?.userid?.count ?? 0) > 0{
                    let vc = ComplaintVC.init()
                    vc.complaintId = (self.singleModel?.userid ?? "")
                    vc.ifPerson = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }else{
                //投诉群
                if (self.groupModel?.id ?? 0) > 0{
                    let vc = ComplaintVC.init()
                    vc.complaintId = "\(self.groupModel?.id ?? 0)"
                    vc.ifPerson = false
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        if model.infoCell == .Publicnotice {
            
            if UserServre.shareService.userModel.teamid == self.groupModel?.tuserid {
 
            }else{
                if self.groupModel?.notice != nil && (self.groupModel?.notice)!.count > 0{
                }else{
                    
                    WFHudView.showMsg("只有群主可以编辑群公告", in: self.view)
                    
                    return;
                }
            }
            let group = GroupChatPublicNoticeVC.init();
           //群主 self.groupModel?.tuserid
            group.groupid =  self.groupModel?.id;
            group.groupCreaterId = self.groupModel?.tuserid
            group.groupNotice = model.righttitle
            group.groupUpdated = model.noticeupdated
            for item in (self.groupModel?.users)! {
                if item.teamid == self.groupModel?.tuserid{
                    group.groupCreatername = item.realname;
                    group.groupCreaterHeader = item.headimg
                    break;
                }
            }
            group.backResult = {(notice) -> Void in
                model.righttitle = notice;
                NSString.currentTime1970()
                self.tableView.reloadData()                
                ChattingMainViewController.shareInstance().groupChatSendNotice(notice);
                
                
            }
            self.navigationController?.pushViewController(group, animated: true);
        }
    }
    
    /// 获取个人信息
    ///
    /// - Parameter userid: 用户id
    func loadSingleChatUserInfo(userid:Int) -> Void {
       
        self.showGifView()
        ClanAPI .requestForUserInfo(ttUserid: userid) {[weak self] (result) in
            self?.hiddenGifView()
            if result.status == "200"{
                print(result.data ?? "")
                let single = MTTUserEntity.mj_object(withKeyValues: result.data!);
                single?.teamid = (self?.singleModel?.teamid)!
                self?.singleModel = nil
                self?.singleModel = single;
                self?.loadSectionData()
                self?.loadHeaderFooter()
            }else{
                WFHudView.showMsg(result.message, in:self?.view)
            }
            
        }
        
    }
    
    /// 群信息
    ///
    /// - Parameter groupid: 群id
    func loadGroupChatUserList(groupid:Int) -> Void {
        

        self.showGifView();
        ClanAPI.requestForGroupInfo(ttGroupid: groupid) { [weak self](result) in
            self?.hiddenGifView()
            if result.status == "200"{
                print(result.data ?? "")
                
                let group =  MTTGroupEntity.mj_object(withKeyValues: result.data!)
                self?.groupModel?.id = (group?.id)!
                
                self?.groupModel?.name = group?.name;
                self?.groupModel?.tuserid = (group?.tuserid)!;
                self?.groupModel?.userid = group?.userid;
                self?.groupModel?.users = group?.users;
                var createrIndex = -1;
                if self?.groupModel?.users != nil{
                    for (idx,Item) in (self?.groupModel?.users?.enumerated())!{
                        Item.headimg = NSString.formatImageUrl(with: Item.headimg, ifThumb: true, thumb_W: 0);
                        if Item.teamid == (self?.groupModel?.tuserid)!{
                            createrIndex = idx
                        }
                    }
                    if createrIndex != -1{
                        var groupUsers = (group?.users)!
                        groupUsers.remove(at: createrIndex)
                        groupUsers.insert((group?.users![createrIndex])!, at: 0)
                        self?.groupModel?.users = groupUsers;
                    }
                }
                self?.loadSectionData()
                self?.loadHeaderFooter()
                self?.loadGroupNotice()
            }else{
                WFHudView.showMsg(result.message, in:self?.view)
            }
  
        }
    }
    
    func loadGroupNotice() -> Void {
        ClanAPI.requestForGroupPublicNotice(ttGroupid: self.groupModel?.id ?? 0) {[weak self] (result) in
            if result.status == "200"{
                print(result.data ?? "")
                let data = result.data as! Dictionary<String,Any>
                let content = data["content"]
                let updated = data["updated"];
                if content != nil && (content as! String).count > 0{
                    for model in (self?.dataArray)!{
                        
                        if model.infoCell == InfoCellType.Publicnotice{
                            model.righttitle = content as! String
                            model.noticeupdated = updated as? String
                            self?.tableView.reloadData()
                            break;
                        }
                    }
                }
                
            }else{
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class MemberDetialHeaderView : UIView {
    
    
    var memberData = Array<MTTUserEntity>()
    
    /// 群id。objctID
    var groupid : String!
    /// 群主id
    var groupCreaterid : Int!
    
    typealias closureBlock = () -> Void
    var changeHei:closureBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
    }
    
    func loadMemberData(singleChat:Bool,data:Array<MTTUserEntity>) -> Void {
        self.memberData = data;
        if singleChat == true {
            
            let head = UIImageView.init(frame: CGRect.init(x: 12, y: 10, width: 50, height: 50))
            
            self.addSubview(head);
            head.sd_setImage(with: URL.init(string:NSString.formatImageUrl(with: data.first?.headimg ?? "", ifThumb: true, thumb_W: 0)), placeholderImage: UIImage.init(named: CUKey.kPlaceHead), options: .retryFailed)
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(friendHeadTap));
            head.isUserInteractionEnabled = true;
            head.addGestureRecognizer(tap)
            
            let clubname = UserServre.shareService.userClub?.club
            
            let name = UILabel.label(frame: CGRect.init(x: head.right_sd+10, y: 0, width: KScreenWidth-head.right_sd-20, height: 20), text:(clubname ?? "") + (data.first?.realname ?? "") , font: UIFont.systemFont(ofSize: 15), textColor: UIColor.textColor1, textAlignment: .left)
            self.addSubview(name)
            
            name.centerY_sd = head.centerY_sd;
            
            self.height_sd = head.bottom_sd + 10;
        }else{
            var space : CGFloat = 0.0;
            var count = 5;
            
            if KScreenWidth < 375{
                count = 4;
            }
            space = (KScreenWidth-24 - (CGFloat)(50 * count))/(CGFloat)(count-1);

            self.removeAllSubviews()
            for (idx,item) in data.enumerated(){
                
                let head = UIImageView.init(frame: CGRect.init(x: 12+(50+space)*(CGFloat)(idx % count), y: 15+(50+5+15+15)*(CGFloat)(idx/count), width: 50, height: 50));
                head.tag = 1923+idx
                let tap = UITapGestureRecognizer.init(target: self, action: #selector(headerTapClicked(_:)));
                head.isUserInteractionEnabled = true;
                head.addGestureRecognizer(tap)
                self.addSubview(head);
                let name = UILabel.label(frame: CGRect.init(x:head.left_sd, y: head.bottom_sd+5, width: head.width_sd, height: 15), text:item.realname ?? "" , font: UIFont.systemFont(ofSize: 15), textColor: UIColor.textColor1, textAlignment: .center)
                self.addSubview(name)
                self.height_sd = name.bottom_sd+15;
                if item.addDelete != 33 && item.addDelete != 11{
                    head.sd_setImage(with: URL.init(string: item.headimg ?? ""), placeholderImage: UIImage.init(named: CUKey.kPlaceHead), options: .retryFailed)
                }else{
                    name.isHidden = true;
                    var icon = "addGrouperIcon"
                    if item.addDelete == 33{
                        icon = "deleteGrouperIcon"
                    }
                    head.image = UIImage.init(named: icon)
                }
            }
            
        }
    }
    func friendHeadTap() -> Void {
        let model = self.memberData[0];
        let vc = StrangerOrFriendVC.init();
        vc.username = model.username
        self.viewController()?.navigationController?.pushViewController(vc, animated: true)

    }
    
    func headerTapClicked(_ sender:UIGestureRecognizer) -> Void {
        if sender.view != nil {
            let model = self.memberData[((sender.view?.tag)! - 1923)]
            if !(model.addDelete == 11 || model.addDelete == 33){
                //点击头像--进入详情
                if UserServre.shareService.userModel.teamid == model.teamid{
                    let mying = MyInfoVC.init()
                    self.viewController()?.navigationController?.pushViewController(mying, animated: true);
                    return;
                    
                }
                print(model.username ?? "username")
                let vc = StrangerOrFriendVC.init();
                vc.username = model.username
                self.viewController()?.navigationController?.pushViewController(vc, animated: true)
                
                return;
            }
            var groups = Array<MTTUserEntity>();
            var tempCreater : Int = -1;
            for item in self.memberData{
                if !(item.addDelete == 11 || item.addDelete == 33){
                    item.objID = MTTUtil.changeOriginal(toLocalID: UInt32(item.teamid), sessionType: 1)
                    groups.append(item)
                    if self.groupCreaterid == item.teamid{
                        tempCreater = groups.count-1;
                        item.selected = 2;//群主
                    }
                }
            }
            if tempCreater != -1{
                let groupCreaterModel = groups[tempCreater];
                groups.remove(at: tempCreater);
                groups.insert(groupCreaterModel, at: 0)
            }
            let addFriend = SelectedUserVC.init()
            let navigation = KNavigationController.init(rootViewController: addFriend)
            addFriend.type = model.addDelete;//33删除，11新增
            addFriend.groupid = self.groupid
            addFriend.groupArray = groups;
            addFriend .resultBlock = {[weak self](isAdd,addmembers) -> Void in
                
                if isAdd == true && addmembers != nil{
                    for item in addmembers!{
                        if self?.memberData.contains(item) == false{
                            self?.memberData.insert(item, at: 1);
                        }
                    }
                }
                if isAdd == false && addmembers != nil{
                    for item in addmembers!{
                        if self?.memberData.contains(item) == true{
                            self?.memberData.remove(at: (self?.memberData.index(of: item))!)
                        }
                    }
                }
                self?.loadMemberData(singleChat: false, data: (self?.memberData)!)
                self?.changeHei!()
                
//                self?.tableView.tableHeaderView = self?.headerView
            }
            self.viewController()?.present(navigation, animated: true, completion: {
            })
        }
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MemberDetialCell : UITableViewCell{
    static let reuseIdentifier = "MemberDetialCell"
    
    var leftTitle = UILabel()
    var rightText = UILabel()
    var rightImg = UIImageView()
    var rightSwitch = UISwitch()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none;
        self.leftTitle = UILabel.label(frame: CGRect.init(x: 12, y: 12, width: 100, height:20 ), text: "", font: UIFont.systemFont(ofSize: 14), textColor: UIColor.textColor1, textAlignment: .left)
        self.contentView.addSubview(self.leftTitle)
        
        self.rightText = UILabel.label(frame: CGRect.init(x: 12, y: 12, width: 100, height:20 ), text: "123", font: UIFont.systemFont(ofSize: 13), textColor: UIColor.textColor2, textAlignment: .right)
        self.rightText.numberOfLines = 0;
        self.rightText.width_sd = KScreenWidth-24-70;
        self.rightText.right_sd = KScreenWidth-12
        self.contentView.addSubview(self.rightText)
        self.rightImg = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 17, height: 17))
        self.rightImg.image = UIImage.init(named: "crcodeIcon");
        self.contentView.addSubview(self.rightImg);
        self.rightImg.centerY_sd = self.leftTitle.centerY_sd;
        self.rightImg.right_sd = KScreenWidth-12;
        
        self.rightSwitch = UISwitch.init(frame: CGRect.init(x: 0, y: 0, width: 51, height: 31));
        self.rightSwitch.centerY_sd = self.leftTitle.centerY_sd;
        self.rightSwitch.centerX_sd = KScreenWidth-12-25;
        self.rightSwitch.onTintColor = UIColor.theme
        self.rightSwitch.tintColor = UIColor.theme;
        self.rightSwitch.isOn = true
        self.contentView.addSubview(self.rightSwitch);
        self.rightSwitch.addTarget(self, action: #selector(switchClicked(sender:)), for: UIControlEvents.valueChanged)
        
    }
    func switchClicked(sender:UISwitch) -> Void {
        
    }
    var model = MemberDetialCellModel(){
        willSet{
            if newValue.type == 0 {
                self.rightSwitch.isHidden = true
                self.rightImg.isHidden = true
                self.rightText.isHidden = true
                self.leftTitle.text = newValue.lefttitle
                
            }else if newValue.type == 1{
                self.rightSwitch.isHidden = true
                self.rightImg.isHidden = true
                self.rightText.isHidden = false
                self.rightText.text = newValue.righttitle
                self.leftTitle.text = newValue.lefttitle
                self.rightText.height_sd = 20;
                self.rightText.centerY_sd = self.leftTitle.centerY_sd;
                self.rightText.height_sd = self.leftTitle.height_sd;
                if newValue.infoCell == .Publicnotice{
                    self.rightText.height_sd = PLGlobalClass.size(withText: newValue.righttitle, font: UIFont.systemFont(ofSize: 13), width: KScreenWidth-24-70, height: 100).height;
                    if self.rightText.height_sd >= 20{
                        self.rightText.top_sd = self.leftTitle.top_sd;
                        if self.rightText.height_sd > 56{
                            self.rightText.height_sd = 56;
                        }
                    }else{
                        self.rightText.height_sd = 20;
                    }
                }
                
                

            }else if newValue.type == 2{
                self.rightSwitch.isHidden = true
                self.rightImg.isHidden = false
                self.rightText.isHidden = true
                self.leftTitle.text = newValue.lefttitle
            }else if newValue.type == 3{
                self.rightSwitch.isHidden = false
                self.rightImg.isHidden = true
                self.rightText.isHidden = true
                self.leftTitle.text = newValue.lefttitle
            }
        }
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
enum InfoCellType : Int {
    case Default = 0
    case GroupName = 1
    case QRCode = 2
    case Publicnotice = 3
    case ChatTop = 4
    case Disturb = 5
    case Complaint = 6
    case ClearRecord = 7
}

class MemberDetialCellModel : KBaseModel{
    
    /// 0 无right，1right有文本，2二维码，3开关
    var type : Int = 0
    var lefttitle : String = ""
    var noticeupdated : String?
    var righttitle : String = ""{
        willSet{
            if self.infoCell == .Publicnotice  {
                self.cellHeight = PLGlobalClass.size(withText: newValue, font: UIFont.systemFont(ofSize: 13), width: KScreenWidth-24-70, height: 100).height+24;
                if self.cellHeight <= 44{
                    self.cellHeight = 44;
                }else{
                    self.cellHeight = 24+56;
                }
            }
        }
    }
    var rightSwith : Bool = true
    var cellHeight : CGFloat = 44;
    var infoCell : InfoCellType = InfoCellType.Default
    class func loadModel(type:Int,left:String,_ right : String?,_ rightSwithcOn:Bool,_ infocell:InfoCellType) -> MemberDetialCellModel {
        let model = MemberDetialCellModel.init()
        model.cellHeight = 44;
        model.type = type
        model.lefttitle = left
        model.rightSwith = rightSwithcOn
        model.infoCell = infocell;
        model.cellHeight = 44;
        model.righttitle = right ?? ""
        
        return model;
    }
   
}


