//
//  MyPageSideMenuRT.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/10.
//

import ReactorKit
import RxSwift

//내 주류 레벨 전용 ReactorKit 아키텍쳐 파일(내 레벨조회, 토큰 갱신 서비스 컨트롤)
final class MyAlcoholLevelRT: Reactor {
    
    fileprivate let myAlcoholLevelService: MyAlcoholLevelService
    fileprivate let tokenRenewalService: TokenRenewalService
    typealias NetworkData = MyAlcoholLevelRPModel
    
    struct TokenRenewal {
        var eventIndex:Int
    }
    
    struct AlcoholLevel {
        let level:Int //현재 레벨
        let bottleImageList:Array<UIImage> //술병 갯수 이미지
        let statusMsg:String  //주류 레벨 상태 메시지
        let nextLevelMsg:String  //다음 주류 레벨 메시지
        let remainderCnt:Int //다음 레벨까지 남은 리뷰
        let level5Rank:Int //레벨 5 달성 순서
    }

    
    //VC에서 들어오는 Event
    enum Action {
        case levelAPI
        case accessTokenSave(String?,Int?)
        case level(Int?)
        case levelImage(Int?)
    }
    
    enum Mutation {
        case setLevelAPI(MyAlcoholLevelRPModel?)
        case setLevelImage(Array<UIImage>?)
        case setLevelStateMSG(String?)
        case setLevelInfo(AlcoholLevel?)
        case setTokenRenewal(String?,Int?)
        case setAccessTokenSave(Bool?,Int?)
        case setLogin(Bool?)
        case setIndicator(Bool?)
        case setErrors(Bool?,Int?)
        case setTokenError(Bool?,TokenRenewal?)
        case setTimeOut(Bool?)
    }
    
    struct State {
        var isLevelAPI:MyAlcoholLevelRPModel?
        var isLevelImage: Array<UIImage>?
        var isLevelStateMSG: (String?)
        var isLevelInfo: (AlcoholLevel?)
        var isTokenRenewal: (String?,Int?)
        var isAccessTokenSave: (Bool?,Int?)
        var isLogin: Bool?
        var isIndecator : Bool?
        var isErrors: (Bool?,Int?)
        var isTokenError: (Bool?,TokenRenewal?)
        var isTimeOut: Bool?
    }
    
    let initialState: State
    
