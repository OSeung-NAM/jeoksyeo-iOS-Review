//
//  ReviewListVC.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/30.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

//리뷰 모아보기 화면 UI를 컨트롤 하기위한 파일
class ReviewListVC: BaseViewController, StoryboardView {
    
    let reviewMoreListRT = ReviewMoreListRT()
    
    @IBOutlet weak var titleBackgroundWrap: UIView!
    @IBOutlet weak var titleWrap: UIView!
    //뒷배경 이미지
    @IBOutlet weak var backgroundImage: UIImageView?
    //총 리뷰 갯수
    @IBOutlet weak var reviewCntGL: UILabel?
    //뒤로가기 버튼
    @IBOutlet weak var backBtn: UIButton?
    //리뷰 리스트 테이블뷰
    @IBOutlet weak var reviewListTV: UITableView!
    
    @IBOutlet weak var reviewCntWrap: UIView!
    
    var reviewListCell:ReviewListCell?
    
    var alcoholId:String = String()
    var reviewId:String = String()
    
    var reviewContentsLine:(CGFloat,CGFloat, Bool) = (0,0,false)
    
    //이전화면에서 넘어온 뒷배경 이미지
    var beforeBackgroundImage:UIImage?
    
    /* pagination */
    var pagingInfo:PagingInfo?
    
    var isPaging:Bool = false //현재 페이징 진행중인지 체크하는 flag
    
    var reviewRQInfo:BehaviorRelay<Int> = BehaviorRelay.init(value: 1)
    
    //리뷰 리스트 중복 제거하기 위함
    var reviewIdList:Array<String> = []
    var reviewList:BehaviorRelay<[ReviewList]> = BehaviorRelay.init(value: [])

    override func viewDidLoad() {
        super.viewDidLoad()
       
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        reviewListTV?.backgroundColor = .clear
        reviewCntWrap.borderAll(width: 0.5, color: UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1).cgColor)
        
