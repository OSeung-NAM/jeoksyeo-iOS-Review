//
//  ReviewDetailRT.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/16.
//

import ReactorKit
import RxSwift

//리뷰 단건 상세조회 관련 ReactorKit 아키텍쳐 파일(리뷰 상세, 리뷰 신규 작성, 리뷰 업데이트,토큰 갱신 서비스 컨트롤)
final class ReviewDetailRT: Reactor {
    // Action is an user interaction
    
    fileprivate let reviewDetailService: ReviewDetailService
    fileprivate let reviewWriteService: ReviewWriteService
    fileprivate let reviewUpdateService: ReviewUpdateService
    fileprivate let tokenRenewalService: TokenRenewalService
    
    struct TokenRenewal {
        var pathParams:[String:String]?
        var params:[String:String]?
        var writeParams:ReviewWriteRQModel?
        var accessToken:String?
        var saveFlag:Bool?
        var eventIndex:Int
    }
    
    struct ReviewData {
        let contents:String
        let aroma:Float
        let mouthFeel:Float
        let taste:Float
        let appearance:Float
        let overall:Float
        let score:Float
    }
    
    enum Action {
        case reviewDetail([String:String]?)
        case reviewWrite(ReviewWriteRQModel?,[String:String]?)
        case reviewUpdate(ReviewWriteRQModel?,[String:String]?)
        case accessTokenSave(TokenRenewal?)
    }
    
    // Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case setReviewDetail(ReviewData?)
        case setReviewWrite(Bool?)
        case setReviewUpdate(Bool?)
        case setTokenRenewal(TokenRenewal?)
        case setAccessTokenSave(TokenRenewal?)
        case setLogin(Bool?)
        case setContents(String?)
        case setAroma(String?)
        case setIndicator(Bool?)
        case setErrors(Bool?,Int?)
        case setTokenError(Bool?,TokenRenewal?)
        case setTimeOut(Bool?)
    }
    
    // State is a current view state(상태관리)
    struct State {
        var isReviewDetail: ReviewData?
        var isReviewWrite: Bool?
        var isReviewUpdate: Bool?
        var isTokenRenewal: TokenRenewal?
        var isAccessTokenSave: TokenRenewal?
        var isLogin: Bool?
        var isContents: String?
        var isAroma: String?
        var isIndicator: Bool?
        var isErrors: (Bool?,Int?)
        var isTokenError: (Bool?,TokenRenewal?)
        var isTimeOut: Bool?
    }
    
    let initialState: State
    
    init() {
        self.initialState = State()
        reviewDetailService = ReviewDetailService()
        reviewWriteService = ReviewWriteService()
        reviewUpdateService = ReviewUpdateService()
        tokenRenewalService = TokenRenewalService()
    }
    
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        
        case let .reviewDetail(params):
            return Observable.concat([ //contat : 배열 순서대로 Observable실행
                getReviewDetail(params: params)
                    .map { [weak self] result in
                        if result.errors == nil {
                            return Mutation.setReviewDetail(self?.reviewDataSetting(result: result))
                        }else {
                            if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                return Mutation.setTokenError(true, TokenRenewal(params:params,eventIndex:0))
                            }else {
                                return Mutation.setErrors(true, 0)
                            }
                        }
                    }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                    .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                Observable.just(Mutation.setReviewDetail(nil)),
                Observable.just(Mutation.setTimeOut(false)),
                Observable.just(Mutation.setErrors(nil,nil)),
                Observable.just(Mutation.setTokenError(nil, nil))
            ])
        case let .reviewWrite(params, pathParams):
            if tokenState() == 1 { //토큰 만료
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
                    reviewWrite(params: params, pathParams: pathParams)
                        .map { result in
                            if result.errors == nil {
                                return Mutation.setReviewWrite(true)
                            }else {
                                if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                    return Mutation.setTokenError(true, TokenRenewal(pathParams:pathParams, writeParams: params,eventIndex:1))
                                }else {
                                    return Mutation.setErrors(true, 1)
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setReviewWrite(false)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil)),
                    Observable.just(Mutation.setIndicator(false))
                ])
            }
        case let .reviewUpdate(params, pathParams):
            if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(pathParams:pathParams,accessToken: result, eventIndex: 2)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)), //재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false))
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                    reviewUpdate(params: params, pathParams: pathParams)
                        .map { result in
                            if result.errors == nil {
                                return Mutation.setReviewUpdate(true)
                            }else {
                                if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                    return Mutation.setTokenError(true, TokenRenewal(pathParams:pathParams, writeParams: params,eventIndex:2))
                                }else {
                                    return Mutation.setErrors(true, 2)
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setReviewUpdate(false)),
                    Observable.just(Mutation.setIndicator(false)),
                    Observable.just(Mutation.setTimeOut(false)),
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
        case let .setReviewDetail(result):
            state.isReviewDetail = result
        case let .setReviewWrite(SuccessRPModel):
            state.isReviewWrite = SuccessRPModel
        case let .setReviewUpdate(SuccessRPModel):
            state.isReviewUpdate = SuccessRPModel
        case let .setTokenRenewal(tokenRenewal) :
            state.isTokenRenewal = tokenRenewal
        case let .setAccessTokenSave(tokenRenewal) :
            state.isAccessTokenSave = tokenRenewal
        case let .setLogin(flag) :
            state.isLogin = flag
        case let .setContents(contents):
            state.isContents = contents
        case let .setAroma(aroma):
            state.isAroma = aroma
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
    
    func reviewDataSetting(result:ReviewDetailRPModel) -> ReviewData {
        let contents = result.data?.review?.contents ?? ""
        let aroma = result.data?.review?.aroma ?? 0.0
        let mouthFeel = result.data?.review?.mouthfeel ?? 0.0
        let taste = result.data?.review?.taste ?? 0.0
        let appearance = result.data?.review?.appearance ?? 0.0
        let overall = result.data?.review?.overall ?? 0.0
        let score = result.data?.review?.score ?? 0.0
        return ReviewData(contents: contents, aroma: aroma, mouthFeel: mouthFeel, taste: taste, appearance: appearance, overall: overall, score: score)
    }

    /* Service */
    
    //리뷰 상세조회
    func getReviewDetail(params:[String:String]?) -> Observable<ReviewDetailRPModel> {
        return reviewDetailService.getReviewDetail(pathParams: params)
    }
    
    //리뷰 작성
    func reviewWrite(params:ReviewWriteRQModel?, pathParams:[String:String]?)->Observable<SuccessRPModel> {
        return reviewWriteService.reviewWrite(params: params!, pathParams: pathParams!)
    }
    
    //리뷰 수정
    func reviewUpdate(params:ReviewWriteRQModel?, pathParams:[String:String]?)->Observable<SuccessRPModel> {
        return reviewUpdateService.reviewUpdate(params: params!, pathParams: pathParams!)
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
