//
//  AlcoholDetailReviewRPModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/26.
//

import Foundation

//주류 상세화면 리뷰정보 조회 API호출 후 성공 Response 데이터를 담기위한 모델
struct AlcoholDetailReviewRPModel : Codable {
    let errors:Errors?
    let data : AlcoholDetailReviewRPModelData?
}

struct AlcoholDetailReviewRPModelData : Codable {
    
    let pageInfo : PagingInfo?
    let reviewInfo : ReviewInfo?
    let reviewList : [ReviewList]?
    let userAssessment : UserAssessment?
    
    enum CodingKeys: String, CodingKey {
        case pageInfo = "pageInfo"
        case reviewInfo = "reviewInfo"
        case reviewList = "reviewList"
        case userAssessment = "userAssessment"
    }
}

struct UserAssessment : Codable {
    
    let appearance : Double?
    let aroma : Double?
    let mouthfeel : Double?
    let overall : Double?
    let score : Double?
    let taste : Double?
    
    enum CodingKeys: String, CodingKey {
        case appearance = "appearance"
        case aroma = "aroma"
        case mouthfeel = "mouthfeel"
        case overall = "overall"
        case score = "score"
        case taste = "taste"
    }
}


struct ReviewInfo : Codable {
    let reviewTotalCount : Int?
    let score1Count : Int?
    let score2Count : Int?
    let score3Count : Int?
    let score4Count : Int?
    let score5Count : Int?
    let scoreAvg : Double?
    
    enum CodingKeys: String, CodingKey {
        case reviewTotalCount = "review_total_count"
        case score1Count = "score_1_count"
        case score2Count = "score_2_count"
        case score3Count = "score_3_count"
        case score4Count = "score_4_count"
        case score5Count = "score_5_count"
        case scoreAvg = "score_avg"
    }
}
