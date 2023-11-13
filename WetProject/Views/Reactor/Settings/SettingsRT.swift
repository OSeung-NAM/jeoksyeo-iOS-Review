//
//  SettingsRT.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/13.
//

import ReactorKit
import RxSwift

//마이페이지 설정 화면 전용 ReactorKit 아키텍쳐 파일(앱 버전, 회원탈퇴, 토큰 갱신 서비스 컨트롤)
final class SettingsRT: Reactor {
    // Action is an user interaction
    
    fileprivate let appVersionService: AppVersionService
    fileprivate let userOutService: UserOutService
    fileprivate let tokenRenewalService: TokenRenewalService
    
    
    struct TokenRenewal {
        var accessToken:String?
        var eventIndex:Int
        var saveFlag:Bool?
    }
    
    enum Action {
        case appVersion
        case userOut
        case userUpdate
        case accessTokenSave(TokenRenewal?)
    }
    
    // Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case setAppVersion(AppVersionRPModelData?)
        case setUserUpdate(Bool?)
        case setUserOut(Bool?)
        case setTokenRenewal(TokenRenewal?)
        case setAccessTokenSave(TokenRenewal?)
        case setLogin(Bool?)
        case setIndicator(Bool?)
        case setErrors(Bool?,Int?)
        case setTokenError(Bool?,TokenRenewal?)
        case setTimeOut(Bool?)
    }
    
    // State is a current view state(상태관리)
    struct State {
        var isAppVerion: AppVersionRPModelData?
        var isUserUpdate : Bool?
        var isUserOut: Bool?
        var isTokenRenewal: (TokenRenewal?)
        var isAccessTokenSave: (TokenRenewal?)
        var isLogin: Bool?
        var isIndicator:Bool?
        var isErrors: (Bool?,Int?)
        var isTokenError: (Bool?,TokenRenewal?)
        var isTimeOut: Bool?
    }
    
    let initialState: State
    
    init() {
        self.initialState = State()
        appVersionService = AppVersionService()
        userOutService = UserOutService()
        tokenRenewalService = TokenRenewalService()
    }
    
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .appVersion:
            if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(accessToken: result ,eventIndex: 0)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)), //재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false)) //갱신 후
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                    getAppVersion()
                    .map{ result in
                        if result.errors == nil {
                            return Mutation.setAppVersion(result.data)
                        }else {
                            if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                return Mutation.setTokenError(true, TokenRenewal(eventIndex:0))
                            }else {
                                return Mutation.setErrors(true, 0)
                            }
                        }
                    }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                    .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setAppVersion(nil)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil)),
                    Observable.just(Mutation.setIndicator(false))
                ])
            }
        case .userOut: //회원 탈퇴
            if tokenState() == 0 { //로그인 여부 체크
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    Observable.just(Mutation.setLogin(false)), //로그인 플래그 처리
                    Observable.just(Mutation.setLogin(nil)) //초기화
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(accessToken: result ,eventIndex: 1)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)), //재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false)) //갱신 후
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                    deleteUser()
                    .map{ result in
                        if result.errors == nil {
                            return Mutation.setUserOut(true)
                        }else {
                            if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                return Mutation.setTokenError(true, TokenRenewal(eventIndex:1))
                            }else {
                                return Mutation.setErrors(true, 1)
                            }
                        }
                    }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setUserOut(false)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setIndicator(nil)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil)),
                ])
            }
        case .userUpdate:
            if tokenState() == 0 { //로그인 여부 체크
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    Observable.just(Mutation.setLogin(false)), //로그인 플래그 처리
                    Observable.just(Mutation.setLogin(nil)) //초기화
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(accessToken: result ,eventIndex: 2)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)), //재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false)) //갱신 후
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setUserUpdate(true)),
                    Observable.just(Mutation.setUserUpdate(nil)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil))
                ])
            }
        case var .accessTokenSave(tokenReviewal): //토큰 저장
            return Observable.concat([ //contat : 배열 순서대로 Observable실행
                accessTokenSave(accessToken: tokenReviewal?.accessToken)
                    .map{ result in
                        tokenReviewal?.saveFlag = result
                        return tokenReviewal
                    }
                    .map{Mutation.setAccessTokenSave($0)},  //저장 후 리턴
                Observable.just(Mutation.setAccessTokenSave(nil)) //토큰저장 재호출 방지를 위해 초기화
            ])
        }
    }
    
    // Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setAppVersion(appVersionRPModel):
            state.isAppVerion = appVersionRPModel
        case let .setUserUpdate(flag):
            state.isUserUpdate = flag
        case let .setUserOut(successRPModel) :
            state.isUserOut = successRPModel
        case let .setTokenRenewal(tokenRenewal) :
            state.isTokenRenewal = tokenRenewal
        case let .setAccessTokenSave(tokenRenewal) :
            state.isAccessTokenSave = tokenRenewal
        case let .setLogin(flag) :
            state.isLogin = flag
        case let .setIndicator(flag) :
            state.isIndicator = flag
        case let .setErrors(flag,eventIndex) :
            state.isErrors = (flag,eventIndex)
        case let .setTokenError(flag, tokenRenewal) :
            state.isTokenError = (flag, tokenRenewal)
        case let .setTimeOut(flag):
            state.isTimeOut = flag
        }
        
        return state
    }
    
    //앱 버전 조회
    func getAppVersion() -> Observable<AppVersionRPModel> {
        return appVersionService.getAppVersion()
    }
    
    //회원탈퇴
    func deleteUser() -> Observable<SuccessRPModel> {
        return userOutService.deleteUser()
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
