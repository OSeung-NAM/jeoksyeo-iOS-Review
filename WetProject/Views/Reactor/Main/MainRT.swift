//
//  MainRT.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/29.
//

import ReactorKit
import RxSwift

//메인화면 관련 ReactorKit 아키텍쳐 파일(메인화면 배너, 주류추천, 주류랭킹, 주류 좋아요, 토큰 갱신 서비스 컨트롤)
final class MainRT: Reactor {
    
    fileprivate let mainBannerService: MainBannerService
    fileprivate let mainRecommendService: MainRecommendService
    fileprivate let mainAlcoholRankService: MainAlcoholRankService
    fileprivate let alcoholLikeService: AlcoholLikeService
    fileprivate let tokenRenewalService: TokenRenewalService
    
    var disposeBag = DisposeBag()
    
    struct TokenRenewal {
        var pathParams:[String:String]?
        var accessToken:String?
        var eventIndex:Int
        var saveFlag:Bool?
    }
    
    enum Action {
        case main
        case alcoholLikeOn([String:String]?)
        case alcoholLikeOff([String:String]?)
        case accessTokenSave(TokenRenewal?)
        case timeOutReset
    }
    
    enum Mutation {
        case setBanner([MainBanner]?)
        case setRecommend([MainRecommendAlcoholList]?)
        case setRank([AlcoholList]?)
        case setAlcoholLikeOn(Bool?)
        case setAlcoholLikeOff(Bool?)
        case setTokenRenewal(TokenRenewal?)
        case setAccessTokenSave(TokenRenewal?)
        case setLogin(Bool?)
        case setErrors(Bool?,Int?)
        case setTokenError(Bool?,TokenRenewal?)
        case setIndicator(Bool?)
        case setTimeOut(Bool?)
    }
    
    // State is a current view state(상태관리)
    struct State {
        var isBanner: ([MainBanner]?)
        var isRecommend: ([MainRecommendAlcoholList]?)
        var isRank: ([AlcoholList]?)
        var isAlcoholLikeOn: Bool?
        var isAlcoholLikeOff: Bool?
        var isTokenRenewal: (TokenRenewal?)
        var isAccessTokenSave: (TokenRenewal?)
        var isLogin: (Bool?)
        var isErrors: (Bool?,Int?)
        var isTokenError: (Bool?,TokenRenewal?)
        var isIndicator:Bool?
        var isTimeOut:Bool?
    }
    
    let initialState: State
    
