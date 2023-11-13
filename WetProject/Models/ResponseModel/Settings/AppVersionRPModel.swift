//
//  AppVersionRPModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/13.
//

import Foundation

//앱버전 조회 API호출 후 성공 Response 데이터를 담기 위한 모델
struct AppVersionRPModel: Codable {
    let errors: Errors?
    let data: AppVersionRPModelData
}

struct AppVersionRPModelData: Codable {
    let changeLog : String? //업데이트 내역
    let platform : String?
    let version : String?
    
    enum CodingKeys: String, CodingKey {
        case changeLog = "change_log"
        case platform = "platform"
        case version = "version"
    }
}

