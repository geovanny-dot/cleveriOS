//
//  NativeDisplayManager.swift
//  CleveriOS
//
//  Created by Geovanny Valdez on 3/09/26.
//

import CleverTapSDK
import Combine

class NativeDisplayManager: NSObject, ObservableObject, CleverTapDisplayUnitDelegate {
    @Published var units: [CleverTapDisplayUnit] = []

    override init() {
        super.init()
        CleverTap.sharedInstance()?.setDisplayUnitDelegate(self)
    }

    func displayUnitsUpdated(_ displayUnits: [CleverTapDisplayUnit]) {
        DispatchQueue.main.async {
            self.units = displayUnits
        }
    }

    func triggerCampaign(eventName: String) {
        CleverTap.sharedInstance()?.recordEvent(eventName)
    }

    func markViewed(_ unit: CleverTapDisplayUnit) {
        guard let id = unit.unitID else { return }
        CleverTap.sharedInstance()?.recordDisplayUnitViewedEvent(forID: id)
    }

    func markClicked(_ unit: CleverTapDisplayUnit) {
        guard let id = unit.unitID else { return }
        CleverTap.sharedInstance()?.recordDisplayUnitClickedEvent(forID: id)
    }
}
