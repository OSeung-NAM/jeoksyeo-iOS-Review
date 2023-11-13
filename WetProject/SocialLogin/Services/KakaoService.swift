//
//  KakaoService.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/15.
//

import Foundation
import Alamofire
import KakaoSDKAuth
import KakaoSDKUser

//카카오 로그인을 위한 서비스 파일
class KakaoService {
    
    //return Type
    typealias Result = (SignInRQModel) -> Void
    
    func kakaoLogin(_ result: @escaping Result) {
        kakaoLogout()
        
           
        // 카카오톡 설치 여부 확인
        if (AuthApi.isKakaoTalkLoginAvailable()) {
            //카카오톡 앱으로 로그인
            AuthApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    //do something
                    _ = oauthToken
                    let oauthProvider:String = "KAKAO"
                    if let oauthToken:String = oauthToken?.accessToken {
                        result(SignInRQModel(oauth_provider: oauthProvider, oauth_token: oauthToken, user_id: nil, nickname: nil, birth: nil, gender: nil, address: nil))

                    }
                }
            }
        }else { //카카오톡 웹뷰 계정으로 로그인
            AuthApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    //do something
                    _ = oauthToken

                    let oauthProvider:String = "KAKAO"
                    if let oauthToken:String = oauthToken?.accessToken {
                        result(SignInRQModel(oauth_provider: oauthProvider, oauth_token: oauthToken, user_id: nil, nickname: nil, birth: nil, gender: nil, address: nil))
                    }
                }
            }
        }
    }
    
    func kakaoLogout() {
        //로그인 되어있을 수 있으니 로그아웃 진행 후 처리
        AUTH.tokenManager.deleteToken()
    }
}
