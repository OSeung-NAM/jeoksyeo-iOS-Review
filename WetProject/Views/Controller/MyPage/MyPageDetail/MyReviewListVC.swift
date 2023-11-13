//
//  MyReviewListVC.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/02.
//

import UIKit
import RxCocoa
import RxSwift
import ReactorKit

//내가 평가한 주류 화면 UI를 컨트롤 하기위한 파일
class MyReviewListVC: BaseViewController, StoryboardView {
    
    @IBOutlet weak var titleBackgroundWrap: UIView!
    @IBOutlet weak var titleWrap: UIView!
    @IBOutlet weak var userNameGL: UILabel!
    @IBOutlet weak var reviewAllCntGL: UILabel!
    
    @IBOutlet weak var reviewMainWrap: UIView!
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var reviewListContainer: UIView!
    @IBOutlet weak var allGuideWrap: UIView!
    @IBOutlet weak var traditionGuideWrap: UIView!
    @IBOutlet weak var beerGuideWrap: UIView!
    @IBOutlet weak var wineGuideWrap: UIView!
    @IBOutlet weak var liquorGuideWrap: UIView!
    @IBOutlet weak var sakeGuideWrap: UIView!
    
    @IBOutlet weak var allToTopWrap: UIView!
    @IBOutlet weak var trToTopWrap: UIView!
    @IBOutlet weak var beToTopWrap: UIView!
    @IBOutlet weak var wiToTopWrap: UIView!
    @IBOutlet weak var liToTopWrap: UIView!
    @IBOutlet weak var saToTopWrap: UIView!
    
    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var traditionBtn: UIButton!
    @IBOutlet weak var beerBtn: UIButton!
    @IBOutlet weak var wineBtn: UIButton!
    @IBOutlet weak var liquorBtn: UIButton!
    @IBOutlet weak var sakeBtn: UIButton!
    @IBOutlet weak var categoryBottomLine: UIView!
    
    @IBOutlet weak var myReviewListTV: UITableView!
    
    let myReviewListRT = MyReviewListRT()
    
    var myReviewCategoryTableCell:MyReviewCategoryTableCell? = nil
    
    //현재 선택한 카테고리
    var currentCatecory:Int = 0
    
    var reviewTotalCnt:Int = 0
    
    
    var myReviewCell : MyReviewCell?
    
    var reviewList:[ReviewList] = []
    
    @IBOutlet weak var noReviewListWrap: UIView!
    
    var deleteReviewIndex:Int = Int()
    var updateReviewIndex:Int = Int()
    
    var review:ReviewList?
    
    var isPaging = false
    var pagingInfo:PagingInfo?
    
