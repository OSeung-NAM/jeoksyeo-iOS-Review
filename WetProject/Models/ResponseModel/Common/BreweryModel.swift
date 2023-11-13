//
//  BreweryModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/13.
//

import Foundation

//양조장 단건 전용 데이터 모델
struct Brewery : Codable {
    let breweryId : String?
    let location : String?
    let name : String?
    
    enum CodingKeys: String, CodingKey {
        case breweryId = "brewery_id"
        case location = "location"
        case name = "name"
    }
}
