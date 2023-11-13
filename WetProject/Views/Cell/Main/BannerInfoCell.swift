//
//  BannerInfoCell.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/28.
//

import UIKit
import FSPagerView
import Nuke
import NukeWebPPlugin
import RxCocoa
import RxSwift

//메인화면 배너 관련 리스트 표현을 위한 UICell 컴포넌트
class BannerInfoCell:UIView, FSPagerViewDelegate, FSPagerViewDataSource {

    private let xibName = "BannerInfoCell"
    
    @IBOutlet weak var bannerView: FSPagerView? {
        didSet {
            bannerView?.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        }
    }
    @IBOutlet weak var bannerCntWrap: UIView?
    @IBOutlet weak var bannerCntGL: UILabel?
    
    var disposeBag: DisposeBag = DisposeBag()
    
    var bannerList:BehaviorRelay<[MainBanner]> = BehaviorRelay.init(value: [])

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
        
        bannerView?.backgroundColor = .white
        bannerView?.delegate = self
        bannerView?.dataSource = self
        
        bannerView?.automaticSlidingInterval = 6.0 //6초마다 페이지 넘어감
        bannerView?.isInfinite = true //배너 무한스크롤 여부 - carousel처리됨.
        bannerView?.transformer = .none //배너 페이징 형식
        
        bannerView?.itemSize = .zero
        
        bannerCntWrap?.layer.cornerRadius = 10.0

        self.addSubview(view)
        
        output()
    }
    
    func output() {
        bannerList
            .subscribe(onNext:{ [weak self] data in
                self?.bannerCntGL?.text = "0/0"
                self?.bannerCntGL?.text = "1/" + String(self?.bannerList.value.count ?? 0)
                self?.bannerView?.reloadData()
            })
            .disposed(by: disposeBag)
    }

    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return bannerList.value.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {  
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        
        let bannerImageUrl:String = bannerList.value[index].media.mediaResource?.large?.src ?? ""
        alcoholImageSetting(urlString: bannerImageUrl, cell: cell)
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true

        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        let bannerUrl:String = bannerList.value[index].url
        if let url = URL(string: bannerUrl) {
            UIApplication.shared.open(url)
        }
    }
    
    func alcoholImageSetting(urlString: String, cell:FSPagerViewCell) {
        let imageView = UIImageView()
        
        let webpimageURL = URL(string: urlString)!
        Nuke.loadImage(with: webpimageURL, into: cell.imageView ?? imageView)
        WebPImageDecoder.enable()
    }
    
    //메인 배너 자동 스크롤 후 이벤트
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        bannerCntGL?.text = "0/0"
        bannerCntGL?.text = "\(pagerView.currentIndex+1)/\(bannerList.value.count)"
    }
    
    //메인 배너 사용자 직접 스크롤 후 이벤트
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        bannerCntGL?.text = "0/0"
        bannerCntGL?.text = "\(targetIndex+1)/\(bannerList.value.count)"
    }
}
