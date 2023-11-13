//
//  CustomCellTest.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/26.
//

import UIKit
//webp이미지 로드하기위한 플러그인
import Nuke
import NukeWebPPlugin
import MGStarRatingView
import RxSwift
import RxCocoa

//메인화면 주류 추천 리스트 표현을 위한 UICell 컴포넌트
class MainRecommendCell: UICollectionViewCell, StarRatingDelegate {
    
    @IBOutlet weak var alcoholImage: UIImageView!
    @IBOutlet weak var alcoholName: UILabel!
    @IBOutlet weak var percentage: UILabel!
    @IBOutlet weak var likeCnt: UILabel!
    
    @IBOutlet weak var likeWrap: UIView!
    @IBOutlet weak var score: UILabel!
    
    @IBOutlet weak var alcoholLikeImage: UIImageView!
    @IBOutlet weak var recommendWrap: UIView!
    
    @IBOutlet weak var bottomWrap: UIView!
    @IBOutlet weak var bottomIsEmptyWrap: UIView!
    
    @IBOutlet weak var starView: StarRatingView!
    
    var eventIndex:Int = 0
    var callingView:Any?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        recommendWrap.layer.cornerRadius = 15.0
        
        recommendWrap.shadow(opacity: 0.16, radius: 6, offset: CGSize(width: 0, height: 2),color: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1).cgColor)
        
        let attribute = StarRatingAttribute(type: .rate,
                                            point: 11,
                                            spacing: 0.0,
                                            emptyColor: .clear,
                                            fillColor: UIColor(red: 251/255, green: 192/255, blue: 45/255, alpha: 1.0),
                                            emptyImage: UIImage(named: "ratingEmpty"),
                                            fillImage: UIImage(named: "ratingFullstar"))
        starView?.configure(attribute, current: 0, max: 5)
        
        starView?.delegate = self
        starView?.current = 0.0
    }
    
    func alcoholImageSetting(urlString: String) {
        WebPImageDecoder.enable()
        let webpimageURL = URL(string: urlString)!
        Nuke.loadImage(with: webpimageURL, into: alcoholImage)
    }
    
    func likeImageSetting(isLiked: Bool) {
        if isLiked {
            self.alcoholLikeImage.image = UIImage(named: "heartOn")
        }else {
            self.alcoholLikeImage.image = UIImage(named: "heartOff")
        }
    }

    func StarRatingValueChanged(view: StarRatingView, value: CGFloat) {}
}
