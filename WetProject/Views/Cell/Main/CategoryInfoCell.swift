//
//  CategoryInfoCell.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/28.
//

import UIKit
import FSPagerView
import Nuke
import NukeWebPPlugin

//메인화면 주류 카테고리 리스트 표현을 위한 UICell 컴포넌트
class CategoryInfoCell:UIView {

    private let xibName = "CategoryInfoCell"
    
    //전통주
    @IBOutlet weak var trWrap: UIView!
    //맥주
    @IBOutlet weak var beWrap: UIView!
    //와인
    @IBOutlet weak var wiWrap: UIView!
    //양주
    @IBOutlet weak var liWrap: UIView!
    //사케
    @IBOutlet weak var saWrap: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit(){
        
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
    

        self.addSubview(view)
    }
}
