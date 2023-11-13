//
//  UserInfoUpdateVC.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/19.
//

import UIKit
import RxCocoa
import RxSwift
import ReactorKit
//import RxGesture
import TLPhotoPicker
import Photos
import Mantis
//webp이미지 로드하기위한 플러그인
import Nuke
import NukeWebPPlugin
import SnapKit


//회원정보 수정 화면 UI를 컨트롤 하기위한 파일
class UserInfoUpdateVC: BaseViewController,StoryboardView {
    
    /* 프로필 이미지 */
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileImageWrap: UIView!
    @IBOutlet weak var defaultProfileImage: UIImageView!
    /* 닉네임 */
    @IBOutlet weak var nickNameGL: UILabel!
    @IBOutlet weak var nickNameTF: UITextField!
    @IBOutlet weak var validationGL: UILabel!
    @IBOutlet weak var validationBottomLine: UIView!
    /* 성별 */
    @IBOutlet weak var femaleWrap: UIView!
    @IBOutlet weak var femaleCheckImage: UIImageView!
    @IBOutlet weak var maleWrap: UIView!
    @IBOutlet weak var maleCheckImage: UIImageView!
    /* 생년월일 */
    @IBOutlet weak var datePickerWrap: UIView!
    @IBOutlet weak var yearGL: UILabel!
    @IBOutlet weak var monthGL: UILabel!
    @IBOutlet weak var dayGL: UILabel!
    /* 확인 */
    @IBOutlet weak var confirmBtnWrap: UIView!
    @IBOutlet weak var confirmBtn: UIButton!
    /* 기타 */
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var userInfoWrap: UIView!
    
    let userInfoUpdateRT = UserInfoUpdateRT()
    
    var currentProfileId:String = ""
    var currentNickName:String = ""
    var currentGender:String = ""
    var currentBirth:String = ""
    var birthInfo:BehaviorRelay<String> = BehaviorRelay.init(value: String())
    
    //프로필 이미지 바뀌었는지 여부
    var profileImageChangeFlag:BehaviorRelay<Bool> = BehaviorRelay.init(value: Bool())
    //생년월일 바뀌었는지 여부
    var birthChangeFlag:BehaviorRelay<Bool> = BehaviorRelay.init(value: Bool())
    //성별 바뀌었는지 여부
    var genderChangeFlag:BehaviorRelay<Bool> = BehaviorRelay.init(value: Bool())
    
    //0 : 닉네임 ,1 : 사진 ,2 : 성별 ,3 : 생년월일
    var confirmValidation:BehaviorRelay<(Bool,Bool,Bool,Bool)> = BehaviorRelay.init(value: (false,false,false,false))
    var mediaId:String = String()
    
    var image:UIImage?
    var croppedImage:UIImage?
    var gender:String = String()
    
    var selectedAssets = [TLPHAsset]()
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    @IBOutlet weak var selectedImage: UIImageView!
    
    var imageManager = PHCachingImageManager() //앨범에서 사진 받아오기 위한 객체
    
    var nickNameValidationList:[String] = ["개발","적셔","운영","관리자","운영자","관리"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reactor = userInfoUpdateRT
        profileImageWrap.shadow(opacity: 0.37, radius: 3, offset: CGSize(width: 1, height: 1),color: UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1).cgColor)
        
