//
//  TokenExistCheck.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/03.
//

import JWTDecode
import RxSwift

//토큰 만료 체크를 위한 파일
class TokenValidationCheck {
    
    static let shared = TokenValidationCheck()
    
    //토큰 유효성 검사로직 
    func tokenValidationCheck() -> Int{
        
        var returnValue:Int = 0
        let tokenIsEmpty:Bool = tokenIsEmptyCheck()
        let refreshTokenCheck:Bool = getRefreshTokenCheck(refreshTokenExpireTime: getRefreshTokenExpireTime())
        let accessTokenCheck:Bool = getAccessTokenCheck(accessTokenExpireTime: getAccessTokenExpireTime())
        
        if tokenIsEmpty {
            if refreshTokenCheck {
                if accessTokenCheck {
                    returnValue = 2
                }else {
                    returnValue = 1
                }
            }
        }
        return returnValue
    }
    
    //토큰 내장 DB존재여부 체크
    func tokenIsEmptyCheck() -> Bool{
        var tokenExistFlag:Bool = false
        if let _ = UserDefaults.standard.string(forKey: "refreshToken") {
            if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
                tokenExistFlag = true
                log.info("accessToken:\(accessToken)")
            }
        }
        
        return tokenExistFlag
    }
    
    //리프레시 토큰 시간 가져오기 메서드
    func getRefreshTokenExpireTime() -> Int {
        var returnRefreshExpireTime:Int = 0
        if let refreshToken = UserDefaults.standard.string(forKey: "refreshToken") {
            let refreshJWT = try? decode(jwt: refreshToken)
            
            if let refreshExpireTime:Int = refreshJWT?.body["exp"] as? Int {
                returnRefreshExpireTime = refreshExpireTime
            }
        }
        return returnRefreshExpireTime
    }
    
    //리프레시 토큰 만료시간 체크 메서드
    func getRefreshTokenCheck(refreshTokenExpireTime:Int) -> Bool {
        var expireFlag:Bool = false
        let dateGap:DateComponents = tokenDateSetting(tokenExpireTime: refreshTokenExpireTime)
        
        if case let (year?, month?, date?, hour?, minute?, second?) = (dateGap.year, dateGap.month, dateGap.day, dateGap.hour, dateGap.minute, dateGap.second)
        {
            
            log.info("RefreshTokenExpireTime : \(year)년 \(month)개월 \(date)일 \(hour)시간 \(minute)분 \(second)초 전")
            //리프레시 토큰은 모두 0과 같거나 작으면 만료로 풀게이지 처리
            //result - true : 토큰 유효, false : 토큰 만료
            if year <= 0 && month <= 0 && date <= 0 && hour <= 0 && minute <= 0 && second <= 0{
                expireFlag = false
            }else {
                expireFlag = true
            }
        }
        return expireFlag
    }
    
    //액세스 토큰 시간 가져오기 메서드
    func getAccessTokenExpireTime() -> Int {
        var returnAccessExpireTime:Int = 0
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
            let accessJWT = try? decode(jwt: accessToken)
            
            if let accessExpireTime:Int = accessJWT?.body["exp"] as? Int {
                returnAccessExpireTime = accessExpireTime
            }
        }
        return returnAccessExpireTime
    }
    
    //액세스 토큰 만료시간 체크 메서드
    func getAccessTokenCheck(accessTokenExpireTime:Int) -> Bool {
        var expireFlag:Bool = false
        let dateGap:DateComponents = tokenDateSetting(tokenExpireTime: accessTokenExpireTime)
        if case let (year?, month?, date?, hour?, minute?, second?) = (dateGap.year, dateGap.month, dateGap.day, dateGap.hour, dateGap.minute, dateGap.second)
        {
            log.info("AccessTokenExpireTime : \(year)년 \(month)개월 \(date)일 \(hour)시간 \(minute)분 \(second)초 전")
            //액세스 토큰은 1시간 전부터 자동으로 갱신해주기 위해 체크함.
            //result - true : 토큰 유효, false : 토큰 만료
            if year <= 0 && month <= 0 && date <= 0 && hour <= 0 && minute <= 59 && second <= 59{
                expireFlag = false
            }else {
                expireFlag = true
            }
        }
        return expireFlag
    }
    
    //토큰 만료시간 체크 직전 비교 할 시간 체킹만 해주는 메서드 (리프레시 , 액세스 토큰 공통)
    func tokenDateSetting(tokenExpireTime:Int) -> DateComponents{
        let nowDate = Date()
        let timeInterval = TimeInterval(tokenExpireTime)
        let writeDate = NSDate(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let expireTime = dateFormatter.date(from: dateFormatter.string(from: writeDate as Date))
        let currentTime = dateFormatter.date(from: dateFormatter.string(from: nowDate))
        let calendar = Calendar.current
        let dateGap:DateComponents = calendar.dateComponents([.year,.month,.day,.hour,.minute,.second], from: currentTime!, to: expireTime!)
        
        return dateGap
    }
}
