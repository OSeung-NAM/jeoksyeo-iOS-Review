//
//  MyReviewCategoryTableCell.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/03.
//

import UIKit

//내가 평가 한 리뷰 리스트 상단 카테고리 리스트 표현을 위한 UICell 컴포넌트
class MyReviewCategoryTableCell: UICollectionViewCell {
    
    @IBOutlet weak var reviewListTV: UITableView!
    
    var tableCount:Array<Int> = [2]
    
    var reviewList:MyReviewListRPModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let myReviewTableHeader = UINib.init(nibName: "MyReviewTableHeader", bundle: Bundle.main)
        reviewListTV.register(myReviewTableHeader, forHeaderFooterViewReuseIdentifier: "MyReviewTableHeader")
        
        reviewListTV.dataSource = self
        reviewListTV.delegate = self
        
        reviewListTV.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
    }
    
    override func prepareForReuse() {
        
    }
}

extension MyReviewCategoryTableCell :UITableViewDataSource, UITableViewDelegate {
    
    //헤더 전용 cell추가
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let myReviewTableHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MyReviewTableHeader") as! MyReviewTableHeader
        return myReviewTableHeader
    }
    
    //헤더 높이 조절
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5.0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let reviewList = reviewList?.data?.reviewList else {return 0}

        return reviewList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var myReviewCell : MyReviewCell? = tableView.dequeueReusableCell(withIdentifier: "MyReviewCell") as? MyReviewCell
        
        if myReviewCell == nil {
            myReviewCell = Bundle.main.loadNibNamed("MyReviewCell", owner: self, options: nil)?.first as? MyReviewCell
        }
        myReviewCell?.backgroundColor = .white
        myReviewCell?.selectionStyle = .none
        
        if let reviewList = reviewList?.data?.reviewList {
            let reviewContents = reviewList[indexPath.row].contents
            myReviewCell?.reviewContents.text = reviewContents
        }
        
        return myReviewCell!
    }
    
    @objc func reviewContentsExpend() {
        tableCount.insert(100, at: 0)
        reviewListTV.reloadData()
    }
}
