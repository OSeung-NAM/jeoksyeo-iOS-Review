//
//  MainBannerRPModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/02.
//
import Foundation

//메인화면 배너리스트 조회 API 호출 후 성공 Response데이터를 담기위한 모델
struct MainBannerRPModel : Codable {
    let errors: Errors?
    let data : MainBannerRPModelData?
}

struct MainBannerRPModelData : Codable {
    let banner : [MainBanner]?
    
    enum CodingKeys: String, CodingKey {
        case banner = "banner"
    }
}

struct MainBanner : Codable {
    let url : String
    let name : String
    let media : Media
}
