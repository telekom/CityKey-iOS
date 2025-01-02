//
//  SCDataUIEvents.swift
//  SmartCity
//
//  Created by Michael on 14.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

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
