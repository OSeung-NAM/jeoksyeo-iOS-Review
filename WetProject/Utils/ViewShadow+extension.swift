//
//  ViewShadow+extension.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/09.
//


import UIKit

//그림자 공통 extension
extension UIView {
    
    func shadow(opacity:Float, radius:CGFloat, offset:CGSize, color:CGColor?) {
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        if color != nil {
            self.layer.shadowColor = color
        }
    }
    
    func shadow(shadowModel:ShadowModel) {
        self.layer.shadowOpacity = shadowModel.opacity
        self.layer.shadowOffset = shadowModel.offset
        self.layer.shadowRadius = shadowModel.radius
        if let color = shadowModel.color{
            self.layer.shadowColor = color
        }
    }
}
