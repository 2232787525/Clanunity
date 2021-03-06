//
//  CULoginVC.swift
//  Clanunity
//
//  Created by 白bex on 2018/2/1.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//
import UIKit
import WebKit

//MARK: - ----------------发布动态
class ChatroomVC: WKWebViewController,WKNavigationDelegate,UITextFieldDelegate {
    //KBaseClanViewController
    
    /// 聊天室model
    var model : ChatRoomModel?
    var wkView : WKWebView!
    var bridge = WebViewJavascriptBridge()
    var ifLoadError = false
    
    var input :  ReviewInputView?
    var jsItem : KNaviBarBtnItem?
    
    var emoj = STEmojiKeyboard()
    
    override func viewWillAppear(_ animated: Bool) {
        PLGlobalClass.useIQKeyboard(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        PLGlobalClass.useIQKeyboard(true)
    }
    
    deinit{
        self.wkWebView.stopLoading()
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - 加载页面 绘制UI
    override func viewDidLoad() {
        super.viewDidLoad()
        self.wkWebView.frame = CGRect.init(x: 0, y: KTopHeight, width: KScreenWidth, height: KScreenHeight - KTopHeight - 50 - KBottomStatusH)
        
        jsItem = KNaviBarBtnItem.init(frame:  CGRect.init(x: 0, y: KStatusBarHeight, width: 44, height: 44), title: "") { [weak self](sender) in
            self?.jsBackAction()
        }
//
        self.knavigationBar?.title = self.model?.roomname ?? "聊天大厅"
        self.makeJSBridge()

        //键盘弹出时
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoard(notification: )), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoard(notification: )), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name:NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    func jsBackAction() {
        
        if ifLoadError == false{
            //调用JS端注册的方法
            bridge.callHandler("goBack", data: nil) {[weak self] (responseData) in
                print(responseData ?? "data为空")
                if responseData is Dictionary<String, Any>{
                    let dic = responseData as! Dictionary<String, String>
                    if (dic["status"] == "1" ){
                        self?.wkWebView.stopLoading()
                        self?.navigationController?.popViewController(animated: true)
                    }
                    if (dic["status"] == "2" ){
                        self?.knavigationBar?.title = self?.model?.roomname ?? "聊天大厅名称"
                        self?.input?.isHidden = false
                    }
                }
            }
        }else{
            self.wkWebView.stopLoading()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ifLoadError = false
        self.knavigationBar?.addSubview(jsItem!)
        if input == nil{
            self.makeSendView()
        }
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        ifLoadError = true
    }

    
    func makeSendView(){
        input =  ReviewInputView.init(frame: CGRect.init(x: 0, y: KScreenHeight-KBottomStatusH - 50, width: KScreenWidth, height: 50))
        
        input?.inputText.removeFromSuperview()
        input?.inputText = textField_emoj.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0   ))
        input?.addSubview((input?.inputText)!)
        
        input?.inputText.delegate = self
        input?.inputText.returnKeyType = .done
        input?.inputText.placeholder = "请输入内容"
        input?.inputText.layer.cornerRadius = 5
        input?.inputText.clipsToBounds = true
        input?.inputText.height_sd = 32
        input?.inputText.layer.borderWidth = 0.5
        input?.inputText.layer.borderColor = UIColor.textColor3.cgColor
        input?.inputText.removeTarget(input, action: nil, for: .editingChanged)
        input?.inputText.centerY_sd = 25
        input?.inputText.leftView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 8, height: 0))
        input?.inputText.leftViewMode = .always
        
        
        input?.backgroundColor = UIColor.white
        let line = input?.addBottomLine(color: UIColor.cutLineColor)
        line?.top_sd = 0
        
        input?.send.backgroundColor = UIColor.baseColor
        input?.send.setTitle("发送", for: .normal)
        input?.send.height_sd = 32
        input?.send.width_sd = 46
        input?.send.right_sd = KScreenWidth - 12
        input?.send.centerY_sd = 25

        input?.send.setTitleColor(UIColor.white, for: .normal)
        input?.inputText.width_sd = (input?.send.left_sd)!-5-12 - 40
        input?.inputText.right_sd = (input?.send.left_sd)!-5

        let emoj = STEmojiKeyboard.init()
        
        let emoj_btn = UIButton.init(frame: CGRect.init(x: 12, y: 0, width: 32, height: 32))
        emoj_btn.centerY_sd = (input?.send.centerY_sd)!
        emoj_btn.setImage(UIImage.init(named: "emoj_btn"), for: .normal)
        input?.addSubview(emoj_btn)
        emoj_btn.handleEventTouchUpInside {
            emoj.textView = self.input?.inputText
            self.input?.inputText.reloadInputViews()
            self.input?.inputText.becomeFirstResponder()
        }

        self.view.addSubview(input!)
        
        input?.send.handleEventTouchUpInside {[weak self] in
            self?.input?.inputText.inputView = nil
            self?.input?.inputText.reloadInputViews()
            self?.input?.inputText.resignFirstResponder()
            //调用JS端注册的方法
            if ((self?.input?.inputText.text?.count ?? 0) > 0){
                self?.bridge.callHandler("sendMsg", data: ["text":self?.input?.inputText.text]) { (responseData) in
                }
                self?.input?.inputText.text = ""
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.input?.inputText.resignFirstResponder()
        return true
    }
    
    //键盘的出现
    func keyBoard(notification: Notification){
        //获取userInfo
        let kbInfo = notification.userInfo
        //获取键盘的size
        let kbRect = (kbInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        //键盘的y偏移量
        //键盘弹出的时间
        let duration = kbInfo?[UIKeyboardAnimationDurationUserInfoKey] as!Double

        //界面偏移动画
        UIView.animate(withDuration: duration) {[weak self] in
            if kbRect.origin.y == KScreenHeight{
                self?.input?.bottom_sd = kbRect.origin.y - KBottomStatusH
            }else{
                self?.input?.bottom_sd = kbRect.origin.y
            }
        }
    }
    
    //从后台回到前台
    func didBecomeActive(){
//        self.wkWebView.reload()
        self.bridge.callHandler("reLoad", data: ["roomId":UserServre.shareService.userModel.username,"username":self.model?.areaid ?? "123456"]) { (any) in
        }
    }

    /// 创建web
    func makeJSBridge() -> Void {
        //开启日志
        WebViewJavascriptBridge.enableLogging()
        
        //给Objc与JS建立桥梁
        self.bridge = WebViewJavascriptBridge.init(forWebView: self.wkWebView)
        self.bridge.setWebViewDelegate(self)
        
        self.bridge.registerHandler("gotoUserInfoVC") {[weak self] (data, responseCallback) in
            print(data ?? "data为空")
            let dic = data as! Dictionary<String, String>
            if dic["username"] == UserServre.shareService.userModel.username{
                    let vc = MyInfoVC.init()
                    self?.navigationController?.pushViewController(vc, animated: true)
            }else{
                let vc = StrangerOrFriendVC.init()
                vc.username = dic["username"]
                vc.notPOPWhenDelete = true
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        //跳转成员列表时 刷新导航栏title
        self.bridge.registerHandler("memberIconClick") {[weak self] (data, responseCallback) in
            self?.knavigationBar?.title =  "在线成员"
            self?.input?.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: - ----------------发布动态
class textField_emoj: UITextField {
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        if self.inputView == nil{
        }else{
            self.inputView = nil
            self.reloadInputViews()
        }
        return false
    }
}



final class FauxBarHelper: NSObject {
    @objc var inputAccessoryView: AnyObject? { return nil }
    
    func removeInputAccessoryView(webView: WKWebView) {
        var targetView: UIView? = nil
        
        for view in webView.scrollView.subviews {
            if String(describing: type(of: view)).hasPrefix("WKContent") {
                targetView = view
            }
        }
        
        guard let target = targetView else { return }
        
        let noInputAccessoryViewClassName = "\(target.superclass!)_NoInputAccessoryView"
        var newClass: AnyClass? = NSClassFromString(noInputAccessoryViewClassName)
        if newClass == nil {
            let targetClass: AnyClass = object_getClass(target)!
            newClass = objc_allocateClassPair(targetClass, noInputAccessoryViewClassName.cString(using: String.Encoding.ascii)!, 0)
        }
        
        let originalMethod = class_getInstanceMethod(FauxBarHelper.self, #selector(getter: FauxBarHelper.inputAccessoryView))
        class_addMethod(newClass!.self, #selector(getter: FauxBarHelper.inputAccessoryView), method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        object_setClass(target, newClass!)
    }
}


