//
//  SignUpAreaCell.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/20.
//

import UIKit

//회원가입 시 지역정보 리스트 표현을 위한 UICell 컴포넌
class SignUpAreaCell: UICollectionViewCell {
    
    @IBOutlet weak var areaBGImage: UIImageView!
    @IBOutlet weak var areaName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        areaBGImage.image = UIImage(named: "roundboxWhite")
    }
}
