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
        
        // 별점, 메인 이미지, 제목, 소요시간, 거리, 등록 날짜 바인딩
        cell.starRating.rating = self.viewModel.rating(index: indexPath.row)
        cell.mainImage.image = self.viewModel.mainImage(index: indexPath.row)
        cell.nameLabel.text = self.viewModel.name(index: indexPath.row)
        cell.timeLabel.text = self.viewModel.time(index: indexPath.row)
        cell.distanceLabel.text = self.viewModel.distance(index: indexPath.row)
        cell.dateLabel.text = self.viewModel.date(index: indexPath.row)
        
        // context menu
        cell.moreButton.showsMenuAsPrimaryAction = true
        cell.moreButton.menu = self.getMoreContextMenu(index: indexPath.row,
                                                       sender: cell.moreButton)
        
        // Hero 애니메이션 id 설정
        let sortedDataID = self.viewModel.sortedID(index: indexPath.row)
        if let indexOfRealm = self.viewModel.indexOfRealm(id: sortedDataID) {
            cell.nameLabel.hero.id = "nameLabel\(indexOfRealm)"
            cell.timeLabel.hero.id = "timeLabel\(indexOfRealm)"
            cell.distanceLabel.hero.id = "distanceLabel\(indexOfRealm)"
        }
        
        return cell
    }
    
    // 셀이 선택되었을 때 실행할 내용
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailInfoViewController") as? DetailInfoViewController else { return }
        
        let sortedDataID = self.viewModel.sortedID(index: indexPath.row)
        if let indexOfRealm = self.viewModel.indexOfRealm(id: sortedDataID) {
            nextVC.cellIndex = indexOfRealm
            nextVC.modalPresentationStyle = .overFullScreen
            nextVC.hero.isEnabled = true
            nextVC.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut)
            self.present(nextVC, animated: true, completion: nil)
        }
    }
    
    //MARK: - indirectly called method
    
    private func getMoreContextMenu(index: Int, sender: UIButton) -> UIMenu {
        let actions = [
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
            let sortedDataID = self.viewModel.sortedID(index: index)
            if let indexOfRealm = self.viewModel.indexOfRealm(id: sortedDataID) {
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
