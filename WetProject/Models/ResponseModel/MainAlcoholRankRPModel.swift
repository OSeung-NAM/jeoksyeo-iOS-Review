//
//  MainAlcoholRankRPModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/05.
//

//메인화면 주류 랭킹 조회 API 호출 후 성공 Response데이터를 담기위한 모델
struct MainAlcoholRankRPModel : Codable {
    let errors: Errors?
    let data : MainAlcoholRankRPModelData?
}

struct MainAlcoholRankRPModelData : Codable {
    public var alcoholList : [AlcoholList]
}
