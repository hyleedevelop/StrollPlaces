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
    
    //MARK: - 줌인, 줌아웃 관련

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

    private func setCenterCoordinate(coordinate: CLLocationCoordinate2D, zoomLevel: Int) {
        let span = MKCoordinateSpan(
            latitudeDelta: 0,
            longitudeDelta: 360 / pow(2, Double(zoomLevel)) * Double(self.frame.size.width) / 256
        )
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        self.setRegion(region, animated: true)
    }
    
    //MARK: - 파라미터로 전달받은 위경도를 중심으로 일정 반경(m)만큼의 지도 범위 설정

    func centerToLocation(location: CLLocation, deltaLat: CLLocationDistance, deltaLon: CLLocationDistance) {
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: deltaLat,
            longitudinalMeters: deltaLon
        )
        self.setRegion(region, animated: true)
    }
    
    //MARK: - annotation 추가
    
    // 현재 표시되어 있는 모든 annotation 삭제
    func removeAllAnnotation() {
        self.removeAnnotations(self.annotations)
    }
    
    //MARK: - Cluster 라이브러리 관련

    func annotationView<T: MKAnnotationView>(of type: T.Type, annotation: MKAnnotation?, reuseIdentifier: String) -> T {
        guard let annotationView = dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? T else {
            return type.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        }
        annotationView.annotation = annotation
        return annotationView
    }
    
    func annotationView(selection: Selection, annotation: MKAnnotation?, reuseIdentifier: String) -> MKAnnotationView {
        switch selection {
        case .count:
            let annotationView = self.annotationView(of: CountClusterAnnotationView.self, annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView.countLabel.backgroundColor = K.Map.themeColor[2]
            return annotationView
        case .imageCount:
            let annotationView = self.annotationView(of: ImageCountClusterAnnotationView.self, annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView.countLabel.textColor = K.Map.themeColor[2]
            annotationView.image = .pin2
            return annotationView
        case .image:
            let annotationView = self.annotationView(of: MKAnnotationView.self, annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView.image = .pin
            return annotationView
        }
    }
    
}
