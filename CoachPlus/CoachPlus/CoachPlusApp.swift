//
//  CoachPlusApp.swift
//  CoachPlus
//
//  Created by Christopher Chinonuma on 1/21/25.
//

import SwiftUI

@main
struct CoachPlusApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    init() {
        // Lock orientation to portrait
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        AppDelegate.orientationLock = .portrait
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Add AppDelegate to handle orientation lock
class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
