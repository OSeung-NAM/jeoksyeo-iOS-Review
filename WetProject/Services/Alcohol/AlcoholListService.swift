//
//  AlcoholTableService.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/28.
//

import RxSwift

//주류 리스트조회 전용 API호출 서비스
class AlcoholListService:APIUrlService,RequestService,ModelToDictionary {
    
    typealias NetworkData = AlcoholListRPModel
    
    //API URL
    let URL = serviceUrl(version: "/v1", path: "/alcohols")
    
    func getAlcoholList(params:AlcoholListRQModel)-> Observable<NetworkData> {
        let bodyParams = AlcoholListService.modelToDictionary(model: params)
        return getable(URL: URL, body: bodyParams)
    }
}
