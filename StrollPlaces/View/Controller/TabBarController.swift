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

    //MARK: - normal property
    
    private var upperLineView: UIView!
    private let spacing: CGFloat = 12

    //MARK: - drawing cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
    }

    //MARK: - directly called method
    
    private func setupTabBar() {
        self.delegate = self
        selectedIndex = initialIndex
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
            self.addTabbarIndicatorView(index: self.initialIndex, isFirstTime: true)
        }
        
        // iOS 15 업데이트 이후 TabBar, NavigationBar가 보이지 않는 문제 해결
//        if #available(iOS 15.0, *) {
//            tabBar.backgroundColor = UIColor.brown
//            tabBar.tintColor = UIColor.black
//            tabBar.layer.cornerRadius = tabBar.frame.height / 2.0
//            tabBar.isTranslucent = false
//
//            let tabBarAppearance = UITabBarAppearance()
//            tabBarAppearance.configureWithDefaultBackground()
//            tabBarAppearance.backgroundColor = UIColor.white
//            UITabBar.appearance().standardAppearance = tabBarAppearance
//            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
//
//
//            //self.tabBar.layer.borderColor = UIColor.lightGray.cgColor
//            //self.tabBar.layer.borderWidth = 0.5
//
//
//            let navigationBarAppearance = UINavigationBarAppearance()
//            navigationBarAppearance.configureWithDefaultBackground()
//            //navigationBarAppearance.backgroundColor = UIColor(named: "BGColor")
//            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
//            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
//            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
//        }
    }
    
    func addTabbarIndicatorView(index: Int, isFirstTime: Bool = false){
        guard let tabView = tabBar.items?[index].value(forKey: "view") as? UIView else { return }
        
        if !isFirstTime{ upperLineView.removeFromSuperview() }
        
        upperLineView = UIView(frame: CGRect(x: tabView.frame.minX + spacing,
                                             y: tabView.frame.minY + 0.5,
                                             width: tabView.frame.size.width - spacing * 2,
                                             height: 4))
        upperLineView.backgroundColor = K.Color.mainColor
        tabBar.addSubview(upperLineView)
        
        //DispatchQueue.main.async { self.view.layoutIfNeeded() }
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
        
        addTabbarIndicatorView(index: self.selectedIndex)
    }
    
}
