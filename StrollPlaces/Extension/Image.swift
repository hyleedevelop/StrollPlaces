//
//  UIImage.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/15.
//

import UIKit

extension UIImage {
    
    static let pin = UIImage(named: "pin")?.filled(with: UIColor.green)
    static let pin2 = UIImage(named: "pin2")?.filled(with: UIColor.green)
    static let me = UIImage(named: "me")?.filled(with: UIColor.blue)
    
    func filled(with color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        color.setFill()
        
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0);
        context.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        guard let mask = self.cgImage else { return self }
        context.clip(to: rect, mask: mask)
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}
