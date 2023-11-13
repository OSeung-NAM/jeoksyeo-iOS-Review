//
//  SignInRT.swift
//  WetProject
//
//  Created by 남오승 on 2020/12/02.
//

import ReactorKit
import RxSwift

//유저 로그인 관련 ReactorKit 아키텍쳐 파일(유저 로그인 서비스 컨트롤)
final class SignInRT: Reactor {
    // Action is an user interaction

    fileprivate let signInService: SignInService
    
    enum Action {
        case login(SignInRQModel?)
    }
    
    // Mutate is a state manipulator which is not exposed to a view
    enum Mutation {
        case setLogin(SignInRPModelData?)
        case setIndicator(Bool?)
        case setErrors(Bool?)
        case setTimeOut(Bool?)
    }
    
    // State is a current view state(상태관리)
    struct State {
        var isLogin: SignInRPModelData?
        var isIndecator : Bool?
        var isTimeOut : Bool?
        var isErrors: Bool?
    }
    
    let initialState: State
    
    init() {
        self.initialState = State()
        signInService = SignInService()
    }
    
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .login(params) :
            return Observable.concat([
                Observable.just(Mutation.setIndicator(true)),
                signIn(signInRQModel: params).map{ result in
                    if result.errors == nil {
                        return Mutation.setLogin(result.data)
                    }else {
                        return Mutation.setErrors(true)
                    }
                }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                Observable.just(Mutation.setLogin(nil)),
                Observable.just(Mutation.setIndicator(false)),
                Observable.just(Mutation.setTimeOut(false))
            ])
        }
    }
    
    // Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setLogin(SignInRPModelData) :
            state.isLogin = SignInRPModelData
        case let .setIndicator(flag) :
            state.isIndecator = flag
        case let .setErrors(flag) :
            state.isErrors = flag
        case let .setTimeOut(flag) :
            state.isTimeOut = flag
        }
        
        return state
    }

 
    //로그인
    func signIn(signInRQModel:SignInRQModel?) -> Observable<SignInRPModel> {
        return signInService.signIn(params: signInRQModel!)
    }
}
