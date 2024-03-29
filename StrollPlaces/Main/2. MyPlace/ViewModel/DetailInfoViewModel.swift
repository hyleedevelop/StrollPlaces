//
//  DetailInfoViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/05/02.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import RealmSwift
import CoreLocation
import MapKit

final class DetailInfoViewModel: CommonViewModel {
    
    //MARK: - 속성 선언
    
    private var pointData = RealmService.shared.trackPointObject
    private var points = [CLLocationCoordinate2D]()
    
    let nameRelay = BehaviorRelay<String>(value: "알수없음")
    let dateRelay = BehaviorRelay<String>(value: "알수없음")
    let timeRelay = BehaviorRelay<String>(value: "알수없음")
    let distanceRelay = BehaviorRelay<String>(value: "알수없음")
    let explanationRelay = BehaviorRelay<String>(value: "알수없음")
    let featureRelay = BehaviorRelay<String>(value: "알수없음")
    let ratingRelay = BehaviorRelay<String>(value: "알수없음")
    
    //MARK: - 생성자 관련
    
    var startAnnotation: Artwork!
    var endAnnotation: Artwork!
    var cellIndex: Int
    
    init(cellIndex: Int) {
        self.cellIndex = cellIndex
        
        let points = RealmService.shared.readTrackData(at: cellIndex).points
        self.startAnnotation = Artwork(
            title: "출발",
            coordinate: CLLocationCoordinate2D(
                latitude: points.first?.latitude ?? 0.0,
                longitude: points.first?.longitude ?? 0.0
            )
        )
        self.endAnnotation = Artwork(
            title: "도착",
            coordinate: CLLocationCoordinate2D(
                latitude: points.last?.latitude ?? 0.0,
                longitude: points.last?.longitude ?? 0.0
            )
        )
        
        super.init()
        
        self.getTrackDataFromRealmDB(index: cellIndex)
    }
    
    //MARK: - 바인딩 관련
    
    // Realm DB에 임시저장 해놓은 경로 데이터를 받아 relay에서 요소 방출
    func getTrackDataFromRealmDB(index: Int) {
        let currentTrackData = RealmService.shared.readTrackData(at: index)
        var distance: String {
            return (..<1000) ~= currentTrackData.distance
            ? String(format: "%.1f", currentTrackData.distance) + "m"
            : String(format: "%.2f", currentTrackData.distance/1000.0) + "km"
        }
        var rating: String {
            return "\(RealmService.shared.readTrackData(at: index).rating) / 5"
        }
        
        self.nameRelay.accept(currentTrackData.name)
        self.dateRelay.accept(currentTrackData.date)
        self.timeRelay.accept(currentTrackData.time)
        self.distanceRelay.accept(distance)
        self.explanationRelay.accept(currentTrackData.explanation)
        self.featureRelay.accept(currentTrackData.feature)
        self.ratingRelay.accept(rating)
    }
    
    //MARK: - 지도 관련
    
    // MapView에 이동경로를 표시하기 위해 track point 데이터를 좌표로 변환 후 가져오기
    func getTrackPointsForPolyline(index: Int) -> [CLLocationCoordinate2D] {
        let currentTrackPoints = RealmService.shared.readTrackPoints(at: index)
        
        // List<TrackPoint> (위도+경도) -> CLLocationCoordinate2D (좌표)
        for (_, point) in currentTrackPoints.enumerated() {
            let coordinate = CLLocationCoordinate2DMake(
                point.latitude, point.longitude
            )
            self.points.append(coordinate)
        }
        
        return self.points
    }
    
    // 경로를 보여줄 영역 정보 가져오기
    func getDeltaCoordinate() -> (Double, Double)? {
        var latitudeArray = [Double]()
        var longitudeArray = [Double]()
        
        for index in 0..<self.points.count {
            latitudeArray.append(self.points[index].latitude)
            longitudeArray.append(self.points[index].longitude)
        }
        
        if latitudeArray.max() != nil, latitudeArray.min() != nil,
           longitudeArray.max() != nil, longitudeArray.min() != nil {
            let latitudeDelta = abs(latitudeArray.max()! - latitudeArray.min()!) * 2.0
            let longitudeDelta = abs(longitudeArray.max()! - longitudeArray.min()!) * 2.0
            return (latitudeDelta, longitudeDelta)
        } else {
            return nil
        }
    }
    
