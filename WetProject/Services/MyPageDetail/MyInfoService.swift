//
//  MyInfoService.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/12.
//

import RxSwift

//내 정보 조회를 위한 API호출 서비스
class MyInfoService:APIUrlService,RequestService,ModelToDictionary {

    typealias NetworkData = MyInfoRPModel
    
    //API URL
    let URL = serviceUrl(version: "/v1", path: "/users")
    
    func getMyInfo() -> Observable<NetworkData>{
        return getable(URL: URL, body: nil)
    }
}
