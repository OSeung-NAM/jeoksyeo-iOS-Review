//
//  MyInfoRPModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/12.
//

import Foundation

//내정보 페이지 API호출 후 성공 Response 데이터를 담기 위한 모델
struct MyInfoRPModel : Codable {
    let errors: Errors?
    let data : MyInfoRPModelData?
}

struct MyInfoRPModelData : Codable {
    let userInfo : UserInfo?
    
    enum CodingKeys: String, CodingKey {
        case userInfo = "userInfo"
    }
}

struct UserInfo : Codable {
    var birth : String?
    var gender : String?
    var level : Int?
    var nickname : String?
    var profile : [Profile]?
    var role : String?
    var userId : String?
    var profileUrl : String?
    
    enum CodingKeys: String, CodingKey {
        case birth = "birth"
        case gender = "gender"
        case level = "level"
        case nickname = "nickname"
        case profile = "profile"
        case role = "role"
        case userId = "user_id"
        case profileUrl = "profileUrl"
    }
}

struct Profile : Codable {
    let mediaId : String?
    let mediaResource : MediaResource?
    let type : String?
    
    enum CodingKeys: String, CodingKey {
        case mediaId = "media_id"
        case mediaResource = "media_resource"
        case type = "type"
    }
    
}
