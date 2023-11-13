//
//  AlcoholSearchRT.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/16.
//

import ReactorKit
import RxSwift

//주류검색 관련 ReactorKit 아키텍쳐 파일(연관검색어, 주류 검색, 주류 좋아요, 주류 좋아요 취소, 토큰 갱신 서비스 컨트롤)
final class AlcoholSearchRT: Reactor {
    // Action is an user interaction
    
    fileprivate let keywordSearchService: KeywordSearchService
    fileprivate let alcoholSearchService: AlcoholSearchService
    fileprivate let alcoholLikeOnService: AlcoholLikeOnService
    fileprivate let alcoholLikeOffService: AlcoholLikeOffService
    fileprivate let tokenRenewalService: TokenRenewalService
    
    typealias keywordSearchRPModel = KeywordSearchRPModel
    typealias alcoholSearchRPModel = AlcoholSearchRPModel
    typealias successRPModel = SuccessRPModel
    
    struct TokenRenewal {
        var keywordParams:[String:Any]?
        var params:AlcoholSearchRQModel?
        var pathParams:[String:String]?
        var accessToken:String?
        var eventIndex:Int
        var saveFlag:Bool?
    }
    
    enum Action {
        case keywordSearch([String:Any]?)
        case alcoholSearch(AlcoholSearchRQModel?)
        case alcoholLikeOn([String:String]?)
        case alcoholLikeOff([String:String]?)
        case accessTokenSave(TokenRenewal?)
    }
    
    // Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case setKeywordSearch([String]?)
        case setAlcoholSearch(AlcoholSearchRPModelData?)
        case setAlcoholLikeOn(Bool?)
        case setAlcoholLikeOff(Bool?)
        case setIndicator(Bool?)
        case setTokenRenewal(TokenRenewal?)
        case setAccessTokenSave(TokenRenewal?)
        case setLogin(Bool?)
        case setErrors(Bool?,Int?)
        case setTokenError(Bool?,TokenRenewal?)
        case setTimeOut(Bool?)
    }
    
    // State is a current view state(상태관리)
    struct State {
        var isKeywordSearch: [String]?
        var isAlcoholSearch: AlcoholSearchRPModelData?
        var isAlcoholLikeOn: Bool?
        var isAlcoholLikeOff: Bool?
        var isIndecator : Bool?
        var isTokenRenewal: (TokenRenewal?)
        var isAccessTokenSave: (TokenRenewal?)
        var isLogin: Bool?
        var isErrors: (Bool?,Int?)
        var isTokenError: (Bool?,TokenRenewal?)
        var isTimeOut: Bool?
    }
    
    let initialState: State
    
    init() {
        self.initialState = State()
        keywordSearchService = KeywordSearchService()
        alcoholSearchService = AlcoholSearchService()
        alcoholLikeOnService = AlcoholLikeOnService()
        alcoholLikeOffService = AlcoholLikeOffService()
        tokenRenewalService = TokenRenewalService()
    }
    
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .alcoholLikeOn(pathParams):
            if tokenState() == 0 { //로그인 안됨
                return Observable.concat([
                    Observable.just(Mutation.setLogin(false)),
                    Observable.just(Mutation.setLogin(nil))
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(pathParams:pathParams,accessToken: result, eventIndex: 0)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)), //재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false))
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                    setAlcoholLikeOn(pathParams: pathParams)
                        .map{ result in
                            if result.errors == nil {
                                return Mutation.setAlcoholLikeOn(true)
                            }else {
                                if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                    return Mutation.setTokenError(true, TokenRenewal(pathParams:pathParams,eventIndex:0))
                                }else {
                                    return Mutation.setErrors(true, 0)
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setAlcoholLikeOn(false)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil)),
                    Observable.just(Mutation.setIndicator(false))
                ])
            }
        case let .alcoholLikeOff(pathParams):
            if tokenState() == 0 { //로그인 안됨
                return Observable.concat([
                    Observable.just(Mutation.setLogin(false)),
                    Observable.just(Mutation.setLogin(nil))
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(pathParams:pathParams,accessToken: result, eventIndex: 1)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)), //재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false))
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                    setAlcoholLikeOff(pathParams: pathParams)
                        .map{ result in
                            if result.errors == nil {
                                return Mutation.setAlcoholLikeOff(true)
                            }else {
                                if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                    return Mutation.setTokenError(true, TokenRenewal(pathParams:pathParams,eventIndex:1))
                                }else {
                                    return Mutation.setErrors(true, 1)
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setAlcoholLikeOff(false)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil)),
                    Observable.just(Mutation.setIndicator(false))
                ])
            }
        case let .keywordSearch(keywordParams):
            if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(keywordParams:keywordParams ,accessToken: result, eventIndex: 2)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)), //재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false))
                ])
            }else { //토큰 정상
                return Observable.concat([
                    getKeywordSearch(params: keywordParams)
                        .map{ result in
                            if result.errors == nil {
                                return Mutation.setKeywordSearch(result.data.alcoholList)
                            }else {
                                if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                    return Mutation.setTokenError(true, TokenRenewal(keywordParams:keywordParams,eventIndex:2))
                                }else {
                                    return Mutation.setErrors(true, 2)
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setKeywordSearch(nil)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil))
                ])
            }
        case let .alcoholSearch(params):
            if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(params:params,accessToken: result, eventIndex: 3)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)),
                    Observable.just(Mutation.setTimeOut(false))//재호출 방지를 위해 초기화
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                    getAlcoholSearchList(params: params)
                    .map{ result in
                        if result.errors == nil {
                            return Mutation.setAlcoholSearch(result.data)
                        }else {
                            if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                return Mutation.setTokenError(true, TokenRenewal(params:params,eventIndex:3))
                            }else {
                                return Mutation.setErrors(true, 3)
                            }
                        }
                    }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setAlcoholSearch(nil)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil)),
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
        case let .setAlcoholLikeOn(flag) :
            state.isAlcoholLikeOn = flag
        case let .setAlcoholLikeOff(flag) :
            state.isAlcoholLikeOff = flag
        case let .setKeywordSearch(keywordSearchRPModel) :
            state.isKeywordSearch = keywordSearchRPModel
        case let .setAlcoholSearch(alcoholSearchRPModel) :
            state.isAlcoholSearch = alcoholSearchRPModel
        case let .setIndicator(flag):
            state.isIndecator = flag
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
        case let .setTimeOut(flag):
            state.isTimeOut = flag
        }
        
        return state
    }

    //키워드 검색
    func getKeywordSearch(params:[String:Any]?) -> Observable<KeywordSearchRPModel> {
        return keywordSearchService.getKeywordSearch(params: params)
    }
    
    //주류 검색
    func getAlcoholSearchList(params:AlcoholSearchRQModel?) -> Observable<AlcoholSearchRPModel> {
        return alcoholSearchService.getAlcoholSearch(params: params)
    }
    
    //주류 좋아요
    func setAlcoholLikeOn(pathParams:[String:String]?) -> Observable<SuccessRPModel> {
        return alcoholLikeOnService.setAlcoholLikeOn(params: nil, pathParams: pathParams!)
    }
    
    //주류 좋아요 취소
    func setAlcoholLikeOff(pathParams:[String:String]?) -> Observable<SuccessRPModel> {
        return alcoholLikeOffService.setAlcoholLikeOff(params: nil, pathParams: pathParams!)
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
