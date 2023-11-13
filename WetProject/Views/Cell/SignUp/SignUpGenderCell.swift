//
//  SignUpGenderCell.swift
//  WetProject
//
//  Created by 남오승 on 2020/12/02.
//

import UIKit
import RxCocoa
import RxSwift

//회원가입 시 성별 기입 화면을 위하 UICell 컴포넌트
class SignUpGenderCell: UICollectionViewCell {
    
    @IBOutlet weak var femaleWrap: UIView!
    @IBOutlet weak var femaleImage: UIImageView!
    @IBOutlet weak var maleWrap: UIView!
    @IBOutlet weak var maleImage: UIImageView!
    @IBOutlet weak var confirmBtn: UIButton!
    
    var disposeBag:DisposeBag = DisposeBag()
    
    var genderValidationInfo:BehaviorRelay = BehaviorRelay<Bool>.init(value: false)
    var callingView:Any?
    var genderFlag:Bool = false
    override func awakeFromNib() {
        super.awakeFromNib()
        
        confirmBtn.layer.cornerRadius = 4.0
        confirmBtn.shadow(opacity: 0.38, radius: 3, offset: CGSize(width: 3, height: 3), color: UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1).cgColor)
    
        input()
        output()
        
    }
    
    func input() {
        femaleWrap.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.genderFlag = true
                self?.genderSetting(flag: true)
            })
            .disposed(by: disposeBag)
        
        maleWrap.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.genderFlag = false
                self?.genderSetting(flag: false)
            })
            .disposed(by: disposeBag)
        
        confirmBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.nextEvent()
            })
            .disposed(by: disposeBag)
    }
    
    func output() {
        genderValidationInfo.asDriver()
            .drive(onNext: { [weak self] data in
                self?.confirmSetting(flag: data)
            })
            .disposed(by: disposeBag)
    }
    
    func genderSetting(flag:Bool) {
        genderValidationInfo.accept(true)
        if flag {
            femaleImage.image = UIImage(named: "checkboxOrangeBig")
            maleImage.image = UIImage(named: "checkboxGrayBig")
        }else {
            femaleImage.image = UIImage(named: "checkboxGrayBig")
            maleImage.image = UIImage(named: "checkboxOrangeBig")
        }
    }
    
    func confirmSetting(flag:Bool) {
        if flag {
            confirmBtn.backgroundColor = UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1)
        }else {
            confirmBtn.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
        }
    }
    
    func nextEvent() {
        let validation = genderValidationInfo.value
        if validation {
            if let signUpVC = callingView as? SignUpVC {
                if genderFlag {
                    signUpVC.gender = "F"
                }else {
                    signUpVC.gender = "M"
                }
                
                if signUpVC.signUpArr.contains("birth") {
                    signUpVC.nextViewMove(nextIndex: 3)
                }else {
                    signUpVC.nextViewMove(nextIndex: 2)
                }
            }
        }
    }
}
