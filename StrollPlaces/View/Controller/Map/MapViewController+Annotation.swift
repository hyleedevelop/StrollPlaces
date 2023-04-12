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
import SPIndicator

//MARK: - Extension for CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    // 위치 추적 권한 요청 실행
    internal func getLocationUsagePermission() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    // 위치 추적 권한 요청 결과에 따른 처리
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("위치 추적 권한 허용됨")
            self.locationManager.startUpdatingLocation()
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
            //return nil
            
//        } else if annotation is RouteAnnotation {
//            let annotationView = mapView.dequeueReusableAnnotationView(
//                withIdentifier: RouteAnnotationView.identifier)
//            mapView.register(RouteAnnotationView.self,
//                             forAnnotationViewWithReuseIdentifier: RouteAnnotationView.identifier)
//            annotationView?.canShowCallout = true
//
//            let customImage: UIImage!
//            let size = CGSize(width: 15, height: 25)
//            UIGraphicsBeginImageContext(size)
//
//            customImage = UIImage(named: "pin")
//            customImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
//            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
//            annotationView?.image = resizedImage
//
//            return annotationView
            
        } else {
            let identifier = "Pin"
            let annotationView = mapView.annotationView(of: MKPinAnnotationView.self, annotation: annotation, reuseIdentifier: identifier)
            
            annotationView.canShowCallout = true
            annotationView.detailCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView.pinTintColor = K.Color.themeYellow
            return annotationView
            
        }
    }
    
    // 사용자의 위치가 업데이트 될 때 수행할 내용
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            print(#function, latitude, longitude, separator: ", ")
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
                deltaLat: 0.5.km,
                deltaLon: 0.5.km
            )
            
            // 데이터 보내기 (1): MapVC -> MapVM
            self.viewModel.pinData = self.dataArray[pin.index]
            let placeInfoViewController = PlaceInfoViewController()
            placeInfoViewController.viewModel = self.viewModel.sendPinData()
            
            // 현재 사용자의 위치와 핀의 위치 가져오기
            let startLocation = CLLocationCoordinate2D(
                latitude: self.currentLocation.coordinate.latitude,
                longitude: self.currentLocation.coordinate.longitude
            )
            let endLocation = CLLocationCoordinate2D(
                latitude: latitude,
                longitude: longitude
            )
            
            // 경로 계산하여 예상 거리 및 소요시간 데이터 넘겨주기
            self.fetchRoute(method: AppSettingValues.shared.navigationMode,
                            pickupCoordinate: startLocation,
                            destinationCoordinate: endLocation,
                            draw: false) { distance, time in
                placeInfoViewController.viewModel.distance = distance
                placeInfoViewController.viewModel.time = time
            }
            
            // 파란색 점(사용자의 위치) annotation을 클릭한 것이 아니라면 상세정보 창 표출
            if annotation.title != "My Location" {
                placeInfoViewController.modalPresentationStyle = .overCurrentContext
                self.present(placeInfoViewController, animated: false, completion: nil)  // ⭐️
            }
            
            // 기존에 경로를 표시하고 있었다면 제거
            if !self.mapView.overlays.isEmpty {
                self.mapView.removeOverlays(self.mapView.overlays)
            }
            
            // 경로안내 버튼을 누르면 경로 표시
            placeInfoViewController.navigateButton.rx.controlEvent(.touchUpInside).asObservable()
                .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
                .subscribe(
                    onNext: {[weak self] in
                        guard let self = self else { return }
                        self.fetchRoute(method: AppSettingValues.shared.navigationMode,
                                        pickupCoordinate: startLocation,
                                        destinationCoordinate: endLocation,
                                        draw: true) { _, _ in }
                        placeInfoViewController.animateDismissView()
                        let indicatorView = SPIndicatorView(title: "경로 탐색 완료", preset: .done)
                        indicatorView.present(duration: 2.0, haptic: .success)
                    }, onError: { _ in
                        let indicatorView = SPIndicatorView(title: "경로 탐색 실패", preset: .error)
                        indicatorView.present(duration: 2.0, haptic: .error)
                    }
                )
                .disposed(by: rx.disposeBag)
            
            // 선택된 annotation 해제
            mapView.selectedAnnotations = []
        }
    }
    
    // 경로 안내를 위한 polyline 렌더링 설정
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = K.Color.themeYellow
        renderer.lineWidth = 4.0
        renderer.alpha = 1.0
        
        return renderer
    }
     
}