    // MKAnnotationView 생성
    func annotationView(mapView: MKMapView, annotation: MKAnnotation) -> MKAnnotationView? {
        return MapService.shared.getAnnotationView(mapView: mapView, annotation: annotation)
    }
    
    // MKOverlayRenderer 생성
    func overlayRenderer(mapView: MKMapView, overlay: MKOverlay) -> MKOverlayRenderer {
        return MapService.shared.getOverlayRenderer(mapView: mapView, overlay: overlay)
    }
    
    //MARK: - Realm DB 관련
    
    // 상세정보 화면에서 편집 버튼을 통해 Realm DB 업데이트 하기
    func updateDB(index: Int, newValue: String, item: EditableItems) {
        RealmService.shared.updateTrackData(at: index, item: item, newValue: newValue)
        
        switch item {
        case .name: self.nameRelay.accept(newValue)
        case .explanation: self.explanationRelay.accept(newValue)
        case .feature: self.featureRelay.accept(newValue)
        }
    }
    
    //MARK: - Action 관련
    
    func editItemWithAlertMessage(cellIndex: Int, item: EditableItems, viewController: UIViewController) {
        var currentText = ""
        var message = ""
        var placeHolder = ""
        var isNameField = false
        
        switch item {
        case .name:
            currentText = RealmService.shared.readTrackData(at: cellIndex).name
            message = "산책길 이름을 다음과 같이 변경합니다."
            placeHolder = "산책길 이름"
            isNameField = true
        case .explanation:
            currentText = RealmService.shared.readTrackData(at: cellIndex).explanation
            message = "간단한 소개를 다음과 같이 변경합니다."
            placeHolder = "간단한 소개"
            isNameField = false
        case .feature:
            currentText = RealmService.shared.readTrackData(at: cellIndex).feature
            message = "특이사항을 다음과 같이 변경합니다."
            placeHolder = "특이사항"
            isNameField = false
        }
        
        // alert message 보여주고 입력값 받기
        let alert = UIAlertController(
            title: "수정", message: message, preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "취소", style: .default)
        let okAction = UIAlertAction(title: "저장", style: .default) { _ in
            // TextField에서 입력받은 값을 전달하여 Realm DB의 업데이트 수행
            guard let text = alert.textFields![0].text else { return }

            let isValidLength = InputValidationService.shared.validateLength(
                text: text, textField: alert.textFields![0], isNameField: isNameField
            )
            let isUniqueName = InputValidationService.shared.validateUniqueName(
                text: text, textField: alert.textFields![0], isNameField: isNameField
            )
            
            // 유효성 검사 결과에 따라 메세지를 다르게 출력
            if isNameField {
                if isUniqueName {
                    if isValidLength {
                        self.updateDB(index: cellIndex, newValue: text, item: item)
                        SPIndicatorService.shared.showSuccessIndicator(title: "변경 완료")
                    } else {
                        SPIndicatorService.shared.showErrorIndicator(title: "변경 실패", message: "2~10글자로 입력")
                    }
                } else {
                    SPIndicatorService.shared.showErrorIndicator(title: "변경 실패", message: "중복되는 이름")
                }
            } else {
                if isValidLength {
                    self.updateDB(index: cellIndex, newValue: text, item: item)
                    SPIndicatorService.shared.showSuccessIndicator(title: "변경 완료")
                } else {
                    SPIndicatorService.shared.showErrorIndicator(title: "변경 실패", message: "2~20글자로 입력")
                }
            }
        }
        
        // TextField와 Action Button 추가
        alert.addTextField { textField in
            textField.text = currentText
            textField.placeholder = placeHolder
            textField.clearButtonMode = .whileEditing
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        // 메세지 보여주기
        viewController.present(alert, animated: true, completion: nil)
    }
    
}
