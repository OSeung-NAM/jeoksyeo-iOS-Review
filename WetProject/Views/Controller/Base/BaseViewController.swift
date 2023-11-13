//
//  BaseViewController.swift
//  WetProject
//
//  Created by 남오승 on 2020/12/09.
//

import UIKit
import Lottie
import RxSwift
import SystemConfiguration //네트워크 연결상태 확인을 위한 라이브러리

//모든 컨트롤러의 기본이 되는 파일
class BaseViewController: UIViewController {
    
    // MARK: Rx
    
    var disposeBag = DisposeBag()
    
    // MARK: Layout Constraints
    
    var currentViewSize = UIScreen.main.bounds
    let standardWidthSize:CGFloat = 375  //디자인 기준 width
    let standardHeightSize:CGFloat = 812 //디자인 기준 height
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //로딩
    func loadingIndicator(flag:Bool) {
        //초기화
        for view in view.subviews {
            if let _ = view as? IndicatorCell {
                view.removeFromSuperview()
            }else if let _ = view as? AnimationView {
                view.removeFromSuperview()
            }
        }
        
        if flag {
            
            let animationView = AnimationView(name: "loading") // AnimationView(name: "파일이름")으로 설정
            
            animationView.frame = CGRect(x: 0, y: 0, width: 300, height: 300) //애니메이션뷰의 크기설정
            
            animationView.contentMode = .scaleAspectFill //애니메이션 뷰의 콘텐츠 모드 설정 (꽉차게 할 것이냐 등등...)
            
            animationView.loopMode = .loop
            
            let indicatorCell = IndicatorCell(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
            
            indicatorCell.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.2)
            
            indicatorCell.lottieWrap.addSubview(animationView) //애니메이션뷰를 메인뷰에 추가시킨다.
            
            animationView.play() //애니메이션 뷰의 실행
            
            view?.addSubview(indicatorCell)
        }
    }
    
    //네트워크 상태관련 Toast메시지 출력
    func netWorkStateToast(errorIndex:Int?) {
        //초기화
        for view in view.subviews {
            if let _ = view as? NetworkStateCell {
                view.removeFromSuperview()
            }
        }
        let viewHeight = view.frame.height
        let viewWidth = view.frame.width
        let bottomSafeArea:CGFloat = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.bottom ?? 0
        let tabbarHeight:CGFloat = (tabBarController?.tabBar.frame.minY ?? 0) - (tabBarController?.tabBar.frame.height ?? 0) + (bottomSafeArea)
        var networkCell = NetworkStateCell(frame: CGRect(x: 16.0, y: (viewHeight - 74.0), width: viewWidth - 32.0, height: 54.0))
        if !(tabBarController?.tabBar.isHidden ?? false){
            networkCell = NetworkStateCell(frame: CGRect(x: 16.0, y: (tabbarHeight - 16.0), width: viewWidth - 32.0, height: 54.0))
        }
        
        if errorIndex == 0 { //네트워크 미 접속 에러
            networkCell.errorMsgGL.text = "네트워크에 접속 할 수 없습니다.\n네트워크 연결상태를 확인해 주세요."
        }else if errorIndex == 1 { //일반적인 API오류
            networkCell.errorMsgGL.text = "일시적인 네트워크 오류입니다.\n잠시 후 다시 시도해 주세요."
        }else if errorIndex == 2 { //유효하지않은 토큰 사용자
            networkCell.errorMsgGL.text = "올바르지 않은 유저입니다. \n다시 로그인 해 주세요."
        }else if errorIndex == 3 { //이미 찜한 주류
            networkCell.errorMsgGL.text = "이미 찜한 주류입니다."
        }else if errorIndex == 4 { //이미 좋아요 한 리뷰
            networkCell.errorMsgGL.text = "이미 좋아요 한 리뷰입니다."
        }else if errorIndex == 5 { //이미 싫어요 한 리뷰
            networkCell.errorMsgGL.text = "이미 싫어요 한 리뷰입니다."
        }else if errorIndex == 408 { //timeOut Error
            networkCell.errorMsgGL.text = "네트워크 통신이 원활하지 않습니다.\n잠시 후 다시 시도해 주세요."
        }
        networkCell.alpha = 0.0
        view.addSubview(networkCell)
        
        UIView.animate(withDuration: 0.75) {
            networkCell.alpha = 1.0
        }
        
        let timer = Timer.new(every: 2.5.second) {}
        timer.start(modes: .tracking)
        Timer.every(2.5.second) {(timer: Timer) in
            timer.invalidate()
            UIView.animate(withDuration: 0.75) {
                networkCell.alpha = 0.0
            }
        }
    }
    
    /// - parameter standardSize: 디자인 기준 사이즈
    /// - Returns: 비율 변환 된 값
    /// - Important: 변경할 비율 사이즈 (view, font)
    func aspectRatio(standardSize:CGFloat) -> CGFloat {
        var ratio: CGFloat = 0.0
        
        let standardRatio = (standardSize/standardWidthSize)
        ratio = currentViewSize.width * standardRatio
        
        return ratio
    }
    
    //네트워크 연결상태 확인
    func isInternetAvailable() -> Bool
        {
            var zeroAddress = sockaddr_in()
            zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
            zeroAddress.sin_family = sa_family_t(AF_INET)
            
            let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                    SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
                }
            }
            
            var flags = SCNetworkReachabilityFlags()

            if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {

                return false

            }

            let isReachable = flags.contains(.reachable)
            let needsConnection = flags.contains(.connectionRequired)

            return (isReachable && !needsConnection)
    }
}

extension UIScreen {

//    func widthOfSafeArea() -> CGFloat {
//
//        guard let rootView = UIApplication.shared.keyWindow else { return 0 }
//
//        if #available(iOS 11.0, *) {
//
//            let leftInset = rootView.safeAreaInsets.left
//
//            let rightInset = rootView.safeAreaInsets.right
//
//            return rootView.bounds.width - leftInset - rightInset
//
//        } else {
//
//            return rootView.bounds.width
//
//        }
//
//    }

    func heightOfSafeArea() -> CGFloat {

        guard let rootView = UIApplication.shared.keyWindow else { return 0 }

        if #available(iOS 11.0, *) {

            let topInset = rootView.safeAreaInsets.top

            let bottomInset = rootView.safeAreaInsets.bottom

            return rootView.bounds.height - topInset - bottomInset

        } else {

            return rootView.bounds.height

        }

    }

}
