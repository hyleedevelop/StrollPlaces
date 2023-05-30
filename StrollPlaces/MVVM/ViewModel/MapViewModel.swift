//
//  MapViewModel.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation
import MapKit
import RealmSwift

final class MapViewModel {
    
    //MARK: - 생성자 관련
    
    let themeCellViewModel: [ThemeCellViewModel]
    private var publicData = [PublicData]()
    var pinData: PublicData!
    
    init() {
        let themeCell = [
            ThemeCellData(icon: UIImage(named: "icons8-park-96")!, title: "공원"),
            ThemeCellData(icon: UIImage(named: "icons8-forest-path-64")!, title: "산책로"),
            ThemeCellData(icon: UIImage(named: "icons8-log-cabin-80")!, title: "자연휴양림"),
            ThemeCellData(icon: UIImage(named: "icons8-star-96")!, title: "즐겨찾기"),
        ]
        self.themeCellViewModel = themeCell.compactMap(ThemeCellViewModel.init)
    }
    
    //MARK: - Realm DB 관련
    
    var myPlaceData = RealmService.shared.realm.objects(MyPlace.self)
    
    //MARK: - 지도에 표출할 데이터 처리 관련
    
    // PublicData 형식을 가진 데이터를 append
    func getPublicData() -> [PublicData] {
        self.loadParkData()
        self.loadStrollWayData()
        self.loadRecreationForestData()
        return publicData
    }
    
    // 공원 데이터 로드
    private func loadParkData() {
        guard let dataArray = openDataFile(file: K.CSV.parkData) else { return }
        
        // 공공 데이터에 추가
        for index in 1..<dataArray.count-1 {  // index = 0은 제목에 해당하므로 제외
            if let latitude = Double(dataArray[index][5]),
               let longitude = Double(dataArray[index][6]) {
                
                // 이름
                let name: String = !dataArray[index][1].isEmpty ? dataArray[index][1] : K.Map.noDataMessage
                
                // 카테고리
                let category: String = !dataArray[index][2].isEmpty ? dataArray[index][2] : K.Map.noDataMessage
                
                // 경로
                let route: String = K.Map.noDataMessage
                
                // 주소(도로명주소 우선, 없을 시 지번주소, 둘다 없을 시 정보 없음)
                var address: String {
                    if dataArray[index][3].isEmpty && dataArray[index][4].isEmpty {
                        return K.Map.noDataMessage
                    } else {
                        return !dataArray[index][3].isEmpty ? dataArray[index][3] : dataArray[index][4]
                    }
                }
                
                // 참고사항
                let feature: String = K.Map.noDataMessage
                
                // 주변시설
                var infra: String {
                    var fullString = ""
                    [8, 9, 10, 11, 12].forEach {
                        if !dataArray[index][$0].isEmpty {
                            fullString = fullString + dataArray[index][$0] + " "
                        }
                    }
                    return !fullString.isEmpty ? fullString : K.Map.noDataMessage
                }
                
                // 관리기관
                let organization: String = !dataArray[index][14].isEmpty ? dataArray[index][14] : K.Map.noDataMessage
                
                // 관리기관 전화번호
                let telephoneNumber: String = !dataArray[index][15].isEmpty ? dataArray[index][15] : K.Map.noDataMessage
                
                // 홈페이지 주소
                let homepage: String = K.Map.noDataMessage
                
                // 입장료
                let fee: String = K.Map.noDataMessage
                
                publicData.append(
                    PublicData(infoType: .park,
                               name: name,
                               category: category,
                               route: route,
                               address: address,
                               lat: latitude,
                               lon: longitude,
                               feature: feature,
                               infra: infra,
                               organization: organization,
                               telephoneNumber: telephoneNumber,
                               homepage: homepage,
                               fee: fee)
                )
            }
        }
        
    }
    
    // 산책로 데이터 로드
    private func loadStrollWayData() {
        guard let dataArray = openDataFile(file: K.CSV.strollWayData) else { return }

        // 공공 데이터에 추가
        for index in 1..<dataArray.count-1 {  // index = 0은 제목에 해당하므로 제외
            if let latitude = Double(dataArray[index][14]),
               let longitude = Double(dataArray[index][15]) {

                // 이름
                let name: String = !dataArray[index][1].isEmpty ? dataArray[index][1] : K.Map.noDataMessage
                
                // 카테고리
                let category: String = !dataArray[index][2].isEmpty ? dataArray[index][2] : K.Map.noDataMessage
                
                // 경로
                let route: String = !dataArray[index][3].isEmpty ? dataArray[index][3] : K.Map.noDataMessage
                
                // 주소(도로명주소 우선, 없을 시 지번주소, 둘다 없을 시 정보 없음)
                let address: String = !dataArray[index][13].isEmpty ? dataArray[index][13] : K.Map.noDataMessage

                // 설명
                let feature: String = !dataArray[index][8].isEmpty ? dataArray[index][8] : K.Map.noDataMessage
                
                // 주변시설
                var infra: String {
                    var fullString = ""
                    if !dataArray[index][10].isEmpty {
                        fullString = "화장실: " + dataArray[index][10]
                    } else if !dataArray[index][11].isEmpty {
                        fullString = "편의시설: " + dataArray[index][11]
                    } else if !dataArray[index][10].isEmpty && !dataArray[index][11].isEmpty {
                        fullString = "화장실: " + dataArray[index][10] + "\n" +
                                     "편의시설: " + dataArray[index][11]
                    }
                    return !fullString.isEmpty ? fullString : K.Map.noDataMessage
                }
                
                // 관리기관
                let organization: String = K.Map.noDataMessage
                
                // 관리기관 전화번호
                let telephoneNumber: String = K.Map.noDataMessage

                // 홈페이지 주소
                let homepage: String = K.Map.noDataMessage
                
                // 입장료
                let fee: String = K.Map.noDataMessage
                
                publicData.append(
                    PublicData(infoType: .strollWay,
                               name: name,
                               category: category,
                               route: route,
                               address: address,
                               lat: latitude,
                               lon: longitude,
                               feature: feature,
                               infra: infra,
                               organization: organization,
                               telephoneNumber: telephoneNumber,
                               homepage: homepage,
                               fee: fee)
                )
            }
        }
    }

