//
//  AddMyPlaceViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/04/02.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import RealmSwift
import CoreLocation
import MapKit
import SkyFloatingLabelTextField

final class AddMyPlaceViewModel: CommonViewModel {
    
   
    
    //MARK: - 생성자 관련
    
    let startAnnotation: Artwork!
    let endAnnotation: Artwork!
    
    override init() {
        self.startAnnotation = Artwork(
            title: "출발",
            coordinate: CLLocationCoordinate2D(
                latitude: self.trackData.last?.points.first?.latitude ?? 0.0,
                longitude: self.trackData.last?.points.first?.longitude ?? 0.0
            )
        )
        
        self.endAnnotation = Artwork(
            title: "도착",
            coordinate: CLLocationCoordinate2D(
                latitude: self.trackData.last?.points.last?.latitude ?? 0.0,
                longitude: self.trackData.last?.points.last?.longitude ?? 0.0
            )
        )
    }
    
    //MARK: - Realm DB 관련
    
    // Rx 관련 속성
    let dateRelay = BehaviorRelay<String>(value: "알수없음")
    let timeRelay = BehaviorRelay<String>(value: "알수없음")
    let distanceRelay = BehaviorRelay<String>(value: "알수없음")
    let isTrackDataUpdated = BehaviorSubject<Bool>(value: false)
    
    // DB 관련 속성
    
    private var trackData = RealmService.shared.realm.objects(TrackData.self)
    private var pointData = RealmService.shared.realm.objects(TrackPoint.self)
    private var primaryKey = RealmService.shared.realm.objects(TrackData.self).last?._id
    private var points = [CLLocationCoordinate2D]()
    
    // Realm DB에 임시저장 해놓은 경로 데이터를 받아 relay에서 요소 방출
    func getTrackDataFromRealmDB() {
        //self.primaryKey = RealmService.shared.realm.objects(TrackData.self).last?._id
        
        var dateString: String {
            //let date = RealmService.shared.realm.objects(TrackData.self).last?.date ?? Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH시 mm분"
            return dateFormatter.string(from: Date())
        }
        self.dateRelay.accept(dateString)
        
        var timeString: String {
            let time = RealmService.shared.realm.objects(TrackData.self).last?.time ?? "알수없음"
            return time
        }
        self.timeRelay.accept(timeString)
        
        var distanceString: String {
            let distance = RealmService.shared.realm.objects(TrackData.self).last?.distance ?? 0.0
            if (..<1000) ~= distance {
                return String(format: "%.1f", distance) + "m"
            } else {
                return String(format: "%.2f", distance/1000.0) + "km"
            }
        }
        self.distanceRelay.accept(distanceString)
    }
    
    // Realm DB에 데이터 추가하기
    func updateTrackData(name: String, explanation: String, feature: String, rating: Double) {
        // TrackData의 id, name, explanation, feature 업데이트
        let realm = try! Realm()
        try! realm.write {
            realm.create(TrackData.self,
                         value: ["_id": self.primaryKey!,
                                 "name": name,
                                 "explanation": explanation,
                                 "feature": feature,
                                 "rating": rating]
                         as [String: Any],
                         update: .modified)
        }
        
        // TrackPoint의 id 업데이트
        let rangeEnd = self.pointData.count
        let rangeStart = rangeEnd - (self.trackData.last?.points.count)!
        for index in rangeStart..<rangeEnd {
            let pointDB = realm.objects(TrackPoint.self)
            try! realm.write {
                pointDB[index].id = self.primaryKey!.stringValue
            }
        }
        
        isTrackDataUpdated.onNext(true)
    }
    
    // 임시로 저장했던 경로 데이터 지우기
    func clearTemporaryTrackData() {
        // 가장 마지막에 저장된 TrackData에 접근
        guard let latestTrackData = self.trackData.last else { return }
        for _ in 0..<latestTrackData.points.count {
            guard let latestPointData = self.pointData.last else { return }
            // TrackPoint에서 points의 갯수 만큼 삭제
            RealmService.shared.delete(latestPointData)
        }
        
        // TrackData 삭제
        RealmService.shared.delete(latestTrackData)
        
        // 지도 이미지 삭제
        let imageName = self.primaryKey?.stringValue ?? "noname"
        self.deleteImageFromDocumentDirectory(imageName: imageName)
    }
    
    
    
    //MARK: - 입력값에 대한 유효성 검사 관련
    
    // TextField에 입력된 문자열에 대한 유효성 검사
    func checkTextFieldIsValid(text: String, textField: SkyFloatingLabelTextField, isNameField: Bool) -> Bool {
        return InputValidationService.shared.validateInputText(text: text, textField: textField, isNameField: isNameField)
    }
    
    // TextField의 글자수 제한을 넘기면 초과되는 부분은 입력되지 않도록 설정
    func limitTextFieldLength(text: String, textField: UITextField, isNameField: Bool) -> String {
        return InputValidationService.shared.limitInputText(text: text, textField: textField, isNameField: isNameField)
    }
    
    // 산책길 난이도 별점에 대한 유효성 검사
    func checkStarRatingIsValid(value: Double) -> Bool {
        return InputValidationService.shared.checkStarRatingIsValid(value: value)
    }
    
    //MARK: - 지도 관련
    
    // MapView에 이동경로를 표시하기 위해 track point 데이터를 좌표로 변환 후 가져오기
    var trackPointForPolyline: [CLLocationCoordinate2D] {
        // Realm DB에서 자료 읽기 및 빈 배열 생성
        let trackPoint = RealmService.shared.realm.objects(TrackData.self).last?.points
        
        // List<TrackPoint> (위도+경도) -> CLLocationCoordinate2D (좌표)
        guard let tp = trackPoint else { fatalError("could not find track points...") }
        for index in 0..<tp.count {
            let coordinate = CLLocationCoordinate2DMake(tp[index].latitude,
                                                        tp[index].longitude)
            self.points.append(coordinate)
        }
        
        return self.points
    }
    
