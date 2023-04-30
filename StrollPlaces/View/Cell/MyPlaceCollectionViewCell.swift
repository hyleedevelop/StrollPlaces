//
//  MyPlaceCollectionViewCell.swift
//  StrollPlaces
//
//  Created by Eric on 2023/04/30.
//

import UIKit

class MyPlaceCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var removeButtonBackView: UIView!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupBackView()
        setupImage()
        setupRemoveButton()
    }
    
    private func setupBackView() {
        self.backView.backgroundColor = UIColor.white
        self.backView.clipsToBounds = true
//        self.backView.layer.masksToBounds = false
        self.backView.layer.cornerRadius = 20
        self.backView.layer.borderColor = UIColor.systemGray5.cgColor
        self.backView.layer.borderWidth = 1.0
//        self.backView.layer.shadowColor = UIColor.black.cgColor
//        self.backView.layer.shadowRadius = 3
//        self.backView.layer.shadowOffset = CGSize(width: 0, height: 0)
//        self.backView.layer.shadowOpacity = 0.3
    }
    
    private func setupImage() {
        self.mainImage.layer.cornerRadius = 5
        self.mainImage.clipsToBounds = true
        self.mainImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        self.mainImage.layer.masksToBounds = false
//        self.mainImage.layer.borderColor = UIColor.black.cgColor
//        self.mainImage.layer.borderWidth = 0.0
//        self.mainImage.layer.shadowColor = UIColor.black.cgColor
//        self.mainImage.layer.shadowRadius = 1
//        self.mainImage.layer.shadowOffset = CGSize(width: 0, height: 0)
//        self.mainImage.layer.shadowOpacity = 0.5
    }

    private func setupRemoveButton() {
        self.removeButtonBackView.clipsToBounds = true
        self.removeButtonBackView.layer.cornerRadius = self.removeButtonBackView.frame.height / 2.0
        
        
    }
    
}
