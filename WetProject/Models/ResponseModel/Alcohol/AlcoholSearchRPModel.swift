//
//  AlcoholSearchRPModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/16.
//

import Foundation

//주류 검색 API호출 후 성공 Response 데이터를 담기위한 모델
struct AlcoholSearchRPModel : Codable {
    let errors : Errors?
    let data : AlcoholSearchRPModelData?
}

struct AlcoholSearchRPModelData : Codable {
    
    let alcoholList : [AlcoholList]?
    let pagingInfo : PagingInfo?
    
    enum CodingKeys: String, CodingKey {
        case alcoholList = "alcoholList"
        case pagingInfo = "pagingInfo"
    }
}
