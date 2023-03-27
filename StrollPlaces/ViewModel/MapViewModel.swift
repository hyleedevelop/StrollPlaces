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
        loadParkData()
        loadStrollWayData()
        loadRecreationForestData()
        loadTourSpotData()
        return publicData
    }
    
    // 공원 데이터 로드
    private func loadParkData() {
        guard let dataArray = openDataFile(file: K.CSV.parkData) else { return }
        
        // 데이터를 Park 구조체에 넣기
        for index in 1..<dataArray.count-1 {  // index = 0은 제목에 해당하므로 제외
            if let latitude = Double(dataArray[index][5]),
               let longitude = Double(dataArray[index][6]) {
                
                // 이름
                let name: String = dataArray[index][1].count != 0 ? dataArray[index][1] : K.Map.noDataMessage
                // 카테고리
                let category: String = dataArray[index][2].count != 0 ? dataArray[index][2] : K.Map.noDataMessage
                // 주소(도로명주소 우선, 없을 시 지번주소, 둘다 없을 시 정보 없음)
                var address: String {
                    if (dataArray[index][3].count + dataArray[index][4].count) == 0 {
                        return K.Map.noDataMessage
                    } else {
                        return dataArray[index][3].count != 0 ? dataArray[index][3] : dataArray[index][4]
                    }
                }
                // 주변시설
                var infra: String {
                    #warning("코드 구현 필요")
                    //let mergedString = dataArray[index][8]
                    return K.Map.noDataMessage
                }
                // 관리기관
                let organization: String = dataArray[index][14].count != 0 ? dataArray[index][14] : K.Map.noDataMessage
                // 관리기관 전화번호
                let telephoneNumber: String = dataArray[index][15].count != 0 ? dataArray[index][15] : K.Map.noDataMessage
                
                publicData.append(
                    PublicData(infoType: .park,
                               name: name,
                               category: category,
                               address: address,
                               lat: latitude,
                               lon: longitude,
                               infra: infra,
                               organization: organization,
                               telephoneNumber: telephoneNumber)
                )
            }
        }
        
    }
    
    // 산책로 데이터 로드
    private func loadStrollWayData() {
        guard let dataArray = openDataFile(file: K.CSV.strollWayData) else { return }

        // 데이터를 Park 구조체에 넣기
        for index in 1..<dataArray.count-1 {  // index = 0은 제목에 해당하므로 제외
            if let latitude = Double(dataArray[index][14]),
               let longitude = Double(dataArray[index][15]) {

                // 이름
                var name: String {
                    if dataArray[index][1] == dataArray[index][2] {
                        return dataArray[index][1]
                    } else if (dataArray[index][1].count + dataArray[index][2].count) == 0 {
                        return K.Map.noDataMessage
                    } else {
                        return "\(dataArray[index][1])(\(dataArray[index][2]))"
                    }
                }
                #warning("여기까지 작업 완료")
                // 카테고리
                let category: String = dataArray[index][2].count != 0 ? dataArray[index][2] : K.Map.noDataMessage
                // 주소(도로명주소 우선, 없을 시 지번주소, 둘다 없을 시 정보 없음)
                var address: String {
                    if (dataArray[index][3].count + dataArray[index][4].count) == 0 {
                        return K.Map.noDataMessage
                    } else {
                        return dataArray[index][3].count != 0 ? dataArray[index][3] : dataArray[index][4]
                    }
                }
                // 주변시설
                var infra: String {
                    //let mergedString = dataArray[index][8]
                    return K.Map.noDataMessage
                }
                // 관리기관
                let organization: String = dataArray[index][10].count != 0 ? dataArray[index][10] : K.Map.noDataMessage
                // 관리기관 전화번호
                let telephoneNumber: String = dataArray[index][11].count != 0 ? dataArray[index][11] : K.Map.noDataMessage

                publicData.append(
                    PublicData(infoType: .strollWay,
                               name: name,
                               category: category,
                               address: address,
                               lat: latitude,
                               lon: longitude,
                               infra: infra,
                               organization: organization,
                               telephoneNumber: telephoneNumber)
                )
            }
        }
    }

    // 자연휴양림 데이터 로드
    private func loadRecreationForestData() {
        guard let dataArray = openDataFile(file: K.CSV.recreationForestData) else { return }

        // 데이터 추가
        for index in 1..<dataArray.count-1 {  // index = 0은 제목에 해당하므로 제외
            if let latitude = Double(dataArray[index][12]),
               let longitude = Double(dataArray[index][13]) {
                // 이름
                let name: String = dataArray[index][0].count != 0 ? dataArray[index][0] : K.Map.noDataMessage
                // 카테고리
                let category: String = dataArray[index][2].count != 0 ? dataArray[index][2] : K.Map.noDataMessage
                // 주소
                var address: String = dataArray[index][8].count != 0 ? dataArray[index][8] : K.Map.noDataMessage
                // 주변시설
                var infra: String = dataArray[index][7].count != 0 ? dataArray[index][7] : K.Map.noDataMessage
                // 관리기관
                let organization: String = dataArray[index][9].count != 0 ? dataArray[index][9] : K.Map.noDataMessage
                // 관리기관 전화번호
                let telephoneNumber: String = dataArray[index][10].count != 0 ? dataArray[index][10] : K.Map.noDataMessage

                publicData.append(
                    PublicData(infoType: .recreationForest,
                               name: name,
                               category: category,
                               address: address,
                               lat: latitude,
                               lon: longitude,
                               infra: infra,
                               organization: organization,
                               telephoneNumber: telephoneNumber)
                )
            }
        }
    }
    
    // 지역명소 데이터 로드
    private func loadTourSpotData() {
        guard let dataArray = openDataFile(file: K.CSV.tourSpotData) else { return }

        // 데이터를 Park 구조체에 넣기
        for index in 1..<dataArray.count-1 {  // index = 0은 제목에 해당하므로 제외
            if let latitude = Double(dataArray[index][4]),
               let longitude = Double(dataArray[index][5]) {
                // 이름
                let name: String = dataArray[index][0].count != 0 ? dataArray[index][0] : K.Map.noDataMessage
                #warning("여기까지 작업 완료")
                // 카테고리
                let category: String = dataArray[index][2].count != 0 ? dataArray[index][2] : K.Map.noDataMessage
                // 주소(도로명주소 우선, 없을 시 지번주소, 둘다 없을 시 정보 없음)
                var address: String {
                    if (dataArray[index][3].count + dataArray[index][4].count) == 0 {
                        return K.Map.noDataMessage
                    } else {
                        return dataArray[index][3].count != 0 ? dataArray[index][3] : dataArray[index][4]
                    }
                }
                // 주변시설
                var infra: String {
                    //let mergedString = dataArray[index][8]
                    return K.Map.noDataMessage
                }
                // 관리기관
                let organization: String = dataArray[index][10].count != 0 ? dataArray[index][10] : K.Map.noDataMessage
                // 관리기관 전화번호
                let telephoneNumber: String = dataArray[index][11].count != 0 ? dataArray[index][11] : K.Map.noDataMessage

                publicData.append(
                    PublicData(infoType: .tourSpot,
                               name: name,
                               category: category,
                               address: address,
                               lat: latitude,
                               lon: longitude,
                               infra: infra,
                               organization: organization,
                               telephoneNumber: telephoneNumber)
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
            ThemeCellData(icon: UIImage(systemName: "star.fill")!, title: "즐겨찾기"),
            ThemeCellData(icon: UIImage(systemName: "tree.fill")!, title: "공원"),
            ThemeCellData(icon: UIImage(systemName: "road.lanes")!, title: "산책로"),
            ThemeCellData(icon: UIImage(systemName: "mountain.2.fill")!, title: "자연휴양림"),
            ThemeCellData(icon: UIImage(systemName: "hand.thumbsup.fill")!, title: "지역명소")
        ]
        self.themeCellViewModel = themeCell.compactMap(ThemeCellViewModel.init)
    }
    
    func themeCellData(at index: Int) -> ThemeCellViewModel {
        return self.themeCellViewModel[index]
    }
    
}

