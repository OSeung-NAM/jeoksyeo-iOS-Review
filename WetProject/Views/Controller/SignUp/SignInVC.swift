//
//  SignUpVC.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/15.
//

import UIKit
import JWTDecode
import NaverThirdPartyLogin
import KakaoSDKAuth
import ReactorKit
import RxCocoa
import RxSwift
import KakaoSDKUser

//로그인 화면 UI를 컨트롤 하기위한 파일
class SignInVC: BaseViewController, StoryboardView {
    
    //singleTon으로 만들어야함
    //2020/10/12 16:56 남오승
    
    let naverLoginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    let kakaoLoginInstance:KakaoService = KakaoService()
    
    // 애플로그인용
    var currentNonce: String?
    
    var signInRQModel:SignInRQModel?
    
    var signInRT = SignInRT()
    
    var socialDivision:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naverLoginInstance?.delegate = self
        reactor = signInRT

    }
    
    func bind(reactor: SignInRT) {
        
        /* State */
        
        let isIndicator = reactor.state.map{$0.isIndecator}.filter{$0 != nil}.map{$0 ?? false}
        
        isIndicator.bind{[weak self] result in self?.loadingIndicator(flag: result) }.disposed(by: disposeBag)
        
        let isError = reactor.state.map{$0.isErrors}.filter{$0 != nil}.map{$0 ?? false}

        //에러 여부
        isError.bind{ [weak self] result in
            if result {
                self?.netWorkStateToast(errorIndex: 1)
            }
        }.disposed(by: disposeBag)
        
        let isTimeOut = reactor.state.map{$0.isTimeOut}.filter{$0 != nil}.map{$0 ?? false}
        
        //서버 타임아웃 에러
        isTimeOut
            .bind{[weak self] result in
            if result {
                self?.netWorkStateToast(errorIndex: 408)
            }
        }.disposed(by: disposeBag)
        
        reactor.state.map{$0.isLogin}
            .filter{$0 != nil}
            .subscribe(onNext:{ [weak self] result in
                if let result = result {
                    self?.signInCallback(signInViewData: result)
                }
            })
            .disposed(by: disposeBag)
        /* */
    }

    @IBAction func kakaoLoginBtn(_ sender: Any) {
        kakaoLogin()
    }
    @IBAction func appleLoginBtn(_ sender: Any) {
        loadingIndicator(flag: true)
        appleLogin()
    }
    @IBAction func googleLoginBtn(_ sender: Any) {
        loadingIndicator(flag: true)
        googleLogin()
    }
    @IBAction func naverLoginBtn(_ sender: Any) {
        naverLogin()
    }

    func kakaoLogin(){
        kakaoLoginInstance.kakaoLogin { [weak self] (result) in
            self?.eventExecution(eventIndex: 0, signInRQModel: result, social: "KAKAO")
        }
    }
    
    //로그인 후 콜백처리
    func signInCallback(signInViewData: SignInRPModelData?) {
        
        SignUpUserInfo.shared.userRPInfo = signInViewData

        if signInViewData?.token == nil { //회원가입
            let hasEmail:Bool = signInViewData?.user?.hasEmail ?? false
            
            if hasEmail {
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                var signUpArr:[String] = []
                
                signUpArr.append("nickname")
                //reject으로 인한 회원가입 시 생년월일, 성별, 지역정보 추가기입 로직 제거

                if let pvc = self.presentingViewController as? UINavigationController {
                    if let userInfo = signInViewData?.user {
                        for parentVC in pvc.viewControllers {
                            if let myPageSideMenuVC = parentVC as? MyPageSideMenuVC {
                                myPageSideMenuVC.goSignUp(signUpArr: signUpArr,userInfo: userInfo, socialDivision: socialDivision)
                            }else if let mainVC = parentVC as? MainVC {
                                mainVC.goSignUp(signUpArr: signUpArr,userInfo: userInfo, socialDivision: socialDivision)
                            }else if let tabbar = parentVC as? UITabBarController {
                                if let myPage = tabbar.selectedViewController as? MyPageVC {
                                    myPage.goSignUp(signUpArr: signUpArr, userInfo: userInfo, socialDivision: socialDivision)
                                }else if let navigationController = tabbar.selectedViewController as? UINavigationController {
                                    let selectedTab01LastView = navigationController.viewControllers[navigationController.viewControllers.count - 1] //테이스트 저널 탭의 제일 마지막 호출 된 뷰
                                    if let alcoholDetailVC = selectedTab01LastView as? AlcoholDetailVC {
                                        alcoholDetailVC.goSignUp(signUpArr: signUpArr, userInfo: userInfo, socialDivision: socialDivision)
                                    }else if let alcoholListVC = selectedTab01LastView as? AlcoholListVC {
                                        alcoholListVC.goSignUp(signUpArr: signUpArr, userInfo: userInfo, socialDivision: socialDivision)
                                    }else if let alcoholSearchVC = selectedTab01LastView as? AlcoholSearchVC {
                                        alcoholSearchVC.goSignUp(signUpArr: signUpArr, userInfo: userInfo, socialDivision: socialDivision)
                                    }
                                }
                            }
                        }
                    }
                }
            }else {
                if socialDivision == "KAKAO" {
                    //이메일 없으면 메시지로 처리해야함 (카카오)
                    //이메일 없으면 링크 끊어서 계속 동의창 나오도록 구성
                    UserApi.shared.unlink {(error) in
                        if let error = error {
                            print("링크 연결 해제 에러:\(error)")
                        }
                        else {
                            print("링크 연결 해제 성공")
                        }
                    }
                    
                    let singleAlertPopVC = StoryBoardName.popupStoryBoard.instantiateViewController(withIdentifier: "SingleAlertPopVC") as! SingleAlertPopVC
                    singleAlertPopVC.modalPresentationStyle = .overCurrentContext
                    singleAlertPopVC.alertFlag = 2
                    present(singleAlertPopVC, animated: false, completion: nil)
                }else if socialDivision == "NAVER" {
                    //이메일 없으면 메시지로 처리해야함 (네이버)
                    //이메일 없으면 링크 끊어서 계속 동의창 나오도록 구성
                    naverLoginInstance?.requestDeleteToken()
                    
                    let singleAlertPopVC = StoryBoardName.popupStoryBoard.instantiateViewController(withIdentifier: "SingleAlertPopVC") as! SingleAlertPopVC
                    singleAlertPopVC.modalPresentationStyle = .overCurrentContext
                    singleAlertPopVC.alertFlag = 2
                    present(singleAlertPopVC, animated: false, completion: nil)
                }
            }
        }else { //로그인
            if let refreshToken:String = signInViewData?.token?.refreshToken {
                if let accessToken:String = signInViewData?.token?.accessToken {
                    UserDefaults.standard.setValue(accessToken, forKey: "accessToken")
                    UserDefaults.standard.setValue(refreshToken, forKey: "refreshToken")
                }
            }

            if let pvc = presentingViewController as? UINavigationController {
                let lastView = pvc.viewControllers[pvc.viewControllers.count-1] //해당 화면을 호출 한 화면 (제일 마지막 stack view)
                
                if let myPageSideMenuVC = lastView as? MyPageSideMenuVC {
                    myPageSideMenuVC.loginCallback()
                }else if let mainVC = lastView as? MainVC {
                    mainVC.reactor?.action.onNext(.main)
                }else if let tabbar = lastView as? UITabBarController {
                    if let myPageVC = tabbar.selectedViewController as? MyPageVC {
                        myPageVC.reactor?.action.onNext(.myInfo)
                    }
                }
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
}

//토큰 처리용 extension
extension SignInVC {
    //이벤트 관리
    func eventExecution(eventIndex:Int, signInRQModel:SignInRQModel,social: String) {
        socialDivision = social
        if let reactor = reactor {
            switch eventIndex {
            case 0: //로그인
                SignUpUserInfo.shared.userRQInfo = signInRQModel
                reactor.action.onNext(.login(signInRQModel))
                break
            case 1: //주류 상세 리뷰 조회

                break
            default:
                break
            }
        }
    }
}



