//
//  AlcoholDetail+AlcoholInfo.swift
//  WetProject
//
//  Created by 남오승 on 2020/12/10.
//

import UIKit

//주류 상세화면 중간 지표부분 화면 UI를 컨트롤 하기위한 파일
extension AlcoholDetailVC {
    
    //주류 정보세팅
    func alcoholSetting(alcoholDetail:AlcoholDetail?) {
        guard let alcoholDetail = alcoholDetail else {return}
        let alcoholName:String = alcoholDetail.name?.kr ?? ""
        let alcoholBackgroundImageUrl:String = alcoholDetail.backgroundMedia?[0].mediaResource?.large?.src ?? ""
        let alcoholImageUrl:String = alcoholDetail.media?[0].mediaResource?.medium?.src ?? ""
        let alcoholCategory:String = alcoholDetail.classField?.firstClass?.name ?? ""
        let brewery:String = alcoholDetail.brewery?[0].name ?? ""
        let abv:Double = alcoholDetail.abv ?? 0.0
        let likeCnt:Int = alcoholDetail.likeCount ?? 0
        let viewCnt:Int = alcoholDetail.viewCount ?? 0
        let isLiked:Bool = alcoholDetail.isLiked ?? false
        let description:String = alcoholDetail.descriptionField ?? ""
        
        //주류 이름라인 체크
        let alcoholNameLine = alcoholName.lineOfString(width: view.frame.width - 124.0, font: UIFont(name: "AppleSDGothicNeo-Bold", size: 23.0) ?? UIFont.boldSystemFont(ofSize: 23.0), lineSpacing: 4.0)
        //주류 설명 라인 체크
        let alcoholDescriptionLine = description.lineOfString(width: view.frame.width - 26.0, font: UIFont(name: "AppleSDGothicNeo-SemiBold", size: 15.0) ?? UIFont.boldSystemFont(ofSize: 15.0), lineSpacing: 4.0)
        
        if alcoholNameLine > 1.0 {
            alcoholNameGL?.textAlignment = .left
        }else {
            alcoholNameGL?.textAlignment = .center
        }
        
        if likeCnt > 9999 {
            likeCntGL.text = "9999+"
        }else {
            likeCntGL.text = String(likeCnt)
        }
        
        if viewCnt > 999 {
            viewCntGL.text = "9999+"
        }else {
            viewCntGL.text = String(viewCnt)
        }
        
        alcoholImageSetting(urlString: alcoholImageUrl)
        backgroundImageSetting(urlString: alcoholBackgroundImageUrl)
        alcoholNameGL?.text = alcoholName
        breweryGL?.text = brewery
        thermometerGL?.text = String(abv) + "%"
        alcoholCategoryGL?.text = alcoholCategory
        alcoholDescriptionGL?.text = description
        alcoholLikeFlag = isLiked
        alcoholLikeCnt = likeCnt
        
        if isLiked {
            likeImage?.image = UIImage(named: "heartOn")
        }else {
            likeImage?.image = UIImage(named: "heartOff")
        }
        
        if alcoholDescriptionLine > 3.0 {
            moreExpandWrap.isHidden = false
        }else {
            moreExpandWrap.isHidden = true
        }
    }
    
    
    //주류 정보 컴포넌트 세팅
    func alcoholInfoSetting(alcoholDetail:AlcoholDetail?) {
        guard let alcoholDetail = alcoholDetail else {return}
        guard let alcoholInfoWrap = alcoholInfoWrap else {return}
        
        alcoholNameGL?.text = alcoholDetail.name?.kr ?? ""
        
        //초기화
        for view in alcoholInfoWrap.subviews {
            if let _ = view as? AlcoholInfoComponent {
                view.removeFromSuperview()
            }
        }
        
        var cellArr:Array<String> = []
        let category = alcoholDetail.classField?.firstClass?.code ?? ""
        let ibu = alcoholDetail.more?.ibu ?? 0
        let srm = alcoholDetail.more?.srm?.srm ?? 0.0
        let srmRgbHex = alcoholDetail.more?.srm?.rgbHex ?? ""
        let hop = alcoholDetail.more?.hop ?? []
        let temperature = alcoholDetail.more?.temperature ?? []
        let filtered = alcoholDetail.more?.filtered ?? false
        let malt = alcoholDetail.more?.malt ?? []
        let adjunct = alcoholDetail.adjunct ?? []
        let barrelAged = alcoholDetail.barrelAged ?? false
        let expandedFlag:Bool = alcoholDetail.expanded
        let color = alcoholDetail.more?.color?.name ?? ""
        let colorRgbHex = alcoholDetail.more?.color?.rbgHex ?? ""
        let body = alcoholDetail.more?.body ?? ""
        let grape = alcoholDetail.more?.grape ?? []
        let sweet = alcoholDetail.more?.sweet ?? ""
        let acidic = alcoholDetail.more?.acidity ?? ""
        let tannin = alcoholDetail.more?.tannin ?? ""
        let caskType = alcoholDetail.more?.caskType ?? ""
        let agedYear = alcoholDetail.more?.agedYear ?? 0.0
        let sakeType = alcoholDetail.more?.type ?? ""
        let smv = alcoholDetail.more?.smv ?? 0.0
        let rpr = alcoholDetail.more?.rpr ?? 0.0
        
        if category == "TR" { //전통주
            if adjunct.count > 0 {
                cellArr.append("adjunct")
            }
            
            if color.count > 0 {
                cellArr.append("color")
            }
            
            if temperature.count > 0 {
                cellArr.append("temperature")
            }
            
            if body.count > 0 {
                cellArr.append("body")
            }
            
            cellArr.append("filtered")
            cellArr.append("barrel")
            
        }else if category == "BE" { //맥주
            if ibu > 0 {
                cellArr.append("ibu")
            }
            
            if srm > 0.0 {
                cellArr.append("srm")
            }
            
            if hop.count > 0 {
                cellArr.append("hop")
            }
            
            if temperature.count > 0 {
                cellArr.append("temperature")
            }
            
            if malt.count > 0 {
                cellArr.append("malt")
            }
            
            if adjunct.count > 0 {
                cellArr.append("adjunct")
            }
            
            cellArr.append("filtered")
            cellArr.append("barrel")
        }else if category == "WI" { //와인
            if grape.count > 0 {
                cellArr.append("grape")
            }
            
            if color.count > 0 {
                cellArr.append("color")
            }
            
            if sweet.count > 0 {
                cellArr.append("sweet")
            }
            
            if acidic.count > 0 {
                cellArr.append("acidic")
            }
            
            if tannin.count > 0 {
                cellArr.append("tannin")
            }
            
            if body.count > 0 {
                cellArr.append("body")
            }
            
            if temperature.count > 0 {
                cellArr.append("temperature")
            }
            
            if adjunct.count > 0 {
                cellArr.append("adjunct")
            }
            
            cellArr.append("barrel")

        }else if category == "FO" { //양주
            if malt.count > 0 {
                cellArr.append("malt")
            }
            
            if color.count > 0 {
                cellArr.append("color")
            }
            
            if adjunct.count > 0 {
                cellArr.append("adjunct")
            }
            
            if temperature.count > 0 {
                cellArr.append("temperature")
            }
            
            cellArr.append("barrel")
            
            if agedYear > 0.0 {
                cellArr.append("agedYear")
            }
            
            if caskType.count > 0 {
                cellArr.append("caskType")
            }
        }else { //사케
            if sakeType.count > 0 {
                cellArr.append("sakeType")
            }
            if color.count > 0 {
                cellArr.append("color")
            }
            if smv > 0.0 {
                cellArr.append("smv")
            }
            if acidic.count > 0 {
                cellArr.append("acidic")
            }
            if rpr > 0.0 {
                cellArr.append("rpr")
            }
            if adjunct.count > 0 {
                cellArr.append("adjunct")
            }
            if temperature.count > 0 {
                cellArr.append("temperature")
            }
            cellArr.append("filtered")
            cellArr.append("barrel")
            
        }
        
      
        let ratioHeight = 375.0 / 141.0 //주류정보 기본 셀 높이 비율
        let ratioWidth = 375.0 / 162.0 //주류정보 기본 셀 너비 비율
        let cellInterval = (view.frame.width - (34.0 + (view.frame.width / CGFloat(ratioWidth)) * 2)) //셀 사이 간격
        var index:Int = 0
        var cellX:CGFloat = 17.0
        var cellY:CGFloat = 81.0
        
        for cell in cellArr {
            if index%2 == 0 {
                cellX = 17.0
                if index > 1 {
                    cellY += (view.frame.width / CGFloat(ratioHeight)) + 10.0
                }
            }else {
                cellX = (view.frame.width / CGFloat(ratioWidth)) + 17.0 + cellInterval
            }
            
            
            let alcoholInfo = AlcoholInfoComponent(frame: CGRect(x: cellX, y: cellY, width: view.frame.width / CGFloat(ratioWidth), height: view.frame.width / CGFloat(ratioHeight)))
            
            if cell == "ibu" {
                alcoholInfo.contentsGL.text = String(ibu)
            }else if cell == "srm" {
                alcoholInfo.contentsGL.text = String(srm)
                alcoholInfo.alcoholInfoWrap?.shadow(opacity: 0.16, radius: 1, offset: CGSize(width: 1, height: 1),color: UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1).cgColor)

                alcoholInfo.alcoholInfoWrap?.backgroundColor = UIColor(hexString: srmRgbHex)
            }else if cell == "hop" {
                var hopFinal:String = ""
                var index:Int = 0
                for ho in hop {
                    if index > 0 {
                        hopFinal += ("\n" + ho)
                    }else {
                        hopFinal += (ho)
                    }
                    index += 1
                }
                alcoholInfo.contentsGL.numberOfLines = hop.count
                alcoholInfo.contentsGL.text = hopFinal
            }else if cell == "temperature" {
                var temperatureFinal:String = ""
                var index:Int = 0
                for t in temperature {
                    if index > 0 {
                        temperatureFinal += ("\n" + t)
                    }else {
                        temperatureFinal += t
                    }
                    index += 1
                }
                alcoholInfo.contentsGL.numberOfLines = temperature.count
                alcoholInfo.contentsGL.text = temperatureFinal
            }else if cell == "filtered" {
                if filtered {
                    alcoholInfo.contentsGL.text = "YES"
                }else {
                    alcoholInfo.contentsGL.text = "NO"
                }
            }else if cell == "malt" {
                var maltFinal:String = ""
                var index:Int = 0
                for ma in malt {
                    if index > 0 {
                        maltFinal += ("\n" + ma)
                    }else {
                        maltFinal += (ma)
                    }
                    index += 1
                }
                alcoholInfo.contentsGL.numberOfLines = malt.count
                alcoholInfo.contentsGL.text = maltFinal
            }else if cell == "adjunct" {
                var adjunctFinal:String = ""
                var index:Int = 0
                for ad in adjunct {
                    if index > 0 {
                        adjunctFinal += ("\n" + ad)
                    }else {
                        adjunctFinal += (ad)
                    }
                    index += 1
                }
                alcoholInfo.contentsGL.numberOfLines = adjunct.count
                alcoholInfo.contentsGL.text = adjunctFinal
            }else if cell == "barrel" {    
                if barrelAged {
                    alcoholInfo.contentsGL.text = "YES"
                }else {
                    alcoholInfo.contentsGL.text = "NO"
                }
            }else if cell == "color" {
                alcoholInfo.contentsGL.text = color
                if colorRgbHex == "#FFFFFF" {
                    alcoholInfo.titleGL.textColor = UIColor(red: 255/255, green: 146/255, blue: 0/255, alpha: 1)
                    alcoholInfo.subTitleGL.textColor = UIColor(red: 103/255, green: 103/255, blue: 103/255, alpha: 1)
                    alcoholInfo.titleUnderLine.backgroundColor = UIColor(red: 255/255, green: 190/255, blue: 103/255, alpha: 1)
                    alcoholInfo.contentsGL.textColor = .black
                }else {
                    alcoholInfo.titleGL.textColor = .white
                    alcoholInfo.subTitleGL.textColor = .white
                    alcoholInfo.titleUnderLine.backgroundColor = .white
                    alcoholInfo.contentsGL.textColor = .white
                }
                alcoholInfo.alcoholInfoWrap?.backgroundColor = UIColor(hexString: colorRgbHex)
            }else if cell == "body" {
                alcoholInfo.contentsGL.text = body
            }else if cell == "acidic" {
                if acidic.isNumeric() {
                    alcoholInfo.contentsGL.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 20.0)
                }else {
                    alcoholInfo.contentsGL.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16.0)
                }
                alcoholInfo.contentsGL.text = acidic
            }else if cell == "tannin" {
                alcoholInfo.contentsGL.text = tannin
            }else if cell == "sweet" {
                alcoholInfo.contentsGL.text = sweet
            }else if cell == "smv" {
                alcoholInfo.contentsGL.text = String(smv)
            }else if cell == "rpr" {
                alcoholInfo.contentsGL.text = String(rpr)
            }else if cell == "caskType" {
                alcoholInfo.contentsGL.text = caskType
            }else if cell == "sakeType" {
                alcoholInfo.contentsGL.text = sakeType
            }else if cell == "grape" {
                var grapeFinal:String = ""
                var index:Int = 0
                for gr in grape {
                    if index > 0 {
                        grapeFinal += ("\n" + gr)
                    }else {
                        grapeFinal += (gr)
                    }
                    index += 1
                }
                alcoholInfo.contentsGL.numberOfLines = grape.count
                alcoholInfo.contentsGL.text = grapeFinal
            }else if cell == "agedYear" {
                alcoholInfo.contentsGL.text = String(agedYear)
            }
            
            alcoholInfo.cellSetting(cell: cell)
            alcoholInfoWrap.addSubview(alcoholInfo)
            
            
            if !expandedFlag {
                if index > 2 {
                    break
                }
            }
            
            index += 1
        }
        
        cellY += CGFloat(46.0) + (view.frame.width / CGFloat(ratioHeight)) + 10.0
        
        if expandedFlag {
            alcoholInfoMoreImage?.image = UIImage(named: "expandUpOrange")
            alcoholInfoMoreGL?.text = "주류정보 접기"
        }else {
            alcoholInfoMoreImage?.image = UIImage(named: "expandDownOrange")
            alcoholInfoMoreGL?.text = "주류정보 더보기"
        }
        
        if cellArr.count > 4 {
            alcoholInfoMoreWrap?.isHidden = false
            alcoholInfoWrap.constraints.forEach { (constraint) in // ---- 3
                if constraint.firstAttribute == .height {
                    constraint.constant = cellY
                }
            }
        }else {
            alcoholInfoMoreWrap?.isHidden = true
            alcoholInfoWrap.constraints.forEach { (constraint) in // ---- 3
                if constraint.firstAttribute == .height {
                    constraint.constant = cellY - 35.0
                }
            }
        }
    }
}
