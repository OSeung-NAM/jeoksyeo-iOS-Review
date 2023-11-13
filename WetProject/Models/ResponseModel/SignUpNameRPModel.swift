//
//  SignUpNameRPModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/22.
//

import Foundation

//회원가입 및 회원정보 변경 시 닉네임 체크 관련 API호출 후 성공 Response데이터를 담기 위한 모델
struct SignUpNameRPModel: Codable {
    let errors: Errors?
    var data: SignUpNameRPModelData?
}

// MARK: - SignUpNameRPModelData
struct SignUpNameRPModelData: Codable {
    var result : Bool
}
