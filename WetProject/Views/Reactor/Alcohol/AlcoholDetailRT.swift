//
//  AlcoholDetailRT.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/10.
//

import ReactorKit
import RxSwift

//주류 상세조회 관련 ReactorKit 아케텍쳐 파일(주류 상세, 주류 상세 전용 리뷰리스트, 리뷰 생성 여부, 리뷰 좋아요, 리뷰 싫어요, 리뷰 좋아요 취소, 리뷰 싫어요 취소,  주류 좋아요, 토큰 갱신 서비스 컨트롤)
final class AlcoholDetailRT: Reactor {
    // Action is an user interaction
    
    fileprivate let alcoholDetailService: AlcoholDetailService
    fileprivate let alcoholDetailReviewService: AlcoholDetailReviewService
    fileprivate let reviewCreatedService:ReviewCreatedService
    fileprivate let reviewLikeService:ReviewLikeService
    fileprivate let reviewDisLikeService:ReviewDisLikeService
    fileprivate let alcoholLikeService:AlcoholLikeService
    fileprivate let tokenRenewalService: TokenRenewalService
    
    struct TokenRenewal {
        var alcoholId:String?
        var reviewId:String?
        var alcoholDetail:AlcoholDetail?
        var reviewList:[ReviewList]?
        var pathParams:[String:String]?
        var params:[String:Any]?
        var accessToken:String?
        var saveFlag:Bool?
        var eventIndex:Int
    }
    
    enum Action {
        case alcoholDetail([String:String]?) //0
        case alcoholReview([String:String]?, [String:Int]?) //1
        case alcoholLikeOn(AlcoholDetail?,[String:String]?) //2
        case alcoholLikeOff(AlcoholDetail?,[String:String]?) //3
        case reviewLikeOn([ReviewList]?,String?,[String:String]?) //4
        case reviewLikeOff([ReviewList]?,String?,[String:String]?) //5
        case reviewDisLikeOn([ReviewList]?,String?,[String:String]?) //6
        case reviewDisLikeOff([ReviewList]?,String?,[String:String]?)//7
        case reviewCreated([String:String]?) //8
        case reviewMoreList([String:String]?, [String:Int]?)
        case accessTokenSave(TokenRenewal?)
        case reviewContentsExpanded([ReviewList]?,String?,Bool?)
    }
    
    // Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case setAlcoholDetail(AlcoholDetail?)
        case setAlcoholReview((UserAssessment?,ReviewInfo?,[ReviewList]?))
        case setReviewCreated(Bool?)
        case setTokenRenewal(TokenRenewal?)
        case setAccessTokenSave(TokenRenewal?)
        case setLogin(Bool?)
        case setReviewListRenewal([ReviewList]?)
        case setReviewMoreList(PagingInfo?, ReviewInfo?, [ReviewList]?)
        case setIndicator(Bool?)
        case setErrors(Bool?,Int?)
        case setTokenError(Bool?,TokenRenewal?)
        case setTimeOut(Bool?)
    }
    
    // State is a current view state(상태관리)
    struct State {
        var isAlcoholDetail:AlcoholDetail?
        var isAlcoholReview: (UserAssessment?,ReviewInfo?,[ReviewList]?)
        var isReviewCreated: Bool?
        var isTokenRenewal: (TokenRenewal?)
        var isAccessTokenSave: (TokenRenewal?)
        var isLogin: Bool?
        var isReviewListRenewal:[ReviewList]?
        var isReviewMoreList:(PagingInfo?, ReviewInfo?, [ReviewList]? )
        var isIndicator : Bool?
        var isErrors: (Bool?,Int?)
        var isTokenError: (Bool?,TokenRenewal?)
        var isTimeOut:Bool?
    }
    
    let initialState: State
    
    init() {
        self.initialState = State()
        alcoholDetailService = AlcoholDetailService()
        alcoholDetailReviewService = AlcoholDetailReviewService()
        reviewCreatedService = ReviewCreatedService()
        reviewLikeService = ReviewLikeService()
        reviewDisLikeService = ReviewDisLikeService()
        alcoholLikeService = AlcoholLikeService()
        tokenRenewalService = TokenRenewalService()
    }
    
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        
        case let .alcoholDetail(pathParams):
            if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(pathParams: pathParams,accessToken: result, eventIndex: 0)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)), //재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false)) //갱신 후
                ])
            }else { //토큰 정상
                return Observable.concat([
                    getAlcoholDetail(pathParams: pathParams)
                        .map{result in
                            if result.errors == nil {
                                return Mutation.setAlcoholDetail(result.data?.alcohol)
                            }else {
                                if result.errors?.errorCode == 11004 { //정상적인 유저가 아님
                                    return Mutation.setTokenError(true,TokenRenewal(pathParams: pathParams, eventIndex: 0)) //토큰 에러
                                }else {
                                    return Mutation.setErrors(true,0) //일반 에러
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setAlcoholDetail(nil)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil))
                ])
            }
        case let .alcoholReview(pathParams, params):
            if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(pathParams: pathParams, params: params,accessToken: result , eventIndex: 1)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)), //재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false)) //갱신 후
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                    getAlcoholDetailReivew(pathParams: pathParams, params: params)
                        .map{ result in
                            if result.errors == nil {
                                return Mutation.setAlcoholReview((result.data?.userAssessment,result.data?.reviewInfo,result.data?.reviewList))
                            }else {
                                if result.errors?.errorCode == 11004 { //정상적인 유저가 아님
                                    return Mutation.setTokenError(true,TokenRenewal(pathParams: pathParams, params: params, eventIndex: 1)) //토큰 에러
                                }else {
                                    return Mutation.setErrors(true,1) //일반 에러
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setAlcoholReview((nil,nil,nil))),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil)),
                    Observable.just(Mutation.setIndicator(false))
                ])
            }
        case let .alcoholLikeOn(alcoholDetail,pathParams):
            if tokenState() == 0 { //로그인 안됨
                return Observable.concat([
                    Observable.just(Mutation.setLogin(false)),
                    Observable.just(Mutation.setLogin(nil))
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{result in TokenRenewal(alcoholDetail: alcoholDetail, pathParams: pathParams,accessToken: result, eventIndex: 2)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)),//재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false)) //갱신 후
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                     alcoholLike(pathParams: pathParams, flag: true)
                        .map { [weak self] result in
                            if result.errors == nil {
                                return Mutation.setAlcoholDetail(self?.alcoholLikeAfterEvent(alcoholDetail: alcoholDetail))
                            }else {
                                if result.errors?.errorCode == 11004 { //정상적인 유저가 아님
                                    return Mutation.setTokenError(true,TokenRenewal(alcoholDetail: alcoholDetail, pathParams: pathParams, eventIndex: 2)) //토큰 에러
                                }else {
                                    return Mutation.setErrors(true,2) //일반 에러
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setAlcoholDetail(nil)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil)),
                    Observable.just(Mutation.setIndicator(false))
                ])
            }
        case let .alcoholLikeOff(alcoholDetail,pathParams):
            if tokenState() == 0 { //로그인 안됨
                return Observable.concat([
                    Observable.just(Mutation.setLogin(false)),
                    Observable.just(Mutation.setLogin(nil))
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{result in TokenRenewal(alcoholDetail: alcoholDetail, pathParams: pathParams,accessToken: result ,eventIndex: 3)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)), //재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false)) //갱신 후
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                     alcoholLike(pathParams: pathParams, flag: false)
                        .map { [weak self] result in
                            if result.errors == nil {
                                return Mutation.setAlcoholDetail(self?.alcoholLikeAfterEvent(alcoholDetail: alcoholDetail))
                            }else {
                                if result.errors?.errorCode == 11004 { //정상적인 유저가 아님
                                    return Mutation.setTokenError(true,TokenRenewal(alcoholDetail: alcoholDetail,pathParams: pathParams, eventIndex: 3)) //토큰 에러
                                }else {
                                    return Mutation.setErrors(true,3) //일반 에러
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setAlcoholDetail(nil)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil)),
                    Observable.just(Mutation.setIndicator(false))
                ])
            }
        case let .reviewLikeOn(reviewList, reviewId, pathParams):
            if tokenState() == 0 { //로그인 안됨
                return Observable.concat([
                    Observable.just(Mutation.setLogin(false)),
                    Observable.just(Mutation.setLogin(nil))
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{result in TokenRenewal(reviewId: reviewId,reviewList: reviewList,pathParams: pathParams,accessToken: result, eventIndex: 4)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)),//재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false)) //갱신 후
                    
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                    reviewLike(pathParams: pathParams, flag: true)
                        .map{ [weak self] result in
                            if result.errors == nil {
                                return Mutation.setReviewListRenewal(self?.reviewLikeAfterEvent(reviewList: reviewList ?? [], reviewId: reviewId ?? "", reviewLikeFlag: true))
                            }else {
                                if result.errors?.errorCode == 11004 { //정상적인 유저가 아님
                                    return Mutation.setTokenError(true,TokenRenewal(reviewId: reviewId,reviewList: reviewList,pathParams: pathParams, eventIndex: 4)) //토큰 에러
                                }else {
                                    return Mutation.setErrors(true,4) //일반 에러
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setReviewListRenewal(nil)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil)),
                    Observable.just(Mutation.setIndicator(false))
                ])
            }
        case let .reviewLikeOff(reviewList, reviewId, pathParams):
            if tokenState() == 0 { //로그인 안됨
                return Observable.concat([
                    Observable.just(Mutation.setLogin(false)),
                    Observable.just(Mutation.setLogin(nil))
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(reviewId: reviewId,reviewList: reviewList,pathParams: pathParams,accessToken: result ,eventIndex: 5)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)),//재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false)) //갱신 후
                    
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                    reviewLike(pathParams: pathParams, flag: false)
                        .map{ [weak self] result in
                            if result.errors == nil {
                                return Mutation.setReviewListRenewal(self?.reviewLikeAfterEvent(reviewList: reviewList ?? [], reviewId: reviewId ?? "", reviewLikeFlag: false))
                            }else {
                                if result.errors?.errorCode == 11004 { //정상적인 유저가 아님
                                    return Mutation.setTokenError(true,TokenRenewal(reviewId: reviewId,reviewList: reviewList,pathParams: pathParams ,eventIndex: 5)) //토큰 에러
                                }else {
                                    return Mutation.setErrors(true,5) //일반 에러
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setReviewListRenewal(nil)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil)),
                    Observable.just(Mutation.setIndicator(false))
                ])
            }
        case let .reviewDisLikeOn(reviewList, reviewId, pathParams):
            if tokenState() == 0 { //로그인 안됨
                return Observable.concat([
                    Observable.just(Mutation.setLogin(false)),
                    Observable.just(Mutation.setLogin(nil))
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(reviewId: reviewId,reviewList: reviewList,pathParams: pathParams,accessToken: result, eventIndex: 6)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)),//재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false))//갱신 후
                    
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                    reviewDisLike(pathParams: pathParams, flag: true)
                        .map{ [weak self] result in
                            if result.errors == nil {
                                return Mutation.setReviewListRenewal(self?.reviewDisLikeAfterEvent(reviewList: reviewList ?? [], reviewId: reviewId ?? "", reviewDisLikeFlag: true))
                            }else {
                                if result.errors?.errorCode == 11004 { //정상적인 유저가 아님
                                    return Mutation.setTokenError(true,TokenRenewal(reviewId: reviewId,reviewList: reviewList,pathParams: pathParams, eventIndex: 6)) //토큰 에러
                                }else {
                                    return Mutation.setErrors(true,6) //일반 에러
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setReviewListRenewal(nil)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil)),
                    Observable.just(Mutation.setIndicator(false))
                ])
            }
        case let .reviewDisLikeOff(reviewList, reviewId, pathParams):
            if tokenState() == 0 { //로그인 안됨
                return Observable.concat([
                    Observable.just(Mutation.setLogin(false)),
                    Observable.just(Mutation.setLogin(nil))
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(reviewId: reviewId,reviewList: reviewList,pathParams: pathParams,accessToken: result ,eventIndex: 7)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)),//재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false)) //갱신 후
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                    reviewDisLike(pathParams: pathParams, flag: false)
                        .map{ [weak self] result in
                            if result.errors == nil {
                                return Mutation.setReviewListRenewal(self?.reviewDisLikeAfterEvent(reviewList: reviewList ?? [], reviewId: reviewId ?? "", reviewDisLikeFlag: false))
                            }else {
                                if result.errors?.errorCode == 11004 { //정상적인 유저가 아님
                                    return Mutation.setTokenError(true,TokenRenewal(reviewId: reviewId,reviewList: reviewList,pathParams: pathParams ,eventIndex: 7)) //토큰 에러
                                }else {
                                    return Mutation.setErrors(true,7) //일반 에러
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setReviewListRenewal(nil)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil)),
                    Observable.just(Mutation.setIndicator(false))
                ])
            }
        case let .reviewCreated(pathParams): //리뷰 생성 여부
            if tokenState() == 0 { //로그인 안됨
                return Observable.concat([
                    Observable.just(Mutation.setLogin(false)),
                    Observable.just(Mutation.setLogin(nil))
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(pathParams: pathParams, accessToken: result, eventIndex: 8)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)), //재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false)) //갱신 후
                ])
            }else { //내장디비에 저장 된 토큰에 대한 만료시간 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                        getReviewCreated(pathParams: pathParams) //주류 리스트 호출
                            .map{ result in
                                if result.errors == nil {
                                    return Mutation.setReviewCreated(result.data.isExist)
                                }else {
                                    if result.errors?.errorCode == 11004 { //정상적인 유저가 아님
                                        return Mutation.setTokenError(true,TokenRenewal(pathParams: pathParams, eventIndex: 8)) //토큰 에러
                                    }else {
                                        return Mutation.setErrors(true,8) //일반 에러
                                    }
                                }
                            }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                            .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setReviewCreated(nil)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil)),
                    Observable.just(Mutation.setIndicator(false))
                ])
            }
        case let .reviewMoreList(pathParams, params):
            if tokenState() == 0 { //로그인 안됨
                return Observable.concat([
                    Observable.just(Mutation.setLogin(false)),
                    Observable.just(Mutation.setLogin(nil))
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(pathParams: pathParams, accessToken: result, eventIndex: 9)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)), //재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false)) //갱신 후
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                    getReviewMoreList(pathParams: pathParams, params: params)
                        .map{Mutation.setReviewMoreList($0.0, $0.1, $0.2)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setReviewMoreList(nil, nil, nil)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setIndicator(false))
                ])
            }
        case let .reviewContentsExpanded(reviewList,reviewId,expandFlag):
            return Observable.concat([
                reviewListExpandSetting(reviewList: reviewList ?? [], reviewId: reviewId ?? "", expandFlag: expandFlag ?? false)
                    .map{Mutation.setReviewListRenewal($0)},
                Observable.just(Mutation.setReviewListRenewal(nil))
            ])
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
        case let .setAlcoholDetail(alcohol):
            state.isAlcoholDetail = alcohol
        case let .setAlcoholReview(alcoholReview):
            state.isAlcoholReview = alcoholReview
        case let .setReviewCreated(ReviewCreatedRPModel):
            state.isReviewCreated = ReviewCreatedRPModel
        case let .setTokenRenewal(tokenRenewal) :
            state.isTokenRenewal = tokenRenewal
        case let .setAccessTokenSave(tokenRenewal) :
            state.isAccessTokenSave = tokenRenewal
        case let .setLogin(flag) :
            state.isLogin = flag
        case let .setReviewListRenewal(reviewList) :
            state.isReviewListRenewal = reviewList
        case let .setReviewMoreList(pagingInfo, reviewInfo, reviewList):
            state.isReviewMoreList.0 = pagingInfo
            state.isReviewMoreList.1 = reviewInfo
            state.isReviewMoreList.2 = reviewList
        case let .setIndicator(flag) :
            state.isIndicator = flag
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
    
    //주류 좋아요 후 UI 후속조치 이벤트
    func alcoholLikeAfterEvent(alcoholDetail:AlcoholDetail?) -> AlcoholDetail? {
        
        if var alcoholDetail = alcoholDetail {
            let isLiked:Bool = alcoholDetail.isLiked ?? false
            let likeCnt:Int = alcoholDetail.likeCount ?? 0
            if isLiked {
                alcoholDetail.likeCount = (likeCnt - 1)
            }else {
                alcoholDetail.likeCount = (likeCnt + 1)
            }
            
            alcoholDetail.isLiked  = !isLiked
            return alcoholDetail
        }else {
            return nil
        }
    }
    
    //리뷰 좋아요 부분 클릭 후 UI 후속조치 이벤트
    func reviewLikeAfterEvent(reviewList:[ReviewList],reviewId:String,reviewLikeFlag:Bool) ->[ReviewList]{
        var reviewListDummy = reviewList
        var index:Int = 0
        for review in reviewListDummy {
            let rId = review.reviewId
            let likeCnt = review.likeCount ?? 0
            let disLikeCnt = review.disLikeCount ?? 0
            let hasDisLike:Bool = review.hasDisLike ?? false
            if rId == reviewId {
                reviewListDummy[index].hasLike = reviewLikeFlag
                if reviewLikeFlag {
                    reviewListDummy[index].likeCount = (likeCnt + 1)
                    if hasDisLike {
                        reviewListDummy[index].hasDisLike = false
                        reviewListDummy[index].disLikeCount = (disLikeCnt - 1)
                    }
                }else {
                    reviewListDummy[index].likeCount = (likeCnt - 1)
                }
                break
            }
            index += 1
        }
        return reviewListDummy
    }
    
    //리뷰 싫어요 부분 클릭 후 UI 후속조치 이벤트
    func reviewDisLikeAfterEvent(reviewList:[ReviewList],reviewId:String,reviewDisLikeFlag:Bool) ->[ReviewList]{
        var reviewListDummy = reviewList
        var index:Int = 0
        for review in reviewListDummy {
            let rId = review.reviewId
            let likeCnt = review.likeCount ?? 0
            let disLikeCnt = review.disLikeCount ?? 0
            let hasLike:Bool = review.hasLike ?? false
            if rId == reviewId {
                reviewListDummy[index].hasDisLike = reviewDisLikeFlag
                if reviewDisLikeFlag {
                    reviewListDummy[index].disLikeCount = (disLikeCnt + 1)
                    if hasLike {
                        reviewListDummy[index].hasLike = false
                        reviewListDummy[index].likeCount = (likeCnt - 1)
                    }
                }else {
                    reviewListDummy[index].disLikeCount = (disLikeCnt - 1)
                }
                break
            }
            index += 1
        }
        return reviewListDummy
    }
    
    //주류 상세조회
    func getAlcoholDetail(pathParams:[String:String]?) -> Observable<AlcoholDetailRPModel> {
        return alcoholDetailService.getAlcoholDetail(pathParams: pathParams!)
    }
    
    //주류 상세 리뷰 조회
    func getAlcoholDetailReivew(pathParams:[String:String]?,params:[String:Int]?) -> Observable<AlcoholDetailReviewRPModel> {
        return alcoholDetailReviewService.getAlcoholDetailReview(pathParams: pathParams!, params: params)
    }
    
    //주류 리뷰 더보기 조회
    func getReviewMoreList(pathParams:[String:String]?,params:[String:Int]?) -> Observable<(PagingInfo?,ReviewInfo?,[ReviewList]?)> {
            return alcoholDetailReviewService.getAlcoholDetailReview(pathParams: pathParams!, params: params)
                .map{(
                    $0.data?.pageInfo,
                    $0.data?.reviewInfo,
                    $0.data?.reviewList
                )}
    }
    
    //리뷰 생성 여부 조회
    func getReviewCreated(pathParams:[String:String]?) -> Observable<ReviewCreatedRPModel> {
        return reviewCreatedService.getReviewCreated(pathParams: pathParams!)
    }
    
    //주류 리뷰 좋아요 관리
    func reviewLike(pathParams:[String:String]?,flag:Bool) -> Observable<SuccessRPModel> {
        return reviewLikeService.reviewLike(pathParams: pathParams!,flag: flag)
    }
    
    //주류 리뷰 싫어요 관리
    func reviewDisLike(pathParams:[String:String]?, flag:Bool) -> Observable<SuccessRPModel> {
        return reviewDisLikeService.reviewDisLike(pathParams: pathParams!,flag: flag)
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
