//
//  OnboardingCollectionViewCell.swift
//  StrollPlaces
//
//  Created by Eric on 2023/05/09.
//

import UIKit
import Lottie

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    //MARK: - IB outlet
    @IBOutlet weak var slideImage: UIImageView!
    @IBOutlet weak var slideTitleLabel: UILabel!
    @IBOutlet weak var slideDescriptionLabel: UILabel!
        
    //MARK: - initialize
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: - directly called method
    
    func setup(_ slide: OnboardingData) {
        self.slideImage.image = slide.image
        self.slideTitleLabel.text = slide.title
        self.slideDescriptionLabel.text = slide.description
    }
    
}
