//
//  CustomAnnotation.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/19.
//

import UIKit
import CoreLocation
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    
    let index: Int
    let title: String?
    let locationName: String?
    let discipline: String?
    let coordinate: CLLocationCoordinate2D
    
    init(
        index: Int,
        title: String?,
        locationName: String?,
        discipline: String?,
        coordinate: CLLocationCoordinate2D
    ) {
        self.index = index
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    
}
