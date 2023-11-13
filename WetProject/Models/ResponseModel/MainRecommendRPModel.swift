//
//  MainRecommendRPModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/26.
//

//메인화면 주류추천 조회API호출 후 성공 Response데이터를 담기위한 모델
struct MainRecommendRPModel : Codable {
    let errors: Errors?
    var data : MainRecommendRPModelData?
}

struct MainRecommendRPModelData : Codable {
    var alcoholList : [MainRecommendAlcoholList]?
    
    enum CodingKeys: String, CodingKey {
        case alcoholList = "alcoholList"
    }
}
struct MainRecommendAlcoholList : Codable, Equatable {
    static func == (lhs: MainRecommendAlcoholList, rhs: MainRecommendAlcoholList) -> Bool {
        return lhs.alcoholId == rhs.alcoholId
    }
    
    let abv : Double?
    let alcoholId : String
    var alcoholLikeCount : Int?
    let capacity : Int?
    let classField : Class?
    var isLiked : Bool?
    let media : [Media]?
    let name : Name?
    let review : Review?
    
    enum CodingKeys: String, CodingKey {
        case abv = "abv"
        case alcoholId = "alcohol_id"
        case alcoholLikeCount = "alcohol_like_count"
        case capacity = "capacity"
        case classField = "class"
        case isLiked = "isLiked"
        case media = "media"
        case name = "name"
        case review = "review"
    }
}






