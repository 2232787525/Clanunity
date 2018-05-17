//
//  MyMoreGroupsListVC.swift
//  Clanunity
//
//  Created by wangyadong on 2018/3/27.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

import UIKit
import MJRefresh
class MyMoreGroupsListVC: KBaseClanViewController,UITableViewDelegate,UITableViewDataSource {

    var list = Array<MTTGroupEntity>()
    var tableView : UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.knavigationBar?.title = "我的群";
        self.makeTableView()
        self.tableView.reloadData()
        // Do any additional setup after loading the view.
    }
    func makeTableView() -> Void {
        
        self.tableView = UITableView.init(frame: CGRect.init(x: 0, y: KTopHeight, width: KScreenWidth, height: KScreenHeight-KTopHeight), style: .grouped);
        self.tableView.separatorColor = UIColor.cutLineColor;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.adjustEstimatedHeight()
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.layoutMargins = UIEdgeInsets.zero
        self.view .addSubview(self.tableView);
        
        self.tableView.register(MoreGroupListCell.self, forCellReuseIdentifier: MoreGroupListCell.reuseIdentifier)

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60;
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
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MoreGroupListCell.reuseIdentifier) as! MoreGroupListCell
        cell.model = list[indexPath.row];
        
        return cell;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let group = list[indexPath.row];
        let session = MTTSessionEntity.init(sessionID: group.objID, type: .sessionTypeGroup)
        let chatting = ChattingMainViewController.shareInstance()
        chatting?.showChattingContent(forSession: session)
        self.navigationController?.pushViewController(chatting!, animated: true)
        chatting?.knavigationBar?.title = group.name;
        
        
        
        
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


class MoreGroupListCell : UITableViewCell{
    
    var imgView : MTTAvatarImageView!
    var namelb : UILabel!
    var count : UILabel!
    
    static let reuseIdentifier = "MoreGroupListCell"

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.imgView = MTTAvatarImageView.init(frame: CGRect.init(x: 12, y: 5, width: 50, height: 50))
        self.imgView.backgroundColor = UIColor.bgGreyColor
        self.contentView.addSubview(self.imgView);
        
        self.namelb = UILabel.label(frame: CGRect.init(x: self.imgView.right_sd+10, y: self.imgView.top_sd, width: KScreenWidth-self.imgView.right_sd-20, height: 20), text: "", font: UIFont.boldSystemFont(ofSize: 15), textColor: UIColor.textColor1, textAlignment: .left)
        self.contentView.addSubview(self.namelb);
        
        self.count = UILabel.label(frame: CGRect.init(x: self.imgView.right_sd+10, y: self.imgView.centerY_sd, width: KScreenWidth-self.imgView.right_sd-20, height: 20), text: "", font: UIFont.systemFont(ofSize: 12), textColor: UIColor.textColor2, textAlignment: .left)
        self.contentView.addSubview(self.count);
    }
    var model : MTTGroupEntity?{
        willSet{
            if newValue != nil {
                self.namelb.text = newValue?.name;
                let users = newValue!.users
                if users != nil{
                    self.count.text = "(\(users!.count)人)"
                }else{
                    self.count.text = ""
                }
                self.imgView.setAvatar(newValue?.imgArray?.joined(separator: ";"), group: true);
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}



