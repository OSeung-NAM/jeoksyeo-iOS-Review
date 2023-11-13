//
//  AlcoholDetailRPModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/26.
//

import Foundation

//주류 상세화면 주류정보 조회 API호출 후 성공 Response 데이터를 담기위한 모델
struct AlcoholDetailRPModel : Codable {
    let errors: Errors?
    let data : AlcoholDetailRPModelData?
}

struct AlcoholDetailRPModelData : Codable {
    let alcohol : AlcoholDetail?
    
    enum CodingKeys: String, CodingKey {
        case alcohol = "alcohol"
    }
}