        confirmBtnWrap.layer.cornerRadius = 4.0
        confirmBtnWrap.shadow(opacity: 0.2, radius: 3, offset: CGSize(width: 3, height: 3),color: UIColor(red: 122/255, green: 122/255, blue: 122/255, alpha: 1).cgColor)
        profileImageWrap.snp.makeConstraints{ make in
            let height = aspectRatio(standardSize: 140)
            make.width.height.equalTo(height)
            profileImageWrap.layer.cornerRadius = height/2
            profileImage.layer.cornerRadius = height/2
        }
    }
    
    func bind(reactor:UserInfoUpdateRT) {
        
        let nickNameTFOb = nickNameTF.rx.text.orEmpty.asObservable()
        
        /* event */
        userInfoWrap.rx.tapGesture()
            .when(.recognized)
            .bind{ [weak self] _ in
                self?.view.endEditing(true)
            }.disposed(by: disposeBag)
        
        //뒤로가기
        backBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.backEvent()
            })
            .disposed(by: disposeBag)
        
        //유저 프로필 이미지 뷰
        profileImageWrap.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self]_ in
                self?.albumMoveEvent()
            })
            .disposed(by: disposeBag)
        
        femaleWrap.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: {[weak self] _ in
                self?.gender = "F"
                var confirm = self?.confirmValidation.value
                if self?.currentGender == "F" {
                    confirm?.2 = false
                }else {
                    confirm?.2 = true
                }
                self?.confirmValidation.accept(confirm ?? (false,false,false,false))
                self?.genderSetting(genderFlag: true)
            })
            .disposed(by: disposeBag)
        
        maleWrap.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: {[weak self] _ in
                self?.gender = "M"
                var confirm = self?.confirmValidation.value
                if self?.currentGender == "M" {
                    confirm?.2 = false
                }else {
                    confirm?.2 = true
                }
                self?.confirmValidation.accept(confirm ?? (false,false,false,false))
                self?.genderSetting(genderFlag: false)
            })
            .disposed(by: disposeBag)
        
        
        //닉네임 작성 중 이벤트
        nickNameTFOb
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance) //작성 간격
            .subscribe(onNext:{ [weak self] text in
                for validationName in self?.nickNameValidationList ?? []{
                    if text.contains(validationName) {
                        self?.nickNameValidationSetting(validation: true)
                        var confirm = self?.confirmValidation.value
                        confirm?.0 = false
                        self?.confirmValidation.accept(confirm ?? (false,false,false,false))
                        break
                    }else {
                        //닉네임 중복체크 이벤트 실행
                        var confirm = self?.confirmValidation.value
                        confirm?.0 = false
                        self?.confirmValidation.accept(confirm ?? (false,false,false,false))
                        
                        let nickNameCheckFlag = self?.nickNameCheckFlag() ?? false
                        
                        if nickNameCheckFlag {
                            let params = [
                                "n" : text
                            ]
                            reactor.action.onNext(.nickNameCheck(params))
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        datePickerWrap.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext:{[weak self] _ in
                self?.datePickerEvent()
            })
            .disposed(by: disposeBag)

        confirmBtn.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                if (self?.confirmValidation.value.0 ?? false) || (self?.confirmValidation.value.1 ?? false) || (self?.confirmValidation.value.2 ?? false) || (self?.confirmValidation.value.3 ?? false) {
                    self?.userInfoUpdate(reactor: reactor)
                }
            })
            .disposed(by: disposeBag)

        /* */
        
        /* action */
        
        //Network State Checking
        if(isInternetAvailable)(){
            log.info("Network Connected")
        } else {
            netWorkStateToast(errorIndex: 0)
            log.info("Network DisConnected")
            return
        }
        
        reactor.action.onNext(.myInfo)
        
        /* */
        
        /* state */
        
        let isMyInfo = reactor.state.map{$0.isMyInfo}.filter{$0 != nil}
        let isNickNameCheck = reactor.state.map{$0.isNickNameCheck}.filter{$0 != nil} //닉네임 사용여부 체크
        let isImageUploadSuccess = reactor.state.map{$0.isImageUploadSuccess}.filter{$0 != nil} //프로필 이미지 업로드 성공여부
        let isUserUpdateSuccess = reactor.state.map{$0.isUserUpdateSuccess}.filter{$0 != nil}.map{$0 ?? false} //유저 정보 변경 성공여부
        let isIndicator = reactor.state.map{$0.isIndicator}
        
        let isTimeOut = reactor.state.map{$0.isTimeOut}.filter{$0 != nil}.map{$0 ?? false}
        
        //서버 타임아웃 에러
        isTimeOut
            .bind{[weak self] result in
            if result {
                self?.netWorkStateToast(errorIndex: 408)
            }
        }.disposed(by: disposeBag)
        
        isIndicator.bind{[weak self] result in
            self?.loadingIndicator(flag: result ?? false)
            
        }.disposed(by:disposeBag)
        
        //유저 정보 조회
        isMyInfo.bind{[weak self] result in
            self?.userInfoSetting(result: result)
        }.disposed(by: disposeBag)
        
        //닉네임 체크
        isNickNameCheck.bind{[weak self] result in
            for validationName in self?.nickNameValidationList ?? []{
                if self?.nickNameTF.text!.contains(validationName) ?? false{
                    self?.nickNameValidationSetting(validation: true)
                    var confirm = self?.confirmValidation.value
                    confirm?.0 = false
                    self?.confirmValidation.accept(confirm ?? (false,false,false,false))
                    break
                }else {
                    var confirm = self?.confirmValidation.value
                    self?.nickNameValidationSetting(validation: result?.result ?? true)
                    confirm?.0 = !(result?.result ?? true)

                    self?.confirmValidation.accept(confirm ?? (false,false,false,false))
                }
            }
        }.disposed(by: disposeBag)

        //유저 이미지 업로드
        isImageUploadSuccess
            .bind{[weak self] result in
                var confirm = self?.confirmValidation.value
                let profileImageUrl:String = result?.mediaResource?.medium?.src ?? ""
                let profileMediaId:String = result?.mediaId ?? ""
                self?.mediaId = profileMediaId
                self?.profileImageWebpSetting(urlString: profileImageUrl)
                confirm?.1 = true
                self?.confirmValidation.accept(confirm ?? (false,false,false,false))
            }.disposed(by: disposeBag)
        
        //유저정보 변경
        isUserUpdateSuccess.bind{[weak self] result in
            if result {
                self?.backFinalEvent()
            }
        }.disposed(by: disposeBag)

        //생년월일 콜백
        birthInfo
            .asDriver()
            .filter { $0 != ""}
            .drive(onNext: { [weak self] birth in
                var confirm = self?.confirmValidation.value
    
                if self?.currentBirth != birth {
                    confirm?.3 = true
                }else {
                    confirm?.3 = false
                }
                self?.confirmValidation.accept(confirm ?? (false,false,false,false))
            })
            .disposed(by: disposeBag)

        confirmValidation.asDriver()
            .drive(onNext :{ [weak self] data in
                if data.0 || data.1 || data.2 || data.3 {
                    self?.confirmBtnWrap.backgroundColor = UIColor(red: 253/255, green: 177/255, blue: 78/255, alpha: 1)
                }else {
                    self?.confirmBtnWrap.backgroundColor = UIColor(red: 207/255, green: 207/255, blue: 207/255, alpha: 1)
                }
            })
            .disposed(by: disposeBag)
        
        /* */
        
        /* 토큰 관리 (공통) */
        
        //로그인 여부 체크
        reactor.state.map{ $0.isLogin }
            .filter{$0 != nil}
            .subscribe(onNext:{ result in
                if !(result ?? true) { //로그아웃 시
                    LoginService.shared.login(callingView: self as Any)
                }
            })
            .disposed(by: disposeBag)
        
        //토큰 갱신
        reactor.state.map{$0.isTokenRenewal}
            .observeOn(MainScheduler.asyncInstance)
            .filter{$0 != nil}
            .subscribe(onNext:{ result in
                reactor.action.onNext(.accessTokenSave(result))
            }).disposed(by: disposeBag)
        
        //토큰 갱신 후 -> 내장 저장 -> 기존에 실행하려 했던 이벤트 실행
        reactor.state.map{$0.isAccessTokenSave}
            .observeOn(MainScheduler.asyncInstance)
            .filter{$0 != nil}
            .subscribe(onNext: { result in
                if result?.saveFlag ?? false {
                    if result?.eventIndex == 0 { //유저 정보 조회
                        reactor.action.onNext(.myInfo)
                    }else if result?.eventIndex == 1 { //닉네임 체크
                        reactor.action.onNext(.nickNameCheck(result?.nickNameParams))
                    }else if result?.eventIndex == 2 { //프로필 사진 업로드
                        reactor.action.onNext(.imageUpload(profileImage: result?.imageParams))
                    }else if result?.eventIndex == 3 { //유저 정보 업데이트
                        reactor.action.onNext(.userUpdate(result?.params))
                    }
                }else { //갱신 실패
                    log.error("Token Renewal Fail")
                }
            })
            .disposed(by: disposeBag)
        
        /* */
    }

    
    //유저정보 업데이트
    func userInfoUpdate(reactor:UserInfoUpdateRT) {
        let year = yearGL.text ?? ""
        let month = monthGL.text ?? ""
        let day = dayGL.text ?? ""
        let birth = year + "-" + month + "-" + day
        var profile:UserProfileImage?
        if mediaId != "" {
            profile = UserProfileImage(type: "image", media_id: mediaId)
        }
    
        
        if gender == "" {
            gender = currentGender
        }
        
        if let nickName = nickNameTF.text {
            if gender != "" {
                if year != "" {
                    let params: UserInfoUpdateRQModel = UserInfoUpdateRQModel(profile: profile, nickname: nickName, birth: birth, gender: gender)
                    reactor.action.onNext(.userUpdate(params))
                }else {
                    let params: UserInfoUpdateRQModel = UserInfoUpdateRQModel(profile: profile, nickname: nickName, gender: gender)
                    reactor.action.onNext(.userUpdate(params))
                }
            }else {
                if year != "" {
                    let params: UserInfoUpdateRQModel = UserInfoUpdateRQModel(profile: profile, nickname: nickName, birth: birth)
                    reactor.action.onNext(.userUpdate(params))
                }else {
                    let params: UserInfoUpdateRQModel = UserInfoUpdateRQModel(profile: profile, nickname: nickName)
                    reactor.action.onNext(.userUpdate(params))
                }
            }
        }
    }
 
    func nickNameCheckFlag() -> Bool {
        let nickNameCheckFlag = nickNameTF.nickNameValidationCheck(validationGL: validationGL, validationBottomLine: validationBottomLine, currentNickName: currentNickName, callingView: self as Any)
        return nickNameCheckFlag
    }
    
    //리턴받은 유저 정보를 바탕으로 데이터 바인딩
    func userInfoSetting(result:MyInfoRPModelData?) {
        let nickName:String = result?.userInfo?.nickname ?? ""
        let birth = (result?.userInfo?.birth ?? "").split(separator: "-")
        let gender:String = result?.userInfo?.gender ?? ""
        
        if (result?.userInfo?.profile?.count ?? 0) > 0 {
            let profileMediaId:String = result?.userInfo?.profile?[0].mediaId ?? ""
            let profileImageUrl:String = result?.userInfo?.profile?[0].mediaResource?.medium?.src ?? ""
            if profileImageUrl == "" {
                defaultProfileImage.isHidden = false
            }else {
                profileImageWebpSetting(urlString: profileImageUrl)
                currentProfileId = profileMediaId
            }
        }else {
            defaultProfileImage.isHidden = false
        }
        
        
        currentNickName = nickName
        nickNameTF.text = nickName
        nickNameGL.isHidden = true
        currentGender = gender
        if gender != "" {
            if gender == "F" {
                genderSetting(genderFlag: true)
            }else {
                genderSetting(genderFlag: false)
            }
        }

        if birth.count > 0 {
            currentBirth = String(birth[0]) + "-" + String(birth[1]) + "-" + String(birth[2])
            yearGL.text = String(birth[0])
            monthGL.text = String(birth[1])
            dayGL.text = String(birth[2])
        }
    }
    
    //닉네임 API 중복확인 후 세팅작업
    func nickNameValidationSetting(validation:Bool) {
        validationGL.isHidden = false
        if validation { //닉네임 중복(사용불가능)
            validationGL.nickNameValidationGLSetting(view: (validationBottomLine)!, validationFlag: 1, callingView: self as Any)
        }else { //사용가능
            validationGL.nickNameValidationGLSetting(view: (validationBottomLine)!, validationFlag: 0, callingView: self as Any)
        }
    }
    
    func nickNameGLSetting(nickNameCnt:Int) {
        if nickNameCnt > 0 {
            nickNameGL.isHidden = true
        }else {
            nickNameGL.isHidden = false
            validationGL.nickNameValidationGLSetting(view: (validationBottomLine)!, validationFlag: 4, callingView: self as Any)
        }
    }
    
    //뒤로가기 버튼 누르면 발생하는 이벤트
    func backEvent() {
        if confirmValidation.value.0 || confirmValidation.value.1 || confirmValidation.value.2 || confirmValidation.value.3 {
            let customAlertPopVC = StoryBoardName.popupStoryBoard.instantiateViewController(withIdentifier: "CustomAlertPopVC") as! CustomAlertPopVC
            customAlertPopVC.modalPresentationStyle = .overCurrentContext
            customAlertPopVC.alertFlag = 2
            present(customAlertPopVC, animated: false, completion: nil)
        }else {//하나도 바뀐게 없으면 바로 뒤로가기
            backFinalEvent()
        }
    }
    
    //완전히 뒤로 가는 이벤트
    func backFinalEvent() {
        navigationController?.popViewController(animated: true)
    }
    
    //성별 세팅 이벤트
    func genderSetting(genderFlag:Bool) {
        //true : 여성, false : 남성
        if genderFlag {
            femaleCheckImage.image = UIImage(named: "checkboxOrangeBig")
            maleCheckImage.image = UIImage(named: "checkboxGrayBig")
 
        }else {
            femaleCheckImage.image = UIImage(named: "checkboxGrayBig")
            maleCheckImage.image = UIImage(named: "checkboxOrangeBig")
        }
    }
    
    //날짜 선택 팝업에서 선택 후 호출
    func datePickerCallBack(y:String,m:String,d:String) {
        let birth = y + "-" + m + "-" + d
        
        yearGL.text = y
        monthGL.text = m
        dayGL.text = d
        
        birthInfo.accept(birth)
    }
    
    //날짜 선택 팝업 띄우는 이벤트
    func datePickerEvent() {
        let datePickerPopVC = StoryBoardName.popupStoryBoard.instantiateViewController(withIdentifier: "DatePickerPopVC") as! DatePickerPopVC
        datePickerPopVC.modalPresentationStyle = .overCurrentContext
        datePickerPopVC.year = yearGL.text!
        datePickerPopVC.month = monthGL.text!
        datePickerPopVC.day = dayGL.text!
        present(datePickerPopVC, animated: false, completion: nil)
    }
    
    //입력 텍스트 밖 영역 클릭시 키보드 내려가도록 해주는 함수
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //webp프로필 이미지 세팅하기위한 메소드
    func profileImageWebpSetting(urlString: String) {
        if urlString.count > 0 {
            defaultProfileImage.isHidden = true
            profileImage.isHidden = false
            WebPImageDecoder.enable()
            let webpimageURL = URL(string: urlString)!
            Nuke.loadImage(with: webpimageURL, into: profileImage)
        }else {
            defaultProfileImage.isHidden = false
            profileImage.isHidden = true
        }
    }
    
    //엘범 호출하는 이벤트
    func albumMoveEvent() {
        let alcoholStatus = PHPhotoLibrary.authorizationStatus()
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video);

        if cameraStatus == .authorized {// 권한 설정이 되었을 때 처리
            if alcoholStatus == .authorized { // 권한 설정이 되었을 때 처리
                photoMove()
            } else if alcoholStatus == .denied  { // 권한 설정이 거부 되었을 때
                accessDeniedAlert(flag: true)
            } else if alcoholStatus == .notDetermined {
                // 결정 안됨 (아래와 같이 시스템 팝업 띄움)
                PHPhotoLibrary.requestAuthorization({ [weak self] (result:PHAuthorizationStatus) in
                    switch result{
                    case .authorized: // 권한 설정이 되었을 때 처리
                        DispatchQueue.main.async {
                            self?.photoMove()
                        }
                        break
                    case .denied: // 권한 설정이 거부 되었을 때
                        DispatchQueue.main.async {
                            self?.accessDeniedAlert(flag: true)
                        }
                        break
                    default:
                        break
                    }
                })
            }
        } else if cameraStatus == .denied {// 권한 설정이 거부 되었을 때
            accessDeniedAlert(flag: false)
        }else if cameraStatus == .notDetermined { //초기 물음
            // 결정 안됨 (아래와 같이 시스템 알럿 띄움)
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { [weak self] response in
                if response { // 권한 설정이 되었을 때 처리
                    if alcoholStatus == .authorized { // 권한 설정이 되었을 때 처리
                        self?.photoMove()
                    } else if alcoholStatus == .denied  { // 권한 설정이 거부 되었을 때
                        self?.accessDeniedAlert(flag: true)
                    } else if alcoholStatus == .notDetermined {
                        // 결정 안됨 (아래와 같이 시스템 팝업 띄움)
                        PHPhotoLibrary.requestAuthorization({ [weak self] (result:PHAuthorizationStatus) in
                            switch result{
                            case .authorized: // 권한 설정이 되었을 때 처리
                                DispatchQueue.main.async {
                                    self?.photoMove()
                                }
                                break
                            case .denied: // 권한 설정이 거부 되었을 때
                                DispatchQueue.main.async {
                                    self?.accessDeniedAlert(flag: true)
                                }
                                break
                            default:
                                break
                            }
                        })
                    }
                } else { // 권한 설정이 거부 되었을 때
                    DispatchQueue.main.async {
                        self?.accessDeniedAlert(flag: false)
                    }
                }
            }
        }
    }
    
    //앨범 + 카메라 접근
    func photoMove() {
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = self
        var configure = TLPhotosPickerConfigure() //커스텀
        
        configure.cancelTitle = "취소"
        configure.doneTitle = "완료"
        configure.emptyMessage = "앨범이 없습니다."
        configure.allowedVideo = false
        configure.allowedVideoRecording = false
        configure.allowedLivePhotos = false
        configure.singleSelectedMode = true
        configure.tapHereToChange = "앨범 변경"
        configure.selectedColor = UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1.0)
        viewController.configure = configure
        
        present(viewController, animated: true, completion: nil)
    }
    
    func accessDeniedAlert(flag:Bool) {
        var alert = UIAlertController(title: "고객님의 원활한 '적셔' \n서비스 이용을 위해\n아래의 앨범 접근 권한 허용이 필요합니다.", message: "\n프로필 설정 시 이미지 첨부", preferredStyle: .alert)
        if !flag {
            alert = UIAlertController(title: "고객님의 원활한 '적셔' \n서비스 이용을 위해\n아래의 카메라 접근 권한 허용이 필요합니다.", message: "\n프로필 설정 시 이미지 첨부", preferredStyle: .alert)
        }
        
        // Change font and color of title
        
        alert.setValue(NSAttributedString(string: alert.title!, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold), NSAttributedString.Key.foregroundColor : UIColor.black]), forKey: "attributedTitle")
        
        alert.setValue(NSAttributedString(string: alert.message!, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13,weight: UIFont.Weight.regular),NSAttributedString.Key.foregroundColor :UIColor.black]), forKey: "attributedMessage")
        
        let subview = (alert.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
        
        alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: { (action:UIAlertAction!) in
            if let settingUrl = URL(string:UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingUrl)
            } else {
                print("Setting URL invalid")
            }
        }))
        
        subview.backgroundColor = UIColor.white
        
        self.present(alert, animated: true)
    }
}