    var reviewIdList:[String] = [String()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        reviewMainWrap.layer.cornerRadius = 20.0
        reviewMainWrap.shadow(opacity: 0.13, radius: 3, offset: CGSize(width: -2, height: -3), color: UIColor(red: 234/255, green: 149/255, blue: 35/255, alpha: 1).cgColor)
        
        //일시적으로 constraint(관계) 끊어줌 - 카테고리 선택할때마다 라인 움직여야함
        categoryBottomLine.translatesAutoresizingMaskIntoConstraints = true
        
        myReviewListTV.delegate = self
        myReviewListTV.dataSource = self
        myReviewListTV.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        
        

        titleWrap?.topAnchor.constraint(equalTo: titleBackgroundWrap.topAnchor,constant:getStatusBarHeight()).isActive = true

        //스와이프 해서 뒤로가기 허용
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        reactor = myReviewListRT
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
        
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
    
    func bind(reactor: MyReviewListRT) {
        
        /* UIEvent */
        
        allGuideWrap.rx.tapGesture().when(.recognized)
            .bind{ [weak self] _ in self?.categorySetting(categoryIndex: 0)}.disposed(by: disposeBag)
        
        allToTopWrap.rx.tapGesture().when(.recognized)
            .bind{ [weak self] _ in self?.tableScrollToTop()}.disposed(by: disposeBag)
        
        traditionGuideWrap.rx.tapGesture().when(.recognized)
            .bind{ [weak self] _ in self?.categorySetting(categoryIndex: 1)}.disposed(by: disposeBag)
        
        trToTopWrap.rx.tapGesture().when(.recognized)
            .bind{ [weak self] _ in self?.tableScrollToTop()}.disposed(by: disposeBag)
        
        beerGuideWrap.rx.tapGesture().when(.recognized)
            .bind{ [weak self] _ in self?.categorySetting(categoryIndex: 2)}.disposed(by: disposeBag)
        
        beToTopWrap.rx.tapGesture().when(.recognized)
            .bind{ [weak self] _ in self?.tableScrollToTop()}.disposed(by: disposeBag)
        
        wineGuideWrap.rx.tapGesture().when(.recognized)
            .bind{ [weak self] _ in self?.categorySetting(categoryIndex: 3)}.disposed(by: disposeBag)
        
        wiToTopWrap.rx.tapGesture().when(.recognized)
            .bind{ [weak self] _ in self?.tableScrollToTop()}.disposed(by: disposeBag)
        
        liquorGuideWrap.rx.tapGesture().when(.recognized)
            .bind{ [weak self] _ in self?.categorySetting(categoryIndex: 4)}.disposed(by: disposeBag)
        
        liToTopWrap.rx.tapGesture().when(.recognized)
            .bind{ [weak self] _ in self?.tableScrollToTop()}.disposed(by: disposeBag)
        
        sakeGuideWrap.rx.tapGesture().when(.recognized)
            .bind{ [weak self] _ in self?.categorySetting(categoryIndex: 5)}.disposed(by: disposeBag)
        
        saToTopWrap.rx.tapGesture().when(.recognized)
            .bind{ [weak self] _ in self?.tableScrollToTop()}.disposed(by: disposeBag)
        
        backBtn.rx.tap.bind{[weak self] _ in self?.backEvent()}.disposed(by: disposeBag)
        
        myReviewListTV.rx.contentOffset
            .subscribe(onNext:{ [weak self] _ in
                let height: CGFloat = self?.myReviewListTV.frame.size.height ?? 0.0
                let contentYOffset: CGFloat = self?.myReviewListTV.contentOffset.y ?? 0.0
                let scrollViewHeight: CGFloat = self?.myReviewListTV.contentSize.height ?? 0.0
                let distanceFromBottom: CGFloat = scrollViewHeight - contentYOffset
                

                if distanceFromBottom < height {
                    let nextFlag = self?.pagingInfo?.next ?? false
                    
                    let currentPage = self?.pagingInfo?.page ?? 1
                    
                    
                    if !(self?.isPaging ?? false) {
                        self?.isPaging = true
                        if nextFlag {
                            let params = MyReviewListRQModel(f: self?.apiCallCategory() ?? "ALL", c: 20, p: currentPage + 1)
                            reactor.action.onNext(.getMyReviewList(params))
                        }
                    }
                }
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
    
        categorySetting(categoryIndex: 0)
        
        /* */
        
        /* State */
        
        let isReviewListPageInfo = reactor.state.map{$0.isMyReviewList?.pagingInfo}.filter{$0 != nil}
        let isSummaryInfo = reactor.state.map{$0.isMyReviewList?.summary}.filter{$0 != nil}
        let isMyReviewListInfo = reactor.state.map{$0.isMyReviewList?.reviewList}.filter{$0 != nil}
        let isReviewDelete = reactor.state.map{$0.isReviewDelete}.filter{$0 != nil}
        
        let isIndicator = reactor.state.map{$0.isIndecator}.filter{$0 != nil}
        
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

        isReviewListPageInfo.bind{[weak self] result in self?.pagingInfo = result}.disposed(by: disposeBag)
        
        isSummaryInfo.map{($0?.nickname ?? "") + "님,"}.bind(to: userNameGL.rx.text).disposed(by: disposeBag)
        isSummaryInfo.map{"총 " + String($0?.reviewCount ?? 0) + "개의 주류를 평가하셨습니다"}.bind(to: reviewAllCntGL.rx.text).disposed(by: disposeBag)
        isSummaryInfo.map{$0?.reviewCount ?? 0}.bind{[weak self] result in self?.reviewTotalCnt = result }.disposed(by: disposeBag)
        
        isMyReviewListInfo
            .bind{[weak self] result in
                self?.isPaging = false
                self?.reviewListSetting(review: result ?? [])
        }.disposed(by: disposeBag)
        
        isReviewDelete.bind{ [weak self] result in
            if result ?? false {
                //리뷰 삭제 성공 후 삭제한 리뷰 Index제거 후 리로딩
                if let deleteReviewIndex = self?.deleteReviewIndex {
                    let reviewTotalCnt:Int = self?.reviewTotalCnt ?? 0
                    if reviewTotalCnt > 0 {
                        self?.reviewAllCntGL.text = "총 " + String(reviewTotalCnt - 1) + "개의 주류를 평가하셨습니다"
                        self?.reviewTotalCnt = (reviewTotalCnt - 1)
                        self?.reviewList.remove(at: deleteReviewIndex)
                        self?.myReviewListTV.reloadData()
                    }
                }
            }
        }.disposed(by: disposeBag)
        
        //로딩
        isIndicator.bind{[weak self] result in
            self?.loadingIndicator(flag: result ?? false)}.disposed(by: disposeBag)
        
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
                    if result?.eventIndex == 0 { //내가 작성한 리뷰 리스트 조회
                        reactor.action.onNext(.getMyReviewList(result?.params))
                    }else if result?.eventIndex == 1 { //리뷰 삭제
                        reactor.action.onNext(.reviewDelete(result?.pathParams))
                    }
                }else { //갱신 실패
                    print("갱신실패")
                }
            })
            .disposed(by: disposeBag)
        
        /* */
    }
    
