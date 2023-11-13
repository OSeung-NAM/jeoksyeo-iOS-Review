//
//  SignUpAreaService.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/23.
//

import Foundation
import RxSwift

//회원가입 시 지역정보 조회를 위한 전용 API호출 서비스
class SignUpAreaService:APIUrlService,RequestService,ModelToDictionary {
  
    typealias NetworkData = SignUpAreaRPModel
    
    //API URL
    let URL = serviceUrl(version: "/v1", path: "/area")
    
    //회원가입 지역 호출
    func getSignUpArea(params:[String:Any]?)-> Observable<NetworkData> {
        return getable(URL: URL, body: params)
    }
}