//이미지 호출 후 크롭하기위한 extension
extension UserInfoUpdateVC: TLPhotosPickerViewControllerDelegate, CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage) {
        if let reactor = self.reactor {
            croppedImage = cropped
            reactor.action.onNext(.imageUpload(profileImage: cropped))
        }
    }
    
    //TLPhotosPickerViewControllerDelegate
    func shouldDismissPhotoPicker(withTLPHAssets: [TLPHAsset]) -> Bool {
        // use selected order, fullresolution image
        selectedAssets = withTLPHAssets
        return true
    }
    
    func dismissPhotoPicker(withPHAssets: [PHAsset]) {
        if withPHAssets.count > 0 {
            self.imageManager.requestImage(for: withPHAssets[0], targetSize: .zero, contentMode: .aspectFill, options: nil, resultHandler: { image, info in
                
                //고품질 사진 확인
                if let complete = (info?["PHImageResultIsDegradedKey"] as? Bool) {
                    if !complete {
                        if let image = image {
                            let cropViewController = Mantis.cropViewController(image: image)
                            cropViewController.delegate = self
                            cropViewController.modalPresentationStyle = .fullScreen
                            self.present(cropViewController, animated: true)
                        }
                    }
                }
            })
        }
    }
    
    func photoPickerDidCancel() {
        // cancel
    }
    
    func dismissComplete() {
        // picker viewcontroller dismiss completion
    }
    
    func canSelectAsset(phAsset: PHAsset) -> Bool {
        //Custom Rules & Display
        //You can decide in which case the selection of the cell could be forbidden.
        return true
    }
    
    func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
        // exceed max selection
    }
    
    func handleNoAlbumPermissions(picker: TLPhotosPickerViewController) {
        // handle denied albums permissions case
    }
    
    func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
        // handle denied camera permissions case
    }
}
