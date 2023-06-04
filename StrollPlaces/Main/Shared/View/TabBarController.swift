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

        self.setupNotificationObserver()
        self.setupTabBar()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    //MARK: - directly called method

    // Notification을 받았을 때 수행할 내용 설정
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(self.updateBadge(_:)),
            name: Notification.Name("updateBadge"), object: nil
        )
    }
    
    // Tab Bar 설정
    private func setupTabBar() {
        self.delegate = self
        selectedIndex = initialIndex
        
        UITabBar.clearShadow()
        tabBar.layer.applyShadow(color: .gray, alpha: 0.3, x: 0, y: 0, blur: 12)
        
        self.updateNumberInBadge()
    }
    
    //MARK: - indirectly called method
    
    // Tab Bar의 배지 업데이트
    @objc private func updateBadge(_ sender: NSNotification) {
        self.updateNumberInBadge()
    }
    
    // Tab Bar의 배지 업데이트
    private func updateNumberInBadge() {
        let numberOfTracks = RealmService.shared.realm.objects(TrackData.self).count
        self.tabBar.items![1].badgeValue = "\(numberOfTracks)"
        self.tabBar.items![1].badgeColor = K.Color.themeGreen
    }
    
    private func showSpringAnimation(imageView: UIImageView) {
        DispatchQueue.main.async {
            UIView.animate(
                withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut
            ) {
                imageView.transform = CGAffineTransform.init(scaleX: 1.25, y: 1.25)
                
                UIView.animate(
                    withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut
                ) {
                    imageView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                }
            }
        }
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
        
        guard let index = tabBar.items?.firstIndex(of: item),
              tabBar.subviews.count > index + 1,
              let imageView = tabBar.subviews[index + 1].subviews.compactMap({ $0 as? UIImageView }).first
        else { return }
        
        self.showSpringAnimation(imageView: imageView)
    }
    
}
