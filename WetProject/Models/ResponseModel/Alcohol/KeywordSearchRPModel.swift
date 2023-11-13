//
//  SearchRPModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/16.
//

import Foundation

//키워드 자동완성 API호출 후 성공 Response 데이터를 담기위한 모델
struct KeywordSearchRPModel:Codable {
    let errors: Errors?
    let data: KeywordSearchRPModelData
}

struct KeywordSearchRPModelData: Codable {
    let alcoholList:[String]?
}
