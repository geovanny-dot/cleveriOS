//
//  CleverTapReset.swift
//  CleveriOS
//
//  Created by Geovanny Valdez on 15/09/26.
//

import CleverTapSDK
@objc private protocol CleverTapPrivateSwitchUser {
    @objc(_asyncSwitchUser:withCachedGuid:andCleverTapID:forAction:)
    func asyncSwitchUser(_ properties: [AnyHashable: Any]?,
                         cachedGuid: String?,
                         cleverTapID: String?,
                         action: String)
}
enum CleverTapReset {
    private static let switchUserSelector = NSSelectorFromString(
        "_asyncSwitchUser:withCachedGuid:andCleverTapID:forAction:")
    /// Cambia la instancia compartida a un perfil anónimo nuevo.
    /// Devuelve false si el selector no está disponible en la versión del SDK.
    static func switchToNewAnonymousUser() -> Bool {
        guard let instance = CleverTap.sharedInstance(),
              instance.responds(to: switchUserSelector) else {
            return false
        }
        let proxy = unsafeBitCast(instance, to: CleverTapPrivateSwitchUser.self)
        proxy.asyncSwitchUser(nil,
                              cachedGuid: nil,
                              cleverTapID: nil,
                              action: "resetCleverTapInstance")
        return true
    }
}

