//
//  JourneyView.swift
//  WetProject
//
//  Created by 남오승 on 2021/01/11.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import WebKit
import SwiftyTimer

//저니박스 화면 전용 View (SnapKit 라이브러리를 활용하여 소스로만 구성되어 있음.)
class JourneyView: BaseView, WKNavigationDelegate, WKUIDelegate {

    lazy var webView:WKWebView = {
        let webView = WKWebView()
        webView.backgroundColor = .white
        return webView
    }()
    lazy var signUpAlarmPopWrap:UIView = {
        let view = UIView()
        view.setBackgroundColor(r: 253, g: 177, b: 75, alpha: 1)
        view.layer.cornerRadius = 5
        view.alpha = 0.0
        return view
    }()
    lazy var signUpAlarmPopGL:UILabel = {
        let label = UILabel()
        let spacingRatio = aspectRatio(standardSize: 2)
        label.text = "\'저니박스\'와 \'테이스트 저널\'은 현재 분리된 서비스로\n각 서비스를 이용하려면 회원가입 절차를\n모두 진행해주셔야 합니다. "
        label.numberOfLines = 3
        label.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 15)
        label.colorSetting(r: 255, g: 255, b: 255, alpha: 1)
        label.setLinespace(spacing: spacingRatio)
        label.textAlignment = .center
        return label
    }()
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        addContentView()
        autoLayout()
    }
    
    func addContentView() {
        addSubview(webView)
    }
    
    func autoLayout() {
        /* jeokSyeo 웹뷰 상태 서머리 영역 */
        let url = URL(string: "https://jeoksyeo.co.kr")
        
        let request = URLRequest(url: url!)
        
        webView.snp.makeConstraints{ make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.leading.bottom.trailing.equalToSuperview()
            webView.load(request)
        }
        /* */
        
    }
    
    func signUpAlarmPopupSetting() {
        //초기화
        for view in subviews {
            if view == signUpAlarmPopWrap {
                view.removeFromSuperview()
            }
        }
        
        addSubview(signUpAlarmPopWrap)
        signUpAlarmPopWrap.addSubview(signUpAlarmPopGL)
        
        signUpAlarmPopWrap.alpha = 0.0
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.signUpAlarmPopWrap.alpha = 0.95
        })
        
        signUpAlarmPopWrap.snp.makeConstraints { (make) in
            let height = aspectRatio(standardSize: 78)
            make.height.equalTo(height)
            make.leading.equalTo(16)
            make.trailing.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
        }
        signUpAlarmPopGL.snp.makeConstraints { (make) in
            let fontSize = aspectRatio(standardSize: 15)
            signUpAlarmPopGL.font = signUpAlarmPopGL.font.withSize(fontSize)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
            make.top.equalTo(10)
            make.bottom.equalTo(-10)
        }
        
        let timer = Timer.new(every: 10.0.second) {}
        timer.start(modes: .tracking)
        Timer.every(10.0.second) { [weak self] (timer: Timer) in
            timer.invalidate()

            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.signUpAlarmPopWrap.alpha = 0.0
            })
        }
    }
}

