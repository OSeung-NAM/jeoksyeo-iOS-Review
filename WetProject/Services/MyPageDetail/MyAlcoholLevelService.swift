//
//  MyAlcoholLevelService.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/11.
//

import RxSwift

//내 주류 레벨 조회를 위한 전용 API호출 서비스
class MyAlcoholLevelService:APIUrlService,RequestService,ModelToDictionary {

    typealias NetworkData = MyAlcoholLevelRPModel
    
    //API URL
    let URL = serviceUrl(version: "/v1", path: "/users/level")
    
    func getMyAlcoholLevel() -> Observable<NetworkData>{
        return getable(URL: URL, body: nil)
    }
}
