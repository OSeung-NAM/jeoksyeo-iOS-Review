//
//  UserInfoUpdateRT.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/20.
//

import ReactorKit
import RxSwift

//회원정보 수정 전용 ReactorKit 아키텍쳐 파일(내 정보 조회, 닉네임 체크, 유저 정보 업데이트, 유저 프로필 이미지 업데이트, 토큰 갱신 서비스 컨트롤)
final class UserInfoUpdateRT: Reactor {
    // Action is an user interaction
    
    fileprivate let myInfoService: MyInfoService
    fileprivate let signUpNameService: SignUpNameService
    fileprivate let userInfoUpdateService: UserInfoUpdateService
    fileprivate let oneImageUploadService: OneImageUploadService
    fileprivate let tokenRenewalService: TokenRenewalService
    
    struct TokenRenewal {
        var imageParams:UIImage?
        var nickNameParams:[String:Any]?
        var params:UserInfoUpdateRQModel?
        var pathParams:[String:String]?
        var accessToken:String?
        var eventIndex:Int
        var saveFlag:Bool?
    }
    
    enum Action {
        case myInfo
        case nickNameCheck([String:Any]?)
        case imageUpload(profileImage:UIImage?)
        case userUpdate(UserInfoUpdateRQModel?)
        case accessTokenSave(TokenRenewal?)
    }
    
    // Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case setMyInfo(MyInfoRPModelData?)
        case setNickNameCheck(SignUpNameRPModelData?)
        case setImageUpload(OneImageUploadRPModelData?)
        case setUserUpdateSuccess(Bool?)
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
        var isMyInfo: MyInfoRPModelData?
        var isNickNameCheck: SignUpNameRPModelData?
        var isImageUploadSuccess: OneImageUploadRPModelData?
        var isUserUpdateSuccess: Bool?
        var isTokenRenewal: (TokenRenewal?)
        var isAccessTokenSave: (TokenRenewal?)
        var isLogin: Bool?
        var isIndicator: Bool?
        var isErrors: (Bool?,Int?)
        var isTokenError: (Bool?,TokenRenewal?)
        var isTimeOut:Bool?
    }
    
    let initialState: State
    
    init() {
        self.initialState = State()
        myInfoService = MyInfoService()
        signUpNameService = SignUpNameService()
        userInfoUpdateService = UserInfoUpdateService()
        oneImageUploadService = OneImageUploadService()
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
                    tokenRenewal().map{ result in TokenRenewal(accessToken: result ,eventIndex: 0)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)), //재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false)) //갱신 후
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                    getMyInfo()
                    .map{ result in
                        if result.errors == nil {
                            return Mutation.setMyInfo(result.data)
                        }else {
                            if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                return Mutation.setTokenError(true, TokenRenewal(eventIndex:0))
                            }else {
                                return Mutation.setErrors(true, 0)
                            }
                        }
                    }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setMyInfo(nil)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setIndicator(false)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil))
                ])
            }
        case let .nickNameCheck(params) :
            if tokenState() == 0 {
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
                    getNickNameCheck(params: params!)
                        .map{ result in
                            if result.errors == nil {
                                return Mutation.setNickNameCheck(result.data)
                            }else {
                                if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                    return Mutation.setTokenError(true, TokenRenewal(nickNameParams: params,eventIndex:1))
                                }else {
                                    return Mutation.setErrors(true, 1)
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setNickNameCheck(nil)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil))
                ])
            }
        case let .imageUpload(profileImage) :
            if tokenState() == 0 {
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
                    Observable.just(Mutation.setTimeOut(false))//갱신 후
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                    oneImageUpload(imageParam: profileImage!)
                    .map{ result in
                        if result.errors == nil {
                            return Mutation.setImageUpload(result.data)
                        }else {
                            if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                return Mutation.setTokenError(true, TokenRenewal(imageParams:profileImage,eventIndex:2))
                            }else {
                                return Mutation.setErrors(true, 2)
                            }
                        }
                    }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setImageUpload(nil)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setIndicator(false)),
                    Observable.just(Mutation.setErrors(nil,nil)),
                    Observable.just(Mutation.setTokenError(nil, nil))
                ])
            }
        case let .userUpdate(params) :
            if tokenState() == 1 { //토큰 만료
                return Observable.concat([ //contat : 배열 순서대로 Observable실행
                    tokenRenewal().map{ result in TokenRenewal(accessToken: result ,eventIndex: 3)}
                        .map{Mutation.setTokenRenewal($0)}.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setTokenRenewal(nil)),//재호출 방지를 위해 초기화
                    Observable.just(Mutation.setTimeOut(false)) //갱신 후
                ])
            }else { //토큰 정상
                return Observable.concat([
                    Observable.just(Mutation.setIndicator(true)),
                    putUserInfoUpdate(params: params!)
                        .map{ result in
                            if result.errors == nil {
                                return Mutation.setUserUpdateSuccess(true)
                            }else {
                                if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                                    return Mutation.setTokenError(true, TokenRenewal(params:params,eventIndex:3))
                                }else {
                                    return Mutation.setErrors(true, 3)
                                }
                            }
                        }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                        .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                    Observable.just(Mutation.setUserUpdateSuccess(false)),
                    Observable.just(Mutation.setTimeOut(false)),
                    Observable.just(Mutation.setIndicator(false)),
                    Observable.just(Mutation.setErrors(false, nil)),
                    Observable.just(Mutation.setTokenError(false, nil))
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
        case let .setMyInfo(myInfoRPModel):
            state.isMyInfo = myInfoRPModel
        case let .setNickNameCheck(signUpNameRPModel) :
            state.isNickNameCheck = signUpNameRPModel
        case let .setImageUpload(oneImageUploadRPModel) :
            state.isImageUploadSuccess = oneImageUploadRPModel
        case let .setUserUpdateSuccess(SuccessRPModel) :
            state.isUserUpdateSuccess = SuccessRPModel
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
        case let .setTimeOut(flag) :
            state.isTimeOut = flag
        }
        
        return state
    }

    //사용자 정보 조회
    func getMyInfo() -> Observable<MyInfoRPModel> {
        return myInfoService.getMyInfo()
    }
    
    //닉네임 중복 체크
    func getNickNameCheck(params:[String:Any]) -> Observable<SignUpNameRPModel> {
        return signUpNameService.checkEmailOverlap(params: params)
    }
    
    //유저정보 업데이트
    func putUserInfoUpdate(params:UserInfoUpdateRQModel) -> Observable<SuccessRPModel> {
        return userInfoUpdateService.putUserInfoUpdate(params: params)
    }
    
    //이미지 업로드
    func oneImageUpload(imageParam:UIImage) -> Observable<OneImageUploadRPModel> {
        return oneImageUploadService.oneImageUpload(imageParam: imageParam)
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
