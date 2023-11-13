//
//  SettingsService.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/13.
//

import Foundation
import RxSwift

//앱 버전 조회를 위한 API호출 전용 서비스
class AppVersionService:APIUrlService,RequestService,ModelToDictionary {
    
    typealias NetworkData = AppVersionRPModel
    
    //API URL
    let URL = serviceUrl(version: "/v1", path: "/manage/version/ios")

    func getAppVersion()-> Observable<NetworkData> {
        return getable(URL: URL, body: nil)
    }
}
