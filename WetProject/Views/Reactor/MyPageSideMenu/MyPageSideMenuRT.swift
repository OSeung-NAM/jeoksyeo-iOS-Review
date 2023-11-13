//
//  MyPageSideMenuRT.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/10.
//

import ReactorKit
import RxSwift

//마이페이지 사이드메뉴 전용 ReactorKit 아키텍쳐 파일(내 정보 조회, 토큰 갱신 서비스 컨트롤)
final class MyPageSideMenuRT: Reactor {
    // Action is an user interaction
    
    fileprivate let myInfoService: MyInfoService
    fileprivate let tokenRenewalService: TokenRenewalService
    
    enum Action {
        case myInfo
        case setting
        case myReview
        case myLevel
        case myBookmark
        case accessTokenSave(String?,Int?)
    }
    
    // Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case setMyInfo(MyInfoRPModel?)
        case setSetting(Bool?)
        case setMyReview(Bool?)
        case setMyLevel(Bool?)
        case setMyBookmark(Bool?)
        case setTokenRenewal(String?,Int?)
        case setAccessTokenSave(Bool?,Int?)
        case setLogin(Bool?)
    }
    
    // State is a current view state(상태관리)
    struct State {
        var isMyInfo:MyInfoRPModel?
        var isSetting:Bool?
        var isMyReview:Bool?
        var isMyLevel:Bool?
        var isMyBookmark:Bool?
        var isTokenRenewal: (String?,Int?)
        var isAccessTokenSave: (Bool?,Int?)
        var isLogin: (Bool?)
    }
    
    var initialState: State
    
    init() {
        self.initialState = State()
        myInfoService = MyInfoService()
        tokenRenewalService = TokenRenewalService()
    }
    
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .myInfo:
            if tokenState() == 0 { //로그인 여부 체크
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    Observable.just(Mutation.setLogin(false)), //로그인 플래그 처리
                    Observable.just(Mutation.setLogin(nil)) //초기화
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{Mutation.setTokenRenewal($0,0)}, //갱신 후
                    Observable.just(Mutation.setTokenRenewal(nil, nil)) //재호출 방지를 위해 초기화
                ])
            }else { //토큰 정상
                return Observable.concat([
                    getMyInfo()
                        .map { Mutation.setMyInfo($0)},
                    Observable.just(Mutation.setMyInfo(nil))
                ])
            }
        case .setting:
            if tokenState() == 0 { //로그인 여부 체크
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    Observable.just(Mutation.setLogin(false)), //로그인 플래그 처리
                    Observable.just(Mutation.setLogin(nil)) //초기화
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{Mutation.setTokenRenewal($0,1)}, //갱신 후
                    Observable.just(Mutation.setTokenRenewal(nil, nil)) //재호출 방지를 위해 초기화
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setSetting(true)),
                    Observable.just(Mutation.setSetting(false))
                ])
            }
        case .myReview:
            if tokenState() == 0 { //로그인 여부 체크
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    Observable.just(Mutation.setLogin(false)), //로그인 플래그 처리
                    Observable.just(Mutation.setLogin(nil)) //초기화
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{Mutation.setTokenRenewal($0,2)}, //갱신 후
                    Observable.just(Mutation.setTokenRenewal(nil, nil)) //재호출 방지를 위해 초기화
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setMyReview(true)),
                    Observable.just(Mutation.setMyReview(false))
                ])
            }
        case .myLevel:
            if tokenState() == 0 { //로그인 여부 체크
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    Observable.just(Mutation.setLogin(false)), //로그인 플래그 처리
                    Observable.just(Mutation.setLogin(nil)) //초기화
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{Mutation.setTokenRenewal($0,3)}, //갱신 후
                    Observable.just(Mutation.setTokenRenewal(nil, nil)) //재호출 방지를 위해 초기화
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setMyLevel(true)),
                    Observable.just(Mutation.setMyLevel(false))
                ])
            }
        case .myBookmark:
            if tokenState() == 0 { //로그인 여부 체크
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    Observable.just(Mutation.setLogin(false)), //로그인 플래그 처리
                    Observable.just(Mutation.setLogin(nil)) //초기화
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{Mutation.setTokenRenewal($0,4)}, //갱신 후
                    Observable.just(Mutation.setTokenRenewal(nil, nil)) //재호출 방지를 위해 초기화
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setMyBookmark(true)),
                    Observable.just(Mutation.setMyBookmark(false))
                ])
            }
        case let .accessTokenSave(token,event): //토큰 저장
            return Observable.concat([ //contat : 배열 순서대로 Observable실행
                accessTokenSave(accessToken: token)
                    .map{Mutation.setAccessTokenSave($0,event)}, //저장 후
                Observable.just(Mutation.setAccessTokenSave(nil, nil)) //토큰저장 재호출 방지를 위해 초기화
            ])
        }
    }
    
    // Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setMyInfo(result):
            state.isMyInfo = result
        case let .setSetting(bool) :
            state.isSetting = bool
        case let .setMyReview(bool) :
            state.isMyReview = bool
        case let .setMyLevel(bool) :
            state.isMyLevel = bool
        case let .setMyBookmark(bool) :
            state.isMyBookmark = bool
        case let .setTokenRenewal(token,event) :
            state.isTokenRenewal = (token, event)
        case let .setAccessTokenSave(flag,event) :
            state.isAccessTokenSave = (flag,event)
        case let .setLogin(flag) :
            state.isLogin = flag
        
        }
        
        return state
    }
    
    
    //내 정보 조회
    func getMyInfo() -> Observable<MyInfoRPModel> {
        return myInfoService.getMyInfo()
    }

    //토큰 상태 체크
    func tokenState() -> Int {
        return TokenValidationCheck.shared.tokenValidationCheck()
    }
    
    //토큰 갱신
    func tokenRenewal() -> Observable<String> {
        return tokenRenewalService.tokenRenewal().map{$0.data?.token.accessToken ?? ""}
    }
    
    //토큰 갱신 후 저장
    func accessTokenSave(accessToken:String?) -> Observable<Bool> {
        if let accessToken = accessToken {
            UserDefaults.standard.setValue(accessToken, forKey: "accessToken")
            return Observable.just(true)
        }else {
            return Observable.just(false)
        }
    }
}
