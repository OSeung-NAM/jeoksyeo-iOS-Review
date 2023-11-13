//
//  journeyVC.swift
//  WetProject
//
//  Created by 남오승 on 2021/01/11.
//

import UIKit
import WebKit

//저니박스 화면 View 파일을 컨트롤 하기위한 파일
class JourneyVC:BaseViewController, WKNavigationDelegate {
    let journeyView = JourneyView()
    
    //window.open()으로 열리는 새창
    var createWebView: WKWebView?
    
    override func viewDidLoad() {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(isInternetAvailable)(){
            log.info("Network Connected")
        } else {
            netWorkStateToast(errorIndex: 0)
            log.info("Network DisConnected")
            return
        }
        view = journeyView
        journeyView.webView.uiDelegate = self
        
        journeyView.webView.navigationDelegate = self
        
        journeyView.webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        journeyView.signUpAlarmPopupSetting()
    }
    
}


extension JourneyVC: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Swift.Void) {
        
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert);
        
        let cancelAction = UIAlertAction(title: "확인", style: .cancel) {
            _ in completionHandler()
        }
        
        alertController.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        //뷰를 생성하는 경우
        let frame = UIScreen.main.bounds
        
        //파라미터로 받은 configuration
        createWebView = WKWebView(frame: frame, configuration: configuration)
        
        //오토레이아웃 처리
        createWebView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        createWebView?.navigationDelegate = self
        createWebView?.uiDelegate = self
        
        
        view.addSubview(createWebView!)
        
        return createWebView!
        
        /* 현재 창에서 열고 싶은 경우
         self.webView.load(navigationAction.request)
         return nil
         */
    }
    
    //새창 닫기
    //iOS9.0 이상
    func webViewDidClose(_ webView: WKWebView) {
        if webView == createWebView {
            createWebView?.removeFromSuperview()
            createWebView = nil
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.scheme != "http" && url.scheme != "https" {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
