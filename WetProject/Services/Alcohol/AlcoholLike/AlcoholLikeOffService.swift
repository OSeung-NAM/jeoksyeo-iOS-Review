//
//  AlcoholLikeOffService.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/05.
//

import Foundation
import RxSwift

//주류 좋아요취소를 위한 전용 API호출 서비스
class AlcoholLikeOffService:RequestService,ModelToDictionary {
 
    typealias NetworkData = SuccessRPModel
    
    func setAlcoholLikeOff(params:[String:Any]?,pathParams:[String:String])-> Observable<NetworkData> {
        let alcoholId:String = pathParams["alcoholId"] ?? ""
        
        //API URL
        let url = AlcoholLikeOnService.serviceUrl(version: "/v1", path: "/alcohols/\(alcoholId)/like")
        return deletaable(URL: url, body: params)
            .asObservable()
    }
}
