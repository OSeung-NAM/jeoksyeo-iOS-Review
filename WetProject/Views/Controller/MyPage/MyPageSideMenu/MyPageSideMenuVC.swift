//
//  SideMenuViewController.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/19.
//

import UIKit
import SideMenu
import RxSwift
import RxCocoa
import ReactorKit
//import RxGesture
//webp이미지 로드하기위한 플러그인
import Nuke
import NukeWebPPlugin

//https://gonslab.tistory.com/10 참고용
//CustomSideMenuNavigation.swift 파일 안에 들어가 사이드 메뉴화면을 구현하고, UI를 컨트롤 하기위한 파일
class MyPageSideMenuVC: BaseViewController,StoryboardView {
    
    //MARK -- UI
    @IBOutlet weak var summaryWrap: UIView!
    @IBOutlet weak var defaultProfileImage: UIImageView!
    @IBOutlet weak var profileImageWrap: UIView!
    @IBOutlet weak var settingWrap: UIView!
    @IBOutlet weak var myReviewWrap: UIView!
    @IBOutlet weak var myLevelWrap: UIView!
    @IBOutlet weak var myBookmarkWrap: UIView!
    @IBOutlet weak var loginWrap: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    
    //로그인 or 로그아웃 label
    @IBOutlet weak var loginImage: UIImageView!
    @IBOutlet weak var loginGL: UILabel!
    @IBOutlet weak var nickNameGL: UILabel!
    @IBOutlet weak var wellcomeGL: UILabel!
    
