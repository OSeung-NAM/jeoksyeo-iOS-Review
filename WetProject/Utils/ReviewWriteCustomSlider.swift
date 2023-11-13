//
//  UISlider+extension.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/25.
//

import UIKit

//리뷰 평가하기 Slider 변환 확장 파일
class ReviewWriteCustomSlider: UISlider {
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: 18.0))
        
        super.trackRect(forBounds: customBounds)
        return customBounds
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if #available(iOS 14.0, *) { //주류 평점 슬라이드 14버전
            
        }else { //주류 평점 슬라이드 14 이외 버전
            self.layer.sublayers?[1].cornerRadius = 10
        }
    }
}
