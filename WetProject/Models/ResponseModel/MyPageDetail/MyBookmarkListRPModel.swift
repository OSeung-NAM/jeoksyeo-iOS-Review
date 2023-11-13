//
//  MyBookmarkListModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/16.
//

import Foundation

//내가 찜한 목록조회 API호출 후 성공 Response 데이터를 담기위한 모델
struct MyBookmarkListRPModel : Codable {
    let errors: Errors?
    var data : MyBookmarkListRPModelData?
}

struct MyBookmarkListRPModelData : Codable {
    
    var alcoholList : [AlcoholList]?
    let pagingInfo : PagingInfo?
    let summary : Summary?
    
    enum CodingKeys: String, CodingKey {
        case alcoholList = "alcoholList"
        case pagingInfo = "pagingInfo"
        case summary = "summary"
    }
    
}
