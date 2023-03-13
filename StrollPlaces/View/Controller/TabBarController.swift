//
//  TabBarController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
    }
    
    func setupTabBar() {
        // iOS 15 업데이트 이후 TabBar, NavigationBar가 보이지 않는 문제 해결
        if #available(iOS 15.0, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            tabBarAppearance.backgroundColor = UIColor(named: "IBColor")
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithDefaultBackground()
            navigationBarAppearance.backgroundColor = UIColor(named: "BGColor")
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        }
        
        tabBar.tintColor = .label
        
        /*
        // 수익계산 탭 (홈)
        let vc1 = UINavigationController(rootViewController: MapViewController())
        vc1.tabBarItem.title = "홈"
        vc1.tabBarItem.image = UIImage(systemName: "square.and.pencil")
        
        // 설정 탭
        let vc2 = UINavigationController(rootViewController: SettingViewController())
        vc2.tabBarItem.title = "설정"
        vc2.tabBarItem.image = UIImage(systemName: "ellipsis")
        
        viewControllers = [vc1, vc2]
        
        // 앱을 처음 실행했을 때 화면에 보여줄 탭 설정 (Index = 0, 1)
        self.selectedIndex = 0
         */
    }

}
