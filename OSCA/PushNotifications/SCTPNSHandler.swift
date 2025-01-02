//
//  SCTPNSHandler.swift
//  OSCA
//
//  Created by A118572539 on 27/12/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCTPNSHandler: NSObject {
    private var pushRegisterd : Bool = false
    private var refreshHandler: SCSharedWorkerRefreshHandling
    private let privacySettingsProvider: SCAppContentPrivacySettingsOberserving
    private let worker: SCTPNSWorker
    static var pushDeviceToken : String?
    private var userID: String? = "-1"
    private var cityID: String? = "-1"
    private var additionalParameters: [String: String] = [:]
    
    static func isPushEnabled(completion: @escaping (_ enabled: Bool) ->()) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            completion (settings.authorizationStatus == .authorized)
        }
    }
    
    init(userIDProvider : SCUserContentUserIdentifing, privacySettingsProvider : SCAppContentPrivacySettingsOberserving, refreshHandler: SCSharedWorkerRefreshHandling, worker: SCTPNSWorker) {
        
        self.privacySettingsProvider = privacySettingsProvider
        self.refreshHandler = refreshHandler
        self.worker = worker
        super.init()
        // catch all USERID changes
        userIDProvider.observeUserID(completion: { [weak self] (userID) in
            guard let weakSelf = self else { return }
            weakSelf.userID = userID
            if userID == nil {
                weakSelf.userID = "-1"
                weakSelf.cityID = "-1"
            }
            
            if weakSelf.cityID != "-1" {
                weakSelf.refreshNotificationStatus()
            }
        })
        
        // catch all CITYID changes
        userIDProvider.observeCityID(completion: { [weak self] (cityID) in
            guard let weakSelf = self else { return }
            weakSelf.cityID = cityID
            if cityID == nil {
                weakSelf.userID = "-1"
                weakSelf.cityID = "-1"
            }
            
            if weakSelf.userID != "-1" {
                weakSelf.refreshNotificationStatus()
            }
        })
        
        // catch all privacy setting changes
        privacySettingsProvider.observePrivacySettings(completion: { [weak self ] (tpnsOptOut, adjustOptOut) in
            guard let weakSelf = self else { return }
            weakSelf.updatePushNotificationSetting(optOut: tpnsOptOut)
        })
    }
    
    internal func updatePushNotificationSetting(optOut: Bool){
        if optOut {
            worker.unRegisterForPush { successful, error in
                // handle response if any required
            }
        }
    }
    
    private func refreshNotificationStatus() {
        // When the user is not logged than we will not register again.
        if SCAuth.shared.isUserLoggedIn() {
            registerPushForApplication()
        }
    }
    
    private func saveAppVersionToDefaults () {
        UserDefaults.standard.set(self.getAppVersion(), forKey: "app version")
    }
    
    private func getAppVersion () -> AnyObject {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")! as AnyObject
    }
    
    private func getPushPriority(priority: String) -> SCPushNotificationPriority{
        switch priority.uppercased() {
        case "LOW":
            return .low
        case "MEDIUM":
            return .medium
        default:
            return .high
        }
    }
    
    private func setupAdditionalParameters() -> [String: String] {
        additionalParameters["CITY_ID"] = SCAuth.shared.isUserLoggedIn() ? cityID : "-1"
        additionalParameters["USER_ID"] = SCAuth.shared.isUserLoggedIn() ? userID : "-1"
        additionalParameters["USER_ACTIVE"] = (userID != "-1" && userID != nil) ? "true" : "false"
        return additionalParameters
    }
}

extension SCTPNSHandler: NotificationManagerDelegate {
    func initializeNotificationForApplication(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
    }
    
    func didRegisterForRemoteNotificationsWithDeviceToken(_ deviceToken: Data) {
        let token = deviceToken.reduce("", {$0 + String(format: "%02x", $1)})
        SCNotificationManager.shared.pushToken = token
        SCTPNSHandler.pushDeviceToken = token
    }
    
    func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
        
    }
    
    func registerPushForApplication() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            if error != nil {
                // Handle the error here.
            } else if granted, let weakSelf = self {
                    if let deviceToken = SCTPNSHandler.pushDeviceToken {
                        let parameters = weakSelf.setupAdditionalParameters()
                        weakSelf.worker.registerForPush(with: parameters, registrationID: deviceToken) { successful, error in
                            // handle response if any
                        }
                    }
                }
            }
        }
    
    func refreshNotificationStatusWithUserID(_ userid: String?) {
        
    }
    
    func refreshNotificatonStatusWithCityID(_ cityid: String?) {
        
    }
}

extension SCTPNSHandler: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        SCFileLogger.shared.write("TPNSHandler -> userNotificationCenter didReceive response : \(response.notification.description)", withTag: .logout)
        completionHandler()
        let userInfo = response.notification.request.content.userInfo
        if let deeplinkURL = userInfo["deeplink"] as? String {
            if !deeplinkURL.isEmpty {
                SCDeeplinkingHandler.shared.deeplinkWithUri(deeplinkURL)
            }
        }
        
        SCFileLogger.shared.write("TPNSHandler -> userNotificationCenter didReceive response -> self.refreshHandler.reloadUserInfoBox()  ", withTag: .logout)
        // refresh always the info box messages
        self.refreshHandler.reloadUserInfoBox()

    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if let priorityString = userInfo["oscaPriority"] as? String {
            let priority = self.getPushPriority(priority: priorityString)
            switch priority {
            case .high:
                completionHandler([.alert , .sound, .badge])
            case .medium:
                let state = UIApplication.shared.applicationState
                if state == .background || state == .inactive {
                    // background
                    completionHandler([.alert, .sound, .badge])
                } else if state == .active {
                    // foreground, no notification for medium priority on foreground
                }
            case .low:
                // no notification for Low priority
                break
            }
        }
        
        SCFileLogger.shared.write("TPNSHandler -> userNotificationCenter willPresent notification \(notification.description)", withTag: .logout)
        SCFileLogger.shared.write("TPNSHandler -> userNotificationCenter willPresent notification  -> self.refreshHandler.reloadUserInfoBox()  ", withTag: .logout)
        // refresh always the info box messages
        self.refreshHandler.reloadUserInfoBox()
    }
}
    
    
