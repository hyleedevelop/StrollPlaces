//
//  MyPlaceViewController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import UIKit
import CoreLocation
//import ActivityKit

class MyPlaceViewController: UIViewController {

    //MARK: - IB outlet & action
    
    @IBOutlet weak var currentLocationLabel: UILabel!
    
    //MARK: - property
    
    private var locationManager: CLLocationManager!
    
    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.locationManager = CLLocationManager()
        self.locationManager.startUpdatingLocation()
        self.locationManager.delegate = self
        self.locationManager.allowsBackgroundLocationUpdates = true
    }

}

//MARK: - extension for

extension MyPlaceViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocationLabel.text = "위도: \(location.coordinate.latitude)°" + "\n" +
                                        "경도: \(location.coordinate.longitude)°"
        }
    }
    
}
