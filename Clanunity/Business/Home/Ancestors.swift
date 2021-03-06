import UIKit

//MARK: - ----------------寄思先祖页
class Ancestors: KBaseClanViewController {
    

    var bg = UIImageView()
    var animation : LewPopupViewAnimationSlide?
    var alterV : JisiAlterView?
    var xiangNum = 0
    var xingli_ing = false //行李中

    var gonpinArr = [String]() //贡品桌Arr
    var huaArr = [String]() //鲜花Arr

    /// 香
    var xiang = UIImageView()
    /// 桌子
    var zhuo = UIImageView()
    /// 贡品1
    var gongpin1 = UIImageView()
    /// 贡品2
    var gongpin2 = UIImageView()
    /// 花
    var hua = UIImageView()
    /// 人
    var ren = UIImageView()

    let centerGonpinFrame = CGRect.init(x: F_I6(place: 168), y: F_I6(place: 339), width: F_I6(place: 44), height: F_I6(place: 31))
    let leftGonpinFrame = CGRect.init(x: F_I6(place: 144), y: F_I6(place: 339), width: F_I6(place: 44), height: F_I6(place: 31))
    let rightGonpinFrame = CGRect.init(x: F_I6(place: 193), y: F_I6(place: 339), width: F_I6(place: 44), height: F_I6(place: 31))
    let huaFrame = CGRect.init(x: F_I6(place: 167), y: F_I6(place: 386), width: F_I6(place: 44), height: F_I6(place: 37))
    let renFrame = CGRect.init(x: F_I6(place: 157), y: F_I6(place: 320), width: F_I6(place: 61), height: F_I6(place: 194))

    
    //MARK: - 加载页面 绘制UI
    override func viewDidLoad() {
        super.viewDidLoad()
        GlobalClass.single_event(eventName: CUKey.UM_jisi)
        
        self.knavigationBar?.cutlineColor = UIColor.clear
        self.knavigationBar?.title = "寄思先祖"
        
        //TODO:右按钮下拉三个选项
        self.knavigationBar?.rightBarBtnItem = KNaviBarBtnItem.init(frame: CGRect.init(x: KScreenWidth-44, y: KStatusBarHeight, width: 44, height: 44), image: "more") {[weak self] (sender) in
            
            let titles = ["姓氏名人","姓氏源流","线下宗祠"]

            let alert = pulldownalterView.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight), title : titles)
            self?.view.addSubview(alert)
            
