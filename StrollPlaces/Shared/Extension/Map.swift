//
//  MKMapView.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import Foundation
import CoreLocation
import MapKit

//MARK: - extension for MKMapView

extension MKMapView {
    
    // 줌인, 줌아웃을 위한 줌레벨
    var zoomLevel: Int {
        get {
            return Int(log2(360 * (Double(self.frame.size.width/256) / self.region.span.longitudeDelta)) + 1)
        }
        set (newZoomLevel) {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut) {
                    self.setCenterCoordinate(coordinate: self.centerCoordinate, zoomLevel: newZoomLevel)
                }
            }
        }
    }

    // MapView 기본 설정
    func applyDefaultSettings(viewController: UIViewController, trackingMode: MKUserTrackingMode, showsUserLocation: Bool) {
        self.delegate = (viewController as! any MKMapViewDelegate)
        self.isZoomEnabled = true
        self.isRotateEnabled = true
        self.isScrollEnabled = true
        self.isPitchEnabled = false
        self.isUserInteractionEnabled = true
        self.showsCompass = false
        self.showsUserLocation = showsUserLocation
        self.setUserTrackingMode(trackingMode, animated: true)
    }
    
    // 사용자를 중심으로 하는 지도 영역 설정
    private func setCenterCoordinate(coordinate: CLLocationCoordinate2D, zoomLevel: Int) {
        let span = MKCoordinateSpan(
            latitudeDelta: 0,
            longitudeDelta: 360 / pow(2, Double(zoomLevel)) * Double(self.frame.size.width) / 256
        )
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        self.setRegion(region, animated: true)
    }
    
    // 파라미터로 전달받은 위경도를 중심으로 일정 반경(m)만큼의 지도 범위 설정
    func centerToLocation(location: CLLocation, deltaLat: CLLocationDistance, deltaLon: CLLocationDistance) {
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: deltaLat,
            longitudinalMeters: deltaLon
        )
        self.setRegion(region, animated: true)
    }
    
    // 현재 표시되어 있는 모든 annotation 삭제
    func removeAllAnnotation() {
        self.removeAnnotations(self.annotations)
    }
    
    // Cluster 라이브러리 관련 (1)
    func annotationView<T: MKAnnotationView>(of type: T.Type, annotation: MKAnnotation?, reuseIdentifier: String) -> T {
        guard let annotationView = dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? T else {
            return type.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        }
        annotationView.annotation = annotation
        return annotationView
    }
    
    // Cluster 라이브러리 관련 (2)
    func annotationView(selection: Selection, annotation: MKAnnotation?, reuseIdentifier: String) -> MKAnnotationView {
        switch selection {
        case .count:
            let annotationView = self.annotationView(of: CountClusterAnnotationView.self, annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView.countLabel.backgroundColor = K.Map.placeColor
            return annotationView
        case .imageCount:
            let annotationView = self.annotationView(of: ImageCountClusterAnnotationView.self, annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView.countLabel.textColor = K.Map.placeColor
            annotationView.image = .pin2
            return annotationView
        case .image:
            let annotationView = self.annotationView(of: MKAnnotationView.self, annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView.image = .pin2
            return annotationView
        }
    }
    
}

//MARK: - extension for CLPlacemark

extension CLPlacemark {

    // 사용자의 현재 위치 주소
    var compactAddress: String {
        var result = ""
        
        if let area = self.administrativeArea {
            result += " \(area)"
        }
        
        if let city = self.locality {
            result += " \(city)"
        }
        
        if let name = self.name {
            result += " \(name)"
        }
        
        return result
    }

}
