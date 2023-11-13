//
//  MainVC2.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/28.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import SnapKit

// 메인화면 UI를 컨트롤 하기위한 파일
class MainVC: BaseViewController,StoryboardView {
    
    @IBOutlet weak var recommendWrap: UIView!
    @IBOutlet weak var bannerInfoWrap: UIView!
    @IBOutlet weak var categoryInfoWrap: UIView!
    @IBOutlet weak var companyInfoWrap: UIView!
    @IBOutlet weak var alcoholRankWrap: UIView!
    
    @IBOutlet weak var searchBtn: UIButton!
    

    @IBOutlet weak var mainScrollView: UIScrollView!
    //    var disposeBag = DisposeBag()
    
    let mainRT = MainRT()
    
    var alcoholLikeInfo:BehaviorRelay<(String,Bool)?> = BehaviorRelay.init(value: nil)
    
    let recommendWrapHeightRatio = 375.0 / 370.0
    let bannerWrapHeightRatio = 375.0 / 250.0
    let categoryWrapHeightRatio = 375.0 / 166.0
    
    var qrFlag:Bool = false
    var alcoholId:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        let viewWidth = view.frame.width

        recommendWrap.constraints.forEach { (constraint) in // ---- 3
            if constraint.firstAttribute == .height {
                constraint.constant = viewWidth / CGFloat(recommendWrapHeightRatio)
            }
        }

        bannerInfoWrap.constraints.forEach { (constraint) in // ---- 3
            if constraint.firstAttribute == .height {
                constraint.constant = viewWidth / CGFloat(bannerWrapHeightRatio)
            }
        }

        companyInfoWrap.constraints.forEach { (constraint) in // ---- 3
            if constraint.firstAttribute == .height {
                constraint.constant = viewWidth / CGFloat(categoryWrapHeightRatio)
            }
        }

        let categoryInfoCell = CategoryInfoCell(frame: CGRect(x: 0, y: 0, width: viewWidth, height: CGFloat(viewWidth / CGFloat(categoryWrapHeightRatio))))