        if let image = beforeBackgroundImage {
            backgroundImage?.image = image
        }
        reviewListTV.delegate = self
        titleWrap?.topAnchor.constraint(equalTo: view.topAnchor,constant: getStatusBarHeight()).isActive = true
        reactor = reviewMoreListRT
    }

    override func viewDidDisappear(_ animated: Bool) {
        disposeBag = DisposeBag()
    }
    
    func bind(reactor: ReviewMoreListRT) {
        
        let pathParams = [
            "alcoholId" : alcoholId
        ]
        
        /* UIEvent */
        
        backBtn?.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                self?.backEvent()
            })
            .disposed(by: disposeBag)
        
        reviewListTV.rx.contentOffset
            .subscribe(onNext:{ [weak self] _ in
                let height: CGFloat = self?.reviewListTV.frame.size.height ?? 0.0
                let contentYOffset: CGFloat = self?.reviewListTV.contentOffset.y ?? 0.0
                let scrollViewHeight: CGFloat = self?.reviewListTV.contentSize.height ?? 0.0
                let distanceFromBottom: CGFloat = scrollViewHeight - contentYOffset

                if distanceFromBottom < height {
                    let nextFlag = self?.pagingInfo?.next ?? false
                    
                    let currentPage = self?.pagingInfo?.page ?? 1
                    
                    if !(self?.isPaging ?? false) {
                        self?.isPaging = true
                        if nextFlag {
                            let params = [
                                "p" : (currentPage + 1),
                                "c" : 20
                            ]
                            reactor.action.onNext(.reviewMoreList(pathParams, params))
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        /* */
        
        if(isInternetAvailable)(){
            log.info("Network Connected")
        } else {
            netWorkStateToast(errorIndex: 0)
            log.info("Network DisConnected")
            return
        }
        
        /* Action */
        let params = [
            "p" : 1,
            "c" : 20
        ]
        
        reactor.action.onNext(.reviewMoreList(pathParams, params))
        
        /* */
        
        /* State */
        let isPagingInfo = reactor.state.map{$0.isReviewMoreList}.map{$0.0}.filter{$0 != nil}
        let isReviewInfo = reactor.state.map{$0.isReviewMoreList}.map{$0.1}.filter{$0 != nil}
        let isReviewList = reactor.state.map{$0.isReviewMoreList}.map{$0.2}.filter{$0 != nil}.map{$0 ?? []}
        let isIndicator = reactor.state.map{$0.isIndicator}.filter{$0 != nil}.map{$0 ?? false}
        let isReviewLikeOn = reactor.state.map{$0.isReviewLikeOn}.filter{$0 != nil}.map{$0 ?? false}
        let isReviewLikeOff = reactor.state.map{$0.isReviewLikeOff}.filter{$0 != nil}.map{$0 ?? false}
        let isReviewDisLikeOn = reactor.state.map{$0.isReviewDisLikeOn}.filter{$0 != nil}.map{$0 ?? false}
        let isReviewDisLikeOff = reactor.state.map{$0.isReviewDisLikeOff}.filter{$0 != nil}.map{$0 ?? false}
        
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
                
                if result.1 == 1 { //중복 리뷰 좋아요 에러
                    self?.netWorkStateToast(errorIndex: 4)
                }else if result.1 == 3 { //중복 리뷰 싫어요 에러
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
                if result.1?.eventIndex == 0 { //리뷰 리스트 조회는 로그인이 필요없어서 로그아웃 시켜버리고 다시 조회 진입
                    reactor.action.onNext(.reviewMoreList(result.1?.pathParams, result.1?.params))
                }
            }
        }.disposed(by: disposeBag)
        
        isIndicator.bind{[weak self] result in
            self?.loadingIndicator(flag: result)}.disposed(by: disposeBag)
        
        isPagingInfo.bind{[weak self] result in
            self?.isPaging = false
            self?.pagingInfo = result
        }.disposed(by: disposeBag)
        
        isReviewInfo.bind{[weak self] result in
            self?.reviewCntGL?.text = "총 " + String(result?.reviewTotalCount ?? 0) + "개의 리뷰"
        }.disposed(by: disposeBag)
        
        isReviewList.bind{[weak self] result in
            self?.reviewListSetting(review: result)
        }.disposed(by: disposeBag)
        
        reviewList.bind(to: reviewListTV.rx.items){ [weak self] (tableView: UITableView, index: Int, review: ReviewList) -> UITableViewCell in
            
            self?.reviewListCell = tableView.dequeueReusableCell(withIdentifier: "ReviewListCell") as? ReviewListCell
            
            if self?.reviewListCell == nil {
                self?.reviewListCell = Bundle.main.loadNibNamed("ReviewListCell", owner: self, options: nil)?.first as? ReviewListCell
            }
            let line = self?.sizeOfString(contents: review.contents ?? "")
            self?.reviewContentsLine = (line?.0 ?? 0,line?.1 ?? 0,review.expandFlag )
            if (line?.0) ?? 0 > 2 {
                self?.reviewListCell?.reviewBottomExpandedWrap.constraints.forEach { (constraint) in // ---- 3
                    if constraint.firstAttribute == .height {
                        constraint.constant = 36.0
                    }
                }
            }else {
                self?.reviewListCell?.reviewBottomExpandedWrap.constraints.forEach { (constraint) in // ---- 3
                    if constraint.firstAttribute == .height {
                        constraint.constant = 0.0
                    }
                }
            }
            //주류 좋아요, 좋아요 취소
            let reviewLikeTap = ReviewListVCTapGesture(target: self, action: #selector(self?.likeCtrl(_:)))
            reviewLikeTap.reviewId = review.reviewId ?? ""
            reviewLikeTap.reviewLikeFlag = review.hasLike ?? false
            self?.reviewListCell?.likeWrap.addGestureRecognizer(reviewLikeTap)
            self?.reviewListCell?.reviewSetting(review: review)
            
            //주류 싫어요, 싫어요 취소
            let reviewDisLikeTap = ReviewListVCTapGesture(target: self, action: #selector(self?.disLikeCtrl(_:)))
            reviewDisLikeTap.reviewId = review.reviewId ?? ""
            reviewDisLikeTap.reviewDisLikeFlag = review.hasDisLike ?? false
            self?.reviewListCell?.disLikeWrap.addGestureRecognizer(reviewDisLikeTap)
            
            //주류 좋아요, 좋아요 취소
            let expandTap = ReviewListVCTapGesture(target: self, action: #selector(self?.expandSetting(_:)))
            expandTap.reviewId = review.reviewId ?? ""
            expandTap.expandFlag = review.expandFlag
            self?.reviewListCell?.expandWrap.addGestureRecognizer(expandTap)
            self?.reviewListCell?.reviewSetting(review: review)
            
            self?.reviewListCell?.reviewSetting(review: review)
            
            let reviewCell = self?.reviewListCell
            return reviewCell!
            
        }.disposed(by: disposeBag)
        
        isReviewLikeOn.bind{[weak self] result in
            if result {
                self?.reviewLikeAfterEvent()
            }
        }.disposed(by: disposeBag)
        
        isReviewLikeOff.bind{[weak self] result in
            if result {
                self?.reviewLikeAfterEvent()
            }
        }.disposed(by: disposeBag)
        
        isReviewDisLikeOn.bind{[weak self] result in
            if result {
                self?.reviewDisLikeAfterEvent()
            }
        }.disposed(by: disposeBag)
        
        isReviewDisLikeOff.bind{[weak self] result in
            if result {
                self?.reviewDisLikeAfterEvent()
            }
        }.disposed(by: disposeBag)
        
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
                    if result?.eventIndex == 0 { //리뷰 리스트 조회
                        reactor.action.onNext(.reviewMoreList(result?.pathParams, result?.params))
                    }else if result?.eventIndex == 1 { //좋아요
                        reactor.action.onNext(.reviewLikeOn(result?.pathParams))
                    }else if result?.eventIndex == 2 { //좋아요 취소
                        reactor.action.onNext(.reviewLikeOff(result?.pathParams))
                    }else if result?.eventIndex == 3 { //싫어요 취소
                        reactor.action.onNext(.reviewDisLikeOn(result?.pathParams))
                    }else if result?.eventIndex == 4 { //싫어요 취소
                        reactor.action.onNext(.reviewDisLikeOff(result?.pathParams))
                    }
                }else { //갱신 실패
                    print("갱신실패")
                }
            })
            .disposed(by: disposeBag)
        
        /* */
    }
   
    func reviewListSetting(review:[ReviewList]) {
     
        var reviewDummyList:[ReviewList] = reviewList.value

        for r in review {
            if let reviewId:String = r.reviewId {
                if !reviewIdList.contains(reviewId) {
                    reviewIdList.append(reviewId)
                    reviewDummyList.append(r)
                }
            }
        }
        reviewList.accept(reviewDummyList)
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
    
    //뒤로가기
    func backEvent() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func expandSetting(_ gesture:ReviewListVCTapGesture) {
        let reviewId = gesture.reviewId
        let expandFlag = gesture.expandFlag
        var reviewListDummy = reviewList.value
        
        var index:Int = 0
        for v in reviewListDummy {
            if reviewId == v.reviewId {
                reviewListDummy[index].expandFlag = !expandFlag
                break
            }
            index += 1
        }
        reviewList.accept(reviewListDummy)
    }
    
    @objc func likeCtrl(_ gesture: ReviewListVCTapGesture) {
        reviewId = gesture.reviewId
        let isLiked:Bool = gesture.reviewLikeFlag
        
        if let reactor = reactor {
            let pathParams = [
                "alcoholId":alcoholId,
                "reviewId":reviewId
            ]
            
            if isLiked {
                reactor.action.onNext(.reviewLikeOff(pathParams))
            }else {
                reactor.action.onNext(.reviewLikeOn(pathParams))
            }
        }
    }
    
    @objc func disLikeCtrl(_ gesture: ReviewListVCTapGesture) {
        reviewId = gesture.reviewId
        let isDisLiked:Bool = gesture.reviewDisLikeFlag
    
        if let reactor = reactor {
            let pathParams = [
                "alcoholId":alcoholId,
                "reviewId":reviewId
            ]
            
            if isDisLiked {
                reactor.action.onNext(.reviewDisLikeOff(pathParams))
            }else {
                reactor.action.onNext(.reviewDisLikeOn(pathParams))
            }
        }
    }
    
    func reviewLikeAfterEvent(){
        var reviewDummyList = reviewList.value
        var index:Int = 0
        for r in reviewDummyList {
            let rId = r.reviewId
            let hasLiked:Bool = r.hasLike ?? false
            let hasDisLiked:Bool = r.hasDisLike ?? false
            let likeCnt:Int = r.likeCount ?? 0
            let disLikeCnt:Int = r.disLikeCount ?? 0
            if rId == reviewId {
                if hasLiked {
                    reviewDummyList[index].likeCount = (likeCnt - 1)
                }else {
                    if hasDisLiked {
                        reviewDummyList[index].hasDisLike = false
                        reviewDummyList[index].disLikeCount = (disLikeCnt - 1)
                    }
                    reviewDummyList[index].likeCount = (likeCnt + 1)
                }
                reviewDummyList[index].hasLike = !hasLiked
                break
            }
            index += 1
        }
        reviewList.accept(reviewDummyList)
    }
    
    func reviewDisLikeAfterEvent(){
        var reviewDummyList = reviewList.value
        var index:Int = 0
        for r in reviewDummyList {
            let rId = r.reviewId
            let hasLiked:Bool = r.hasLike ?? false
            let hasDisLiked:Bool = r.hasDisLike ?? false
            let likeCnt:Int = r.likeCount ?? 0
            let disLikeCnt:Int = r.disLikeCount ?? 0
            if rId == reviewId {
                if hasDisLiked {
                    reviewDummyList[index].disLikeCount = (disLikeCnt - 1)
                }else {
                    if hasLiked {
                        reviewDummyList[index].hasLike = false
                        reviewDummyList[index].likeCount = (likeCnt - 1)
                    }
                    reviewDummyList[index].disLikeCount = (disLikeCnt + 1)
                }
                reviewDummyList[index].hasDisLike = !hasDisLiked
                break
            }
            index += 1
        }
        reviewList.accept(reviewDummyList)
    }
}

extension ReviewListVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let expandFlag:Bool = reviewContentsLine.2
        let line:CGFloat = reviewContentsLine.0
        
        if line > 2 {
            if expandFlag {
                return  UITableView.automaticDimension
            }else {
                return 176
            }
        }else {
            return 154.0
        }
    }
    
    //리뷰 컨텐츠 라인 체크
    func sizeOfString(contents:String) -> (CGFloat,CGFloat){
        let contentsLine = (round(contents.boundingRect(
                                    with: CGSize(width: view.frame.width - 34.0, height: CGFloat.infinity),
                                    options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                    attributes: [.font: UIFont(name: "AppleSDGothicNeo-Medium", size: 13.0) ],
                                    context: nil).size.height / UIFont(name: "AppleSDGothicNeo-Medium", size: 13.0)!.lineHeight * 1000) / 1000)
        let spacing = (round((contentsLine * 4) * 1000) / 1000)
        let textViewHeight = (contentsLine * (UIFont(name: "AppleSDGothicNeo-Medium", size: 13.0)!.lineHeight)) + spacing
        
        return (line:contentsLine,height:textViewHeight)
    }
}

//주류리뷰 모아보기 전용 탭 제스처 공용 class
class ReviewListVCTapGesture: UITapGestureRecognizer {
    //리뷰 아이디
    var reviewId:String = String()
    //좋아요 여부
    var reviewLikeFlag:Bool = Bool()
    //싫어요 여부
    var reviewDisLikeFlag:Bool = Bool()
    //리뷰 펼치기 여부
    var expandFlag:Bool = Bool()
}
