//
//  MyAlcoholLevelVC.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/21.
//

import UIKit
import SideMenu
import ReactorKit
import RxSwift
import Lottie

//내 주류 레벨 화면 UI를 컨트롤 하기위한 파일
class MyAlcoholLevelVC: BaseViewController, StoryboardView {

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var logoutWrap: UIView!
    @IBOutlet weak var loginWrap: UIView!
    
    //Ex)술을 즐기는 사람
    @IBOutlet weak var reviewLevelGL: UILabel!
    //까지 0병 남았습니다
    @IBOutlet weak var reviewLevelCntGL: UILabel!
    
    //주류 레벨 안내문구
    @IBOutlet weak var statusGL: UILabel!
    @IBOutlet weak var lottieWrap: UIView!
    
    @IBOutlet weak var levelBottleImage01: UIImageView!
    @IBOutlet weak var levelBottleImage02: UIImageView!
    @IBOutlet weak var levelBottleImage03: UIImageView!
    @IBOutlet weak var levelBottleImage04: UIImageView!
    @IBOutlet weak var levelBottleImage05: UIImageView!
    @IBOutlet weak var levelBottleImage06: UIImageView!
    @IBOutlet weak var levelBottleImage07: UIImageView!
    @IBOutlet weak var levelBottleImage08: UIImageView!
    @IBOutlet weak var levelBottleImage09: UIImageView!
    @IBOutlet weak var levelBottleImage10: UIImageView!
    
    @IBOutlet weak var alcoholLevelImage: UIImageView!
    
    @IBOutlet weak var alcoholLevelWrap: UIView!
    
    @IBOutlet weak var bottomBottleWrap: UIView!
    @IBOutlet weak var bottomWaveWrap: UIView!
    @IBOutlet weak var bottomGLWrap: UIView!
    @IBOutlet weak var levelFullGL01: UILabel!
    @IBOutlet weak var levelFullGL02: UILabel!
    @IBOutlet weak var levelFullGL03: UILabel!

    
    let myAlcoholLevelRT = MyAlcoholLevelRT()
    
    let color:CGColor = UIColor(red: 255/255, green: 185/255, blue: 91/255, alpha: 1).cgColor
    
    private var observer: NSObjectProtocol?
    
    var levelAnimationView:AnimationView = AnimationView(name: "level_01_lottie")
    let waveAnimationView:AnimationView = AnimationView(name: "wave")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reactor = myAlcoholLevelRT
        //스와이프 해서 뒤로가기 허용
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        uiInit()
        
