//
//  SingleAlertPopVC.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/23.
//

import UIKit

//확인버튼 1개짜리 공통 팝업 화면 UI를 컨트롤 하기위한 파일
class SingleAlertPopVC: UIViewController {
    
    @IBOutlet weak var alertWrap: UIView!
    @IBOutlet weak var messageGL: UILabel!
    
    var alertFlag:Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        alertWrap.layer.cornerRadius = 5.0
        
        switch alertFlag {
        case 0 :
            messageGL.text = "네트워크에 접속 할 수 없습니다.\n네트워크 연결상태를 확인해 주세요."
            break
        case 1 :
            messageGL.text = "이미 평가한 주류입니다."
            break
        case 2 :
            messageGL.text = "‘적셔’는 서비스 이용내역 안내를 위해\n이메일 사용 권한 허용이 필요합니다.\n이메일 제공에 동의 해 주세요."
        default :
            break
        }
    }
    
    @IBAction func confirmBtn(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}
