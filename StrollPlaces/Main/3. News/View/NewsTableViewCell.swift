//
//  NewsTableViewCell.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/25.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.white
        
        setupBackView()
        setupLabel()
    }
    
    private func setupBackView() {
        backView.clipsToBounds = true
        backView.layer.masksToBounds = false
        backView.layer.cornerRadius = K.Shape.largeCornerRadius
        backView.layer.borderColor = K.Color.mainColor.cgColor
        backView.layer.borderWidth = 1
        backView.layer.shadowColor = UIColor.systemGray5.cgColor
        backView.layer.shadowRadius = 3
        backView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backView.layer.shadowOpacity = 0.7
    }
    
    private func setupLabel() {
        //titleLabel.textColor = K.Color.mainColor
    }
}
