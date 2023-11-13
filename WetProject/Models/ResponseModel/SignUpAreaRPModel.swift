//
//  SignUpAreaRPModefl.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/23.
//

import Foundation

//회원가입 시 지역정보 조회API호출 후 성공 Response데이터를 담기 위한 모델
struct SignUpAreaRPModel: Codable {
    let errors: Errors?
    var data: SignUpAreaRPModelData
}

// MARK: - SignUpNameRPModelData
struct SignUpAreaRPModelData: Codable {
    var areaList: [SignUpAreaList]
}
// MARK: - SignUpAreaList
struct SignUpAreaList: Codable {
    var code : String
    var name : String
}
