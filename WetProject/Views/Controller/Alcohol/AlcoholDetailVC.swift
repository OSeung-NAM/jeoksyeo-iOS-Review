//
//  AlcoholDetailVC.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/10.
//

import UIKit
import RxCocoa
import RxSwift
import ReactorKit
import SwiftyTimer
import MGStarRatingView
//webp이미지 로드하기위한 플러그인
import Nuke
import NukeWebPPlugin
import RadarChart

//주류 상세 화면 UI를 컨트롤 하기위한 파일
class AlcoholDetailVC:BaseViewController, StoryboardView, StarRatingDelegate {
    func StarRatingValueChanged(view: StarRatingView, value: CGFloat) {}
    
    @IBOutlet weak var backgroundWrap: UIView!
    
    /* Reactor Kit */
    let alcoholDetailRT = AlcoholDetailRT()
    
    var eventIndex:Int = 0
    //이벤트 처리 observable : <토큰 상태, 호출 이벤트>
    var eventExecution:BehaviorRelay<Int?> = BehaviorRelay.init(value: nil)
    
    /* 주류 좋아요, 싫어요 Observable용 변수 */
    var reviewLikeInfo:BehaviorRelay = BehaviorRelay<(String,Bool)>.init(value: (String(),Bool()))
    var reviewDisLikeInfo:BehaviorRelay = BehaviorRelay<(String,Bool)>.init(value: (String(),Bool()))
    
    /* 화면 공통사용 변수 */
    var alcoholId:String = String()
    var reviewList:[ReviewList]?
    var alcoholLikeFlag:Bool = false
    var alcoholLikeCnt:Int = 0
    var alcoholDetail:AlcoholDetail?
    
    /* 공통 UIKit */
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    /* 주류 정보 */
    @IBOutlet weak var alcoholNameGL: UILabel!
    @IBOutlet weak var alcoholImage: UIImageView!
    @IBOutlet weak var breweryGL: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var likeCntGL: UILabel!
    @IBOutlet weak var reviewCntGL: UILabel!
    @IBOutlet weak var viewCntGL: UILabel!
    @IBOutlet weak var alcoholCategoryGL: UILabel!
    @IBOutlet weak var reviewScoreGL: UILabel!
    @IBOutlet weak var thermometerGL: UILabel!
    @IBOutlet weak var alcoholDescriptionWrap: UIView!
    @IBOutlet weak var alcoholDescriptionGL: UITextView!
    @IBOutlet weak var alcoholLikeWrap: UIView!
    @IBOutlet weak var alcoholReviewWrap: UIView!
    @IBOutlet weak var alcoholInfoMoreWrap: UIView!
    @IBOutlet weak var alcoholInfoMoreImage: UIImageView!
    @IBOutlet weak var alcoholInfoMoreGL: UILabel!
    @IBOutlet weak var alcoholInfoWrap: UIView!
    @IBOutlet weak var moreExpandWrap: UIView!
    @IBOutlet weak var moreImage: UIImageView!
    @IBOutlet weak var moreGL: UILabel!
    var descriptionExpandFlag:Bool = false
    
    /* 사용자 지표 */
    @IBOutlet weak var userGraphView: RadarChartView!
    @IBOutlet weak var userAssessmentWrap: UIView!
    @IBOutlet weak var userGraphIsEmptyWrap: UIView!
    /* 주류 리뷰 */
    
    @IBOutlet weak var reviewBtn: UIButton!
    @IBOutlet weak var starView: StarRatingView!
    @IBOutlet weak var scoreAvgGL: UILabel!
    
    @IBOutlet weak var score5CntGL: UILabel!
    @IBOutlet weak var score4CntGL: UILabel!
    @IBOutlet weak var score3CntGL: UILabel!
    @IBOutlet weak var score2CntGL: UILabel!
    @IBOutlet weak var score1CntGL: UILabel!
    
    @IBOutlet weak var score5GaugeBarWrap: UIView!
    @IBOutlet weak var score5GaugeBar: UIView!
    @IBOutlet weak var score4GaugeBarWrap: UIView!
    @IBOutlet weak var score4GaugeBar: UIView!
    @IBOutlet weak var score3GaugeBarWrap: UIView!
    @IBOutlet weak var score3GaugeBar: UIView!
    @IBOutlet weak var score2GaugeBarWrap: UIView!
    @IBOutlet weak var score2GaugeBar: UIView!
    @IBOutlet weak var score1GaugeBarWrap: UIView!
    @IBOutlet weak var score1GaugeBar: UIView!
    
