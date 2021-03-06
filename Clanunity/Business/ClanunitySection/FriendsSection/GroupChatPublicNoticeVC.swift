//
//  GroupChatPublicNoticeVC.swift
//  Clanunity
//
//  Created by wangyadong on 2018/4/13.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//

import UIKit
class GroupChatPublicNoticeVC: KBaseClanViewController,UITextViewDelegate {

    var backResult : (((String) -> Void)?)
    
    /// 群id
    var groupid : Int?
    
    /// 群主名字
    var groupCreatername : String?
    var groupCreaterHeader : String?
    var groupNotice : String = ""
    var groupCreaterId : Int?
    var groupUpdated : String?
    var header = UIImageView();
    var name = UILabel();
    var time = UILabel()
    var notice = AmbitionTextView()
    var point = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.knavigationBar?.title = "群公告"
        
        let scroll = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight))
        self.view.addSubview(scroll);
        self.header = UIImageView.init(frame: CGRect.init(x: 12, y: KTopHeight+15, width: 50, height: 50));
        scroll.addSubview(self.header)
        self.header.sd_setImage(with: URL.init(string: NSString.formatImageUrl(with: self.groupCreaterHeader ?? "", ifThumb: true, thumb_W: 0)), placeholderImage: UIImage.init(named: CUKey.kPlaceHead), options: .retryFailed)
        
        
        self.name = UILabel.label(frame: CGRect.init(x: self.header.right_sd+10, y: 0, width: KScreenWidth-100, height: 20), text: self.groupCreatername ?? "", font: UIFont.systemFont(ofSize: 14), textColor: UIColor.textColor1, textAlignment: .left)
        scroll.addSubview(self.name)
        self.name.bottom_sd = self.header.centerY_sd;
        
        self.time = UILabel.label(frame: CGRect.init(x: self.header.right_sd+10, y: 0, width: KScreenWidth-100, height: 18), text: "", font: UIFont.systemFont(ofSize: 12), textColor: UIColor.textColor2, textAlignment: .left)
        self.time.bottom_sd = self.header.bottom_sd;
        scroll.addSubview(self.time);
        self.time.text = self.groupUpdated ?? ""
        self.notice = AmbitionTextView.init(frame: CGRect.init(x: self.header.left_sd, y: self.header.bottom_sd+15, width: KScreenWidth-24, height:200));
        self.notice.marginEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        self.notice.textView.font = UIFont.systemFont(ofSize: 16);
        self.notice.textView.textColor = UIColor.textColor1;
        self.notice.textView.textAlignment = .left;
        self.notice.maxCount = 100;
        self.notice.textViewValueChanged = {() -> Void in
            print(self.notice.textView.text);
        }
        
        scroll.addSubview(self.notice);
        self.notice.textView.isEditable = false;
        self.notice.textView.isUserInteractionEnabled = false;
        if self.groupNotice.count > 0 {
            self.notice.textString = self.groupNotice;
        }
        self.notice.placeHolder = "请编辑群公告"
        self.notice.textView.returnKeyType = .done
        self.point = UILabel.label(frame: CGRect.init(x: 0, y: 0, width: 200, height: 20), text: "只有群主才可编辑群公告", font: UIFont.systemFont(ofSize: 12), textColor: UIColor.textColor3, textAlignment: .center);
        self.point.centerX_sd = KScreenWidth/2.0;
        self.point.top_sd = KScreenHeight - KBottomHeight;
        scroll.addSubview(self.point)
        
        if ( self.groupNotice.count == 0) {
            self.header.isHidden = true;
            self.name.isHidden = true;
            self.time.isHidden = true;
            self.notice.top_sd = KTopHeight+10;
        }
                
        if UserServre.shareService.userModel.teamid == self.groupCreaterId {
            var right = "编辑"
            if self.groupNotice.count == 0 {
                right = "完成"
                self.notice.textView.isEditable = true
                self.notice.textView.isUserInteractionEnabled = true
                self.notice.textView.becomeFirstResponder()
            }
            self.knavigationBar?.rightBarBtnItem = KNaviBarBtnItem.init(frame: CGRect.init(x: 0, y: 0, width: 60, height: 44), title: right, hander: { [weak self](sender) in
                if self?.knavigationBar?.rightBarBtnItem?.button.titleLabel?.text == "完成"{
                    
                    let content = self?.notice.textView.text ?? "";
                    let groupNotice = self?.groupNotice ?? ""
                    if content.count > 0{
                        self?.publishNotice(notice: content)
                        return
                    }else{
                        if groupNotice.count  == 0{
                            WFHudView.showMsg("请输入公告内容", in: self?.view)
                        }else{
                            PLGlobalClass.alet(withTitle: "确定清空群公告？", message: nil, sureTitle: "确定", cancelTitle: "取消", sureBlock: {
                                self?.publishNotice(notice: "");
                            }, andCancel: {
                                self?.notice.textString = groupNotice
                            }, andDelegate: self!)
                        }
                    }
                    
                }else{
                    self?.knavigationBar?.rightBarBtnItem?.button.setTitle("完成", for: .normal);
                    self?.notice.textView.isUserInteractionEnabled = true;
                    self?.notice.textView.isEditable = true;
                    self?.notice.textView.becomeFirstResponder()
                    WFHudView.showMsg("公告长度不能超过100", in: self?.view)
                }
                
            })
        }
        
    }
    
    func publishNotice(notice: String) -> Void {
        
        self.showGifView()
        ClanAPI.requestForPublicGroupNotice(groupid: self.groupid ?? 0, content: notice) {[weak self] (result) in
            self?.hiddenGifView()
            if result.status == "200"{
                WFHudView.showMsg("群公告发布成功", in: self?.view)
                if self?.backResult != nil{
                    self?.backResult!(notice)
                }
                self?.kBackBtnAction()
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
