//
//  MainAlcoholRankService.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/05.
//

import Foundation
import RxSwift

//메인화면 주류 랭킹 조회 전용 API호출 서비스
class MainAlcoholRankService:APIUrlService,RequestService,ModelToDictionary {
    typealias NetworkData = MainAlcoholRankRPModel
    
    //API URL
    let URL = serviceUrl(version: "/v1", path: "/main/rank")
    
    func getMainAlcoholRank(params:[String:Any]?)-> Observable<NetworkData> {
        return getable(URL: URL, body: params)
    }
}
