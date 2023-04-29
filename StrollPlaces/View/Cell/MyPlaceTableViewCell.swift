//
//  MyPlaceTableViewCell.swift
//  StrollPlaces
//
//  Created by Eric on 2023/04/01.
//

import UIKit

class MyPlaceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupBackView()
        setupImage()
    }
    
    private func setupBackView() {
        self.backView.layer.cornerRadius = 10
        self.backView.clipsToBounds = true
        self.backView.layer.masksToBounds = false
        self.backView.layer.borderColor = UIColor.black.cgColor
        self.backView.layer.borderWidth = 0.0
        self.backView.layer.shadowColor = UIColor.black.cgColor
        self.backView.layer.shadowRadius = 3
        self.backView.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.backView.layer.shadowOpacity = 0.3
        self.backView.backgroundColor = UIColor.white
    }
    
    private func setupImage() {
        self.mainImage.layer.cornerRadius = 5
        self.mainImage.clipsToBounds = true
        self.mainImage.layer.masksToBounds = false
        self.mainImage.layer.borderColor = UIColor.black.cgColor
        self.mainImage.layer.borderWidth = 0.0
        self.mainImage.layer.shadowColor = UIColor.black.cgColor
        self.mainImage.layer.shadowRadius = 1
        self.mainImage.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.mainImage.layer.shadowOpacity = 0.5
    }
    
}
