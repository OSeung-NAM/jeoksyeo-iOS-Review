//
//  CarouselView.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/26.
//

import UIKit

//https://uruly.xyz/carousel-infinite-scroll-3/
//메인화면 주류 추천 CollectionView 를 관리하기위한 파일
class MainRecommendCV: UICollectionView {
    
    let cellIdentifier = "MainRecommendCell"
    var alcoholList:[MainRecommendAlcoholList]?
    let isInfinity = true
    var cellItemsWidth: CGFloat = 0.0
    var callingView:Any?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.delegate = self
        self.dataSource = self
        self.register(UINib(nibName: "MainRecommendCell", bundle: nil), forCellWithReuseIdentifier: "MainRecommendCell")
        self.decelerationRate = .fast //스크롤 속도 조정
    }
    
    convenience init(frame: CGRect,cellWidth:CGFloat,cellHeight:CGFloat, spacing:CGFloat) {
        let layout = PagingPerCellFlowLayout()
        
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = spacing
        
        self.init(frame: frame, collectionViewLayout: layout)
        
        // 수평 막대스크롤 숨기기
        self.showsHorizontalScrollIndicator = false
        self.backgroundColor = UIColor.white
    }
    
    // 셀의 비율 변경
    func transformScale(cell: UICollectionViewCell) {
        let cellCenter:CGPoint = self.convert(cell.center, to: nil) //셀의 중심좌표
        let screenCenterX:CGFloat = UIScreen.main.bounds.width / 2  //화면의 중심 좌표
        let reductionRatio:CGFloat = -0.0004                        //양옆 축소 된 값
        let maxScale:CGFloat = 1                                    //가운데 커지는 값
        let cellCenterDisX:CGFloat = abs(screenCenterX - cellCenter.x)
        let newScale = reductionRatio * cellCenterDisX + maxScale
        cell.transform = CGAffineTransform(scaleX:newScale, y:newScale)
    }
    
    // 초기 셀 위치 중간
    func scrollToFirstItem() {
        if isInfinity {
            guard let alcoholList = alcoholList else {
                scrollToItem(at:IndexPath(row: 5, section: 0) , at: .centeredHorizontally, animated: true)
                return
            }
            scrollToItem(at:IndexPath(row: alcoholList.count, section: 0) , at: .centeredHorizontally, animated: true)
        }
    }
}

extension MainRecommendCV: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // 섹션당 셀 수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let mainAlcoholList = alcoholList else {
            return isInfinity ? 5 * 3 : 5
        }
        return isInfinity ? mainAlcoholList.count * 3 : mainAlcoholList.count
    }
    
    // 셀 설정
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let alcoholList = alcoholList else {
            let mainRecommendCell : MainRecommendCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "MainRecommendCell", for: indexPath) as? MainRecommendCell
            mainRecommendCell?.bottomWrap.isHidden = true
            mainRecommendCell?.bottomIsEmptyWrap.isHidden = false
            return mainRecommendCell!
        }
        
        let mainRecommendCell : MainRecommendCell? = collectionView.dequeueReusableCell(withReuseIdentifier: "MainRecommendCell", for: indexPath) as? MainRecommendCell
        
        //정확한 index
        let fixedIndex = isInfinity ? indexPath.row % alcoholList.count : indexPath.row
        
        let alcoholId:String = alcoholList[fixedIndex].alcoholId
        let alcoholName:String = alcoholList[fixedIndex].name?.kr ?? "" //술 이름
        let abv:Double = alcoholList[fixedIndex].abv ?? 0.0 //술 도수
        let alcoholLikeCnt:Int = alcoholList[fixedIndex].alcoholLikeCount ?? 0 //술 좋아요 갯수
        let reviewScore:Float = alcoholList[fixedIndex].review?.score ?? 0.0 //리뷰 평점
        let alcoholImageUrl:String = alcoholList[fixedIndex].media?[0].mediaResource?.medium?.src ?? ""
        let isLiked:Bool = alcoholList[fixedIndex].isLiked ?? false
        
        if alcoholLikeCnt > 9999 {
            mainRecommendCell?.likeCnt.text = "9999+"
        }else {
            mainRecommendCell?.likeCnt.text = String(alcoholLikeCnt)
        }
        
        mainRecommendCell?.alcoholName.text = alcoholName
        mainRecommendCell?.percentage.text = "\(abv)%"
        
        mainRecommendCell?.score.text = "\(reviewScore)"
        mainRecommendCell?.starView.current = CGFloat(reviewScore)
        mainRecommendCell?.bottomWrap.isHidden = false
        mainRecommendCell?.bottomIsEmptyWrap.isHidden = true
        mainRecommendCell?.alcoholImageSetting(urlString: alcoholImageUrl)
        mainRecommendCell?.likeImageSetting(isLiked: isLiked)
        mainRecommendCell?.likeWrap.tag = fixedIndex
        
        let alcoholDetailTap = MainVCTapGesture(target: self, action: #selector(alcoholDetailMove(_:)))
        alcoholDetailTap.alcoholId = alcoholId
        mainRecommendCell?.alcoholImage.addGestureRecognizer(alcoholDetailTap)
        
        let alcoholLikeTap = MainVCTapGesture(target: self, action: #selector(alcoholLike(_:)))
        alcoholLikeTap.alcoholId = alcoholId
        alcoholLikeTap.likeFlag = !isLiked
        mainRecommendCell?.likeWrap.addGestureRecognizer(alcoholLikeTap)
        
        return mainRecommendCell!
    }
    
    //주류 이동(부모: MainVC)으로 전달
    @objc func alcoholDetailMove(_ sender: MainVCTapGesture) {
        if let mainVC:MainVC = callingView as? MainVC {
            mainVC.alcoholDetailMove(sender)
        }
    }
    
    //주류 좋아요/좋아요 취소(부모: MainVC)으로 전달
    @objc func alcoholLike(_ sender: MainVCTapGesture) {
        if let mainVC:MainVC = callingView as? MainVC {
            mainVC.alcoholLike(sender)
        }
    }
}

extension MainRecommendCV: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isInfinity {
            if cellItemsWidth == 0.0 {
                cellItemsWidth = floor(scrollView.contentSize.width / 3.0)//표시 할 요소 그룹의 width를 계산
            }
            
            if (scrollView.contentOffset.x <= 0.0) || (scrollView.contentOffset.x > cellItemsWidth * 2.0) {
                //스크롤 위치가 임계 값을 초과하면 중앙 취소
                scrollView.contentOffset.x = cellItemsWidth
            }
        }
    }
}
