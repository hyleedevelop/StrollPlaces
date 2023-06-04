//
//  MyPlaceViewController+CollectionView.swift
//  StrollPlaces
//
//  Created by Eric on 2023/06/02.
//

import UIKit

//MARK: - extension for UICollectionViewDelegate, UICollectionViewDataSource

extension MyPlaceViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK: - directly called method
    
    // section의 개수
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.viewModel.numberOfSections
    }
        
    // section 내 아이템의 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.numberOfItemsInSection
    }
    
    // 각 셀마다 실행할 내용
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: K.MyPlace.cellName, for: indexPath
        ) as? MyPlaceCollectionViewCell else { return UICollectionViewCell() }
        
        let dataSource = self.viewModel.sortedTrackList(index: indexPath.row)
        
        cell.starRating.rating = dataSource.rating
        
        cell.mainImage.image = self.viewModel.loadImageFromDocumentDirectory(
            imageName: dataSource._id.stringValue
        )
        
        cell.nameLabel.text = dataSource.name.count == 0 ? "제목없음" : dataSource.name
        cell.timeLabel.text = "\(dataSource.time)"
        cell.distanceLabel.text = dataSource.distance < 1000.0
        ? String(format: "%.1f", dataSource.distance) + "m"
        : String(format: "%.2f", dataSource.distance/1000.0) + "km"
        cell.dateLabel.text = Date().getTimeIntervalString(
            since: dataSource.date.toDate(mode: .myPlace)!
        )
        
        cell.moreButton.showsMenuAsPrimaryAction = true
        cell.moreButton.menu = self.getMoreContextMenu(index: indexPath.row,
                                                       sender: cell.moreButton)
        
        let sortedDataID = self.viewModel.sortedID(index: indexPath.row)
        let realmDB = self.viewModel.realmDB
        
        if let indexOfRealm = realmDB.firstIndex(where: { $0._id == sortedDataID } ) {
            cell.nameLabel.hero.id = "nameLabel\(indexOfRealm)"
            cell.timeLabel.hero.id = "timeLabel\(indexOfRealm)"
            cell.distanceLabel.hero.id = "distanceLabel\(indexOfRealm)"
        }
        
        return cell
    }
    
    // 셀이 선택되었을 때 실행할 내용
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailInfoViewController") as? DetailInfoViewController else { return }
        let sortedDataID = self.viewModel.itemViewModel.sortedTrackData[indexPath.row]._id
        let realmDB = self.viewModel.itemViewModel.trackData
        
        if let indexOfRealm = realmDB.firstIndex(where: { $0._id == sortedDataID } ) {
            nextVC.cellIndex = indexOfRealm
            nextVC.modalPresentationStyle = .overFullScreen
            nextVC.hero.isEnabled = true
            nextVC.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut)
            //nextVC.viewModel = DetailInfoViewModel(cellIndex: indexOfRealm)
            self.present(nextVC, animated: true, completion: nil)
        }
    }
    
    //MARK: - indirectly called method
    
    private func getMoreContextMenu(index: Int, sender: UIButton) -> UIMenu {
        let actions = [
//            UIAction(title: "수정", image: UIImage(systemName: "pencil"),
//                     attributes: .keepsMenuPresented, handler: { _ in
//
//                     }),
            UIAction(title: "삭제", image: UIImage(systemName: "trash"),
                     attributes: .destructive, handler: { _ in
                         self.removeMyPlace(sender, index: index)
                     }),
        ]
        return UIMenu(title: "", options: [.displayInline], children: actions)
    }
    
    // 나만의 산책길 항목 삭제하기
    private func removeMyPlace(_ sender: UIButton, index: Int) {
        let alert = UIAlertController(
            title: "확인",
            message: "선택한 나만의 산책길을 삭제할까요?\n한번 삭제하면 복구할 수 없습니다.",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "아니요", style: .default)
        let okAction = UIAlertAction(title: "네", style: .destructive) { _ in
            // 정렬된 셀에서 indexPath.row번째 cell에 해당하는 ID
            let sortedDataID = self.viewModel.itemViewModel.sortedTrackData[index]._id
            let realmDB = self.viewModel.itemViewModel.trackData
            
            if let indexOfRealm = realmDB.firstIndex(where: { $0._id == sortedDataID } ) {
                // DB에서 데이터 삭제
                self.viewModel.removeTrackData(at: indexOfRealm)
                
                // CollectionView에서 셀 삭제
                DispatchQueue.main.async {
                    self.myPlaceCollectionView.reloadData()
                }
                
                // 화면 상단에 완료 메세지 보여주기
                SPIndicatorService.shared.showSuccessIndicator(title: "삭제 완료")
            } else {
                // 화면 상단에 에러 메세지 보여주기
                SPIndicatorService.shared.showSuccessIndicator(title: "삭제 실패", type: .error)
            }
        }
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        // 메세지 보여주기
        self.present(alert, animated: true, completion: nil)
    }
    
}
