//
//  UILabel+extension.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/20.
//

import UIKit

//닉네임 체크 색 변경, Label 라인 체크, Label 줄간격 세팅 등 기능 담겨있는 UILabel 확장파일
extension UILabel {
    
    //닉네임 관련
    func nickNameValidationGLSetting(view:UIView, validationFlag:Int, callingView:Any) {
        let nickNameRedColor  = UIColor(red: 252/255, green: 102/255, blue: 67/255, alpha: 1)
        let nickNameGreenColor = UIColor(red: 78/255, green: 201/255, blue: 148/255, alpha: 1)
        var defaultColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        
        
        if let _ = callingView as? UserInfoUpdateVC {
            defaultColor = UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 1)
        }else if let _ = callingView as? SignUpNameCell {
            defaultColor = UIColor(red: 253/255, green: 177/255, blue: 75/255, alpha: 1)
        }
        
        switch validationFlag {
        case 0 : //사용가능 닉네임
            self.isHidden = false
            self.text = "사용 가능한 닉네임입니다."
            self.textColor = nickNameGreenColor
            view.backgroundColor = nickNameGreenColor
            break
        case 1 : //사용 불가능 닉네임
            self.isHidden = false
            self.text = "이미 적시고있는 회원입니다."
            self.textColor = nickNameRedColor
            view.backgroundColor = nickNameRedColor
            break
        case 2 : //특수문자 닉네임
            self.isHidden = false
            self.text = "한글, 영문, 숫자로 입력해주세요."
            self.textColor = nickNameRedColor
            view.backgroundColor = nickNameRedColor
            break
        case 3 : //닉네임 자릿수 초과
            self.isHidden = false
            self.text = "8글자 이하로 입력해주세요."
            self.textColor = nickNameRedColor
            view.backgroundColor = nickNameRedColor
            break
        case 4 :
            self.isHidden = true
            view.backgroundColor = defaultColor
            break
        default:
            break
        }
    }
    
    //Label 줄 수 구하는 공통 메소드
    func lineOfLabel(width:CGFloat, font:UIFont) -> CGFloat {
        
        let sizeOfString = self.text!.boundingRect(
            with: CGSize(width: width, height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: [.font: font ],
            context: nil).size.height / font.lineHeight
        
        return round(sizeOfString * 1000) / 1000 //소수점 셋째 자리에서 반올림
    }
    
    //Label 줄 간격 세팅
    func setLinespace(spacing: CGFloat) {
        if let text = text {
            let attributeString = NSMutableAttributedString(string: text)
            let style = NSMutableParagraphStyle()
            style.lineSpacing = spacing
            attributeString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSMakeRange(0, attributeString.length))
            attributedText = attributeString
        }
    }
    
    //컬러 간편 세팅
    func colorSetting(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat) {
        textColor = UIColor(red: r/255, green: g/255, blue: b/255, alpha: alpha)
    }
}
