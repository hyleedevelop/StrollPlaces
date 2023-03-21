//
//  MapViewController+Annotation.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/18.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import NSObject_Rx
import CoreLocation
import MapKit
import Cluster

//MARK: - Extension for CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    // 1. 사용자 위치 관련 설정
    func setupUserLocation() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.getLocationUsagePermission()
    }
    
    // 2. 위치 추적 권한 요청 실행
    private func getLocationUsagePermission() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    // 3. 위치 추적 권한 요청 결과에 따른 처리
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("위치 추적 권한 허용됨")
            self.locationManager.startUpdatingLocation()
            self.locationManager.startUpdatingHeading()
        case .restricted, .notDetermined:
            print("위치 추적 권한 미설정")
        case .denied:
            print("위치 추적 권한 거부됨")
        default:
            break
        }
    }
    
}

//MARK: - Extension for ClusterManagerDelegate

extension MapViewController: ClusterManagerDelegate {
    
    func cellSize(for zoomLevel: Double) -> Double? {
        return nil // default
    }
    
    func shouldClusterAnnotation(_ annotation: MKAnnotation) -> Bool {
        return !(annotation is MeAnnotation)
    }
    
}

//MARK: - extension for MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ClusterAnnotation {
            let index = 0
            let identifier = "Cluster\(index)"
            let selection = Selection(rawValue: 0)!
            //let selection = Selection(rawValue: index)!
            return mapView.annotationView(selection: selection, annotation: annotation, reuseIdentifier: identifier)
            
        } else if annotation is MeAnnotation {
            let identifier = "Me"
            let annotationView = mapView.annotationView(of: MKAnnotationView.self, annotation: annotation, reuseIdentifier: identifier)
            //annotationView.image = .me
            annotationView.image = UIImage()
            return annotationView
            
        } else if annotation is MKUserLocation {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "UserLocationAnnotationView")
            return annotationView
            
        } else {
            let identifier = "Pin"
            let annotationView = mapView.annotationView(of: MKPinAnnotationView.self, annotation: annotation, reuseIdentifier: identifier)
            
            //annotationView.detailCalloutAccessoryView = self.tempView
            //annotationView.detailCalloutAccessoryView = UIButton(type: .detailDisclosure)
            //annotationView.canShowCallout = true
            
            annotationView.pinTintColor = K.Map.themeColor[2]
            return annotationView
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            print(#function, latitude, longitude, separator: ", ")
            
            
            //let deltaLat = self.mapView.region.span.latitudeDelta.km
            //let deltaLon = self.mapView.region.span.longitudeDelta.km
            
            // 사용자의 위치가 업데이트 될 때마다 지도 중심을 사용자의 위치로 변경
            //self.mapView.centerToLocation(
            //    location: CLLocation(latitude: latitude, longitude: longitude),
            //    deltaLat: 750.m,
            //    deltaLon: 750.m
            //)
            
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        clusterManager.reload(mapView: mapView)
    }
    
    // annotation을 클릭했을 때 실행할 내용
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        
        // 클러스터를 클릭했을 때
        if let cluster = annotation as? ClusterAnnotation {
            var zoomRect = MKMapRect.null
            
            for annotation in cluster.annotations {
                let annotationPoint = MKMapPoint(annotation.coordinate)
                let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y,
                                          width: 0, height: 0)
                if zoomRect.isNull {
                    zoomRect = pointRect
                } else {
                    zoomRect = zoomRect.union(pointRect)
                }
            }
            
            mapView.setVisibleMapRect(zoomRect, animated: true)
            
//        } else if view.annotation as! String == "My Location" {
//            print("현재 내 위치")
//
        // 핀을 선택했을 때
        } else if let pin = annotation as? Annotation {
            let latitude = annotation.coordinate.latitude
            let longitude = annotation.coordinate.longitude
            self.mapView.centerToLocation(
                location: CLLocation(latitude: latitude, longitude: longitude),
                deltaLat: 1.0.km,
                deltaLon: 1.0.km
            )
            
            // 데이터 보내기 (1): MapVC -> MapVM
            self.viewModel.pinData = self.dataArray[pin.index]
            let placeInfoViewController = PlaceInfoViewController()
            placeInfoViewController.viewModel = self.viewModel.getPlaceInfoViewModel()
            placeInfoViewController.modalPresentationStyle = .overCurrentContext
            
            placeInfoViewController.placeData = self.dataArray[pin.index]

            // 파란색 점(사용자의 위치) annotation을 클릭한 것이 아니라면 상세정보 창 표출
            if annotation.title != "My Location" {
                self.present(placeInfoViewController, animated: false, completion: nil)
            }
            
            // 선택된 annotation 해제
            mapView.selectedAnnotations = []
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print(#function)
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {

    }
    
}
