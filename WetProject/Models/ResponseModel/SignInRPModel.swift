//
//  SignUpRP.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/15.
//

import Foundation

//로그인 API호출 후 성공 Response데이터를 담기 위한 모델
struct SignInRPModel: Codable {
    let errors: Errors?
    var data: SignInRPModelData?
}

// MARK: - SignUpRPModelData
struct SignInRPModelData: Codable {
    var user: User?
    var token: UserToken?
}

// MARK: - User
struct User: Codable {
    var userID, gender: String
    var email : String
    var hasEmail : Bool
    var hasGender: Bool
    var nickname: String
    var hasNickname: Bool
    var birth: String
    var hasBirth: Bool

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email = "email"
        case hasEmail = "has_email"
        case gender
        case hasGender = "has_gender"
        case nickname
        case hasNickname = "has_nickname"
        case birth
        case hasBirth = "has_birth"
    }
}

struct UserToken: Codable {
    var accessToken: String
    var refreshToken: String
}
