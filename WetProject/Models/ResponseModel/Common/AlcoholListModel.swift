//
//  AlcoholListModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/13.
//

//주류리스트 전용 데이터 모델
struct AlcoholList : Codable {
    let abv : Double?
    let alcoholId : String?
    let brewery : [Brewery]?
    let classField : Class?
    var isLiked : Bool?
    var likeCount : Int?
    let media : [Media]?
    let name : Name?
    let review : Review?
    let viewCount : Int?
    
    enum CodingKeys: String, CodingKey {
        case abv = "abv"
        case alcoholId = "alcohol_id"
        case brewery = "brewery"
        case classField = "class"
        case isLiked = "isLiked"
        case likeCount = "like_count"
        case media = "media"
        case name = "name"
        case review = "review"
        case viewCount = "view_count"
    }
    
}
