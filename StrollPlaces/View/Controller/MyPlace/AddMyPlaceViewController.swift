//
//  AddMyPlaceViewController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/28.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import NSObject_Rx
import CoreLocation
import MapKit
import RealmSwift

class AddMyPlaceViewController: UIViewController {

    //MARK: - IB outlet & action
    
    @IBOutlet weak var testSwitch: UISwitch!
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        // 스위치의 값을 UserDefaults에 저장 후
        self.userDefaults.set(sender.isOn, forKey: "testSwitchValue")
    }
    
    @IBAction func saveButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - normal property
    
    private let userDefaults = UserDefaults.standard
    private var locationManager: CLLocationManager!
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.testSwitch.isOn = self.userDefaults.bool(forKey: "testSwitchValue")
    }

    //MARK: - directly called method
    
    // NavigationBar 설정
    private func setupNavigationBar() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.backgroundColor = UIColor.white
        
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.setNeedsStatusBarAppearanceUpdate()

        navigationItem.scrollEdgeAppearance = navigationBarAppearance
        navigationItem.standardAppearance = navigationBarAppearance
        
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    private func setupLocationManager() {
        self.locationManager = CLLocationManager()
        self.locationManager.startUpdatingLocation()
        self.locationManager.delegate = self
        self.locationManager.allowsBackgroundLocationUpdates = true
    }
    
}

//MARK: - extension for CLLocationManagerDelegate

extension AddMyPlaceViewController: CLLocationManagerDelegate {
    
    
    
}
