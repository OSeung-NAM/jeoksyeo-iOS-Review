//
//  APIService.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/13.
//

protocol APIUrlService {}

//모든 API호출 시 Base가 되는 도메인 설정 서비스
extension APIUrlService {
    static func serviceUrl(version: String,path: String) -> String {
        //Plist에 등록 된 BaseUrl 호출
        return "APIUrl".getPlistInfo() + version + path
    }
}
