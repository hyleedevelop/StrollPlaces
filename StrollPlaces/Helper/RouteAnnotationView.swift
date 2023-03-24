//
//  RouteAnnotationView.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/24.
//

import MapKit

//MARK: - MKAnnotationView

class RouteAnnotationView: MKAnnotationView {

    static let identifier = "RouteAnnotationView"
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        frame = CGRect(x: 0, y: 0, width: 50, height: 20)
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2.0)
        
        backgroundColor = .clear
        
//        guard let attractionAnnotation = self.annotation
//                as? RouteAnnotation else { return }
//
//        image = attractionAnnotation.type.image()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    

}
