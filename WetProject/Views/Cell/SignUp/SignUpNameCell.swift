//
//  SignUpNameCell.swift
//  WetProject
//
//  Created by 남오승 on 2020/12/02.
//

import UIKit
import ReactorKit
import RxCocoa
import RxSwift

//회원가입 시 닉네임 화면을 위한 UICell 컴포넌트
class SignUpNameCell: UICollectionViewCell, StoryboardView {
    
    /* 닉네임 체크 관리 */
    @IBOutlet weak var nickNameTF: UITextField!
    @IBOutlet weak var nickNamePlaceHolderGL: UILabel!
    @IBOutlet weak var nickNameValidationGL: UILabel!
    @IBOutlet weak var validationBottomLine: UIView!
    
    /*  약관동의 관리 */
    @IBOutlet weak var allAgreeBtn: UIButton!
    @IBOutlet weak var allAgreeWrap: UIView!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var useTermsWrap: UIView!
    @IBOutlet weak var useTermsBtn: UIButton!
    @IBOutlet weak var useTermsMoveBtn: UIButton!
    
    @IBOutlet weak var privacyWrap: UIView!
    @IBOutlet weak var privacyBtn: UIButton!
    @IBOutlet weak var privacyMoveBtn: UIButton!
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var signUpRT = SignUpRT()
    //    var allAgreeFlagValidation:BehaviorRelay<(Bool)> = BehaviorRelay.init(value: (false))
    
    //    var useTermsFlagValidation:BehaviorRelay<(Bool)> = BehaviorRelay.init(value: (false))
    //    var privacyFlagValidation:BehaviorRelay<(Bool)> = BehaviorRelay.init(value: (false))
    var confirmValidation:BehaviorRelay<(Bool,Bool)> = BehaviorRelay.init(value: (false,false))
    
    var nickNameValidation = false
    var allAgreeFlag = false
    var useTermsFlag = false
    var privacyFlag = false
    
    var currentNickName:String = ""
    
    var callingView:Any?
    
    var nickName:String = String()
    
