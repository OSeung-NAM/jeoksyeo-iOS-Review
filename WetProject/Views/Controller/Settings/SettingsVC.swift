//
//  SettingsVC.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/13.
//

import UIKit
import RxCocoa
import RxSwift
import ReactorKit
import RxGesture

//설정화면 UI를 컨트롤 하기위한 파일
class SettingsVC: BaseViewController, StoryboardView {

    let settingsRT = SettingsRT()
    
    //회원정보 수정 감싸는 뷰
    @IBOutlet weak var infoUpdateWrap: UIView!
    //앱버전 감싸는 뷰
    @IBOutlet weak var appVersionWrap: UIView!
    //회원탈퇴 감싸는 뷰
    @IBOutlet weak var userOutWrap: UIView!
    //뒤로가기 버튼
    @IBOutlet weak var backBtn: UIButton!
    //앱버전 조회 Label
    @IBOutlet weak var appVersionGL: UILabel!
    //이용약관 감싸는 뷰
    @IBOutlet weak var serviceTermsWrap: UIView!
    //개인정보 취급 방침 감싸는 뷰
    @IBOutlet weak var userPolicyWrap: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        reactor = settingsRT
        uiInit()
    }
    
    func bind(reactor: SettingsRT) {
        
        /* btnEvent */
        
        //뒤로가기
        backBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.backEvent()
            })
            .disposed(by: disposeBag)
        
        //유저정보 변경
        infoUpdateWrap.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext:{ _ in
                reactor.action.onNext(.userUpdate)
            })
            .disposed(by: disposeBag)
        
        //이용약관
        serviceTermsWrap.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext:{ [weak self] _ in
                self?.policyMove(policyFlag: 0)
            })
            .disposed(by: disposeBag)
        
        //개인정보 취급 방침
        userPolicyWrap.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext:{ [weak self] _ in
                self?.policyMove(policyFlag: 1)
            })
            .disposed(by: disposeBag)
        
        //회원탈퇴
        userOutWrap.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext:{ [weak self] _ in
                self?.userOutEvent()
            })
            .disposed(by: disposeBag)
        
        /* */
        
        /* action */
        
        if(isInternetAvailable)(){
            log.info("Network Connected")
        } else {
            netWorkStateToast(errorIndex: 0)
            log.info("Network DisConnected")
            return
        }
        
        reactor.action.onNext(.appVersion)
        
        /* */
        
        /* state */
        
        let isAppVersion = reactor.state.map{$0.isAppVerion}.filter{$0 != nil}
        let isUserOut = reactor.state.map{$0.isUserOut}.filter{$0 != nil}
        let isUserUpdateMove = reactor.state.map{$0.isUserUpdate}.filter{$0 != nil}
        let isIndicator = reactor.state.map{$0.isIndicator}.filter{$0 != nil}.map{$0 ?? false}
        let isError = reactor.state.map{$0.isErrors}.filter{$0.0 != nil}
        let isTokenError = reactor.state.map{$0.isTokenError}.filter{$0.0 != nil}
        
        let isTimeOut = reactor.state.map{$0.isTimeOut}.filter{$0 != nil}.map{$0 ?? false}
        
        //서버 타임아웃 에러
        isTimeOut
            .bind{[weak self] result in
            if result {
                self?.netWorkStateToast(errorIndex: 408)
            }
        }.disposed(by: disposeBag)

        //에러 여부
        isError.bind{ [weak self] result in
            if (result.0 ?? false) { //일반 API 에러
                self?.netWorkStateToast(errorIndex: 1)
            }
        }.disposed(by: disposeBag)
        
        //유효하지 않은 토큰 에러
        isTokenError
            .observeOn(MainScheduler.asyncInstance)
            .bind{[weak self] result in
            if (result.0 ?? false) { //유효하지 않은 토큰이면 그냥 로그아웃시키고 에러 문구띄워줌
                UserDefaults.standard.setValue(nil, forKey: "accessToken")
                UserDefaults.standard.setValue(nil, forKey: "refreshToken")
                self?.netWorkStateToast(errorIndex: 2)
            }
        }.disposed(by: disposeBag)
        
        isIndicator.bind{[weak self] result in self?.loadingIndicator(flag: result)}.disposed(by: disposeBag)
        
        //앱 버전
        isAppVersion
            .bind{[weak self] result in
                self?.appVersionGL.text = "v " + (result?.version ?? "")
            }.disposed(by: disposeBag)
        
        //회원 탈퇴
        isUserOut
            .bind{[weak self] result in
                if result ?? false {
                    UserDefaults.standard.setValue(nil, forKey: "accessToken")
                    UserDefaults.standard.setValue(nil, forKey: "refreshToken")
                    self?.backEvent()
                }
            }.disposed(by: disposeBag)
        
        //회원정보 수정 이동
        isUserUpdateMove
            .bind{[weak self] result in
                if result ?? false {
                    self?.userInfoUpdateMove()
                }
            }.disposed(by: disposeBag)
        
        /* */
        
        /* 토큰 관리 (공통) */
        
        //로그인 여부 체크
        reactor.state.map{ $0.isLogin }
            .filter{$0 != nil}
            .subscribe(onNext:{ result in
                if !(result ?? true) { //로그아웃 시
                    LoginService.shared.login(callingView: self as Any)
                }
            })
            .disposed(by: disposeBag)
        
        //토큰 갱신
        reactor.state.map{$0.isTokenRenewal}
            .observeOn(MainScheduler.asyncInstance)
            .filter{$0 != nil}
            .subscribe(onNext:{ result in
                reactor.action.onNext(.accessTokenSave(result))
            }).disposed(by: disposeBag)
        
        //토큰 갱신 후 -> 내장 저장 -> 기존에 실행하려 했던 이벤트 실행
        reactor.state.map{$0.isAccessTokenSave}
            .observeOn(MainScheduler.asyncInstance)
            .filter{$0 != nil}
            .subscribe(onNext: { result in
                if result?.saveFlag ?? false {
                    if result?.eventIndex == 0 { //앱 버전 조회
                        reactor.action.onNext(.appVersion)
                    }else if result?.eventIndex == 1 { //회원 탈퇴
                        reactor.action.onNext(.userOut)
                    }else if result?.eventIndex == 2 { //유저 정보 번경이동
                        reactor.action.onNext(.userUpdate)
                    }
                }else { //갱신 실패
                    log.error("Token Renewal Fail")
                }
            })
            .disposed(by: disposeBag)
        
        /* */
        
    }

    func backEvent() {
        navigationController?.popViewController(animated: true)
    }
    
    //앱 버젼 가져오는 서비스 호출
    func getAppVersion() {
        if let reactor = self.reactor {
            reactor.action.onNext(.appVersion)
        }
    }
    
    //회원정보 수정화면 이동
    func userInfoUpdateMove() {
        if(isInternetAvailable)(){
            log.info("Network Connected")
        } else {
            netWorkStateToast(errorIndex: 0)
            log.info("Network DisConnected")
            return
        }
        
        let userInfoUpdateVC = StoryBoardName.myPageStoryBoard.instantiateViewController(withIdentifier: "UserInfoUpdateVC") as! UserInfoUpdateVC

        navigationController?.pushViewController(userInfoUpdateVC, animated: true)
    }
    
    //정책 화면으로 이동
    func policyMove(policyFlag:Int) {
        let policyVC = StoryBoardName.policyStoryBoard.instantiateViewController(withIdentifier: "PolicyVC") as! PolicyVC

        policyVC.policyFlag = policyFlag
        navigationController?.pushViewController(policyVC, animated: true)
    }
    
    //회원탈퇴 이벤트
    func userOutEvent() {
        if(isInternetAvailable)(){
            log.info("Network Connected")
        } else {
            netWorkStateToast(errorIndex: 0)
            log.info("Network DisConnected")
            return
        }
        let customAlertPopVC = StoryBoardName.popupStoryBoard.instantiateViewController(withIdentifier: "CustomAlertPopVC") as! CustomAlertPopVC
        customAlertPopVC.modalPresentationStyle = .overCurrentContext
        customAlertPopVC.alertFlag = 0
        present(customAlertPopVC, animated: false, completion: nil)
    }
}

extension SettingsVC {
    func uiInit() {
        
        //스와이프 해서 뒤로가기 허용
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        infoUpdateWrap.borderAll(width: 0.5, color: UIColor(red: 196/255, green: 196/255, blue: 196/255, alpha: 1.0).cgColor)
        appVersionWrap.borderAll(width: 0.5, color: UIColor(red: 196/255, green: 196/255, blue: 196/255, alpha: 1.0).cgColor)
        serviceTermsWrap.borderAll(width: 0.5, color: UIColor(red: 196/255, green: 196/255, blue: 196/255, alpha: 1.0).cgColor)
        userPolicyWrap.borderAll(width: 0.5, color: UIColor(red: 196/255, green: 196/255, blue: 196/255, alpha: 1.0).cgColor)
        userOutWrap.borderAll(width: 0.5, color: UIColor(red: 196/255, green: 196/255, blue: 196/255, alpha: 1.0).cgColor)
        infoUpdateWrap.layer.cornerRadius = 5.0
        appVersionWrap.layer.cornerRadius = 5.0
        serviceTermsWrap.layer.cornerRadius = 5.0
        userPolicyWrap.layer.cornerRadius = 5.0
        userOutWrap.layer.cornerRadius = 5.0
    }
}
