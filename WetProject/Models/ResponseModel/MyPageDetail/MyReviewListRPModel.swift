//
//  MyReviewListRPModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/13.
//

import Foundation

//내 리뷰 목록 조회 API호출 후 성공 Response 데이터를 담기위한 모델
struct MyReviewListRPModel : Codable {
    let errors: Errors?
    var data : MyReviewListRPModelData?
}

struct MyReviewListRPModelData : Codable {
    var pagingInfo : PagingInfo?
    var reviewList : [ReviewList]?
    let summary : Summary?
   
    
    enum CodingKeys: String, CodingKey {
        case pagingInfo = "pagingInfo"
        case reviewList = "reviewList"
        case summary = "summary"
    }
}

struct Summary : Codable {
    let alcoholLikeCount: Int? // 내가 찜한 주류 용
    let level : Int? // 내가 평가한 주류 용
    let nickname : String? //공통
    let reviewCount : Int? // 내가 평가한 주류 용
    let profile : [Profile]?
    
    enum CodingKeys: String, CodingKey {
        case alcoholLikeCount = "alcohol_like_count"
        case level = "level"
        case nickname = "nickname"
        case reviewCount = "review_count"
        case profile = "profile"
    }
}



