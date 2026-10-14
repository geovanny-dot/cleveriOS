//
//  ContentView.swift
//  CleveriOS
//
//  Created by Geovanny Valdez on 14/01/26.
//

import SwiftUI
import CleverTapSDK

struct ContentView: View {
    @State private var isLoading = false
    @StateObject private var manager = NativeDisplayManager()
    
    var body: some View {
        VStack {
            Button("Login") {
                            sendLogin()
                    }
            Button("Send Event") {
                            sendTestEvent()
                    }
            Button("Login new user") {
                            sendLoginNewUser()
                    }
            Button("Clear cache") {
                            clearCache()
                    }

            Button("Cerrar sesión") {
                logoutFromCleverTap()
            }
            
            ForEach(Array(manager.units.enumerated()), id: \.offset) { _, unit in
                ForEach(Array((unit.contents ?? []).enumerated()), id: \.offset) { _, content in
                    VStack(alignment: .leading) {
                        
                        Text(content.title ?? "")
                            .font(.headline)
                        Text(content.message ?? "")
                            .font(.subheadline)
                    }
                    .padding()
                    .cornerRadius(8)
                    // Se dispara cuando la vista aparece en pantalla
                    .onAppear {
                        manager.markViewed(unit)
                    }
                    .onTapGesture {
                        manager.markClicked(unit)
                    }
                }
            }
        }.onAppear {
            
            manager.triggerCampaign(eventName: "NativeEvent")
            manager.triggerCampaign(eventName: "NativeEvent2")
            manager.triggerCampaign(eventName: "NativeEvent3")
            manager.triggerCampaign(eventName: "NativeEvent4")
            manager.triggerCampaign(eventName: "NativeEvent5")
        }
        .padding()
    }
    
    func clearCache(){
        let defaults = UserDefaults.standard
           defaults.dictionaryRepresentation().keys
               .filter { $0.hasPrefix("WizRocket") && $0.hasSuffix(":CachedGUIDS") }
               .forEach { defaults.removeObject(forKey: $0) }
    }
    
    func sendLoginUserB() {
        let profile: [String: Any] = [
            "Name": "TestLogOutUser_A03",
            "Identity": "10000A03",
            "Email": "fakeA03@TestLogOutUser_b.com"
        ]

        CleverTap.sharedInstance()?.onUserLogin(profile)
    }
    
    func sendLoginNewUser() {
        clearCache()
        guard CleverTapReset.switchToNewAnonymousUser() else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("===== TRAS SWITCH =====")
            printKeys()
            
            CleverTap.sharedInstance()?.recordEvent("Onboarding Started")
            CleverTap.sharedInstance()?.recordEvent("Onboarding Step 1")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                sendLoginUserB()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    print("===== DESPUES LOGIN B =====")
                    printKeys()
                }
            }
        }
    }
    
    func printKeys() {
        UserDefaults.standard.dictionaryRepresentation().keys
            .filter { $0.contains("WizRocket") }
            .sorted()
            .forEach {
                print("KEYS__", $0, "=", UserDefaults.standard.object(forKey: $0) ?? "nil")
            }
    }
    
    func sendLogin() {
        print("===== ANTES =====")
        printKeys()
        
        let profile: [String: Any] = [
            "Name": "TestLogOutUser_A01",
            "Identity": "10000A01",
            "Email": "fakeA01@TestLogOutUser_b.com"
        ]

        CleverTap.sharedInstance()?.onUserLogin(profile)
        
        // Después del switch
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("===== DESPUES =====")
            printKeys()
        }
    }
    
    func performLogout() {
        isLoading = true

        let profile: [String: Any] = [
            "Identity": "0000",
            "Email": "fake@demo.com",
            "MSG-push":     false,
            "MSG-email":    false,
            "MSG-sms":      false,
            "MSG-whatsapp": false
        ]

        CleverTap.sharedInstance()?.onUserLogin(profile)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoading = false
        }
    }

    
    func sendTestEvent() {

            let orderDetails: [String: Any] = [
                "orderId": "ORD-10001",
                "total": 249.99,
                "currency": "USD",
                "customer": [
                    "id": "USER_12345",
                    "membership": "Gold"
                ],
                "shipping": [
                    "method": "Express",
                    "address": [
                        "city": "Miami",
                        "country": "USA"
                    ]
                ],
                "items": [
                    [
                        "sku": "IPH16-128",
                        "name": "iPhone 16",
                        "price": 199.99,
                        "quantity": 1
                    ],
                    [
                        "sku": "CASE-001",
                        "name": "Silicone Case",
                        "price": 50.00,
                        "quantity": 1
                    ]
                ]
            ]

            CleverTap.sharedInstance()?.recordEvent(
                "Order Completed",
                withProps: orderDetails as [String: AnyObject]
            )
            
        
        /*
            let epoch = Int(Date().timeIntervalSince1970) + 3600

            let props: [String: Any] = [
                "due_date_test2": "$D_1714206907"
            ]

            CleverTap.sharedInstance()?.recordEvent(
                "Reminder Test Event2",
                withProps: props
            )

            print("Event sent with due date: \(epoch)")
         */
        }
         
    func logoutFromCleverTap() {
        // 1. Apagar el push del perfil que cierra sesión.
        // MSG-push es una bandera a nivel de dispositivo: no afecta
        // a los demás dispositivos de ese usuario.
        CleverTap.sharedInstance()?.profilePush(["MSG-push": false])
        // 2. Cambiar a un perfil anónimo nuevo.
        guard CleverTapReset.switchToNewAnonymousUser() else {
            // Reportar al monitoreo: el dispositivo sigue en el perfil anterior.
            return
        }
        // 3. Habilitar el push en el perfil anónimo, para poder alcanzarlo
        // con campañas durante el onboarding.
        CleverTap.sharedInstance()?.profilePush(["MSG-push": true])
    }

}

#Preview {
    ContentView()
}
