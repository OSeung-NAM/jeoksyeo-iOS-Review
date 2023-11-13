//
//  ReviewModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/13.
//

import Foundation

//리뷰 작성, 업데이트 공통 데이터 모델
struct Review : Codable {
    let reviews:[Reviews]?
    let reviewCount : Int?
    let score : Float?
    let alcohol : AlcoholReviewDetail?
    let appearance : Float? //리뷰 디테일용
    let aroma : Float? //리뷰 디테일용
    let contents : String? //리뷰 디테일용
    let createdAt : Int? //리뷰 디테일용
    let mouthfeel : Float? //리뷰 디테일용
    let overall : Float? //리뷰 디테일용
    let reviewDislikeCount : Int? //리뷰 디테일용
    let reviewId : String? //리뷰 디테일용
    let reviewLikeCount : Int? //리뷰 디테일용
    let taste : Float? //리뷰 디테일용
    let updatedAt : Int? //리뷰 디테일용
    
    
    enum CodingKeys: String, CodingKey {
        case reviews = "reviews"
        case reviewCount = "review_count"
        case score = "score"
        case alcohol = "alcohol"
        case appearance = "appearance"
        case aroma = "aroma"
        case contents = "contents"
        case createdAt = "created_at"
        case mouthfeel = "mouthfeel"
        case overall = "overall"
        case reviewDislikeCount = "review_dislike_count"
        case reviewId = "review_id"
        case reviewLikeCount = "review_like_count"
        case taste = "taste"
        case updatedAt = "updated_at"
    }
}

struct Reviews : Codable {
    let reviewId:String
    let contents:String
    
    enum CodingKeys: String, CodingKey {
        case reviewId = "review_id"
        case contents = "contents"
    }
}
