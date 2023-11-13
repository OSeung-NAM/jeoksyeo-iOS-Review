//
//  SearchMainVC.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/16.
//

import UIKit
import SideMenu
import ReactorKit
import RxSwift
import RxCocoa

//주류 검색 UI를 컨트롤 하기위한 파일
class AlcoholSearchVC: BaseViewController,StoryboardView {
    
    @IBOutlet weak var keywordTF: UITextField!
    
    @IBOutlet weak var keywordGL: UILabel!
    
    @IBOutlet weak var backBtn: UIButton!
    /* 검색 모드 별 테이블 뷰 */
    
    //최근검색어 키워드 테이블
    @IBOutlet weak var recentlyListTV: UITableView!
    //연관검색어 키워드 테이블
    @IBOutlet weak var keywordListTV: UITableView!
    //키워드로 주류 검색 테이블
    @IBOutlet weak var alcoholSearchTV: UITableView!
    
    /* */
    /* 키워드 관련 조회 안 될 경우 뷰 */
    @IBOutlet weak var alcoholKeywordIsNullGL: UILabel!
    
    @IBOutlet weak var recentlyIsNullWrap: UIView!
    @IBOutlet weak var keywordListIsNullWrap: UIView!
    @IBOutlet weak var alcoholSearchIsNullWrap: UIView!
    
    @IBOutlet weak var recentlyKeywordWrap: UIView!
    @IBOutlet weak var keywordListWrap: UIView!
    @IBOutlet weak var alcoholSearchWrap: UIView!
    @IBOutlet weak var searchListWrap: UIView!
    
    /* */
    
    //하단 테이블 별 타이틀
    //최근검색어, 연관검색어, 키워드에 대한 주류
    @IBOutlet weak var tableTitleGL: UILabel!
    //키워드 text삭제 버튼
    @IBOutlet weak var keywordDeleteBtn: UIButton!
    //검색 돋보기 버튼
    @IBOutlet weak var searchBtn: UIButton!
    
    @IBOutlet weak var sizeCheckGL: UILabel!
    
    //검색버튼 클릭여부
    
    //0 : 최근검색어, 1: 연관검색어, 2: 키워드로 주류 검색
    var searchViewMode:BehaviorRelay<Int> = BehaviorRelay.init(value: 0)
    
    var alcoholId:String = String()
    
    let alcoholSearchRT = AlcoholSearchRT()
    
    var recentlyKeywordList:BehaviorRelay<[String]> = BehaviorRelay.init(value: [])
    var keywordList:[String] = []
    var alcoholList:BehaviorRelay<[AlcoholList]> = BehaviorRelay.init(value: [])
    var alcoholIdList:[String] = []
    var alcoholSearchKeyword:String = String()
    
    @IBOutlet weak var shortKeywordWrap: UIView!
    @IBOutlet weak var longKeywordWrap: UIView!
    @IBOutlet weak var longKeywordGL: UILabel!
    @IBOutlet weak var shortKeywordGL: UILabel!
    @IBOutlet weak var longKeywordListCntGL: UILabel!
    
    /* 검색 모드 별 Cell 세팅 */
    
    var recentlyKeywordCell : RecentlyKeywordCell?
    var searchKeywordCell : SearchKeywordCell?
    var alcoholSearchCell : AlcoholSearchCell?
    
    /* */
    
    /* Pagination */
    
    var isPaging = false
    var pagingInfo:PagingInfo?
    
    /* */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        reactor = alcoholSearchRT
        
