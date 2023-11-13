//
//  ReLoginService.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/04.
//

import Foundation
import UIKit

//로그인 화면 띄우기 위한 공통 파일
class LoginService {
    
    static let shared = LoginService()

    //리프레시 토큰까지 만료 된 경우 및 로그인 안된 경우 소셜 로그인 화면으로 가야함
    func login(callingView: Any){
        if let viewController = callingView as? UIViewController {
            let signInVC = StoryBoardName.signUpStoryBoard.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
            
            viewController.present(signInVC, animated: true, completion: nil)
        }
    }
}