    //상단 카테고리 선택하기 전 버튼 색 초기화
    func categoryColorInit() {
        allBtn.setTitleColor(UIColor(red: 143/255, green: 143/255, blue: 143/255, alpha: 1), for: .normal)
        traditionBtn.setTitleColor(UIColor(red: 143/255, green: 143/255, blue: 143/255, alpha: 1), for: .normal)
        beerBtn.setTitleColor(UIColor(red: 143/255, green: 143/255, blue: 143/255, alpha: 1), for: .normal)
        wineBtn.setTitleColor(UIColor(red: 143/255, green: 143/255, blue: 143/255, alpha: 1), for: .normal)
        liquorBtn.setTitleColor(UIColor(red: 143/255, green: 143/255, blue: 143/255, alpha: 1), for: .normal)
        sakeBtn.setTitleColor(UIColor(red: 143/255, green: 143/255, blue: 143/255, alpha: 1), for: .normal)
    }
    
    //카테고리 선택하기 전 초기화
    func scrollTopInit() {
        allToTopWrap.isHidden = true
        trToTopWrap.isHidden = true
        beToTopWrap.isHidden = true
        wiToTopWrap.isHidden = true
        liToTopWrap.isHidden = true
        saToTopWrap.isHidden = true
    }
    
    //테이블 스크롤 맨위로
    func tableScrollToTop() {
        if reviewList.count > 0{
            myReviewListTV.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func categorySetting(categoryIndex:Int) {
        
        //카테고리 선택시 버튼 색 초기화 작업 진행
        categoryColorInit()
        scrollTopInit()
        categoryBottomLine.isHidden = false

        currentCatecory = categoryIndex
        
        var params = MyReviewListRQModel(f: "ALL", c: 20, p: 1)
        
        if categoryIndex == 0 {
            allBtn.setTitleColor(UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1), for: .normal)
            UIView.animate(withDuration: 0.2) { [self] in
                categoryBottomLine.frame = CGRect(x:allBtn.frame.origin.x, y: allBtn.frame.height - 2.0, width:allBtn.frame.width, height:2.0)
                categoryBottomLine.frame.origin.x = allBtn.frame.origin.x
            }
            allToTopWrap.isHidden = false
            params.f = "ALL"
        }else if categoryIndex == 1 { //전통주
            traditionBtn.setTitleColor(UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1), for: .normal)
            UIView.animate(withDuration: 0.2) { [self] in
                categoryBottomLine.frame = CGRect(x:traditionBtn.frame.origin.x, y: traditionBtn.frame.height - 2.0, width:traditionBtn.frame.width, height:2.0)
                categoryBottomLine.frame.origin.x = traditionBtn.frame.origin.x
            }
            trToTopWrap.isHidden = false
            params.f = "TR"
        }else if categoryIndex == 2 { //맥주
            self.beerBtn.setTitleColor(UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1), for: .normal)
            UIView.animate(withDuration: 0.2) { [self] in
                self.categoryBottomLine.frame = CGRect(x:beerBtn.frame.origin.x, y: beerBtn.frame.height - 2.0, width:beerBtn.frame.width, height:2.0)
                self.categoryBottomLine.frame.origin.x = beerBtn.frame.origin.x
            }
            beToTopWrap.isHidden = false
            params.f = "BE"
        }else if categoryIndex == 3 { //와인
            self.wineBtn.setTitleColor(UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1), for: .normal)
            UIView.animate(withDuration: 0.2) { [self] in
                categoryBottomLine.frame = CGRect(x:wineBtn.frame.origin.x, y: wineBtn.frame.height - 2.0, width:wineBtn.frame.width, height:2.0)
                categoryBottomLine.frame.origin.x = wineBtn.frame.origin.x
            }
            wiToTopWrap.isHidden = false
            params.f = "WI"
        }else if categoryIndex == 4 { //양주
            self.liquorBtn.setTitleColor(UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1), for: .normal)
            UIView.animate(withDuration: 0.2) { [self] in
                categoryBottomLine.frame = CGRect(x:liquorBtn.frame.origin.x, y: liquorBtn.frame.height - 2.0, width:liquorBtn.frame.width, height:2.0)
                categoryBottomLine.frame.origin.x = liquorBtn.frame.origin.x
            }
            liToTopWrap.isHidden = false
            params.f = "FO"
        }else { //사케
            sakeBtn.setTitleColor(UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1), for: .normal)
            UIView.animate(withDuration: 0.2) { [self] in
                categoryBottomLine.frame = CGRect(x:sakeBtn.frame.origin.x, y: sakeBtn.frame.height - 2.0, width:sakeBtn.frame.width, height:2.0)
                categoryBottomLine.frame.origin.x = sakeBtn.frame.origin.x
            }
            saToTopWrap.isHidden = false
            params.f = "SA"
        }
        
        reviewList = []
        reviewIdList = []
        myReviewListTV.reloadData()
        if let reactor = reactor {
            reactor.action.onNext(.getMyReviewList(params))
        }
    }
    
    //뒤로가기
    func backEvent() {
        navigationController?.popViewController(animated: true)
    }
    
    
    func apiCallCategory() -> String {
        var code:String = "ALL"
        switch currentCatecory {
        case 1:
            code = "TR"
            break
        case 2:
            code = "BE"
            break
        case 3:
            code = "WI"
            break
        case 4:
            code = "FO"
            break
        case 5:
            code = "SA"
            break
        default:
            break
        }
        return code
    }
    
    func reviewListSetting(review:[ReviewList]) {
        
        for r in review {
            if let reviewId:String = r.reviewId {
                if !reviewIdList.contains(reviewId) {
                    reviewIdList.append(reviewId)
                    reviewList.append(r)
                }
            }
        }
        myReviewListTV.reloadData()
    }
}

