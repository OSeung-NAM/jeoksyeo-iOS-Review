//
//  SignUpNameService.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/22.
//

import Foundation
import RxSwift

//회원가입, 유저정보 변경 시 닉네임 중복 확인을 위한 전용 API호출 서비스
class SignUpNameService:APIUrlService,RequestService,ModelToDictionary {

    typealias NetworkData = SignUpNameRPModel
    
    //API URL
    let URL = serviceUrl(version: "/v1", path: "/auth/check-nickname")
    
    //이메일 중복 체크
    func checkEmailOverlap(params:[String:Any])-> Observable<NetworkData> {
 
        return getable(URL: URL, body: params)
    }
}
