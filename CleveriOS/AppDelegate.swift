//
//  AppDelegate.swift
//  CleveriOS
//
//  Created by Geovanny Valdez on 21/01/26.
//


import SwiftUI
import CleverTapSDK
import UserNotifications

class AppDelegate: NSObject,
                   UIApplicationDelegate,
                   UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        CleverTap.setDebugLevel(CleverTapLogLevel.debug.rawValue)
        CleverTap.autoIntegrate()
    
        let profile: Dictionary<String, AnyObject> = [:]
        CleverTap.sharedInstance()?.onUserLogin(profile)
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, _ in
            print("🔔 Push permission:", granted)
        }

        UIApplication.shared.registerForRemoteNotifications()
        return true
    }
    
    func clearKeychain() {
        let secItemClasses = [
            kSecClassGenericPassword,
            kSecClassInternetPassword,
            kSecClassCertificate,
            kSecClassKey,
            kSecClassIdentity
        ]

        for secItemClass in secItemClasses {
            let query: [String: Any] = [
                kSecClass as String: secItemClass
            ]
            SecItemDelete(query as CFDictionary)
        }
    }
    
    func registerForPush() {
        UNUserNotificationCenter.current().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(
            options: [.sound, .badge, .alert]
        ) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    // MARK: APNs token
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        CleverTap.sharedInstance()?.setPushToken(deviceToken)
    }

    // MARK: FOREGROUND (push normal)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) {

        let userInfo = notification.request.content.userInfo
        trackLatency(userInfo: userInfo,
                     appState: "foreground",
                     pushType: "alert")

        completionHandler([.banner, .sound])
    }

    // MARK: TAP (background / terminated)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {

        let userInfo = response.notification.request.content.userInfo
        CleverTap.sharedInstance()?.handleNotification(withData: userInfo)

        trackLatency(userInfo: userInfo,
                     appState: "background_or_terminated",
                     pushType: "alert")

        completionHandler()
    }

    // MARK: SILENT PUSH (background / terminated)
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler:
        @escaping (UIBackgroundFetchResult) -> Void
    ) {

        trackLatency(userInfo: userInfo,
                     appState: application.applicationState == .active ? "foreground" : "background",
                     pushType: "silent")

        completionHandler(.newData)
    }

    // MARK: Latency calculation
    private func trackLatency(
        userInfo: [AnyHashable: Any],
        appState: String,
        pushType: String
    ) {

        guard let sentAt = userInfo["sent_at"] as? Double else {
            print("⚠️ sent_at missing")
            return
        }

        let receivedAt = Date().timeIntervalSince1970
        let latency = receivedAt - sentAt

        CleverTap.sharedInstance()?.recordEvent(
            "Push Latency",
            withProps: [
                "latency_seconds": latency,
                "received_at": receivedAt,
                "app_state": appState,
                "push_type": pushType
            ]
        )

        print("⏱ Latency:", latency,
              "| state:", appState,
              "| type:", pushType)
    }
}

