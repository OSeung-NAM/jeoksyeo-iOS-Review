//
//  MyReviewListRT.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/13.
//

import RxCocoa
import ReactorKit
import RxSwift

//내가 작성한 리뷰 리스트 전용 ReactorKit 아키텍쳐 파일(내 리뷰 조회, 리뷰 삭제, 토큰 갱신 서비스 컨트롤)
final class MyReviewListRT: Reactor {
    
    fileprivate let myReviewListService: MyReviewListService
    fileprivate let reviewDeleteService: ReviewDeleteService
    fileprivate let tokenRenewalService: TokenRenewalService
    
    struct TokenRenewal {
        var params:MyReviewListRQModel?
        var pathParams:[String:String]?
        var accessToken:String?
        var eventIndex:Int
        var saveFlag:Bool?
    }
    
    //VC에서 들어오는 Event
    enum Action {
        case getMyReviewList(MyReviewListRQModel?)
        case reviewDelete([String:String]?)
        case accessTokenSave(TokenRenewal?)
    }
    
    enum Mutation {
        case setMyReviewList(MyReviewListRPModelData?)
        case setReviewDelete(Bool?)
        case setIndicator(Bool?)
        case setTokenRenewal(TokenRenewal?)
        case setAccessTokenSave(TokenRenewal?)
        case setLogin(Bool?)
        case setErrors(Bool?,Int?)
        case setTokenError(Bool?,TokenRenewal?)
        case setTimeOut(Bool?)
    }
    
    struct State {
        var isMyReviewList:MyReviewListRPModelData?
        var isMyStateMSG: (Int?, String?)
        var isReviewDelete : Bool?
        var isIndecator : Bool?
        var isTokenRenewal: (TokenRenewal?)
        var isAccessTokenSave: (TokenRenewal?)
        var isLogin: Bool?
        var isErrors: (Bool?,Int?)
        var isTokenError: (Bool?,TokenRenewal?)
        var isTimeOut: Bool?
    }
    
    let initialState: State
    
    //초기화
    init() {
        self.initialState = State()
        myReviewListService = MyReviewListService()
        reviewDeleteService = ReviewDeleteService()
        tokenRenewalService = TokenRenewalService()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .getMyReviewList(params):
            if tokenState() == 0 { //로그인 안됨
                return Observable.concat([
                    Observable.just(Mutation.setLogin(false)),
                    Observable.just(Mutation.setLogin(nil))
                ])
            }else if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(params: params,accessToken: result, eventIndex: 0)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)), //재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false))
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                    getMyReviewList(params: params)
                        .map{ result in
                            if result.errors == nil {
                                return Mutation.setMyReviewList(result.data)
                            }else {
                                if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                    return Mutation.setTokenError(true, TokenRenewal(params: params,eventIndex:0))
                                }else {
                                    return Mutation.setErrors(true, 0)
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setMyReviewList(nil)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil)),
                    Observable.just(Mutation.setIndicator(false))
                ])
            }
        case let .reviewDelete(pathParams):
            if tokenState() == 0 { //로그인 안됨
                return Observable.concat([
                    Observable.just(Mutation.setLogin(false)),
                    Observable.just(Mutation.setLogin(nil))
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
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                    deleteMyReview(pathParams: pathParams)
                    .map{ result in
                        if result.errors == nil {
                            return Mutation.setReviewDelete(true)
                        }else {
                            if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                return Mutation.setTokenError(true, TokenRenewal(pathParams: pathParams,eventIndex:1))
                            }else {
                                return Mutation.setErrors(true, 1)
                            }
                        }
                    }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setReviewDelete(nil)),
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
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state

        switch mutation {
        case let .setMyReviewList(result):
            state.isMyReviewList = result
        case let .setReviewDelete(flag):
            state.isReviewDelete = flag
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
    
    //내 리뷰 조회
    func getMyReviewList(params:MyReviewListRQModel?) -> Observable<MyReviewListRPModel> {
        return myReviewListService.getMyReviewList(params: params)
    }
    
    //내 리뷰 삭제
    func deleteMyReview(pathParams:[String:String]?) -> Observable<SuccessRPModel> {
        return reviewDeleteService.deleteReview(params: nil, pathParams: pathParams!)
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
