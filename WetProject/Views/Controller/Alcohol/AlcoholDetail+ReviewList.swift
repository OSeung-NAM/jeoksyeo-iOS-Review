//
//  AlcoholDetail+ReviewList.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/27.
//

import UIKit

//주류 상세화면 하단 리뷰부분 화면 UI를 컨트롤 하기위한 파일
extension AlcoholDetailVC {

    //주류리뷰 부분 점수별 게이지 세팅
    func reviewScoreGaugeSetting(reviewInfo:ReviewInfo?) {
        guard let reviewInfo = reviewInfo else {return}
        let score1Cnt:Int = reviewInfo.score1Count ?? 0
        let score2Cnt:Int = reviewInfo.score2Count ?? 0
        let score3Cnt:Int = reviewInfo.score3Count ?? 0
        let score4Cnt:Int = reviewInfo.score4Count ?? 0
        let score5Cnt:Int = reviewInfo.score5Count ?? 0
        let reviewTotalCnt:Int = reviewInfo.reviewTotalCount ?? 0
        
    
        if reviewTotalCnt == 0 { //리뷰가 작성 안되어 있다는건 사용자 지표 또한 없다는것이기 때문에 숨김 여부 처리
            userAssessmentWrap.isHidden = true
            userGraphIsEmptyWrap?.isHidden = false
        }else {
            userAssessmentWrap.isHidden = false
            userGraphIsEmptyWrap?.isHidden = true
        }

        
        let percent5:Double = Double(score5Cnt)/Double(reviewTotalCnt)*100
        var scoreGaugeBarWidth:CGFloat = CGFloat((Double(score5GaugeBarWrap.frame.width)/Double(100)) * percent5)
        var scoreGaugeBarHeight:CGFloat = score5GaugeBarWrap.frame.height
        
        scoreGaugeBarVisibleSetting(view: score5GaugeBar, score: percent5,width: scoreGaugeBarWidth,height: scoreGaugeBarHeight)
        
        let percent4:Double = Double(score4Cnt)/Double(reviewTotalCnt)*100
        scoreGaugeBarWidth = CGFloat((Double(score4GaugeBarWrap.frame.width)/Double(100)) * percent4)
        scoreGaugeBarHeight = score4GaugeBarWrap.frame.height
        
        
        scoreGaugeBarVisibleSetting(view: score4GaugeBar, score: percent4,width: scoreGaugeBarWidth,height: scoreGaugeBarHeight)
        
        let percent3:Double = Double(score3Cnt)/Double(reviewTotalCnt)*100
        scoreGaugeBarWidth = CGFloat((Double(score3GaugeBarWrap.frame.width)/Double(100)) * percent3)
        scoreGaugeBarHeight = score3GaugeBarWrap.frame.height
        
        scoreGaugeBarVisibleSetting(view: score3GaugeBar, score: percent3,width: scoreGaugeBarWidth,height: scoreGaugeBarHeight)
        
        let percent2:Double = Double(score2Cnt)/Double(reviewTotalCnt)*100
        scoreGaugeBarWidth = CGFloat((Double(score2GaugeBarWrap.frame.width)/Double(100)) * percent2)
        scoreGaugeBarHeight = score2GaugeBarWrap.frame.height
        
        scoreGaugeBarVisibleSetting(view: score2GaugeBar, score: percent2,width: scoreGaugeBarWidth,height: scoreGaugeBarHeight)
        
        let percent1:Double = Double(score1Cnt)/Double(reviewTotalCnt)*100
        scoreGaugeBarWidth = CGFloat((Double(score1GaugeBarWrap.frame.width)/Double(100)) * percent1)
        scoreGaugeBarHeight = score1GaugeBarWrap.frame.height
        
        scoreGaugeBarVisibleSetting(view: score1GaugeBar, score: percent1, width: scoreGaugeBarWidth, height: scoreGaugeBarHeight)
        
    }
    
    //주류리뷰 부분 점수별 게이지 숨김여부 세팅
    func scoreGaugeBarVisibleSetting(view:UIView, score:Double, width:CGFloat, height:CGFloat){
        if score > 0.0 {
            view.isHidden = false
            view.frame = CGRect(x: 0 , y: 0, width: width, height: height)
        }else {
            view.isHidden = true
        }
    }
    
