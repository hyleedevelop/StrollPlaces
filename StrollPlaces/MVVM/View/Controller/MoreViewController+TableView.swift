//
//  MoreViewController+TableView.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/26.
//

import UIKit
import MapKit
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.viewModel.getTitleForHeaderInSection(at: section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 50 : 40
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let yPosition: CGFloat = section == 0 ? 20 : 10
        let titleLabel = UILabel(frame: CGRect(
            x: 10, y: yPosition, width: tableView.frame.width, height: 18
        ))
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = UIColor.black
        titleLabel.text = self.viewModel.getTitleForHeaderInSection(at: section)
        
        let headerView = UIView()
        headerView.addSubview(titleLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let separatorView = UIView(frame: CGRect(
            x: -20, y: 20, width: tableView.frame.width, height: 1
        ))
        separatorView.backgroundColor = UIColor.systemGray5
        
        let footerView = UIView()
        footerView.addSubview(separatorView)
        
        return section == self.viewModel.getNumberOfSections()-1 ? nil : footerView
    }
    
    // TableViewCell 높이 설정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    // TableViewCell에 표출할 내용
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MoreCell", for: indexPath)
                as? MoreTableViewCell else { fatalError("Unable to find MoreCell") }
        
        cell.titleLabel.text = self.viewModel.moreCellData[indexPath.section][indexPath.row].title
        cell.descriptionLabel.text = self.viewModel.moreCellData[indexPath.section][indexPath.row].value
                
        cell.accessoryType = .none
        cell.selectionStyle = .none
        
        switch MoreCellSection(rawValue: indexPath.section) {
        case .appSettings:
            if indexPath.row == 0 {
                cell.descriptionLabel.text = self.viewModel.getLabelTextForMapType()
            }
            if indexPath.row == 1 {
                cell.descriptionLabel.text = self.viewModel.getLabelTextForMapRadius()
            }
            
        case .feedback:
            if indexPath.row == 0 {
                
            }
            if indexPath.row == 1 {
                
            }
            
        case .aboutTheApp:
            if indexPath.row == 4 {
                cell.descriptionLabel.text = "\(self.viewModel.getCurrentAppVersion()) " +
                "(\(self.viewModel.getCurrentBuildNumber()))"
            }
            
        case .none:
            break
        }
        
        return cell
    }
    
    // TableViewCell 선택 시 동작 설정
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch MoreCellSection(rawValue: indexPath.section) {
        case .appSettings:
            if indexPath.row == 0 {
                self.present(self.viewModel.getActionForMapType(), animated: true, completion: nil)
            }
            if indexPath.row == 1 {
                self.present(self.viewModel.getActionForMapRadius(), animated: true, completion: nil)
            }
            if indexPath.row == 2 {
                self.present(self.viewModel.getActionForDBRemoval(), animated: true, completion: nil)
            }
            
        case .feedback:
            self.showWillBeUpdatedMessage()
            
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
