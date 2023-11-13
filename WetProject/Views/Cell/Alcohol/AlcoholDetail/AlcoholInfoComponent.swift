//
//  AlcoholInfoType01.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/27.
//

import UIKit

//주류 상세페이지 지표 표현을 위한 UICell 컴포넌트
class AlcoholInfoComponent:UIView {

    private let xibName = "AlcoholInfoComponent"
    
    @IBOutlet weak var titleGL: UILabel!
    @IBOutlet weak var subTitleGL: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var alcoholInfoWrap: UIView?
    @IBOutlet weak var contentsGL: UILabel!
    @IBOutlet weak var titleUnderLine: UIView!
    
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
        alcoholInfoWrap?.layer.cornerRadius = 5.0
        alcoholInfoWrap?.borderAll(width: 0.5, color: UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1.0).cgColor)
        alcoholInfoWrap?.shadow(opacity: 0.2, radius: 1, offset: CGSize(width: 1, height: 1),color: UIColor(red: 207/255, green: 207/255, blue: 207/255, alpha: 1).cgColor)
        contentsGL.adjustsFontSizeToFitWidth = true
        self.addSubview(view)
    }
    
    func cellSetting(cell:String) {
        if cell == "ibu" {
            titleGL.text = "IBU"
            subTitleGL.text = "쓴맛지표"
            contentsGL.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 20.0)
            image.image = UIImage(named: "ibu")
        }else if cell == "srm" {
            titleGL.text = "SRM"
            subTitleGL.text = "색"
            image.isHidden = true
            titleGL.textColor = .white
            subTitleGL.textColor = .white
            contentsGL.textColor = .white
            titleUnderLine.backgroundColor = .white
            contentsGL.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 20.0)
        }else if cell == "hop" {
            titleGL.text = "Hop"
            subTitleGL.text = "홉"
            contentsGL.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16.0)
            image.image = UIImage(named: "hop")
        }else if cell == "temperature" {
            titleGL.text = "Temperature"
            subTitleGL.text = "음용 온도"
            contentsGL.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 20.0)
            image.image = UIImage(named: "temperature")
        }else if cell == "filtered" {
            titleGL.text = "Filtered"
            subTitleGL.text = "여과 여부"
            contentsGL.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16.0)
            image.image = UIImage(named: "filtered")
        }else if cell == "malt" {
            titleGL.text = "Malt"
            subTitleGL.text = "몰트"
            contentsGL.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16.0)
            image.image = UIImage(named: "malt")
        }else if cell == "adjunct" {
            titleGL.text = "Adjunct"
            subTitleGL.text = "첨가물"
            contentsGL.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16.0)
            image.image = UIImage(named: "adjunct")
        }else if cell == "barrel" {
            titleGL.text = "Barrel"
            subTitleGL.text = "오크숙성"
            contentsGL.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16.0)
            image.image = UIImage(named: "barrel")
        }else if cell == "color" {
            titleGL.text = "Color"
            subTitleGL.text = "색"
            image.isHidden = true
            contentsGL.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16.0)
            image.image = UIImage(named: "color")
        }else if cell == "body" {
            titleGL.text = "Body"
            subTitleGL.text = "바디"
            contentsGL.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16.0)
            image.image = UIImage(named: "body")
        }else if cell == "acidic"{
            titleGL.text = "Acidic"
            subTitleGL.text = "산도"
            image.image = UIImage(named: "acidic")
        }else if cell == "tannin" {
            titleGL.text = "Tannin"
            subTitleGL.text = "타닌"
            contentsGL.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16.0)
            image.image = UIImage(named: "tannin")
        }else if cell == "sweet" {
            titleGL.text = "Sweet"
            subTitleGL.text = "당도"
            contentsGL.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16.0)
            image.image = UIImage(named: "sweet")
        }else if cell == "smv" {
            titleGL.text = "SMV"
            subTitleGL.text = "당도"
            contentsGL.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 20.0)
            image.image = UIImage(named: "sweet")
        }else if cell == "rpr" {
            titleGL.text = "RPR"
            subTitleGL.text = "정미율"
            contentsGL.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 20.0)
            image.image = UIImage(named: "rpr")
        }else if cell == "caskType" {
            titleGL.text = "Cask Type"
            subTitleGL.text = "캐스크 종류"
            contentsGL.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16.0)
            image.image = UIImage(named: "caskType")
        }else if cell == "sakeType" {
            titleGL.text = "Sake Type"
            subTitleGL.text = "사케 타입"
            contentsGL.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16.0)
            image.image = UIImage(named: "sakeType")
        }else if cell == "grape" {
            titleGL.text = "Grape"
            subTitleGL.text = "포도 품종"
            contentsGL.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16.0)
            image.image = UIImage(named: "grape")
        }else if cell == "agedYear" {
            titleGL.text = "Aged Year"
            subTitleGL.text = "숙성 기간"
            contentsGL.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 20.0)
            image.image = UIImage(named: "agedYear")
        }
    }
}

