//
//  MyReviewCell.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/02.
//

import UIKit
//webp이미지 로드하기위한 플러그인
import Nuke
import NukeWebPPlugin
import MGStarRatingView

//내가 평가 한 리뷰 리스트 표현을 위한 UICell 컴포넌트
class MyReviewCell:UITableViewCell, StarRatingDelegate {
    func StarRatingValueChanged(view: StarRatingView, value: CGFloat) {}
    
    @IBOutlet weak var alcoholImageWrap: UIView!
    @IBOutlet weak var alcoholImage: UIImageView!
    @IBOutlet weak var alcoholName: UILabel!
    
    @IBOutlet weak var alcoholBrewery: UILabel!
    
    @IBOutlet weak var reviewContents: UILabel!
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var updateBtn: UIButton!
    
    @IBOutlet weak var alcoholScore: UILabel!
    @IBOutlet weak var writeDate: UILabel!
    @IBOutlet weak var expandWrap: UIView!
    @IBOutlet weak var expandImage: UIImageView!
    @IBOutlet weak var expandGL: UILabel!
    
    @IBOutlet weak var starView: StarRatingView!
    
    var reviewList:[ReviewList]?
    var callingView:Any?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        alcoholImageWrap.layer.cornerRadius = 10.0
        
        alcoholImageWrap.shadow(opacity: 0.16, radius: 2, offset: CGSize(width: 0, height: 1), color: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1).cgColor)
        
        updateBtn.layer.borderWidth = 0.5
        updateBtn.layer.borderColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1).cgColor
        
        deleteBtn.layer.borderWidth = 0.5
        deleteBtn.layer.borderColor = UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1).cgColor
        
        let attribute = StarRatingAttribute(type: .rate,
                                            point: 12,
                                            spacing: 0.0,
                                            emptyColor: .clear,
                                            fillColor: UIColor(red: 251/255, green: 192/255, blue: 45/255, alpha: 1.0),
                                            emptyImage: UIImage(named: "ratingEmpty"),
                                            fillImage: UIImage(named: "ratingFullstar"))
        starView?.configure(attribute, current: 0, max: 5)
        
        starView?.delegate = self
        starView?.current = 0.0
        
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
    
    func dataSetting(indexPath:IndexPath, view:UIView ) {
        guard let reviewList = reviewList else { return }
        let alcoholNameTx:String = reviewList[indexPath.row].alcohol?.name ?? ""
        let brewery:String = reviewList[indexPath.row].alcohol?.brewery?[0].name ?? ""
        let reviewWriteDate:Int = reviewList[indexPath.row].createdAt ?? 0
        let reviewUpdateDate:Int = reviewList[indexPath.row].updatedAt ?? 0
        let reviewScore:Float = reviewList[indexPath.row].score ?? 0.0
        let reviewContentsTx:String = reviewList[indexPath.row].contents ?? ""
        let reviewExpandFlag:Bool = reviewList[indexPath.row].expandFlag
        let alcoholUrl:String = reviewList[indexPath.row].alcohol?.media?[0].mediaResource?.small?.src ?? ""

        if reviewWriteDate < reviewUpdateDate { //수정 됨
            writeDate.text = reviewUpdateDate.timeStampToDate()
        }else {
            writeDate.text = reviewWriteDate.timeStampToDate()
        }

        alcoholName.text = alcoholNameTx
        alcoholBrewery.text = brewery

        alcoholScore.text = String(reviewScore)
        reviewContents.text = reviewContentsTx
        alcoholImageSetting(urlString: alcoholUrl)

        let lineOfReivewContents = reviewContents.lineOfLabel(width: view.frame.width - 40, font: UIFont(name: "AppleSDGothicNeo-Medium", size: 13.0)!)
        
        if lineOfReivewContents > 2.0 {
            if reviewExpandFlag {
                reviewContents.numberOfLines = 0
                expandWrap.isHidden = false
                expandGL.text = "접기"
                expandImage.image = UIImage(named: "expandMoreUp")
            }else {
                expandGL.text = "더보기"
                expandImage.image = UIImage(named: "expandMoreDown")
            }
           expandWrap.tag = indexPath.row
           expandWrap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(expandEvent)))

        }else {
            expandWrap.isHidden = true
        }
        
        starView.current = CGFloat(reviewScore)
        

        selectionStyle = .none
        backgroundColor = .white

    }
    
    //리뷰 내용 접기/펼치기
    @objc func expandEvent(_ gesture:UITapGestureRecognizer) {
        let view = gesture.view
        let row = view!.tag
        
        if let list = reviewList {
            if let myReviewListVC:MyReviewListVC = callingView as? MyReviewListVC {
                myReviewListVC.reviewList[row].expandFlag = !list[row].expandFlag
                myReviewListVC.myReviewListTV.reloadData()
            }
        }
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}
