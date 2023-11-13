//
//  ReviewDetailVC.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/16.
//

import UIKit
import SideMenu
import ReactorKit
import RxSwift
import RxCocoa
import SwiftyTimer
import MGStarRatingView
//webp이미지 로드하기위한 플러그인
import Nuke
import NukeWebPPlugin


//리뷰 작성 화면 UI를 컨트롤 하기위한 파일
class ReviewWriteVC: BaseViewController, StoryboardView, StarRatingDelegate, UITextViewDelegate {
    func StarRatingValueChanged(view: StarRatingView, value: CGFloat) {}
    
    @IBOutlet weak var backgroundWrap: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var starView: StarRatingView!
    
    @IBOutlet weak var contentsWriteBtnWrap: UIView!
    
    @IBOutlet weak var tasteBtnWrap: UIView!
    
    let reviewDetailRT = ReviewDetailRT()
    
    @IBOutlet weak var aromaGuideWrap: UIView!
    @IBOutlet weak var mourhFeelGuideWrap: UIView!
    @IBOutlet weak var tasteGuideWrap: UIView!
    @IBOutlet weak var appearanceGuideWrap: UIView!
    @IBOutlet weak var overallGuideWrap: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var reviewIsEmptyGL: UILabel!
    @IBOutlet weak var reviewContentsTV: UITextView!
    @IBOutlet weak var reviewContentsCnt: UILabel!
    @IBOutlet weak var leftAlcoholImageWrap: UIView!
    @IBOutlet weak var leftAlcoholImage: UIImageView!
    
    @IBOutlet weak var aromaSlider: ReviewWriteCustomSlider!
    @IBOutlet weak var mouthFeelSlider: ReviewWriteCustomSlider!
    @IBOutlet weak var tasteSlider: ReviewWriteCustomSlider!
    @IBOutlet weak var appearanceSlider: ReviewWriteCustomSlider!
    @IBOutlet weak var overallSlider: ReviewWriteCustomSlider!
    
    @IBOutlet weak var contentsWrap: UIView!
    
    @IBOutlet weak var centerAlcoholImageWrap: UIView!
    @IBOutlet weak var centerAlcoholImage: UIImageView!
    
    @IBOutlet weak var dynamicAlcoholImage: UIImageView!
    @IBOutlet weak var aromaSliderValue: UILabel!
    @IBOutlet weak var mouthFeelSliderValue: UILabel!
    @IBOutlet weak var tasteSliderValue: UILabel!
    @IBOutlet weak var appearanceSliderValue: UILabel!
    @IBOutlet weak var overallSliderValue: UILabel!
    
    @IBOutlet weak var scoreGL: UILabel!
    @IBOutlet weak var writeConfirmBtn: UIButton!
    
    var score = BehaviorRelay<Float>.init(value: 0.0)
    var writeValidationFlag = BehaviorRelay<Bool>.init(value: false)
    
    @IBOutlet weak var alcoholNameGL: UILabel!
    
    @IBOutlet weak var breweryGL: UILabel!
    
    var alcoholId:String = String()
    var reviewId:String = String()
    
    var aromaSliderFlag:Bool = false
    var mouthFeelSliderFlag:Bool = false
    var tasteSliderFlag:Bool = false
    var appearanceSliderFlag:Bool = false
    var overallSliderFlag:Bool = false
    
    var beforeBackgroundImage:UIImage = UIImage()
    var beforeAlcoholImage:UIImage = UIImage()
    
    //리뷰 신규, 수정여부
    //true : 수정, false : 신규
    var reviewUpdateFlag:Bool = false
    
    var alcoholName:String = String()
    var brewery:String = String()
    var reviewDetail:ReviewList?
    @IBOutlet weak var alcoholCommentWrap: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let review = reviewDetail {
            let alcoholName:String = review.alcohol?.name ?? ""
            let brewery:String = review.alcohol?.brewery?[0].name ?? ""
            let alcoholId:String = review.alcohol?.alcoholId ?? ""
            let reviewId:String = review.reviewId ?? ""
            let backgroundImageUrl:String = review.alcohol?.backgroundMedia?[0].mediaResource?.large?.src ?? ""
            let alcoholImageUrl:String = review.alcohol?.media?[0].mediaResource?.medium?.src ?? ""
            
            alcoholNameGL.text = alcoholName
            breweryGL.text = brewery
            self.alcoholId = alcoholId
            self.reviewId = reviewId
            
            alcoholImageSetting(urlString: alcoholImageUrl)
            backgroundImageSetting(urlString: backgroundImageUrl)
        }else {
            backgroundImage.image = beforeBackgroundImage
            leftAlcoholImage.image = beforeAlcoholImage
            centerAlcoholImage.image = beforeAlcoholImage
            dynamicAlcoholImage.image = beforeAlcoholImage
        }
        
