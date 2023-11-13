//
//  ReviewCreatedRPModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/16.
//

import Foundation

//리뷰 작성 생성 API호출 후 성공 Response 데이터를 담기위한 모델
struct ReviewCreatedRPModel:Codable {
    let errors: Errors?
    let data: ReviewCreatedRPModelData
}

struct ReviewCreatedRPModelData: Codable {
    let isExist:Bool
}
