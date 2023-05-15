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
//import RealmSwift

final class MapViewModel {
    
    private var publicData = [PublicData]()
    var pinData: PublicData!
    
    //MARK: - 지도의 데이터 표출 관련
    
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
    
    //MARK: - 상세정보를 PlaceInfoViewModel에 전달
    
    // 데이터 보내기 (2): MapVM -> PlaceVM (pinData로 초기화)
    func sendPinData() -> PlaceInfoViewModel {
        return PlaceInfoViewModel(self.pinData)
    }
    
    //MARK: - 경로 안내 관련
    
    
    //MARK: - UICollectionView 관련
    
    let themeCellViewModel: [ThemeCellViewModel]
    
    init() {
        let themeCell = [
            ThemeCellData(icon: UIImage(named: "icons8-park-96")!, title: "공원"),
            ThemeCellData(icon: UIImage(named: "icons8-forest-path-64")!, title: "산책로"),
            ThemeCellData(icon: UIImage(named: "icons8-log-cabin-80")!, title: "자연휴양림"),
            //ThemeCellData(icon: UIImage(systemName: "star.fill")!, title: "즐겨찾기"),
        ]
        self.themeCellViewModel = themeCell.compactMap(ThemeCellViewModel.init)
    }
    
    func themeCellData(at index: Int) -> ThemeCellViewModel {
        return self.themeCellViewModel[index]
    }
    
}

