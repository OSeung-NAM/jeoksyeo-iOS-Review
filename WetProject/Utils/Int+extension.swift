//
//  Int+extension.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/23.
//

import Foundation

//timestamp-> 날짜로 변환시켜주는 Int 확장 파일
extension Int {
    //timeStamp -> 날짜로 변환
    func timeStampToDate() -> String {

        let timeInterval = TimeInterval(self)
        let writeDate = NSDate(timeIntervalSince1970: timeInterval)

        let calendar = Calendar.current
        
        let writeYear = calendar.component(.year, from: writeDate as Date)
        let writeMonth = calendar.component(.month, from: writeDate as Date)
        let writeDay = calendar.component(.day, from: writeDate as Date)
     
        return String(writeYear) + "." + String(writeMonth) + "." + String(writeDay)
    }
}
