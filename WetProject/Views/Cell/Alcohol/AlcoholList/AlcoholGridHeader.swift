//
//  AlcoholGridHeader.swift
//  WetProject
//
//  Created by 남오승 on 2020/12/01.
//

import Foundation
import UIKit

//주류리스트 그리드모드부분 헤더 표현을 위한 UI컴포넌트(주류 총 갯수 보여주는 헤더)
class AlcoholGridHeader: UICollectionReusableView {
    
    @IBOutlet weak var gridTotalCntGL: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
     }

     required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

     }
}

