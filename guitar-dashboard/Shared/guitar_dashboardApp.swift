//
//  guitar_dashboardApp.swift
//  Shared
//
//  Created by Guglielmo Frigerio on 07/01/22.
//

import SwiftUI

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func sceneWillEnterForeground(_ scene: UIScene) {
        // ...
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // ...
    }
    
    // ...
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // ...
        return true
    }
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self // 
        return sceneConfig
    }
}

@main
struct guitar_dashboardApp: App {
    let persistenceController = PersistenceController.shared
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    
    init() {
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

