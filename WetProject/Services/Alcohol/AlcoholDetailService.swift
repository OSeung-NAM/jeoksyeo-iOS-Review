//
//  AlcoholDetailService.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/26.
//

import Foundation
import RxSwift

//주류 상세정보 - 주류정보파트 조회를 위한 전용 API호출 서비스
class AlcoholDetailService:APIUrlService,RequestService,ModelToDictionary {
    
    typealias NetworkData = AlcoholDetailRPModel

    func getAlcoholDetail(pathParams:[String:String])-> Observable<NetworkData> {
        let alcoholId: String = pathParams["alcoholId"]!

        //API URL
        let URL = AlcoholDetailService.serviceUrl(version: "/v1", path: "/alcohols/\(alcoholId)")
        return getable(URL: URL, body: nil)
    }
}
