//
//  NameModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/13.
//

import Foundation

//양조장,주류 이름 다국어 전용 데이터 모델
struct Name : Codable {
    let en : String?
    let kr : String?
    
    enum CodingKeys: String, CodingKey {
        case en = "en"
        case kr = "kr"
    }
}
