//
//  AlcoholListRQModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/30.
//

import Foundation

//주류 목록조회 API호출 시 Request 파라메터를 위한 모델
struct AlcoholListRQModel: Codable {
    var f: String?
    var c: Int?
    var s: String?
    var p: Int?
}