    @IBOutlet weak var reviewMoreWrap: UIView!
    @IBOutlet weak var reviewMoreBtn: UIButton!
    @IBOutlet weak var reviewListWrap: UIView!
    @IBOutlet weak var reviewIsEmptyWrap: UIView!
    
    var callingView:Any?
    
    override func viewDidLoad() {
        tabBarController?.tabBar.isHidden = true
        reactor = alcoholDetailRT
        uiInit()
        backBtn?.topAnchor.constraint(equalTo: backgroundWrap.topAnchor,constant:getStatusBarHeight()).isActive = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //스와이프 해서 뒤로가기 허용
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        /* Action */
        
        if(isInternetAvailable)(){
            log.info("Network Connected")
        } else {
            netWorkStateToast(errorIndex: 0)
            log.info("Network DisConnected")
            return
        }
        
        let pathParams = [
            "alcoholId": alcoholId
        ]
        
        if let reactor = reactor {
            reactor.action.onNext(.alcoholReview(pathParams, nil))
        }
    }
    
    func bind(reactor: AlcoholDetailRT){
        let pathParams = [
            "alcoholId": alcoholId
        ]
        
        /* UIEvent */
        
        backBtn.rx.tap.bind{[weak self] _ in self?.backEvent()}.disposed(by: disposeBag)
        
        reviewBtn.rx.tap.bind{ [weak self] _ in
            if(self?.isInternetAvailable() ?? false){
                log.info("Network Connected")
            } else {
                self?.netWorkStateToast(errorIndex: 0)
                log.info("Network DisConnected")
                return
            }
            reactor.action.onNext(.reviewCreated(pathParams))
        }.disposed(by: disposeBag)
        
        alcoholLikeWrap.rx.tapGesture().when(.recognized)
            .bind{ [weak self] _ in
                let isLiked:Bool = self?.alcoholDetail?.isLiked ?? false
                let pathParams = [
                    "alcoholId":self?.alcoholId ?? ""
                ]
                
                if(self?.isInternetAvailable() ?? false){
                    print("네트워크 연결 됨")
                } else {
                    self?.netWorkStateToast(errorIndex: 0)
                    print("네트워크 연결 안됨")
                    return
                }
                
                if isLiked {
                    reactor.action.onNext(.alcoholLikeOff(self?.alcoholDetail, pathParams))
                }else {
                    reactor.action.onNext(.alcoholLikeOn(self?.alcoholDetail, pathParams))
                }
                
            }.disposed(by: disposeBag)
        
        moreExpandWrap.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext:{ [weak self] _ in
                self?.descriptionExpand()
            })
            .disposed(by: disposeBag)
        
        alcoholReviewWrap?.rx.tapGesture()
            .when(.recognized)
            .bind{[weak self] _ in
                self?.scrollView?.scrollToBottom()
            }.disposed(by: disposeBag)
        
        reviewMoreBtn?.rx.tap
            .bind{[weak self] _ in
                if(self?.isInternetAvailable() ?? false){
                    print("네트워크 연결 됨")
                } else {
                    self?.netWorkStateToast(errorIndex: 0)
                    print("네트워크 연결 안됨")
                    return
                }
                self?.reviewListMove()
            }.disposed(by: disposeBag)
            
        
        /* */
       
        
        reactor.action.onNext(.alcoholDetail(pathParams))
        
        
        /* */
        
        /* State */
        
        let isAlcoholDetail = reactor.state.map{$0.isAlcoholDetail}.filter{$0 != nil}
        let isAlcoholUserAssessment = reactor.state.map{$0.isAlcoholReview}.filter{$0.0 != nil}.map{$0.0}
        let isAlcoholReviewInfo = reactor.state.map{$0.isAlcoholReview}.filter{$0.1 != nil}.map{$0.1}
        let isAlcoholReviewList = reactor.state.map{$0.isAlcoholReview}.filter{$0.2 != nil}.map{$0.2}
        let isReviewCreated = reactor.state.map{$0.isReviewCreated}.filter{$0 != nil}
        
        let isIndicator = reactor.state.map{$0.isIndicator}.filter{$0 != nil}.map{$0 ?? false}
        let isReviewListRenewal = reactor.state.map{$0.isReviewListRenewal}.filter{$0 != nil}
        
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
                
