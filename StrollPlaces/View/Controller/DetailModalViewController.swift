//
//  DetailModalViewController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/16.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class DetailModalViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    private let mapViewController = MapViewController()
    
    var name: String?
    var phoneNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLabel()
    }
    
    private func setupLabel() {
        self.nameLabel.text = name
        self.phoneNumberLabel.text = phoneNumber
    }
    
}
