//
//  AlcoholSearchService.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/16.
//

import Foundation
import RxSwift

//주류 검색을 위한 API 호출 전용 서비스
class AlcoholSearchService:APIUrlService,RequestService,ModelToDictionary {
    
    typealias NetworkData = AlcoholSearchRPModel
    
    //API URL
    let URL = serviceUrl(version: "/v1", path: "/alcohols/search")
    
    func getAlcoholSearch(params:AlcoholSearchRQModel?)-> Observable<NetworkData> {
        let bodyParams = TokenRenewalService.modelToDictionary(model: params)
        return getable(URL: URL, body: bodyParams)
    }
}
