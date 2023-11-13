//
//  ModelToDictionary.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/15.
//

import Foundation

//Model에 담긴 내용물 API Request가능하도록 변환
protocol ModelToDictionary {
    associatedtype NetworkData: Codable
    static func modelToDictionary(model:Codable) -> [String:Any]
}

//Model to Dictionary 공통
extension ModelToDictionary {
    //모델데이터 Distionary로 변환
    static func modelToDictionary(model:Codable) -> [String:Any] {
        return (try? model.asDictionary()) ?? [:]
    }
}
