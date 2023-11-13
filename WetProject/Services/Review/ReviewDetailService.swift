//
//  ReviewDetailService.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/16.
//

import Foundation
import RxSwift

//리뷰 단건조회를 위한 API 호출 전용 서비스
class ReviewDetailService:APIUrlService,RequestService,ModelToDictionary {
    
    typealias NetworkData = ReviewDetailRPModel

    func getReviewDetail(pathParams:[String:String]?)-> Observable<NetworkData> {
        let alcoholId: String = pathParams!["alcoholId"]!
        let reviewId: String = pathParams!["reviewId"]!

        //API URL
        let URL = ReviewDetailService.serviceUrl(version: "/v1", path: "/alcohols/\(alcoholId)/reviews/\(reviewId)")
        return getable(URL: URL, body: nil)
    }
}