        keywordListTV.backgroundColor = .clear
        alcoholSearchTV.backgroundColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        searchListWrap.snp.makeConstraints{ make in
            if let tabbar = tabBarController?.tabBar {
                make.bottom.equalTo(tabbar.snp.top)
            }
        }
        tabBarController?.tabBar.isHidden = false
    }
    
    func bind(reactor: AlcoholSearchRT) {
        
        enum Event {
        case tap
        case timeout
        }
        
        /* UIEvent */
        
        backBtn.rx.tap
            .bind{[weak self] _ in
                self?.backEvent()    
            }.disposed(by: disposeBag)
        
        searchBtn.rx.tap
            .bind{[weak self] _ in
                //Network State
                if(self?.isInternetAvailable() ?? false) {
                    log.info("Network Connected")
                } else {
                    self?.netWorkStateToast(errorIndex: 0)
                    log.info("Network DisConnected")
                    return
                }

                if let keyword = self?.keywordTF.text{
                    if keyword.count > 0 {
                        self?.alcoholIdList.removeAll()
                        self?.alcoholList.accept([])
                        self?.searchViewMode.accept(2)
                        let params = AlcoholSearchRQModel(k: keyword, c: 20, s: nil, p: 1)
                        //주류 검색 Action
                        reactor.action.onNext(.alcoholSearch(params))
                        self?.alcoholSearchKeyword = keyword
                        self?.recentlyKeywordSetting(keyword: keyword)
                    }
                }
            }.disposed(by: disposeBag)
        

        

        keywordDeleteBtn.rx.tap
            .asDriver()
            .drive(onNext:{ [weak self]_ in
                self?.searchViewMode.accept(0)
                self?.keywordTF.text = ""
                self?.keywordTF.addRightPadding(paddingWidth: 0.0)
                self?.view.endEditing(true) //키보드 내리기 위한 용도
                self?.keywordGL.isHidden = false
                self?.keywordTF.isHidden = true
                self?.recentlyKeywordListSetting()
                self?.keywordDeleteBtn.isHidden = true
            })
            .disposed(by: disposeBag)
        
        
        keywordGL.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                if let text = self?.keywordTF.text {
                    if text.count == 0 {
                        self?.searchViewMode.accept(0)
                        self?.recentlyKeywordListSetting()
                    }
                }
                self?.keywordGL.isHidden = true
                self?.keywordTF.isHidden = false
                self?.keywordTF.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
        
        keywordTF.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext:{ [weak self] _ in
                self?.searchViewMode.accept(1)
                self?.keywordListTV.isHidden = false
                self?.keywordListIsNullWrap.isHidden = true
            }).disposed(by: disposeBag)
        
        //연관검색어 row 클릭 이벤트
        keywordListTV.rx.itemSelected
            .bind{[weak self] indexPath in
                if let keyword = self?.keywordList[indexPath.row] {
                    self?.searchViewMode.accept(2)
                    let params = AlcoholSearchRQModel(k: keyword, c: 20, s: nil, p: 1)
                    //주류 검색 Action
                    reactor.action.onNext(.alcoholSearch(params))
                    
                    self?.alcoholSearchKeyword = keyword
                }
            }.disposed(by: disposeBag)
        
        //주류 검색 리스트 row 클릭 이벤트
        alcoholSearchTV.rx.itemSelected
            .bind{[weak self] indexPath in
                if let alcoholId:String = self?.alcoholList.value[indexPath.row].alcoholId {
                    let alcoholDetailVC = StoryBoardName.mainServiceStoryBoard.instantiateViewController(withIdentifier: "AlcoholDetailVC") as! AlcoholDetailVC
                    alcoholDetailVC.alcoholId = alcoholId
                    alcoholDetailVC.callingView = self as Any
                    self?.navigationController?.pushViewController(alcoholDetailVC, animated: true)
                }
            }.disposed(by: disposeBag)
        
        keywordTF.rx.text.orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                let size:CGSize = (self?.keywordTF.attributedText!.size())!
                let width = size.width
                
                if text.count > 0 {
                    //연관검색어 모드
                    self?.searchViewMode.accept(1)
                    self?.keywordDeleteBtn.isHidden = false
                }else {
                    //최근검색어 모드
                    self?.searchViewMode.accept(0)
                    self?.keywordDeleteBtn.isHidden = true
                    self?.recentlyKeywordListSetting()
                }
                
                if ((self?.keywordTF.frame.width)! - 60.0) <= width {
                    self?.keywordTF.addRightPadding(paddingWidth: 26.0)
                }else {
                    self?.keywordTF.addRightPadding(paddingWidth: 0.0)
                }
            })
            .disposed(by: disposeBag)
        
        keywordTF.rx.text.orEmpty
            .distinctUntilChanged()
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance) //작성 간격
            .subscribe(onNext: { [weak self]text in
                //Network State
                if(self?.isInternetAvailable() ?? false) {
                    log.info("Network Connected")
                } else {
                    self?.netWorkStateToast(errorIndex: 0)
                    log.info("Network DisConnected")
                    return
                }
                if text.count > 0 {
                    let params = [
                        "k":text
                    ]
                    reactor.action.onNext(.keywordSearch(params))
                }
            })
            .disposed(by: disposeBag)
        
        alcoholSearchTV.rx.contentOffset
            .subscribe(onNext:{ [weak self] _ in
                let height: CGFloat = self?.alcoholSearchTV.frame.size.height ?? 0.0
                let contentYOffset: CGFloat = self?.alcoholSearchTV.contentOffset.y ?? 0.0
                let scrollViewHeight: CGFloat = self?.alcoholSearchTV.contentSize.height ?? 0.0
                let distanceFromBottom: CGFloat = scrollViewHeight - contentYOffset
                
                if distanceFromBottom < height {
                    let nextFlag = self?.pagingInfo?.next ?? false
                    
                    let currentPage = self?.pagingInfo?.page ?? 1
                    
                    if !(self?.isPaging ?? false) {
                        self?.isPaging = true
                        if nextFlag {
                            self?.searchViewMode.accept(2)
                            if let keyword = self?.alcoholSearchKeyword {
                                let params = AlcoholSearchRQModel(k: keyword, c: 20, s: nil, p: currentPage + 1)
                                //주류 검색 Action
                                reactor.action.onNext(.alcoholSearch(params))
                            }
                        }
                    }
                    log.info("주류 총 갯수:\(self?.alcoholList.value.count ?? 0)")
                }
            })
            .disposed(by: disposeBag)
        
        /* */
        
        /* State */
        
        //Network State
        if(isInternetAvailable)(){
            log.info("Network Connected")
        } else {
            netWorkStateToast(errorIndex: 0)
            log.info("Network DisConnected")
            return
        }
        
        //연관 검색어
        let isKeywordSearch = reactor.state.map{$0.isKeywordSearch}.filter{$0 != nil}
        //키워드로 주류 검색
        let isAlcoholList = reactor.state.map{$0.isAlcoholSearch}.map{$0?.alcoholList}.filter{$0 != nil}.map{$0 ?? []}
        //키워드로 주류 검색 페이지 정보
        let isPagingInfo = reactor.state.map{$0.isAlcoholSearch}.map{$0?.pagingInfo}.filter{$0 != nil}
        //로딩 Indicator
        let isIndicator = reactor.state.map{$0.isIndecator}.filter{$0 != nil}
        //주류 좋아요
        let isAlcoholLikeOn = reactor.state.map{$0.isAlcoholLikeOn}.filter{$0 != nil}.map{$0 ?? false}
        //주류 좋아요 취소
        let isAlcoholLikeOff = reactor.state.map{$0.isAlcoholLikeOff}.filter{$0 != nil}.map{$0 ?? false}
        
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
                if result.1 == 0 {//좋아요 중복 오류
                    self?.netWorkStateToast(errorIndex: 3)
                }else { //일반 API 오류
                    self?.netWorkStateToast(errorIndex: 1)
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
                if result.1?.eventIndex == 2 { //연관검색어 조회는 로그인 필요없어서 로그아웃 후 재 조회 실행
                    reactor.action.onNext(.keywordSearch(result.1?.keywordParams))
                }else if result.1?.eventIndex == 3 { //검색어로 주류 조회는 로그인 필요 없어서 로그아웃 후 재 조회 실행
                    reactor.action.onNext(.alcoholSearch(result.1?.params))
                }
            }
        }.disposed(by: disposeBag)
        
        isIndicator.bind{[weak self] result in
            self?.loadingIndicator(flag: result ?? false)}.disposed(by: disposeBag)
        
        isKeywordSearch.map{$0 ?? []}
            .bind{[weak self] result in
                //Network State
                if(self?.isInternetAvailable() ?? false) {
                    log.info("Network Connected")
                } else {
                    self?.netWorkStateToast(errorIndex: 0)
                    log.info("Network DisConnected")
                    return
                }
                
                self?.tableOrNullWrapInit()
                if result.count > 0 {
                    self?.keywordListIsNullWrap.isHidden = true
                    self?.keywordListWrap.isHidden = false
                }else {
                    self?.keywordListIsNullWrap.isHidden = false
                    self?.keywordListWrap.isHidden = true
                }
                self?.keywordList = result
            }.disposed(by: disposeBag)
        
        isKeywordSearch.map{$0 ?? []}.bind(to: keywordListTV.rx.items){ [weak self] (tableView: UITableView, index: Int, keyword: String) -> UITableViewCell in
            
            self?.searchKeywordCell = tableView.dequeueReusableCell(withIdentifier: "SearchKeywordCell") as? SearchKeywordCell
            
            if self?.searchKeywordCell == nil {
                self?.searchKeywordCell = Bundle.main.loadNibNamed("SearchKeywordCell", owner: self, options: nil)?.first as? SearchKeywordCell
            }
            
            self?.searchKeywordCell?.keywordName.text = keyword
            self?.searchKeywordCell?.selectionStyle = .none
            
            let keywordCell = self?.searchKeywordCell
            return keywordCell!
            
        }.disposed(by: disposeBag)
        
        isPagingInfo.bind{[weak self] result in
            self?.isPaging = false
            self?.pagingInfo = result
        }.disposed(by: disposeBag)
        
        isAlcoholList.bind{[weak self] result in
            self?.tableOrNullWrapInit()
            if result.count > 0 {
                self?.alcoholSearchIsNullWrap.isHidden = true
                self?.alcoholSearchWrap.isHidden = false
            }else {
                self?.alcoholSearchIsNullWrap.isHidden = false
                self?.alcoholSearchWrap.isHidden = true
            }
            self?.alcoholListDataSetting(alcohol: result)
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
        
        alcoholList.bind(to: alcoholSearchTV.rx.items){ [self] (tableView: UITableView, index: Int, element: AlcoholList) -> UITableViewCell in
            alcoholSearchCell = tableView.dequeueReusableCell(withIdentifier: "AlcoholSearchCell") as? AlcoholSearchCell
            
            if alcoholSearchCell == nil {
                alcoholSearchCell = Bundle.main.loadNibNamed("AlcoholSearchCell", owner: self, options: nil)?.first as? AlcoholSearchCell
            }
            //주류 좋아요
            let alcoholLikeTap = SearchMainVCTapGesture(target: self, action: #selector(alcoholLike(_:)))
            alcoholLikeTap.alcoholId = alcoholList.value[index].alcoholId ?? ""
            alcoholLikeTap.alcoholIsLike = alcoholList.value[index].isLiked ?? false
            alcoholSearchCell?.likeImageWrap.addGestureRecognizer(alcoholLikeTap)
            
            alcoholSearchCell?.dataSetting(alcohol: element)
            alcoholSearchCell?.selectionStyle = .none
            return alcoholSearchCell!
            
        }.disposed(by: disposeBag)
        
        recentlyKeywordList.bind(to: recentlyListTV.rx.items){ [self] (tableView: UITableView, index: Int, element: String) -> UITableViewCell in
            recentlyKeywordCell = tableView.dequeueReusableCell(withIdentifier: "RecentlyKeywordCell") as? RecentlyKeywordCell
            
            if recentlyKeywordCell == nil {
                recentlyKeywordCell = Bundle.main.loadNibNamed("RecentlyKeywordCell", owner: self, options: nil)?.first as? RecentlyKeywordCell
            }
            
            recentlyKeywordCell?.keywordNameBtn.addTarget(self, action: #selector(keywordNameBtnEvent(_:)), for: .touchUpInside)
            recentlyKeywordCell?.deleteBtn.addTarget(self, action: #selector(deleteBtnEvent(_:)), for: .touchUpInside)
            recentlyKeywordCell?.keywordNameBtn.setTitle(element, for: .normal)
            recentlyKeywordCell?.selectionStyle = .none
            return recentlyKeywordCell!
            
        }.disposed(by: disposeBag)
        
        /* */
        
        /* 테이블 모드 */
        
        searchViewMode.bind{[weak self] data in
            if data == 0 { //최근검색어
                self?.tableTitleGL.isHidden = false
                self?.tableTitleGL.text = "최근 검색어"
                self?.alcoholIdList.removeAll()
                self?.alcoholList.accept([])
                self?.shortKeywordWrap.isHidden = true
                self?.longKeywordWrap.isHidden = true
            }else if data == 1 { //연관검색어
                self?.tableTitleGL.isHidden = false
                self?.tableTitleGL.text = "연관 검색어"
                self?.alcoholIdList.removeAll()
                self?.alcoholList.accept([])
                self?.shortKeywordWrap.isHidden = true
                self?.longKeywordWrap.isHidden = true
            }else { //키워드로 주류 검색
                self?.alcoholSearchTV.isHidden = false
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
                    if result?.eventIndex == 0 { //주류 좋아요
                        reactor.action.onNext(.alcoholLikeOn(result?.pathParams))
                    }else if result?.eventIndex == 1 { //주류 좋아요 취소
                        reactor.action.onNext(.alcoholLikeOff(result?.pathParams))
                    }else if result?.eventIndex == 2 { //연관검색어
                        reactor.action.onNext(.keywordSearch(result?.keywordParams))
                    }else if result?.eventIndex == 3 { //키워드로 주류 검색
                        reactor.action.onNext(.alcoholSearch(result?.params))
                    }
                }else { //갱신 실패
                    print("갱신실패")
                }
            })
            .disposed(by: disposeBag)
        
        /* */
        
    }
    
    //테이블 , 결과없음 감싸는 뷰 초기화
    func tableOrNullWrapInit() {
        recentlyKeywordWrap.isHidden = true
        keywordListWrap.isHidden = true
        alcoholSearchWrap.isHidden = true
        recentlyIsNullWrap.isHidden = true
        keywordListIsNullWrap.isHidden = true
        alcoholSearchIsNullWrap.isHidden = true
    }
    
    //최근검색어 이름 클릭 이벤트
    @IBAction func keywordNameBtnEvent(_ sender: UIButton) {
        //Network State
        if isInternetAvailable() {
            log.info("Network Connected")
        } else {
            netWorkStateToast(errorIndex: 0)
            log.info("Network DisConnected")
            return
        }
        let point = sender.convert(CGPoint.zero, to: recentlyListTV)
        guard let indexPath = recentlyListTV.indexPathForRow(at: point) else {return}
        if let reactor = reactor {
            searchViewMode.accept(2)
            let keyword = recentlyKeywordList.value[indexPath.row]
            let params = AlcoholSearchRQModel(k: keyword, c: 20, s: nil, p: 1)
            //주류 검색 Action
            reactor.action.onNext(.alcoholSearch(params))
            
            alcoholSearchKeyword = keyword
        }
    }

    //최근검색어 리스트 삭제 이벤트
    @IBAction func deleteBtnEvent(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: recentlyListTV)
        guard let indexPath = recentlyListTV.indexPathForRow(at: point) else {return}
        
        recentlyListTV.beginUpdates()
        var list:[String] = []
        var index:Int = 0
        for keyword in recentlyKeywordList.value {
            if index != indexPath.row {
                list.append(keyword)
            }
            index += 1
        }
        
        UserDefaults.standard.set(list, forKey: "recentlyKeywordList")
        recentlyKeywordListSetting()
        recentlyListTV.deleteRows(at: [indexPath], with: .left)
        recentlyListTV.endUpdates()
    }

    //최근 검색어 세팅
    func recentlyKeywordSetting(keyword:String) {
        if var recentlyKeywordList = UserDefaults.standard.stringArray(forKey: "recentlyKeywordList") ?? [String](){
            if !recentlyKeywordList.contains(keyword) { //같은 키워드는 안넣음
                recentlyKeywordList.insert(keyword, at: 0)
                if recentlyKeywordList.count > 10 {
                    recentlyKeywordList.removeLast()
                }
                UserDefaults.standard.set(recentlyKeywordList, forKey: "recentlyKeywordList")
            }
        }else {
            let recentlyKeywordList:Array<String> = [keyword]
            UserDefaults.standard.set(recentlyKeywordList, forKey: "recentlyKeywordList")
        }
    }

    func recentlyKeywordListSetting() {
        tableOrNullWrapInit()
        //내장 DB에 있는 최근검색어리스트를 초기화
        if let list = UserDefaults.standard.stringArray(forKey: "recentlyKeywordList") ?? [String](){
            if list.count > 0 {
                recentlyIsNullWrap.isHidden = true
                recentlyKeywordWrap.isHidden = false
            }else {
                recentlyIsNullWrap.isHidden = false
                recentlyKeywordWrap.isHidden = true
            }
            recentlyKeywordList.accept(list)
        }else {
            recentlyIsNullWrap.isHidden = false
            recentlyKeywordWrap.isHidden = true
        }
    }
    
    func alcoholListDataSetting(alcohol:[AlcoholList]) {
        var list:[AlcoholList] = alcoholList.value
        for a in alcohol {
            if let alcoholId:String = a.alcoholId {
                if !alcoholIdList.contains(alcoholId){
                    alcoholIdList.append(alcoholId)
                    list.append(a)
                }
            }
        }
        
        alcoholList.accept(list)
        if list.count == 0 {
            alcoholKeywordIsNullGL.text = "'\(alcoholSearchKeyword)' 에 대한 검색결과가 없습니다."
            statusMSGSetting()
        }else {
            sizeCheckGL.text = alcoholSearchKeyword
            let size = sizeCheckGL.attributedText!.size()
            let width = size.width
            if longKeywordGL.frame.width < width {
                longKeywordGL.text = "\"" + alcoholSearchKeyword
                longKeywordListCntGL.text = "\" 관련해서 총\(alcoholList.value.count) 개의 상품을 찾았습니다."
                longKeywordWrap.isHidden = false
                shortKeywordWrap.isHidden = true
            }else {
                shortKeywordGL.text = "\"" + alcoholSearchKeyword + "\" 관련해서 총 \(alcoholList.value.count) 개의 상품을 찾았습니다."
                longKeywordWrap.isHidden = true
                shortKeywordWrap.isHidden = false
            }
            tableTitleGL.isHidden = true
            recentlyKeywordSetting(keyword: alcoholSearchKeyword)
        }
    }
    
    //뒤로가기
    func backEvent() {
        navigationController?.popViewController(animated: true)
    }
 
    //키워드 좋아요 , 좋아요 취소처리
    @objc func alcoholLike(_ gesture: SearchMainVCTapGesture) {
        let aId:String = gesture.alcoholId
        let isLiked:Bool = gesture.alcoholIsLike
        
        if let reactor = reactor {
            let pathParams = [
                "alcoholId":aId
            ]
            alcoholId = aId
            
            print(isLiked)
            if isLiked {
                reactor.action.onNext(.alcoholLikeOff(pathParams))
            }else {
                reactor.action.onNext(.alcoholLikeOn(pathParams))
            }
            
        }
    }
    
    //주류 좋아요 후 UI처리 이벤트
    func alcoholLikeAfterEvent() {
        var alcoholDummyList = alcoholList.value
        var index:Int = 0
        for alcohol in alcoholDummyList {
            let aId = alcohol.alcoholId
            let likeCnt:Int = alcohol.likeCount ?? 0
            let isLike:Bool = alcohol.isLiked ?? false
            if aId == alcoholId {
                if isLike {
                    alcoholDummyList[index].likeCount = (likeCnt - 1)
                }else {
                    alcoholDummyList[index].likeCount = (likeCnt + 1)
                }
                alcoholDummyList[index].isLiked = !isLike
                break
            }
            index += 1
        }
        alcoholList.accept(alcoholDummyList)
    }
    
    //검색 결과 없을 때 문구 부분 문구 및 폰트 변경
    func statusMSGSetting() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        
        let color:CGColor = UIColor(red: 123/255, green: 123/255, blue: 123/255, alpha: 1).cgColor
        
        let attributedString = NSMutableAttributedString(string: alcoholKeywordIsNullGL.text!)
        let fontSize = UIFont(name: "AppleSDGothicNeo-Medium", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)
        
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, alcoholKeywordIsNullGL.text?.count ?? 0))
        
        attributedString.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String), value: fontSize, range: (alcoholKeywordIsNullGL.text! as NSString).range(of: "에 대한 검색결과가 없습니다."))
        
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: (alcoholKeywordIsNullGL.text! as NSString).range(of:"에 대한 검색결과가 없습니다."))
        
        alcoholKeywordIsNullGL.attributedText = attributedString
        alcoholKeywordIsNullGL.textAlignment = .center
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

//메인화면 전용 탭 제스처 공용 class
class SearchMainVCTapGesture: UITapGestureRecognizer {
    //주류 아이디
    var alcoholId:String = String()
    var alcoholIsLike:Bool = Bool()
}
