//
//  UserOutAlertPopVC.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/17.
//

import UIKit
import RxSwift
import RxCocoa

//공통 팝업 화면 UI를 컨트롤 하기위한 파일
class CustomAlertPopVC: UIViewController {

    @IBOutlet weak var alertWrap: UIView!

    var disposeBag = DisposeBag()
    
    //alert창 메시지
    @IBOutlet weak var alertMessage: UILabel!

    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    
    var message:String = ""
    
    var alertFlag:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertWrap.layer.cornerRadius = 5.0

        leftBtn.rx.tap
            .asDriver()
            .drive(onNext:{ [weak self] _ in
                self?.leftBtnEvent()
            })
            .disposed(by: disposeBag)
            
        rightBtn.rx.tap
            .asDriver()
            .drive(onNext:{ [weak self]_ in
                self?.rightBtnEvent()
            })
            .disposed(by: disposeBag)
        
        alertMessageSetting()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        disposeBag = DisposeBag()
    }
    
    func viewDismiss() {
        self.dismiss(animated: false, completion: nil)
    }
  
    func alertMessageSetting() {
        switch alertFlag {
        case 0:
            leftBtn.setTitle("탈퇴", for: .normal)
            rightBtn.setTitle("취소", for: .normal)
            alertMessage.text = "등록한 회원 정보가 모두 사라집니다\n탈퇴하시겠습니까?"
            break
        case 1:
            leftBtn.setTitle("삭제", for: .normal)
            rightBtn.setTitle("취소", for: .normal)
            alertMessage.text = "등록한 리뷰가 사라집니다.\n삭제하시겠습니까?"
            break
        case 2:
            leftBtn.setTitle("취소", for: .normal)
            rightBtn.setTitle("확인", for: .normal)
            alertMessage.text = "변경 내용을 삭제하시겠습니까?\n수정된 내용이 삭제됩니다."
            break
        default:
            break
        }
    }
    
    func leftBtnEvent() {
        if let pvc = self.presentingViewController as? UINavigationController {
            let lastView = pvc.viewControllers[pvc.viewControllers.count-1]
            
            if let _:UserInfoUpdateVC = lastView as? UserInfoUpdateVC {
                dismiss(animated: false, completion: nil)
            }else if let settingsVC:SettingsVC = lastView as? SettingsVC {
                settingsVC.reactor?.action.onNext(.userOut)
                dismiss(animated: false, completion: nil)
            }else if let myReviewListVC:MyReviewListVC = lastView as? MyReviewListVC {
                myReviewListVC.reviewDelete()
                dismiss(animated: false, completion: nil)
            }
        }
    }
    
    func rightBtnEvent() {
        if let pvc = self.presentingViewController as? UINavigationController {
            let lastView = pvc.viewControllers[pvc.viewControllers.count-1]
            
            if let userInfoUpdateVC:UserInfoUpdateVC = lastView as? UserInfoUpdateVC {
                dismiss(animated: false, completion: nil)
                userInfoUpdateVC.backFinalEvent()
            }else if let _:SettingsVC = lastView as? SettingsVC {
                dismiss(animated: false, completion: nil)
            }else if let _:MyReviewListVC = lastView as? MyReviewListVC {
                dismiss(animated: false, completion: nil)
            }
        }
    }
}
