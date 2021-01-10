//
//  SceneDelegate.swift
//  Test_App
//
//  Created by Kristina Afanasieva on 06.01.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        guard let firstVC = R.storyboard.listFriends().instantiateInitialViewController() else { return }
        let navigationController = UINavigationController()
        navigationController.viewControllers = [firstVC]
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    

}

