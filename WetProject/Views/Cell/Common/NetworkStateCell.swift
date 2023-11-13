//
//  NetworkStateCell.swift
//  WetProject
//
//  Created by 남오승 on 2020/12/18.
//

import UIKit

//네트워크 접속오류 Toast Message를 위한 공통UI컴포넌트
class NetworkStateCell:UIView {

    private let xibName = "NetworkStateCell"

    @IBOutlet weak var networkWrap: UIView!
    @IBOutlet weak var errorMsgGL: UILabel!
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
        networkWrap.layer.cornerRadius = 6.0

        self.addSubview(view)
    }
    
}
