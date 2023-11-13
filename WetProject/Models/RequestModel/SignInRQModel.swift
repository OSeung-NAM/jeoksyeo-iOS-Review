//
//  SignUpRQ.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/15.
//

import Foundation

//로그인 API호출 시 Request 파라메터를 위한 모델
struct SignInRQModel: Codable {
    var oauth_provider: String
    var oauth_token: String
    var user_id: String?
    var nickname: String?
    var birth: String?
    var gender: String?
    var address: String?
    var device_platform: String?
    var device_model: String?
    var device_id: String?
    var device_token: String?
}


