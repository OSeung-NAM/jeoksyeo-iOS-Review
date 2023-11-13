//
//  TokenRenewalModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/16.
//


import Foundation

//토큰 갱신 시 Request파라메터를 위한 모델
struct TokenRenewalRQModel: Codable {
    let refresh_token: String
}
