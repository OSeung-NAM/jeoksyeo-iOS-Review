//
//  ErrorModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/15.
//

import Foundation

// MARK: - ErrorModel
//API호출 실패 Response 데이터를 담기 위한 모델
struct ErrorModel: Codable {
    let errors: Errors
}

// MARK: - Errors
struct Errors: Codable {
    let errorCode: Int
    let message: String

    enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case message
    }
}
