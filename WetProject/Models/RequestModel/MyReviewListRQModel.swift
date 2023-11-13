//
//  MyReviewListRQModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/12/14.
//

import Foundation

//내 리뷰 목록 조회 API호출 시 Request 파라메터를 위한 모델
struct MyReviewListRQModel:Codable {
    var f: String //주종 코드(Default: ALL) 맥주: BE, 와인: WI, 사케: SA, 전통주: TR, 양주: FO
    var c: Int //조회할 주류 갯수(Default: 20)
    var p: Int //    조회할 페이지(Default: 1)
}
