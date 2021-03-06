//
//  CULoginVC.swift
//  Clanunity
//
//  Created by 白bex on 2018/2/1.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//
import UIKit
import MJRefresh

//MARK: - ----------------寄思先祖详情
class AncestorsInfo: CommentTabVC {
    /// 聊天室model
    var infoView : UITextView!
    var model : AncestorsModel?
    var pinlun = UIButton()
    
    //MARK: - 加载页面 绘制UI
    override func viewDidLoad() {
        super.viewDidLoad()
        self.infoId = self.model?.id

        self.requestforList()
        
        self.knavigationBar?.title = "详情"
        self.knavigationBar?.rightBarBtnItem = KNaviBarBtnItem.init(frame:  CGRect.init(x: 0, y: KStatusBarHeight, width: 44, height: 44), image: "share_white", hander: {  [weak self](sender) in
            self?.toShare()
        })
    }
    
    //TODO:加载表和详情
    override func maketableView() -> Void {
        super.maketableView()
        
        self.infoView = UITextView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight - KTopHeight))
        self.showGifView()
        
        self.infoView.isUserInteractionEnabled = false
        //子线程 – Swift
        DispatchQueue.global().async { [weak self] in
            //加载html富文本

            let htmlString = "<style> \nbody  img{width:" + String(describing: KScreenWidth - 24) + "!important;height:auto} \n</style> \n" +  (self?.model?.context)!
            
            do {
                let attrString = try NSMutableAttributedString.init(data: (htmlString.data(using: String.Encoding.unicode))!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
                // 主线程 – Swift
                DispatchQueue.main.async {
                    self?.hiddenGifView()
                    self?.infoView.attributedText = attrString;
                    self?.infoView.height_sd = (self?.infoView.contentSize.height)!
                    self?.tableView.tableHeaderView = self?.infoView
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    DispatchQueue.main.async {
                        self?.infoView.height_sd = (self?.infoView.contentSize.height)!
                        self?.tableView.tableHeaderView = self?.infoView
                    }
                }
            }catch{
            }
        }

        self.tableView.height_sd = KScreenHeight - KTopHeight - F_I6(place: 49)
        self.tableView.tableHeaderView = self.infoView

        pinlun = UIButton.init(frame: CGRect.init(x: 0, y: KScreenHeight-F_I6(place: 49), width: KScreenWidth, height: F_I6(place: 49)))
        pinlun.setBackgroundImage(UIImage.init(named: "pinglun_bg"), for: .normal)
        pinlun.backgroundColor = UIColor.white
        self.view.addSubview(pinlun)
        
        pinlun.handleEventTouchUpInside {[weak self] in
            self?.requestForcomment()
        }
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
    
    // MARK: - 分享
    override func toShare() {
        self.shareTitle = self.model?.title
        
        var classid = ""
        if self.pinlunType == "4"{
            classid = "1"
        }
        if self.pinlunType == "5"{
            classid = "2"
        }
        if self.pinlunType == "6"{
            classid = "3"
        }
        
        self.shareUrl = ClanAPI.H5UserName + ClanAPI.H5Share_zongCi + (self.model?.id ?? "") + "&classid=" + classid
        self.shareImgUrl = NSString.formatImageUrl(with: model?.themeimg, ifThumb: true, thumb_W: 100)
        
        PLShareGlobalView.toShare(sharetype : nil, targetid : (self.model?.id)!,  shareTitle: self.shareTitle, shareUrl: self.shareUrl, shareImgUrl: self.shareImgUrl, shareDes: "来自同宗汇", shareimg: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

