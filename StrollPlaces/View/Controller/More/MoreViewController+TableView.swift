//
//  MoreViewController+TableView.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/26.
//

import UIKit

//MARK: - extension for UITableViewDelegate, UITableViewDataSource

extension MoreViewController: UITableViewDelegate, UITableViewDataSource {
    
    // Section의 개수
    func numberOfSections(in tableView: UITableView) -> Int {
//        return self.dataSource.count
        return 3
    }
    
    // Section 내의 Cell 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch self.dataSource[section] {
//        case let .appSettings(appSettingsModel):
//            return appSettingsModel.count
//        case let .feedback(feedbackModel):
//            return feedbackModel.count
//        case let .aboutTheApp(aboutTheAppModel):
//            return aboutTheAppModel.count
//        }
        return 5
    }
    
    // Section Header의 제목 설정
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        switch self.dataSource[section] {
//        case .appSettings(_):
//            return Constant.TitleSetting.settingSectionName1
//        case .feedback(_):
//            return Constant.TitleSetting.settingSectionName2
//        case .aboutTheApp(_):
//            return Constant.TitleSetting.settingSectionName3
//        }
        return nil
    }

    // Section Header의 스타일 설정
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        let title = UILabel()
//        title.font = UIFont.systemFont(ofSize: 18, weight: .bold)
//        title.textColor = .label
//        switch self.dataSource[section] {
//        case .appSettings(_):
//            title.text = Constant.TitleSetting.settingSectionName1
//        case .feedback(_):
//            title.text = Constant.TitleSetting.settingSectionName2
//        case .aboutTheApp(_):
//            title.text = Constant.TitleSetting.settingSectionName3
//        }
//
//        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
//        header.textLabel!.font = title.font
//        header.textLabel?.textColor = title.textColor
//        header.textLabel?.text = title.text?.localizedCapitalized
    }
    
    // TableViewCell 높이 설정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    // TableViewCell에 표출할 내용
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        switch self.dataSource[indexPath.section] {
//
//        case let .appSettings(appSettingModel):
//            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingCell
//            let model = appSettingModel[indexPath.row]
//            cell.prepare(icon: model.icon, title: model.title, value: model.value)
//            cell.accessoryType = .disclosureIndicator
//            cell.selectionStyle = .none
//            cell.backgroundColor = UIColor(named: "IBColor")
//            return cell
//
//        case let .feedback(feedbackModel):
//            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingCell
//            let model = feedbackModel[indexPath.row]
//            cell.prepare(icon: model.icon, title: model.title, value: model.value)
//            cell.accessoryType = .disclosureIndicator
//            cell.selectionStyle = .none
//            cell.backgroundColor = UIColor(named: "IBColor")
//            return cell
//
//        case let .aboutTheApp(aboutTheAppModel):
//            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingCell
//            let model = aboutTheAppModel[indexPath.row]
//
//            cell.prepare(icon: model.icon, title: model.title, value: model.value)
//            if 0...3 ~= indexPath.row {
//                cell.accessoryType = .disclosureIndicator
//            } else {
//                cell.accessoryType = .none
//            }
//            cell.selectionStyle = .none
//            cell.backgroundColor = UIColor(named: "IBColor")
//            return cell
//        }
        return UITableViewCell()
    }
    
    // Cell 선택 시 동작 설정
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        switch self.dataSource[indexPath.section] {
//        case .appSettings(_):
//            if indexPath.row == 0 {
//                let themeColorVC = ThemeColorViewController()
//                navigationController?.pushViewController(themeColorVC, animated: true)
//            }
//        case .feedback(_):
//            if indexPath.row == 0 {
//                guard let writeReviewURL = URL(string: Constant.URLSetting.writeReviewURL) else { return }
//                UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
//            }
//            if indexPath.row == 1 { contactMenuTapped() }
//        case .aboutTheApp(_):
//            if indexPath.row == 0 {
//                let websiteURL = NSURL(string: Constant.URLSetting.helpURL)
//                let webView = SFSafariViewController(url: websiteURL! as URL)
//                self.present(webView, animated: true, completion: nil)
//            }
//            if indexPath.row == 1 {
//                let acknowListVC = AcknowListViewController(fileNamed: "Pods-CryptoSimulator-acknowledgements")
//                navigationController?.pushViewController(acknowListVC, animated: true)
//            }
//            if indexPath.row == 2 {
//                let websiteURL = NSURL(string: Constant.URLSetting.privacyPolicyURL)
//                let webView = SFSafariViewController(url: websiteURL! as URL)
//                self.present(webView, animated: true, completion: nil)
//            }
//            if indexPath.row == 3 {
//                let websiteURL = NSURL(string: Constant.URLSetting.termsAndConditionsURL)
//                let webView = SFSafariViewController(url: websiteURL! as URL)
//                self.present(webView, animated: true, completion: nil)
//            }
//        }
        
    }
    
}
