//
//  MyPlaceViewController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import UIKit
import SnapKit
import CoreLocation
//import ActivityKit
import Lottie

class MyPlaceViewController: UIViewController {

    //MARK: - IB outlet & action
    
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var currentLocationLabel: UILabel!
    
    //MARK: - property
    
    private var locationManager: CLLocationManager!
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupLottieAnimation()
        
        self.locationManager = CLLocationManager()
        self.locationManager.startUpdatingLocation()
        self.locationManager.delegate = self
        self.locationManager.allowsBackgroundLocationUpdates = true
    }
    
    //MARK: - directly called method
    
    // NavigationBar 설정
    private func setupNavigationBar() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.backgroundColor = UIColor.white
//        navigationBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
//        navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        // scrollEdge: 스크롤 하기 전의 NavigationBar
        // standard: 스크롤을 하고 있을 때의 NavigationBar
        navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.setNeedsStatusBarAppearanceUpdate()

        navigationItem.scrollEdgeAppearance = navigationBarAppearance
        navigationItem.standardAppearance = navigationBarAppearance
        
        self.extendedLayoutIncludesOpaqueBars = true
    }

    private func setupLottieAnimation() {
        self.animationView.loopMode = .loop
        self.animationView.animationSpeed = 1.0
        self.animationView.play()
    }
    
    //MARK: - indirectly called method
    
}

//MARK: - extension for CLLocationManagerDelegate

extension MyPlaceViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.last {
//            currentLocationLabel.text = "위도: \(location.coordinate.latitude)°" + "\n" +
//                                        "경도: \(location.coordinate.longitude)°"
//        }
    }
    
}
