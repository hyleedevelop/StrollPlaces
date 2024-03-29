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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifier.moreCell, for: indexPath)
                as? MoreTableViewCell else { fatalError("Unable to find MoreCell") }
        
        cell.titleLabel.text = self.viewModel.cellItemTitle(indexPath: indexPath)
        cell.descriptionLabel.text = self.viewModel.cellItemValue(indexPath: indexPath)
                
        cell.accessoryType = .none
        cell.selectionStyle = .none
        
        switch MoreCellSection(rawValue: indexPath.section) {
        case .appSettings:
            switch indexPath.row {
            case 0: cell.descriptionLabel.text = self.viewModel.labelTextForMapType
            case 1: cell.descriptionLabel.text = self.viewModel.labelTextForMapRadius
            default: break
            }
            
        case .feedback:
            break
            
        case .aboutTheApp:
            switch indexPath.row {
            case 3: cell.descriptionLabel.text =
                "\(self.viewModel.appVersion) (\(self.viewModel.buildNumber))"
            default: break
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
            switch indexPath.row {
            case 0: self.present(self.viewModel.actionForMapType, animated: true)
            case 1: self.present(self.viewModel.actionForMapRadius, animated: true)
            case 2: self.present(self.viewModel.actionForMarkRemoval, animated: true)
            case 3: self.present(self.viewModel.actionForDBRemoval, animated: true)
            case 4: self.present(self.viewModel.actionForLogout, animated: true)
            case 5: self.present(self.viewModel.actionForSignout, animated: true)
            default: break
            }
            
        case .feedback:
            switch indexPath.row {
            case 0: self.viewModel.showSafariView(viewController: self,
                                                  urlString: K.More.writeReviewURL)
            case 1: self.viewModel.contactMenuTapped(viewController: self)
            default: break
            }
            
        case .aboutTheApp:
            switch indexPath.row {
            case 0: self.viewModel.showSafariView(viewController: self,
                                                  urlString: K.More.helpURL)
            case 1: self.viewModel.showSafariView(viewController: self,
                                                  urlString: K.More.privacyPolicyURL)
            case 2: self.viewModel.showSafariView(viewController: self,
                                                  urlString: K.More.termsAndConditionsURL)
            default: break
            }
            
        case .none:
            break
        }
        
    }
    
}
