//
//  SignUpAreaCell.swift
//  WetProject
//
//  Created by 남오승 on 2020/12/02.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

//회원가입 시 지역정보 리스트를 호출하는 화면을 위한 UICell 컴포넌트
class SignUpAreaSettingCell: UICollectionViewCell, StoryboardView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var confirmBtn: UIButton!
    
    @IBOutlet weak var areaHeaderCV: UICollectionView!
    @IBOutlet weak var areaDetailCV: UICollectionView!
    
    @IBOutlet weak var area01Wrap: UIView!
    @IBOutlet weak var area02Wrap: UIView!
    @IBOutlet weak var area01GL: UILabel!
    @IBOutlet weak var area01PlaceHolderGL: UILabel!
    
    @IBOutlet weak var area02GL: UILabel!
    @IBOutlet weak var area02PlaceHolderGL: UILabel!
    
    var disposeBag: DisposeBag = DisposeBag()
    var signUpRT = SignUpRT()
    
    var areaHeaderList:[SignUpAreaList]?
    var areaDetailList:[SignUpAreaList]?
    
    var area01Code:String = String()
    var area02Code:String = String()
    var area03Code:String = String()
    var area02Name:String = String()
    var area03Name:String = String()
    
    var areaFlag:Bool = true
    
    var depth:Int = 0
    
    var callingView:Any?
    
    var confirmValidation:BehaviorRelay<Bool> = BehaviorRelay.init(value: false)
        
    override func awakeFromNib() {
        super.awakeFromNib()
        reactor = signUpRT
        
        areaHeaderCV.delegate = self
        areaHeaderCV.dataSource = self
        areaHeaderCV.register(UINib(nibName: "SignUpAreaCell", bundle: nil), forCellWithReuseIdentifier: "SignUpAreaCell")
        
        areaDetailCV.delegate = self
        areaDetailCV.dataSource = self
        areaDetailCV.register(UINib(nibName: "SignUpAreaCell", bundle: nil), forCellWithReuseIdentifier: "SignUpAreaCell")
        
        confirmBtn.layer.cornerRadius = 4.0
        confirmBtn.shadow(opacity: 0.38, radius: 3, offset: CGSize(width: 3, height: 3), color: UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1).cgColor)
    }
    
    func bind(reactor:SignUpRT) {
        /* UIEvent */
        
        area01Wrap.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext:{ [weak self] _ in
                self?.areaTextCtrl(areaDivision: false, flag: false)
                self?.areaTextCtrl(areaDivision: true, flag: false)
                self?.confirmValidation.accept(false)
                self?.depth = 0
                self?.getArea(code: nil)
            })
            .disposed(by: disposeBag)
        
        area02Wrap.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext:{ [weak self] _ in
                self?.areaTextCtrl(areaDivision: false, flag: false)
                self?.confirmValidation.accept(false)
                self?.depth = 1
                self?.getArea(code: self?.area01Code)
            })
            .disposed(by: disposeBag)

        confirmBtn.rx.tap
            .asDriver()
            .drive(onNext:{ [weak self] _ in
                self?.nextEvent()
            })
            .disposed(by: disposeBag)
        /* */
        
        /* Action */
        
        getArea(code: nil)
        /* */
        
        /* State */
        
        let isArea = reactor.state.map{$0.isArea}.filter{$0 != nil}
        
        isArea.bind{[weak self] result in
            if self?.areaFlag ?? true {
                self?.areaHeaderCV.isHidden = false
                self?.areaDetailCV.isHidden = true
                self?.areaHeaderList = result
                self?.areaHeaderCV.reloadData()
                self?.areaFlag = false
                self?.depth += 1
            }else {
                self?.areaHeaderCV.isHidden = true
                self?.areaDetailCV.isHidden = false
                
                if (result?.count ?? 0) > 0 {
                    self?.areaDetailList = result
                    if self?.depth == 1 {
                        self?.depth += 1
                    }else if self?.depth == 2 {
                        self?.area02GL.text = (self?.area02Name ?? "")
                        self?.depth += 1
                        self?.confirmValidation.accept(false)
                    }
                }else {
                    if self?.depth == 2 {
                        self?.area02GL.text = (self?.area02Name ?? "")
                    }else { //depth == 3
                        self?.area02GL.text = (self?.area02Name ?? "") + " " + (self?.area03Name ?? "")
                    }
                }
                
                self?.areaDetailCV.reloadData()
            }
        }.disposed(by: disposeBag)
        
        confirmValidation.asDriver()
            .drive(onNext: { [weak self] data in
                self?.confirmBtnSetting(validationFlag: data)
            })
            .disposed(by: disposeBag)
        
        /* */
    }

    func areaTextCtrl(areaDivision:Bool,flag:Bool) {
        if areaDivision {//area01
            if flag { //숨김여부
                area01GL.isHidden = false
                area01PlaceHolderGL.isHidden = true
            }else {
                areaFlag = true
                area01GL.isHidden = true
                area01PlaceHolderGL.isHidden = false
                area01GL.text = ""
                area02GL.text = ""
                area01Code = ""
                area02Code = ""
                area03Code = ""
                area02Name = ""
                area03Name = ""
            }
        }else {//area02
            if flag {
                area02GL.isHidden = false
                area02PlaceHolderGL.isHidden = true
            }else {
                areaFlag = false
                area02GL.isHidden = true
                area02PlaceHolderGL.isHidden = false
                area02GL.text = ""
                area02Code = ""
                area02Name = ""
                area03Code = ""
                area03Name = ""
            }
        }
    }
    
    func getArea(code:String?) {
        if let signUpVC = callingView as? SignUpVC {
            if(signUpVC.isInternetAvailable)(){
                log.info("Network Connected")
            } else {
                signUpVC.netWorkStateToast(errorIndex: 0)
                log.info("Network DisConnected")
                return
            }
        }
        
        if let reactor = reactor {
            if let code = code {
                let params = [
                    "c" : code
                ]
                reactor.action.onNext(.area(params))
            }else {
                reactor.action.onNext(.area(nil))
            }
        }
    }
    
    //확인버튼 색 변경 체크 후 세팅
    func confirmBtnSetting(validationFlag:Bool) {
        if validationFlag {
            confirmBtn.backgroundColor = UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1)
        }else {
            confirmBtn.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
        }
    }
    
    func nextEvent() {
        let validation = confirmValidation.value
        if validation {
            if let signUpVC = callingView as? SignUpVC {
                if let  userRQInfo:SignInRQModel = SignUpUserInfo.shared.userRQInfo {
                    if let userRPInfo:SignInRPModelData = SignUpUserInfo.shared.userRPInfo {
                        let hasBirth:Bool = userRPInfo.user?.hasBirth ?? false
                        let hasGender:Bool = userRPInfo.user?.hasGender ?? false
                        let userId:String = userRPInfo.user?.userID ?? ""
                        let oauthProvider:String = userRQInfo.oauth_provider
                        let oauthToken:String = userRQInfo.oauth_token 
                        let nickName:String = signUpVC.nickName
                        var gender:String = ""
                        var birth:String = ""
                        var areaCode:String = ""
                        let deviceModel:String = UIDevice.modelName
                        if hasGender {
                            gender = userRPInfo.user?.gender ?? ""
                        }else {
                            gender = signUpVC.gender
                        }
                        
                        if hasBirth {
                            birth = userRPInfo.user?.birth ?? ""
                        }else {
                            birth = signUpVC.birth
                        }
                        
                        if depth == 2 {
                            areaCode = area02Code
                        }else {
                            areaCode = area03Code
                        }
                        
                        let deviceId: String = UIDevice.current.identifierForVendor?.uuidString ?? "" //UDID
                        var signInRQModel:SignInRQModel = SignInRQModel(oauth_provider: oauthProvider, oauth_token: oauthToken, user_id: userId, nickname: nickName, birth: birth, gender: gender, address: areaCode, device_platform: "IOS", device_model: deviceModel, device_id: deviceId)
                        
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == areaHeaderCV {
            guard let areaList = areaHeaderList else {return 0}
            return areaList.count
        }else {
            guard let areaList = areaDetailList else {return 0}
            return areaList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let signUpAreaCell : SignUpAreaCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "SignUpAreaCell", for: indexPath) as? SignUpAreaCell
        
        if collectionView == areaHeaderCV {
            if let areaList = areaHeaderList {
                let code = areaList[indexPath.row].code
                signUpAreaCell?.areaName.text = areaList[indexPath.row].name
                if area01Code == code {
                    signUpAreaCell?.areaBGImage.image = UIImage(named: "roundboxOrange")
                }else {
                    signUpAreaCell?.areaBGImage.image = UIImage(named: "roundboxWhite")
                }
            }
        }else {
            if let areaList = areaDetailList {
                let code = areaList[indexPath.row].code
                signUpAreaCell?.areaName.text = areaList[indexPath.row].name
                if depth == 2 {
                    if area02Code == code {
                        signUpAreaCell?.areaBGImage.image = UIImage(named: "roundboxOrange")
                    }
                }else {
                    if area03Code == code {
                        signUpAreaCell?.areaBGImage.image = UIImage(named: "roundboxOrange")
                    }
                }
            }
        }
        
        return signUpAreaCell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == areaHeaderCV {
            guard let areaList = areaHeaderList else {return}
            let code:String = areaList[indexPath.row].code
            let name:String = areaList[indexPath.row].name
            area01Code = code
            area01GL.text = name
            areaTextCtrl(areaDivision: true, flag: true)
            getArea(code: code)
        }else {
            guard let areaList = areaDetailList else {return}
            let code:String = areaList[indexPath.row].code
            let name:String = areaList[indexPath.row].name
            if depth == 2 {
                area02Code = code
                area02Name = name
                confirmValidation.accept(true)
            }else if depth == 3 {
                area03Code = code
                area03Name = name
                confirmValidation.accept(true)
            }
            areaTextCtrl(areaDivision: false, flag: true)
            getArea(code: code)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width = CGFloat(0.0)
        var height = CGFloat(0.0)
        
        width = areaHeaderCV.frame.width/4.0
        height = 38.0
        
        let size = CGSize(width: width, height: height)
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
