//
//  String + extension.swift
//  WetProject
//
//  Created by 남오승 on 2020/12/09.
//

import Foundation
import UIKit

//문자열 줄수 체크, 높이체크, 숫자여부체크 등 기능을 위한 확장파일
extension String {
    //문자열 줄 수 체크
    func lineOfString(width: CGFloat, font:UIFont, lineSpacing: CGFloat) -> CGFloat{
        let contentsLine = (round(self.boundingRect(
                                    with: CGSize(width:width, height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                    attributes: [.font: font ],
            context: nil).size.height / font.lineHeight * 1000) / 1000)
        
        return contentsLine
    }
    
    //문자열 높이 체크
    func heightOfString(width: CGFloat, font:UIFont, lineSpacing: CGFloat) -> CGFloat{
        let contentsLine = (round(self.boundingRect(
                                    with: CGSize(width:width, height: CGFloat.infinity),
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                    attributes: [.font: font ],
            context: nil).size.height / font.lineHeight * 1000) / 1000)
        let spacing = (round((contentsLine * lineSpacing) * 1000) / 1000)
        let textViewHeight = (contentsLine * font.lineHeight) + spacing
        
        return textViewHeight
    }
    
    //문자열이 숫자인지 확인
    func isNumeric() -> Bool{
        var numberFlag:Bool = false
        let digitSet = CharacterSet.decimalDigits
        for (_, ch) in self.unicodeScalars.enumerated() {
            
            if ch == "." || digitSet.contains(ch){
                numberFlag = true
            }else {
                numberFlag = false
                break
            }
        }

        return numberFlag
    }
    
    func getPlistInfo() -> String{
        var returnValue:String = ""
        if let config = getPlist(withName: self) {
            // 키 값을 dictionary 조회하듯이 조회합니다.
            // 마찬가지로 optional 이기 때문에 if 로 검사해줍니다.
            if let DEV_FLAG = config["DEV_FLAG"] as? Bool {
                print("개발여부:\(DEV_FLAG)")
                
                if DEV_FLAG {
                    if let DEV_SERVER_ADDR = config["DEV_SERVER_ADDR"] as? String {
                        print("개발서버 url:\(DEV_SERVER_ADDR)")
                        returnValue = DEV_SERVER_ADDR
                    }
                }else {
                    if let OPS_SERVER_ADDR = config["OPS_SERVER_ADDR"] as? String {
                        print("운영서버 url:\(OPS_SERVER_ADDR)")
                        returnValue = OPS_SERVER_ADDR
                    }
                }
            }
        }
        return returnValue
    }
    
    func getPlist(withName name: String) -> [String: Any]?
    {
        if  let path = Bundle.main.path(forResource: self , ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path)
        {
            return (try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil)) as? [String: Any]
        }
        return nil
    }
}
