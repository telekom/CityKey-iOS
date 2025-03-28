/*
 NotificationService.swift
 NotificationExtension
 
 Created by Michael on 17.01.20.
 Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
 
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 https://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 In accordance with Sections 4 and 6 of the License, the following exclusions apply:
 
 1. Trademarks & Logos – The names, logos, and trademarks of the Licensor are not covered by this License and may not be used without separate permission.
 2. Design Rights – Visual identities, UI/UX designs, and other graphical elements remain the property of their respective owners and are not licensed under the Apache License 2.0.
 3: Non-Coded Copyrights – Documentation, images, videos, and other non-software materials require separate authorization for use, modification, or distribution.
 
 These elements are not considered part of the licensed Work or Derivative Works unless explicitly agreed otherwise. All elements must be altered, removed, or replaced before use or distribution. All rights to these materials are reserved, and Contributor accepts no liability for any infringing use. By using this repository, you agree to indemnify and hold harmless Contributor against any claims, costs, or damages arising from your use of the excluded elements.
 
 SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Michael
 SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
 License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
 */

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
