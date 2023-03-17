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
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut) {
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

    func centerToLocation(location: CLLocation, regionRadius: CLLocationDistance) {
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius
        )
        
        self.setRegion(region, animated: true)
    }
    
    //MARK: - annotation 추가
    
    /*
    // 하나의 annotation 추가 시 (테스트용)
    func markSingleAnnotation(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                              title: String?, subtitle: String?) {
        self.removeAnnotations(self.annotations)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        annotation.title = title
        annotation.subtitle = subtitle
        
        self.addAnnotation(annotation)
    }
    
    // 여러 개의 annotation 추가 시
    func markMultipleAnnotation(annotations: [Annotation]) {
        self.removeAnnotations(self.annotations)
        
        var annotationArray = [MKPointAnnotation]()
        for i in 0..<annotations.count {
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = CLLocationCoordinate2DMake(annotations[i].latitude,
                                                               annotations[i].longitude)
            annotation.title = annotations[i].title
            annotation.subtitle = annotations[i].subtitle
            
            annotationArray.append(annotation)
        }
        
        self.addAnnotations(annotationArray)
    }
     */
    
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
    
}
