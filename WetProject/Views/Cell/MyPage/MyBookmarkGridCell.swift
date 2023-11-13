//
//  MyBookmarkGridCell.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/23.
//

import UIKit
//webp이미지 로드하기위한 플러그인
import Nuke
import NukeWebPPlugin

//내가 찜한 주류 리스트 표현을 위한 UICell 컴포넌트
class MyBookmarkGridCell: UICollectionViewCell {
    
    @IBOutlet weak var alcoholNameGL: UILabel!

    @IBOutlet weak var breweryGL: UILabel!
    @IBOutlet weak var alcoholImage: UIImageView!
    @IBOutlet weak var alcoholImageWrap: UIView!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var likeCntGL: UILabel!
    @IBOutlet weak var reviewCntGL: UILabel!
    //알코올 농도
    @IBOutlet weak var alcoholConcentrationGL: UILabel!
    
    @IBOutlet weak var likeCntWrap: UIView!
    @IBOutlet weak var reviewCntWrap: UIView!
    
    var callingView:Any?
    var bookmarkList:[AlcoholList]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        alcoholImageWrap.layer.cornerRadius = 5.0
        alcoholImageWrap.borderAll(width: 0.5, color: UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1).cgColor)
        alcoholImageWrap.shadow(opacity: 0.14, radius: 1, offset: CGSize(width: 2, height: 2), color: UIColor(red: 199/255, green: 199/255, blue: 199/255, alpha: 1).cgColor)

        backgroundColor = .clear
    }
    
    override func prepareForReuse() {
          //재 사용 시 이미지 리로딩에 관한 부분 처리
        alcoholImage.image = nil
    }
    
    func alcoholImageSetting(urlString: String) {
        if urlString.count > 0 {
            WebPImageDecoder.enable()
            let webpimageURL = URL(string: urlString)!
            Nuke.loadImage(with: webpimageURL, into: alcoholImage)
        }
    }
    
    func dataSetting (indexPath:IndexPath) {
        guard let alcoholList = bookmarkList else {return}
        let alcoholName:String = alcoholList[indexPath.row].name?.kr ?? ""
        let brewery:String = alcoholList[indexPath.row].brewery?[0].name ?? ""
        let isLiked:Bool = alcoholList[indexPath.row].isLiked ?? true
        let likeCnt:Int = alcoholList[indexPath.row].likeCount ?? 0
        let reviewCnt:Int = alcoholList[indexPath.row].review?.reviewCount ?? 0
        let alcoholConcentration:String = String(alcoholList[indexPath.row].abv ?? 0.0)
        let alcoholImageUrl:String = alcoholList[indexPath.row].media?[0].mediaResource?.medium?.src ?? ""

        if isLiked {
            likeImage.image = UIImage(named: "heartOn")
        }else {
            likeImage.image = UIImage(named: "heartOff")
        }
        
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
        
        alcoholNameGL.text = alcoholName
        breweryGL.text = brewery
        alcoholConcentrationGL.text = alcoholConcentration + " %"
        alcoholImageSetting(urlString: alcoholImageUrl)
    }
}
