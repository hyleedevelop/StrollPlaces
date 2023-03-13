//
//  MKMapView.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import Foundation
import CoreLocation
import MapKit

extension MKMapView {
    
    // 파라미터로 전달받은 위경도를 중심으로 일정 반경(m)만큼의 지도 범위 설정
    func centerToLocation(location: CLLocation, regionRadius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )
        
        setRegion(coordinateRegion, animated: true)
    }
    
}
