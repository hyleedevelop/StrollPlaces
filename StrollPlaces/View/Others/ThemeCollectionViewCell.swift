//
//  ThemeCollectionViewCell.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import UIKit

class ThemeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var themeIcon: UIImageView!
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupBackView()
    }
    
    private func setupBackView() {
        backView.clipsToBounds = true
        backView.layer.masksToBounds = false
        backView.layer.cornerRadius = (K.ThemeCV.cellHeight / 2.0) - 2
        backView.layer.borderColor = UIColor.lightGray.cgColor
        backView.layer.borderWidth = 0.5
        backView.layer.shadowColor = UIColor.black.cgColor
        backView.layer.shadowRadius = 1
        backView.layer.shadowOffset = CGSize(width: 0, height: 1)
        backView.layer.shadowOpacity = 0.3
        
    }

}
