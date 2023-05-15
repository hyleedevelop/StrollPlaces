//
//  AnnotationView.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/15.
//

import UIKit
import MapKit
import Cluster

class CountClusterAnnotationView: ClusterAnnotationView {
    
    override func configure() {
        super.configure()

        guard let annotation = annotation as? ClusterAnnotation else { return }
        let count = annotation.annotations.count
        let diameter = radius(for: count) * 2
        self.frame.size = CGSize(width: diameter, height: diameter)
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1.5
        self.alpha = 0.8
    }

    // cluster 개수에 따른 annotation 크기(반지름) 설정
    func radius(for count: Int) -> CGFloat {
        if count < 10 {
            return 13
        } else if count < 100 {
            return 16
        } else if count < 1000 {
            return 19
        } else {
            return 22
        }
    }

}

class ImageCountClusterAnnotationView: ClusterAnnotationView {

    lazy var once: Void = { [unowned self] in
        self.countLabel.frame.size.width -= 6
        self.countLabel.frame.origin.x += 3
        self.countLabel.frame.origin.y -= 6
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()

        _ = once
    }

}

