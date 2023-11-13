//
//  MyRevelRPModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/11.
//

import Foundation

//내 주류레벨 조회 API호출 후 성공 Response데이터를 담기위한 모델
struct MyAlcoholLevelRPModel : Codable {
    let errors: Errors?
    let data : MyAlcoholLevelRPModelData?
}

struct MyAlcoholLevelRPModelData : Codable {
    let level : Int?
    let level5Rank : Int?
    let reviewCount : Int?
    
    enum CodingKeys: String, CodingKey {
        case level = "level"
        case level5Rank = "level_5_rank"
        case reviewCount = "review_count"
    }
}
