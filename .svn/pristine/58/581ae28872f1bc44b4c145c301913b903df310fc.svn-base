//此页面内容：
//        1.空视图
//        2.一个普通弹窗 标题 确定取消按钮
//        3.创建表
//        4.请求列表方法

//继承该类后应该做的事：
//        1.重写请求列表方法
//        2.写表的各种代理方法


import UIKit
import MJRefresh

//MARK: - ----------------列表基类

class BaseTabVC: KBaseClanViewController,UITableViewDelegate {
    
    var tableView = UITableView()
    var footerview = UIView()
    /// 页数
    var pno = 1
    /// 每页个数
    var pnu = 20
    
    /// 弹窗
    lazy var animation : LewPopupViewAnimationSlide = {
        let anima = LewPopupViewAnimationSlide.init()
        anima.type = LewPopupViewAnimationSlideType.bottomBottom
        return anima
    }()
    lazy var alterV : msgAlterView = {
        let alterView = msgAlterView.init(frame: CGRect.init(x: 0, y: 0, width: F_I6(place: 251), height: 102), parentVC: self, dismiss: self.animation, title: "您还未实名认证")
        return alterView!
    }()
    
    lazy var emptyView: EmptySwiftView = {
        let tempView = EmptySwiftView.showEmptyView(emptyPicName: "empty_comment", describe: "暂无评论，赶快抢个沙发吧！")
        tempView.centerX_sd = KScreenWidth/2.0
        return tempView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.maketableView()
    }
    
    //MARK: - tableView
    func maketableView(){
        self.tableView = UITableView.init(frame: CGRect.init(x: 0, y: KTopHeight, width: KScreenWidth, height: KScreenHeight - KTopHeight - F_I6(place: 50)), style: UITableViewStyle.grouped)
        self.settableView()
    }
    
    //MARK: - tableView
    func settableView(){
        
        self.tableView.backgroundColor = UIColor.white
        self.tableView.delegate=self
        self.view.addSubview(self.tableView)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorColor = UIColor.cutLineColor
        tableView.separatorInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        
        let mjheader = MJRefreshGifHeader.init { [weak self] in
            self?.pno=1;
            self?.requestforList()
        }
        GlobalClass.setMjHeader(mjheader: mjheader!)
        tableView.mj_header = mjheader
        
        self.tableView.mj_footer = MJRefreshAutoNormalFooter{ [weak self] in
            if self != nil{
                self?.pno = (self?.pno)! + 1
                self?.requestforList()
            }
        }
        self.tableView.mj_footer.isHidden = true
        
        self.showGifView()
        self.requestforList()
        
        /// 自动关闭估算高度，不想估算那个，就设置那个即可
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        
        footerview = UIView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: 0))
        footerview.addSubview(emptyView)
        emptyView.top_sd = 40
        footerview.clipsToBounds = true
        tableView.tableFooterView = footerview
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        return view
    }
    
    func requestforList(){
    }
    
    //Pno-1
    func loadPno(){
        if self.pno > 1 {
            self.pno = self.pno - 1
        }
    }
    
    func emptyShow(show:Bool){
        if show{
            footerview.height_sd = 180
        }else{
            footerview.height_sd = 0
        }
    }
    
    //TODO: - 请求详情
    func requestforDetail(){
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



