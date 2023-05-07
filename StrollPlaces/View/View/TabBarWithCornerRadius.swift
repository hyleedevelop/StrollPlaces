//
//  TabBarWithCornerRadius.swift
//  StrollPlaces
//
//  Created by Eric on 2023/05/07.
//

import UIKit

@IBDesignable class TabBarWithCornerRadius: UITabBar {
    
    @IBInspectable var color: UIColor?
    @IBInspectable var radii: CGFloat = 20
    
    private var shapeLayer: CALayer?
    
    override func draw(_ rect: CGRect) {
        addShape()
    }
    
    private func addShape() {
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.path = createPath()
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.fillColor = color?.cgColor ?? UIColor.white.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.shadowColor = UIColor.lightGray.cgColor
        shapeLayer.shadowOffset = CGSize(width: 0, height: -3);
        shapeLayer.shadowOpacity = 0.5
        shapeLayer.shadowRadius = 3
        shapeLayer.shadowPath =  UIBezierPath(roundedRect: bounds, cornerRadius: radii).cgPath
        
        if let oldShapeLayer = self.shapeLayer {
            layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            layer.insertSublayer(shapeLayer, at: 0)
        }
        
        self.shapeLayer = shapeLayer
    }
    
    private func createPath() -> CGPath {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: radii, height: 0.0))
        
        return path.cgPath
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let window = UIApplication.shared.windows[0]
        let safeFrame = window.safeAreaLayoutGuide.layoutFrame
        let bottomSafeAreaHeight = window.frame.maxY - safeFrame.maxY
        
        var tabFrame = self.frame
        tabFrame.size.height = radii*2 + bottomSafeAreaHeight
        tabFrame.origin.y = self.frame.origin.y + self.frame.height - radii*2 - bottomSafeAreaHeight
        
        self.isTranslucent = true
        self.layer.cornerRadius = radii
        self.frame = tabFrame
        self.items?.forEach({ $0.titlePositionAdjustment = UIOffset(horizontal: 0.0, vertical: -10.0) })
    }
    
}
