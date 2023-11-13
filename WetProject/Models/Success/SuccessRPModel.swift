//
//  SuccessRPModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/03.
//

import Foundation

//좋아요완료, 리뷰작성 완료 등 공통 Response Model
//API 호출성공 Response 데이터를 담기 위한 모델
struct SuccessRPModel : Codable {
    let errors: Errors?
    let data: SuccessRPModelData?
}

struct SuccessRPModelData : Codable {
    let result : String
}
