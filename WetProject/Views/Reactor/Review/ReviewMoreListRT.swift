//
//  ReviewMoreListRT.swift
//  WetProject
//
//  Created by 남오승 on 2020/12/16.
//

import ReactorKit
import RxSwift

//리뷰 모아보기 관련 ReactorKit 아키텍쳐 파일(리뷰 좋아요, 리뷰 싫어요, 리뷰 좋아요 취소, 리뷰 싫어요 취소, 리뷰 리스트, 토큰 갱신 서비스 컨트롤)
final class ReviewMoreListRT: Reactor {
    // Action is an user interaction
    
    fileprivate let reviewLikeService:ReviewLikeService
    fileprivate let alcoholDetailReviewService:AlcoholDetailReviewService
    fileprivate let reviewDisLikeService:ReviewDisLikeService
    fileprivate let tokenRenewalService: TokenRenewalService
    
    struct TokenRenewal {
        var alcoholId:String?
        var reviewId:String?
        var pathParams:[String:String]?
        var params:[String:Int]?
        var accessToken:String?
        var saveFlag:Bool?
        var eventIndex:Int
    }
    
    enum Action {
        case reviewLikeOn([String:String]?) //4
        case reviewLikeOff([String:String]?) //5
        case reviewDisLikeOn([String:String]?) //6
        case reviewDisLikeOff([String:String]?)//7
        case reviewMoreList([String:String]?, [String:Int]?)
        case accessTokenSave(TokenRenewal?)
    }
    
    // Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case setTokenRenewal(TokenRenewal?)
        case setAccessTokenSave(TokenRenewal?)
        case setLogin(Bool?)
        case setErrors(Bool?)
        case setReviewMoreList(PagingInfo?, ReviewInfo?, [ReviewList]?)
        case setIndicator(Bool?)
        case setReviewLikeOn(Bool?)
        case setReviewLikeOff(Bool?)
        case setReviewDisLikeOn(Bool?)
        case setReviewDisLikeOff(Bool?)
        case setErrors(Bool?,Int?)
        case setTokenError(Bool?,TokenRenewal?)
        case setTimeOut(Bool?)
    }
    
    // State is a current view state(상태관리)
    struct State {
        var isTokenRenewal: (TokenRenewal?)
        var isAccessTokenSave: (TokenRenewal?)
        var isLogin: Bool?
        var isReviewMoreList:(PagingInfo?, ReviewInfo?, [ReviewList]? )
        var isIndicator : Bool?
        var isReviewLikeOn: Bool?
        var isReviewLikeOff: Bool?
        var isReviewDisLikeOn: Bool?
        var isReviewDisLikeOff: Bool?
        var isErrors: (Bool?,Int?)
        var isTokenError: (Bool?,TokenRenewal?)
        var isTimeOut: Bool?
    }
    
    let initialState: State
    
    init() {
        self.initialState = State()
        reviewLikeService = ReviewLikeService()
        reviewDisLikeService = ReviewDisLikeService()
        tokenRenewalService = TokenRenewalService()
        alcoholDetailReviewService = AlcoholDetailReviewService()
    }
    
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .reviewMoreList(pathParams, params):
            if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(pathParams: pathParams, accessToken: result, eventIndex: 0)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)), //재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false)) //갱신 후
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                    getReviewMoreList(pathParams: pathParams, params: params)
                        .map{ result in
                            if result.errors == nil {
                                return Mutation.setReviewMoreList(result.data?.pageInfo, result.data?.reviewInfo, result.data?.reviewList)
                            }else {
                                if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                    return Mutation.setTokenError(true, TokenRenewal(pathParams:pathParams, params:params ,eventIndex:0))
                                }else {
                                    return Mutation.setErrors(true, 0)
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setReviewMoreList(nil, nil, nil)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil)),
                    Observable.just(Mutation.setIndicator(false))
                ])
            }
        case let .reviewLikeOn(pathParams):
            if tokenState() == 0 { //로그인 안됨
                return Observable.concat([
                    Observable.just(Mutation.setLogin(false)),
                    Observable.just(Mutation.setLogin(nil))
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{result in TokenRenewal(pathParams: pathParams,accessToken: result, eventIndex: 1)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)),//재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false)) //갱신 후
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                    reviewLike(pathParams: pathParams, flag: true)
                        .map{ result in
                            if result.errors == nil {
                                return Mutation.setReviewLikeOn(true)
                            }else {
                                if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                    return Mutation.setTokenError(true, TokenRenewal(pathParams:pathParams,eventIndex:1))
                                }else {
                                    return Mutation.setErrors(true, 1)
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setReviewLikeOn(nil)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil)),
                    Observable.just(Mutation.setIndicator(false))
                ])
            }
        case let .reviewLikeOff(pathParams):
            if tokenState() == 0 { //로그인 안됨
                return Observable.concat([
                    Observable.just(Mutation.setLogin(false)),
                    Observable.just(Mutation.setLogin(nil))
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(pathParams: pathParams,accessToken: result ,eventIndex: 2)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)),//재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false))//갱신 후
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                    reviewLike(pathParams: pathParams, flag: false)
                        .map{ result in
                            if result.errors == nil {
                                return Mutation.setReviewLikeOff(true)
                            }else {
                                if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                    return Mutation.setTokenError(true, TokenRenewal(pathParams:pathParams,eventIndex:2))
                                }else {
                                    return Mutation.setErrors(true, 2)
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setReviewLikeOff(nil)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil)),
                    Observable.just(Mutation.setIndicator(false))
                ])
            }
        case let .reviewDisLikeOn(pathParams):
            if tokenState() == 0 { //로그인 안됨
                return Observable.concat([
                    Observable.just(Mutation.setLogin(false)),
                    Observable.just(Mutation.setLogin(nil))
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(pathParams: pathParams,accessToken: result, eventIndex: 3)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)), //재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false)) //갱신 후
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                    reviewDisLike(pathParams: pathParams, flag: true)
                        .map{ result in
                            if result.errors == nil {
                                return Mutation.setReviewDisLikeOn(true)
                            }else {
                                if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                    return Mutation.setTokenError(true, TokenRenewal(pathParams:pathParams,eventIndex:3))
                                }else {
                                    return Mutation.setErrors(true, 3)
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setReviewDisLikeOn(nil)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil)),
                    Observable.just(Mutation.setIndicator(false))
                ])
            }
        case let .reviewDisLikeOff(pathParams):
            if tokenState() == 0 { //로그인 안됨
                return Observable.concat([
                    Observable.just(Mutation.setLogin(false)),
                    Observable.just(Mutation.setLogin(nil))
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(pathParams: pathParams,accessToken: result ,eventIndex: 4)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)),//재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false)) //갱신 후
                ])
            }else { //토큰 정상
                return Observable.concat([
                   Observable.just(Mutation.setIndicator(true)),
                    reviewDisLike(pathParams: pathParams, flag: false)
                        .map{ result in
                            if result.errors == nil {
                                return Mutation.setReviewDisLikeOff(true)
                            }else {
                                if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                    return Mutation.setTokenError(true, TokenRenewal(pathParams:pathParams,eventIndex:4))
                                }else {
                                    return Mutation.setErrors(true, 4)
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setReviewDisLikeOff(nil)),
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
        case let .setTokenRenewal(tokenRenewal) :
            state.isTokenRenewal = tokenRenewal
        case let .setAccessTokenSave(tokenRenewal) :
            state.isAccessTokenSave = tokenRenewal
        case let .setLogin(flag) :
            state.isLogin = flag
        case let .setReviewMoreList(pagingInfo, reviewInfo, reviewList):
            state.isReviewMoreList.0 = pagingInfo
            state.isReviewMoreList.1 = reviewInfo
            state.isReviewMoreList.2 = reviewList
        case let .setIndicator(flag) :
            state.isIndicator = flag
        case let .setReviewLikeOn(flag):
            state.isReviewLikeOn = flag
        case let .setReviewLikeOff(flag):
            state.isReviewLikeOff = flag
        case let .setReviewDisLikeOn(flag):
            state.isReviewDisLikeOn = flag
        case let .setReviewDisLikeOff(flag):
            state.isReviewDisLikeOff = flag
        case let .setErrors(flag,eventIndex) :
            state.isErrors = (flag,eventIndex)
        case let .setTokenError(flag, tokenRenewal) :
            state.isTokenError = (flag, tokenRenewal)
        case let .setTimeOut(flag) :
            state.isTimeOut = flag
        }
        
        return state
    }
    
    
    //리뷰 내용 더보기 관리
    func reviewListExpandSetting(reviewList:[ReviewList],reviewId:String,expandFlag:Bool) -> Observable<[ReviewList]?> {
        var reviewList = reviewList
        var index = 0
        for review in reviewList {
            if let rId:String = review.reviewId {
                if rId == reviewId {
                    reviewList[index].expandFlag = !reviewList[index].expandFlag
                    break
                }
            }
            index += 1
        }
        return Observable.just(reviewList)
    }
 
    //주류 리뷰 더보기 조회
    func getReviewMoreList(pathParams:[String:String]?,params:[String:Int]?) -> Observable<AlcoholDetailReviewRPModel> {
            return alcoholDetailReviewService.getAlcoholDetailReview(pathParams: pathParams!, params: params)
    }
    
    //주류 리뷰 좋아요 관리
    func reviewLike(pathParams:[String:String]?,flag:Bool) -> Observable<SuccessRPModel> {
        return reviewLikeService.reviewLike(pathParams: pathParams!,flag: flag)
    }
    
    //주류 리뷰 싫어요 관리
    func reviewDisLike(pathParams:[String:String]?, flag:Bool) -> Observable<SuccessRPModel> {
        return reviewDisLikeService.reviewDisLike(pathParams: pathParams!,flag: flag)
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
