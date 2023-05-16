//
//  TrackingViewController+Route.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/30.
//

import UIKit
import CoreLocation
import MapKit
import IVBezierPathRenderer

//MARK: - extension for CLLocationManagerDelegate

extension TrackingViewController: CLLocationManagerDelegate {
    
    // 위치 추적 권한 요청 실행
    internal func getLocationUsagePermission() {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.allowsBackgroundLocationUpdates = true  // 백그라운드에서도 위치 업데이트 필요
    }
    
    // 위치 추적 권한 요청 결과에 따른 처리
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("위치 추적 권한 허용됨")
        case .restricted, .notDetermined:
            print("위치 추적 권한 미설정")
        case .denied:
            print("위치 추적 권한 거부됨")
        default:
            break
        }
    }
    
    // 사용자의 위치가 업데이트 될 때 수행할 내용
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.moveToCurrentLocation()
        
        guard let location = locations.last else { return }
        
        // 위치 추적이 허용되었을 때만 지도에 경로 나타내기
        if self.isTrackingAllowed {            
            // 현재 사용자의 위치에 해당하는 위도와 경도 가져오기
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            if let previousCoordinate = self.previousCoordinate {
                // 이전 위치
                let previousPoint = CLLocationCoordinate2DMake(previousCoordinate.latitude,
                                                               previousCoordinate.longitude)
                // 현재 위치
                let currentPoint = CLLocationCoordinate2DMake(latitude, longitude)
                
                // 지점의 좌표 정보를 담을 배열 생성 및 위치가 업데이트 될 때마다 위치 추가
                var points = [CLLocationCoordinate2D]()
                [previousPoint, currentPoint].forEach { points.append($0) }
                
                // 각 지점들을 기록하고 그 지점들 사이를 선으로 연결
                let routeLine = MKPolyline(coordinates: points, count: points.count)
                
                // 지도에 선 나타내기(addOverlay 시 아래의 rendererFor 함수가 호출됨)
                self.mapView.addOverlay(routeLine)
            }
            
            self.previousCoordinate = location.coordinate
            
            // 새로운 사용자의 위치를 track point에 추가
            self.viewModel.appendTrackPoint(currentLatitude: latitude,
                                            currentLongitude: longitude)
        }
        
    }
    
}

//MARK: - extension for MKMapViewDelegate

extension TrackingViewController: MKMapViewDelegate {
    
    // 경로를 표시하기 위한 polyline의 렌더링 설정
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let routeLine = overlay as? MKPolyline else { return MKOverlayRenderer() }
        let renderer = MKPolylineRenderer(polyline: routeLine)
//        let renderer = IVBezierPathRenderer(overlay: routeLine)
        
        renderer.strokeColor = K.Map.routeLineColor
        renderer.lineWidth = K.Map.routeLineWidth
        renderer.alpha = K.Map.routeLineAlpha
        
        return renderer
    }
    
}