    //MARK -- Reactor
    let myPageSideMenuRT = MyPageSideMenuRT()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reactor = myPageSideMenuRT
        uiInit()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        disposeBag = DisposeBag()
    }

    //Action, State 초기화
    func bind(reactor: MyPageSideMenuRT) {
        /* btnEvent */
        
        //설정
        settingWrap.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext:{ [weak self] _ in
                if(self?.isInternetAvailable() ?? false){
                    log.info("Network Connected")
                } else {
                    LoginService.shared.login(callingView: self as Any)
                    log.info("Network DisConnected")
                    return
                }
                reactor.action.onNext(.setting)
            })
            .disposed(by: disposeBag)
        
        //내가작성한 리뷰
        myReviewWrap.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext:{ [weak self] _ in
                if(self?.isInternetAvailable() ?? false){
                    log.info("Network Connected")
                } else {
                    LoginService.shared.login(callingView: self as Any)
                    log.info("Network DisConnected")
                    return
                }
                reactor.action.onNext(.myReview)
            })
            .disposed(by: disposeBag)
        
        //나의 주류 레벨
        myLevelWrap.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext:{ [weak self] _ in
                if(self?.isInternetAvailable() ?? false){
                    log.info("Network Connected")
                } else {
                    LoginService.shared.login(callingView: self as Any)
                    log.info("Network DisConnected")
                    return
                }
                reactor.action.onNext(.myLevel)
            })
            .disposed(by: disposeBag)
        
        //내가 찜한 주류
        myBookmarkWrap.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext:{ [weak self] _ in
                if(self?.isInternetAvailable() ?? false){
                    log.info("Network Connected")
                } else {
                    LoginService.shared.login(callingView: self as Any)
                    log.info("Network DisConnected")
                    return
                }
                reactor.action.onNext(.myBookmark)
            })
            .disposed(by: disposeBag)
        
        //뒤로가기 버튼
        backBtn.rx.tap
            .subscribe(onNext:{ [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        
        //로그인 or 로그아웃 버튼
        loginWrap.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                if let _ = UserDefaults.standard.string(forKey: "accessToken") {
                    self?.logout()
                }else {
                    LoginService.shared.login(callingView: self as Any)
                }
            })
            .disposed(by: disposeBag)
        
        /* */
        
        /* action */
        reactor.action.onNext(.myInfo)
        
        /* */
        
        /* state */
        reactor.state.map{$0.isMyInfo}
            .filter{$0 != nil }
            .subscribe(onNext:{ [weak self] result in
                if result?.errors == nil { //성공
                    if result?.data?.userInfo?.profile?.count ?? 0 > 0 {
                        let profileImageUrl = result?.data?.userInfo?.profile?[0].mediaResource?.small?.src ?? ""
                        self?.myProfileImageSetting(url: profileImageUrl)
                    }
                    let nickName:String = result?.data?.userInfo?.nickname ?? ""
                    self?.nickNameGL.text = nickName+"님,"
                    self?.wellcomeGL.text = "안녕하세요!"
                    self?.loginGL.text = "로그아웃"
                    self?.loginImage.image = UIImage(named: "logout")
                }else { //실패
                    
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map{$0.isSetting}
            .filter{($0 ?? false)}
            .subscribe(onNext:{ [weak self] _ in self?.settingMove() }).disposed(by: disposeBag)
        
        reactor.state.map{$0.isMyReview}
            .filter{($0 ?? false)}
            .subscribe(onNext:{ [weak self] _ in self?.myReviewListMove() }).disposed(by: disposeBag)
        
        reactor.state.map{$0.isMyLevel}
            .filter{($0 ?? false)}
            .subscribe(onNext:{ [weak self] _ in self?.myAlcoholLevelMove() }).disposed(by: disposeBag)
        
        reactor.state.map{$0.isMyBookmark}
            .filter{($0 ?? false)}
            .subscribe(onNext:{ [weak self] _ in self?.myBookmarkMove() }).disposed(by: disposeBag)
        
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
            .filter{$0.0 != nil && $0.1 != nil}
            .subscribe(onNext:{ result in
                if result.0 != "" {
                    reactor.action.onNext(.accessTokenSave(result.0, result.1))
                }
            })
            .disposed(by: disposeBag)
        
        //토큰 갱신 후 -> 내장 저장 -> 기존에 실행하려 했던 이벤트 실행
        reactor.state.map{$0.isAccessTokenSave}
            .observeOn(MainScheduler.asyncInstance)
            .filter{$0.0 != nil && $0.1 != nil}
            .subscribe(onNext: { result in
                if result.0 ?? false {
                    if result.1 == 0 { //내 정보 호출
                        reactor.action.onNext(.myInfo)
                    }else if result.1 == 1 { //내가 평가한 주류
                        reactor.action.onNext(.setting)
                    }else if result.1 == 2 { //나의 주류 레벨
                        reactor.action.onNext(.myReview)
                    }else if result.1 == 3 { //내가 찜한 주류
                        reactor.action.onNext(.myLevel)
                    }else if result.1 == 4 {
                        reactor.action.onNext(.myBookmark)
                    }
                }else { //갱신 실패
                    log.error("Token is Not Renwaled")
                }
            })
            .disposed(by: disposeBag)
        
        /* */
    }
    
    //summary 클릭 로그인
    @objc func loginMove() {
        if TokenValidationCheck.shared.tokenValidationCheck() == 0 {
            LoginService.shared.login(callingView: self as Any)
        }
    }
    
    
    //로그인 후 콜백
    func loginCallback() {
        if let _ = UserDefaults.standard.string(forKey: "accessToken") {
            if let _  = UserDefaults.standard.string(forKey: "refreshToken") {
                if let reactor = reactor {
                    reactor.action.onNext(.myInfo)
                    if let customSideMenuNavigation = parent as? CustomSideMenuNavigation {
                        if let pvc = customSideMenuNavigation.presentingViewController as? UINavigationController {
                            //사이드 마이페이지를 통해 로그인하는 경우
                            let lastView = pvc.viewControllers[pvc.viewControllers.count-1] //해당 화면을 호출 한 화면 (제일 마지막 stack view)
                            if let mainVC = lastView as? MainVC {
                                mainVC.reactor?.action.onNext(.main) //호출 후 주류 좋아요 등 체크위해 메인 항목들 재호출
                            }else if let _ = lastView as? AlcoholListVC {
                                //                            alcoholListVC.eventExecution(event: 1) //호출 후 주류 좋아요 등 체크위해 주류리스트 항목들 재호출
                            }
                        }
                    }
                }
            }
        }
    }
    
    //설정 화면 이동
    func settingMove() {
        if(isInternetAvailable)(){
            log.info("Network Connected")
        } else {
            LoginService.shared.login(callingView: self as Any)
            log.info("Network DisConnected")
            return
        }
        if let customSideMenuNavigation = parent as? CustomSideMenuNavigation {
            if let pvc = customSideMenuNavigation.presentingViewController as? UINavigationController {
                dismiss(animated: true, completion: nil)
                let lastView = pvc.viewControllers[pvc.viewControllers.count-1] //해당 화면을 호출 한 화면 (제일 마지막 stack view)
                let settingsVC = StoryBoardName.myPageStoryBoard.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
                
                lastView.navigationController?.pushViewController(settingsVC, animated: true)
            }
        }
    }
    
    //나의 주류레벨 이동
    func myAlcoholLevelMove() {
        if(isInternetAvailable)(){
            log.info("Network Connected")
        } else {
            LoginService.shared.login(callingView: self as Any)
            log.info("Network DisConnected")
            return
        }
        if let customSideMenuNavigation = parent as? CustomSideMenuNavigation {
            if let pvc = customSideMenuNavigation.presentingViewController as? UINavigationController {
                dismiss(animated: true, completion: nil)
                let lastView = pvc.viewControllers[pvc.viewControllers.count-1] //해당 화면을 호출 한 화면 (제일 마지막 stack view)
                let myAlcoholLevelVC = StoryBoardName.myPageStoryBoard.instantiateViewController(withIdentifier: "MyAlcoholLevelVC") as! MyAlcoholLevelVC
                
                lastView.navigationController?.pushViewController(myAlcoholLevelVC, animated: true)
            }
        }
    }
    
    //내가 평가한 리뷰 이동
    func myReviewListMove() {
        if(isInternetAvailable)(){
            log.info("Network Connected")
        } else {
            LoginService.shared.login(callingView: self as Any)
            log.info("Network DisConnected")
            return
        }
        if let customSideMenuNavigation = parent as? CustomSideMenuNavigation {
            if let pvc = customSideMenuNavigation.presentingViewController as? UINavigationController {
                dismiss(animated: true, completion: nil)
                let lastView = pvc.viewControllers[pvc.viewControllers.count-1] //해당 화면을 호출 한 화면 (제일 마지막 stack view)
                let myReviewListVC = StoryBoardName.myPageStoryBoard.instantiateViewController(withIdentifier: "MyReviewListVC") as! MyReviewListVC
                
                lastView.navigationController?.pushViewController(myReviewListVC, animated: true)
            }
        }
    }
    
    //내가 찜한 주류
    func myBookmarkMove() {
        if(isInternetAvailable)(){
            log.info("Network Connected")
        } else {
            LoginService.shared.login(callingView: self as Any)
            log.info("Network DisConnected")
            return
        }
        if let customSideMenuNavigation = parent as? CustomSideMenuNavigation {
            if let pvc = customSideMenuNavigation.presentingViewController as? UINavigationController {
                dismiss(animated: true, completion: nil)
                let lastView = pvc.viewControllers[pvc.viewControllers.count-1] //해당 화면을 호출 한 화면 (제일 마지막 stack view)
                let myBookmarkListVC = StoryBoardName.myPageStoryBoard.instantiateViewController(withIdentifier: "MyBookmarkListVC") as! MyBookmarkListVC
                
                lastView.navigationController?.pushViewController(myBookmarkListVC, animated: true)
            }
        }
    }
    
    func logout() {
        //로그아웃 토큰 초기화
        UserDefaults.standard.setValue(nil, forKey: "accessToken")
        UserDefaults.standard.setValue(nil, forKey: "refreshToken")
        if let customSideMenuNavigation = parent as? CustomSideMenuNavigation {
            if let pvc = customSideMenuNavigation.presentingViewController as? UINavigationController {
                //사이드 마이페이지를 통해 로그인하는 경우
                let lastView = pvc.viewControllers[pvc.viewControllers.count-1] //해당 화면을 호출 한 화면 (제일 마지막 stack view)
                if let mainVC = lastView as? MainVC {
                    mainVC.reactor?.action.onNext(.main) //호출 후 주류 좋아요 등 체크위해 메인 항목들 재호출
                    //                        mainVC.eventExecution(event: 1) //호출 후 주류 좋아요 등 체크위해 메인 항목들 재호출
                }else if let _ = lastView as? AlcoholListVC {
                    //                        alcoholListVC.eventExecution(event: 1) //호출 후 주류 좋아요 등 체크위해 주류리스트 항목들 재호출
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    //내 정보 이미지 세팅
    func myProfileImageSetting(url:String) {
        if url.count > 0 {
            profileImage.isHidden = false
            defaultProfileImage.isHidden = true
            let webpimageURL = URL(string: url)!
            Nuke.loadImage(with: webpimageURL, into: profileImage)
            
            WebPImageDecoder.enable()
        }else {
            profileImage.isHidden = true
            defaultProfileImage.isHidden = false
        }
    }
    
    
    //회원가입 요청
    func goSignUp(signUpArr:[String], userInfo:User, socialDivision:String) {
        if let customSideMenuNavigation = parent as? CustomSideMenuNavigation {
            if let pvc = customSideMenuNavigation.presentingViewController as? UINavigationController {
                dismiss(animated: true, completion: nil)
                let lastView = pvc.viewControllers[pvc.viewControllers.count-1] //해당 화면을 호출 한 화면 (제일 마지막 stack view)
                let signUpVC = StoryBoardName.signUpStoryBoard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
                signUpVC.signUpArr = signUpArr
                signUpVC.userInfo = userInfo
                signUpVC.socialDivision = socialDivision
                lastView.navigationController?.pushViewController(signUpVC, animated: true)
            }
        }
    }
}

extension MyPageSideMenuVC {
    func uiInit() {
        summaryWrap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loginMove)))
        
        settingWrap.borderAll(width: 1.0, color: UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1.0).cgColor)
        myReviewWrap.borderAll(width: 1.0, color: UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1.0).cgColor)
        myLevelWrap.borderAll(width: 1.0, color: UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1.0).cgColor)
        myBookmarkWrap.borderAll(width: 1.0, color: UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1.0).cgColor)
        loginWrap.borderAll(width: 1.0, color: UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1.0).cgColor)
        
        profileImage.layer.cornerRadius = 36.0
    }
}
