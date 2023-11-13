//
//  OneImageUploadService.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/20.
//

import RxSwift

//이미지 단건 전용 API호출 서비스
class OneImageUploadService:APIUrlService,RequestService,ModelToDictionary {
    
    typealias NetworkData = OneImageUploadRPModel
    
    //API URL
    let URL = serviceUrl(version: "/v1", path: "/upload/image")

    func oneImageUpload(imageParam:UIImage)-> Observable<NetworkData> {
        return imageUpload(URL: URL, image: imageParam)
    }
}