        categoryInfoCell.trWrap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(alcoholListMove(_:))))
        categoryInfoCell.beWrap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(alcoholListMove(_:))))
        categoryInfoCell.wiWrap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(alcoholListMove(_:))))
        categoryInfoCell.liWrap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(alcoholListMove(_:))))
        categoryInfoCell.saWrap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(alcoholListMove(_:))))
        categoryInfoWrap.addSubview(categoryInfoCell)

        let companyInfoCell = CompanyInfoCell(frame: CGRect(x: 0, y: 0, width: viewWidth, height: companyInfoWrap.frame.height))

        //이용약관 이동
        let useTermsTap = MainVCTapGesture(target: self, action: #selector(policyMove(_:)))
        useTermsTap.policyFlag = 0
        companyInfoCell.useTermsWrap?.addGestureRecognizer(useTermsTap)

        //개인정보 처리 방침 이동
        let userPrivacyTap = MainVCTapGesture(target: self, action: #selector(policyMove(_:)))
        userPrivacyTap.policyFlag = 1
        companyInfoCell.userPrivacyWrap?.addGestureRecognizer(userPrivacyTap)

        companyInfoWrap.addSubview(companyInfoCell)

        reactor = mainRT
        

        tabBarController?.tabBar.layer.borderWidth = 0.5
        tabBarController?.tabBar.layer.borderColor = UIColor(red: 207/255, green: 207/255, blue: 207/255, alpha: 1).cgColor
        
    }

    override func viewDidAppear(_ animated: Bool) {
        //스와이프해서 뒤로가기 막음
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        mainScrollView.snp.makeConstraints{ make in
            if let tabbar = tabBarController?.tabBar {
                make.bottom.equalTo(tabbar.snp.top)
            }
        }
        tabBarController?.tabBar.isHidden = false
        if let reactor = reactor {
            /* Action */
                
            if(isInternetAvailable)(){
                log.error("Network is Connected")
            } else {
                netWorkStateToast(errorIndex: 0)
                log.error("Network is DisConnected")
            }
                
            reactor.action.onNext(.main) //배너, 주류추천, 주류랭킹 한번에 실행
                
            /* */
        }
        
        if qrFlag {
            qrFlag = false
            let alcoholDetailVC = StoryBoardName.mainServiceStoryBoard.instantiateViewController(withIdentifier: "AlcoholDetailVC") as! AlcoholDetailVC
            alcoholDetailVC.alcoholId = alcoholId
            navigationController?.pushViewController(alcoholDetailVC, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        disposeBag = DisposeBag()
    }
    
    func bind(reactor: MainRT) {
        /* UIEvent */
        
        searchBtn.rx.tap
            .asDriver()
            .drive(onNext:{ [weak self] in
                let alcoholSearchVC = StoryBoardName.mainServiceStoryBoard.instantiateViewController(withIdentifier: "AlcoholSearchVC") as! AlcoholSearchVC
                
                self?.navigationController?.pushViewController(alcoholSearchVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        alcoholLikeInfo
            .filter{$0 != nil}
            .subscribe(onNext: { data in
                if let alcoholId:String = data?.0, let likeFlag:Bool = data?.1 {
                    let pathParams = [
                        "alcoholId":alcoholId
                    ]
                    
                    if likeFlag {
                        reactor.action.onNext(.alcoholLikeOn(pathParams))
                    }else {
                        reactor.action.onNext(.alcoholLikeOff(pathParams))
                    }
                    
                }
            })
            .disposed(by: disposeBag)
        
        /* */
        
        /* Action */
//        
//        if(isInternetAvailable)(){
//            log.error("Network is Connected")
//        } else {
//            netWorkStateToast(errorIndex: 0)
//            log.error("Network is DisConnected")
//        }
//        
//        reactor.action.onNext(.main) //배너, 주류추천, 주류랭킹 한번에 실행
        
        /* */
        
        /* State */
        
        let isBanner = reactor.state.map{$0.isBanner}.filter {$0 != nil}.map{$0 ?? []}
        let isRecommend = reactor.state.map{$0.isRecommend}.filter{$0 != nil}.map{$0 ?? []}
        let isRank = reactor.state.map{$0.isRank}.filter{$0 != nil}.map{$0 ?? []}
        let isAlcoholLikeOn = reactor.state.map{$0.isAlcoholLikeOn}.filter{$0 != nil}.map{$0 ?? false}
        let isAlcoholListOff = reactor.state.map{$0.isAlcoholLikeOff}.filter{$0 != nil}.map{$0 ?? false}
        let isIndicator = reactor.state.map{$0.isIndicator}.filter{$0 != nil}.map{$0 ?? false}
        
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
            if (result.0 ?? false) {
                if result.1 == 1 { //중복 주류 좋아요 에러
                    self?.netWorkStateToast(errorIndex: 3)
                }else{ //일반 API 에러
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
                if result.1?.eventIndex == 1 { //배너, 주류추천, 주류랭킹 이면 토큰 이상하더라도 로그아웃 강제로 시켜버리고 조회하는로직으로 다시 흘려버림.
                    reactor.action.onNext(.main)
                }
            }
        }.disposed(by: disposeBag)
        
        isBanner.bind{[weak self] result in
            if (self?.subViewInit(index: 0) ?? false) {
                let viewWidth = self?.view.frame.width ?? 0.0
                let bannerWrapHeightRatio = 375.0 / 250.0
                
                let bannerInfoCell = BannerInfoCell(frame: CGRect(x: 0, y: 0, width: viewWidth, height: CGFloat(viewWidth / CGFloat(bannerWrapHeightRatio))))
                bannerInfoCell.bannerList.accept(result)
                self?.bannerInfoWrap.addSubview(bannerInfoCell)
            }
        }.disposed(by: disposeBag)
        
        isRecommend.bind{[weak self] result in
            if (self?.subViewInit(index: 1) ?? false) {
                let viewWidth = self?.view.frame.width ?? 0.0
                let recommendWrapHeightRatio = 375.0 / 370.0
                
                let recommendWrapCell = RecommendWrapCell(frame: CGRect(x: 0, y: 0, width: viewWidth, height: CGFloat(viewWidth / CGFloat(recommendWrapHeightRatio))))
                
                recommendWrapCell.recommendSetting(alcoholList: result, callingView: self as Any)
                self?.recommendWrap.addSubview(recommendWrapCell)
            }
        }.disposed(by: disposeBag)
        
        isRank.bind{[weak self] result in
            if (self?.subViewInit(index: 2) ?? false) {
                let viewWidth = self?.view.frame.width ?? 0.0
                var index:Int = 0
                var rankY:CGFloat = 0
                for alcohol in result {
                    let alcoholRank = AlcoholRankCell(frame: CGRect(x: 0, y: rankY, width: viewWidth, height: 200.0))
                    alcoholRank.rankSetting(alcoholList: alcohol ,index: index)
                    if index == 0 {
                        alcoholRank.borderTop?.isHidden = true
                    }
                    
                    let rankMoveTap = MainVCTapGesture(target: self, action: #selector(self?.alcoholDetailMove(_:)))
                    rankMoveTap.alcoholId = alcohol.alcoholId ?? ""
                    alcoholRank.addGestureRecognizer(rankMoveTap)
                    self?.alcoholRankWrap.addSubview(alcoholRank)
                    rankY += 200
                    index += 1
                }
            }
        }.disposed(by: disposeBag)
        
        isAlcoholLikeOn.bind{[weak self] result in
            if result {
                self?.likeCallback()
            }
        }.disposed(by: disposeBag)
        
        isAlcoholListOff.bind{[weak self] result in
            if result {
                self?.likeCallback()
            }
        }.disposed(by: disposeBag)
        
        isIndicator.bind{[weak self] result in
            self?.loadingIndicator(flag: result)
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
                    if result?.eventIndex == 0 { //배너, 주류추천, 주류랭킹 조회
                        reactor.action.onNext(.main)
                    }else if result?.eventIndex == 1 { //좋아요
                        reactor.action.onNext(.alcoholLikeOn(result?.pathParams))
                    }else if result?.eventIndex == 2 { //좋아요 취소
                        reactor.action.onNext(.alcoholLikeOff(result?.pathParams))
                    }
                }else { //갱신 실패
                    print("갱신실패")
                }
            })
            .disposed(by: disposeBag)
        
        /* */
    }

    //컴포넌트 뷰 초기화
    func subViewInit(index:Int) -> Bool {
        var successFlag:Bool = false
        
        if index == 0 {
            if bannerInfoWrap.subviews.count > 0 {
                for view in bannerInfoWrap.subviews {
                    if let _ = view as? BannerInfoCell {
                        view.removeFromSuperview()
                        successFlag = true
                    }
                }
            }else {
                successFlag = true
            }
        }else if index == 1 {
            if recommendWrap.subviews.count > 0 {
                for view in recommendWrap.subviews {
                    if let _ = view as? RecommendWrapCell {
                        view.removeFromSuperview()
                        successFlag = true
                    }
                }
            }else {
                successFlag = true
            }
        }else {
            if alcoholRankWrap.subviews.count > 0 {
                for view in alcoholRankWrap.subviews {
                    if let _ = view as? AlcoholRankCell {
                        view.removeFromSuperview()
                        successFlag = true
                    }
                }
            }else {
                successFlag = true
            }
        }
        return successFlag
    }
    
    //주류 상세 이동
    @objc func alcoholDetailMove(_ sender: MainVCTapGesture) {
        let alcoholDetailVC = StoryBoardName.mainServiceStoryBoard.instantiateViewController(withIdentifier: "AlcoholDetailVC") as! AlcoholDetailVC
        alcoholDetailVC.alcoholId = sender.alcoholId
        navigationController?.pushViewController(alcoholDetailVC, animated: true)
    }
    
    
    //주류 좋아요 요청
    @objc func alcoholLike(_ sender: MainVCTapGesture) {
        let alcoholId:String = sender.alcoholId
        let likeFlag:Bool = sender.likeFlag
        alcoholLikeInfo.accept((alcoholId,likeFlag))
    }
    
    //주류 좋아요, 좋아요 취소 후 콜백 메서드
    func likeCallback() {
        for view in recommendWrap.subviews {
            if let recommendWrapCell = view as? RecommendWrapCell {
                guard let alcoholList = recommendWrapCell.mainRecommendCV?.alcoholList else {return}
                
                var index:Int = 0
                for alcohol in alcoholList {
                    let alcoholId:String = alcohol.alcoholId
                    if alcoholId == (alcoholLikeInfo.value?.0 ?? "" ) {
                        break
                    }
                    index += 1
                }
                
                let alcoholLikeCnt:Int = alcoholList[index].alcoholLikeCount ?? 0
                if (alcoholLikeInfo.value?.1) ?? false {
                    recommendWrapCell.mainRecommendCV?.alcoholList?[index].isLiked = true
                    recommendWrapCell.mainRecommendCV?.alcoholList?[index].alcoholLikeCount = alcoholLikeCnt + 1
                }else {
                    recommendWrapCell.mainRecommendCV?.alcoholList?[index].isLiked = false
                    recommendWrapCell.mainRecommendCV?.alcoholList?[index].alcoholLikeCount = alcoholLikeCnt - 1
                }
                
                recommendWrapCell.mainRecommendCV?.reloadData()
            }
        }
    }
    
    //회원가입 요청
    func goSignUp(signUpArr:[String], userInfo:User, socialDivision:String) {
        //로그인 하지 않은 상태에서 로그인 했을 시 유저정보가 없을 경우 해당화면에서 회원가입 화면으로 이동하는 콜백 메서드
        let signUpVC = StoryBoardName.signUpStoryBoard.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        signUpVC.signUpArr = signUpArr
        signUpVC.userInfo = userInfo
        signUpVC.socialDivision = socialDivision
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    //정책 화면으로 이동
    @objc func policyMove(_ sender:MainVCTapGesture) {
        let policyVC = StoryBoardName.policyStoryBoard.instantiateViewController(withIdentifier: "PolicyVC") as! PolicyVC
        
        policyVC.policyFlag = sender.policyFlag
        navigationController?.pushViewController(policyVC, animated: true)
    }
    
    //주류 리스트 이동 (카테고리 눌러서)
    @objc func alcoholListMove(_ gesture: UITapGestureRecognizer) {
        let view = gesture.view
        let tag = view?.tag
        let alcoholListVC = StoryBoardName.mainServiceStoryBoard.instantiateViewController(withIdentifier: "AlcoholListVC") as! AlcoholListVC
        alcoholListVC.currentCategoryIndex = tag ?? 0
        navigationController?.pushViewController(alcoholListVC, animated: true)
    }
}

//메인화면 전용 탭 제스처 공용 class
class MainVCTapGesture: UITapGestureRecognizer {
    //주류 아이디
    var alcoholId:String = String()
    //좋아요 여부
    var likeFlag:Bool = Bool()
    //정책 여부
    var policyFlag:Int = Int()
}
