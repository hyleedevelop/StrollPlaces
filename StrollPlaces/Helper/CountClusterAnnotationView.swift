//
//  CustomClusterAnnotation.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/15.
//

import Foundation
import Cluster

class CountClusterAnnotationView: ClusterAnnotationView {
    override func configure() {
        super.configure()

        self.layer.cornerRadius = self.frame.width / 2
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1.5
    }
}
