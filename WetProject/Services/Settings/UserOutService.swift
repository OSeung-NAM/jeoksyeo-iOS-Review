//
//  UserOutService.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/20.
//

import RxSwift

//유저 회원탈퇴 전용 API호출 서비스
class UserOutService:APIUrlService,RequestService,ModelToDictionary {
    
    typealias NetworkData = SuccessRPModel
    
    //API URL
    let URL = serviceUrl(version: "/v1", path: "/users/close")

    func deleteUser()-> Observable<NetworkData> {
        return deletaable(URL: URL, body: nil)
    }
}
