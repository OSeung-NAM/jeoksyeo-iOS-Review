//
//  StoryBoardName.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/15.
//

import UIKit

//스토리 보드 호출 시 일일 히 객체를 생성하는데 번거로움이 있어 미리 스토리보드 객체를 하나의 파일로 모아둔 파일
struct StoryBoardName {
    static let mainStoryBoard:UIStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
    static let signUpStoryBoard:UIStoryboard = UIStoryboard.init(name: "SignUp", bundle: nil)
    static let mainServiceStoryBoard:UIStoryboard = UIStoryboard.init(name: "MainService", bundle: nil)
    static let myPageStoryBoard:UIStoryboard = UIStoryboard.init(name: "MyPage", bundle: nil)
    static let popupStoryBoard:UIStoryboard = UIStoryboard.init(name: "Popup", bundle: nil)
    static let policyStoryBoard:UIStoryboard = UIStoryboard.init(name: "Policy", bundle: nil)
}