extension MyReviewListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if reviewList.count > 0 {
            noReviewListWrap.isHidden = true
            view.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        }else {
            noReviewListWrap.isHidden = false
            view.backgroundColor = .white
        }
        
        return reviewList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        myReviewCell = tableView.dequeueReusableCell(withIdentifier: "MyReviewCell") as? MyReviewCell
        
        if myReviewCell == nil {
            myReviewCell = Bundle.main.loadNibNamed("MyReviewCell", owner: self, options: nil)?.first as? MyReviewCell
        }
        

        myReviewCell?.reviewList = reviewList
        myReviewCell?.callingView = self as Any
        myReviewCell?.dataSetting(indexPath: indexPath,view: view)
          
        myReviewCell?.deleteBtn.tag = indexPath.row
        myReviewCell?.deleteBtn.addTarget(self, action: #selector(deleteEvent(_:)), for: .touchUpInside)
        myReviewCell?.updateBtn.tag = indexPath.row
        myReviewCell?.updateBtn.addTarget(self, action: #selector(updateEvent(_:)), for: .touchUpInside)
       
        return myReviewCell!
    }
    
    //리뷰 삭제 이벤트
    @objc func deleteEvent(_ sender:UIButton) {
        let row = sender.tag
        deleteReviewIndex = row
        let customAlertPopVC = StoryBoardName.popupStoryBoard.instantiateViewController(withIdentifier: "CustomAlertPopVC") as! CustomAlertPopVC
        customAlertPopVC.modalPresentationStyle = .overCurrentContext
        customAlertPopVC.alertFlag = 1
        present(customAlertPopVC, animated: false, completion: nil)
    }
    
    //리뷰 수정 이벤트
    @objc func updateEvent(_ sender:UIButton) {
        let row = sender.tag
        updateReviewIndex = row

        review = reviewList[row]

        let reviewWriteVC = StoryBoardName.mainServiceStoryBoard.instantiateViewController(withIdentifier: "ReviewWriteVC") as! ReviewWriteVC
        reviewWriteVC.reviewUpdateFlag = true
        reviewWriteVC.reviewDetail = review
        navigationController?.pushViewController(reviewWriteVC, animated: true)

    }
    
    //리뷰 삭제
    func reviewDelete(){
        if let reactor = reactor {
            let alcoholId = reviewList[deleteReviewIndex].alcohol?.alcoholId ?? ""
            let reviewId = reviewList[deleteReviewIndex].reviewId ?? ""
            let pathParams = [
                "alcoholId": alcoholId,
                "reviewId":reviewId
            ]
            reactor.action.onNext(.reviewDelete(pathParams))
        }
    }
}
