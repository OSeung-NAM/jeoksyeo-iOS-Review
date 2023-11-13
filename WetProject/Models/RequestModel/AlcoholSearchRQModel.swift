//
//  AlcoholSearchRQModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/16.
//

import Foundation

//주류검색 API호출 시 Request 파라메터를 위한 모델
struct AlcoholSearchRQModel: Codable {
    var k: String?
    var c: Int?
    var s: String?
    var p: Int?
}

