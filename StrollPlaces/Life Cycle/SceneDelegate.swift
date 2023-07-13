//
//  SceneDelegate.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/13.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
//        // 사용자의 식별자 가져오기
//        if let userIdentifier = UserDefaults.standard.value(forKey: K.UserDefaults.userIdentifier) as? String {
//
//            ASAuthorizationAppleIDProvider()
//                .getCredentialState(forUserID: userIdentifier) { credentialState, error in
//                    switch credentialState {
//                    case .authorized:
//                        print("credentialState: authorized")
//                        DispatchQueue.main.async {
//                            //authorized된 상태이므로 바로 로그인 완료 화면으로 이동
//                            self.window?.rootViewController = UITabBarController()
//                        }
//                    case .revoked:
//                        // The Apple ID credential is revoked. Show SignIn UI Here.
//                        print("credentialState: revoked")
//                    case .notFound:
//                        // No credential was found. Show SignIn UI Here.
//                        print("credentialState: notFound")
//                        break
//                    default:
//                        break
//                    }
//                }
//        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        print(#function)
    }


}

