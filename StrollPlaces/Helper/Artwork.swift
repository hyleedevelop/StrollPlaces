//
//  Artwork.swift
//  StrollPlaces
//
//  Created by Eric on 2023/04/28.
//

import Foundation
import CoreLocation
import MapKit

class Artwork: NSObject, MKAnnotation {
    
    let title: String?
    let coordinate: CLLocationCoordinate2D
    
    init(
        title: String?,
        coordinate: CLLocationCoordinate2D
    ) {
        self.title = title
        self.coordinate = coordinate
        
        super.init()
    }
    
}
