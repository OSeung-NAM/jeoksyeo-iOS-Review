//
//  SplashVC.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/13.
//

import UIKit
import SwiftyTimer
import Lottie

//앱 실행 시 스플래시 UI를 컨트롤 하기위한 파일
class SplashVC: BaseViewController {
    @IBOutlet weak var splashWrap: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //테스트 하기위해서 타이버 일시 주석 추후 풀어야함
        
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
                        self?.splashAnimate()
                    }
                        
                        return
                    }
                }
            }
        }
    }
    
    private func splashAnimate() {
       
        let animationView = AnimationView(name: "splash") 
        
        animationView.frame = CGRect(x: (view.frame.width - 250) / 2, y:(view.frame.height - 250) / 2, width: 250, height: 250) //애니메이션뷰의 크기설정
        
        animationView.contentMode = .scaleAspectFill //애니메이션 뷰의 콘텐츠 모드 설정 (꽉차게 할 것이냐 등등...)
        animationView.loopMode = .loop
        
        splashWrap.addSubview(animationView) //애니메이션뷰를 메인뷰에 추가시킨다.
        
        animationView.play() //애니메이션 뷰의 실행
        
        
        let timer = Timer.new(every: 3.7.second) {}
        timer.start(modes: .tracking)
        Timer.every(3.7.second) { [self] (timer: Timer) in
            timer.invalidate()
            
            animationView.stop()
            //            let mainVC = storyboard!.instantiateViewController(withIdentifier: "MainVC") as! MainVC
            //            navigationController?.pushViewController(mainVC, animated: true)
            let tabbar = storyboard!.instantiateViewController(withIdentifier: "mainTabbar")
            navigationController?.pushViewController(tabbar, animated: true)
        }
    }
    
    func appUpdate() {
        DispatchQueue.main.async { [weak self] in
            
            let appUpdateAlertPopVC = StoryBoardName.popupStoryBoard.instantiateViewController(withIdentifier: "AppUpdateAlertPopVC") as! AppUpdateAlertPopVC
            appUpdateAlertPopVC.modalPresentationStyle = .overCurrentContext
            self?.present(appUpdateAlertPopVC, animated: false, completion: nil)
            
        }
    }
}

