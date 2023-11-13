//
//  ReviewDisLike.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/27.
//

import Foundation
import RxSwift

//리뷰 싫어요, 싫어요 취소를 위한 API호출 전용 서비스
class ReviewDisLikeService:APIUrlService,RequestService,ModelToDictionary {
    
    typealias NetworkData = SuccessRPModel

    func reviewDisLike(pathParams:[String:String], flag:Bool)-> Observable<NetworkData> {
        let alcoholId: String = pathParams["alcoholId"]!
        let reviewId:String = pathParams["reviewId"]!
        
        //API URL
        let URL = ReviewDetailService.serviceUrl(version: "/v1", path: "/alcohols/\(alcoholId)/reviews/\(reviewId)/dislike")
        
        if flag {
            return postable(URL: URL, body: nil)
        }else {
            return deletaable(URL: URL, body: nil)
        }
    }
}