    //스크롤뷰 하단 리뷰 리스트 세팅
    func reviewListSetting(reviewList:[ReviewList]?) {
        guard let reviewList = reviewList else {return}
        
        for view in reviewListWrap.subviews {
            if let _ = view as? AlcoholDetailReview {
                view.removeFromSuperview()
            }
        }
        
        let defaultReviewHeight:CGFloat = 142.0
        
        if (reviewList.count > 0) {
            reviewIsEmptyWrap.isHidden = true
            
            var reviewListWrapHeight:CGFloat = 0.0
            var index:Int = 0
            let reviewMoreWrapHeight:CGFloat = 60.0
            for _ in reviewList {
                if index < 3 {
                    let reviewContents = reviewList[index].contents ?? ""
                    let expandedFlag:Bool = reviewList[index].expandFlag
                    var defaultTextViewHeight:CGFloat = 39.6
                    //리뷰 컨텐츠 라인 체크
                    let contentsLine = reviewContents.lineOfString(width: view.frame.width - 26.0, font: UIFont(name: "AppleSDGothicNeo-Medium", size: 13.0) ?? UIFont.boldSystemFont(ofSize: 13.0), lineSpacing: 4.0)
                    //리뷰 컨텐츠 높이 체크
                    let contentsHeight = reviewContents.heightOfString(width: view.frame.width - 26.0, font: UIFont(name: "AppleSDGothicNeo-Medium", size: 13.0) ?? UIFont.boldSystemFont(ofSize: 13.0), lineSpacing: 4.0)
                    
                    
                    if expandedFlag {
                        if contentsLine > 2 {
                            defaultTextViewHeight = contentsHeight
                        }
                    }
                    
                    let review = AlcoholDetailReview(frame: CGRect(x: 0.0, y: reviewListWrapHeight, width: reviewListWrap.frame.width, height: defaultReviewHeight + defaultTextViewHeight))
                    
                    //리뷰 내용 더보기
                    let reviewContentsMoreTap = AlcoholDetailVCTapGesture(target: self, action: #selector(reviewContentsExpand(_:)))
                    reviewContentsMoreTap.reviewExpandedFlag = reviewList[index].expandFlag
                    reviewContentsMoreTap.reviewId = reviewList[index].reviewId ?? ""
                    reviewContentsMoreTap.reviewList = reviewList
                    review.moreWrap.addGestureRecognizer(reviewContentsMoreTap)
                    
                    
                    //리뷰 좋아요
                    let reviewLikeTap = AlcoholDetailVCTapGesture(target: self, action: #selector(reviewLike(_:)))
                    reviewLikeTap.reviewId = reviewList[index].reviewId ?? ""
                    reviewLikeTap.reviewHasLike = reviewList[index].hasLike ?? false
                    reviewLikeTap.reviewList = reviewList
                    review.likeWrap.addGestureRecognizer(reviewLikeTap)
                    
                    //리뷰 싫어요
                    let reviewDisLikeTap = AlcoholDetailVCTapGesture(target: self, action: #selector(reviewDisLike(_:)))
                    
                    reviewDisLikeTap.reviewId = reviewList[index].reviewId ?? ""
                    reviewDisLikeTap.reviewHasDisLike = reviewList[index].hasDisLike ?? false
                    reviewDisLikeTap.reviewList = reviewList
                    review.disLikeWrap.addGestureRecognizer(reviewDisLikeTap)
                    
                    review.expandImage.image = UIImage(named: "expandMoreUp")
                    
                    if expandedFlag {
                        review.expandImage.image = UIImage(named: "expandMoreUp")
                        review.moreGL.text = "접기"
                    }else {
                        if contentsLine > 2 {
                            review.moreWrap.isHidden = false
                            review.expandImage.image = UIImage(named: "expandMoreDown")
                            review.moreGL.text = "더보기"
                        }else {
                            review.moreWrap.isHidden = true
                        }
                    }
                    
                    review.reviewSetting(review: reviewList[index])
                    review.reviewContentsTV.text = reviewContents
                    reviewListWrapHeight += defaultReviewHeight
                    reviewListWrapHeight += defaultTextViewHeight
                    reviewListWrap.addSubview(review)
                    index += 1
                }
            }
            
            reviewIsEmptyWrap.isHidden = true
            reviewListWrap.constraints.forEach { (constraint) in // ---- 3
                if constraint.firstAttribute == .height {
                    if reviewList.count > 3 {
                        constraint.constant = (reviewListWrapHeight + reviewMoreWrapHeight)
                    }else {
                        constraint.constant = reviewListWrapHeight
                    }
                }
            }
        }else {
            reviewIsEmptyWrap.isHidden = false
            reviewListWrap.constraints.forEach { (constraint) in // ---- 3
                if constraint.firstAttribute == .height {
                    constraint.constant = 176
                }
            }
        }
    }
    
    //리뷰 내용 더보기 펼치기 관리
    @objc func reviewContentsExpand(_ gesture: AlcoholDetailVCTapGesture) {
        if let reactor = reactor {
            reactor.action.onNext(.reviewContentsExpanded(gesture.reviewList, gesture.reviewId, gesture.reviewExpandedFlag))
        }
    }
    
    //리뷰 좋아요 관리
    @objc func reviewLike(_ gesture: AlcoholDetailVCTapGesture) {
        let reviewLikeFlag:Bool = gesture.reviewHasLike
        let reviewList = gesture.reviewList
        let reviewId = gesture.reviewId
        if let reactor = reactor {
            let pathParams = [
                "alcoholId" : alcoholId,
                "reviewId" : gesture.reviewId
            ]
            if reviewLikeFlag {
                reactor.action.onNext(.reviewLikeOff(reviewList,reviewId,pathParams))
            }else {
                reactor.action.onNext(.reviewLikeOn(reviewList,reviewId,pathParams))
            }
            
        }
    }
    
    //리뷰 싫어요 관리
    @objc func reviewDisLike(_ gesture: AlcoholDetailVCTapGesture) {
        
        let reviewDisLikeFlag:Bool = gesture.reviewHasDisLike
        let reviewList = gesture.reviewList
        let reviewId = gesture.reviewId
        if let reactor = reactor {
            let pathParams = [
                "alcoholId" : alcoholId,
                "reviewId" : gesture.reviewId
            ]
        
            if reviewDisLikeFlag {
                reactor.action.onNext(.reviewDisLikeOff(reviewList,reviewId,pathParams))
            }else {
                reactor.action.onNext(.reviewDisLikeOn(reviewList,reviewId,pathParams))
            }
        }
    }
}
