//
//  AppUpdateAlertPopVC.swift
//  WetProject
//
//  Created by 남오승 on 2021/02/18.
//

import UIKit

//앱 업데이트 알림을 위한 팝업 UI를 컨트롤 하기위한 파일
class AppUpdateAlertPopVC: UIViewController {
    
    @IBOutlet weak var alertWrap: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertWrap.layer.cornerRadius = 5.0
    }
    
    @IBAction func confirmBtn(_ sender: Any) {
        // id뒤에 값은 앱정보에 Apple ID에 써있는 숫자
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1546204372"), UIApplication.shared.canOpenURL(url) { // 앱스토어로 이동
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
