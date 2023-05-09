//
//  TabBarController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import UIKit
import TransitionableTab

final class TabBarController: UITabBarController {

    //MARK: - storyboard property

    @IBInspectable var initialIndex: Int = 0

    //MARK: - life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupTabBar()
        
    }

    //MARK: - directly called method

    private func setupTabBar() {
        self.delegate = self
        selectedIndex = initialIndex
        
        UITabBar.clearShadow()
        tabBar.layer.applyShadow(color: .gray, alpha: 0.3, x: 0, y: 0, blur: 12)
        
        let numberOfTracks = RealmService.shared.realm.objects(TrackData.self).count
        self.tabBar.items![2].badgeValue = "\(numberOfTracks)"
        self.tabBar.items![2].badgeColor = K.Color.themeGreen
    }

}

//MARK: - extension for TransitionableTab

extension TabBarController: TransitionableTab {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return animateTransition(tabBarController, shouldSelect: viewController)
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
}