    var nickNameValidationList:[String] = ["개발","적셔","운영","관리자","운영자","관리"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reactor = signUpRT
        confirmBtn.layer.cornerRadius = 4.0
        confirmBtn.shadow(opacity: 0.38, radius: 3, offset: CGSize(width: 3, height: 3), color: UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1).cgColor)
        
    }
    
    func bind(reactor: SignUpRT) {
        /* UIEvent */
        nickNameTF.rx.text.orEmpty
            .asDriver()
            .distinctUntilChanged()
            .drive(onNext:{ [weak self] text in
                for validationName in self?.nickNameValidationList ?? []{
                    if text.contains(validationName) {
                        self?.nickNameValidationGL.nickNameValidationGLSetting(view: (self?.validationBottomLine)!, validationFlag: 1, callingView: self as Any)
                        var validation = self?.confirmValidation.value
                        validation?.0 = false
                        self?.confirmValidation.accept(validation ?? (false, false))
                        break
                    }else {
                        self?.nickNameGLSetting(nickNameCnt: text.count)
                        self?.nickNameValidation(flag: false, text: text)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        nickNameTF.rx.text.orEmpty
            .distinctUntilChanged()
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance) //작성 간격
            .filter{$0.count > 0}
            .subscribe(onNext:{ [weak self] text in
                if let signUpVC = self?.callingView as? SignUpVC {
                    if(signUpVC.isInternetAvailable)(){
                        log.info("Network Connected")
                    } else {
                        signUpVC.netWorkStateToast(errorIndex: 0)
                        log.info("Network DisConnected")
                        return
                    }
                }
                
                for validationName in self?.nickNameValidationList ?? []{
                    if text.contains(validationName) {
                        self?.nickNameValidationGL.nickNameValidationGLSetting(view: (self?.validationBottomLine)!, validationFlag: 1, callingView: self as Any)
                        var validation = self?.confirmValidation.value
                        validation?.0 = false
                        self?.confirmValidation.accept(validation ?? (false, false))
                        break
                    }else {
                        self?.nickNameGLSetting(nickNameCnt: text.count)
                        self?.nickNameValidation(flag: true, text: text)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        confirmBtn.rx.tap
            .asDriver()
            .drive(onNext:{ [weak self] _ in
                self?.nextEvent()
            })
            .disposed(by: disposeBag)
        
        
        allAgreeWrap.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext:{ [weak self] _ in
                self?.allAgreeSetting(flag: !(self?.confirmValidation.value.1 ?? false))
            })
            .disposed(by: disposeBag)
        
        useTermsWrap.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext:{ [weak self] _ in
                self?.useTermsSetting(flag: !(self?.useTermsFlag ?? false))
            })
            .disposed(by: disposeBag)
        
        privacyWrap.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext:{ [weak self] _ in
                self?.privacySetting(flag: !(self?.privacyFlag ?? false))
            })
            .disposed(by: disposeBag)
        
        useTermsMoveBtn.rx.tap
            .asDriver()
            .drive(onNext:{ [weak self] _ in
                if let signUpVC = self?.callingView as? SignUpVC {
                    signUpVC.policyMove(policyFlag: 0)
                }
            })
            .disposed(by: disposeBag)
        
        privacyMoveBtn.rx.tap
            .asDriver()
            .drive(onNext:{ [weak self] _ in
                if let signUpVC = self?.callingView as? SignUpVC {
                    signUpVC.policyMove(policyFlag: 1)
                }
            })
            .disposed(by: disposeBag)
        
        /* */
        
        /* Action */
        
        /* */
        
        /* State */
        
        let isNickNameCheck = reactor.state.map{$0.isNickNameCheck}.filter{$0 != nil}
        
        isNickNameCheck.bind{[weak self] result in
            for validationName in self?.nickNameValidationList ?? []{
                if self?.nickNameTF.text!.contains(validationName) ?? false {
                    self?.nickNameValidationGL.nickNameValidationGLSetting(view: (self?.validationBottomLine)!, validationFlag: 1, callingView: self as Any)
                    var validation = self?.confirmValidation.value
                    validation?.0 = false
                    self?.confirmValidation.accept(validation ?? (false, false))
                    break
                }else {
                    self?.nickNameValidationSetting(nameValidation: result ?? false)
                }
            }
            
        }.disposed(by: disposeBag)
        
        
        confirmValidation.asDriver()
            .drive(onNext: { [weak self] data in
                if data.0 && data.1 {
                    self?.confirmBtnSetting(validationFlag: true)
                }else {
                    self?.confirmBtnSetting(validationFlag: false)
                }
            })
            .disposed(by: disposeBag)
    }
    
    //회원가입
    func nextEvent() {
        let validation = confirmValidation.value
        if validation.0 && validation.1 {
            if let signUpVC = callingView as? SignUpVC {
                signUpVC.nickName = nickNameTF.text!
                if let signUpVC = callingView as? SignUpVC {
                    if let  userRQInfo:SignInRQModel = SignUpUserInfo.shared.userRQInfo {
                        if let userRPInfo:SignInRPModelData = SignUpUserInfo.shared.userRPInfo {
                            let userId:String = userRPInfo.user?.userID ?? ""
                            let oauthProvider:String = userRQInfo.oauth_provider
                            let oauthToken:String = userRQInfo.oauth_token
                            let nickName:String = signUpVC.nickName
                            let deviceModel:String = UIDevice.modelName
                            let deviceId: String = UIDevice.current.identifierForVendor?.uuidString ?? "" //UDID
                            
                            var signInRQModel:SignInRQModel = SignInRQModel(oauth_provider: oauthProvider, oauth_token: oauthToken, user_id: userId, nickname: nickName, device_platform: "IOS", device_model: deviceModel, device_id: deviceId)
                            
                            if let deviceToken: String = UserDefaults.standard.string(forKey: "APNSToken") {
                                signInRQModel.device_token = deviceToken
                            }
                            
                            if(signUpVC.isInternetAvailable)(){
                                log.info("Network Connected")
                            } else {
                                signUpVC.netWorkStateToast(errorIndex: 0)
                                log.info("Network DisConnected")
                                return
                            }
                            
                            signUpVC.reactor?.action.onNext(.signUp(signInRQModel))
                        }
                    }
                }
            }
        }
    }
    
    func nickNameGLSetting(nickNameCnt:Int) {
        if nickNameCnt > 0 {
            nickNamePlaceHolderGL.isHidden = true
        }else {
            nickNamePlaceHolderGL.isHidden = false
            nickNameValidationGL.nickNameValidationGLSetting(view: (validationBottomLine)!, validationFlag: 4, callingView: self as Any)
            var validation = confirmValidation.value
            validation.0 = false
            confirmValidation.accept(validation)
        }
    }
    
    func nickNameValidation(flag:Bool, text:String) {
        let nickNameCheckFlag:Bool = nickNameTF.nickNameValidationCheck(validationGL: nickNameValidationGL, validationBottomLine: validationBottomLine, currentNickName: nil, callingView: self as Any)
        
        if flag && nickNameCheckFlag {
            if let reactor = reactor {
                let params = [
                    "n" : text
                ]
                reactor.action.onNext(.nickNameCheck(params))
            }
        }
    }
    
    //닉네임 API 중복확인 후 세팅작업
    func nickNameValidationSetting(nameValidation:Bool) {
        nickNameValidationGL.isHidden = false
        
        if nameValidation { //닉네임 중복(사용불가능)
            nickNameValidationGL.nickNameValidationGLSetting(view: (validationBottomLine)!, validationFlag: 1, callingView: self as Any)
        }else { //사용가능
            nickNameValidationGL.nickNameValidationGLSetting(view: (validationBottomLine)!, validationFlag: 0, callingView: self as Any)
            nickNameGLSetting(nickNameCnt: nickNameTF.text?.count ?? 0)
        }
        
        var validation = confirmValidation.value
        validation.0 = !nameValidation
        confirmValidation.accept(validation)
    }
    
    func allAgreeSetting(flag:Bool) {
        if flag {
            allAgreeBtn.setImage(UIImage(named: "checkboxOrangeBig"), for: .normal)
            useTermsBtn.setImage(UIImage(named: "checkboxOrangeBig"), for: .normal)
            privacyBtn.setImage(UIImage(named: "checkboxOrangeBig"), for: .normal)
        }else {
            allAgreeBtn.setImage(UIImage(named: "checkboxGrayBig"), for: .normal)
            useTermsBtn.setImage(UIImage(named: "checkboxGrayBig"), for: .normal)
            privacyBtn.setImage(UIImage(named: "checkboxGrayBig"), for: .normal)
        }
        useTermsFlag = flag
        privacyFlag = flag
        var validation = confirmValidation.value
        validation.1 = flag
        confirmValidation.accept(validation)
    }
    
    func useTermsSetting(flag:Bool) {
        var validation = confirmValidation.value
        if flag {
            useTermsBtn.setImage(UIImage(named: "checkboxOrangeBig"), for: .normal)
            if privacyFlag {
                allAgreeBtn.setImage(UIImage(named: "checkboxOrangeBig"), for: .normal)
                validation.1 = true
            }else {
                allAgreeBtn.setImage(UIImage(named: "checkboxGrayBig"), for: .normal)
                validation.1 = false
            }
        }else {
            useTermsBtn.setImage(UIImage(named: "checkboxGrayBig"), for: .normal)
            allAgreeBtn.setImage(UIImage(named: "checkboxGrayBig"), for: .normal)
            validation.1 = false
        }
        useTermsFlag = flag
        confirmValidation.accept(validation)
    }
    
    func privacySetting(flag:Bool) {
        var validation = confirmValidation.value
        if flag {
            privacyBtn.setImage(UIImage(named: "checkboxOrangeBig"), for: .normal)
            if useTermsFlag {
                allAgreeBtn.setImage(UIImage(named: "checkboxOrangeBig"), for: .normal)
                validation.1 = true
            }else {
                allAgreeBtn.setImage(UIImage(named: "checkboxGrayBig"), for: .normal)
                validation.1 = false
            }
        }else {
            privacyBtn.setImage(UIImage(named: "checkboxGrayBig"), for: .normal)
            allAgreeBtn.setImage(UIImage(named: "checkboxGrayBig"), for: .normal)
            validation.1 = false
        }
        privacyFlag = flag
        confirmValidation.accept(validation)
    }
    
    //확인버튼 색 변경 체크 후 세팅
    func confirmBtnSetting(validationFlag:Bool) {
        if validationFlag {
            confirmBtn.backgroundColor = UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1)
        }else {
            confirmBtn.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
        }
    }
    
    //입력 텍스트 밖 영역 클릭시 키보드 내려가도록 해주는 함수
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
    
}
