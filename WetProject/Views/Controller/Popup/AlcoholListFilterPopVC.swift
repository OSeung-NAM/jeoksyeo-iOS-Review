//
//  AlcoholListFilterPopVC.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/03.
//

import UIKit
import BottomPopup

//주류 리스트 필터링 바텀시트 화면 UI를 컨트롤 하기위한 파일
class AlcoholListFilterPopVC: BottomPopupViewController {
    
    var height: CGFloat?
    var topCornerRadius: CGFloat?
    var presentDuration: Double?
    var dismissDuration: Double?
    var shouldDismissInteractivelty: Bool?

    
    //좋아요순
    @IBOutlet weak var likeBtn: UIButton!
    //리뷰순
    @IBOutlet weak var reviewBtn: UIButton!
    //높은 도수순
    @IBOutlet weak var highAlcoholBtn: UIButton!
    //낮은 도수순
    @IBOutlet weak var lowAlcoholBtn: UIButton!
    
    var filterIndex:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterTitleColorInit()
        
        if filterIndex == 0 {
            likeBtn.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1), for: .normal)
        }else if filterIndex == 1 {
            reviewBtn.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1), for: .normal)
        }else if filterIndex == 2 {
            highAlcoholBtn.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1), for: .normal)
        }else {
            lowAlcoholBtn.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1), for: .normal)
        }
    }
    
    func filterTitleColorInit() {
        self.likeBtn.setTitleColor(UIColor(red: 143/255, green: 143/255, blue: 143/255, alpha: 1), for: .normal)
        self.reviewBtn.setTitleColor(UIColor(red: 143/255, green: 143/255, blue: 143/255, alpha: 1), for: .normal)
        self.highAlcoholBtn.setTitleColor(UIColor(red: 143/255, green: 143/255, blue: 143/255, alpha: 1), for: .normal)
        self.lowAlcoholBtn.setTitleColor(UIColor(red: 143/255, green: 143/255, blue: 143/255, alpha: 1), for: .normal)
    }
    
    //좋아요순
    @IBAction func likeBtn(_ sender: Any) {
        if let pvc = presentingViewController as? UINavigationController {
            let parentView = pvc.viewControllers[pvc.viewControllers.count-1] //해당 화면을 호출 한 화면 (제일 마지막 stack view)
            if let tabbarController = parentView as? UITabBarController {
                if let nvc = tabbarController.selectedViewController as? UINavigationController {
                    let lastView = nvc.viewControllers[nvc.viewControllers.count-1]
                    if let alcoholListVC:AlcoholListVC = lastView as? AlcoholListVC {
                        dismiss(animated: true, completion: nil)
                        alcoholListVC.filterChange(filterIndex: 0)
                    }
                }
            }
        }
//        if let pvc = presentingViewController as? UINavigationController {
//            let lastView = pvc.viewControllers[pvc.viewControllers.count-1] //해당 화면을 호출 한 화면 (제일 마지막 stack view)
//            if let alcoholListVC:AlcoholListVC = lastView as? AlcoholListVC {
//                dismiss(animated: true, completion: nil)
//                alcoholListVC.filterChange(filterIndex: 0)
//            }
//        }
    }
    
    //리뷰순
    @IBAction func reviewBtn(_ sender: Any) {
        if let pvc = presentingViewController as? UINavigationController {
            let parentView = pvc.viewControllers[pvc.viewControllers.count-1] //해당 화면을 호출 한 화면 (제일 마지막 stack view)
            if let tabbarController = parentView as? UITabBarController {
                if let nvc = tabbarController.selectedViewController as? UINavigationController {
                    let lastView = nvc.viewControllers[nvc.viewControllers.count-1]
                    if let alcoholListVC:AlcoholListVC = lastView as? AlcoholListVC {
                        dismiss(animated: true, completion: nil)
                        alcoholListVC.filterChange(filterIndex: 1)
                    }
                }
            }
        }
    }
    
    //높은 도수순
    @IBAction func highAlcoholBtn(_ sender: Any) {
        if let pvc = presentingViewController as? UINavigationController {
            let parentView = pvc.viewControllers[pvc.viewControllers.count-1] //해당 화면을 호출 한 화면 (제일 마지막 stack view)
            if let tabbarController = parentView as? UITabBarController {
                if let nvc = tabbarController.selectedViewController as? UINavigationController {
                    let lastView = nvc.viewControllers[nvc.viewControllers.count-1]
                    if let alcoholListVC:AlcoholListVC = lastView as? AlcoholListVC {
                        dismiss(animated: true, completion: nil)
                        alcoholListVC.filterChange(filterIndex: 2)
                    }
                }
            }
        }
//        if let pvc = presentingViewController as? UINavigationController {
//            let lastView = pvc.viewControllers[pvc.viewControllers.count-1] //해당 화면을 호출 한 화면 (제일 마지막 stack view)
//
//            if let alcoholListVC:AlcoholListVC = lastView as? AlcoholListVC {
//                dismiss(animated: true, completion: nil)
//                alcoholListVC.filterChange(filterIndex: 2)
//            }
//        }
    }
    
    //낮은 도수순
    @IBAction func lowAlcoholBtn(_ sender: Any) {
        if let pvc = presentingViewController as? UINavigationController {
            let parentView = pvc.viewControllers[pvc.viewControllers.count-1] //해당 화면을 호출 한 화면 (제일 마지막 stack view)
            if let tabbarController = parentView as? UITabBarController {
                if let nvc = tabbarController.selectedViewController as? UINavigationController {
                    let lastView = nvc.viewControllers[nvc.viewControllers.count-1]
                    if let alcoholListVC:AlcoholListVC = lastView as? AlcoholListVC {
                        dismiss(animated: true, completion: nil)
                        alcoholListVC.filterChange(filterIndex: 3)
                    }
                }
            }
        }
    
//        if let pvc = presentingViewController as? UINavigationController {
//            let lastView = pvc.viewControllers[pvc.viewControllers.count-1] //해당 화면을 호출 한 화면 (제일 마지막 stack view)
//
//            if let alcoholListVC:AlcoholListVC = lastView as? AlcoholListVC {
//                dismiss(animated: true, completion: nil)
//                alcoholListVC.filterChange(filterIndex: 3)
//            }
//        }
    }
    
    override var popupHeight: CGFloat { return height ?? CGFloat(250) }
      
    override var popupTopCornerRadius: CGFloat { return topCornerRadius ?? CGFloat(0) }
      
    //나타나는데 보여지는 시간
    override var popupPresentDuration: Double { return presentDuration ?? 0.2 }
      
    //사라지는데 보여지는 시간
    override var popupDismissDuration: Double { return dismissDuration ?? 0.2 }
      
    override var popupShouldDismissInteractivelty: Bool { return shouldDismissInteractivelty ?? true }
      
    override var popupDimmingViewAlpha: CGFloat { return 0.61 }
     
}
