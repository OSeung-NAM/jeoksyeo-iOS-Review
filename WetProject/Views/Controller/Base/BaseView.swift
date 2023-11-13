//
//  BaseView.swift
//  WetProject
//
//  Created by 남오승 on 2021/01/08.
//

import UIKit

//모든 SnapKit UI의 기본이 되는 파일
class BaseView: UIView {
    
    var currentViewSize = UIScreen.main.bounds
    let standardWidthSize:CGFloat = 375  //디자인 기준 width
    let standardHeightSize:CGFloat = 812 //디자인 기준 height
    
    //constraint 방향 기준
    enum Direction {
        case top
        case left
        case right
        case bottom
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        backgroundColor = .white
    }
    
    /// - Returns: 비율 변환 된 값
    /// - Important: 변경할 관계 비율
    /// - parameter direction: 관계 설정 할 방향
    /// - parameter standardSize: 디자인 기준 사이즈
    func constraintRatio(direction:Direction,standardSize:CGFloat) -> CGFloat{
        var ratio: CGFloat = 0.0
        
        switch direction {
        case .top,.bottom:
            let standardRatio = (standardSize/standardHeightSize)
            ratio = currentViewSize.height * standardRatio
            break
        case .left,.right:
            let standardRatio = (standardSize/standardWidthSize)
            ratio = currentViewSize.width * standardRatio
            break
        }
        
        
        return ratio
    }
    
    /// - parameter standardSize: 디자인 기준 사이즈
    /// - Returns: 비율 변환 된 값
    /// - Important: 변경할 비율 사이즈 (view, font)
    func aspectRatio(standardSize:CGFloat) -> CGFloat {
        var ratio: CGFloat = 0.0
        
        let standardRatio = (standardSize/standardWidthSize)
        ratio = currentViewSize.width * standardRatio
        
        return ratio
    }

    
    /// - parameter r: 빨강
    /// - parameter g: 녹색
    /// - parameter b: 파랑
    /// - parameter alpha: 투명도
    /// - Returns: 색 적용 된 값
    /// - Important: 컬러 간편 세팅
    func colorSetting(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: alpha)
    }
}