            alert.show()
            alert.callBlock(block: { (index) in
                
                let list = AncestorsList.init()
                self?.navigationController?.pushViewController(list, animated: true)
                
                if index == 0{
                    list.knavigationBar?.title = "姓氏名人"
                    list.shoupin = "xsmr"
                    list.pinlunType = "4"
                    print("姓氏名人")
                    //测试线下宗祠列表UI
                }else if index == 1{
                    print("姓氏源流")
                    list.knavigationBar?.title = "姓氏源流"
                    list.shoupin = "xsyl"
                    list.pinlunType = "5"
                }else if index == 2{
                    print("线下宗祠")
                    list.knavigationBar?.title = "线下宗祠"
                    list.shoupin = "xxzc"
                    list.ifZongci = true
                    list.pinlunType = "6"
                }
            })
        }
        
        self.createView()
        self.writeOrGetData(ifwrite: false)
    }
    
    func createView(){
        //背景图
        bg = UIImageView.init(frame: CGRect.init(x: 0, y: KTopHeight, width: KScreenWidth, height: KScreenHeight-KTopHeight))
        bg.image = UIImage.init(named: "ancestor")
        bg.isUserInteractionEnabled = true
        self.view.addSubview(bg)
        
        //鼎
        let ding = UIImageView.init(frame: CGRect.init(x: 0, y: F_I6(place: 273), width: F_I6(place: 156), height: F_I6(place: 98)))
        ding.image = UIImage.init(named: "ding")
        bg.addSubview(ding)
        ding.centerX_sd = bg.centerX_sd
        
        //香
        xiang = UIImageView.init(frame: CGRect.init(x: F_I6(place: 170), y: F_I6(place: 239), width: F_I6(place: 36), height: F_I6(place: 54)))
        xiang.image = UIImage.init(named: "")
        bg.addSubview(xiang)
        xiang.isHidden = true
        
        //桌子
        zhuo = UIImageView.init(frame: CGRect.init(x: F_I6(place: 124), y: F_I6(place: 362), width: F_I6(place: 130), height: F_I6(place: 43)))
        zhuo.image = UIImage.init(named: "zhuozi")
        zhuo.isHidden = true
        bg.addSubview(zhuo)
        
        //贡品1
        gongpin1 = UIImageView.init(frame: leftGonpinFrame)
        gongpin1.image = UIImage.init(named: "jisi_zhu")
        gongpin1.isHidden = true
        bg.addSubview(gongpin1)
        
        //贡品2
        gongpin2 = UIImageView.init(frame: rightGonpinFrame)
        gongpin2.image = UIImage.init(named: "jisi_apple")
        gongpin2.isHidden = true
        bg.addSubview(gongpin2)
        
        //花
        hua = UIImageView.init(frame: huaFrame)
        hua.image = UIImage.init(named: "jisi_hua")
        hua.isHidden = true
        bg.addSubview(hua)
        
        //人
        ren = UIImageView.init(frame: renFrame)
        ren.image = UIImage.init(named: "jugong")
        ren.isHidden = true
        bg.addSubview(ren)
        
        //贡品弹窗
        self.setAlter()
        
        let arr = ["jisi_shangxiang","jisi_gongpin","jisi_flower","jisi_xingli"]
        //下面四个按钮
        self.setIcon(arr: arr)
    }
    
    //TODO:贡品弹窗
    func setAlter() {
        let tap = UITapGestureRecognizer.bk_recognizer(handler: {[weak self] (tap, state, point) in
            self?.altershow(show: false, type: 0 , thingsArr: nil)
        })
        bg.addGestureRecognizer(tap as! UIGestureRecognizer)
        

        alterV = JisiAlterView.init(frame:CGRect.init(x: 0, y: F_I6(place: 300), width: F_I6(place: 218), height: F_I6(place: F_I6(place: 156))), parentVC: self, dismiss: self.animation)
        alterV?.centerX_sd = self.view.centerX_sd
        self.view.addSubview(alterV!)
        alterV?.height_sd = 0
        alterV?.bottom_sd = F_I6(place: 575)
        alterV?.alpha = 0
        alterV?.selectedIndexBlock = {[weak self] (index) -> () in
            //弹窗消失
            self?.altershow(show: false, type: 0 , thingsArr: nil)
            
            if (self?.alterV?.type == 0){
                
                if index == 0{
                    if(self?.xiangNum == 10){
                        WFHudView.showMsg("上香不在多少，贵在心诚，三支为宜！", in: self?.view)
                    }else{
                        
                        if (self?.xiangNum)! + 1 <= 3 {
                            self?.xiangNum = (self?.xiangNum)! + 1
                            self?.reloadxiang()
                        }else{
                            WFHudView.showMsg("上香不在多少，贵在心诚，三支为宜！", in: self?.view)
                        }
                    }
                }
                
                if index == 1{
                    if ((self?.xiangNum)! > 0 && (self?.xiangNum)! != 10){
                        WFHudView.showMsg("上香不在多少，贵在心诚，三支为宜！", in: self?.view)
                    }else if(self?.xiangNum == 10){
                        WFHudView.showMsg("上香不在多少，贵在心诚，三支为宜！", in: self?.view)
                    }else{
                        self?.xiangNum = 10
                        self?.reloadxiang()
                    }
                }
                
            }else if (self?.alterV?.type == 1){

                if ( self?.gonpinArr.contains(self?.alterV?.thingsArr[index] as! String))!{
                    WFHudView.showMsg("该贡品已存在", in: self?.view)
                }else if(self?.gonpinArr.count == 2){
                    WFHudView.showMsg("贡品桌已摆满", in: self?.view)
                }else{
                    self?.gonpinArr.append(self?.alterV?.thingsArr[index] as! String)
                    self?.reloadGonpinZhuo(ifanimation: true)
                }
                
            }else if (self?.alterV?.type == 2){
                
                if(self?.huaArr.count == 1){
                    WFHudView.showMsg("已经献过花了", in: self?.view)
                }else{
                    self?.huaArr.append(self?.alterV?.thingsArr[index] as! String)
                    self?.reloadhua()
                }
                
            }else if (self?.alterV?.type == 3){
            }
            self?.writeOrGetData(ifwrite: true)
        }
    }
    
    //TODO:贡品弹窗的出现与消失
    func altershow(show : Bool ,type :NSInteger, thingsArr : Array<String>?) {
        if alterV != nil{

            if show{
                self.alterV?.type = type
                self.alterV?.thingsArr = thingsArr
                
                UIView.animate(withDuration: 0.3, animations: { [weak self] in
                    self?.alterV?.height_sd = F_I6(place: 156)
                    self?.alterV?.alpha = 1
                    self?.alterV?.top_sd = F_I6(place: 300)
                })
                
            }else{
                
                UIView.animate(withDuration: 0.15, animations: {[weak self] in
                    self?.alterV?.bottom_sd = F_I6(place: 575)

                }, completion: { (boo) in
                    UIView.animate(withDuration: 0.2, animations: {[weak self] in
                        self?.alterV?.height_sd = 0
                        self?.alterV?.alpha = 0
                        self?.alterV?.bottom_sd = F_I6(place: 575)
                    })
                })
            }
        }
    }
    
    //TODO:贡品信息的读取和写入
    func writeOrGetData(ifwrite : Bool) {
        
        if ifwrite{
            let dic = [CUKey.kAncestor_xiang:self.xiangNum,CUKey.kAncestor_gongpin:self.gonpinArr,CUKey.kAncestor_hua:self.huaArr,CUKey.kAncestor_time:Date()] as [String : Any];
            PLGlobalClass.write(toFile: CUKey.kAncestor, withKey: UserServre.shareService.userModel.username, value: dic)
            
        }else{
            let dic = PLGlobalClass.getValueFromFile(CUKey.kAncestor, withKey: UserServre.shareService.userModel.username) as? Dictionary<String, Any>
            if dic == nil{
                return
            }
            let time = dic![CUKey.kAncestor_time]
            if (time is Date){
                if PLGlobalClass.ifToday(time as! Date){
                    xiangNum = dic![CUKey.kAncestor_xiang] as! Int
                    gonpinArr = dic![ CUKey.kAncestor_gongpin] as! Array
                    huaArr = dic![ CUKey.kAncestor_hua] as! Array
                    
                    self.reloadxiang()
                    self.reloadGonpinZhuo(ifanimation: false)
                    self.reloadhua()
                }
            }
        }
    }

    //TODO:加载香炉
    func reloadxiang(){

        self.xiang.image = UIImage.init(named: "xiang_" + String(self.xiangNum) )
        self.xiang.isHidden = false
    }
    
    //TODO:加载贡品桌
    func reloadGonpinZhuo(ifanimation : Bool ){
        
        if self.gonpinArr.count == 1{
            zhuo.isHidden = false
            gongpin1.isHidden = false
            gongpin1.frame = centerGonpinFrame
            gongpin1.image = UIImage.init(named: self.gonpinArr[0])
        }
        
        if self.gonpinArr.count == 2{
            zhuo.isHidden = false
            gongpin1.isHidden = false
            gongpin1.frame = centerGonpinFrame
            gongpin1.image = UIImage.init(named: self.gonpinArr[0])

            if ifanimation{
                
                UIView.animate(withDuration: 0.5, animations: { [weak self] in
                    self?.gongpin1.frame = (self?.leftGonpinFrame)!
                }, completion: {[weak self] (finish) in
                    self?.gongpin2.isHidden = false
                    self?.gongpin2.image = UIImage.init(named: (self?.gonpinArr[1])!)
                    self?.gongpin2.frame = (self?.rightGonpinFrame)!
                })
            }else{
                self.gongpin1.frame = self.leftGonpinFrame
                self.gongpin2.isHidden = false
                self.gongpin2.image = UIImage.init(named: self.gonpinArr[1])
                self.gongpin2.frame = self.rightGonpinFrame
            }
        }
    }
    
    //TODO:加载鲜花
    func reloadhua(){
        if self.huaArr.count>0{
            hua.isHidden = false
            hua.image = UIImage.init(named: self.huaArr[0])
        }else{
            hua.isHidden = true
        }
    }
    
    //TODO:四个icon
    func setIcon(arr : Array<String>) {
        
        let W = F_I6(place: 60)
        let H = F_I6(place: 60)//F_I6(place: 56)   62
        
        var toTop = F_I6(place: 0)
        if KScreenHeight == 480{
            toTop = KScreenHeight - H - 10
        }else{
            toTop = F_I6(place: 575)
        }
        let toLeft = F_I6(place: 39)
        
        let betw = (KScreenWidth - toLeft*2 - W*4)/3

        for i in 0...arr.count-1{
            let icon = UIImageView.init(frame: CGRect.init(x: toLeft+CGFloat(i%4)*(W+betw), y: toTop + CGFloat(i/4)*(H+toTop), width: W, height: H))
            
            icon.tag = 20+i
            icon.image = UIImage.init(named: arr[i])
            icon.isUserInteractionEnabled = true
            self.view.addSubview(icon)
            
            let tap = UITapGestureRecognizer.bk_recognizer(handler: {[weak self] (tap, state, point) in
                
                if i == 3{
                    //TODO:行李
                    if self?.xingli_ing == false{
                        self?.xingli_ing = true
                        self?.ren.isHidden = false
                        self?.ren.image = UIImage.sd_animatedGIFNamed("jugong")
                        self?.ren.alpha = 0.99
                        
                        UIView.animate(withDuration: 12, animations: {
                            self?.ren.alpha = 1
                        }, completion: { (finish) in
                            
                            UIView.animate(withDuration: 0.3, animations: {
                                self?.ren.alpha = 0
                                self?.xingli_ing = false
                            })
                        })
                    }
                }else{
                    var arr = [String]()
                    if i == 0{
                        arr = ["alter_xiang1","alter_xiang3"]
                    }
                    if i == 1{
                        arr = ["jisi_zhu","jisi_apple"]
                    }
                    if i == 2{
                        arr = ["jisi_hua1","jisi_hua2"]
                    }
                    self?.altershow(show: true, type: i,thingsArr: arr)
                }
            })
            icon.addGestureRecognizer(tap as! UIGestureRecognizer)
        }
    }
    
    func renhidden(){
        UIView.animate(withDuration: 12, animations: { [weak self] in
            self?.ren.isHidden = true
        }, completion: { (finish) in
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



//MARK: - ----------------下拉选择框
class pulldownalterView: UIView {
    
    typealias indexBlock = (NSInteger)->()
    var block:indexBlock?
    
    func callBlock(block:indexBlock?) {
        self.block = block
    }
    
    var selectheight = CGFloat(0)
    var titles = Array<String>()
    
    lazy var alphaBtn: UIButton = {
        let tempbtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: KScreenWidth, height: KScreenHeight))
        tempbtn.backgroundColor = UIColor.black
        tempbtn.alpha = 0
        tempbtn.handleEventTouchUpInside(callback: {
            self.close()
        })
        return tempbtn
    }()
    
    lazy var selectView: UIView = {
        

        let tempView = UIView.init(frame: CGRect.init(x: 0, y: KTopHeight, width: 95, height: 132))
        tempView.backgroundColor = UIColor.white
        tempView.right_sd = KScreenWidth-5 //距离右边的距离
        tempView.clipsToBounds = true
        
        for i in 0 ... self.titles.count-1{
            
            let btn = UIButton.init(frame: CGRect.init(x: 0, y:CGFloat(i) * 44, width: 95, height: 44))
            btn.setTitle(self.titles[i], for: .normal)
            btn.setTitleColor(UIColor.textColor1,for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            tempView.addSubview(btn)
            btn.handleEventTouchUpInside(callback: {[weak self] in
                if let block  =  self?.block {
                    block(i)
                }
                self?.close()
            })
        }
        return tempView
    }()
    
    init(frame: CGRect , title: Array<String>) {
        super.init(frame: frame)
        self.titles = title
        
        self.addSubview(self.alphaBtn)
        self.addSubview(self.selectView)
        self.selectheight = self.selectView.height_sd
        self.selectView.height_sd = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func close(){
        UIView.animate(withDuration: 0.25, animations: {
            self.selectView.height_sd = 0
            self.alphaBtn.alpha = 0
        }) { (finish) in
            self.selectView.removeFromSuperview()
            self.alphaBtn.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
    
    func show(){
        UIView.animate(withDuration: 0.25, animations: {
            self.selectView.height_sd = self.selectheight
            self.alphaBtn.alpha = 0.25
        }) { (finish) in
            
        }
    }

}







