//
//  ReviewCreatedService.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/16.
//

import Foundation
import RxSwift

//리뷰생성여부 조회를 위한 API 호출 전용 서비스
class ReviewCreatedService:APIUrlService,RequestService,ModelToDictionary {
    
    typealias NetworkData = ReviewCreatedRPModel

    
    func getReviewCreated(pathParams:[String:String]?)-> Observable<NetworkData> {
        let alcoholId: String = pathParams!["alcoholId"]!
       
        //API URL
        let URL = ReviewDetailService.serviceUrl(version: "/v1", path: "/alcohols/\(alcoholId)/reviews/check")
        return getable(URL: URL, body: nil)
    }
}
