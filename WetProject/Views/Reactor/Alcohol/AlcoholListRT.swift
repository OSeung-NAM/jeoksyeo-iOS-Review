//
//  AlcoholListRT.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/30.
//

import ReactorKit
import RxSwift

//주류 리스트 관련 ReactorKit 아키텍쳐 파일(주류리스트, 주류 좋아요, 토큰 갱신 서비스 컨트롤)
final class AlcoholListRT: Reactor {
    // Action is an user interaction
    
    
    //MARK -- Service
    
    fileprivate let alcoholListService: AlcoholListService
    fileprivate let alcoholLikeService: AlcoholLikeService
    fileprivate let tokenRenewalService: TokenRenewalService
    
    //MARK --
    var alcoholIdList:[String] = [String]()
    var alcoholList:[AlcoholList] = [AlcoholList]()
    var pagingInfo:PagingInfo?
    var category:String = String()
    var filter:String = String()
    var page:Int = 1
    
    struct TokenRenewal {
        var params:AlcoholListRQModel?
        var pathParams:[String:String]?
        var accessToken:String?
        var eventIndex:Int
        var saveFlag:Bool?
    }
    
    enum Action {
        case alcoholList(AlcoholListRQModel?)
        case alcoholLikeOn([String:String]?)
        case alcoholLikeOff([String:String]?)
        case accessTokenSave(TokenRenewal?)
    }
    
    // Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case setAlcoholList(PagingInfo?,[AlcoholList]?)
        case setAlcoholLikeOn(Bool?)
        case setAlcoholLikeOff(Bool?)
        case setAlcoholIdList([String]?)
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
        var isAlcoholList: (PagingInfo?,[AlcoholList]?)
        var isAlcoholLikeOn: Bool?
        var isAlcoholLikeOff: Bool?
        var isAlcoholIdList: [String]?
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
        alcoholListService = AlcoholListService()
        alcoholLikeService = AlcoholLikeService()
        tokenRenewalService = TokenRenewalService()
    }
    
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .alcoholList(params): //주류 리스트는 로그인 한해도 되기 때문에 로그인 안함 여부 체크 안함
            if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(params: params,accessToken: result, eventIndex: 0)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)), //재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false))
                ])
            }else { //토큰 정상
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    Observable.just(Mutation.setIndicator(true)),
                    getAlcoholList(params: params) //주류 리스트 호출
                        .map{ result in
                            if result.errors == nil {
                                return Mutation.setAlcoholList(result.data?.pagingInfo, result.data?.alcoholList)
                            }else {
                                if result.errors?.errorCode == 11004 { //정상적인 유저가 아님
                                    return Mutation.setTokenError(true,TokenRenewal(params: params, eventIndex: 0)) //토큰 에러
                                }else {
                                    return Mutation.setErrors(true,0) //일반 에러
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                            .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setAlcoholList(nil, nil)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil)),
                    Observable.just(Mutation.setIndicator(false))
                ])
            }
        case let .alcoholLikeOn(pathParams):
            if tokenState() == 0 { //로그인 여부 체크
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    Observable.just(Mutation.setLogin(false)), //로그인 플래그 처리
                    Observable.just(Mutation.setLogin(nil)) //초기화
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(pathParams: pathParams,accessToken: result, eventIndex: 1)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)), //재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false))
                ])
            }else { //토큰 정상
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    Observable.just(Mutation.setIndicator(true)),
                    alcoholLike(pathParams: pathParams, flag: true)
                        .map{ result in
                            if result.errors == nil {
                                return Mutation.setAlcoholLikeOn(true)
                            }else {
                                if result.errors?.errorCode == 11004 { //정상적인 유저가 아님
                                    return Mutation.setTokenError(true,TokenRenewal(pathParams:pathParams, eventIndex: 1)) //토큰 에러
                                }else {
                                    return Mutation.setErrors(true,1) //일반 에러
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
            if tokenState() == 0 { //로그인 여부 체크
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    Observable.just(Mutation.setLogin(false)), //로그인 플래그 처리
                    Observable.just(Mutation.setLogin(nil)) //초기화
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(pathParams: pathParams,accessToken: result, eventIndex: 2)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)), //재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false))
                ])
            }else { //토큰 정상
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    Observable.just(Mutation.setIndicator(true)),
                    alcoholLike(pathParams: pathParams, flag: false)
                        .map{ result in
                            if result.errors == nil {
                                return Mutation.setAlcoholLikeOff(true)
                            }else {
                                if result.errors?.errorCode == 11004 { //정상적인 유저가 아님
                                    return Mutation.setTokenError(true,TokenRenewal(pathParams:pathParams, eventIndex: 2)) //토큰 에러
                                }else {
                                    return Mutation.setErrors(true,2) //일반 에러
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
        case var .accessTokenSave(tokenRenewal): //토큰 저장
            return Observable.concat([ //contat : 배열 순서대로 Observable실행
                accessTokenSave(accessToken: tokenRenewal?.accessToken)
                    .map{ result in
                        tokenRenewal?.saveFlag = result
                        return tokenRenewal
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
        case let .setAlcoholList(pagingInfo,alcoholList):
            state.isAlcoholList = (pagingInfo,alcoholList)
        case let .setAlcoholLikeOn(flag):
            state.isAlcoholLikeOn = flag
        case let .setAlcoholLikeOff(flag):
            state.isAlcoholLikeOff = flag
        case let .setAlcoholIdList(list):
            state.isAlcoholIdList = list
        case let .setIndicator(flag):
            state.isIndecator = flag
        case let .setTokenRenewal(tokenRenewal) :
            state.isTokenRenewal = tokenRenewal
        case let .setAccessTokenSave(tokenRenewal) :
            state.isAccessTokenSave = tokenRenewal
        case let .setLogin(flag) :
            state.isLogin = flag
        case let .setErrors(flag,eventIndex) :
            state.isErrors = (flag, eventIndex)
        case let .setTokenError(flag,tokenRenewal) :
            state.isTokenError = (flag,tokenRenewal)
        case let .setTimeOut(flag):
            state.isTimeOut = flag
        }
        
        return state
    }

    //주류 리스트
    func getAlcoholList(params:AlcoholListRQModel?) -> Observable<AlcoholListRPModel> {
        return alcoholListService.getAlcoholList(params: params!)
    }
    
    //주류 좋아요, 좋아요 취소 관리
    func alcoholLike(pathParams:[String:String]?, flag:Bool?) -> Observable<SuccessRPModel> {
        return alcoholLikeService.setAlcoholLike(params: nil, pathParams: pathParams!, flag: flag!)
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
