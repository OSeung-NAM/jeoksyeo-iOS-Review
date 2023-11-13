//
//  CountryModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/13.
//

//양조장 지역 다국어 전용 데이터 모델
struct Country : Codable {
    
    let en : String?
    let kr : String?
    
    enum CodingKeys: String, CodingKey {
        case en = "en"
        case kr = "kr"
    }
}
