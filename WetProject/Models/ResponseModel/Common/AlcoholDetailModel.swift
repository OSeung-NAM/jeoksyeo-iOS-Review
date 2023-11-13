//
//  AlcoholDetailModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/26.
//

import Foundation

//주류 상세 전용 데이터 모델
struct AlcoholDetail : Codable {
    
    let adjunct : [String]? //공통지표 : 첨가물
    let barrelAged : Bool? //공통지표 : 오크숙성
    let award : [String]? //공통지표 : 수상내역
    let container : String? //공통지표 : 용기
    let foodPairing : [String]? //공통지표 : 푸드 페어링
    let productionYear : Int? //공통지표 : 생산년도
    let sale : Bool? //공통지표 : 단종여부
    let more : More? //주류별 지표
    let abv : Double?
    let alcoholId : String?
    let backgroundMedia : [BackgroundMedia]?
    let brewery : [Brewery]?
    let capacity : Int?
    let classField : Class?
    let descriptionField : String?
    var isLiked : Bool?
    var likeCount : Int?
    let media : [Media]?
    let name : Name?
    let viewCount : Int?
    var expanded:Bool = false
    
    enum CodingKeys: String, CodingKey {
        case abv = "abv"
        case adjunct = "adjunct"
        case alcoholId = "alcohol_id"
        case award = "award"
        case backgroundMedia = "background_media"
        case barrelAged = "barrel_aged"
        case brewery = "brewery"
        case capacity = "capacity"
        case classField = "class"
        case container = "container"
        case descriptionField = "description"
        case foodPairing = "food_pairing"
        case isLiked = "isLiked"
        case likeCount = "like_count"
        case media = "media"
        case more = "more"
        case name = "name"
        case productionYear = "production_year"
        case sale = "sale"
        case viewCount = "view_count"
    }
}

struct More : Codable {
    
    let filtered : Bool? //맥주,전통주,와인,사케 : 여과여부
    let hop : [String]? //맥주 : 홉
    let ibu : Double? //맥주 : 쓴맛 지표
    let malt : [String]? //맥주,양주 : 몰트
    let srm : Srm? //맥주 : 색
    let tannin : String? //와인 : 타닌
    let acidity : String? //와인, 사케 : 산도
    let sweet : String? //와인 : 당도
    let smv : Double? //사케 : 당도
    let rpr : Double? //사케 : 정미율
    let color : Color? //전통주,와인,사케,양주 : 색
    let body : String? //전통주,와인 : 바디
    let grape : [String]? //와인 : 포도
    let caskType : String? //양주 : 캐스크 종류
    let agedYear : Double? //숙성기간 : 양주
    let type : String? //사케 : Sake Type (사케에만 존재)
    let temperature : [String]? //공통지표 : 음용온도
    
    enum CodingKeys: String, CodingKey {
        case filtered = "filtered"
        case hop = "hop"
        case ibu = "ibu"
        case malt = "malt"
        case srm = "srm"
        case tannin = "tannin"
        case acidity = "acidity"
        case sweet = "sweet"
        case smv = "smv"
        case rpr = "rpr"
        case color = "color"
        case body = "body"
        case grape = "grape"
        case caskType = "cask_type"
        case agedYear = "aged_year"
        case type = "type"
        case temperature = "temperature"
    }
}

struct Srm : Codable {
    let color : String?
    let rgbHex : String?
    let srm : Double?
    
    enum CodingKeys: String, CodingKey {
        case color = "color"
        case rgbHex = "rgb_hex"
        case srm = "srm"
    }
}

struct BackgroundMedia : Codable {
    
    let mediaId : String?
    let mediaResource : MediaResource?
    let type : String?
    
    enum CodingKeys: String, CodingKey {
        case mediaId = "media_id"
        case mediaResource = "media_resource"
        case type = "type"
    }
}

struct Color :Codable {
    let rbgHex : String?
    let name : String?
    
    enum CodingKeys: String, CodingKey {
        case rbgHex = "rgb_hex"
        case name = "name"
    }
}
