//
//  AlcoholDetailReviewService.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/26.
//

import Foundation
import RxSwift

//주류 상세정보 - 리뷰파트 조회를 위한 전용 API호출 서비스
class AlcoholDetailReviewService:APIUrlService,RequestService,ModelToDictionary {
    
    typealias NetworkData = AlcoholDetailReviewRPModel

    func getAlcoholDetailReview(pathParams:[String:String], params:[String:Int]?)-> Observable<NetworkData> {
        let alcoholId: String = pathParams["alcoholId"]!

        //API URL
        let URL = AlcoholDetailService.serviceUrl(version: "/v1", path: "/alcohols/\(alcoholId)/reviews")
        return getable(URL: URL, body: params)
    }
}
