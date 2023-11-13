//
//  PolicyVC.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/18.
//

import UIKit
import WebKit
import RxCocoa
import RxSwift

//개인정보 처리방침, 서비스 이용약관 화면 UI를 컨트롤 하기위한 파일
class PolicyVC: UIViewController {
    
    //0 : 이용 약관
    //1 : 개인정보 취급 방침
    var policyFlag:Int = 0
    
    @IBOutlet weak var policyWebView: WKWebView!
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var headerGL: UILabel!
    
    var url:String = ""
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if policyFlag == 0 {
            headerGL.text = "이용약관"
            url = "https://policy.jeoksyeo.com/policy/service.html"
        }else {
            headerGL.text = "개인정보 취급 방침"
            url = "https://policy.jeoksyeo.com/policy/privacy.html"
        }
        
        let url = URL(string: self.url)
        
        let request = URLRequest(url: url!)
        policyWebView.load(request)
        
        backBtn.rx.tap
            .asDriver()
            .drive(onNext: {[weak self] _ in 
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        //스와이프 해서 뒤로가기 허용
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        disposeBag = DisposeBag()
    }
}
