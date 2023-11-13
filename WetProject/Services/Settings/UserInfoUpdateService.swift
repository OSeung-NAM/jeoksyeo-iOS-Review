//
//  UserInfoUpdateService.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/20.
//

import RxSwift

//유저정보 업데이트 를위한 API호출 전용 서비스
class UserInfoUpdateService:APIUrlService,RequestService,ModelToDictionary {
    
    typealias NetworkData = SuccessRPModel
    
    //API URL
    let URL = serviceUrl(version: "/v1", path: "/users")

    func putUserInfoUpdate(params:UserInfoUpdateRQModel)-> Observable<NetworkData> {
        let bodyParams = TokenRenewalService.modelToDictionary(model: params)
        return putable(URL: URL, body: bodyParams)
    }
}
