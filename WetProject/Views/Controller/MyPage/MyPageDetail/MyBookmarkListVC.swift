//
//  MyBookmarkListVC.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/16.
//

import UIKit
import SideMenu
import ReactorKit
import RxSwift
//webp이미지 로드하기위한 플러그인
import Nuke
import NukeWebPPlugin

//내가 찜한 주류 리스트 화면 UI를 컨트롤 하기위한 파일
class MyBookmarkListVC: BaseViewController, StoryboardView {
    
    @IBOutlet weak var titleBackgroundWrap: UIView!
    @IBOutlet weak var titleWrap: UIView!
    @IBOutlet weak var backBtn: UIButton!
    
    let myBookmarkListRT = MyBookmarkListRT()
    
    @IBOutlet weak var defaultProfileImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nickNameGL: UILabel!
    @IBOutlet weak var bookmarkCntGL: UILabel!
    @IBOutlet weak var categoryNameGL: UILabel!
    @IBOutlet weak var categoryCntGL: UILabel!
    @IBOutlet weak var profileImageWrap: UIView!
    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var traditionBtn: UIButton!
    @IBOutlet weak var beerBtn: UIButton!
    @IBOutlet weak var wineBtn: UIButton!
    @IBOutlet weak var liquorBtn: UIButton!
    @IBOutlet weak var sakeBtn: UIButton!
    
    @IBOutlet weak var bookmarkCV: UICollectionView!
    @IBOutlet weak var categoryBottomLine: UIView!
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
    
    
    @IBOutlet weak var bookmarkMainWrap: UIView!
    @IBOutlet weak var noBookmarkListWrap: UIView!
    
    //현재 선택한 카테고리
    var currentCatecory:Int = 0
    var currentLikeAlcoholId:String = String()

    var bookmarkList:[AlcoholList] = []
    var alcoholIdList:[String] = []
    
    var isPaging = false
    var pagingInfo:PagingInfo?
    
    var bookmarkTotalCnt:Int = 0
    var categoryTotalCnt:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        bookmarkCV.delegate = self
        bookmarkCV.dataSource = self
        
        bookmarkCV.backgroundColor = .clear
        //일시적으로 constraint(관계) 끊어줌 - 카테고리 선택할때마다 라인 움직여야함
        categoryBottomLine.translatesAutoresizingMaskIntoConstraints = true
        profileImageWrap.layer.cornerRadius = 32.5
        profileImageWrap.shadow(opacity: 0.1, radius: 1, offset: CGSize(width: 1, height: 1), color: UIColor(red: 143/255, green: 143/255, blue: 143/255, alpha: 1).cgColor)
        
        profileImage.layer.cornerRadius = 32.5
        bookmarkMainWrap.layer.cornerRadius = 20.0
        bookmarkMainWrap.shadow(opacity: 0.13, radius: 3, offset: CGSize(width: -2, height: -3), color: UIColor(red: 234/255, green: 149/255, blue: 35/255, alpha: 1).cgColor)
        
        bookmarkCV.register(UINib(nibName: "MyBookmarkGridCell", bundle: nil), forCellWithReuseIdentifier: "MyBookmarkGridCell")
        
