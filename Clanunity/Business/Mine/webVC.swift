//
//  CULoginVC.swift
//  Clanunity
//
//  Created by 白bex on 2018/2/1.
//  Copyright © 2018年 DlmTechnology. All rights reserved.
//
import UIKit
import WebKit

//MARK: - ----------------wkwebview
class webVC: WKWebViewController,WKNavigationDelegate {

    var urlStr = ""
    var titleStr = ""
    var bridge = WebViewJavascriptBridge()
    var getWebTitle = false
    var responseCallback : WVJBResponseCallback?
    
    
    override func kBackBtnAction() {
        
        if wkWebView.canGoBack{
            wkWebView.goBack()
        }else{
            self.wkWebView.stopLoading()
            super.kBackBtnAction()
        }
    }
    
    //MARK: - 加载页面 绘制UI
    override func viewDidLoad() {
        super.viewDidLoad()
        self.knavigationBar?.title = titleStr
        
        self.wkWebView.frame = CGRect.init(x: 0, y: KTopHeight, width: KScreenWidth, height: KScreenHeight - KTopHeight)
        self.makeJSBridge()
    }
    
    /// 创建web
    func makeJSBridge() -> Void {
        //开启日志
        WebViewJavascriptBridge.enableLogging()
        
        //给Objc与JS建立桥梁
        self.bridge = WebViewJavascriptBridge.init(forWebView: self.wkWebView)
        self.bridge.setWebViewDelegate(self)

        
        //注册JS交互 ：关闭页面
        self.bridge.registerHandler("closeVC") { [weak self] (data, responseCallback) in
            self?.wkWebView.stopLoading()
            self?.navigationController?.popViewController(animated: true)
        }
        
        //注册JS交互 ：关闭页面
        self.bridge.registerHandler("takePhoto") { [weak self] (data, responseCallback) in
            
            self?.responseCallback = responseCallback

            PLGlobalClass.openAlter(withMaxNumber: 3, blockHandler: { (array) in
                
                for assestModel in array!{
                    let model = assestModel as? ZLPhotoAssets
                    let image = model?.originImage
                    let qualitydata = PLGlobalClass.compressImageQuality(image)
                    if qualitydata != nil{
                        self?.upload(file: qualitydata!)
                    }
                }
            })
        }
    }


    func upload(file:Data){
        ClanAPI.clanRequestPOST_Updatefile(.IMG, files: [file] , progress:
            { (progress) in
        }, success: {[weak self] (_, result ) in
            
            if (result is Dictionary<String,Any>){
                let dic = result as! Dictionary<String,Any>
                
                if (dic["data"] is Array<Dictionary<String,Any>>){
                    let arr = dic["data"] as! Array<Dictionary<String,Any>>
                    let uploadarr = uploadfilesModel.mj_objectArray(withKeyValuesArray: arr)
                    
                    if uploadarr != nil{
                        
                        let model2 = uploadarr?.firstObject as? uploadfilesModel
                        if (self?.responseCallback != nil && ((model2?.path.count ?? 0) > 0)){
                            self?.responseCallback!(["path":model2!.path])
                        }
                    }
                }else{
                    WFHudView.showMsg("不好意思，图片上传失败了", in: self?.view)
                }
            }
            
        }, faile: {[weak self] (_, error) in
            WFHudView.showMsg("不好意思，图片上传失败了", in: self?.view)
        })
    }
    
    //MARK: - UIImagePickerControllerDelegate选择好图片的回调
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if (info["UIImagePickerControllerMediaType"] as? String == "public.movie") {
        }else{
            //拿到选择的图片
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            let qualitydata = PLGlobalClass.compressImageQuality(image)
            if qualitydata != nil{
                self.upload(file: qualitydata!)
            }
            //相册消失
            picker.dismiss(animated: true, completion: nil)
//            if (self.responseCallback != nil){
//                self.responseCallback!(["path":path])
//            }
        }
    }
    
    //MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.knavigationBar?.title = self.wkWebView.title
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
