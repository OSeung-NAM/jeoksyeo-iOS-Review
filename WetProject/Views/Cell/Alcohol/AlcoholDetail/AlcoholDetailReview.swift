//
//  AlcoholDetailReview.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/26.
//

import UIKit
import MGStarRatingView
//webp이미지 로드하기위한 플러그인
import Nuke
import NukeWebPPlugin
import MGStarRatingView

//주류 상세페이지 하단 리뷰 리스트 표현을 위한 UICell 컴포넌트
class AlcoholDetailReview:UIView, StarRatingDelegate {
    func StarRatingValueChanged(view: StarRatingView, value: CGFloat) {}
    
    private let xibName = "AlcoholDetailReview"
    
    @IBOutlet weak var defaultImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameGL: UILabel!
    @IBOutlet weak var reviewLikeImage: UIImageView!
    @IBOutlet weak var reviewDisLikeImage: UIImageView!
    @IBOutlet weak var reviewLikeCntGL: UILabel!
    @IBOutlet weak var reviewDisLikeCntGL: UILabel!
    
    @IBOutlet weak var reviewContentsTV: UITextView!
    @IBOutlet weak var levelGL: UILabel!
    @IBOutlet weak var reviewScoreGL: UILabel!
    @IBOutlet weak var writeDateGL: UILabel!
    @IBOutlet weak var reviewContentsGL: UILabel!
    @IBOutlet weak var moreWrap: UIView!
    @IBOutlet weak var expandImage: UIImageView!
    @IBOutlet weak var moreGL: UILabel!
    @IBOutlet weak var starView: StarRatingView!
    
    @IBOutlet weak var likeWrap: UIView!
    @IBOutlet weak var disLikeWrap: UIView!
    
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
        
        profileImage.layer.cornerRadius = 19.0
        let attribute = StarRatingAttribute(type: .rate,
                                            point: 12.0,
                                            spacing: 0.0,
                                            emptyColor: .clear,
                                            fillColor: UIColor(red: 251/255, green: 192/255, blue: 45/255, alpha: 1.0),
                                            emptyImage: UIImage(named: "ratingEmpty"),
                                            fillImage: UIImage(named: "ratingFullstar"))
        starView.configure(attribute, current: 0, max: 5)
        
        starView.delegate = self
        starView.current = 0.0
        self.addSubview(view)
    }
    
    func reviewSetting(review:ReviewList) {
        let level = review.level ?? 1
        let writer = review.nickname ?? ""
        let likeCnt = review.likeCount ?? 0
        let disLikeCnt = review.disLikeCount ?? 0
        let createdAt = review.createdAt ?? 0
        let updatedAt = review.updatedAt ?? 0
        let reviewScore = review.score ?? 0.0
        let likeFlag:Bool = review.hasLike ?? false
        let disLikeFlag:Bool = review.hasDisLike ?? false
        
        nameGL.text = writer
        
        if likeCnt > 999 {
            reviewLikeCntGL.text = "999+"
        }else {
            reviewLikeCntGL.text = String(likeCnt)
        }
        
        if disLikeCnt > 999 {
            reviewDisLikeCntGL.text = "999+"
        }else {
            reviewDisLikeCntGL.text = String(disLikeCnt)
        }
        
        if createdAt < updatedAt {
            writeDateGL.text = updatedAt.timeStampToDate()
        }else {
            writeDateGL.text = createdAt.timeStampToDate()
        }
        
        if likeFlag {
            reviewLikeImage.image = UIImage(named: "reviewLikeOn")
        }else {
            reviewLikeImage.image = UIImage(named: "reviewLikeOff")
        }
        
        if disLikeFlag {
            reviewDisLikeImage.image = UIImage(named: "reviewDisLikeOn")
        }else {
            reviewDisLikeImage.image = UIImage(named: "reviewDisLikeOff")
        }
        
        if (review.profile?.count ?? 0) > 0 {
            defaultImage.isHidden = true
            profileImage.isHidden = false
            let profileUrl:String = review.profile?[0].mediaResource?.small?.src ?? ""
            profileImageSetting(urlString: profileUrl)
        }else {
            defaultImage.isHidden = false
            profileImage.isHidden = true
        }
       
        starView.current = CGFloat(reviewScore)
        reviewScoreGL.text = String(reviewScore)
        levelNameSetting(level: level)
    }
    
    func profileImageSetting(urlString: String) {
        if urlString.count > 0 {
            WebPImageDecoder.enable()
            let webpimageURL = URL(string: urlString)!
            Nuke.loadImage(with: webpimageURL, into: profileImage)
        }
    }
    
    func levelNameSetting(level:Int) {
        switch level {
        case 1:
            levelGL.text = "LV1. 마시는척 하는 사람"
            break
        case 2:
            levelGL.text = "LV2. 술을 즐기는 사람"
            break
        case 3:
            levelGL.text = "LV3. 술독에 빠진 사람"
            break
        case 4:
            levelGL.text = "LV4. 주도를 수련하는 사람"
            break
        case 5:
            levelGL.text = "LV5. 술로 해탈한 사람"
            break
        default:
            break
        }
        
    }
}