                if result.1 == 2 { //중복 좋아요 에러
                    self?.netWorkStateToast(errorIndex: 3)
                }else if result.1 == 4 { //중복 리뷰 좋아요 에러
                    self?.netWorkStateToast(errorIndex: 4)
                }else if result.1 == 6 { //중복 리뷰 싫어요 에러
                    self?.netWorkStateToast(errorIndex: 5)
                }else{
                    self?.netWorkStateToast(errorIndex: 1)
                }
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
                if result.1?.eventIndex == 0 { //주류 상세조회는 로그인이 필요없어서 로그아웃 시켜버리고 다시 조회 진입
                    reactor.action.onNext(.alcoholDetail(result.1?.pathParams))
                }else if result.1?.eventIndex == 1 { //주류 리스트는 로그인이 필요없어 로그아웃 시켜 버리고 다시 조회 진입
                    reactor.action.onNext(.alcoholReview(result.1?.pathParams, nil))
                }
            }
        }.disposed(by: disposeBag)
        
        /* AlcoholInfo data Bind - Start */
        
        isAlcoholDetail.bind{[weak self] result in self?.alcoholSetting(alcoholDetail: result)}.disposed(by: disposeBag)
        isAlcoholDetail.bind{[weak self] result in self?.alcoholInfoSetting(alcoholDetail: result)}.disposed(by: disposeBag)
        isAlcoholDetail.bind{[weak self] result in self?.alcoholDetail = result}.disposed(by: disposeBag)
        
        /* End */
        
        /* UserAssessment data Bind - Start */
        
        isAlcoholUserAssessment.bind{ [weak self] result in self?.userGraphSetting(userAssessment: result)}.disposed(by: disposeBag)
        
        /* UserAssessment */
        
        /* ReviewInfo data Bind - Start */
 
        isAlcoholReviewInfo.map{$0?.reviewTotalCount ?? 0}
            .bind{[weak self] result in
                if result > 9999 {
                    self?.reviewCntGL.text = "9999+"
                }else {
                    self?.reviewCntGL.text = String(result)
                }
            }
            .disposed(by: disposeBag)
        
        isAlcoholReviewInfo.map{String($0?.scoreAvg ?? 0.0)}.bind(to: reviewScoreGL.rx.text).disposed(by: disposeBag)
        isAlcoholReviewInfo.map{String($0?.score1Count ?? 0)}.bind(to: score1CntGL.rx.text).disposed(by: disposeBag)
        isAlcoholReviewInfo.map{String($0?.score2Count ?? 0)}.bind(to: score2CntGL.rx.text).disposed(by: disposeBag)
        isAlcoholReviewInfo.map{String($0?.score3Count ?? 0)}.bind(to: score3CntGL.rx.text).disposed(by: disposeBag)
        isAlcoholReviewInfo.map{String($0?.score4Count ?? 0)}.bind(to: score4CntGL.rx.text).disposed(by: disposeBag)
        isAlcoholReviewInfo.map{String($0?.score5Count ?? 0)}.bind(to: score5CntGL.rx.text).disposed(by: disposeBag)
        isAlcoholReviewInfo.map{$0?.scoreAvg ?? 0.0}
            .bind{ [weak self] scoreAvg in
                self?.scoreAvgGL.text = String(scoreAvg)
                self?.starView.current = CGFloat(scoreAvg)
            }.disposed(by: disposeBag)
        
        isAlcoholReviewInfo.map{$0}.bind{ [weak self] result in self?.reviewScoreGaugeSetting(reviewInfo: result)}.disposed(by: disposeBag)
        
        /* End */
        
        /* ReviewList data Bind - Start */
        
        isAlcoholReviewList.bind{ [weak self] result in self?.reviewListSetting(reviewList: result) }.disposed(by: disposeBag)
        isAlcoholReviewList.bind{ [weak self] result in self?.reviewList = result }.disposed(by: disposeBag)
        isReviewListRenewal.bind{ [weak self] result in self?.reviewListSetting(reviewList: result) }.disposed(by: disposeBag)
        isReviewListRenewal.bind{ [weak self] result in self?.reviewList = result }.disposed(by: disposeBag)
        /* End */
        
        /* */
        
        isReviewCreated.bind{[weak self] result in self?.reviewWriteMove(flag: result)}.disposed(by: disposeBag)
        
        isIndicator.bind{[weak self] result in
            self?.loadingIndicator(flag: result)}.disposed(by: disposeBag)
        
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
                    if result?.eventIndex == 0 { //주류정보
                        reactor.action.onNext(.alcoholDetail(result?.pathParams))
                    }else if result?.eventIndex == 1 { //리뷰정보
                        reactor.action.onNext(.alcoholReview(result?.pathParams, nil))
                    }else if result?.eventIndex == 2 { //주류 좋아요
                        reactor.action.onNext(.alcoholLikeOn(result?.alcoholDetail, result?.pathParams))
                    }else if result?.eventIndex == 3 { //주류 좋아요 취소
                        reactor.action.onNext(.alcoholLikeOff(result?.alcoholDetail, result?.pathParams))
                    }else if result?.eventIndex == 4 { //리뷰 좋아요
                        reactor.action.onNext(.reviewLikeOn(result?.reviewList, result?.reviewId, result?.pathParams))
                    }else if result?.eventIndex == 5 { //리뷰 좋아요 취소
                        reactor.action.onNext(.reviewLikeOff(result?.reviewList, result?.reviewId, result?.pathParams))
                    }else if result?.eventIndex == 6 { //리뷰 싫어요
                        reactor.action.onNext(.reviewDisLikeOn(result?.reviewList, result?.reviewId, result?.pathParams))
                    }else if result?.eventIndex == 7 { //리뷰 싫어요 취소
                        reactor.action.onNext(.reviewDisLikeOff(result?.reviewList, result?.reviewId, result?.pathParams))
                    }else if result?.eventIndex == 8 { //리뷰 작성 여부
                        reactor.action.onNext(.reviewCreated(result?.pathParams))
                    }
                }else { //갱신 실패
                    print("갱신실패")
                }
            })
            .disposed(by: disposeBag)
        
        /* */
    }

    //주류설명 더보기 펼치기 관리
    func descriptionExpand() {
        let contentsLine = (alcoholDescriptionGL?.text ?? "").lineOfString(width: view.frame.width - 36.0, font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 15.0) ?? UIFont.boldSystemFont(ofSize: 15.0), lineSpacing: 4.0)
        let contentsHeight = (alcoholDescriptionGL?.text ?? "").heightOfString(width: view.frame.width - 36.0, font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 15.0) ?? UIFont.boldSystemFont(ofSize: 15.0), lineSpacing: 4.0)
        
        if descriptionExpandFlag {
            alcoholDescriptionWrap.constraints.forEach { (constraint) in // ---- 3
                if constraint.firstAttribute == .height {
                    constraint.constant = 211.0
                }
            }
            moreImage.image = UIImage(named: "expandMoreDown")
            moreGL.text = "더보기"
        }else {
            alcoholDescriptionWrap.constraints.forEach { (constraint) in // ---- 3
                if constraint.firstAttribute == .height {
                    //(contentsSize.0 * 5.0) = 라인수-1 * lineSpacing
                    constraint.constant = 119.0 + contentsHeight + (contentsLine * 5.0)
                }
            }
            moreImage.image = UIImage(named: "expandMoreUp")
            moreGL.text = "접기"
        }
        
        descriptionExpandFlag = !descriptionExpandFlag
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
    
    func reviewListMove() {
        let reviewListVC = StoryBoardName.mainServiceStoryBoard.instantiateViewController(withIdentifier: "ReviewListVC") as! ReviewListVC
        reviewListVC.alcoholId = alcoholId
        reviewListVC.beforeBackgroundImage = backgroundImage?.image
        navigationController?.pushViewController(reviewListVC, animated: true)
    }
    
    func reviewWriteMove(flag:Bool?) {
        guard let flag = flag else {return}
        print(flag)
        if flag { //true = 이미 작성 된 리뷰가 있음
            let singleAlertPopVC = StoryBoardName.popupStoryBoard.instantiateViewController(withIdentifier: "SingleAlertPopVC") as! SingleAlertPopVC
            singleAlertPopVC.modalPresentationStyle = .overCurrentContext
            singleAlertPopVC.alertFlag = 1
            present(singleAlertPopVC, animated: false, completion: nil)
        }else { //작성 된 리뷰가 없어서 리뷰작성화면 이동 가능
            let reviewWriteVC = StoryBoardName.mainServiceStoryBoard.instantiateViewController(withIdentifier: "ReviewWriteVC") as! ReviewWriteVC
            reviewWriteVC.alcoholId = alcoholId
            reviewWriteVC.reviewUpdateFlag = false
            reviewWriteVC.alcoholName = alcoholNameGL?.text ?? ""
            reviewWriteVC.brewery = breweryGL?.text ?? ""
            reviewWriteVC.beforeAlcoholImage = alcoholImage?.image ?? UIImage()
            reviewWriteVC.beforeBackgroundImage = backgroundImage?.image ?? UIImage()
            present(reviewWriteVC, animated: false, completion: nil)
        }
    }
    
   
    
    //주류 이미지 세팅
    func alcoholImageSetting(urlString: String) {
        guard let alcoholImage = alcoholImage else {return}
        if urlString.count > 0 {
            WebPImageDecoder.enable()
            let webpimageURL = URL(string: urlString)!
            Nuke.loadImage(with: webpimageURL, into: alcoholImage)
        }
    }
    
    //주류 배경이미지 세팅
    func backgroundImageSetting(urlString: String) {
        guard let backgroundImage = backgroundImage else {return}
        if urlString.count > 0 {
            WebPImageDecoder.enable()
            let webpimageURL = URL(string: urlString)!
            Nuke.loadImage(with: webpimageURL, into: backgroundImage)
        }
    }
    
    //사용자 지표 세팅
    func userGraphSetting(userAssessment:UserAssessment?) {
        guard let userAssessmentWrap = userAssessmentWrap else {return}
        
        
        //초기화
        for view in userAssessmentWrap.subviews {
            if let _ = view as? AlcoholUserAssessment {
                view.removeFromSuperview()
            }
        }
        
        let aroma:Int = Int(round(userAssessment?.aroma ?? 0.0))
        let mouthFeel:Int = Int(round(userAssessment?.mouthfeel ?? 0.0))
        let taste:Int = Int(round(userAssessment?.taste ?? 0.0))
        let appearance:Int = Int(round(userAssessment?.appearance ?? 0.0))
        let overall:Int = Int(round(userAssessment?.overall ?? 0.0))
        
        let alcoholUserAssessment = AlcoholUserAssessment(frame: userAssessmentWrap.frame)
        alcoholUserAssessment.userGraphView?.data = [aroma,taste,appearance,overall,mouthFeel]
        userAssessmentWrap.addSubview(alcoholUserAssessment)
    }
    
    //평가하기 갔다가 돌아올때 스크롤 맨위로 올리기 위한 메소드
    func imageInit() {
        scrollView?.scrollToTop()
    }
    
    //뒤로가기
    func backEvent() {
        
        disposeBag = DisposeBag()

        navigationController?.popViewController(animated: true)
    }
    
    func uiInit() {
        reviewBtn?.layer.cornerRadius = 3.0
        reviewBtn?.shadow(opacity: 0.16, radius: 2, offset: CGSize(width: 0, height: 2), color: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1).cgColor)
        
        starView?.delegate = self
        
        let attribute = StarRatingAttribute(type: .rate,
                                            point: 23,
                                            spacing: 0.0,
                                            emptyColor: .clear,
                                            fillColor: UIColor(red: 251/255, green: 192/255, blue: 45/255, alpha: 1.0),
                                            emptyImage: UIImage(named: "ratingEmpty"),
                                            fillImage: UIImage(named: "ratingFullstar"))
        starView?.configure(attribute, current: 0, max: 5)
        
        starView?.delegate = self
        starView?.current = 0.0
        
        alcoholInfoMoreWrap?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(alcoholInfoMoreCtrl)))
    }
    
    @objc func alcoholInfoMoreCtrl() {
        let expandedFlag:Bool = alcoholDetail?.expanded ?? false
        alcoholDetail?.expanded = !expandedFlag
        
        alcoholInfoSetting(alcoholDetail: alcoholDetail)
    }
    
    //회원가입 요청
    func goSignUp(signUpArr:[String], userInfo:User, socialDivision:String) {
        let signUpVC = StoryBoardName.signUpStoryBoard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        signUpVC.signUpArr = signUpArr
        signUpVC.userInfo = userInfo
        signUpVC.socialDivision = socialDivision
        navigationController?.pushViewController(signUpVC, animated: true)
    }
}


//주류 상세 전용 탭 제스처 공용 class
class AlcoholDetailVCTapGesture: UITapGestureRecognizer {
    /* 주류 관련 */
    //주류 아이디
    var alcoholId:String = String()
    //좋아요 여부
    var alcoholLikeFlag:Bool = Bool()
    
    /* 리뷰 관련*/
    //리뷰 접기 펼치기 여부
    var reviewExpandedFlag:Bool = Bool()
    //리뷰 리스트
    var reviewList:[ReviewList] = []
    //리뷰 id
    var reviewId:String = String()
    //리뷰 좋아요 여부
    var reviewHasLike:Bool = Bool()
    //리뷰 싫어요 여부
    var reviewHasDisLike:Bool = Bool()
}
