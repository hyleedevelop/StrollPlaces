//
//  UIView.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/18.
//

import UIKit

//MARK: - extension for UIView

extension UIView {
    
    //MARK: - slide view 관련
    
    // add drop shadow effect
    func addDropShadow(scale: Bool = true, cornerRadius: CGFloat ) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowRadius = 1.5
        
        //layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // 아래에서 위로 끌어올리면서 화면을 펼치기
    func slideUpShow(_ duration: CGFloat){
        self.alpha = 1
        UIView.animate(withDuration: TimeInterval(duration), delay: 0, options: [.curveEaseOut],
                       animations: {
                        self.center.y -= self.bounds.height
                        self.layoutIfNeeded()
        }, completion: nil)
    }
    
    // 위에서 아래로 끌어내리면서 화면을 접기
    func slideDownHide(_ duration: CGFloat){
        UIView.animate(withDuration: TimeInterval(duration), delay: 0, options: [.curveEaseOut],
                       animations: {
                        self.center.y += self.bounds.height
                        self.layoutIfNeeded()
                        
        },  completion: {(_ completed: Bool) -> Void in
            self.alpha = 0
        })
    }
    
    // 수평 방향으로 gradient 색상 넣기
    func setHorizontalGradient(color1: UIColor, color2: UIColor) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [color1.cgColor, color2.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = bounds
        self.layer.addSublayer(gradient)
    }
    
    // 수직 방향으로 gradient 색상 넣기
    func setVerticalGradient(color1: UIColor, color2: UIColor) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [color1.cgColor, color2.cgColor]
        gradient.locations = [0.0, 0.7]
        gradient.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = bounds
        self.layer.addSublayer(gradient)
    }
    
    // half-rounded corner를 가진 BackView 설정
    func setHalfRoundedCornerBackView() {
        self.layer.cornerRadius = K.Shape.largeCornerRadius
        self.clipsToBounds = true
        self.layer.masksToBounds = false
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 5
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
}