        titleWrap?.topAnchor.constraint(equalTo: titleBackgroundWrap.topAnchor,constant:getStatusBarHeight()).isActive = true
        reactor = myBookmarkListRT
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
    }

    func bind(reactor: MyBookmarkListRT) {
        
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
        
        bookmarkCV.rx.contentOffset
            .subscribe(onNext:{ [weak self] _ in
                let height: CGFloat = self?.bookmarkCV.frame.size.height ?? 0.0
                let contentYOffset: CGFloat = self?.bookmarkCV.contentOffset.y ?? 0.0
                let scrollViewHeight: CGFloat = self?.bookmarkCV.contentSize.height ?? 0.0
                let distanceFromBottom: CGFloat = scrollViewHeight - contentYOffset
                

                if distanceFromBottom < height {
                    let nextFlag = self?.pagingInfo?.next ?? false
                    
                    let currentPage = self?.pagingInfo?.page ?? 1
                    
                    
                    if !(self?.isPaging ?? false) {
                        self?.isPaging = true
                        if nextFlag {
                            let params = MyReviewListRQModel(f: self?.apiCallCategory() ?? "ALL", c: 20, p: currentPage + 1)
                            reactor.action.onNext(.bookmarkList(params))
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
        
        let isBookmarkList = reactor.state.map{$0.isBookmarkList?.alcoholList}.filter{$0 != nil}.map{$0 ?? []}
        let isSummaryInfo = reactor.state.map{$0.isBookmarkList?.summary}.filter{$0 != nil}
        let isPagingInfo = reactor.state.map{$0.isBookmarkList?.pagingInfo}.filter{$0 != nil}
        let isAlcoholLikeOn = reactor.state.map{$0.isAlcoholLikeOn}.filter{$0 != nil}
        let isAlcoholLikeOff = reactor.state.map{$0.isAlcoholLikeOff}.filter{$0 != nil}
        
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
                if result.1 == 1 { //중복 주류 좋아요 에러
                    self?.netWorkStateToast(errorIndex: 3)
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
            }
        }.disposed(by: disposeBag)
        
        isSummaryInfo.map{"총 " + String($0?.alcoholLikeCount ?? 0) + "개의 주류를 찜하셨습니다."}.bind(to: bookmarkCntGL.rx.text).disposed(by: disposeBag)
        isSummaryInfo.map{($0?.nickname ?? "") + "님,"}.bind(to: nickNameGL.rx.text).disposed(by: disposeBag)
        isSummaryInfo.bind{[weak self] result in
            if (result?.profile?.count ?? 0) > 0 {
                let profileImageUrl:String = result?.profile?[0].mediaResource?.medium?.src ?? ""
                self?.profileImageSetting(urlString: profileImageUrl)
            }
            self?.bookmarkTotalCnt = result?.alcoholLikeCount ?? 0
        }.disposed(by: disposeBag)
        
        isBookmarkList
            .bind{[weak self] result in
                self?.bookmarkListSetting(bookmark: result)
            }.disposed(by: disposeBag)
        
        let isIndicator = reactor.state.map{$0.isIndecator}.filter{$0 != nil}

        isPagingInfo.bind{[weak self] result in
            self?.isPaging = false
            self?.pagingInfo = result
            self?.categoryCntGL.text = "총 " + String(result?.alcoholTotalCount ?? 0) + "개의 주류를 찜하셨습니다"
            self?.categoryTotalCnt = result?.alcoholTotalCount ?? 0
        }.disposed(by: disposeBag)
        
        isAlcoholLikeOn.bind{ [weak self] result in
            if result ?? false{
                self?.bookmarkAfterEvent()
            }
        }.disposed(by: disposeBag)
        
        isAlcoholLikeOff.bind{[weak self] result in
            if result ?? false {
                self?.bookmarkAfterEvent()
            }
        }.disposed(by: disposeBag)
        
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
                    if result?.eventIndex == 0 { //찜한 주류 리스트 조회
                        reactor.action.onNext(.bookmarkList(result?.params))
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
    
    //좋아요, 좋아요 취소 후 좋아요 아이콘 관리 메소트
    func likeAfterReload(flag:Bool) {
        
        var index:Int = 0
        for list in bookmarkList {
            let alcoholId:String = list.alcoholId ?? ""
            if alcoholId == currentLikeAlcoholId {
                let isLiked:Bool = list.isLiked ?? true
                let likeCnt:Int = list.likeCount ?? 0
                bookmarkList[index].isLiked = !isLiked
                
                if flag {
                    bookmarkList[index].likeCount = likeCnt+1
                }else {
                    bookmarkList[index].likeCount = likeCnt-1
                }
            }
            
            index += 1
        }
        bookmarkCV.reloadData()
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
            categoryNameGL.text = "전체"
            allToTopWrap.isHidden = false
            params.f = "ALL"
        }else if categoryIndex == 1 { //전통주
            traditionBtn.setTitleColor(UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1), for: .normal)
            UIView.animate(withDuration: 0.2) { [self] in
                categoryBottomLine.frame = CGRect(x:traditionBtn.frame.origin.x, y: traditionBtn.frame.height - 2.0, width:traditionBtn.frame.width, height:2.0)
                categoryBottomLine.frame.origin.x = traditionBtn.frame.origin.x
            }
            categoryNameGL.text = "전통주"
            trToTopWrap.isHidden = false
            params.f = "TR"
        }else if categoryIndex == 2 { //맥주
            self.beerBtn.setTitleColor(UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1), for: .normal)
            UIView.animate(withDuration: 0.2) { [self] in
                self.categoryBottomLine.frame = CGRect(x:beerBtn.frame.origin.x, y: beerBtn.frame.height - 2.0, width:beerBtn.frame.width, height:2.0)
                self.categoryBottomLine.frame.origin.x = beerBtn.frame.origin.x
            }
            categoryNameGL.text = "맥주"
            beToTopWrap.isHidden = false
            params.f = "BE"
        }else if categoryIndex == 3 { //와인
            self.wineBtn.setTitleColor(UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1), for: .normal)
            UIView.animate(withDuration: 0.2) { [self] in
                categoryBottomLine.frame = CGRect(x:wineBtn.frame.origin.x, y: wineBtn.frame.height - 2.0, width:wineBtn.frame.width, height:2.0)
                categoryBottomLine.frame.origin.x = wineBtn.frame.origin.x
            }
            categoryNameGL.text = "와인"
            wiToTopWrap.isHidden = false
            params.f = "WI"
        }else if categoryIndex == 4 { //양주
            self.liquorBtn.setTitleColor(UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1), for: .normal)
            UIView.animate(withDuration: 0.2) { [self] in
                categoryBottomLine.frame = CGRect(x:liquorBtn.frame.origin.x, y: liquorBtn.frame.height - 2.0, width:liquorBtn.frame.width, height:2.0)
                categoryBottomLine.frame.origin.x = liquorBtn.frame.origin.x
            }
            categoryNameGL.text = "양주"
            liToTopWrap.isHidden = false
            params.f = "FO"
        }else { //사케
            sakeBtn.setTitleColor(UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1), for: .normal)
            UIView.animate(withDuration: 0.2) { [self] in
                categoryBottomLine.frame = CGRect(x:sakeBtn.frame.origin.x, y: sakeBtn.frame.height - 2.0, width:sakeBtn.frame.width, height:2.0)
                categoryBottomLine.frame.origin.x = sakeBtn.frame.origin.x
            }
            categoryNameGL.text = "사케"
            saToTopWrap.isHidden = false
            params.f = "SA"
        }
        
        bookmarkList = []
        alcoholIdList = []
        bookmarkCV.reloadData()
        if let reactor = reactor {
            reactor.action.onNext(.bookmarkList(params))
        }
    }
    
    //좋아요 관리 후 UI처리 이벤트
    func bookmarkAfterEvent(){
        var bookmarkDummyList = bookmarkList
        var index:Int = 0
        for b in bookmarkDummyList {
            let alcoholId:String = b.alcoholId ?? ""
            let isLiked:Bool = b.isLiked ?? true
            let likeCnt:Int = b.likeCount ?? 0
            if currentLikeAlcoholId == alcoholId {
                if isLiked {
                    bookmarkCntGL.text = "총 " + String(bookmarkTotalCnt - 1) + "개의 주류를 찜하셨습니다"
                    categoryCntGL.text = "총 " + String(categoryTotalCnt - 1) + "개의 주류를 찜하셨습니다"
                    bookmarkTotalCnt -= 1
                    categoryTotalCnt -= 1
                    bookmarkDummyList[index].likeCount = (likeCnt - 1)
                }else {
                    bookmarkCntGL.text = "총 " + String(bookmarkTotalCnt + 1) + "개의 주류를 찜하셨습니다"
                    categoryCntGL.text = "총 " + String(categoryTotalCnt + 1) + "개의 주류를 찜하셨습니다"
                    bookmarkTotalCnt += 1
                    categoryTotalCnt += 1
                    bookmarkDummyList[index].likeCount = (likeCnt + 1)
                }
                
                bookmarkDummyList[index].isLiked = !isLiked
                break
            }
            
            index += 1
        }
        
        bookmarkList = bookmarkDummyList
        bookmarkCV.reloadData()
    }
    
    func bookmarkListSetting(bookmark:[AlcoholList]) {
        
        for b in bookmark {
            if let alcoholId:String = b.alcoholId {
                if !alcoholIdList.contains(alcoholId) {
                    alcoholIdList.append(alcoholId)
                    bookmarkList.append(b)
                }
            }
        }
        bookmarkCV.reloadData()
    }

    //주류 좋아요 , 좋아요 취소 관리
    func alcoholLikeCtrl(flag:Bool) {
        if let reactor = self.reactor {
            let params = [
                "alcoholId" :  currentLikeAlcoholId
            ]
            
            if flag {
                reactor.action.onNext(.alcoholLikeOn(params))
            }else {
                reactor.action.onNext(.alcoholLikeOff(params))
            }
        }
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
    
    //summary Profile image 세팅
    func profileImageSetting(urlString: String) {
        if urlString.count > 0 {
            WebPImageDecoder.enable()
            let webpimageURL = URL(string: urlString)!
            Nuke.loadImage(with: webpimageURL, into: profileImage)
            profileImage.isHidden = false
        }else {
            profileImage.isHidden = true
        }
    }
    
    //뒤로가기
    func backEvent() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func likeTouchEvent(_ gesture: MyBookmarkListVCTapGesture) {
        let isLiked:Bool = gesture.alcoholLikeFlag
        let alcoholId:String = gesture.alcoholId
        
        currentLikeAlcoholId = alcoholId
        
        let pathParams = [
            "alcoholId" : alcoholId
        ]
        if let reactor = reactor {
            if isLiked {
                reactor.action.onNext(.alcoholLikeOff(pathParams))
            }else {
                reactor.action.onNext(.alcoholLikeOn(pathParams))
            }
        }
    }
    
    @objc func alcoholDetailMove(_ gesture: MyBookmarkListVCTapGesture) {
        let alcoholId:String = gesture.alcoholId
        let alcoholDetailVC = StoryBoardName.mainServiceStoryBoard.instantiateViewController(withIdentifier: "AlcoholDetailVC") as! AlcoholDetailVC

        alcoholDetailVC.alcoholId = alcoholId
        navigationController?.pushViewController(alcoholDetailVC, animated: true)
    }
    
    //테이블 스크롤 맨위로
    func tableScrollToTop() {
        if bookmarkList.count > 0 {
            bookmarkCV.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
}

extension MyBookmarkListVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if bookmarkList.count > 0 {
            noBookmarkListWrap.isHidden = true
        }else {
            noBookmarkListWrap.isHidden = false
        }
        return bookmarkList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myBookmarkGridCell : MyBookmarkGridCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "MyBookmarkGridCell", for: indexPath) as? MyBookmarkGridCell
        
        myBookmarkGridCell?.callingView = self as Any
        myBookmarkGridCell?.bookmarkList = bookmarkList
        myBookmarkGridCell?.dataSetting(indexPath: indexPath)
        myBookmarkGridCell?.likeCntWrap.tag = indexPath.row

        let myBookmarkListTap = MyBookmarkListVCTapGesture(target: self, action: #selector(likeTouchEvent(_:)))
        myBookmarkListTap.alcoholId = bookmarkList[indexPath.row].alcoholId ?? ""
        myBookmarkListTap.alcoholLikeFlag = bookmarkList[indexPath.row].isLiked ?? true
        myBookmarkGridCell?.likeCntWrap.addGestureRecognizer(myBookmarkListTap)
        
        let alcoholDetailTap = MyBookmarkListVCTapGesture(target: self, action: #selector(alcoholDetailMove(_:)))
        alcoholDetailTap.alcoholId = bookmarkList[indexPath.row].alcoholId ?? ""
        myBookmarkGridCell?.alcoholImageWrap.addGestureRecognizer(alcoholDetailTap)
     
        return myBookmarkGridCell!
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var width = CGFloat(0.0)
        var height = CGFloat(0.0)
        
        width = (collectionView.frame.width/2)
        height = width + 110.0
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

//내가 찜한 주류 전용 탭 제스처 공용 class
class MyBookmarkListVCTapGesture: UITapGestureRecognizer {
    /* 주류 관련 */
    //주류 아이디
    var alcoholId:String = String()
    //좋아요 여부
    var alcoholLikeFlag:Bool = Bool()
}
