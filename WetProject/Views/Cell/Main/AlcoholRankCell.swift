//
//  AlcoholRankCell.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/28.
//

import UIKit
import FSPagerView
import Nuke
import NukeWebPPlugin

//메인화면 주류 랭킹 리스트 표현을 위한 UICell 컴포넌트
class AlcoholRankCell:UIView {

    private let xibName = "AlcoholRankCell"
    
    @IBOutlet weak var breweryGL: UILabel!
    @IBOutlet weak var borderTop: UIView?
    @IBOutlet weak var rankImage: UIImageView?
    @IBOutlet weak var alcoholNameKrGL: UILabel?
    @IBOutlet weak var alcoholNameEnGL: UILabel?
    @IBOutlet weak var breweryLocationGL: UILabel!
    @IBOutlet weak var reviewGL: UILabel?
    @IBOutlet weak var alcoholImageWrap: UIView?
    @IBOutlet weak var alcoholImage: UIImageView!
    
    var alcoholList:[AlcoholList]?
    
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
    
        alcoholImageWrap?.layer.cornerRadius = 9.0
        alcoholImageWrap?.shadow(opacity: 0.16, radius: 6, offset: CGSize(width: 2, height: 2),color: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1).cgColor)

        self.addSubview(view)
    }

    //랭킹 데이터 세팅
    func rankSetting(alcoholList:AlcoholList, index:Int) {
        
        let brewery:String = alcoholList.brewery?[0].name ?? ""
        let alcoholNameKr:String = alcoholList.name?.kr ?? ""
        let alcoholNameEn:String = alcoholList.name?.en ?? ""
        let breweryLocation:String = alcoholList.brewery?[0].location ?? ""
        let imageUrl:String = alcoholList.media?[0].mediaResource?.medium?.src ?? ""

        var reviewContents:String = String()
        
        if (alcoholList.review?.reviews?.count) ?? 0 > 0 {
            reviewContents = alcoholList.review?.reviews?[0].contents ?? ""
        }
        
        breweryGL.text = brewery
        alcoholNameKrGL?.text = alcoholNameKr
        alcoholNameEnGL?.text = alcoholNameEn
        breweryLocationGL.text = breweryLocation
        reviewGL?.text = reviewContents
        rankImageSetting(rankIndex: index)
        alcoholSetting(url: imageUrl)

    }
    
    //랭킹순 이미지 세팅
    func rankImageSetting(rankIndex:Int) {
        switch rankIndex {
        case 0:
            rankImage?.image = UIImage(named: "rankOne")
            break
        case 1:
            rankImage?.image = UIImage(named: "rankTwo")
            break
        case 2:
            rankImage?.image = UIImage(named: "rankThree")
            break
        default:
            break
        }
    }
    
    //주류 랭킹 이미지 세팅
    func alcoholSetting(url:String) {
        if url.count > 0 {
            let webpimageURL = URL(string: url)!
            Nuke.loadImage(with: webpimageURL, into: alcoholImage)
            WebPImageDecoder.enable()
        }
    }
}
