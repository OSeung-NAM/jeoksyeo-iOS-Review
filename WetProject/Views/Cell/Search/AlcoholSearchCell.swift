//
//  AlcoholSearchCell.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/17.
//

import UIKit
//webp이미지 로드하기위한 플러그인
import Nuke
import NukeWebPPlugin
import MGStarRatingView

//주류 검색페이지 주류 검색 후 나타나는 리스트 표현을 위한 UICell 컴포넌트
class AlcoholSearchCell:UITableViewCell,StarRatingDelegate {
    func StarRatingValueChanged(view: StarRatingView, value: CGFloat) {}
    
 
    @IBOutlet weak var likeImageWrap: UIView!    
    @IBOutlet weak var reviewImageWrap: UIView!
    
    @IBOutlet weak var alcoholSearchCellWrap: UIView!
    @IBOutlet weak var alcoholImage: UIImageView!
    
    @IBOutlet weak var alcoholNameGL: UILabel!
    @IBOutlet weak var breweryGL: UILabel!
    @IBOutlet weak var scoreGL: UILabel!
    @IBOutlet weak var likeCntGL: UILabel!
    @IBOutlet weak var reviewCntGL: UILabel!
    @IBOutlet weak var viewCntGL: UILabel!
    @IBOutlet weak var abvGL: UILabel!


    @IBOutlet weak var likeImage: UIImageView!
    

    @IBOutlet weak var starView: StarRatingView!
    //알코올 농도
    @IBOutlet weak var alcoholConcentration: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        alcoholSearchCellWrap.shadow(opacity: 0.16, radius: 2, offset: CGSize(width: 0, height: 1),color: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1).cgColor)
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
        alcoholImage.image = nil
    }
    
    func dataSetting(alcohol:AlcoholList) {
        let name:String = alcohol.name?.kr ?? ""
        var brewery:String = ""
        
        if (alcohol.brewery?.count) ?? 0 > 0 { //혹시모를 백엔드 오류에 방지
            brewery = alcohol.brewery?[0].name ?? ""
        }
        
        var alcoholImageUrl:String = ""
        if (alcohol.media?.count ?? 0) > 0 { //혹시모를 백엔드 오류에 방지ㅣ
            alcoholImageUrl = alcohol.media?[0].mediaResource?.medium?.src ?? ""
        }
        
        let score:Float = alcohol.review?.score ?? 0.0
        let likeCnt:Int = alcohol.likeCount ?? 0
        let reviewCnt:Int = alcohol.review?.reviewCount ?? 0
        let viewCnt:Int = alcohol.viewCount ?? 0
        let abv:Double = alcohol.abv ?? 0.0
        let isLiked:Bool = alcohol.isLiked ?? false
        
        alcoholNameGL.text = name
        breweryGL.text = brewery
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
        
        scoreGL.text = String(score)
        
        abvGL.text = String(abv) + "%"
        
        alcoholImageSetting(urlString: alcoholImageUrl)
        likeSetting(isLiked: isLiked)
        starView.current = CGFloat(score)
    }
    
    func alcoholImageSetting(urlString: String) {
        if urlString.count > 0 {
            WebPImageDecoder.enable()
            let webpimageURL = URL(string: urlString)!
            Nuke.loadImage(with: webpimageURL, into: alcoholImage)
        } 
    }
    
    func likeSetting(isLiked:Bool) {
        if isLiked {
            self.likeImage.image = UIImage(named: "heartOn")
        }else {
            self.likeImage.image = UIImage(named: "heartOff")
        }
    }
}
