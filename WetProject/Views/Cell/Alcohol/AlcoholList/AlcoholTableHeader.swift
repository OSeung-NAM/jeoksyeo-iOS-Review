//
//  TestHeader.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/30.
//

import Foundation
import UIKit

//주류리스트 리스트모드부분 헤더 표현을 위한 UI컴포넌트(주류 총 갯수 보여주는 헤더)
class AlcoholTableHeader:UITableViewHeaderFooterView { 
    @IBOutlet weak var productCnt: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
   
    }
   
    override func prepareForReuse() {
   
    }
}
