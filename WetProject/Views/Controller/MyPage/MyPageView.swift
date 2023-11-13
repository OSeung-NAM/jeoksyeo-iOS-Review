//
//  MyPageView.swift
//  WetProject
//
//  Created by 남오승 on 2021/01/08.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
//webp이미지 로드하기위한 플러그인
import Nuke
import NukeWebPPlugin

//마이페이지 화면 전용 View (SnapKit 라이브러리를 활용하여 소스로만 구성되어 있음.
class MyPageView: BaseView {

    lazy var logoutSummaryWrap:UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    lazy var logoutProfileImageWrap:UIView = {
        let view = UIView()
        return view
    }()
    lazy var logoutProfileImage:UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "myPageDefaultProfile")
        return image
    }()
    lazy var logoutGL:UILabel = {
        let label = UILabel()
        label.text = "로그인 해주세요!"
        label.colorSetting(r: 112, g: 112, b: 112, alpha: 1)
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16.0)
        label.textAlignment = .left
        return label
    }()
    lazy var logoutStatusGL:UILabel = {
        let label = UILabel()
        label.text = "비회원"
        label.colorSetting(r: 0, g: 0, b: 0, alpha: 1)
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 30)
        label.textAlignment = .left
        return label
    }()
    
    lazy var loginSummaryWrap:UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    lazy var loginProfileImageWrap:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.shadow(opacity: 0.2, radius: 2, offset: CGSize(width: 2, height: 2),color: UIColor(red: 143/255, green: 143/255, blue: 143/255, alpha: 1).cgColor)
        view.layer.masksToBounds = true
        return view
    }()
    lazy var loginProfileImage:UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "myPageDefaultProfile")
        image.contentMode = .scaleAspectFill
        return image
    }()
    lazy var loginGL:UILabel = {
        let label = UILabel()
        label.text = "Level. 1  마시는 척 하는 사람"
        label.colorSetting(r: 253, g: 177, b: 75, alpha: 1)
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16.0)
        label.textAlignment = .left
        return label
    }()
    lazy var loginUserNameGL:UILabel = {
        let label = UILabel()
        label.text = ""
        label.colorSetting(r: 0, g: 0, b: 0, alpha: 1)
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 30)
        label.textAlignment = .left
        return label
    }()
    lazy var summaryBottom:UIView = {
        let view = UIView()
        view.setBackgroundColor(r: 240, g: 240, b: 240, alpha: 1)
        return view
    }()
    lazy var contentsScrollViewWrap:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.setBackgroundColor(r: 247, g: 247, b: 247, alpha: 1)
        return scrollView
    }()
    lazy var settingWrap:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.tag = 0
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(menuEvent(_:))))
        return view
    }()
    lazy var settingGL:UILabel = {
        let label = UILabel()
        label.text = "설정"
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 20)
        label.colorSetting(r: 0, g: 0, b: 0, alpha: 1)
        return label
    }()
    lazy var settingRightImage:UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "rightYellow")
        return image
    }()
    lazy var settingBottom:UIView = {
        let view = UIView()
        view.setBackgroundColor(r: 240, g: 240, b: 240, alpha: 1)
        return view
    }()
    lazy var journalWrap:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    lazy var journalGL:UILabel = {
        let label = UILabel()
        label.text = "테이스트 저널"
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 20)
        label.colorSetting(r: 0, g: 0, b: 0, alpha: 1)
        return label
    }()
    lazy var journalBottom:UIView = {
        let view = UIView()
        view.setBackgroundColor(r: 240, g: 240, b: 240, alpha: 1)
        return view
    }()
    lazy var reviewWrap:UIView = {
        let view = UIView()
        view.tag = 1
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(menuEvent(_:))))
        view.backgroundColor = .white
        return view
    }()
    lazy var reviewGL:UILabel = {
        let label = UILabel()
        label.text = "내가 평가한 주류"
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 16)
        label.colorSetting(r: 51, g: 51, b: 51, alpha: 1)
        return label
    }()
    lazy var reviewRightImage:UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "rightYellow")
        return image
    }()
    lazy var reviewBottom:UIView = {
        let view = UIView()
        view.setBackgroundColor(r: 240, g: 240, b: 240, alpha: 1)
        return view
    }()
    lazy var levelWrap:UIView = {
        let view = UIView()
        view.tag = 2
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(menuEvent(_:))))
        view.backgroundColor = .white
        return view
    }()
    lazy var levelGL:UILabel = {
        let label = UILabel()
        label.text = "나의 주류 레벨"
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 16)
        label.colorSetting(r: 51, g: 51, b: 51, alpha: 1)
        return label
    }()
    lazy var levelRightImage:UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "rightYellow")
        return image
    }()
    lazy var levelBottom:UIView = {
        let view = UIView()
        view.setBackgroundColor(r: 240, g: 240, b: 240, alpha: 1)
        return view
    }()
    lazy var bookmarkWrap:UIView = {
        let view = UIView()
        view.tag = 3
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(menuEvent(_:))))
        view.backgroundColor = .white
        return view
    }()
    lazy var bookmarkGL:UILabel = {
        let label = UILabel()
        label.text = "내가 찜한 주류"
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 16)
        label.colorSetting(r: 51, g: 51, b: 51, alpha: 1)
        return label
    }()
    lazy var bookmarkRightImage:UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "rightYellow")
        return image
    }()
    lazy var bookmarkBottom:UIView = {
        let view = UIView()
        view.setBackgroundColor(r: 240, g: 240, b: 240, alpha: 1)
        return view
    }()
    lazy var loginWrap:UIView = {
        let view = UIView()
        view.tag = 4
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(menuEvent(_:))))
        view.backgroundColor = .white
        return view
    }()
    lazy var loginEventGL:UILabel = {
        let label = UILabel()
        label.text = "로그인"
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 20)
        label.colorSetting(r: 51, g: 51, b: 51, alpha: 1)
        return label
    }()
    lazy var loginRightImage:UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "rightYellow")
        return image
    }()
    lazy var loginBottom:UIView = {
        let view = UIView()
        view.setBackgroundColor(r: 240, g: 240, b: 240, alpha: 1)
        return view
    }()
    lazy var contactUsWrap:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    lazy var contactUsGL:UILabel = {
        let label = UILabel()
        label.text = "Contact Us"
        label.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 20)
        label.colorSetting(r: 51, g: 51, b: 51, alpha: 1)
        return label
    }()
    lazy var contactUsBottom:UIView = {
        let view = UIView()
        view.setBackgroundColor(r: 240, g: 240, b: 240, alpha: 1)
        return view
    }()
    lazy var contactUsContentsWrap:UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    lazy var contactUsContectnGL:UILabel = {
        let label = UILabel()
        label.text = "help@jeoksyeo.com\nAM 10:00-PM 17:00 ( 점심시간 12:00-14:00 )\nDAYOFF ( 토일 공휴일 )"
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 12)
        label.setLinespace(spacing: 5)
        label.numberOfLines = 3
        label.colorSetting(r: 51, g: 51, b: 51, alpha: 1)
        
        return label
    }()

    //로그아웃 이벤트
    
    var isSettingEvent:BehaviorRelay<Bool> = BehaviorRelay.init(value: false)
    var isReviewEvent:BehaviorRelay<Bool> = BehaviorRelay.init(value: false)
    var isLevelEvent:BehaviorRelay<Bool> = BehaviorRelay.init(value: false)
    var isBookmarkEvent:BehaviorRelay<Bool> = BehaviorRelay.init(value: false)
    var isLogoutEvent:BehaviorRelay<Bool> = BehaviorRelay.init(value: false)
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        addContentView()
        autoLayout()
    }
    
    func addContentView() {
        addSubview(logoutSummaryWrap)
        addSubview(loginSummaryWrap)
        logoutSummaryWrap.addSubview(logoutProfileImageWrap)
        loginSummaryWrap.addSubview(loginProfileImageWrap)
        loginProfileImageWrap.addSubview(loginProfileImage)
        logoutProfileImageWrap.addSubview(logoutProfileImage)
        logoutSummaryWrap.addSubview(logoutGL)
        logoutSummaryWrap.addSubview(logoutStatusGL)
        loginSummaryWrap.addSubview(loginGL)
        loginSummaryWrap.addSubview(loginUserNameGL)
        addSubview(summaryBottom)
        addSubview(contentsScrollViewWrap)
        contentsScrollViewWrap.addSubview(settingWrap)
        settingWrap.addSubview(settingGL)
        settingWrap.addSubview(settingRightImage)
        settingWrap.addSubview(settingBottom)
        contentsScrollViewWrap.addSubview(journalWrap)
        journalWrap.addSubview(journalGL)
        journalWrap.addSubview(journalBottom)
        contentsScrollViewWrap.addSubview(reviewWrap)
        reviewWrap.addSubview(reviewGL)
        reviewWrap.addSubview(reviewRightImage)
        reviewWrap.addSubview(reviewBottom)
        contentsScrollViewWrap.addSubview(levelWrap)
        levelWrap.addSubview(levelGL)
        levelWrap.addSubview(levelRightImage)
        levelWrap.addSubview(levelBottom)
        contentsScrollViewWrap.addSubview(bookmarkWrap)
        bookmarkWrap.addSubview(bookmarkGL)
        bookmarkWrap.addSubview(bookmarkRightImage)
        bookmarkWrap.addSubview(bookmarkBottom)
        contentsScrollViewWrap.addSubview(loginWrap)
        loginWrap.addSubview(loginEventGL)
        loginWrap.addSubview(loginRightImage)
        loginWrap.addSubview(loginBottom)
        contentsScrollViewWrap.addSubview(contactUsWrap)
        contactUsWrap.addSubview(contactUsGL)
        contactUsWrap.addSubview(contactUsBottom)
        contentsScrollViewWrap.addSubview(contactUsContentsWrap)
        contactUsContentsWrap.addSubview(contactUsContectnGL)
    }
    
    func autoLayout() {
        /* 로그아웃 상태 서머리 영역 */
        logoutSummaryWrap.snp.makeConstraints{ make in
            let height = aspectRatio(standardSize: 127)
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalTo(0)
            make.height.equalTo(height)
        }
        logoutProfileImageWrap.snp.makeConstraints{ make in
            let width = aspectRatio(standardSize: 60)
            make.width.height.equalTo(width)
            make.leading.equalTo(16)
            make.centerY.equalToSuperview()
        }
        logoutProfileImage.snp.makeConstraints{ make in
            make.leading.top.trailing.bottom.equalToSuperview()
            make.centerY.centerX.equalToSuperview()
        }
        logoutGL.snp.makeConstraints{ make in
            let fontSize = aspectRatio(standardSize: 16)
            let height = aspectRatio(standardSize: 21)
            make.leading.equalTo(logoutProfileImageWrap.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            logoutGL.font = logoutGL.font.withSize(fontSize)
            make.height.equalTo(height)
            make.top.equalTo(logoutProfileImageWrap.snp.top)
        }
        logoutStatusGL.snp.makeConstraints{ make in
            let fontSize = aspectRatio(standardSize: 30)
            logoutStatusGL.font = logoutStatusGL.font.withSize(fontSize)
            make.leading.equalTo(logoutProfileImageWrap.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(logoutGL.snp.bottom)
            make.bottom.equalTo(logoutProfileImageWrap.snp.bottom)
        }
        /* */
        /* 로그인 상태 서머리 영역 */
        loginSummaryWrap.snp.makeConstraints{ make in
            let height = aspectRatio(standardSize: 127)
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalTo(0)
            make.height.equalTo(height)
        }
        loginProfileImageWrap.snp.makeConstraints{ make in
            let width = aspectRatio(standardSize: 60)
            make.width.height.equalTo(width)
            make.leading.equalTo(16)
            make.centerY.equalToSuperview()
            loginProfileImageWrap.layer.cornerRadius = width/2
        }
        loginProfileImage.snp.makeConstraints{ make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        loginGL.snp.makeConstraints{ make in
            let fontSize = aspectRatio(standardSize: 16)
            loginGL.font = loginGL.font.withSize(fontSize)
            make.top.equalTo(loginProfileImageWrap)
            make.leading.equalTo(loginProfileImageWrap.snp.trailing).offset(16)
            make.trailing.equalTo(-16)
        }
        loginUserNameGL.snp.makeConstraints{ make in
            let fontSize = aspectRatio(standardSize: 30)
            loginUserNameGL.font = loginUserNameGL.font.withSize(fontSize)
            make.top.equalTo(loginGL.snp.bottom)
            make.leading.trailing.equalTo(loginGL)
            make.bottom.equalTo(loginProfileImageWrap.snp.bottom)
        }
        /* */
        summaryBottom.snp.makeConstraints{ make in
            make.top.equalTo(logoutSummaryWrap.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0.8)
        }
        /* ContentsWrap */
        contentsScrollViewWrap.snp.makeConstraints{ make in
            make.top.equalTo(summaryBottom)
            make.leading.trailing.bottom.equalTo(safeAreaLayoutGuide)
        }
        /* */
        /* 설정 */
        settingWrap.snp.makeConstraints{ make in
            let height = aspectRatio(standardSize: 48)
            let topRatio = constraintRatio(direction: .top, standardSize: 20)
            make.top.equalTo(topRatio)
            make.leading.equalToSuperview()
            make.width.equalTo(currentViewSize.width)
            make.height.equalTo(height)
        }
        settingGL.snp.makeConstraints{ make in
            let fontSize = aspectRatio(standardSize: 20)
            settingGL.font = settingGL.font.withSize(fontSize)
            make.leading.equalTo(16)
            make.centerY.equalToSuperview()
        }
        settingRightImage.snp.makeConstraints{ make in
            let width = aspectRatio(standardSize: 24)
            make.width.height.equalTo(width)
            make.trailing.equalTo(-16)
            make.centerY.equalToSuperview()
        }
        settingBottom.snp.makeConstraints{ make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(0.8)
        }
        /* */
        /* 테이스트 저널 */
        journalWrap.snp.makeConstraints{ make in
            let height = aspectRatio(standardSize: 48)
            let topRatio = constraintRatio(direction: .top, standardSize: 20)
            make.leading.equalToSuperview()
            make.width.equalTo(currentViewSize.width)
            make.height.equalTo(height)
            make.top.equalTo(settingWrap.snp.bottom).offset(topRatio)
        }
        journalGL.snp.makeConstraints{ make in
            let fontSize = aspectRatio(standardSize: 20)
            journalGL.font = journalGL.font.withSize(fontSize)
            make.leading.equalTo(16)
            make.centerY.equalToSuperview()
        }
        journalBottom.snp.makeConstraints{ make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(0.8)
        }
        /* */
        /* 내가 평가한 주류 */
        reviewWrap.snp.makeConstraints{ make in
            let height = aspectRatio(standardSize: 48)
            make.leading.equalToSuperview()
            make.width.equalTo(currentViewSize.width)
            make.height.equalTo(height)
            make.top.equalTo(journalWrap.snp.bottom)
        }
        reviewGL.snp.makeConstraints{ make in
            let fontSize = aspectRatio(standardSize: 16)
            reviewGL.font = reviewGL.font.withSize(fontSize)
            make.leading.equalTo(16)
            make.centerY.equalToSuperview()
        }
        reviewRightImage.snp.makeConstraints{ make in
            let width = aspectRatio(standardSize: 24)
            make.width.height.equalTo(width)
            make.trailing.equalTo(-16)
            make.centerY.equalToSuperview()
        }
        reviewBottom.snp.makeConstraints{ make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(0.8)
        }
        /* */
        /* 나의 주류 레벨 */
        levelWrap.snp.makeConstraints{ make in
            let height = aspectRatio(standardSize: 48)
            make.leading.equalToSuperview()
            make.width.equalTo(currentViewSize.width)
            make.height.equalTo(height)
            make.top.equalTo(reviewWrap.snp.bottom)
        }
        levelGL.snp.makeConstraints{ make in
            let fontSize = aspectRatio(standardSize: 16)
            levelGL.font = levelGL.font.withSize(fontSize)
            make.leading.equalTo(16)
            make.centerY.equalToSuperview()
        }
        levelRightImage.snp.makeConstraints{ make in
            let width = aspectRatio(standardSize: 24)
            make.width.height.equalTo(width)
            make.trailing.equalTo(-16)
            make.centerY.equalToSuperview()
        }
        levelBottom.snp.makeConstraints{ make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(0.8)
        }
        /* */
        /* 내가 찜한 주류 */
        bookmarkWrap.snp.makeConstraints{ make in
            let height = aspectRatio(standardSize: 48)
            make.leading.equalToSuperview()
            make.width.equalTo(currentViewSize.width)
            make.height.equalTo(height)
            make.top.equalTo(levelWrap.snp.bottom)
        }
        bookmarkGL.snp.makeConstraints{ make in
            let fontSize = aspectRatio(standardSize: 16)
            bookmarkGL.font = bookmarkGL.font.withSize(fontSize)
            make.leading.equalTo(16)
            make.centerY.equalToSuperview()
        }
        bookmarkRightImage.snp.makeConstraints{ make in
            let width = aspectRatio(standardSize: 24)
            make.width.height.equalTo(width)
            make.trailing.equalTo(-16)
            make.centerY.equalToSuperview()
        }
        bookmarkBottom.snp.makeConstraints{ make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(0.8)
        }
        /* */
        /* 로그인 */
        loginWrap.snp.makeConstraints{ make in
            let height = aspectRatio(standardSize: 48)
            let topRatio = constraintRatio(direction: .top, standardSize: 20)
            make.top.equalTo(bookmarkWrap.snp.bottom).offset(topRatio)
            make.leading.equalToSuperview()
            make.width.equalTo(currentViewSize.width)
            make.height.equalTo(height)
        }
        loginEventGL.snp.makeConstraints{ make in
            let fontSize = aspectRatio(standardSize: 20)
            loginEventGL.font = loginEventGL.font.withSize(fontSize)
            make.leading.equalTo(16)
            make.centerY.equalToSuperview()
        }
        loginRightImage.snp.makeConstraints{ make in
            let width = aspectRatio(standardSize: 24)
            make.width.height.equalTo(width)
            make.trailing.equalTo(-16)
            make.centerY.equalToSuperview()
        }
        loginBottom.snp.makeConstraints{ make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(0.8)
        }
        /* */
        /* Contact Us*/
        contactUsWrap.snp.makeConstraints{ make in
            let height = aspectRatio(standardSize: 48)
            let topRatio = constraintRatio(direction: .top, standardSize: 20)
            make.top.equalTo(loginWrap.snp.bottom).offset(topRatio)
            make.leading.equalToSuperview()
            make.width.equalTo(currentViewSize.width)
            make.height.equalTo(height)
        }
        contactUsGL.snp.makeConstraints{ make in
            let fontSize = aspectRatio(standardSize: 20)
            contactUsGL.font = contactUsGL.font.withSize(fontSize)
            make.leading.equalTo(16)
            make.centerY.equalToSuperview()
        }
        contactUsBottom.snp.makeConstraints{ make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(0.8)
        }
        contactUsContentsWrap.snp.makeConstraints{ make in
            let height = aspectRatio(standardSize: 76)
            make.top.equalTo(contactUsWrap.snp.bottom).offset(1)
            make.leading.bottom.equalToSuperview()
            make.width.equalTo(currentViewSize.width)
            make.height.equalTo(height)
        }
        contactUsContectnGL.snp.makeConstraints{ make in
            let fontSize = aspectRatio(standardSize: 12)
            contactUsContectnGL.font = contactUsContectnGL.font.withSize(fontSize)
            make.leading.equalTo(16)
            make.centerY.equalToSuperview()
        }
        /* */
    }
    
    @objc func menuEvent(_ gesture:UITapGestureRecognizer){
        let view = gesture.view
        let tag = view?.tag

        switch tag {
        case 0:
            isSettingEvent.accept(true)
            break
        case 1:
            isReviewEvent.accept(true)
            break
        case 2:
            isLevelEvent.accept(true)
            break
        case 3:
            isBookmarkEvent.accept(true)
            break
        case 4:
            isLogoutEvent.accept(true)
            break
        default:
            break
        }
    }
    
    //내 정보 이미지 세팅
    func myProfileImageSetting(url:String) {
        if url.count > 0 {
            let webpimageURL = URL(string: url)!
            Nuke.loadImage(with: webpimageURL, into: loginProfileImage)
            
            WebPImageDecoder.enable()
        }else {
            loginProfileImage.image = UIImage(named: "myPageDefaultProfile")
        }
    }
    //내 레벨 세팅
    func myLevelSetting(level:Int) {
        switch level {
        case 1:
            loginGL.text = "Level. 1  마시는 척 하는 사람"
            break
        case 2:
            loginGL.text = "Level. 2  술을 즐기는 사람"
            break
        case 3:
            loginGL.text = "Level. 3  술독에 빠진 사람"
            break
        case 4:
            loginGL.text = "Level. 4  주도를 수련하는 사람"
            break
        case 5:
            loginGL.text = "Level. 5  술로 해탈한 사람"
            break
        default:
            loginGL.text = "Level. 1  마시는 척 하는 사람"
            break
        }
    }
}

