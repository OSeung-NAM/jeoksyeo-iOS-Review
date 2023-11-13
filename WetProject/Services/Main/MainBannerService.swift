//
//  MainBannerService.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/02.
//

import Foundation
import RxSwift

//메인화면 배너조회 전용 API호출 서비스
class MainBannerService:APIUrlService,RequestService,ModelToDictionary {
    
    typealias NetworkData = MainBannerRPModel
    
    //API URL
    let URL = serviceUrl(version: "/v1", path: "/main/banner")
    
    func getMainBanner(params:[String:Any]?)-> Observable<NetworkData> {
        return getable(URL: URL, body: params)
    }
}
