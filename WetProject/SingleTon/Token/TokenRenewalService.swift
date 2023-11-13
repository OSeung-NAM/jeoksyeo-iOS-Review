//
//  TokenRenewalService.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/16.
//

import RxSwift

//만료된 토큰 갱신을 위한 서비스 파일
class TokenRenewalService:APIUrlService,RequestService,ModelToDictionary {

    static let shareInstance = TokenRenewalService()

    typealias NetworkData = TokenRenewalRPModel
    
    //API URL
    let URL = serviceUrl(version: "/v1", path: "/auth/token/refresh")
    
    //토큰 갱신 서비스
    func tokenRenewal()-> Observable<NetworkData>{
        let refreshToken:String = UserDefaults.standard.string(forKey: "refreshToken") ?? ""
      
        let tokenRenewalRQModel:TokenRenewalRQModel = TokenRenewalRQModel(refresh_token: refreshToken)
        let bodyParams = TokenRenewalService.modelToDictionary(model: tokenRenewalRQModel)
        
        return postable(URL: URL, body: bodyParams)
    }
}
