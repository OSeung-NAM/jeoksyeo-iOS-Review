//
//  AlcoholTableCell.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/27.
//

import UIKit
//webp이미지 로드하기위한 플러그인
import Nuke
import NukeWebPPlugin
import MGStarRatingView

//주류 리스트 리스트모드 표현을 위한 UICell 컴포넌트
class AlcoholTableCell:UITableViewCell, StarRatingDelegate {
    func StarRatingValueChanged(view: StarRatingView, value: CGFloat) {}
    
    
    @IBOutlet weak var alcoholImageWrap: UIView!
    @IBOutlet weak var alcoholImage: UIImageView!
    @IBOutlet weak var alcoholBrewery: UILabel!
    
    @IBOutlet weak var alcoholName: UILabel!
    
    @IBOutlet weak var alcoholScore: UILabel!

    @IBOutlet weak var likeImage: UIImageView!
    
    @IBOutlet weak var likeCntGL: UILabel!
    @IBOutlet weak var reviewCntGL: UILabel!
    @IBOutlet weak var viewCntGL: UILabel!
    
    @IBOutlet weak var starView: StarRatingView?
    
    @IBOutlet weak var likeWrap: UIView!
    
    //알코올 농도
    @IBOutlet weak var alcoholConcentration: UILabel!
    
    private var task: URLSessionDataTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        alcoholImageWrap.shadow(opacity: 0.16, radius: 2, offset: CGSize(width: 0, height: 1),color: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1).cgColor)
        alcoholImageWrap.layer.cornerRadius = 10.0
        selectionStyle = .none
        backgroundColor = .clear
        
        let attribute = StarRatingAttribute(type: .rate,
                                            point: 14,
                                            spacing: 0.0,
                                            emptyColor: .clear,
                                            fillColor: UIColor(red: 251/255, green: 192/255, blue: 45/255, alpha: 1.0),
                                            emptyImage: UIImage(named: "ratingEmpty"),
                                            fillImage: UIImage(named: "ratingFullstar"))
        starView?.configure(attribute, current: 0, max: 5)
        
        starView?.delegate = self
        starView?.current = 0.0
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
          //재 사용 시 이미지 리로딩에 관한 부분 처리
//        alcoholImage.image = nil
    }
    
    func alcoholSetting(alcohol:AlcoholList) {
        let name:String = alcohol.name?.kr ?? ""
        let brewery:String = alcohol.brewery?[0].name ?? ""
        let score:Float = alcohol.review?.score ?? 0.0
        let isLiked:Bool = alcohol.isLiked ?? false
        let likeCnt:Int = alcohol.likeCount ?? 0
        let reviewCnt:Int = alcohol.review?.reviewCount ?? 0
        let viewCnt:Int = alcohol.viewCount ?? 0
        let abv:Double = alcohol.abv ?? 0.0
        let alcoholImageUrl:String = alcohol.media?[0].mediaResource?.medium?.src ?? ""
        
        alcoholName.text = name
        alcoholBrewery.text = brewery
        starView?.current = CGFloat(score)
        alcoholScore.text = String(score)
        
        countSetting(likeCnt: likeCnt, reviewCnt: reviewCnt, viewCnt: viewCnt)

        alcoholConcentration.text = String(abv) + "%"
        
        likeSetting(isLiked: isLiked)
        alcoholImageSetting(urlString: alcoholImageUrl)
        
    }
    
    func countSetting(likeCnt:Int, reviewCnt: Int, viewCnt:Int) {
        if likeCnt > 999 {
            likeCntGL.text = "999+"
        }else {
            likeCntGL.text = String(likeCnt)
        }
        
        if reviewCnt > 999 {
            reviewCntGL.text = "999+"
        }else {
            reviewCntGL.text = String(reviewCnt)
        }
        
        if viewCnt > 999 {
            viewCntGL.text = "999+"
        }else {
            viewCntGL.text = String(viewCnt)
        }
    }
    
    //주류 이미지 세팅
    func alcoholImageSetting(urlString: String) {
        if urlString.count > 0 {
            WebPImageDecoder.enable()
            if let url = URL(string: urlString) {
                Nuke.loadImage(with: url, into: alcoholImage)
            }
        }
    }
    
    //좋아요 부분 세팅
    func likeSetting(isLiked:Bool) {
        if isLiked {
            self.likeImage.image = UIImage(named: "heartOn")
        }else {
            self.likeImage.image = UIImage(named: "heartOff")
        }
    }
}
