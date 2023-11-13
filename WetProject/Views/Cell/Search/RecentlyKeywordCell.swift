//
//  RecentlyKeywordCell.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/16.
//

import UIKit

//주류 검색페이지 최근검색어 키워드 리스트 표현을위한 UICell 컴포넌
class RecentlyKeywordCell:UITableViewCell {
 
    @IBOutlet weak var keywordNameBtn: UIButton!
//    @IBOutlet weak var keywordName: UILabel!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
          //재 사용 시 이미지 리로딩에 관한 부분 처리
    }
}
