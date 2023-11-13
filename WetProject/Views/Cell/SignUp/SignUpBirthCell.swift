//
//  SignUpBirthCell.swift
//  WetProject
//
//  Created by 남오승 on 2020/12/02.
//

import UIKit
import RxSwift
import RxCocoa

//회원가입 시 생년월일 기입 화면을 위한 UICell 컴포넌트
class SignUpBirthCell: UICollectionViewCell {

    @IBOutlet weak var birthPicker: UIDatePicker!
    
    @IBOutlet weak var birthPickerWrap: UIView!
    
    @IBOutlet weak var yearGL: UILabel!
    @IBOutlet weak var monthGL: UILabel!
    @IBOutlet weak var dayGL: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var birthPickerTopWrap: UIView!
    
    var callingView:Any?
    var disposeBag: DisposeBag = DisposeBag()
    
    var confirmValidation:BehaviorRelay<Bool> = BehaviorRelay.init(value: false)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        birthPicker.setValue(UIColor.black, forKey: "textColor")
        birthPicker.setValue(false, forKey: "highlightsToday")
        
        let currentDate = Date()
        var dateComponents = DateComponents()
        
        let calendar = Calendar.init(identifier: .gregorian) //양력
        dateComponents.year = -70
        
        let minDate = calendar.date(byAdding: dateComponents, to: currentDate)
        dateComponents.year = -15
        
        let maxDate = calendar.date(byAdding: dateComponents, to: currentDate)
        birthPicker.maximumDate = maxDate
        birthPicker.minimumDate = minDate
        
        let locale = Locale(identifier: "ko_KO");
        birthPicker.locale = locale
        
        confirmBtn.layer.cornerRadius = 4.0
        confirmBtn.shadow(opacity: 0.38, radius: 3, offset: CGSize(width: 3, height: 3), color: UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1).cgColor)
        
        input()
        output()
    }
    
    func input() {
        confirmBtn.rx.tap
            .asDriver()
            .drive(onNext:{ [weak self] _ in
                self?.nextEvent()
            })
            .disposed(by: disposeBag)
    }
    
    func output() {
        confirmValidation.asDriver()
            .drive(onNext:{ [weak self] data in
                self?.confirmSetting(flag: data)
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func birthPicker(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let dateStr = dateFormatter.string(from: sender.date).split(separator: "-")
        
        yearGL.text = String(dateStr[0])
        monthGL.text = String(dateStr[1])
        dayGL.text = String(dateStr[2])
        
        confirmValidation.accept(true)
    }
    
    func confirmSetting(flag:Bool) {
        if flag {
            confirmBtn.backgroundColor = UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1)
        }else {
            confirmBtn.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
        }
    }
    
    func nextEvent() {
        let validation = confirmValidation.value
        if validation {
            if let signUpVC = callingView as? SignUpVC {
                signUpVC.birth = (yearGL.text! + "-" + monthGL.text! + "-" + dayGL.text!)
                signUpVC.nextViewMove(nextIndex: 2)
            }
        }
    }
}
