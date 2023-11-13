//
//  AlcoholLikeService.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/03.
//
import Foundation
import RxSwift

//주류 좋아요를위한 전용 API호출 서비스
class AlcoholLikeOnService:APIUrlService,RequestService,ModelToDictionary {

    typealias NetworkData = SuccessRPModel
    
    func setAlcoholLikeOn(params:[String:Any]?,pathParams:[String:String])-> Observable<NetworkData> {
        let alcoholId:String = pathParams["alcoholId"] ?? ""
        
        //API URL
        let url = AlcoholLikeOnService.serviceUrl(version: "/v1", path: "/alcohols/\(alcoholId)/like")
        return postable(URL: url, body: params)
    }
}
