//
//  AlertMessageService.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/30.
//

import UIKit

final class AlertService {
    
    static let shared = AlertService()
    private init() {}
    
//    func showAlertMessage(
//        title: String,
//        message: String,
//        style: UIAlertController.Style,
//        yesAction: Bool,
//        noAction: Bool,
//        completion: @escaping () -> Void
//    ) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
//        let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
//        let yesAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
//
//            //self.dismiss(animated: true)
//            guard let self = self else { return }
//            self.searchController.isActive = false
//            self.dismiss(animated: true)
//        }
//
//        // 액션 추가 및 팝업메세지 출력
//        alert.addAction(yesAction)
//        alert.addAction(noAction)
//        self.present(alert, animated: true, completion: nil)
//    }
    
}
