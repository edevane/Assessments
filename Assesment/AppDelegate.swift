//
//  AppDelegate.swift
//  Assesment
//
//  Created by Edevane Tan on 17/12/2024.
//

import UIKit
import Swinject
import SwinjectAutoregistration

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let baseAssembler = Assembler([CatAssembler()])

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = CatViewController(viewModel: baseAssembler.resolver~>)
        let navigationController = UINavigationController(rootViewController: viewController)
        setupNavigationBar()
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }

    private func setupNavigationBar() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }
}
