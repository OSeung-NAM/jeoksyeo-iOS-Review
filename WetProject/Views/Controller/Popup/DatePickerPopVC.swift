//
//  DatePickerPopVC.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/19.
//

import UIKit
import RxSwift
import RxCocoa

//날짜 선택 팝업 화면 UI를 컨트롤 하기위한 파일
class DatePickerPopVC: UIViewController {
    
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var datePickerWrap: UIView!
    
    var yearData:[String] = [String]()
    
    var monthData:[String] = [String]()
    
    var dayData:[String] = [String]()
    
    
    @IBOutlet weak var yearPickerView: UIPickerView!
    @IBOutlet weak var monthPickerView: UIPickerView!
    @IBOutlet weak var dayPickerView: UIPickerView!
    
    var year:String = String()
    var month:String = String()
    var day:String = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        delegateInit()
        uiInit()
        
        yearSetting()
        monthSetting()
        daySetting()
        
        cancelBtn.rx.tap
            .asDriver()
            .drive(onNext: {[weak self] _ in
                self?.backEvent()
            })
            .disposed(by: disposeBag)
        
        confirmBtn.rx.tap
            .asDriver()
            .drive(onNext: {[weak self] _ in
                self?.confirmEvent()
            })
            .disposed(by: disposeBag)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLayoutSubviews() {
        yearPickerView.setValue(UIColor.clear, forKey: "magnifierLineColor")
        monthPickerView.setValue(UIColor.clear, forKey: "magnifierLineColor")
        dayPickerView.setValue(UIColor.clear, forKey: "magnifierLineColor")
    }
    
    func yearSetting() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        let currentYear:Int = Int(formatter.string(from: Date()))!
        
        for year in 1930...(currentYear-15) {
            yearData.append(String(year))
        }
        
        
        
        yearPickerView.selectRow(yearData.firstIndex(of: year) ?? 0, inComponent: 0, animated: true)
    }
    
    func monthSetting() {
        for month in 1...12 {
            if month < 10 {
                monthData.append("0" + String(month))
            }else {
                monthData.append(String(month))
            }
        }
        
        monthPickerView.selectRow(monthData.firstIndex(of: month) ?? 0, inComponent: 0, animated: true)
    }
    
    func daySetting() {
        for day in 1...31 {
            if day < 10 {
                dayData.append("0" + String(day))
            }else {
                dayData.append(String(day))
            }
        }
        
        dayPickerView.selectRow(dayData.firstIndex(of: day) ?? 0, inComponent: 0, animated: true)
    }
    
    func backEvent() {
        disposeBag = DisposeBag()
        dismiss(animated: false, completion: nil)
    }
    
    func confirmEvent() {
        if let pvc = self.presentingViewController as? UINavigationController {
            
            let lastView = pvc.viewControllers[pvc.viewControllers.count-1] //해당 화면을 호출 한 화면 (제일 마지막 stack view)
            if let userInfoUpdateVC:UserInfoUpdateVC = lastView as? UserInfoUpdateVC {
                let y = yearData[yearPickerView.selectedRow(inComponent: 0)]
                let m = monthData[monthPickerView.selectedRow(inComponent: 0)]
                let d = dayData[dayPickerView.selectedRow(inComponent: 0)]
                userInfoUpdateVC.datePickerCallBack(y: y, m: m, d: d)
                backEvent()
            }
        }
    }
    
    func delegateInit() {
        yearPickerView.delegate = self
        yearPickerView.dataSource = self
        
        monthPickerView.delegate = self
        monthPickerView.dataSource = self
        
        dayPickerView.delegate = self
        dayPickerView.dataSource = self
    }
    
    func uiInit() {
        yearPickerView.setValue(UIColor.black, forKey: "textColor")
        yearPickerView.setValue(UIColor.clear, forKey: "magnifierLineColor")
        yearPickerView.backgroundColor = .white
        
        monthPickerView.setValue(UIColor.black, forKey: "textColor")
        monthPickerView.setValue(UIColor.clear, forKey: "magnifierLineColor")
        monthPickerView.backgroundColor = .white
        
        dayPickerView.setValue(UIColor.black, forKey: "textColor")
        dayPickerView.setValue(UIColor.clear, forKey: "magnifierLineColor")
        dayPickerView.backgroundColor = .white
        
        datePickerWrap.layer.cornerRadius = 5.0
    }
}


extension DatePickerPopVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == yearPickerView {
            return yearData.count
        }else if pickerView == monthPickerView {
            return monthData.count
        }else {
            return dayData.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView == yearPickerView {
            return yearData[row]
        }else if pickerView == monthPickerView {
            return monthData[row]
        }else {
            return dayData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 63
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            
            
            pickerLabel?.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 23)
            pickerLabel?.textAlignment = .center
        }
        
        if pickerView == yearPickerView {
            pickerLabel?.text = yearData[row]
            
        }else if pickerView == monthPickerView {
            pickerLabel?.text = monthData[row]
        }else {
            pickerLabel?.text = dayData[row]
        }
        
        pickerLabel?.textColor = UIColor.black
        
        return pickerLabel!
    }
}
