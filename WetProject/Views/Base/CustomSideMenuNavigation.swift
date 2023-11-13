//
//  SideMenuViewController.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/19.
//

import UIKit
import SideMenu

//사이트 메뉴 UI컨트롤 하기위한 베이스 파일
class CustomSideMenuNavigation: SideMenuNavigationController {
    
    var callingView:Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presentationStyle = .menuSlideIn
        self.menuWidth = self.view.frame.width * 0.75
        //사이드바 호출 시 뒷배경 투명도조절
        self.presentationStyle.presentingEndAlpha = 0.5
    }
}
