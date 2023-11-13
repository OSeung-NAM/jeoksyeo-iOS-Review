//
//  AppleService.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/15.
//

import FirebaseAuth
import CryptoKit
import AuthenticationServices

//애플 로그인을 위한 서비스 파일
extension SignInVC:ASAuthorizationControllerDelegate {
    
    @available(iOS 13, *)
    func appleLogin() {
        appleLogout()
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    func appleLogout() {
        //로그인 되어있을 수 있으니 로그아웃 진행 후 처리
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("apple logout complete")
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    // Adapted from         https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce, accessToken: nonce
            )
            
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
                if (error != nil) {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error!.localizedDescription)
                    return
                }
                
                guard let _:String = authResult?.user.uid else {
                    print("apple Login oauthId is Empty")
                    self?.loadingIndicator(flag: false)
                    return
                }
                
                guard let _:String = authResult?.user.email else {
                    print("apple Login email is Empty")
                    self?.loadingIndicator(flag: false)
                    return
                }
                
                authResult?.user.getIDToken(){ [weak self] (idToken, error) in
                    if error == nil, let token = idToken {
                        //                        self.idToken = token
                        print("appleIdToken:\(token)")
                        let oauthProvider:String = "APPLE"
                        let oauthToken:String = token
                        let signInRQModel:SignInRQModel = SignInRQModel(oauth_provider: oauthProvider, oauth_token: oauthToken, user_id: nil, nickname: nil, birth: nil, gender: nil, address: nil)
                        self?.eventExecution(eventIndex: 0, signInRQModel: signInRQModel, social: "APPLE")
                    }else{
                        //error handling
                    }
                    
                }
            }
        }
    }
    
    // Apple Login 관련 모든 에러 확인 함수
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
        loadingIndicator(flag: false)
    }
}
