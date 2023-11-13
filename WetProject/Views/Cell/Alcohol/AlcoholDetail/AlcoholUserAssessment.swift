//
//  AlcoholUserAssessment.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/29.
//

import UIKit
import RadarChart

//주류 상세페이지 유저가 세팅한 Web Chart 표현을위한 UICell 컴포넌트
class AlcoholUserAssessment:UIView {

    private let xibName = "AlcoholUserAssessment"

    @IBOutlet weak var userGraphView: RadarChartView?
    
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

        userGraphView?.data = [0, 0, 0, 0, 0]
        userGraphView?.labelTexts = ["아로마", "테이스트", "시각적 특징", "어울림", "마우스필"]
        userGraphView?.numberOfVertexes = 5 //숫자 최고치
        userGraphView?.numberTicks = 5
        userGraphView?.style = RadarChartStyle(color: UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1.0),
                                              backgroundColor: UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1.0),
                                              xAxis: RadarChartStyle.Axis(
                                                colors: [.white],
                                                widths: [1.0, 1.0, 1.0, 1.0, 0.0]),
                                              yAxis: RadarChartStyle.Axis(
                                                colors: [.clear],
                                                widths: [0.5]),
                                              label: RadarChartStyle.Label(fontName: "AppleSDGothicNeo-SemiBold",
                                                                           fontColor: UIColor(red: 133/255, green: 133/255, blue: 133/255, alpha: 1.0),
                                                                           fontSize: 15,
                                                                           lineSpacing: 0,
                                                                           letterSpacing: 0,
                                                                           margin: 14)
        )
        userGraphView?.option = RadarChartOption()

        userGraphView?.shadow(opacity: 0.1, radius: 3, offset: CGSize(width: 3, height: 3), color: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1).cgColor)

        userGraphView?.prepareForDrawChart()
        userGraphView?.setNeedsLayout()

        self.addSubview(view)
    }
    
}
