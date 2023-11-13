//
//  MyPageVC.swift
//  WetProject
//
//  Created by 남오승 on 2021/01/08.
//

import SnapKit
import UIKit
import ReactorKit

//마이페이지 화면 View파일을 컨트롤 하기위한 파일
class MyPageVC: BaseViewController,View {
    
    let myPageView = MyPageView()

    override func viewDidLoad() {
        view = myPageView
        reactor = MyPageSideMenuRT()
    }
    
    func bind(reactor: MyPageSideMenuRT) {
        
        /* UIEvent */
        let isSetting = myPageView.isSettingEvent.filter{$0}
        let isReview = myPageView.isReviewEvent.filter{$0}
        let isLevel = myPageView.isLevelEvent.filter{$0}
        let isBookmark = myPageView.isBookmarkEvent.filter{$0}
        let isLogout = myPageView.isLogoutEvent.filter{$0}
        
        isSetting.bind{[weak self] result in
            self?.moveView(eventIndex: 0)
        }.disposed(by: disposeBag)
        isReview.bind{[weak self] result in
            self?.moveView(eventIndex: 1)
        }.disposed(by: disposeBag)
        isLevel.bind{[weak self] result in
            self?.moveView(eventIndex: 2)
        }.disposed(by: disposeBag)
        isBookmark.bind{[weak self] result in
            self?.moveView(eventIndex: 3)
        }.disposed(by: disposeBag)
        isLogout.bind{[weak self] result in
            if let _ = UserDefaults.standard.string(forKey: "accessToken") {
                self?.logout()
            }else {
                LoginService.shared.login(callingView: self as Any)
            }
            
        }.disposed(by: disposeBag)

        /* Action */
        reactor.action.onNext(.myInfo)
        /* */
        
        /* State */
        let isMyInfo = reactor.state.map{$0.isMyInfo}.filter{$0 != nil}
        isMyInfo.bind{[weak self] result in
            self?.myPageView.logoutSummaryWrap.isHidden = true
            self?.myPageView.loginSummaryWrap.isHidden = false
            self?.myPageView.loginEventGL.text = "로그아웃"
            let nickName = result?.data?.userInfo?.nickname ?? ""
            let level = result?.data?.userInfo?.level ?? 1
            self?.myPageView.loginUserNameGL.text = nickName
            self?.myPageView.myLevelSetting(level: level)
            if result?.data?.userInfo?.profile?.count ?? 0 > 0 {
                let profileImageUrl = result?.data?.userInfo?.profile?[0].mediaResource?.small?.src ?? ""
                self?.myPageView.myProfileImageSetting(url: profileImageUrl)
            }else {
                self?.myPageView.myProfileImageSetting(url: "")
            }
        }.disposed(by: disposeBag)
        /* */
    }
    
    func logout() {
        //로그아웃 토큰 초기화
        UserDefaults.standard.setValue(nil, forKey: "accessToken")
        UserDefaults.standard.setValue(nil, forKey: "refreshToken")
        myPageView.logoutSummaryWrap.isHidden = false
        myPageView.loginSummaryWrap.isHidden = true
        myPageView.loginEventGL.text = "로그인"
    }
    
    func moveView(eventIndex:Int) {
        switch eventIndex {
        case 0:
            if(isInternetAvailable)(){
                log.info("Network Connected")
            } else {
                netWorkStateToast(errorIndex: 0)
                log.info("Network DisConnected")
                return
            }
            let settingsVC = StoryBoardName.myPageStoryBoard.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
            
            navigationController?.pushViewController(settingsVC, animated: true)
            //설정
            break
        case 1:
            if !loginCheck() {
                return
            }
            if(isInternetAvailable)(){
                log.info("Network Connected")
            } else {
                LoginService.shared.login(callingView: self as Any)
                log.info("Network DisConnected")
                return
            }
            let myReviewListVC = StoryBoardName.myPageStoryBoard.instantiateViewController(withIdentifier: "MyReviewListVC") as! MyReviewListVC
            
            navigationController?.pushViewController(myReviewListVC, animated: true)
            //내가 평가한 주류
            break
        case 2:
            if !loginCheck() {
                return
            }
            if(isInternetAvailable)(){
                log.info("Network Connected")
            } else {
                LoginService.shared.login(callingView: self as Any)
                log.info("Network DisConnected")
                return
            }
            let myAlcoholLevelVC = StoryBoardName.myPageStoryBoard.instantiateViewController(withIdentifier: "MyAlcoholLevelVC") as! MyAlcoholLevelVC
            
            navigationController?.pushViewController(myAlcoholLevelVC, animated: true)
            //나의 주류 레벨
            break
        case 3:
            if !loginCheck() {
                return
            }
            if(isInternetAvailable)(){
                log.info("Network Connected")
            } else {
                LoginService.shared.login(callingView: self as Any)
                log.info("Network DisConnected")
                return
            }
            let myBookmarkListVC = StoryBoardName.myPageStoryBoard.instantiateViewController(withIdentifier: "MyBookmarkListVC") as! MyBookmarkListVC
            
            navigationController?.pushViewController(myBookmarkListVC, animated: true)
            //내가 찜한 주류
            break
        default:
            break
        }
    }
    
    //회원가입 요청
    func goSignUp(signUpArr:[String], userInfo:User, socialDivision:String) {
        let signUpVC = StoryBoardName.signUpStoryBoard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        signUpVC.signUpArr = signUpArr
        signUpVC.userInfo = userInfo
        signUpVC.socialDivision = socialDivision
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    func loginCheck() -> Bool {
        guard let _ = UserDefaults.standard.string(forKey: "accessToken") else {
            LoginService.shared.login(callingView: self as Any)
            return false }
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //로그인 여부 체크
        if let _ = UserDefaults.standard.string(forKey: "accessToken") {
            if let reactor = reactor {
                reactor.action.onNext(.myInfo)
                myPageView.logoutSummaryWrap.isHidden = true
                myPageView.loginSummaryWrap.isHidden = false
                myPageView.loginEventGL.text = "로그아웃"
            }
        }else {
            myPageView.logoutSummaryWrap.isHidden = false
            myPageView.loginSummaryWrap.isHidden = true
            myPageView.loginEventGL.text = "로그인"
        }
    }
}
