//
//  DetailView.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/19.
//

import UIKit
import SnapKit

final class DetailView: UIView {
    
    //MARK: - 속성
    
    private let grabBar: UIView = {
        let bar = UIView()
        bar.backgroundColor = UIColor.lightGray
        bar.clipsToBounds = true
        bar.layer.cornerRadius = 1.5
        return bar
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.allowsSelection = false
        return tv
    }()
    
    //MARK: - 생성자
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupGrabBar()
        setupLabel()
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - 메서드
    
    private func setupGrabBar() {
        self.addSubview(grabBar)
        
        grabBar.snp.makeConstraints {
            $0.top.equalTo(self).offset(10)
            $0.centerX.equalTo(self)
            $0.height.equalTo(3)
            $0.width.equalTo(30)
        }
    }
    
    private func setupLabel() {
        self.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(grabBar).offset(15)
            $0.centerX.equalTo(self)
            $0.height.equalTo(20)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        self.addSubview(tableView)

        tableView.snp.makeConstraints {
            $0.top.equalTo(nameLabel).offset(50)
            $0.left.right.equalTo(self.safeAreaLayoutGuide)
            $0.bottom.equalTo(self.safeAreaLayoutGuide)
        }
    }
    
}

//MARK: - extension for
extension DetailView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return UITableViewCell()
    }
    
}
