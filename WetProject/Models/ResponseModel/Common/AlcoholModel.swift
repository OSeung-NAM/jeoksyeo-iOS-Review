//
//  AlcoholModdel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/13.
//

//주류 단건 전용 데이터 모델
struct Alcohol : Codable {
    
    let alcoholId : String?
    let backgroundMedia : [BackgroundMedia]?
    let brewery : [Brewery]?
    let media : [Media]?
    let name : String?
    
    enum CodingKeys: String, CodingKey {
        case alcoholId = "alcohol_id"
        case backgroundMedia = "background_media"
        case brewery = "brewery"
        case media = "media"
        case name = "name"
    }
}
