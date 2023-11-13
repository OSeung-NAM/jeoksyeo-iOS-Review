//
//  AlcoholListVC.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/30.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import SnapKit

//주류 리스트 UI를 컨트롤 하기위한 파일
class AlcoholListVC: BaseViewController,StoryboardView {
    
    var filterIndex:Int = 0
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var filterWrap: UIView!
    
    //0:전통주, 1:사케, 2:맥주, 3:와인, 4:양주
    var currentCategoryIndex:Int = -1
    
    @IBOutlet weak var listBtn: UIButton!
    @IBOutlet weak var gridBtn: UIButton!
    @IBOutlet weak var categoryBottomLine: UIView!
    
    /* 카테고리 */
    
    @IBOutlet weak var trBtn: UIButton!
    @IBOutlet weak var beBtn: UIButton!
    @IBOutlet weak var wiBtn: UIButton!
    @IBOutlet weak var liBtn: UIButton!
    @IBOutlet weak var saBtn: UIButton!
    @IBOutlet weak var trWrap: UIView!
    //전통주 상단 이동 전용 뷰
    @IBOutlet weak var trToTopWrap: UIView!
    @IBOutlet weak var beWrap: UIView!
    //맥주 상단 이동 전용 뷰
    @IBOutlet weak var beToTopWrap: UIView!
    @IBOutlet weak var wiWrap: UIView!
    //와인 상단 이동 전용 뷰
    @IBOutlet weak var wiToTopWrap: UIView!
    @IBOutlet weak var liWrap: UIView!
    //양주 상단 이동 전용 뷰
    @IBOutlet weak var liToTopWrap: UIView!
    @IBOutlet weak var saWrap: UIView!
    //사케 상단 이동 전용 뷰
    @IBOutlet weak var saToTopWrap: UIView!
    
    /* */
    
    @IBOutlet weak var filterBtn: UIButton!
    //리스트모드
    @IBOutlet weak var listTV: UITableView!
    //그리드 모드
    @IBOutlet weak var gridListCV: UICollectionView!
    
    @IBOutlet weak var scrollViewContainerViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var alcoholListWrap: UIView!
    
    var alcoholListRT:AlcoholListRT = AlcoholListRT()
    
    var alcoholTableCell : AlcoholTableCell?
    
    var alcoholGridCell : AlcoholGridCell?
    
    var categoryInfo:BehaviorRelay<String> = BehaviorRelay.init(value: String())
    
    var alcoholRQInfo:BehaviorRelay<(category:String,filter:String)?> = BehaviorRelay.init(value: nil)
    
    /* pagination */
    
    var pagingInfo:PagingInfo?
    
    var isPaging:Bool = false //현재 페이징 진행중인지 체크하는 flag
    
    var currentCatecory = 0
    
    /* */
    
    /* scroll to top */
    
    var scrollToTopFlag:Bool = false
    
    var initFlag:Bool = true
    
    /* */
    
    var alcoholId:String = String()
    //주류 리스트 중복 제거하기 위함
    var alcoholIdList:Array<String> = []
    var alcoholList:[AlcoholList] = []
    var alcoholLikeInfo:BehaviorRelay<(String,Bool)?> = BehaviorRelay.init(value: nil)
    
    var listModeFlag:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alcoholTableHeader = UINib.init(nibName: "AlcoholTableHeader", bundle: Bundle.main)
        let alcoholGridHeader = UINib.init(nibName: "AlcoholGridHeader", bundle: Bundle.main)
        
        scrollViewContainerViewWidth.constant = UIScreen.main.bounds.size.width * 2
        
        listTV.dataSource = self
        listTV.delegate = self
        listTV.register(alcoholTableHeader, forHeaderFooterViewReuseIdentifier: "AlcoholTableHeader")
        listTV.backgroundColor = UIColor(red: 251/255, green: 251/255, blue: 251/255, alpha: 1)
        
