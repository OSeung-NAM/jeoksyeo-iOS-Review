//
//  SignUpSVC.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/15.
//

import Foundation
import Alamofire
import RxSwift

//로그인을 위한 전용 API호출 서비스
class SignInService:APIUrlService,RequestService,ModelToDictionary {

    typealias NetworkData = SignInRPModel
    
    //API URL
    let URL = serviceUrl(version: "/v1", path: "/auth/token")
    
    func signIn(params:SignInRQModel)-> Observable<NetworkData> {
        let bodyParams = TokenRenewalService.modelToDictionary(model: params)
        return postable(URL: URL, body: bodyParams)
    }
}
