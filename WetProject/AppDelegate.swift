//
//  AppDelegate.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/06.
//

import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import NaverThirdPartyLogin
import GoogleSignIn
import Firebase
import RxSwift

//앱의 UI를 그리는 부분에 대한 총괄, 앱의 상태변화에 따른 업데이트 처리 (카카오 로그인 , 네이버로그인, 파이어베이스를 통한 구글로그인, 애플로그인, 푸시 토큰을 위한 디바이스 id 추출, QR코드 인식등을 위한 initialize 로직구현되어있음.)
@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    var shouldSupportAllOrientation = false
    
    
    let desposeBag = DisposeBag()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //        Thread.sleep(forTimeInterval: 0.0)
        
        KakaoSDKCommon.initSDK(appKey: SocialKey.kakaoNativeKey)
        
        let instance = NaverThirdPartyLoginConnection.getSharedInstance()
        
        // 네이버 앱으로 인증하는 방식 활성화
        instance?.isNaverAppOauthEnable = true
        
        // SafariViewController에서 인증하는 방식 활성화
        instance?.isInAppOauthEnable = true
        
        // 인증 화면을 아이폰의 세로모드에서만 적용
        instance?.isOnlyPortraitSupportedInIphone()
        
        instance?.serviceUrlScheme = SocialKey.naverUrlScheme// 앱을 등록할 때 입력한 URL Scheme
        instance?.consumerKey = SocialKey.naverClientID // 상수 - client id
        instance?.consumerSecret = SocialKey.naverSecretKey // pw
        instance?.appName = kServiceAppName // app name
        
        // OAuth 2.0 클라이언트 ID
        GIDSignIn.sharedInstance().clientID = SocialKey.googleClientID+".apps.googleusercontent.com"
        
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        // APNS 설정
        UNUserNotificationCenter.current().delegate = self
        
        //APNS등록
        application.registerForRemoteNotifications()
        let tokenFlag:Int = TokenValidationCheck.shared.tokenValidationCheck()
        tokenCheckResult(tokenFlag: tokenFlag)
        let params = [
            "token" : "dddddd"
        ]
        TokenTempService().postTokenTemp(params: params)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let scheme = url.scheme else { return true }
        
        if scheme.contains(SocialKey.naverUrlScheme) {
            NaverThirdPartyLoginConnection.getSharedInstance().receiveAccessToken(url)
            return true
        }
        
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.handleOpenUrl(url: url)
        }
        
        return true
        
    }
    
    // 푸시토큰 추출 실패시
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        log.error("Failed to register for notifications: \(error.localizedDescription)")
    }
    
    //푸시알림을 위한 토큰
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken pushToken: Data) {
        let tokenParts = pushToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        log.debug("userDeviceToken:\(token)")
        UserDefaults.standard.set(token, forKey: "APNSToken")
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if shouldSupportAllOrientation == true {
            //모든방향 회전 가능
            return UIInterfaceOrientationMask.all
        }
        
        //세로모드 고정
        return UIInterfaceOrientationMask.portrait
    }
    
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        
        
        
        guard let url = dynamicLink.url else { return }
        
        if let alcoholId:String = url.params()?["alcoholID"] as? String {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabVC = storyboard.instantiateViewController(withIdentifier: "mainTabbar")
            let tabToNavitation = UINavigationController(rootViewController: tabVC)
            
            for view in tabVC.children {
                if let navigationView = view as? UINavigationController {
                    for nvc in navigationView.children {
                        if let mainVC = nvc as? MainVC {
                            mainVC.alcoholId = alcoholId
                            mainVC.qrFlag = true
                        }
                    }
                    tabToNavitation.navigationBar.isHidden = true
                    window?.rootViewController = tabToNavitation
                    window?.makeKeyAndVisible()
                }
            }
        }
    }
    
    func appUpdate() {
        DispatchQueue.main.async { [weak self] in
            
            let appUpdateAlertPopVC = StoryBoardName.popupStoryBoard.instantiateViewController(withIdentifier: "AppUpdateAlertPopVC") as! AppUpdateAlertPopVC
            appUpdateAlertPopVC.modalPresentationStyle = .overCurrentContext
            //            self?.window.present(appUpdateAlertPopVC, animated: false, completion: nil)
            self?.window?.rootViewController?.present(appUpdateAlertPopVC, animated: false, completion: nil)
            
        }
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let incomingURL = userActivity.webpageURL {
            
            let linkHandled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { [weak self] (dynamicLink, error) in
                guard error == nil else {
                    print("Found an error! \(error!.localizedDescription)")
                    return
                }
                
                if let dynamicLink = dynamicLink {
                    
                    DispatchQueue.global().async { [weak self] in
                        _ = try? AppStoreCheck.isUpdateAvailable { (update, error) in
                            
                            if let error = error {
                                
                                print(error)
                                
                            } else if let update = update {
                                
                                if update {
                                    
                                    self?.appUpdate()
                                    
                                    return
                                    
                                }else {
                                    DispatchQueue.main.async { [weak self] in
                                        self?.handleIncomingDynamicLink(dynamicLink)
                                    }
                                    
                                    return
                                }
                            }
                        }
                    }
                    
                    
                }
            }
            
            if linkHandled {
                return true
            }else {
                return false
            }
        }
        return false
    }
    
    //background -> foreground
    func applicationWillEnterForeground(_ application: UIApplication) {
        let tokenFlag:Int = TokenValidationCheck.shared.tokenValidationCheck()
        tokenCheckResult(tokenFlag: tokenFlag)
    }
    
    func tokenCheckResult(tokenFlag:Int) {
        switch tokenFlag {
        case 0:
            UserDefaults.standard.setValue(nil, forKey: "refreshToken")
            UserDefaults.standard.setValue(nil, forKey: "accessToken")
        case 1:
            let tokenRenewal = TokenRenewalService.shareInstance.tokenRenewal()
            tokenRenewal.subscribe(onNext:{ result in
                if let resultData = result.data { //토큰 갱신 완료
                    let accessToken:String = resultData.token.accessToken
                    UserDefaults.standard.setValue(accessToken, forKey: "accessToken")
                }else { //토큰 갱신 오류
                    print("갱신오류")
                }
            })
            .disposed(by: desposeBag)
            break
        case 2: //토큰 정상
            break
        default:
            break
        }
    }
}



