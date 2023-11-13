//
//  OneImageUploadRPModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/20.
//


import Foundation

//이미지 단건 업로드 API호출 후 성공 Response 데이터를 담기 위한 모델
struct OneImageUploadRPModel : Codable {
    let errors:Errors?
    let data : OneImageUploadRPModelData?
}

struct OneImageUploadRPModelData : Codable {
    let mediaId : String?
    let mediaResource : MediaResource?
    
    enum CodingKeys: String, CodingKey {
        case mediaId = "media_id"
        case mediaResource = "media_resource"
    }
}