    // 자연휴양림 데이터 로드
    private func loadRecreationForestData() {
        guard let dataArray = openDataFile(file: K.CSV.recreationForestData) else { return }

        // 공공 데이터에 추가
        for index in 1..<dataArray.count-1 {  // index = 0은 제목에 해당하므로 제외
            if let latitude = Double(dataArray[index][12]),
               let longitude = Double(dataArray[index][13]) {
                // 이름
                let name: String = dataArray[index][0].count != 0 ? dataArray[index][0] : K.Map.noDataMessage
                
                // 카테고리
                let category: String = dataArray[index][2].count != 0 ? dataArray[index][2] : K.Map.noDataMessage
                
                // 경로
                let route: String = K.Map.noDataMessage
                
                // 주소
                let address: String = dataArray[index][8].count != 0 ? dataArray[index][8] : K.Map.noDataMessage
                
                // 참고사항
                let feature: String = K.Map.noDataMessage
                
                // 주변시설
                let infra: String = dataArray[index][7].count != 0 ? dataArray[index][7] : K.Map.noDataMessage
                
                // 관리기관
                let organization: String = dataArray[index][9].count != 0 ? dataArray[index][9] : K.Map.noDataMessage
                
                // 관리기관 전화번호
                let telephoneNumber: String = dataArray[index][10].count != 0 ? dataArray[index][10] : K.Map.noDataMessage

                // 홈페이지 주소
                let homepage: String = !dataArray[index][11].isEmpty ? dataArray[index][11] : K.Map.noDataMessage
                
                // 입장료
                let fee: String = !dataArray[index][5].isEmpty ? dataArray[index][5] : K.Map.noDataMessage
                
                publicData.append(
                    PublicData(infoType: .recreationForest,
                               name: name,
                               category: category,
                               route: route,
                               address: address,
                               lat: latitude,
                               lon: longitude,
                               feature: feature,
                               infra: infra,
                               organization: organization,
                               telephoneNumber: telephoneNumber,
                               homepage: homepage,
                               fee: fee)
                )
            }
        }
    }
    
    // CSV 파일 위치 가져오기 및 데이터 담기
    private func openDataFile(file: String) -> [[String]]? {
        // CSV 파일 위치 가져오기
        guard let path = Bundle.main.path(forResource: file, ofType: "csv") else {
            fatalError("[ERROR] Unable to find the path of csv file")
        }

        // CVS 파일에서 데이터 가져오기
        guard let dataArray = parseCSV(url: URL(fileURLWithPath: path)) else {
            fatalError("[ERROR] Unable to fetch csv file")
        }
        
        return dataArray
    }
    
    // CSV parsing 수행
    private func parseCSV(url: URL) -> [[String]]? {
        do {
            let data = try Data(contentsOf: url)
            let dataEncoded = String(data: data, encoding: .utf8)
            
            if let dataArray = dataEncoded?
                .components(separatedBy: "\n")
                .map({$0.components(separatedBy: ",")}) {
                return dataArray
            } else {
                return nil
            }
        } catch {
            print("[ERROR] Unable to load csv file")
            return nil
        }
    }
    
    //MARK: - 데이터 전달 관련
    
    // 데이터 보내기 (2): MapVM -> PlaceVM (pinData로 초기화)
    func sendPinData(pinNumber: Int) -> PlaceInfoViewModel {
        return PlaceInfoViewModel(self.pinData, pinNumber: pinNumber)
    }
    
    //MARK: - 경로 안내 관련
    
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
    
    //MARK: - UICollectionView 관련
    
    // section의 개수
    let numberOfSections: Int = 1
    
    // section당 item의 개수
    var numberOfItemsInSection: Int {
        return self.themeCellViewModel.count
    }
    
    // header의 크기
    let headerSize: CGSize = CGSize(width: 12, height: K.ThemeCV.cellHeight)
    
    // footer의 크기
    let footerSize: CGSize = CGSize(width: 12, height: K.ThemeCV.cellHeight)
    
    // 셀 데이터
    func themeCellData(at index: Int) -> ThemeCellViewModel {
        return self.themeCellViewModel[index]
    }
    
    // 셀의 선택/해제 여부에 따른 UI 변경
    func changeCellUI(cell: ThemeCollectionViewCell, selected: Bool) {
        DispatchQueue.main.async {
            if selected {
                cell.backView.layer.shadowColor = UIColor.black.cgColor
                cell.backView.layer.borderColor = UIColor.black.cgColor
                cell.backView.layer.borderWidth = 2.0
                cell.themeLabel.textColor = K.Color.themeBlack
                cell.themeIcon.tintColor = K.Color.themeBlack
            } else {
                cell.backView.layer.shadowColor = UIColor.black.cgColor
                cell.backView.layer.borderColor = UIColor.black.cgColor
                cell.backView.layer.borderWidth = 0.0
                cell.themeLabel.textColor = K.Color.themeBlack
                cell.themeIcon.tintColor = K.Color.themeBlack
            }
        }
    }
    
}

