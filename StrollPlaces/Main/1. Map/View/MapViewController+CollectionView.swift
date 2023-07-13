//
//  MapViewController+Extension.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/16.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import NSObject_Rx

//MARK: - extension for UICollectionViewDataSource, UICollectionViewDelegate

extension MapViewController: UICollectionViewDataSource,
                             UICollectionViewDelegate {
    
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.ThemeCV.cellName, for: indexPath)
                as? ThemeCollectionViewCell else { return UICollectionViewCell() }

        // 바인딩 수행
        self.viewModel.themeCellData(at: indexPath.row).icon.asDriver(onErrorJustReturn: UIImage())
            .drive(cell.themeIcon.rx.image)
            .disposed(by: rx.disposeBag)
        
        self.viewModel.themeCellData(at: indexPath.row).title.asDriver(onErrorJustReturn: "")
            .drive(cell.themeLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        // 기본 선택값 = 공원
        if indexPath.item == 0 {
            self.viewModel.changeCellUI(cell: cell, selected: true)
        } else {
            self.viewModel.changeCellUI(cell: cell, selected: false)
        }
        cell.themeLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        
        return cell
    }
    
    // 셀이 선택되었을 때 실행할 내용
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ThemeCollectionViewCell
        
        // 기존에 표출되고 있던 annotation을 없애고 선택한 타입의 annotation을 새롭게 표출
        self.removeAnnotations()
        for index in 0..<InfoType.allCases.count {  
            isAnnotationMarked[index] = false
        }
        
        if !self.isAnnotationMarked[indexPath.row] {
            self.addAnnotationsOnTheMapView(with: InfoType(rawValue: indexPath.row)!)
        }
        
        self.viewModel.changeCellUI(cell: cell, selected: true)
    }
    
    // 셀이 해제되었을 때 실행할 내용
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ThemeCollectionViewCell
        self.viewModel.changeCellUI(cell: cell, selected: false)
    }
    
}

//MARK: - extension for UICollectionViewDelegateFlowLayout

extension MapViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return self.viewModel.headerSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return self.viewModel.footerSize
    }
    
    // 각 셀의 사이즈 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: Double?
        
        self.viewModel.themeCellData(at: indexPath.row).title.asObservable()
            .map { $0.count }
            .subscribe(onNext: { value in
                width = Double(value) * 17 + 40
            })
            .disposed(by: rx.disposeBag)
            
        guard let width = width else {
            fatalError("[ERROR] Unable to get size for collection view cell.")
        }
        
        return CGSize(width: width, height: K.ThemeCV.cellHeight)
    }
    
}
