//
//  ReviewLikeService.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/27.
//

import Foundation
import RxSwift

//리뷰 좋아요, 좋아요 취소를 위한 API호출 전용 서비스
class ReviewLikeService:APIUrlService,RequestService,ModelToDictionary {
    
    typealias NetworkData = SuccessRPModel

    func reviewLike(pathParams:[String:String], flag:Bool)-> Observable<NetworkData> {
        let alcoholId: String = pathParams["alcoholId"]!
        let reviewId:String = pathParams["reviewId"]!

        //API URL
        let URL = ReviewDetailService.serviceUrl(version: "/v1", path: "/alcohols/\(alcoholId)/reviews/\(reviewId)/like")
        
        if flag {
            return postable(URL: URL, body: nil)
        }else {
            return deletaable(URL: URL, body: nil)
        }
    }
}
