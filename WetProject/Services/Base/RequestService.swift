//
//  RequestService.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/13.
//

import Alamofire
import RxSwift
import RxAlamofire

protocol RequestService {
    associatedtype NetworkData: Codable
    func getable(URL:String, body:[String:Any]?)-> Observable<NetworkData>
    func postable(URL:String, body:[String:Any]?)-> Observable<NetworkData>
    func deletaable(URL:String, body:[String:Any]?)-> Observable<NetworkData>
    func putable(URL:String, body:[String:Any]?)-> Observable<NetworkData>
}

//모든 API호출 시 공통으로 사용 가능하도록 Alamofire 세팅한 서비스
extension RequestService {
    
    func getable(URL:String, body:[String:Any]? )-> Observable<NetworkData> {
        let headers = HeaderCommon.shareInstance.headerSetting()
        return RxAlamofire.requestData(.get, URL, parameters: body, encoding: URLEncoding.default, headers: headers, interceptor: .none)
            .mapObject(type: NetworkData.self)
    }
    
    func postable(URL:String, body:[String:Any]? )-> Observable<NetworkData> {
        let headers = HeaderCommon.shareInstance.headerSetting()
        return RxAlamofire.requestData(.post, URL, parameters: body, encoding: JSONEncoding.default, headers: headers, interceptor: .none)
            .mapObject(type: NetworkData.self)
    }
    
    func deletaable(URL:String, body:[String:Any]?)-> Observable<NetworkData> {
        let headers = HeaderCommon.shareInstance.headerSetting()
        return RxAlamofire.requestData(.delete, URL, parameters: body, encoding: JSONEncoding.default, headers: headers, interceptor: .none)
            .mapObject(type: NetworkData.self)
    }
    
    func putable(URL:String, body:[String:Any]?)-> Observable<NetworkData> {
        let headers = HeaderCommon.shareInstance.headerSetting()
        return RxAlamofire.requestData(.put, URL, parameters: body, encoding: JSONEncoding.default, headers: headers, interceptor: .none)
            .mapObject(type: NetworkData.self)
    }
   

    //이미지 단건 업로드 공통 API
    func imageUpload(URL:String, image:UIImage) -> Observable<OneImageUploadRPModel> {
        return Observable<OneImageUploadRPModel>.create({ observer in
            let headers = HeaderCommon.shareInstance.headerSetting()
            AF.upload(multipartFormData: { (multipartFormData) in
                if let data = image.jpegData(compressionQuality: 1.0){
                    multipartFormData.append(data, withName: "file", fileName: "file.jpg", mimeType: "image/jpeg")
                }
            }, to:URL, method: .post,headers: headers)
            .responseJSON{ response in
                if response.response?.statusCode == 200 {
                    if let responseData = response.data {
                        let decoder = JSONDecoder()
                        if let returnData = try? decoder.decode(OneImageUploadRPModel.self, from: responseData) {
                            observer.onNext(returnData)
                            observer.onCompleted()
                        }
                    }
                }else {
                    if let statusCode = response.response?.statusCode {
                        observer.onNext(OneImageUploadRPModel(errors: Errors(errorCode: statusCode, message: "네트워크 에러"), data: nil))
                        observer.onCompleted()
                    }else {
                        observer.onNext(OneImageUploadRPModel(errors: Errors(errorCode: 0, message: "네트워크 에러 알수없음"), data: nil))
                        observer.onCompleted()
                    }
                }
            }
            
            return Disposables.create();
        })
    }
}
