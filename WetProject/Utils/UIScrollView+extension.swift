//
//  UIScrollView+extension.swift
//  WetProject
//
//  Created by 남오승 on 2020/11/26.
//

import UIKit

//Scroll 탑 바로가기, 바텀 바로가기 등 기능 확장파일
extension UIScrollView {
    
    // Scroll to a specific view so that it's top is at the top our scrollview
    
    func scrollToView(view:UIView) {
        
        if let origin = view.superview {
            
            // Get the Y position of your child view
            
            let childStartPoint = origin.convert(view.frame.origin, to: self)
            
            
            
            let bottomOffset = scrollBottomOffset()
            
            if (childStartPoint.y > bottomOffset.y) {
                
                setContentOffset(bottomOffset, animated: true)
                
            } else {
                
                setContentOffset(CGPoint(x: 0, y: childStartPoint.y), animated: true)
                
            }
            
        }
        
    }
    
    
    
    // Bonus: Scroll to top
    
    func scrollToTop() {
        
        let topOffset = CGPoint(x: 0, y: -contentInset.top)
        
        setContentOffset(topOffset, animated: true)
        
    }
    
    
    // Bonus: Scroll to bottom
    
    func scrollToBottom() {
        
        let bottomOffset = scrollBottomOffset()
        
        if(bottomOffset.y > 0) {
            
            setContentOffset(bottomOffset, animated: true)
            
        }
        
    }
    
    private func scrollBottomOffset() -> CGPoint {
        
        return CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        
    }
    
    //스크롤 페이징 처리 전용 메소드
    func scrollTo(horizontalPage: Int? = 0, verticalPage: Int? = 0, animated: Bool? = true) {
        var frame: CGRect = self.frame
        frame.origin.x = frame.size.width * CGFloat(horizontalPage ?? 0)
        frame.origin.y = frame.size.width * CGFloat(verticalPage ?? 0)
        self.scrollRectToVisible(frame, animated: animated ?? true)
    }
}

