//
//  ReviewListCell.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/30.
//

import UIKit
//webp이미지 로드하기위한 플러그인
import Nuke
import NukeWebPPlugin
import MGStarRatingView

//리뷰리스트 표현을위한 UICell 컴포넌트
class ReviewListCell:UITableViewCell, StarRatingDelegate {
    func StarRatingValueChanged(view: StarRatingView, value: CGFloat) {}
    

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var defaultProfileImage: UIImageView!
    @IBOutlet weak var nameGL: UILabel!
    @IBOutlet weak var levelGL: UILabel!
    @IBOutlet weak var likeWrap: UIView!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var likeCntGL: UILabel!
    @IBOutlet weak var disLikeWrap: UIView!
    @IBOutlet weak var disLikeImage: UIImageView!
    @IBOutlet weak var disLikeCntGL: UILabel!
    @IBOutlet weak var starView: StarRatingView!
    @IBOutlet weak var scoreGL: UILabel!
    @IBOutlet weak var writeDateGL: UILabel!
    @IBOutlet weak var expandWrap: UIView!
    @IBOutlet weak var moreImage: UIImageView!
    @IBOutlet weak var moreGL: UILabel!
    @IBOutlet weak var reviewContentsGL: UITextView!
    
    @IBOutlet weak var reviewBottomExpandedWrap: UIView!
    
    var deviceWidth:CGFloat = UIScreen.main.bounds.width
    
    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .white
        selectionStyle = .none
        
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
        
        
        reviewContentsGL.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
          //재 사용 시 이미지 리로딩에 관한 부분 처리
    }
    
    func reviewSetting(review:ReviewList) {
        profileImage?.layer.cornerRadius = 19.5
        
        let name:String = review.nickname ?? ""
        let reviewContnets:String = review.contents ?? ""
        let expandFlag:Bool = review.expandFlag
        let hasLike: Bool = review.hasLike ?? false
        let hasDislike :Bool = review.hasDisLike ?? false
        let likeCnt: Int = review.likeCount ?? 0
        let disLikeCnt: Int = review.disLikeCount ?? 0
        let level:Int = review.level ?? 0
        let score:Float = review.score ?? 0.0
        let createdAt:Int = review.createdAt ?? 0
        let updatedAt:Int = review.updatedAt ?? 0
        
        if (review.profile?.count ?? 0) > 0 {
            let profileImageUrl:String = review.profile?[0].mediaResource?.small?.src ?? ""
            profileImageSetting(url: profileImageUrl)
        }

        nameGL.text = name
        
        reviewContentsGL.text = reviewContnets
        
        if likeCnt > 999 {
            likeCntGL.text = "999+"
        }else {
            likeCntGL.text = String(likeCnt)
        }
        
        if disLikeCnt > 999 {
            disLikeCntGL.text = "999+"
        }else {
            disLikeCntGL.text = String(disLikeCnt)
        }
        
        if createdAt < updatedAt {
            writeDateGL.text = updatedAt.timeStampToDate()
        }else {
            writeDateGL.text = createdAt.timeStampToDate()
        }
        
        if hasLike {
            likeImage.image = UIImage(named: "reviewLikeOn")
        }else {
            likeImage.image = UIImage(named: "reviewLikeOff")
        }
        
        if hasDislike {
            disLikeImage.image = UIImage(named: "reviewDisLikeOn")
        }else {
            disLikeImage.image = UIImage(named: "reviewDisLikeOff")
        }
        
        scoreGL.text = String(score)
        
        levelNameSetting(level:level)
        
        let line = sizeOfString(contents: reviewContnets)
        
        if line.0 > 2 {
            reviewBottomExpandedWrap.isHidden = false
        }else {
            reviewBottomExpandedWrap.isHidden = true
        }
        
        if expandFlag {
            moreGL.text = "접기"
            moreImage.image = UIImage(named: "expandMoreUp")
        }else {
            moreGL.text = "더보기"
            moreImage.image = UIImage(named: "expandMoreDown")
        }
        
        starView.current = CGFloat(score)
    }
    
    //레벨 명칭 세팅
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
    
    //리뷰 컨텐츠 라인 체크
    func sizeOfString(contents:String) -> (CGFloat,CGFloat){
        let contentsLine = (round(contents.boundingRect(
                                    with: CGSize(width: deviceWidth - 34.0, height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: [.font: UIFont(name: "AppleSDGothicNeo-Medium", size: 13.0) ],
            context: nil).size.height / UIFont(name: "AppleSDGothicNeo-Medium", size: 13.0)!.lineHeight * 1000) / 1000)
        let spacing = (round((contentsLine * 4) * 1000) / 1000)
        let textViewHeight = (contentsLine * (UIFont(name: "AppleSDGothicNeo-Medium", size: 13.0)!.lineHeight)) + spacing

        return (line:contentsLine,height:textViewHeight)
    }
    
    //주류 랭킹 이미지 세팅
    func profileImageSetting(url:String) {
        if url.count > 0 {
            profileImage.isHidden = false
            defaultProfileImage.isHidden = true
            let webpimageURL = URL(string: url)!
            Nuke.loadImage(with: webpimageURL, into: profileImage)
            WebPImageDecoder.enable()
        }else {
            profileImage.isHidden = true
            defaultProfileImage.isHidden = false
        }
    }
}
