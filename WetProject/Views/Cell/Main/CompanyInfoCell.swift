//
//  CompanyInfoCell.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/28.
//

import UIKit

//메인화면 최하단 회사정보 표현을 위한 UICell 컴포넌트
class CompanyInfoCell:UIView {

    //이용약관
    @IBOutlet weak var useTermsWrap: UIView?
    //개인정보 취급 방침
    @IBOutlet weak var userPrivacyWrap: UIView?
    
    private let xibName = "CompanyInfoCell"

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