        reactor = reviewDetailRT

      
        
        dynamicAlcoholImage.frame = CGRect(x:centerAlcoholImageWrap.frame.origin.x, y: centerAlcoholImageWrap.frame.origin.y + 40, width: centerAlcoholImage.frame.width, height: centerAlcoholImage.frame.height)

        contentsWrap.shadow(opacity: 0.16, radius: 6, offset: CGSize(width: 0, height: 3), color: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1).cgColor)
        contentsWrap.layer.cornerRadius = 7.0
        contentsWrap.borderAll(width: 0.5, color: UIColor(red: 199/255, green: 199/255, blue:199/255, alpha: 1).cgColor)

        contentsWriteBtnWrap.shadow(opacity: 0.16, radius: 2, offset: CGSize(width: 0, height: 2), color: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1).cgColor)
        contentsWriteBtnWrap.layer.cornerRadius = 4.0
        tasteBtnWrap.shadow(opacity: 0.16, radius: 2, offset: CGSize(width: 0, height: 2), color: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1).cgColor)
        tasteBtnWrap.layer.cornerRadius = 4.0

        writeConfirmBtn.shadow(opacity: 0.16, radius: 2, offset: CGSize(width: 0, height: 2), color: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1).cgColor)
        writeConfirmBtn.layer.cornerRadius = 4.0
        
        let sliderShadowModel:ShadowModel = ShadowModel(opacity: 0.15, radius: 2, offset: CGSize(width: 2, height: 2), color: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1).cgColor)
        
        aromaSlider.shadow(shadowModel: sliderShadowModel)
        mouthFeelSlider.shadow(shadowModel: sliderShadowModel)
        tasteSlider.shadow(shadowModel: sliderShadowModel)
        appearanceSlider.shadow(shadowModel: sliderShadowModel)
        overallSlider.shadow(shadowModel: sliderShadowModel)
        
        
        reviewContentsTV.delegate = self
        reviewContentsTV.textContainerInset = UIEdgeInsets(top: 15, left: 8, bottom: 8, right: 8)
        
        let attribute = StarRatingAttribute(type: .rate,
                                            point: 36,
                                            spacing: 4,
                                            emptyColor: .red,
                                            fillColor: .blue,
                                            emptyImage: UIImage(named: "ratingEmpty"),
                                            fillImage: UIImage(named: "ratingFullstar"))
        starView.configure(attribute, current: 0, max: 5)
        
        starView.delegate = self
        starView.current = 0.0
        
        alcoholNameGL.text = alcoholName
        breweryGL.text = brewery
        
       
        
        backBtn?.topAnchor.constraint(equalTo: backgroundWrap.topAnchor,constant:getStatusBarHeight() ).isActive = true
        
        if reviewUpdateFlag {
            //스와이프 해서 뒤로가기 허용
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }else {
            //스와이프 해서 뒤로가기 허용
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
    }

    func getStatusBarHeight() -> CGFloat {
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        return statusBarHeight
    }
    
    @IBAction func tasteQuestionBtn(_ sender: UIButton) {
        let tag = sender.tag
        switch tag {
        case 0:
            aromaGuideWrap.isHidden = !aromaGuideWrap.isHidden
            break
        case 1:
            mourhFeelGuideWrap.isHidden = !mourhFeelGuideWrap.isHidden
            break
        case 2:
            tasteGuideWrap.isHidden = !tasteGuideWrap.isHidden
            break
        case 3:
            appearanceGuideWrap.isHidden = !appearanceGuideWrap.isHidden
            break
        case 4:
            overallGuideWrap.isHidden = !overallGuideWrap.isHidden
            break
        default:
            break
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
//        dch_checkDeallocation()//메모리 누수 체크
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //입력 텍스트 밖 영역 클릭시 키보드 내려가도록 해주는 함수
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        aromaSliderValue.center = setUISliderThumbValueWithLabel(slider: aromaSlider)
        aromaSlider.setThumbImage(progressImage(with: aromaSlider.value), for: .normal)
        mouthFeelSliderValue.center = setUISliderThumbValueWithLabel(slider: mouthFeelSlider)
        mouthFeelSlider.setThumbImage(progressImage(with: mouthFeelSlider.value), for: .normal)
        tasteSliderValue.center = setUISliderThumbValueWithLabel(slider: tasteSlider)
        tasteSlider.setThumbImage(progressImage(with: tasteSlider.value), for: .normal)
        appearanceSliderValue.center = setUISliderThumbValueWithLabel(slider: appearanceSlider)
        appearanceSlider.setThumbImage(progressImage(with: appearanceSlider.value), for: .normal)
        overallSliderValue.center = setUISliderThumbValueWithLabel(slider: overallSlider)
        overallSlider.setThumbImage(progressImage(with: overallSlider.value), for: .normal)
        
        if !reviewUpdateFlag {
            leftAlcoholImageWrap.isHidden = true
            dynamicAlcoholImage.isHidden = false
            
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.dynamicAlcoholImage.frame = CGRect(x: self?.leftAlcoholImageWrap.frame.origin.x ?? 0.0, y: self?.leftAlcoholImageWrap.frame.origin.y ?? 0.0 + 30 , width: self?.leftAlcoholImage.frame.width ?? 0.0, height: self?.leftAlcoholImage.frame.height ?? 0.0)
            }
        }
    }
    
    //개행방지
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let x = round(sender.value * 10) / 10 //소수점 둘째 자리에서 반올림
        let tag = sender.tag
        let aromaScore:Float = aromaSlider.value
        let mouthFeelScore:Float = mouthFeelSlider.value
        let tasteScore:Float = tasteSlider.value
        let appearanceScore:Float = appearanceSlider.value
        let overallScore:Float = overallSlider.value
        
        switch tag {
        case 0:
            if x > 0.0 {
                aromaSliderFlag = true
            }else {
                aromaSliderFlag = false
            }
            aromaSliderValue.text = "\(x)"
            aromaSliderValue.center = setUISliderThumbValueWithLabel(slider: sender)
            let allScore:Float = mouthFeelScore + tasteScore + appearanceScore + overallScore + x
            score.accept(round(allScore * 10) / 10)
            break
        case 1:
            if x > 0.0 {
                mouthFeelSliderFlag = true
            }else {
                mouthFeelSliderFlag = false
            }
            mouthFeelSliderValue.text = "\(x)"
            mouthFeelSliderValue.center = setUISliderThumbValueWithLabel(slider: sender)
            let allScore:Float = aromaScore + tasteScore + appearanceScore + overallScore + x
            score.accept(round(allScore * 10) / 10)
            break
        case 2:
            if x > 0.0 {
                tasteSliderFlag = true
            }else {
                tasteSliderFlag = false
            }
            tasteSliderValue.text = "\(x)"
            tasteSliderValue.center = setUISliderThumbValueWithLabel(slider: sender)
            let allScore:Float = aromaScore + mouthFeelScore + appearanceScore + overallScore + x
            score.accept(round(allScore * 10) / 10)
            break
        case 3:
            if x > 0.0 {
                appearanceSliderFlag = true
            }else {
                appearanceSliderFlag = false
            }
            appearanceSliderValue.text = "\(x)"
            appearanceSliderValue.center = setUISliderThumbValueWithLabel(slider: sender)
            let allScore:Float = aromaScore + mouthFeelScore + tasteScore + overallScore + x
            score.accept(round(allScore * 10) / 10)
            break
        case 4:
            if x > 0.0 {
                overallSliderFlag = true
            }else {
                overallSliderFlag = false
            }
            overallSliderValue.text = "\(x)"
            overallSliderValue.center = setUISliderThumbValueWithLabel(slider: sender)
            let allScore:Float = aromaScore + mouthFeelScore + tasteScore + appearanceScore + x
            score.accept(round(allScore * 10) / 10)
        default:
            break
        }
        
        if aromaSliderFlag && mouthFeelSliderFlag && tasteSliderFlag && appearanceSliderFlag && overallSliderFlag {
            if reviewContentsTV.text.count > 0 {
                writeValidationFlag.accept(true)
            }else {
                writeValidationFlag.accept(false)
            }
        }else {
            writeValidationFlag.accept(false)
        }
    }

    func setUISliderThumbValueWithLabel(slider: UISlider) -> CGPoint {
        let slidertTrack : CGRect = slider.trackRect(forBounds: slider.bounds)
        let sliderFrm : CGRect = slider .thumbRect(forBounds: slider.bounds, trackRect: slidertTrack, value: slider.value)
        return CGPoint(x: sliderFrm.origin.x + slider.frame.origin.x + 14.5, y: slider.frame.origin.y + 10.0 )
    }
    
    func bind(reactor: ReviewDetailRT) {
        
        
        /* UIEvent */
        
        //뒤로가기 버튼
        backBtn.rx.tap.bind{[weak self] _ in self?.backEvent()}.disposed(by: disposeBag)
        //리뷰 작성 버튼
        writeConfirmBtn.rx.tap.bind { [weak self] _ in self?.reviewUpload() }.disposed(by: disposeBag)
        
        //리뷰 작성에 따른 PlaceHolder 숨김여부
        reviewContentsTV.rx.text.orEmpty
            .map{ data -> Bool in
                if data.count > 0 {
                    return true
                }else {
                    return false
                }
            }.bind(to: reviewIsEmptyGL.rx.isHidden)
            .disposed(by: disposeBag)
        
        reviewContentsTV.rx.text.orEmpty
            .distinctUntilChanged()
            .map{$0.count}
            .bind{[weak self] result in
                //리뷰 500글자 이상은 자르기
                if result > 500 {
                    let contents = self?.reviewContentsTV.text ?? ""
                    let firstIndex = contents.index(contents.startIndex, offsetBy: 0)
                    let lastIndex = contents.index(contents.startIndex, offsetBy: 500)
                    self?.reviewContentsTV.text = "\(contents[firstIndex..<lastIndex])"
                }else {
                    self?.reviewContentsCnt.text = String(result) + "/500"
                }
                
            }.disposed(by: disposeBag)
        
        reviewContentsTV.rx.text.orEmpty
            .bind{[weak self] result in
                let alcoholCommentWrapHeight:CGFloat = 405.0
                let defaultHeight:CGFloat = 195.0
                let contentsHeight:CGFloat = result.heightOfString(width: (self?.reviewContentsTV.frame.width ?? 375.0) - 25.3, font: UIFont(name: "AppleSDGothicNeo-Medium", size: 15.0) ?? UIFont.boldSystemFont(ofSize: 15.0), lineSpacing: 3.0)
                
                // 넓이 구하기
                if defaultHeight + contentsHeight > alcoholCommentWrapHeight {
                    self?.alcoholCommentWrap.constraints.forEach { (constraint) in // ---- 3
                        if constraint.firstAttribute == .height {
                            constraint.constant = ((173.0) + contentsHeight)
                        }
                    }
                }else {
                    self?.alcoholCommentWrap.constraints.forEach { (constraint) in // ---- 3
                        if constraint.firstAttribute == .height {
                            constraint.constant = alcoholCommentWrapHeight
                        }
                    }
                }
            }.disposed(by: disposeBag)
    
        
        writeValidationFlag.asDriver()
            .drive(onNext:{ [weak self] flag in
                if flag {
                    self?.writeConfirmBtn.backgroundColor = UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1)
                }else {
                    self?.writeConfirmBtn.backgroundColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1)
                }
            }).disposed(by: disposeBag)
        
        score.asDriver()
            .drive(onNext: { [weak self] result in
                self?.scoreGL.text = String(result) + "/25"
                let averageScore = result/5.0
                self?.starView.current = CGFloat(round(averageScore * 10) / 10)
            })
            .disposed(by: disposeBag)
        
        /* */
        
        
        /* Action */
        
        if(isInternetAvailable)(){
            log.info("Network Connected")
        } else {
            netWorkStateToast(errorIndex: 0)
            log.info("Network DisConnected")
            return
        }
        
        if reviewUpdateFlag { //리뷰 수정시에만 동작
            let params = [
                "alcoholId" : alcoholId,
                "reviewId" : reviewId
            ]
            reactor.action.onNext(.reviewDetail(params))
        }
        
        /* State */
        
        let isReviewDetail = reactor.state.map{$0.isReviewDetail}.filter{$0 != nil}
        let isReviewWrite = reactor.state.map{$0.isReviewWrite}.filter{$0 != nil}.map{$0 ?? false}
        let isReviewUpdate = reactor.state.map{$0.isReviewUpdate}.filter{$0 != nil}.map{$0 ?? false}
        let isIndicator = reactor.state.map{$0.isIndicator}.filter{$0 != nil}.map{$0 ?? false}
        
        isIndicator.bind{[weak self] result in self?.loadingIndicator(flag: result)}.disposed(by: disposeBag)
        
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
        
        /* Review data Bind - Start */
        
        isReviewWrite.bind{[weak self] result in
            if result {
                self?.backEvent()
            }
        }.disposed(by: disposeBag)
        
        isReviewUpdate.bind{[weak self] result in
            if result {
                self?.backEvent()
            }
        }.disposed(by: disposeBag)
        
        isReviewDetail.map{$0?.contents}
            .bind(to: reviewContentsTV.rx.text).disposed(by: disposeBag)
        
        isReviewDetail.map{$0?.score ?? 0.0}
            .subscribe(onNext:{ [weak self] score in self?.score.accept(score) }).disposed(by: disposeBag)
        
        isReviewDetail.map{(String($0?.contents.count ?? 0) + "/500")}
            .bind(to: reviewContentsCnt.rx.text).disposed(by: disposeBag)
        
        isReviewDetail.map{$0?.contents}
            .bind(to: reviewContentsTV.rx.text).disposed(by: disposeBag)
        
        isReviewDetail.map{$0?.aroma ?? 0.0}
            .bind(to: aromaSlider.rx.value).disposed(by: disposeBag)
        isReviewDetail.map{String($0?.aroma ?? 0.0)}
            .bind(to: aromaSliderValue.rx.text).disposed(by: disposeBag)
        
        isReviewDetail.map{$0?.mouthFeel ?? 0.0}
            .bind(to: mouthFeelSlider.rx.value).disposed(by: disposeBag)
        isReviewDetail.map{String($0?.mouthFeel ?? 0.0)}
            .bind(to: mouthFeelSliderValue.rx.text).disposed(by: disposeBag)
        
        isReviewDetail.map{$0?.taste ?? 0.0}
            .bind(to: tasteSlider.rx.value).disposed(by: disposeBag)
        isReviewDetail.map{String($0?.taste ?? 0.0)}
            .bind(to: tasteSliderValue.rx.text).disposed(by: disposeBag)
        
        isReviewDetail.map{$0?.appearance ?? 0.0}
            .bind(to: appearanceSlider.rx.value).disposed(by: disposeBag)
        isReviewDetail.map{String($0?.appearance ?? 0.0)}
            .bind(to: appearanceSliderValue.rx.text).disposed(by: disposeBag)
        
        isReviewDetail.map{$0?.overall ?? 0.0}
            .bind(to: overallSlider.rx.value).disposed(by: disposeBag)
        isReviewDetail.map{String($0?.overall ?? 0.0)}
            .bind(to: overallSliderValue.rx.text).disposed(by: disposeBag)
        
        isReviewDetail.subscribe(onNext:{ [weak self] _ in
            self?.reviewDetailSliderInit()
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
            .filter{$0 != nil}
            .subscribe(onNext:{ result in
                reactor.action.onNext(.accessTokenSave(result))
            }).disposed(by: disposeBag)
        
        //토큰 갱신 후 -> 내장 저장 -> 기존에 실행하려 했던 이벤트 실행
        
        //토큰 갱신 후 -> 내장 저장 -> 기존에 실행하려 했던 이벤트 실행
        reactor.state.map{$0.isAccessTokenSave}
            .observeOn(MainScheduler.asyncInstance)
            .filter{$0 != nil}
            .subscribe(onNext: { result in
                if result?.saveFlag ?? false {
                    if result?.eventIndex == 0 { //리뷰 단건 조회
                        reactor.action.onNext(.reviewDetail(result?.params))
                    }else if result?.eventIndex == 1 { //리뷰 작성
                        reactor.action.onNext(.reviewWrite(result?.writeParams, result?.pathParams))
                    }else if result?.eventIndex == 2 { //리뷰 수정
                        reactor.action.onNext(.reviewUpdate(result?.writeParams, result?.pathParams))
                    }
                }
            }).disposed(by: disposeBag)
        /* */
    }
    
    //리뷰 작성 및 수정 이벤트
    func reviewUpload() {
        
        if(isInternetAvailable)(){
            log.info("Network Connected")
        } else {
            netWorkStateToast(errorIndex: 0)
            log.info("Network DisConnected")
            return
        }
        
        if let reactor = reactor {
            var pathParams = [
                "alcoholId": alcoholId
            ]
            
            let params = ReviewWriteRQModel(contents: reviewContentsTV.text!, aroma: Double(aromaSliderValue.text!) ?? 0.0, mouthfeel: Double(mouthFeelSliderValue.text!) ?? 0.0, taste: Double(tasteSliderValue.text!) ?? 0.0, appearance: Double(appearanceSliderValue.text!) ?? 0.0, overall: Double(overallSliderValue.text!) ?? 0.0)

            if reviewUpdateFlag {
                //업데이트 의 경우 reviewId 까지 필요함
                pathParams["reviewId"] = reviewId
                reactor.action.onNext(.reviewUpdate(params, pathParams))
            }else {
                reactor.action.onNext(.reviewWrite(params, pathParams))
            }
        }
    }
    
    //slider Init
    func reviewDetailSliderInit() {
        sliderValueChanged(aromaSlider)
        sliderValueChanged(mouthFeelSlider)
        sliderValueChanged(tasteSlider)
        sliderValueChanged(appearanceSlider)
        sliderValueChanged(overallSlider)
    }
    
    //뒤로가기
    func backEvent() {
        leftAlcoholImageWrap.isHidden = true
        dynamicAlcoholImage.isHidden = false
        
        if reviewUpdateFlag {
            navigationController?.popViewController(animated: true)
        }else {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.dynamicAlcoholImage.frame = CGRect(x:self?.centerAlcoholImageWrap.frame.origin.x ?? 0.0, y: self?.centerAlcoholImageWrap.frame.origin.y ?? 0.0 + 40, width: self?.centerAlcoholImage.frame.width ?? 0.0, height: self?.centerAlcoholImage.frame.height ?? 0.0)
                
            }
            
            if let pvc = presentingViewController as? UINavigationController {
                let lastView = pvc.viewControllers[pvc.viewControllers.count-1] //해당 화면을 호출 한 화면 (제일 마지막 stack view)
                
                if let alcoholDetailVC:AlcoholDetailVC = lastView as? AlcoholDetailVC {
                    alcoholDetailVC.imageInit()
                    //주류 작성 후 AlcoholDetail 리뷰 호출하여 재정리
                    let pathParams = [
                        "alcoholId": alcoholId
                    ]
                    alcoholDetailVC.reactor?.action.onNext(.alcoholReview(pathParams, nil))
                }
            }
            
            
            let timer = Timer.new(every: 0.18.second) {}
            timer.start(modes: .tracking)
            Timer.every(0.18.second) { [weak self] (timer: Timer) in
                timer.invalidate()
                self?.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    func progressImage(with progress : Float) -> UIImage {
        let layer = CALayer()
        
        layer.backgroundColor = UIColor.green.cgColor
        layer.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        layer.cornerRadius = 9
        let image = UIImage(named: "sliderCircle")
        let label = UILabel(frame: layer.frame)
        label.text = "\(progress)"
        layer.addSublayer(label.layer)
        
        label.textAlignment = .center
        label.tag = 100
        
        UIGraphicsBeginImageContext(layer.frame.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    //주류 이미지 세팅
    func alcoholImageSetting(urlString: String) {
        if urlString.count > 0 {
            let webpimageURL = URL(string: urlString)!
            Nuke.loadImage(with: webpimageURL, into: leftAlcoholImage)
            WebPImageDecoder.enable()
        }
    }
    
    //주류 배경이미지 세팅
    func backgroundImageSetting(urlString: String) {
        if urlString.count > 0 {
            let webpimageURL = URL(string: urlString)!
            Nuke.loadImage(with: webpimageURL, into: backgroundImage)
            WebPImageDecoder.enable()
        }
    }
}

