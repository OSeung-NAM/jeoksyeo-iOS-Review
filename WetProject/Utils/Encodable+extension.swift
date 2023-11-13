//
//  Encodable+extension.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/15.
//

import Foundation

//Dictionary 로 변환하기 위한 Encodable 확장파일
extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
    
}