    init() {
        self.initialState = State()
        mainBannerService = MainBannerService()
        mainRecommendService = MainRecommendService()
        mainAlcoholRankService = MainAlcoholRankService()
        alcoholLikeService = AlcoholLikeService()
        tokenRenewalService = TokenRenewalService()
    }
    
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .timeOutReset:
            return Observable.just(Mutation.setTimeOut(false))
        case .main: //배너, 주류추천, 주류랭킹은 로그인 한해도 되기 때문에 로그인 안함 여부 체크 안함
            if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(accessToken: result ,eventIndex: 0)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)), //재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false)) //갱신 후
                ])
            }else { //토큰 정상
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    getBanner()
                        .map{ result in
                            if result.errors == nil {
                                return Mutation.setBanner(result.data?.banner)
                            }else {
                                if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                    return Mutation.setTokenError(true, TokenRenewal(eventIndex:0))
                                }else {
                                    return Mutation.setErrors(true, 0)
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    getRecommend()
                        .map{ result in
                            if result.errors == nil {
                                return Mutation.setRecommend(result.data?.alcoholList)
                            }else {
                                if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                    return Mutation.setTokenError(true, TokenRenewal(eventIndex:0))
                                }else {
                                    return Mutation.setErrors(true, 0)
                                }
                            }
                        },
                    getRank()
                        .map{ result in
                            if result.errors == nil {
                                return Mutation.setRank(result.data?.alcoholList)
                            }else {
                                if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                    return Mutation.setTokenError(true, TokenRenewal(eventIndex:0))
                                }else {
                                    return Mutation.setErrors(true, 0)
                                }
                            }
                        },
                    Observable.just(Mutation.setBanner(nil)), //재호출 방지를 위해 nil 처리
                    Observable.just(Mutation.setRecommend(nil)),//재호출 방지를 위해 nil 처리
                    Observable.just(Mutation.setRank(nil)),//재호출 방지를 위해 nil 처리
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setErrors(false, nil)),
                    Observable.just(Mutation.setTokenError(false, nil)),
                ])
            }
        case let .alcoholLikeOn(pathParams: pathParams) :
            if tokenState() == 0 { //로그인 여부 체크
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    Observable.just(Mutation.setLogin(false)), //로그인 플래그 처리
                    Observable.just(Mutation.setLogin(nil)) //초기화
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(pathParams:pathParams,accessToken: result ,eventIndex: 1)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)), //재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false)) //갱신 후
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                    alcoholLike(pathParams: pathParams, flag: true)
                        .map{ result in
                            if result.errors == nil {
                                return Mutation.setAlcoholLikeOn(true)
                            }else {
                                if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                    return Mutation.setTokenError(true, TokenRenewal(eventIndex:1))
                                }else {
                                    return Mutation.setErrors(true, 1)
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setAlcoholLikeOn(false)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setErrors(false, nil)),
                    Observable.just(Mutation.setTokenError(false, nil)),
                    Observable.just(Mutation.setIndicator(false))
                ])
            }
        case let .alcoholLikeOff(pathParams):
            if tokenState() == 0 { //로그인 여부 체크
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    Observable.just(Mutation.setLogin(false)), //로그인 플래그 처리
                    Observable.just(Mutation.setLogin(nil)) //초기화
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(pathParams:pathParams,accessToken: result ,eventIndex: 2)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)),//재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false)) //갱신 후
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                    alcoholLike(pathParams: pathParams, flag: false)
                        .map{ result in
                            if result.errors == nil {
                                return Mutation.setAlcoholLikeOff(true)
                            }else {
                                if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                    return Mutation.setTokenError(true, TokenRenewal(eventIndex:2))
                                }else {
                                    return Mutation.setErrors(true, 2)
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setAlcoholLikeOff(false)),
                    Observable.just(Mutation.setTimeOut(false)),      
                    Observable.just(Mutation.setErrors(false, nil)),
                    Observable.just(Mutation.setTokenError(false, nil)),
                    Observable.just(Mutation.setIndicator(false))
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
        case let .setBanner(banner):
            state.isBanner = banner
        case let .setRecommend(recommend) :
            state.isRecommend = recommend
        case let .setRank(rank) :
            state.isRank = rank
        case let .setAlcoholLikeOn(SuccessRPModel) :
            state.isAlcoholLikeOn = SuccessRPModel
        case let .setAlcoholLikeOff(SuccessRPModel) :
            state.isAlcoholLikeOff = SuccessRPModel
        case let .setTokenRenewal(tokenRenewal) :
            state.isTokenRenewal = tokenRenewal
        case let .setAccessTokenSave(tokenRenewal) :
            state.isAccessTokenSave = tokenRenewal
        case let .setLogin(flag) :
            state.isLogin = flag
        case let .setErrors(flag,eventIndex) :
            state.isErrors = (flag,eventIndex)
        case let .setTokenError(flag, tokenRenewal) :
            state.isTokenError = (flag, tokenRenewal)
        case let .setIndicator(flag) :
            state.isIndicator = flag
        case let .setTimeOut(flag) :
            state.isTimeOut = flag
        }
        
        return state
    }
  
    //배너 조회
    func getBanner() -> Observable<MainBannerRPModel> {
        return mainBannerService.getMainBanner(params: nil)
    }
    
    //주류 추천 조회
    func getRecommend() -> Observable<MainRecommendRPModel> {
        return mainRecommendService.getMainRecommend(params: nil)
    }
    
    //주류 랭킹 조회
    func getRank() -> Observable<MainAlcoholRankRPModel> {
        return mainAlcoholRankService.getMainAlcoholRank(params: nil)
    }
    
    //주류 좋아요 관리
    func alcoholLike(pathParams:[String:String]?,flag:Bool) -> Observable<SuccessRPModel> {
        return alcoholLikeService.setAlcoholLike(params: nil, pathParams: pathParams!, flag: flag)
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
