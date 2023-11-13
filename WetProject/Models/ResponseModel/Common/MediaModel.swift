//
//  MediaModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/13.
//

import Foundation

//이미지 리소스 관련 전용 데이터 모델
struct Media : Codable {
    let mediaId : String?
    let mediaResource : MediaResource?
    let type : String?
    
    enum CodingKeys: String, CodingKey {
        case mediaId = "media_id"
        case mediaResource = "media_resource"
        case type = "type"
    }
}

struct MediaResource : Codable {
    let large : Large?
    let medium : Medium?
    let small : Small?
    
    enum CodingKeys: String, CodingKey {
        case large = "large"
        case medium = "medium"
        case small = "small"
    }
}

struct Small : Codable {
    let src : String?
    
    enum CodingKeys: String, CodingKey {
        case src = "src"
    }
}

struct Medium : Codable {
    let src : String?
    
    enum CodingKeys: String, CodingKey {
        case src = "src"
    }
}
struct Large : Codable {
    let src : String?
    
    enum CodingKeys: String, CodingKey {
        case src = "src"
    }
}
