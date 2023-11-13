//
//  SignUpService.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/21.
//

import Foundation
import Alamofire
import RxSwift

//회원가입을 위한 전용 API호출 서비스
class SignUpService:APIUrlService,RequestService,ModelToDictionary {
 
    typealias NetworkData = SignInRPModel
    
    //API URL
    let URL = serviceUrl(version: "/v1", path: "/auth/token")
    
    func signUp(params:SignInRQModel)-> Observable<NetworkData> {
        let bodyParams = TokenRenewalService.modelToDictionary(model: params)
        return postable(URL: URL, body: bodyParams)
    }
}
