//
//  UserInfoUpdateRQModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/20.
//

import Foundation

//유저 정보 변경 API호출 시 Request 파라메터를 위한 모델
struct UserInfoUpdateRQModel:Codable {
    var profile: UserProfileImage?
    var nickname: String
    var birth:String?
    var gender:String?
}

struct UserProfileImage:Codable {
    var type : String
    var media_id : String
}


