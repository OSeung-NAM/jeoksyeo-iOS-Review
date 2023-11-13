//
//  UITextField+extension.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/18.
//

import UIKit

//닉네임 체크가능한 UITextField 확장파일
extension UITextField {
    //우측 패딩 값 조절용도
    func addRightPadding(paddingWidth:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: paddingWidth, height: self.frame.height))
        self.rightView = paddingView
        self.rightViewMode = ViewMode.always
    }
    
    //닉네임 한글, 숫자, 영어만 가능한지 여부 체크하는 메서드
    func nickNameCheck(filter:String = "[0-9a-zA-Zㄱ-ㅎㅏ-ㅣ가-힣]") -> Bool {
        let newText = self.text!
        let regex = try! NSRegularExpression(pattern: filter, options: [])
        let list = regex.matches(in:newText, options: [], range:NSRange.init(location: 0, length:newText.count))
        if(list.count != newText.count){
            return false
        }
        return true
    }
    
    func nickNameValidationCheck(validationGL:UILabel,validationBottomLine:UIView,currentNickName:String?, callingView: Any) -> Bool {
        var result = false
        
        let text = self.text!
         
        if text.count > 0 {
            if text.count > 8 {
                validationGL.nickNameValidationGLSetting(view: validationBottomLine, validationFlag: 3, callingView: callingView)
            }else {
                let textCheck:Bool = self.nickNameCheck() //특수문자, 이모티콘 등 체크
                if textCheck { //순수 영문, 숫자, 한글만 기입
                    if !(currentNickName == text) { //기존 사용자 이름과 textField의 내용이 같으면 API호출 안함
                        result = true
                    }else {
                        //기본으로 세팅
                        validationGL.nickNameValidationGLSetting(view: validationBottomLine, validationFlag: 4, callingView: callingView)
                    }
                }else { //특수문자, 이모지 등 기입
                    validationGL.nickNameValidationGLSetting(view: validationBottomLine, validationFlag: 2, callingView: callingView)
                }
            }
        }
            
        return result
    }
}
