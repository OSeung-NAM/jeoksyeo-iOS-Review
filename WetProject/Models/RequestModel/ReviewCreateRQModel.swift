//
//  ReviewCreateRQModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/25.
//

import Foundation

//리뷰 생성 API호출 시 Request 파라메터를 위한 모델
struct ReviewWriteRQModel: Codable {
    var contents: String
    var aroma: Double
    var mouthfeel: Double
    var taste: Double
    var appearance: Double
    var overall: Double
}
