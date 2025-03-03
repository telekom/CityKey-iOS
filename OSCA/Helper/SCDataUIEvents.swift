/*
Created by Michael on 14.11.18.
Copyright © 2018 Michael. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2018 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

/**
 * Extension to add new Notification names
 */

extension Notification.Name {

    static let didReceiveInfoBoxData = Notification.Name("didReceiveInfoBoxData")
    static let didChangeLocation = Notification.Name("didChangeLocation")
    static let didChangeUserInfoItems = Notification.Name("didChangeUserInfoItems")
    static let didReceiveTermsData = Notification.Name("didReceiveTermsData")

    static let cityContentLoadingFailed = Notification.Name("cityContentLoadingFailed")
    static let eventContentLoadingFailed = Notification.Name("eventContentLoadingFailed")
    static let citiesLoadingFailed = Notification.Name("citiesLoadingFailed")
    static let userDataLoadingFailed = Notification.Name("userDataLoadingFailed")
    static let infoBoxDataLoadingFailed = Notification.Name("infoBoxDataLoadingFailed")
    static let termsLoadingFailed = Notification.Name("impressumDataPrivacyLoadingFailed")

    static let didChangeServiceContentState = Notification.Name("didChangeServiceContentState")
    static let didChangeNewsContentState = Notification.Name("didChangeNewsContentState")
    static let didChangeUserDataState = Notification.Name("didChangeUserDataState")
    static let didChangeFavoriteEventsDataState = Notification.Name("didChangeFavoriteEventsDataState")
    
    static let didChangeAppointmentsDataState = Notification.Name("didChangeAppointmentsDataState")

    static let userDidSignIn = Notification.Name("userDidSignIn")
    static let userDidSignOut = Notification.Name("userDidSignOut")
    static let appMovedToForeground = Notification.Name("appMovedToForeground")

    static let isInitialLoadingFinished = Notification.Name("isInitialLoadingFinished")

    // new Notifications used by SCCityContentSharedWorker
    static let didChangeCityContent = Notification.Name("didChangeCityContent")

    // new Notifications used by SCCityContentSharedWorker to update fetch event status
    static let updateEventWorkerFetchState = Notification.Name("updateEventWorkerFetchState")

    static let didSetWasteReminderDataState = Notification.Name("didChangeAppointmentsDataState")
    
    // new Notifications used by SCBasicPOIGuideWorker
    static let didChangePOICategory = Notification.Name("didChangePOICategory")
    static let didChangePOI = Notification.Name("didChangePOI")

    // new Notifications for city not available
    static let cityNotAvailable = Notification.Name("cityNotAvailable")
    static let showCityNotAvailable = Notification.Name("showCityNotAvailable")
    
    
    // Notifications used by AusweisApp2 SDK Authentication Flow
    static let ausweisSDKServiceDidInititalise = Notification.Name( "SCAusweisAppSDKServiceDidInitialise")
    static let ausweisSDKServiceDidReceiveMessage = Notification.Name( "SCAusweisAppSDKServiceDidReceiveMessage")
    static let ausweisSDKServiceWorkflowDidFinishWithSuccess = Notification.Name("AUSWEIS_AUTH_WORKFLOW_DID_FINISH_WITH_SUCCESS")
    
    // new Notifications used by SCDefectReporterLocationViewController
    static let didChangeDefectLocation = Notification.Name("didChangeDefectLocation")
    
    static let noLatLongFound = Notification.Name("noLatLongFound")
    
    static let didLaunchPOI = Notification.Name("didLaunchPOI")
    static let didUpdatePOICategory = Notification.Name("didUpdatePOICategory")

    static let didUpdateAppPreviewMode = Notification.Name("didUpdateAppPreviewMode")
    static let didInfoBoxItemsLoaded = Notification.Name("didInfoBoxItemsLoaded")
    static let didShowToolTip = Notification.Name("didShowToolTip")
    static let launchScreenNoInternet = Notification.Name("launchScreenNoInternet")
    static let launchScreenRetry = Notification.Name("launchScreenRetry")

}

/**
 * Class for sending UIEvents when data are changed.
 * The UI should listen to those events to refresh all elements
 */
class SCDataUIEvents {
}

/**
 * SCDataUIEvents extension for registering to notifications
 */
extension SCDataUIEvents {
    
    
    /**
     *
     * Class method to register an Object for a Notification type
     *
     * @param object the object that registers for the notification type
     * @param object the the notification type which should call the object selector
     *        string shouldn't be localized, because the method will do this
     * @param selector when the registered notification type was posted, this selector on the object
     *          will be called.
     */
    static func registerNotifications(for object: Any, on event: NSNotification.Name, with selector: Selector ) {
        NotificationCenter.default.addObserver(object, selector: selector, name: event, object: nil)
    }
    
    
    /**
     *
     * Class method to unregister an Object from all notifications
     *
     * @param object the object that should be unregistered f
     */
    static func discardNotifications(for object : Any) {
        NotificationCenter.default.removeObserver(object)
    }

}

/**
 * SCDataUIEvents extension for posting notifications
 */
extension SCDataUIEvents {
    
    
    /**
     *
     * Class method to post a notification
     *
     * @event the notification type to post
     */
    static func postNotification(for event: NSNotification.Name) {
        NotificationCenter.default.post(
            name: event,
            object: nil,
            userInfo: nil)
    }

    static func postNotification(for event: NSNotification.Name, info: Any?) {

        NotificationCenter.default.post(
            name: event,
            object: nil,
            userInfo: info == nil ? nil : ["info": info!])
    }
}
