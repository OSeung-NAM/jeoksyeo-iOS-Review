//
//  ClassModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/13.
//

import Foundation

//카테고리 세분화 전용 데이터 모델
struct Class : Codable {
    let fifthClass : FifthClass?
    let firstClass : FirstClass?
    let fourthClass : FourthClass?
    let secondClass : SecondClass?
    let thirdClass : ThirdClass?
    
    enum CodingKeys: String, CodingKey {
        case fifthClass = "fifth_class"
        case firstClass = "first_class"
        case fourthClass = "fourth_class"
        case secondClass = "second_class"
        case thirdClass = "third_class"
    }
}

struct ThirdClass : Codable {
    let code : String?
    let name : String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case name = "name"
    }
}

struct SecondClass : Codable {
    let code : String?
    let name : String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case name = "name"
    }
}

struct FourthClass : Codable {
    let code : String?
    let name : String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case name = "name"
    }
}

struct FirstClass : Codable {
    let code : String?
    let name : String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case name = "name"
    }
}

struct FifthClass : Codable {
    let code : String?
    let name : String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case name = "name"
    }
}


