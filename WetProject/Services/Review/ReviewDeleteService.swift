//
//  ReviewDeleteService.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/22.
//

import Foundation
import RxSwift

//리뷰 삭제를 위한 API호출 전용 서비스
class ReviewDeleteService:APIUrlService,RequestService,ModelToDictionary {
    typealias NetworkData = SuccessRPModel
    
    
    func deleteReview(params:[String:Any]?,pathParams:[String:String])-> Observable<NetworkData> {
        let alcoholId:String = pathParams["alcoholId"] ?? ""
        let reviewId:String = pathParams["reviewId"] ?? ""
        
        //API URL
        let url = ReviewDeleteService.serviceUrl(version: "/v1", path: "/alcohols/\(alcoholId)/reviews/\(reviewId)")
        return deletaable(URL: url, body: nil)
    }
}
