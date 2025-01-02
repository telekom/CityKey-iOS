//
//  NotificationService.swift
//  NotificationExtension
//
//  Created by Michael on 17.01.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//


import UserNotifications
// 1st Step
//import MORichNotification

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
    
        // 2nd Step
//        if let appGroupID = Bundle.main.infoDictionary?["SCMoEngageAppGroup"] as? String {
//            MORichNotification.setAppGroupID(appGroupID)
//        }
//
//        // 3rd Step
//        //Handle Rich Notification
//        self.contentHandler = contentHandler
//        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
//        var count: Int = UserDefaults(suiteName: WidgetUtility().getAppGroupId())?.value(forKey: "count") as! Int
//        if let bestAttemptContent = bestAttemptContent {
//            bestAttemptContent.title = "\(bestAttemptContent.title) "
//            bestAttemptContent.body = "\(bestAttemptContent.body) "
//            count = count + 1
//            bestAttemptContent.badge = count as NSNumber
//            UserDefaults(suiteName: WidgetUtility().getAppGroupId())?.set(count, forKey: "count")
//            contentHandler(bestAttemptContent)
//        }
//        MORichNotification.handle(request, withContentHandler: contentHandler)

//        // To Increase badge count
//        MORichNotification.updateBadge(with: bestAttemptContent)
//        
//        // 3rd Step
//        MORichNotification.getAttachmentFrom(request) { (attachment) in
//            if let att = attachment {
//                self.bestAttemptContent?.attachments = [att]
//            }
//            
//            if let bestAttemptContent = self.bestAttemptContent {
//                contentHandler(bestAttemptContent)
//            }
//        }

    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
