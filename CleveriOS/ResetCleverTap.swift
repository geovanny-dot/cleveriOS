//
//  ResetCleverTap.swift
//  CleveriOS
//
//  Created by Geovanny Valdez on 15/09/26.
//

import UserNotifications
import UIKit
import CleverTapSDK

@MainActor
func resetCleverTapInstance() async {
    let center = UNUserNotificationCenter.current()
    _ = try? await center.requestAuthorization(options: [.sound, .alert, .badge])
    UIApplication.shared.unregisterForRemoteNotifications()
    guard let accountId = CleverTap.sharedInstance()?.config.accountId else { return }
    CleverTap.sharedInstance()?.onUserLogin([:])
    // Borra el plist local del perfil
    if let appDir = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).last
    {
        let filePath = "\(appDir)/clevertap-\(accountId)-userprofile.plist"
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                try FileManager.default.removeItem(atPath: filePath)
            } catch {
                // Fix: ya no usamos try!, así que un error de permisos no crashea la app.
                print("CleverTap reset: no se pudo borrar el perfil — \(error)")
            }
        }
    }
    // Fix: la condición ahora usa && para preservar ambas claves correctamente.
    let defaults = UserDefaults.standard
    let keysToRemove = defaults.dictionaryRepresentation().keys.filter { key in
        key.contains("WizRocket")
        && key != "WizRocketdevice_token"
        && key != "WizRocketfirstTime"
    }
    keysToRemove.forEach { defaults.removeObject(forKey: $0) }
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
        appDelegate.registerForPush()
    }
}
