//
//  ReviewCreateService.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/25.
//

import Foundation
import RxSwift

//리뷰 생성을 위한 API호출 전용 서비스
class ReviewWriteService:APIUrlService,RequestService,ModelToDictionary {
    
    typealias NetworkData = SuccessRPModel

    func reviewWrite(params:ReviewWriteRQModel, pathParams:[String:String])-> Observable<NetworkData> {
        let alcoholId: String = pathParams["alcoholId"]!
        let bodyParams = ReviewWriteService.modelToDictionary(model: params)
        
        //API URL
        let URL = ReviewDetailService.serviceUrl(version: "/v1", path: "/alcohols/\(alcoholId)/reviews")
        return postable(URL: URL, body: bodyParams)
    }
}
