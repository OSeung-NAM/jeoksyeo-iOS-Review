//
//  MyBookmarkListService.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/16.
//

import Foundation
import RxSwift

//내가 찜한 주류 리스트 조회를 위한 API호출 서비스
class MyBookmarkListService:APIUrlService,RequestService,ModelToDictionary {
    
    typealias NetworkData = MyBookmarkListRPModel
    
    //API URL
    let URL = serviceUrl(version: "/v1", path: "/users/likes/alcohol")
    
    func getMyBookmarkList(params:MyReviewListRQModel?)-> Observable<NetworkData> {
        let params = MyBookmarkListService.modelToDictionary(model: params)
        return getable(URL: URL, body: params)
    }
}