        observer = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification,
                                                                 object: nil,
                                                                 queue: .main) {
                                                                 [unowned self] notification in
                   // background에서 foreground로 돌아오는 경우 실행 될 코드
            if !levelAnimationView.isAnimationPlaying {
                levelAnimationView.play()
            }
            
            if !bottomWaveWrap.isHidden {
                if !waveAnimationView.isAnimationPlaying {
                    waveAnimationView.play()
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        disposeBag = DisposeBag()
    }
    
    deinit {
        disposeBag = DisposeBag()
        if let _ = observer {
            NotificationCenter.default.removeObserver(observer!)
        }
    }
    
    func bind(reactor: MyAlcoholLevelRT) {
        
        /* event */
        
        backBtn.rx.tap
            .asDriver()
            .drive(onNext:{ [weak self] _ in
                self?.backEvent()
            })
            .disposed(by: disposeBag)
        
        /* */
        
        /* action */
        
        if(isInternetAvailable()){
            log.info("Network Connected")
        } else {
            netWorkStateToast(errorIndex: 0)
            log.info("Network DisConnected")
            return
        }
        
        reactor.action.onNext(.levelAPI)
        
        /* */
        
        /* state */
        
        let isIndicator = reactor.state.map{$0.isIndecator}.filter{$0 != nil}.map{$0 ?? false}
        let isLevelInfo = reactor.state.map{$0.isLevelInfo}.filter{$0 != nil}
        let isError = reactor.state.map{$0.isErrors}.filter{$0.0 != nil}
        let isTokenError = reactor.state.map{$0.isTokenError}.filter{$0.0 != nil}
        
        let isTimeOut = reactor.state.map{$0.isTimeOut}.filter{$0 != nil}.map{$0 ?? false}
        
        //서버 타임아웃 에러
        isTimeOut
            .bind{[weak self] result in
            if result {
                self?.netWorkStateToast(errorIndex: 408)
            }
        }.disposed(by: disposeBag)

        //에러 여부
        isError.bind{ [weak self] result in
            if (result.0 ?? false) { //일반 API 에러
                self?.netWorkStateToast(errorIndex: 1)
            }
        }.disposed(by: disposeBag)
        
        //유효하지 않은 토큰 에러
        isTokenError
            .observeOn(MainScheduler.asyncInstance)
            .bind{[weak self] result in
            if (result.0 ?? false) { //유효하지 않은 토큰이면 그냥 로그아웃시키고 에러 문구띄워줌
                UserDefaults.standard.setValue(nil, forKey: "accessToken")
                UserDefaults.standard.setValue(nil, forKey: "refreshToken")
                
                self?.netWorkStateToast(errorIndex: 2)
            }
        }.disposed(by: disposeBag)
        
        isIndicator.bind{[weak self] result in self?.loadingIndicator(flag: result) }.disposed(by: disposeBag)
        
        isLevelInfo
            .observeOn(MainScheduler.asyncInstance)
            .asDriver(onErrorJustReturn: .none)
            .drive(onNext:{ [weak self] result in
                self?.bottleImageBind(image: result?.bottleImageList ?? [])
                self?.statusMSGBind(msg:result?.statusMsg ?? "로그인한 후 이용해보세요!",level: result?.level ?? 0)
                self?.levelImageBind(level: result?.level ?? 1)
                self?.nextLevelBind(nextMsg: result?.nextLevelMsg ?? "", remainderCnt: result?.remainderCnt ?? 0, nextLevel: (result?.level ?? 1) + 1)
                self?.levelLottieBind(level: result?.level ?? 1, level5Rank: result?.level5Rank ?? 0)
            }).disposed(by: disposeBag)
            
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
            .filter{$0.0 != nil && $0.1 != nil}
            .subscribe(onNext:{ result in
                if result.0 != "" {
                    reactor.action.onNext(.accessTokenSave(result.0, result.1))
                }
            })
            .disposed(by: disposeBag)
        
        //토큰 갱신 후 -> 내장 저장 -> 기존에 실행하려 했던 이벤트 실행
        reactor.state.map{$0.isAccessTokenSave}
            .observeOn(MainScheduler.asyncInstance)
            .filter{$0.0 != nil && $0.1 != nil}
            .subscribe(onNext: { result in
                if result.0 ?? false {
                    if result.1 == 0 { //레벨 조회 API 호출
                        reactor.action.onNext(.levelAPI)
                    }
                }else { //갱신 실패
                    log.error("토큰 갱신 실패")
                }
            })
            .disposed(by: disposeBag)
        
        /* */
    }
    
    //뒤로가기
    func backEvent() {
        navigationController?.popViewController(animated: true)
    }
    
    //레벨 상태메시지 색 변경
    func statusMSGSetting() {
        let attributedString = NSMutableAttributedString(string: statusGL.text!)
        
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: (statusGL.text! as NSString).range(of:"마시는 척 하는 사람"))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: (statusGL.text! as NSString).range(of:"술을 즐기는 사람"))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: (statusGL.text! as NSString).range(of:"술독에 빠진 사람"))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: (statusGL.text! as NSString).range(of:"주도를 수련하는 사람"))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: (statusGL.text! as NSString).range(of:"술로 해탈한 사람"))
        
        statusGL.attributedText = attributedString
    }
    
    //상태메시지 바인딩
    func statusMSGBind(msg:String,level:Int) {
        if level > 0 {
            loginWrap.isHidden = false
            logoutWrap.isHidden = true
        }else {
            loginWrap.isHidden = true
            logoutWrap.isHidden = false
        }
        statusGL.text = msg
        statusMSGSetting()
    }
    
    //가져온 술병 이미지 바인딩
    func bottleImageBind(image:Array<UIImage>) {
        if image.count > 0 {
            levelBottleImage01.image = image[0]
            levelBottleImage02.image = image[1]
            levelBottleImage03.image = image[2]
            levelBottleImage04.image = image[3]
            levelBottleImage05.image = image[4]
            levelBottleImage06.image = image[5]
            levelBottleImage07.image = image[6]
            levelBottleImage08.image = image[7]
            levelBottleImage09.image = image[8]
            levelBottleImage10.image = image[9]
        }
    }
    
    //레벨 에 대한 이미지 바인딩
    //json으로 변경해야함
    func levelImageBind(level:Int) {
        switch level {
        case 0:
            alcoholLevelImage.image = UIImage(named: "alcoholLevel0")
            break
        case 1:
            alcoholLevelImage.image = UIImage(named: "alcoholLevel1")
            break
        case 2:
            alcoholLevelImage.image = UIImage(named: "alcoholLevel2")
            break
        case 3:
            alcoholLevelImage.image = UIImage(named: "alcoholLevel3")
            break
        case 4:
            alcoholLevelImage.image = UIImage(named: "alcoholLevel4")
            break
        case 5:
            alcoholLevelImage.image = UIImage(named: "alcoholLevel5")
            break
        default:
            break
        }
    }
    
    func nextLevelBind(nextMsg:String, remainderCnt:Int, nextLevel:Int) {
        reviewLevelGL.text = nextMsg
        if nextLevel == 4 {
            reviewLevelGL.constraints.forEach { (constraint) in
                if constraint.firstAttribute == .width {
                    constraint.constant = 166.2
                }
            }
            reviewLevelGL.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20.0)
        }else {
            reviewLevelGL.constraints.forEach { (constraint) in
                if constraint.firstAttribute == .width {
                    constraint.constant = 145.0
                }
            }
            reviewLevelGL.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 22.0)
        }
        reviewLevelCntGL.text = "까지" + String(remainderCnt) + "병 남았습니다"
    }
    
    func levelLottieBind(level:Int, level5Rank:Int) {
        //level 1 :Default
        
        
        bottomWaveWrap.isHidden = true
        bottomGLWrap.isHidden = true
        bottomBottleWrap.isHidden = false
        
        if level == 2 {
            levelAnimationView = AnimationView(name: "level_02_lottie")
        }else if level == 3{
            levelAnimationView = AnimationView(name: "level_03_lottie")
        }else if level == 4 {
            levelAnimationView = AnimationView(name: "level_04_lottie")
        }else if level == 5{ //level : 5
            levelAnimationView = AnimationView(name: "level_05_lottie")
            bottomWaveWrap.isHidden = false
            bottomGLWrap.isHidden = false
            bottomBottleWrap.isHidden = true
            
            
            
            waveAnimationView.frame = CGRect(x: 0, y: 0, width: bottomWaveWrap.frame.width, height: 220.0)
            
            waveAnimationView.contentMode = .scaleAspectFill //애니메이션 뷰의 콘텐츠 모드 설정 (꽉차게 할 것이냐 등등...)
            waveAnimationView.loopMode = .loop
            
            bottomWaveWrap.addSubview(waveAnimationView) //애니메이션뷰를 메인뷰에 추가시킨다.
            
            waveAnimationView.play() //애니메이션 뷰의 실행
        }
        var minusWidth:CGFloat = 60.0
        var width = (view.frame.width - minusWidth)
        
        var lottieRatioHeight = (403/328.0) * width
        
        if level == 5 {
            minusWidth += 24.0
            width -= 24.0
            lottieRatioHeight = (430.0/328.0) * width
            
            
            let full01Ratio = (18/170.67) * bottomWaveWrap.frame.height //폰트 비율 01,03 같음
            let full02Ratio = (24/170.67) * bottomBottleWrap.frame.height //폰트 비율
            
            let topAnchorRatio01 = (57.0/170.67) * bottomWaveWrap.frame.height //constraint 비율
            let topAnchorRatio02 = (9.0/170.67) * bottomWaveWrap.frame.height //constraint 비율
            let topAnchorRatio03 = (7.0/170.67) * bottomWaveWrap.frame.height //constraint 비율
            
            levelFullGL01.topAnchor.constraint(equalTo: bottomBottleWrap.topAnchor, constant: topAnchorRatio01).isActive = true
            levelFullGL02.topAnchor.constraint(equalTo: levelFullGL01.bottomAnchor, constant: topAnchorRatio02).isActive = true
            levelFullGL03.topAnchor.constraint(equalTo: levelFullGL02.bottomAnchor, constant: topAnchorRatio03).isActive = true
            
            levelFullGL01.font = UIFont(name: "AppleSDGothicNeo-Medium", size: full01Ratio) ?? UIFont.boldSystemFont(ofSize: full01Ratio)
            levelFullGL02.font = UIFont(name: "AppleSDGothicNeo-Bold", size: full02Ratio) ?? UIFont.boldSystemFont(ofSize: full02Ratio)
            levelFullGL03.font = UIFont(name: "AppleSDGothicNeo-Medium", size: full01Ratio) ?? UIFont.boldSystemFont(ofSize: full01Ratio)
            
            levelFullGL02.text = String(level5Rank) + "번째 선주(酒)자가"
            levelFullGL02.shadow(opacity: 0.16, radius: 2, offset: CGSize(width: 0, height: 3),color: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1).cgColor)
        }
        
        let alcoholLevelWrapHeight = (494.33/812.0) * view.frame.height
        //375.0 , 812.0
        //375.0 , 494.33
        let levelWrap = UIView.init(frame: CGRect(x: (minusWidth/2), y: ((alcoholLevelWrapHeight - lottieRatioHeight)/2), width: width, height: lottieRatioHeight))
        
        levelAnimationView.frame = CGRect(x: 0, y: 0, width: levelWrap.frame.width, height: levelWrap.frame.height) //애니메이션뷰의 크기설정
        levelAnimationView.contentMode = .scaleAspectFill //애니메이션 뷰의 콘텐츠 모드 설정 (꽉차게 할 것이냐 등등...)
        levelAnimationView.loopMode = .loop
        levelWrap.addSubview(levelAnimationView)
        alcoholLevelWrap.addSubview(levelWrap)
        levelAnimationView.play() //애니메이션 뷰의 실행
    }
}

extension MyAlcoholLevelVC {
    func uiInit() {
        loginWrap.layer.cornerRadius = 21.0
        loginWrap.shadow(opacity: 0.16, radius: 3, offset: CGSize(width: 0, height: 1), color: nil)
        logoutWrap.layer.cornerRadius = 21.0
        logoutWrap.shadow(opacity: 0.16, radius: 3, offset: CGSize(width: 0, height: 1), color: nil)
    }
}
