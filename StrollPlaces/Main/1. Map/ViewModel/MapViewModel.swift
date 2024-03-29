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

final class MapViewModel: CommonViewModel {
    
    //MARK: - 생성자 관련
    
    private let themeCell = [
        ThemeCellData(icon: UIImage(named: "icons8-park-96")!, title: "공원"),
        ThemeCellData(icon: UIImage(named: "icons8-forest-path-64")!, title: "산책로"),
        ThemeCellData(icon: UIImage(named: "icons8-log-cabin-80")!, title: "자연휴양림"),
        ThemeCellData(icon: UIImage(named: "icons8-star-96")!, title: "즐겨찾기"),
    ]
    let themeCellViewModel: [ThemeCellViewModel]
    private var publicDataArray = [PublicData]()
    var pinData: PublicData!
    
    override init() {
        self.themeCellViewModel = themeCell.compactMap(ThemeCellViewModel.init)
        
        super.init()
        
        self.loadParkData()
        self.loadStrollWayData()
        self.loadRecreationForestData()
    }
    
    //MARK: - Realm DB 관련
    
    var myPlaceData = RealmService.shared.myPlaceObject
    
    //MARK: - 지도에 표출할 데이터 처리 관련
    
    // PublicData 형식을 가진 데이터 추가
    var publicData: [PublicData] {
        return self.publicDataArray
    }

    // 공원 데이터 로드
    private func loadParkData() {
        guard let dataArray = openDataFile(file: K.CSV.parkData) else { return }
        
        // 공공 데이터에 추가
        for index in 1..<dataArray.count-1 {  // index = 0은 제목에 해당하므로 제외
            guard let latitude = Double(dataArray[index][5]),
                  let longitude = Double(dataArray[index][6]) else { continue }  // 반복문이 계속되어야 하므로 continue 사용
            
            // 이름
            let name = dataArray[index][1].isEmpty ? K.Map.noDataMessage : dataArray[index][1]
            
            // 카테고리
            let category = dataArray[index][2].isEmpty ? K.Map.noDataMessage : dataArray[index][2]
            
            // 주소(도로명주소 우선, 없을 시 지번주소, 둘다 없을 시 정보 없음)
            let address = dataArray[index][3].isEmpty
            ? (dataArray[index][4].isEmpty ? K.Map.noDataMessage : dataArray[index][4])
            : dataArray[index][3]
            
            // 주변시설
            var infra = ""
            [8, 9, 10, 11, 12].forEach {
                if !dataArray[index][$0].isEmpty {
                    infra += dataArray[index][$0] + " "
                }
            }
            if infra.isEmpty {
                infra = K.Map.noDataMessage
            }
            
            // 관리기관
            let organization = dataArray[index][14].isEmpty ? K.Map.noDataMessage : dataArray[index][14]
            
            // 관리기관 전화번호
            let telephoneNumber = dataArray[index][15].isEmpty ? K.Map.noDataMessage : dataArray[index][15]
            
            // 경로, 참고사항, 홈페이지, 입장료 - 항상 정보없음으로 처리
            let route = K.Map.noDataMessage
            let feature = K.Map.noDataMessage
            let homepage = K.Map.noDataMessage
            let fee = K.Map.noDataMessage
            
            // 구조체 인스턴스를 배열에 추가
            let dataToAppend = PublicData(
                infoType: .park,
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
                fee: fee
            )
            self.publicDataArray.append(dataToAppend)
        }
    }
    
    // 산책로 데이터 로드
    private func loadStrollWayData() {
        guard let dataArray = openDataFile(file: K.CSV.strollWayData) else { return }

        // 공공 데이터에 추가
        for index in 1..<dataArray.count-1 {  // index = 0은 제목에 해당하므로 제외
            guard let latitude = Double(dataArray[index][14]),
                  let longitude = Double(dataArray[index][15]) else { continue }  // 반복문이 계속되어야 하므로 continue 사용
            
            // 이름
            let name = dataArray[index][1].isEmpty ? K.Map.noDataMessage : dataArray[index][1]
            
            // 카테고리
            let category = dataArray[index][2].isEmpty ? K.Map.noDataMessage : dataArray[index][2]
            
            // 경로
            let route = dataArray[index][3].isEmpty ? K.Map.noDataMessage : dataArray[index][3]
            
            // 설명
            let feature = dataArray[index][8].isEmpty ? K.Map.noDataMessage : dataArray[index][8]
            
            // 주변시설
            var infra = K.Map.noDataMessage
            if !dataArray[index][10].isEmpty {
                infra = "화장실: \(dataArray[index][10])"
            } else if !dataArray[index][11].isEmpty {
                infra = "편의시설: \(dataArray[index][11])"
            } else if !dataArray[index][10].isEmpty && !dataArray[index][11].isEmpty {
                infra = "화장실: \(dataArray[index][10])\n편의시설: \(dataArray[index][11])"
            }
            
            // 주소(도로명주소 우선, 없을 시 지번주소, 둘다 없을 시 정보 없음)
            let address = dataArray[index][13].isEmpty ? K.Map.noDataMessage : dataArray[index][13]
            
            // 관리기관, 관리기관 전화번호, 홈페이지 주소, 입장료 - 항상 정보없음으로 처리
            let organization = K.Map.noDataMessage
            let telephoneNumber = K.Map.noDataMessage
            let homepage = K.Map.noDataMessage
            let fee = K.Map.noDataMessage
            
            // 구조체 인스턴스를 배열에 추가
            let dataToAppend = PublicData(
                infoType: .strollWay,
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
                fee: fee
            )
            self.publicDataArray.append(dataToAppend)
        }
    }

    // 자연휴양림 데이터 로드
    private func loadRecreationForestData() {
        guard let dataArray = openDataFile(file: K.CSV.recreationForestData) else { return }

        // 공공 데이터에 추가
        for index in 1..<dataArray.count-1 {  // index = 0은 제목에 해당하므로 제외
            guard let latitude = Double(dataArray[index][12]),
                  let longitude = Double(dataArray[index][13]) else { continue }  // 반복문이 계속되어야 하므로 continue 사용
            // 이름
            let name = dataArray[index][0].isEmpty ? K.Map.noDataMessage: dataArray[index][0]
            
            // 카테고리
            let category = dataArray[index][2].isEmpty ? K.Map.noDataMessage: dataArray[index][2]
            
            // 입장료
            let fee = dataArray[index][5].isEmpty ? K.Map.noDataMessage : dataArray[index][5]
            
            // 주변시설
            let infra = dataArray[index][7].isEmpty ? K.Map.noDataMessage : dataArray[index][7]
            
            // 주소
            let address = dataArray[index][8].isEmpty ? K.Map.noDataMessage : dataArray[index][8]
            
            // 관리기관
            let organization = dataArray[index][9].isEmpty ? K.Map.noDataMessage : dataArray[index][9]
            
            // 관리기관 전화번호
            let telephoneNumber = dataArray[index][10].isEmpty ? K.Map.noDataMessage : dataArray[index][10]
            
            // 홈페이지 주소
            let homepage = (dataArray[index][11].isEmpty) ? K.Map.noDataMessage : dataArray[index][11]
            
            // 경로, 참고사항 - 항상 정보없음으로 처리
            let route = K.Map.noDataMessage
            let feature = K.Map.noDataMessage
            
            // 구조체 인스턴스를 배열에 추가
            let dataToAppend = PublicData(
                infoType: .recreationForest,
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
                fee: fee
            )
            self.publicDataArray.append(dataToAppend)
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
        return PlaceInfoViewModel(self.publicData[pinNumber], pinNumber: pinNumber)
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

