//
//  MapService.swift
//  StrollPlaces
//
//  Created by Eric on 2023/06/02.
//

import UIKit
import MapKit
import CoreLocation

final class MapService {
    
    static let shared = MapService()
    private init() {}
    
    // MKOverlayRenderer 생성
    func getOverlayRenderer(mapView: MKMapView, overlay: MKOverlay) -> MKOverlayRenderer {
        guard let routeLine = overlay as? MKPolyline else { return MKOverlayRenderer() }
        let renderer = MKPolylineRenderer(polyline: routeLine)
        
        renderer.strokeColor = K.Map.routeLineColor
        renderer.lineWidth = K.Map.routeLineWidth
        renderer.alpha = K.Map.routeLineAlpha
        
        return renderer
    }
    
    // 현재 사용자의 위치로 지도 이동
    func moveToCurrentLocation(manager: CLLocationManager, mapView: MKMapView) {
        let latitude = ((manager.location?.coordinate.latitude)
                        ?? K.Map.defaultLatitude) as Double
        let longitude = ((manager.location?.coordinate.longitude)
                         ?? K.Map.defaultLongitude) as Double
        mapView.centerToLocation(
            location: CLLocation(latitude: latitude, longitude: longitude),
            deltaLat: 0.5.km,
            deltaLon: 0.5.km
        )
    }
    
    // 지도에 경로 표시하기
    func fetchRoute(
        mapView: MKMapView,
        pickupCoordinate: CLLocationCoordinate2D,
        destinationCoordinate: CLLocationCoordinate2D,
        draw: Bool,
        completion: @escaping ((Double, Double) -> Void)
    ) {
        let request = MKDirections.Request()
        request.source = MKMapItem(
            placemark: MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
        )
        request.destination = MKMapItem(
            placemark: MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        )
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let response = response else { return }
            
            // 단일 루트 얻기
            if let route = response.routes.first {
                if draw {  // route를 그려야 하는 경우
                    // 출발지-도착지 경로를 보여줄 지도 영역 설정
                    // (출발지-도착지 간 위경도 차이의 1.5배 크기의 영역을 보여주기)
                    var rect = MKCoordinateRegion(route.polyline.boundingMapRect)
                    rect.span.latitudeDelta = abs(pickupCoordinate.latitude -
                                                  destinationCoordinate.latitude) * 1.5
                    rect.span.longitudeDelta = abs(pickupCoordinate.longitude -
                                                   destinationCoordinate.longitude) * 1.5
                    mapView.setRegion(rect, animated: true)
                    
                    // 경로 그리기
                    mapView.addOverlay(route.polyline)
                }
                
                completion(route.distance, route.expectedTravelTime)
            }
        }
    }
    
    // MKAnnotationView 생성
    func getAnnotationView(mapView: MKMapView, annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Artwork else { return nil }
        
        let identifier = "artwork"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView
            .dequeueReusableAnnotationView(withIdentifier: identifier) as? RouteAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(
                annotation: annotation,
                reuseIdentifier: identifier
            )
            view.markerTintColor = annotation.title == "출발" ? K.Color.themeRed : K.Color.themeGreen
            view.canShowCallout = false
        }
        
        return view
    }
    
}
