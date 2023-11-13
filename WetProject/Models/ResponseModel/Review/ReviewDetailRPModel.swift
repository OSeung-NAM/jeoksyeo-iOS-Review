//
//  ReviewDetailRPModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/16.
//

import Foundation

//리뷰 상세화면 조회 API호출 후 성공 Response 데이터를 담기 위한 모델
struct ReviewDetailRPModel : Codable {
    let errors: Errors?
    let data : ReviewDetailRPModelData?
}

struct ReviewDetailRPModelData : Codable {
    
    let review : Review?
    
    enum CodingKeys: String, CodingKey {
        case review = "review"
    }
}

struct AlcoholReviewDetail : Codable {
    
    let alcoholId : String?
    let brewery : [Brewery]?
    let media : [Media]?
    let name : Name?
    
    enum CodingKeys: String, CodingKey {
        case alcoholId = "alcohol_id"
        case brewery = "brewery"
        case media = "media"
        case name = "name"
    }
}

