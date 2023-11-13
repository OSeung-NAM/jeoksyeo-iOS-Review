//
//  ViewBorder+extension.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/10.
//

import UIKit

//테두리 공통 extension
extension UIView {
    func borderAll(width:CGFloat, color:CGColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color
    }
}
