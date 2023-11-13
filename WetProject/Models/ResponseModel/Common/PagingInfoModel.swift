//
//  PagingInfoModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/13.
//

import Foundation

//페이지네이션 처리를 위한 데이터 모델
struct PagingInfo : Codable {
    let alcoholTotalCount : Int?
    var page: Int?
    let count : Int?
    let next : Bool?
    let reviewTotalCount : Int?
    
    enum CodingKeys: String, CodingKey {
        case alcoholTotalCount = "alcohol_total_count"
        case page
        case count
        case next
        case reviewTotalCount = "review_total_count"
    }
}
