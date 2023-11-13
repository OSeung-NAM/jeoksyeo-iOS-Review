//
//  ShadowModel.swift
//  WetProject
//
//  Created by 남오승 on 2020/12/11.
//

import Foundation
import UIKit

//그림자 세팅을 위한 데이터 모델
struct ShadowModel {
    let opacity:Float
    let radius:CGFloat
    let offset:CGSize
    let color:CGColor?
}
