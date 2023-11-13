////
////  NaverService.swift
////  WetProject
////
////  Created by 남오승 on 2020/10/15.
////
//

import UIKit
import NaverThirdPartyLogin
import Alamofire

//네이버 로그인을 위한 서비스 파일
extension SignInVC:NaverThirdPartyLoginConnectionDelegate {

    func naverLogin() {
        naverLogout()
        naverLoginInstance?.requestThirdPartyLogin()
        
    }
    
    func naverLogout() {
        //로그인 되어있을 수 있으니 로그아웃 진행 후 처리
        naverLoginInstance?.resetToken()
    }
    
    // 로그인에 성공한 경우 호출되는 Naver Login 함수
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("Success login")
        //로그인 성공 후 해당 Naver 계정에 대한 정보 얻을 함수 호출
        getNaverUserInfo()
    }
    
    // 토큰 재 생성 시 호출되는 함수
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        print("Success Re Login")
        //재 로그인 성공 후 해당 Naver 계정에 대한 정보 얻을 함수 호출
        getNaverUserInfo()
    }
    
    // Naver Login 세션 지우는 함수
    func oauth20ConnectionDidFinishDeleteToken() {
        print("log out")
    }
    
    // Naver Login 관련 모든 에러 확인 함수
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("naverLoginerror = \(error.localizedDescription)")
        loadingIndicator(flag: false)
    }

    // RESTful API, id가져오기
    func getNaverUserInfo() {
        
        //네이버 accessToken만료여부 체크
        guard let isValidAccessToken = naverLoginInstance?.isValidAccessTokenExpireTimeNow() else { return }
        
        if !isValidAccessToken {
            return
        }

        guard let accessToken = naverLoginInstance?.accessToken else { return }

        print("naverAccessToken:\(accessToken)")
        let oauthProvider:String = "NAVER"
        let oauthToken:String = accessToken

        let signInRQModel = SignInRQModel(oauth_provider: oauthProvider, oauth_token: oauthToken, user_id: nil, nickname: nil, birth: nil, gender: nil, address: nil)
        eventExecution(eventIndex: 0, signInRQModel: signInRQModel,social: "NAVER")
    }
}

