//
//  AlcoholLikeService.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/27.
//

import Foundation
import RxSwift

//주류 좋아요, 좋아요취소를 위한 전용 API서비스
class AlcoholLikeService:APIUrlService,RequestService,ModelToDictionary {

    typealias NetworkData = SuccessRPModel
    
    func setAlcoholLike(params:[String:Any]?,pathParams:[String:String],flag:Bool)-> Observable<NetworkData> {
        let alcoholId:String = pathParams["alcoholId"] ?? ""
        
        //API URL
        let url = AlcoholLikeOnService.serviceUrl(version: "/v1", path: "/alcohols/\(alcoholId)/like")
        if flag {
            return postable(URL: url, body: params)
        }else {
            return deletaable(URL: url, body: params)
        }
    }
}