    // 경로를 보여줄 영역 정보 가져오기
    var deltaCoordinate: (Double, Double)? {
        var latitudeArray = [Double]()
        var longitudeArray = [Double]()
        
        for index in 0..<self.points.count {
            latitudeArray.append(self.points[index].latitude)
            longitudeArray.append(self.points[index].longitude)
        }
        
        if latitudeArray.max() != nil, latitudeArray.min() != nil,
           longitudeArray.max() != nil, longitudeArray.min() != nil {
            let latitudeDelta = abs(latitudeArray.max()! - latitudeArray.min()!) * 1.5
            let longitudeDelta = abs(longitudeArray.max()! - longitudeArray.min()!) * 1.5
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
    
    //MARK: - 이미지 파일 관련
    
    // 경로가 표시된 지도 이미지를 Document 폴더에 저장히기(new)
    func saveMapViewAsImage(region: MKCoordinateRegion, size: CGSize) {
        let options = MKMapSnapshotter.Options()
        options.region = region
        options.size = size
        options.mapType = .standard

        MKMapSnapshotter(options: options).start { snapshot, error in
            guard let snapshot = snapshot else { return }
            
            // 아무것도 그려지지 않은 빈 지도 이미지
            let mapImage = snapshot.image
            
            // 빈 지도 위에 이동경로를 그린 후 렌더링하여 최종적으로 얻을 이미지
            let finalImage = UIGraphicsImageRenderer(size: size).image { _ in
                mapImage.draw(at: .zero)
                
                // 좌표가 2개 이상인 경우에만 경로 그리기
                let coordinates = self.trackPointForPolyline
                guard coordinates.count > 1 else { return }
                
                // [CLLocationCoordinate2D] -> [CGPoint]
                // (mapView에서의 좌표 -> 이미지에서의 좌표)
                let points = coordinates.map { coordinate in
                    snapshot.point(for: coordinate)
                }

                // bezier path로 경로 포인트 사이를 잇는 선 그리기
                let path = UIBezierPath()
                path.lineWidth = K.Map.routeLineWidth
                path.lineCapStyle = .round
                path.lineJoinStyle = .round

                path.move(to: points[0])
                let rangeMin = 1  // 첫번째를 제외하고 시작
                let rangeMax = (points.count/2) - 1  // points는 lat/lon 두가지가 들어있으므로 2로 나눠야 함
                for i in rangeMin...rangeMax {
                    path.addLine(to: points[i])
                }

                // stroke 하기
                K.Map.routeLineColor.withAlphaComponent(1.0).setStroke()
                path.stroke()
            }
            
            // 렌더링을 마친 이미지를 폴더에 저장
            self.saveRenderedImageToDocumentDirectory(image: finalImage)
        }
    }
    
    // 경로가 표시된 지도 이미지를 Document 폴더에 저장하기
    func saveRenderedImageToDocumentDirectory(image: UIImage) {
        // 이미지를 저장할 경로를 설정해줘야함 - 도큐먼트 폴더 및 파일은 FileManager가 관리함(싱글톤 패턴)
        guard let documentDirectory = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        // 이미지 파일 이름 & 최종 경로 설정
        let imageURL = documentDirectory
            .appendingPathComponent((self.primaryKey?.stringValue ?? "noname")+".png")
        
        // 이미지 압축(image.pngData())
        // 압축이 필요하다면 pngData 대신 jpegData 사용 (0~1 사이 값)
        guard let data = image.pngData() else { return }
        
        // 이미지 저장: 동일한 경로에 이미지를 저장하게 될 경우, 덮어쓰기하는 경우
        // 이미지 경로 여부 확인
        if FileManager.default.fileExists(atPath: imageURL.path) {
            // 이미지가 존재한다면 기존 경로에 있는 이미지 삭제
            do {
                try FileManager.default.removeItem(at: imageURL)
                print("이미지 삭제 완료")
            } catch {
                print("이미지를 삭제하지 못했습니다.")
            }
        }
        
        // 이미지를 도큐먼트에 저장
        do {
            try data.write(to: imageURL)
            print("이미지 저장완료", imageURL)
        } catch {
            print("이미지를 저장하지 못했습니다.")
        }
    }
    
    // 경로가 표시된 지도 이미지를 Document 폴더에서 삭제하기
    private func deleteImageFromDocumentDirectory(imageName: String) {
        // 폴더 경로 가져오기
        guard let documentDirectory = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        // 이미지 URL 만들기
        let imageURL = documentDirectory.appendingPathComponent(imageName + ".png")
        
        // 파일이 존재하면 삭제하기
        if FileManager.default.fileExists(atPath: imageURL.path) {
            do {
                try FileManager.default.removeItem(at: imageURL)
            } catch {
                print("이미지를 삭제하지 못했습니다.")
            }
        }
    }
    
    //MARK: - Action 관련
    
    // 즐겨찾기 데이터 초기화를 위한 Action 구성
    func actionForMarkRemoval(viewController: UIViewController) {
        // 진짜로 취소할 것인지 alert message 보여주고 확인받기
        let alert = UIAlertController(
            title: "확인",
            message: "지금까지 작성한 내용을\n모두 삭제할까요?",
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(title: "아니요", style: .default)
        )
        alert.addAction(
            UIAlertAction(title: "네", style: .destructive) { _ in
                // Realm DB에 임시로 저장했던 경로 삭제하기
                self.clearTemporaryTrackData()
                // 이전화면(경로만들기)로 돌아가기
                viewController.navigationController?.popToRootViewController(animated: true)
            }
        )
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
