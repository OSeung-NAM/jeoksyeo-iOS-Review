//
//  RecommendWrapCell.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/28.
//

import UIKit
import FSPagerView
import Nuke
import NukeWebPPlugin

//메인화면 주류 추천 리스트 를 감싸는 UICell컴포넌트
class RecommendWrapCell:UIView {

    private let xibName = "RecommendWrapCell"
 
    @IBOutlet weak var recommendWrap: UIView!
    
    var mainRecommendCV: MainRecommendCV!
    
    var alcoholList:[MainRecommendAlcoholList]?
    
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
    
        let recommendWrapHeightRatio = 375.0 / 370.0
        let recommendWrapWidth = view.frame.width
        let recommendWrapHeight = (recommendWrapWidth / CGFloat(recommendWrapHeightRatio))
        
        
        let ratioHeight = 375.0 / 340 //주류추천 셀 높이 비율
        let ratioWidth = 375.0 / 240 //주류추천 셀 너비 비율
        let ratioSpacing = 375.0 / 35.0 //주류추천 셀 간격 비율
        
        mainRecommendCV = MainRecommendCV(frame: CGRect(x: 0, y: 0, width: recommendWrapWidth, height: recommendWrapHeight), cellWidth: view.frame.width / CGFloat(ratioWidth), cellHeight: view.frame.width / CGFloat(ratioHeight),spacing: view.frame.width / CGFloat(ratioSpacing))
        mainRecommendCV.center = CGPoint(x: recommendWrapWidth / 2, y: recommendWrapHeight / 2)
        
        mainRecommendCV.backgroundColor = .clear
        recommendWrap.addSubview(mainRecommendCV)
        mainRecommendCV.scrollToFirstItem()
        self.addSubview(view)
    }

    func recommendSetting(alcoholList:[MainRecommendAlcoholList]?, callingView:Any) {
        mainRecommendCV.alcoholList = alcoholList
        mainRecommendCV.callingView = callingView
        mainRecommendCV.reloadData()
        mainRecommendCV.scrollToFirstItem()
    }
}
