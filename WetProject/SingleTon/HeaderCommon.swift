//
//  HeaderCommon.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/09.
//

import Foundation
import Alamofire

//API통신 헤더 전용 공통 파일
class HeaderCommon {
    
    static let shareInstance = HeaderCommon()
    
    func headerSetting()-> HTTPHeaders{
        let accessToken:String? = UserDefaults.standard.string(forKey: "accessToken")
        let requestUUID: String = UUID().uuidString.lowercased()

        let userAgent:String = HTTPHeader.defaultUserAgent.value.replacingOccurrences(of: "적셔", with: "JeokSyeo")
        var headers: HTTPHeaders = [
            "Content-Type":"application/json",
            "Accept":"application/json",
            "X-Request-Id":requestUUID,
            "user-agent":userAgent
        ]

        if let accessToken:String = accessToken {
            headers.add(name: "Authorization", value: "Bearer " + accessToken)
        }
        
        return headers
    }
}
