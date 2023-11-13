//
//  MyReviewListService.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/13.
//

import RxSwift

//내가 작성한 리뷰 리스트 조회를 위한 API 호출 서비스
class MyReviewListService:APIUrlService,RequestService,ModelToDictionary {

    typealias NetworkData = MyReviewListRPModel
    
    //API URL
    let URL = serviceUrl(version: "/v1", path: "/users/reviews")
    
    func getMyReviewList(params:MyReviewListRQModel?) -> Observable<NetworkData>{
        let params = MyReviewListService.modelToDictionary(model: params)
        return getable(URL: URL, body: params)
    }
}
