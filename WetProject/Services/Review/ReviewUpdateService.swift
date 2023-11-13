//
//  ReviewUpdateService.swift
//  WetProject
//
//  Created by 남오승 on 2020/12/03.
//

import Foundation
import RxSwift

//리뷰 수정을 위한 API호출 전용 서비스
class ReviewUpdateService:APIUrlService,RequestService,ModelToDictionary {
    
    typealias NetworkData = SuccessRPModel

    func reviewUpdate(params:ReviewWriteRQModel, pathParams:[String:String])-> Observable<NetworkData> {
        let alcoholId: String = pathParams["alcoholId"]!
        let reviewId: String = pathParams["reviewId"]!
        
        let bodyParams = ReviewWriteService.modelToDictionary(model: params)
        
        //API URL
        let URL = ReviewDetailService.serviceUrl(version: "/v1", path: "/alcohols/\(alcoholId)/reviews/\(reviewId)")
        return putable(URL: URL, body: bodyParams)
    }
}
