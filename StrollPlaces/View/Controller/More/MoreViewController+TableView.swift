//
//  MoreViewController+TableView.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/26.
//

import UIKit
import SafariServices
import AcknowList
import SPIndicator

//MARK: - extension for UITableViewDelegate, UITableViewDataSource

extension MoreViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Section의 개수
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.getNumberOfSections()
    }
    
    // Section 내의 Cell 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getNumberOfRowsInSection(at: section)
    }
    
    // Section Header의 제목 설정
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.viewModel.getTitleForHeaderInSection(at: section)
    }

    // Section Header의 스타일 설정
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        title.textColor = UIColor.black

        let backView = UIView()
        backView.backgroundColor = K.Color.mainColorLight
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel!.font = title.font
        header.textLabel?.textColor = title.textColor
        header.backgroundView = backView
        header.layer.borderColor = UIColor.systemGray4.cgColor
        header.layer.borderWidth = 0
    }
    
    // TableViewCell 높이 설정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    // TableViewCell에 표출할 내용
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MoreCell", for: indexPath)
                as? MoreTableViewCell else { fatalError("Unable to find MoreCell") }
        
        cell.titleIcon.image = self.viewModel.moreCellData[indexPath.section][indexPath.row].icon
        cell.titleLabel.text = self.viewModel.moreCellData[indexPath.section][indexPath.row].title
        cell.descriptionLabel.text = self.viewModel.moreCellData[indexPath.section][indexPath.row].value
                
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor.white
        
        if indexPath.section == 2 {
            if indexPath.row == 4 {
                cell.accessoryType = .none
                cell.descriptionLabel.text = "\(self.viewModel.getCurrentAppVersion()) (\(self.viewModel.getCurrentBuildNumber()))"
            }
        }
        return cell
    }
    
    // TableViewCell 선택 시 동작 설정
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch MoreCellSection(rawValue: indexPath.section) {
        case .appSettings:
            print("appSettings")
            if indexPath.row == 2 {
                // 진짜로 취소할 것인지 alert message 보여주고 확인받기
                let alert = UIAlertController(title: "확인",
                                              message: "산책길 보관함을 초기화할까요?\n모든 산책길 데이터가 삭제됩니다.",
                                              preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "아니요", style: .default)
                let okAction = UIAlertAction(title: "네", style: .destructive) { _ in
                    self.viewModel.clearRealmDB()
                    
                    let indicatorView = SPIndicatorView(title: "삭제 완료", preset: .done)
                    indicatorView.present(duration: 2.0, haptic: .success)
                }
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                
                // 메세지 보여주기
                self.present(alert, animated: true, completion: nil)
                
                // userdefaults 값 false로 초기화 -> Lottie Animation 표출
                self.userDefaults.set(false, forKey: "myPlaceExist")
                NotificationCenter.default.post(name: Notification.Name("showLottieAnimation"), object: nil)
            }
        case .feedback:
            print("feedback")
        case .aboutTheApp:
            if indexPath.row == 0 {
                self.showSafariView(urlString: K.More.helpURL)
            }
            if indexPath.row == 1 {
                //let acknowListViewController =
                //AcknowListViewController(fileNamed: "Pods-CryptoSimulator-acknowledgements")
                //navigationController?.pushViewController(acknowListViewController, animated: true)
                self.showWillBeUpdatedMessage()
            }
            if indexPath.row == 2 {
                self.showSafariView(urlString: K.More.privacyPolicyURL)
            }
            if indexPath.row == 3 {
                self.showSafariView(urlString: K.More.termsAndConditionsURL)
            }
        case .none:
            break
        }
        
    }
    
}