        gridListCV.dataSource = self
        gridListCV.delegate = self
        gridListCV.backgroundColor = UIColor(red: 251/255, green: 251/255, blue: 251/255, alpha: 1)
        gridListCV.register(UINib(nibName: "AlcoholGridCell", bundle: nil), forCellWithReuseIdentifier: "AlcoholGridCell")
        gridListCV.register(alcoholGridHeader, forCellWithReuseIdentifier: "AlcoholGridHeader")
        gridListCV.register(alcoholGridHeader, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "AlcoholGridHeader")
        
        trToTopWrap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(listScrollToTop)))
        beToTopWrap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(listScrollToTop)))
        wiToTopWrap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(listScrollToTop)))
        liToTopWrap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(listScrollToTop)))
        saToTopWrap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(listScrollToTop)))
        
        reactor = AlcoholListRT()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        alcoholListWrap.snp.makeConstraints{ make in
            if let tabbar = tabBarController?.tabBar {
                make.bottom.equalTo(tabbar.snp.top)
            }
        }
            
        tabBarController?.tabBar.isHidden = false
        if(isInternetAvailable)(){
            print("네트워크 연결 됨")
        } else {
            netWorkStateToast(errorIndex: 0)
            print("네트워크 연결 안됨")
            return
        }
        
        if initFlag { //주류 리스트 화면 초기 진입시에만 호출하도록 설정 (viewDidLoad에 넣을 수 있지만 애니메이션 때문에 DidAppear에 설정해야함)
    
            initFlag = false

            categorySetting(categoryIndex: currentCategoryIndex)
        }
        
        //스크롤해서 뒤로가기 허용
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        
    }
    
    func bind(reactor: AlcoholListRT) {
        
        /* UIEvent */
        
        backBtn.rx.tap.bind{[weak self] _ in self?.backEvent()}.disposed(by: disposeBag)
        searchBtn.rx.tap.bind{[weak self] _ in self?.searchMove()}.disposed(by: disposeBag)
        filterWrap.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.filterBottomCall()
            })
            .disposed(by: disposeBag)

        trWrap.rx.tapGesture().when(.recognized)
            .bind{ [weak self] _ in self?.categorySetting(categoryIndex: 0)}.disposed(by: disposeBag)
        
        trToTopWrap.rx.tapGesture().when(.recognized)
            .bind{ [weak self] _ in self?.listScrollToTop()}.disposed(by: disposeBag)
        
        beWrap.rx.tapGesture().when(.recognized)
            .bind{ [weak self] _ in self?.categorySetting(categoryIndex: 1)}.disposed(by: disposeBag)
        
        beToTopWrap.rx.tapGesture().when(.recognized)
            .bind{ [weak self] _ in self?.listScrollToTop()}.disposed(by: disposeBag)
        
        wiWrap.rx.tapGesture().when(.recognized)
            .bind{ [weak self] _ in self?.categorySetting(categoryIndex: 2)}.disposed(by: disposeBag)
        
        wiToTopWrap.rx.tapGesture().when(.recognized)
            .bind{ [weak self] _ in self?.listScrollToTop()}.disposed(by: disposeBag)
        
        liWrap.rx.tapGesture().when(.recognized)
            .bind{ [weak self] _ in self?.categorySetting(categoryIndex: 3)}.disposed(by: disposeBag)
        
        liToTopWrap.rx.tapGesture().when(.recognized)
            .bind{ [weak self] _ in self?.listScrollToTop()}.disposed(by: disposeBag)
        
        saWrap.rx.tapGesture().when(.recognized)
            .bind{ [weak self] _ in self?.categorySetting(categoryIndex: 4)}.disposed(by: disposeBag)
        
        saToTopWrap.rx.tapGesture().when(.recognized)
            .bind{ [weak self] _ in self?.listScrollToTop()}.disposed(by: disposeBag)
        
        //리스트 모드 변경 버튼
        listBtn.rx.tap.bind{[weak self] _ in self?.listModeCtrl(flag: true)}.disposed(by: disposeBag)
        //그리드 모드 변경 버튼
        gridBtn.rx.tap.bind{[weak self] _ in self?.listModeCtrl(flag: false)}.disposed(by: disposeBag)
        
        listTV.rx.contentOffset
            .subscribe(onNext:{ [weak self] _ in
                let height: CGFloat = self?.listTV.frame.size.height ?? 0.0
                let contentYOffset: CGFloat = self?.listTV.contentOffset.y ?? 0.0
                let scrollViewHeight: CGFloat = self?.listTV.contentSize.height ?? 0.0
                let distanceFromBottom: CGFloat = scrollViewHeight - contentYOffset
                
                if distanceFromBottom < height {
                    let nextFlag = self?.pagingInfo?.next ?? false
                    
                    let currentPage = self?.pagingInfo?.page ?? 1
                    
                    if !(self?.isPaging ?? false) {
                        self?.isPaging = true
                        if nextFlag {
                            let params = AlcoholListRQModel(f: self?.alcoholListRQSetting().0, c: 20,s: self?.alcoholListRQSetting().1, p: currentPage + 1)
                            reactor.action.onNext(.alcoholList(params))
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        gridListCV.rx.contentOffset
            .subscribe(onNext:{ [weak self] _ in
                let height: CGFloat = self?.gridListCV.frame.size.height ?? 0.0
                let contentYOffset: CGFloat = self?.gridListCV.contentOffset.y ?? 0.0
                let scrollViewHeight: CGFloat = self?.gridListCV.contentSize.height ?? 0.0
                let distanceFromBottom: CGFloat = scrollViewHeight - contentYOffset
                

                if distanceFromBottom < height {
                    let nextFlag = self?.pagingInfo?.next ?? false
                    let currentPage = self?.pagingInfo?.page ?? 1
                         
                    if !(self?.isPaging ?? false) {
                        self?.isPaging = true
                        
                        if nextFlag {
                            let params = AlcoholListRQModel(f: self?.alcoholListRQSetting().0, c: 20,s: self?.alcoholListRQSetting().1, p: currentPage + 1)
                            reactor.action.onNext(.alcoholList(params))
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        /* */
        
        /* State */
        
        let isPagingInfo = reactor.state.map{$0.isAlcoholList}.map{$0.0}.filter{$0 != nil}
        let isAlcoholList = reactor.state.map{$0.isAlcoholList}.map{$0.1}.filter{$0 != nil}.map{$0 ?? []}
        let isAlcoholLikeOn = reactor.state.map{$0.isAlcoholLikeOn}.filter{$0 != nil}.map{$0 ?? false}
        let isAlcoholLikeOff = reactor.state.map{$0.isAlcoholLikeOff}.filter{$0 != nil}.map{$0 ?? false}
        
        let isError = reactor.state.map{$0.isErrors}.filter{$0.0 != nil}
        let isTokenError = reactor.state.map{$0.isTokenError}.filter{$0.0 != nil}
        let isTimeOut = reactor.state.map{$0.isTimeOut}.filter{$0 != nil}.map{$0 ?? false}
        
        //서버 TimeOut
        isTimeOut.bind{[weak self] result in
            if result {
                self?.netWorkStateToast(errorIndex: 408)
            }
        }.disposed(by: disposeBag)

        //에러 여부
        isError.bind{ [weak self] result in
            if (result.0 ?? false) { //일반 API 에러
                if result.1 == 0 {
                    self?.netWorkStateToast(errorIndex: 1)
                }else if result.1 == 1 { //중복 좋아요 에러
                    self?.netWorkStateToast(errorIndex: 3)
                }
            }
        }.disposed(by: disposeBag)
        
        isTokenError
            .observeOn(MainScheduler.asyncInstance)
            .bind{[weak self] result in
            if (result.0 ?? false) { //유효하지 않은 토큰이면 그냥 로그아웃시키고 에러 문구띄워줌
                UserDefaults.standard.setValue(nil, forKey: "accessToken")
                UserDefaults.standard.setValue(nil, forKey: "refreshToken")
                
                self?.netWorkStateToast(errorIndex: 2)
                if result.1?.eventIndex == 0 { //주류 조회는 로그인이 필요없어서 로그아웃 시켜버리고 다시 조회 진입
                    reactor.action.onNext(.alcoholList(result.1?.params))
                }
            }
        }.disposed(by: disposeBag)
        
        
        
        let isIndicator = reactor.state.map{$0.isIndecator}.filter{$0 != nil}.map{$0 ?? false}
        
        isIndicator.bind{[weak self] result in self?.loadingIndicator(flag: result)}.disposed(by: disposeBag)
        
        isPagingInfo.bind{[weak self] result in
            self?.pagingInfo = result
            self?.isPaging = false
        }.disposed(by: disposeBag)
        
        isAlcoholList
            .bind{[weak self] result in
                self?.alcoholListSetting(alcohol: result)
            }.disposed(by: disposeBag)
        
        isAlcoholLikeOn.bind{[weak self] result in
            if result {
                self?.alcoholLikeAfterEvent()
            }
        }.disposed(by: disposeBag)
        
        isAlcoholLikeOff.bind{[weak self] result in
            if result {
                self?.alcoholLikeAfterEvent()
            }
        }.disposed(by: disposeBag)
        
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
                    if result?.eventIndex == 0 { //주류 리스트 조회
                        reactor.action.onNext(.alcoholList(result?.params))
                    }else if result?.eventIndex == 1 { //주류 좋아요
                        reactor.action.onNext(.alcoholLikeOn(result?.pathParams))
                    }else if result?.eventIndex == 2 { //주류 좋아요 취소
                        reactor.action.onNext(.alcoholLikeOff(result?.pathParams))
                    }
                }else { //갱신 실패
                    print("갱신실패")
                }
            })
            .disposed(by: disposeBag)
        
        /* */
    }
    
    func alcoholListSetting(alcohol:[AlcoholList]) {
        for a in alcohol {
            if let alcoholId:String = a.alcoholId {
                if !alcoholIdList.contains(alcoholId){
                    alcoholIdList.append(alcoholId)
                    alcoholList.append(a)
                }
            }
        }
        listTV.reloadData()
        gridListCV.reloadData()
    }
    
    //리스트 모드 관리
    func listModeCtrl(flag:Bool) {
        listModeFlag = flag
        
        if flag {
            listBtn.setImage(UIImage(named: "listOn"), for: .normal)
            gridBtn.setImage(UIImage(named: "gridOff"), for: .normal)
            listTV.reloadData()
            if gridListCV.indexPathsForVisibleItems.count > 0 {
                var currentGridCVIndexPath:IndexPath = gridListCV.indexPathsForVisibleItems[0]
                if currentGridCVIndexPath.row > 5 {
                    currentGridCVIndexPath = IndexPath(row: currentGridCVIndexPath.row-1, section: 0)
                    listTV.scrollToRow(at: currentGridCVIndexPath, at: .top, animated: false)
                }
            }
            scrollView.scrollTo(horizontalPage: 0, verticalPage: nil, animated: true)
            
        }else {
            listBtn.setImage(UIImage(named: "listOff"), for: .normal)
            gridBtn.setImage(UIImage(named: "gridOn"), for: .normal)
            gridListCV.reloadData()
            
            if let listIndexVisibleRows = listTV.indexPathsForVisibleRows {
                if listIndexVisibleRows.count > 0 {
                    let currentListTVIndexPath:IndexPath = listIndexVisibleRows[0]
                    if currentListTVIndexPath.row > 5 {
                        gridListCV.scrollToItem(at: currentListTVIndexPath, at: .top, animated: false)
                    }
                }
            }
            scrollView.scrollTo(horizontalPage: 1, verticalPage: nil, animated: true)
        }
    }
    
    //뒤로가기
    func backEvent() {
        navigationController?.popViewController(animated: true)
    }
    
    //검색화면 이동
    func searchMove() {
        let alcoholSearchVC = StoryBoardName.mainServiceStoryBoard.instantiateViewController(withIdentifier: "AlcoholSearchVC") as! AlcoholSearchVC
        navigationController?.pushViewController(alcoholSearchVC, animated: true)
    }
    
    //마이페이지 navigationDrawer호출
    func myPageMove() {
        let customSideMenuNavigation = StoryBoardName.myPageStoryBoard.instantiateViewController(withIdentifier: "CustomSideMenuNavigation") as! CustomSideMenuNavigation
        present(customSideMenuNavigation, animated: true, completion: nil)
    }
    
    func categorySetting(categoryIndex:Int) {
        
        categoryBottomLine?.isHidden = false
        categoryColorInit()
        scrollTopInit()
        currentCatecory = categoryIndex
        
        var params = AlcoholListRQModel(f: "TR", c: 20, s: alcoholListRQSetting().1, p: 1)
        
        if categoryIndex == 0 { //전통주
            self.trBtn?.setTitleColor(UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1), for: .normal)
            UIView.animate(withDuration: 0.2) {
                self.categoryBottomLine.frame = CGRect(x:self.trBtn.frame.origin.x, y: self.trBtn.frame.height - 3.0, width:self.trBtn.frame.width, height:3.0)
            }
            trToTopWrap.isHidden = false
            params.f = "TR"
        }else if categoryIndex == 1 { //맥주
            self.beBtn.setTitleColor(UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1), for: .normal)
            UIView.animate(withDuration: 0.2) {
                self.categoryBottomLine?.frame = CGRect(x:self.beBtn.frame.origin.x, y: self.beBtn.frame.height - 3.0, width:self.beBtn.frame.width, height:3.0)
            }
            beToTopWrap.isHidden = false
            params.f = "BE"
        }else if categoryIndex == 2 { //와인
            self.wiBtn.setTitleColor(UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1), for: .normal)
            UIView.animate(withDuration: 0.2) {
                self.categoryBottomLine.frame = CGRect(x:self.wiBtn.frame.origin.x, y: self.wiBtn.frame.height - 3.0, width:self.wiBtn.frame.width, height:3.0)
            }
            wiToTopWrap.isHidden = false
            params.f = "WI"
        }else if categoryIndex == 3 { //양주
            self.liBtn.setTitleColor(UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1), for: .normal)
            UIView.animate(withDuration: 0.2) {
                self.categoryBottomLine.frame = CGRect(x:self.liBtn.frame.origin.x, y: self.liBtn.frame.height - 3.0, width:self.liBtn.frame.width, height:3.0)
            }
            liToTopWrap.isHidden = false
            params.f = "FO"
        }else { //사케
            self.saBtn.setTitleColor(UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1), for: .normal)
            UIView.animate(withDuration: 0.2) {
                self.categoryBottomLine.frame = CGRect(x:self.saBtn.frame.origin.x, y: self.saBtn.frame.height - 3.0, width:self.saBtn.frame.width, height:3.0)
            }
            saToTopWrap.isHidden = false
            params.f = "SA"
        }
        
        if(isInternetAvailable()){
            print("네트워크 연결 됨")
        } else {
            netWorkStateToast(errorIndex: 0)
            print("네트워크 연결 안됨")
            return
        }
        
        alcoholList.removeAll()
        alcoholIdList.removeAll()
        listTV.reloadData()
        gridListCV.reloadData()
        if let reactor = reactor {
            reactor.action.onNext(.alcoholList(params))
        }
    }
    
    //상단 카테고리 선택하기 전 버튼 색 초기화
    func categoryColorInit() {
        trBtn.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1), for: .normal)
        beBtn.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1), for: .normal)
        wiBtn.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1), for: .normal)
        liBtn.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1), for: .normal)
        saBtn.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1), for: .normal)
    }
    
    func filterBottomCall() {
        let alcoholListFilterPopVC = StoryBoardName.popupStoryBoard.instantiateViewController(withIdentifier: "AlcoholListFilterPopVC") as! AlcoholListFilterPopVC
        
        alcoholListFilterPopVC.filterIndex = filterIndex
        present(alcoholListFilterPopVC, animated: true, completion: nil)
    }
    
    //주류리스트 필터 타이틀 변경
    func filterChange(filterIndex:Int) {
        print("2312312")
        self.filterIndex = filterIndex
        if filterIndex == 0 {
            self.filterBtn.titleLabel?.text = "좋아요순"
            self.filterBtn.setTitle("좋아요순", for: .normal)
        }else if filterIndex == 1 {
            self.filterBtn.titleLabel?.text = "리뷰순"
            self.filterBtn.setTitle("리뷰순", for: .normal)
        }else if filterIndex == 2 {
            self.filterBtn.titleLabel?.text = "높은 도수순"
            self.filterBtn.setTitle("높은 도수순", for: .normal)
        }else {
            self.filterBtn.titleLabel?.text = "낮은 도수순"
            self.filterBtn.setTitle("낮은 도수순", for: .normal)
        }
        
        if(isInternetAvailable()){
            print("네트워크 연결 됨")
        } else {
            netWorkStateToast(errorIndex: 0)
            print("네트워크 연결 안됨")
            return
        }
        
        let params = AlcoholListRQModel(f: alcoholListRQSetting().0, c: 20, s: alcoholListRQSetting().1, p: 1)
        
        alcoholList.removeAll()
        alcoholIdList.removeAll()
        listTV.reloadData()
        gridListCV.reloadData()
        if let reactor = reactor {
            reactor.action.onNext(.alcoholList(params))
        }
    }
    
    func alcoholListRQSetting() -> (String,String){
        
        var category = String()
        var filter = String()
        
        switch currentCatecory {
        case 0:
            category = "TR"
            break
        case 1:
            category = "BE"
            break
        case 2:
            category = "WI"
            break
        case 3:
            category = "FO"
            break
        case 4:
            category = "SA"
            break
        default:
            break
        }
        
        switch filterIndex {
        case 0:
            filter = "like"
            break
        case 1:
            filter = "review"
            break
        case 2:
            filter = "abv-desc"
            break
        case 3:
            filter = "abv-asc"
            break
        default:
            break
        }
        
        return (category,filter)
    }
    
    //주류리스트 좋아요 관리 이벤트
    @objc func alcoholLikeEvent(_ gesture: AlcoholListVCTapGesture) {
        if(isInternetAvailable()){
            print("네트워크 연결 됨")
        } else {
            netWorkStateToast(errorIndex: 0)
            print("네트워크 연결 안됨")
            return
        }
        alcoholId = gesture.alcoholId
        let isLiked:Bool = gesture.likeFlag
        
        let pathParams = [
            "alcoholId":alcoholId
        ]
        
        if let reactor = reactor {
            if isLiked {
                reactor.action.onNext(.alcoholLikeOff(pathParams))
            }else {
                reactor.action.onNext(.alcoholLikeOn(pathParams))
            }
        }
    }
    
    //주류 좋아요, 좋아요 취소 부분 클릭 후 UI 후속조치 이벤트
    func alcoholLikeAfterEvent() {
        var alcoholListDummy = alcoholList
        var index:Int = 0
        for alcohol in alcoholListDummy {
            let likeCnt = alcohol.likeCount ?? 0
            let isLiked = alcohol.isLiked ?? false
            
            if let aId = alcohol.alcoholId {
                if aId == alcoholId {
                    if isLiked {
                        alcoholListDummy[index].likeCount = (likeCnt - 1)
                    }else {
                        alcoholListDummy[index].likeCount = (likeCnt + 1)
                    }
                    alcoholListDummy[index].isLiked = !isLiked
                    break
                }
            }
            index += 1
        }
        
        alcoholList = alcoholListDummy
        listTV.reloadData()
        gridListCV.reloadData()
    }
    
    func alcoholDetailMove(alcoholId:String) {
        let alcoholDetailVC = StoryBoardName.mainServiceStoryBoard.instantiateViewController(withIdentifier: "AlcoholDetailVC") as! AlcoholDetailVC
        alcoholDetailVC.alcoholId = alcoholId
        alcoholDetailVC.callingView = self as Any
        navigationController?.pushViewController(alcoholDetailVC, animated: true)
    }
  
    @objc func listScrollToTop() {
        if listModeFlag {
            if alcoholList.count > 0 {
                listTV.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }else {
            gridListCV.scrollToTop()
        }
    }
    
    
    func scrollTopInit() {
        trToTopWrap.isHidden = true
        beToTopWrap.isHidden = true
        wiToTopWrap.isHidden = true
        liToTopWrap.isHidden = true
        saToTopWrap.isHidden = true
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

extension AlcoholListVC: UITableViewDelegate,UITableViewDataSource {

    //헤더 전용 cell추가
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let alcoholTableHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AlcoholTableHeader") as? AlcoholTableHeader
        
        alcoholTableHeader?.productCnt.text = "총 " + String(pagingInfo?.alcoholTotalCount ?? 0) + "개의 상품이 있습니다"
        return alcoholTableHeader ?? UIView.init()
    }
    
    //헤더 높이 조절
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let ratio = 375.0 / 26.0 //디자인 제플린 기준사이즈
        return self.view.frame.width / CGFloat(ratio)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if listModeFlag {
            return alcoholList.count
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        alcoholTableCell = tableView.dequeueReusableCell(withIdentifier: "AlcoholTableCell") as? AlcoholTableCell
    
        if alcoholTableCell == nil {
            alcoholTableCell = Bundle.main.loadNibNamed("AlcoholTableCell", owner: self, options: nil)?.first as? AlcoholTableCell
        }
    
        alcoholTableCell?.alcoholSetting(alcohol: alcoholList[indexPath.row])
        
        //주류 좋아요 세팅
        let likeTap = AlcoholListVCTapGesture(target: self, action: #selector(alcoholLikeEvent(_:)))
        likeTap.alcoholId = alcoholList[indexPath.row].alcoholId ?? ""
        likeTap.likeFlag = alcoholList[indexPath.row].isLiked ?? false
        alcoholTableCell?.likeWrap?.addGestureRecognizer(likeTap)
    
        return alcoholTableCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let alcoholId:String = alcoholList[indexPath.row].alcoholId {
            alcoholDetailMove(alcoholId: alcoholId)
        }
    }
}

extension AlcoholListVC: UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width: CGFloat = self.view.frame.width
        let ratio = 375.0 / 26.0 //디자인 제플린 기준사이즈
        let height: CGFloat = self.view.frame.width / CGFloat(ratio)
        return CGSize(width: width, height: height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "AlcoholGridHeader", for: indexPath) as? AlcoholGridHeader
            headerView?.gridTotalCntGL.text = "총 " + String(pagingInfo?.alcoholTotalCount ?? 0) + "개의 상품이 있습니다"
            return headerView ?? UICollectionReusableView.init()
        default:
            //assert는 Debug모드에서만 동작함. 디버깅 중 조건의 검증을 위해 사용
            assert(false, "Alcohol Grid Header No")
            return UICollectionReusableView.init()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !listModeFlag {
            return alcoholList.count
        }else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        alcoholGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlcoholGridCell", for: indexPath) as? AlcoholGridCell
    
        //그리드 두개중 오른쪽 cell만 우측테두리 없애기 위해 사용
        if indexPath.row%2 != 0 {
            alcoholGridCell?.gridRightLine.isHidden = true
        }else {
            alcoholGridCell?.gridRightLine.isHidden = false
        }
    
        alcoholGridCell?.alcoholSetting(alcohol: alcoholList[indexPath.row])
    
        //주류 좋아요 세팅
        let likeTap = AlcoholListVCTapGesture(target: self, action: #selector(alcoholLikeEvent(_:)))
        likeTap.alcoholId = alcoholList[indexPath.row].alcoholId ?? ""
        likeTap.likeFlag = alcoholList[indexPath.row].isLiked ?? false
        alcoholGridCell?.likeWrap?.addGestureRecognizer(likeTap)
        
        return alcoholGridCell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let alcoholId:String = alcoholList[indexPath.row].alcoholId {
            alcoholDetailMove(alcoholId: alcoholId)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width = CGFloat(0.0)
        var height = CGFloat(0.0)
        
        width = collectionView.frame.width/2
        height = width + 90.0
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

//주류리스트 전용 탭 제스처 공용 class
class AlcoholListVCTapGesture: UITapGestureRecognizer {
    //주류 아이디
    var alcoholId:String = String()
    //좋아요 여부
    var likeFlag:Bool = Bool()
    //정책 여부
    var policyFlag:Int = Int()
}
