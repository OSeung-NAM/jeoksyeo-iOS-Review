//
//  IndicatorCell.swift
//  WetProject
//
//  Created by 남오승 on 2020/12/14.
//

import UIKit


//로딩 Lottie 사용을위한 공통 UI컴포넌트
class IndicatorCell:UIView {

    private let xibName = "IndicatorCell"
    
    @IBOutlet weak var lottieWrap: UIView!
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

