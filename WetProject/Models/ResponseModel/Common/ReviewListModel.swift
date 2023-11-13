//
//  ReviewListModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/13.
//

import Foundation

//리뷰 리스트 관련 데이터 모델
struct ReviewList : Codable {
    let alcohol : Alcohol?
    let contents : String?
    let createdAt : Int?
    let reviewId : String?
    let score : Float?
    let updatedAt : Int?
    var expandFlag : Bool = false //접고 펼치기 여부
    var disLikeCount : Int?
    var hasDisLike : Bool?
    var hasLike : Bool?
    let level : Int?
    var likeCount : Int?
    let nickname : String?
    let profile : [Profile]?
    
    enum CodingKeys: String, CodingKey {
        case alcohol = "alcohol"
        case contents = "contents"
        case createdAt = "created_at"
        case reviewId = "review_id"
        case score = "score"
        case updatedAt = "updated_at"
        case disLikeCount = "dislike_count"
        case hasDisLike = "has_dislike"
        case hasLike = "has_like"
        case level = "level"
        case likeCount = "like_count"
        case nickname = "nickname"
        case profile = "profile"
    }
    
}
