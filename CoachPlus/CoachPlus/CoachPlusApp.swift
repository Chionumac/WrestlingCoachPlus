//
//  CoachPlusApp.swift
//  CoachPlus
//
//  Created by Christopher Chinonuma on 1/21/25.
//

import SwiftUI
import StoreKit

@main
struct CoachPlusApp: App {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showPaywall = false
    @State private var showWelcome = false
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    init() {
        // Lock orientation to portrait
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        AppDelegate.orientationLock = .portrait
        NotificationManager.shared.requestAuthorization()
        NotificationManager.shared.scheduleMonthlyReviewNotification()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    if !hasSeenWelcome {
                        showWelcome = true
                        hasSeenWelcome = true
                    }
                }
                .onChange(of: subscriptionManager.subscriptionStatus) { _, newStatus in
                    if case .notSubscribed = newStatus {
                        showPaywall = true
                    }
                }
                .sheet(isPresented: $showWelcome) {
                    WelcomeView()
                }
                .sheet(isPresented: $showPaywall) {
                    PaywallView()
                }
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
