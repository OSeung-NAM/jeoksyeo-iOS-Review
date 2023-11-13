//
//  SignUpRT.swift
//  WetProject
//
//  Created by 남오승 on 2020/12/02.
//

import ReactorKit
import RxSwift

//유저 회원가입 관련 ReactorKit 아키텍쳐 파일(유저 닉네임 체크, 지역정보호출, 회원가입 관련 서비스 컨트롤)
final class SignUpRT: Reactor {
    // Action is an user interaction

    fileprivate let signUpNameService: SignUpNameService
    fileprivate let signUpAreaService: SignUpAreaService
    fileprivate let signUpService: SignUpService
    

    enum Action {
        case nickNameCheck([String:Any]?)
        case area([String:Any]?)
        case signUp(SignInRQModel?)
    }
    
    enum Mutation {
        case setNickNameCheck(Bool?)
        case setArea([SignUpAreaList]?)
        case setSignUp(SignInRPModelData?)
        case setIndicator(Bool?)
        case setErrors(Bool?)
        case setTimeOut(Bool?)
    }
    
    struct State {
        var isNickNameCheck: Bool?
        var isArea: [SignUpAreaList]?
        var isSignUp: SignInRPModelData?
        var isIndecator : Bool?
        var isErrors: Bool?
        var isTimeOut: Bool?
    }
    
    let initialState: State
    
    init() {
        self.initialState = State()
        signUpNameService = SignUpNameService()
        signUpAreaService = SignUpAreaService()
        signUpService = SignUpService()
    }
    
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .nickNameCheck(params) :
            return Observable.concat([
                getNickNameCheck(params: params!)
                    .map{ result in
                        if result.errors == nil {
                            return Mutation.setNickNameCheck(result.data?.result)
                        }else {
                            return Mutation.setErrors(true)
                        }
                    }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                    .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                Observable.just(Mutation.setNickNameCheck(nil)),
                Observable.just(Mutation.setTimeOut(false)),
                Observable.just(Mutation.setErrors(nil))
            ])
        case let .area(params) :
            return Observable.concat([
                getArea(params: params)
                    .map{ result in
                        if result.errors == nil {
                            return Mutation.setArea(result.data.areaList)
                        }else {
                            return Mutation.setErrors(true)
                        }
                    }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                    .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                Observable.just(Mutation.setArea(nil)),
                Observable.just(Mutation.setTimeOut(false)),
                Observable.just(Mutation.setErrors(nil))
                
            ])
        case let .signUp(params) :
            return Observable.concat([
                Observable.just(Mutation.setIndicator(true)),
                signUp(params: params)
                    .map{ result in
                        if result.errors == nil {
                            return Mutation.setSignUp(result.data)
                        }else {
                            return Mutation.setErrors(true)
                        }
                    }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                    .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                Observable.just(Mutation.setSignUp(nil)),
                Observable.just(Mutation.setTimeOut(false)),
                Observable.just(Mutation.setErrors(nil)),
                Observable.just(Mutation.setIndicator(false))
            ])
        }
    }
    
    // Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setNickNameCheck(signUpNameRPModel) :
            state.isNickNameCheck = signUpNameRPModel
        case let .setArea(signUpAreaRPModel) :
            state.isArea = signUpAreaRPModel
        case let .setSignUp(signInRPModel) :
            state.isSignUp = signInRPModel
        case let .setIndicator(flag) :
            state.isIndecator = flag
        case let .setErrors(flag) :
            state.isErrors = (flag)
        case let .setTimeOut(flag) :
            state.isTimeOut = flag
        }
        
        return state
    }
 
    //닉네임 중복 체크
    func getNickNameCheck(params:[String:Any]) -> Observable<SignUpNameRPModel> {
        return signUpNameService.checkEmailOverlap(params: params)
    }
    
    //지역정보 가져오기
    func getArea(params:[String:Any]?) -> Observable<SignUpAreaRPModel> {
        return signUpAreaService.getSignUpArea(params: params)
    }
    
    //회원가입
    func signUp(params:SignInRQModel?) -> Observable<SignInRPModel> {
        return signUpService.signUp(params: params!)
    }
}
