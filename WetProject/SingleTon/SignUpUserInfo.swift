//
//  SignUpInfo.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/21.
//

import Foundation

//회원가입 시 모델로 사용하기 위한 파일
class SignUpUserInfo {
    static let shared = SignUpUserInfo()
    var userRQInfo:SignInRQModel?
    var userRPInfo:SignInRPModelData?
}

