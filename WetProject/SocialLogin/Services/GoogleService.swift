//
//  GoogleService.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/15.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

//구글 로그인을 위한 서비스 파일
extension SignInVC:GIDSignInDelegate {
    
    //구글로그인 관련 함수 호출
    //이 순간에 delegate 및 인스턴스 생성
    func googleLogin(){
        googleLogout()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func googleLogout() {
        //로그인 되어있을 수 있으니 로그아웃 진행 후 처리
        let firebaseAuth = Auth.auth()
        
        do {
            try firebaseAuth.signOut()
            print("google logout complete")
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
            loadingIndicator(flag: false)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("사용자 취소:\(error.localizedDescription)")
            }
            loadingIndicator(flag: false)
            return
        }
        
        //구글로그인
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        
        //구글 로그인 후 firebase 프로젝트에 usere 등록 하기위한 후작업처리
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                let authError = error as NSError
                //error
                print("google Login Error:\(authError)")
                return
            }
            
            guard let _:String = authResult?.user.uid else {
                print("apple Login oauthId is Empty")
                return
            }
            
            guard let _:String = authResult?.user.email else {
                print("apple Login email is Empty")
                return
            }
            
            authResult?.user.getIDToken(){ [weak self] (idToken, error) in
                if error == nil, let token = idToken {
                    //                        self.idToken = token
                    let oauthProvider:String = "GOOGLE"
                    let oauthToken:String = token
                    print("idToken:\(token)")
                    let signInRQModel:SignInRQModel = SignInRQModel(oauth_provider: oauthProvider, oauth_token: oauthToken, user_id: nil, nickname: nil, birth: nil, gender: nil, address: nil)
                    self?.eventExecution(eventIndex: 0, signInRQModel: signInRQModel, social: "GOOGLEß")
                }else{
                    //error handling
                }
            }
            // User is signed in
            // ...
        }
    }
}
