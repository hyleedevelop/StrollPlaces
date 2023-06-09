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
        return self.viewModel.numberOfSections
    }
    
    // Section 내의 Cell 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numberOfRowsInSection(at: section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.viewModel.headerHeight(at: section)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.viewModel.footerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.viewModel.headerInSection(tableView: tableView, at: section)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.viewModel.footerInSection(tableView: tableView, at: section)
    }
    
    // TableViewCell 높이 설정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.cellHeight
    }
    
    // TableViewCell에 표출할 내용
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MoreCell", for: indexPath)
                as? MoreTableViewCell else { fatalError("Unable to find MoreCell") }
        
        cell.titleLabel.text = self.viewModel.cellItemTitle(indexPath: indexPath)
        cell.descriptionLabel.text = self.viewModel.cellItemValue(indexPath: indexPath)
                
        cell.accessoryType = .none
        cell.selectionStyle = .none
        
        switch MoreCellSection(rawValue: indexPath.section) {
        case .appSettings:
            if indexPath.row == 0 {
                cell.descriptionLabel.text = self.viewModel.labelTextForMapType
            }
            if indexPath.row == 1 {
                cell.descriptionLabel.text = self.viewModel.labelTextForMapRadius
            }
            
        case .feedback:
            break
            
        case .aboutTheApp:
            if indexPath.row == 3 {
                cell.descriptionLabel.text =
                "\(self.viewModel.appVersion) (\(self.viewModel.buildNumber))"
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
                self.present(self.viewModel.actionForMapType, animated: true)
            }
            if indexPath.row == 1 {
                self.present(self.viewModel.actionForMapRadius, animated: true)
            }
            if indexPath.row == 2 {
                self.present(self.viewModel.actionForMarkRemoval, animated: true)
            }
            if indexPath.row == 3 {
                self.present(self.viewModel.actionForDBRemoval, animated: true)
            }
            if indexPath.row == 4 {
                self.present(self.viewModel.actionForLogout, animated: true)
            }
            if indexPath.row == 5 {
                self.present(self.viewModel.actionForSignout, animated: true)
            }
            
        case .feedback:
            if indexPath.row == 0 {
                self.viewModel.showSafariView(
                    viewController: self, urlString: K.More.writeReviewURL
                )
            }
            if indexPath.row == 1 {
                self.viewModel.contactMenuTapped(viewController: self)
            }
            
        case .aboutTheApp:
            if indexPath.row == 0 {
                self.viewModel.showSafariView(
                    viewController: self, urlString: K.More.helpURL
                )
            }
            if indexPath.row == 1 {
                self.viewModel.showSafariView(
                    viewController: self, urlString: K.More.privacyPolicyURL
                )
            }
            if indexPath.row == 2 {
                self.viewModel.showSafariView(
                    viewController: self, urlString: K.More.termsAndConditionsURL
                )
            }
            
        case .none:
            break
        }
        
    }
    
}
