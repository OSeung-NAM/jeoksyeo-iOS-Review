//
//  KeywordSearchService.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/16.
//

import Foundation
import RxSwift

//키워드 자동완성을 위한 API 호출 전용 서비스
class KeywordSearchService:APIUrlService,RequestService,ModelToDictionary {
    
    typealias NetworkData = KeywordSearchRPModel
    
    //API URL
    let URL = serviceUrl(version: "/v1", path: "/alcohols/complete")
    
    func getKeywordSearch(params:[String:Any]?)-> Observable<NetworkData> {
        return getable(URL: URL, body: params)
    }
}
