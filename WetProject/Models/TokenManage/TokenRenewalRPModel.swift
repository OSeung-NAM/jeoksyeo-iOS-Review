//
//  TokenRenewalRPModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/16.
//

import Foundation

//토큰 갱신 API 호출 후 성공 Response 데이터를 담기 위한 모델
struct TokenRenewalRPModel: Codable {
    let errors: Errors?
    let data: TokenRenewalData?
}

// MARK: - TokenRenewalData
struct TokenRenewalData: Codable {
    let token: TokenRenewal
}

// MARK: - TokenRenewal
struct TokenRenewal: Codable {
    let accessToken: String
}
