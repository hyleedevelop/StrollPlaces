//
//  MapItem.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/14.
//

import MapKit

final class MapItem: NSObject, MKAnnotation {
    
    let coordinate: CLLocationCoordinate2D
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
}
