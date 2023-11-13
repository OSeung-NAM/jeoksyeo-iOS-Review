//
//  AlcoholListRPModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/28.
//

import Foundation

//주류 리스트 조회 API호출 후 성공 Response데이터를 담기위한 모델
struct AlcoholListRPModel : Codable {
    let errors: Errors?
    let data : AlcoholListRPModelData?
}

struct AlcoholListRPModelData : Codable {
    
    let alcoholList : [AlcoholList]?
    let pagingInfo : PagingInfo?
    
    enum CodingKeys: String, CodingKey {
        case alcoholList = "alcoholList"
        case pagingInfo = "pagingInfo"
    }
}



