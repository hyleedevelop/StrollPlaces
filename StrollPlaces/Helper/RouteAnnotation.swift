//
//  RouteAnnotation.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/24.
//

import UIKit
import CoreLocation
import MapKit

//MARK: - enum

enum RouteAnnotationType: Int {
    case startOfRoute
    case endOfRoute
    
    func image() -> UIImage {
        switch self {
        case .startOfRoute:
            return UIImage(systemName: "star.fill") ?? UIImage()
        case .endOfRoute:
            return UIImage(systemName: "moon.fill") ?? UIImage()
        }
    }
}

//MARK: - MKAnnotation

class RouteAnnotation: NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let type: RouteAnnotationType
    
    init(
        coordinate: CLLocationCoordinate2D,
        title: String,
        type: RouteAnnotationType
    ) {
        self.coordinate = coordinate
        self.title = title
        self.type = type
    }
    
}
