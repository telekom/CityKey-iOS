//
//  SCNotificationManager.swift
//  OSCA
//
//  Created by A118572539 on 27/12/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//


import UIKit

protocol NotificationManagerDelegate {
    
    /// method will initialize class responsible for push notifications
    func initializeNotificationForApplication(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    
    /// It will register push with APNS
    func registerPushForApplication()
    
    /// if userID changes than will refresh the notifications data with updated value
    func refreshNotificationStatusWithUserID(_ userid : String?)
    
    /// if cityID changes than will refresh the notifications data with updated value
    func refreshNotificatonStatusWithCityID(_ cityid : String?)
    
    /// when device token is available from APNS, this method will be called
    func didRegisterForRemoteNotificationsWithDeviceToken(_ deviceToken: Data)
    
    /// if while fetching device token we get some error than this method will be called
    func didFailToRegisterForRemoteNotificationsWithError(_ error: Error)
}

public enum SCPushNotificationPriority {
    case high
    case medium
    case low
}

class SCNotificationManager {
    
    static let shared = SCNotificationManager()
    
    // Push token for the device in String form, use this value to send to backend server
    var pushToken: String?
    
    func isPushEnabled(completion: @escaping (_ enabled: Bool) ->()) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            completion (settings.authorizationStatus == .authorized)
        }
    }
    
    private init() {
        // intialize values if required
    }
}
