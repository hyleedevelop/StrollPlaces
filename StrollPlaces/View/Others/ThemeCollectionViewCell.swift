//
//  ThemeCollectionViewCell.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import UIKit

class ThemeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var themeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupButton()
    }
    
    private func setupButton() {
        themeLabel.clipsToBounds = true
        themeLabel.layer.cornerRadius = K.ThemeCV.cellHeight / 2.0
        themeLabel.layer.borderColor = UIColor.lightGray.cgColor
        themeLabel.layer.borderWidth = 0.5
        themeLabel.layer.shadowColor = UIColor.black.cgColor
        themeLabel.layer.shadowRadius = 3
        themeLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        themeLabel.layer.shadowOpacity = 0.3
        //themeButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    }

}
