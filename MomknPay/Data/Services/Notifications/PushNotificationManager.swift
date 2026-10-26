//
//  PushNotificationManager.swift
//  MomknPay
//
//  Created by Mohamed Adel on 21/10/2026.
//

import UIKit
import FirebaseMessaging
import UserNotifications

class PushNotificationManager: NSObject {
    
    static let shared = PushNotificationManager()
    private override init() {}

    func configure(_ application: UIApplication) {
        
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                guard granted else { return }
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
    }
}

extension PushNotificationManager: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }
        print("FCM token:", fcmToken)

    }
}

extension PushNotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        
        [.banner, .sound, .badge]
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        let _ = response.notification.request.content.userInfo
    }
}