    //초기화
    init() {
        self.initialState = State()
        myAlcoholLevelService = MyAlcoholLevelService()
        tokenRenewalService = TokenRenewalService()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .levelAPI :
            //API호출 후 AlcoholLevel의 NetworkData에 Mapping 처리해줌
            return Observable.concat([ //contat : 배열 순서대로 Observable실행
                Observable.just(Mutation.setIndicator(true)),
                getMyAlcoholLevel().map{ [weak self] result in
                    if result.errors == nil {
                        return Mutation.setLevelInfo(AlcoholLevel(level: result.data?.level ?? 1, bottleImageList: self?.bottleSetting(reviewCnt: result.data?.reviewCount ?? 0) ?? [], statusMsg: self?.stateMSGSetting(level: result.data?.level ?? 1) ?? "", nextLevelMsg: self?.nextLevelMsg(level: result.data?.level ?? 1) ?? "", remainderCnt: self?.nextLevelRemainder(reviewCnt: result.data?.reviewCount ?? 1 ) ?? 0, level5Rank: result.data?.level5Rank ?? 0))
                    }else {
                        if result.errors?.errorCode == 11004 { // 정상적인 유저가 아님
                            return Mutation.setTokenError(true, TokenRenewal(eventIndex:0))
                        }else {
                            return Mutation.setErrors(true, 0)
                        }
                    }
                }.timeout(.seconds(20), scheduler: MainScheduler.instance) //20초 동안 동작없으면 네트워크 오류 처리하기위함
                .catchErrorJustReturn(Mutation.setTimeOut(true)), //20초 타임아웃 시 리턴되는 catch
                Observable.just(Mutation.setLevelInfo(nil)),
                Observable.just(Mutation.setTimeOut(false)),
                Observable.just(Mutation.setErrors(nil,nil)),
                Observable.just(Mutation.setTokenError(nil, nil)),
                Observable.just(Mutation.setIndicator(false))
            ])
        case let .level(level) :
            guard (self.currentState.isLevelStateMSG == nil) else { return Observable.empty() }
            return Observable.concat([ //contat : 배열 순서대로 Observable실행
                Observable.just(stateMSGSetting(level: level ?? 1))
                    .map{Mutation.setLevelStateMSG($0)},
                Observable.just(Mutation.setLevelStateMSG(nil))
            ])
        case let .levelImage(reviewCnt) :
//            guard (self.currentState.isLevelImage == nil) else { return Observable.empty() }
            return Observable.concat([ //contat : 배열 순서대로 Observable실행
                Observable.just(bottleSetting(reviewCnt: reviewCnt ?? 0))
                    .map{Mutation.setLevelImage($0)},
                Observable.just(bottleImageInit())
                    .map{Mutation.setLevelImage($0)}
            ])
        case let .accessTokenSave(token,event): //토큰 저장
            return Observable.concat([ //contat : 배열 순서대로 Observable실행
                accessTokenSave(accessToken: token)
                    .map{Mutation.setAccessTokenSave($0,event)}, //저장 후
                Observable.just(Mutation.setAccessTokenSave(nil, nil)) //토큰저장 재호출 방지를 위해 초기화
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setLevelAPI(result):
            state.isLevelAPI = result
        case let .setTokenRenewal(token,event) :
            state.isTokenRenewal = (token, event)
        case let .setLevelImage(image) :
            state.isLevelImage = image
        case let .setLevelStateMSG(msg) :
            state.isLevelStateMSG = (msg)
        case let .setLevelInfo(result) :
            state.isLevelInfo = result
        case let .setAccessTokenSave(flag,event) :
            state.isAccessTokenSave = (flag,event)
        case let .setLogin(flag) :
            state.isLogin = flag
        case let .setIndicator(flag) :
            state.isIndecator = flag
        case let .setErrors(flag,eventIndex) :
            state.isErrors = (flag,eventIndex)
        case let .setTokenError(flag, tokenRenewal) :
            state.isTokenError = (flag, tokenRenewal)
        case let .setTimeOut(flag):
            state.isTimeOut = flag
        }
        return state
    }

    //내 주류 레벨 조회
    func getMyAlcoholLevel() -> Observable<NetworkData> {
        return myAlcoholLevelService.getMyAlcoholLevel()
    }
    
    //레벨 0일때 초기 값
    func bottleImageInit() -> Array<UIImage>{
        
        let returnBottleImage = [
            UIImage.init(named: "bottleGray")!,
            UIImage.init(named: "bottleGray")!,
            UIImage.init(named: "bottleGray")!,
            UIImage.init(named: "bottleGray")!,
            UIImage.init(named: "bottleGray")!,
            UIImage.init(named: "bottleGray")!,
            UIImage.init(named: "bottleGray")!,
            UIImage.init(named: "bottleGray")!,
            UIImage.init(named: "bottleGray")!,
            UIImage.init(named: "bottleGray")!
        ]
        
        return returnBottleImage
    }
    
    //리뷰 갯수에 따른 병 on,off 수정
    func bottleSetting(reviewCnt:Int) -> Array<UIImage> {
        var returnBottleImage:Array<UIImage> = bottleImageInit()
        
        if reviewCnt < 50 && reviewCnt > 0 {
            let remainderCnt:Int = (10 - (reviewCnt+10)%10)
            for index in 1...10 {
                if index <= 10 - remainderCnt {
                    returnBottleImage.insert(UIImage.init(named: "bottleOrange")!, at: 0)
                    returnBottleImage.remove(at: returnBottleImage.count-1)
                }
                
            }
        }
        
        return returnBottleImage
    }
    
    func stateMSGSetting(level:Int) -> String {
        var returnStateMSG:String = "로그인한 후 이용해보세요!"
        
        switch level {
        case 1:
            returnStateMSG = "현재 당신은 마시는 척 하는 사람 입니다."
        case 2:
            returnStateMSG = "현재 당신은 술을 즐기는 사람 입니다."
        case 3:
            returnStateMSG = "현재 당신은 술독에 빠진 사람 입니다."
        case 4:
            returnStateMSG = "현재 당신은 주도를 수련하는 사람 입니다."
        case 5:
            returnStateMSG = "현재 당신은 술로 해탈한 사람 입니다."
        default:
            break
        }
        
        return returnStateMSG
    }
    
    //다음 레벨 멘트
    func nextLevelMsg(level:Int) -> String {
        var returnStateMSG:String = ""
        let nextLevel = level + 1
        switch nextLevel {
        case 2:
            returnStateMSG = "술을 즐기는 사람"
        case 3:
            returnStateMSG = "술독에 빠진 사람"
        case 4:
            returnStateMSG = "주도를 수련하는 사람"
        case 5:
            returnStateMSG = "술로 해탈한 사람"
        default:
            break
        }
        
        return returnStateMSG
    }
    
    func nextLevelRemainder(reviewCnt:Int) -> Int {
        if reviewCnt < 51 {
            let remainderCnt:Int = (10 - (reviewCnt+10)%10)
            return remainderCnt
        }else {
            return 0
        }
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
