//
//  TabBarController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import UIKit

class TabBarController: UITabBarController {

    @IBInspectable var initialIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
    }
    
    func setupTabBar() {
        selectedIndex = initialIndex
        
        // iOS 15 업데이트 이후 TabBar, NavigationBar가 보이지 않는 문제 해결
        if #available(iOS 15.0, *) {
            tabBar.backgroundColor = UIColor.brown
            tabBar.tintColor = UIColor.black
            tabBar.layer.cornerRadius = tabBar.frame.height / 2.0
            tabBar.isTranslucent = false

            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            tabBarAppearance.backgroundColor = UIColor.white
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            
            
            //self.tabBar.layer.borderColor = UIColor.lightGray.cgColor
            //self.tabBar.layer.borderWidth = 0.5
            

            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithDefaultBackground()
            navigationBarAppearance.backgroundColor = UIColor(named: "BGColor")
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        }
        
        
        
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
