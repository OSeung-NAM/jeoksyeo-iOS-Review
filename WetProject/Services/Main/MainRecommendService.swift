//
//  MainRecommendService.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/26.
//

import Foundation
import RxSwift

//메인화면 주류 추천 전용 API호출 서비스
class MainRecommendService:APIUrlService,RequestService,ModelToDictionary {
    
    typealias NetworkData = MainRecommendRPModel
    
    //API URL
    let URL = serviceUrl(version: "/v1", path: "/main/recommend")
    
    //주류추천 데이터 호출
    func getMainRecommend(params:[String:Any]?)-> Observable<NetworkData> {
        return getable(URL: URL, body: params)
    }
}
