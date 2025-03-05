/*
Created by Michael on 23.10.19.
Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

import UIKit
import MapKit
import TTGSnackbar

protocol SCEventDetailDisplaying: AnyObject, SCDisplaying  {
    func setupUI(navTitle : String,
                 title: String,
                 description: String,
                 endDate: Date,
                 startDate: Date,
                 hasEndTime: Bool,
                 hasStartTime: Bool,
                 imageURL: SCImageURL?,
                 latitude: Double,
                 longitude: Double,
                 locationName: String,
                 locationAddress: String,
                 imageCredit : String,
                 category : String,
                 pdf : [String]?,
                 link : String,
                 isFavorite: Bool,
                 eventStatus: EventStatus)
    
    func showMoreInfoOverlay(_ show : Bool)
    func isShowMoreInfoOverlayVisible() -> Bool
    func setEventMarkedAsFavorite(isFavorite: Bool)
    
    func showNeedsToLogin(with text : String, cancelCompletion: (() -> Void)?, loginCompletion: @escaping (() -> Void))
    func removeBlurView()
    func dismiss(completion: (() -> Void)?)
    func push(viewController: UIViewController)
    func present(viewController: UIViewController)
    func presentSnackBar(snackBarViewController: UIViewController, completion: (() -> Void)?)
    func presentFullImage(viewController: UIViewController)
    func hideMapView()

}

protocol SCEventDetailPresenting: SCPresenting {
    func setDisplay(_ display: SCEventDetailDisplaying)
    func closeButtonWasPressed()
    func shareButtonWasPressed()
    func moreLinkButtonWasPressed()
    func addToCalendardWasPressed()
    func favoriteButtonWasTapped()
    func imageViewWasTapped()
    func mapViewWasPressed(latitude: Double, longitude: Double, zoomFactor: Float, address: String)
    func directionsButtonWasPressed(latitude : Double, longitude : Double, address: String)
    func trackAdjustEvent(_ engagementOption: String)
    func refreshUI()
}


class SCEventDetailPresenter {
    
    weak private var display: SCEventDetailDisplaying?
    
    private let injector: SCEventDetailInjecting & SCToolsInjecting & SCAdjustTrackingInjection & SCDisplayEventInjecting
    private let event: SCModelEvent
    private let eventWorker: SCDashboardEventWorking
    private let worker: SCDetailEventWorking
    private let userCityContentSharedWorker: SCUserCityContentSharedWorking
    private var eventIsFavorite: Bool = false
    private let cityID : Int
    private let auth: SCAuthStateProviding
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private var isCityChanged: Bool
    private var cityId : Int?

    init(cityID: Int, event: SCModelEvent,
         eventWorker: SCDashboardEventWorking,
         injector: SCEventDetailInjecting & SCToolsInjecting & SCAdjustTrackingInjection & SCDisplayEventInjecting ,
         worker: SCDetailEventWorking,
         userCityContentSharedWorker: SCUserCityContentSharedWorking,
         userContentSharedWorker: SCUserContentSharedWorking,
         auth: SCAuthStateProviding = SCAuth.shared,
         cityContentSharedWorker: SCCityContentSharedWorking,
         isCityChanged: Bool = false,
         cityId: Int? = nil) {
        self.event = event
        self.eventWorker = eventWorker
        self.injector = injector
        self.worker = worker
        self.userCityContentSharedWorker = userCityContentSharedWorker
        self.cityID = cityID
        self.auth = auth
        self.cityContentSharedWorker = cityContentSharedWorker
        self.isCityChanged = isCityChanged
        self.cityId = cityId
        self.setupNotifications()
    }
    
    deinit {
        SCDataUIEvents.discardNotifications(for: self)
    }
        
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(favoritesDidChange), name: .didChangeFavoriteEventsDataState, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(favoritesDidChange), name: .userDidSignOut, object: nil)
        SCDataUIEvents.registerNotifications(for: self, on: .noLatLongFound, with: #selector(updateMapViewLayout))
    }
    
    @objc private func updateMapViewLayout() {
        self.display?.hideMapView()
    }
    
    @objc private func favoritesDidChange(notification: Notification) {
        if notification.name == .userDidSignOut {
            self.eventIsFavorite = false
            self.updateFavoriteStatus()
        } else if notification.userInfo == nil {
            self.updateFavoriteStatus()
            self.display?.setEventMarkedAsFavorite(isFavorite: self.eventIsFavorite)
        }
    }
    
    private func updateFavoriteStatus() {
        let favorites = userCityContentSharedWorker.getUserCityContentData()?.favorites
        if let favorites = favorites {
            for favorite in favorites {
                if favorite.uid == self.event.uid {
                    self.eventIsFavorite = true
                    return
                }
            }
            self.eventIsFavorite = false
        } else {
            self.display?.setEventMarkedAsFavorite(isFavorite: false)
        }
    }
    
    private func setupUI() {
        updateFavoriteStatus()
        self.display?.setEventMarkedAsFavorite(isFavorite: self.eventIsFavorite)
        self.display?.setupUI(navTitle: self.event.title,
                              title: self.event.title,
                              description: self.event.description,
                              endDate: dateFromString(dateString: self.event.endDate) ?? Date(),
                              startDate: dateFromString(dateString: self.event.startDate) ?? Date(),
                              hasEndTime: self.event.hasEndTime,
                              hasStartTime: self.event.hasStartTime,
                              imageURL: self.event.imageURL,
                              latitude: self.event.latitude,
                              longitude: self.event.longitude,
                              locationName: event.locationName,
                              locationAddress: event.locationAddress,
                              imageCredit: self.event.imageCredit,
                              category: self.event.categoryDescription,
                              pdf: self.event.pdf,
                              link: self.event.link,
                              isFavorite: self.eventIsFavorite,
                              eventStatus: EventStatus(rawValue: event.status?.uppercased() ?? "AVAILABLE") ?? .available)

    
    }
    
    private func toggleFavoriteState(newState: Bool) {
        
        if !auth.isUserLoggedIn() {
            self.display?.showNeedsToLogin(with: LocalizationKeys.SCEventDetailPresenter.dialogLoginRequiredMessage.localized(), cancelCompletion: {},loginCompletion: {
                let viewController = self.injector.getLoginViewController(dismissAfterSuccess: true, completionOnSuccess:{self.toggleFavoriteState(newState: newState)})
                self.display?.present(viewController: viewController)
            })
        } else {
            self.display?.setEventMarkedAsFavorite(isFavorite: newState)
            
            //BugFix: For appearance of favorite event twice
//            self.userCityContentSharedWorker.appendFavorite(event: self.event)
            self.worker.saveEventAsFavorite(cityID: self.cityID, eventId: Int(self.event.uid) ?? 0, markAsFavorite: newState) { (workerError) -> ()? in
                if workerError == nil {
                    if newState {
                        self.userCityContentSharedWorker.appendFavorite(event: self.event)
                        // SMARTC-13058 : Track additional events via Adjust - Events
                        // User marks an event as favorite
                        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.eventfavoriteMarked)
                        
                    } else {
                        self.userCityContentSharedWorker.removeFavorite(event: self.event)
                    }
                    self.userCityContentSharedWorker.triggerFavoriteEventsUpdate(errorBlock: { (error) in
                        
                    })
                    self.eventIsFavorite = !self.eventIsFavorite
                } else {
                    self.display?.setEventMarkedAsFavorite(isFavorite: !newState)
                    
                        let snackbar = TTGSnackbar(
                            message: LocalizationKeys.SCEventDetailPresenter.aMessageEventFavoredError.localized(),
                            duration: .middle
                        )
                        snackbar.setCustomStyle()
                        snackbar.show()
                }
                return nil
            }
        }
    }
    private func getCityName() -> String? {
        guard let cityId = cityId else {
            return nil
        }
        return cityContentSharedWorker.cityInfo(for: cityId)?.name
    }
    func showCityChangedSnackBar() {
        guard isCityChanged,
              let changedCityName = getCityName() else {
            return
        }
        isCityChanged = false // clearing deeplink info
        DispatchQueue.main.async {
            self.setupUI()
        }
        let snackbar = TTGSnackbar(
            message: "\(LocalizationKeys.SCEventDetailPresenter.e006EventSwitchCityInfo.localized()) \(changedCityName)",
            duration: .middle
        )
        snackbar.setCustomStyle()
        snackbar.show()
    }

}

extension SCEventDetailPresenter: SCPresenting {
    func viewDidLoad() {
        self.setupUI()
        handleDeeplink()
    }
    
    func handleDeeplink() {
        DispatchQueue.main.async {
            self.showCityChangedSnackBar()
        }
    }
    
    func viewWillAppear() {
    }
    
    func viewDidAppear() {
    }
}

extension SCEventDetailPresenter: SCMapViewDelegate {
    func mapWasTapped(latitude: Double, longitude: Double, zoomFactor: Float, address: String) {
        
    }
    
    func directionsBtnWasPressed(latitude : Double, longitude : Double, address: String){
        self.directionsButtonWasPressed(latitude : latitude, longitude : longitude, address: address)
    }
}

extension SCEventDetailPresenter : SCEventDetailPresenting {
    func imageViewWasTapped() {
        //use injector instatiate viewController, presenter
        if let imageURL = self.event.imageURL {
            let lightBoxController = self.injector.getEventLightBoxController(_with: imageURL, _and: self.event.imageCredit) as! SCEventLightBoxViewController
            lightBoxController.dismissDelegate = self
            self.display?.presentFullImage(viewController: lightBoxController)
        }
    }

    func favoriteButtonWasTapped() {
        //self.injector.trackEvent(eventName: "ClickAddEventToFavoritesBtn")
        self.toggleFavoriteState(newState: !self.eventIsFavorite)
    }

    func setDisplay(_ display: SCEventDetailDisplaying) {
        self.display = display
    }

    func shareButtonWasPressed() {
        //self.injector.trackEvent(eventName: "ClickEventShareBtn")

        let objectToShare = "\(event.title)\n\(event.link)\n\n\(LocalizationKeys.SCEventDetailPresenter.shareStoreHeader.localized())\n"
        SCShareContent.share(objects: [objectToShare], emailTitle: event.title, sourceRect: nil)
    }

    func closeButtonWasPressed() {
        if self.display?.isShowMoreInfoOverlayVisible() ?? false {
            self.display?.showMoreInfoOverlay(false)
        } else {
            self.display?.dismiss(completion: nil)
        }
    }

    func moreLinkButtonWasPressed(){
        if let urlToOpen = URL(string: event.link), UIApplication.shared.canOpenURL(urlToOpen) {
            SCInternalBrowser.showURL(urlToOpen, withBrowserType: .safari)
        }
    }
    
    func addToCalendardWasPressed(){
        //self.injector.trackEvent(eventName: "ClickAddEventToCalendarBtn")
        let successBlock = {
            let startDate = dateFromString(dateString: self.event.startDate) ?? Date()
            let endDate = self.event.hasEndTime ? dateFromString(dateString: self.event.endDate) ?? Date() : startDate.endOfDay
            
            SCCalendarHelper.shared.addEvent(title: self.event.title,
                                             url: self.event.link,
                                             startDate: startDate,
                                             endDate: endDate,
                                             note: self.event.description.stringWithoutHTML,
                                             location: self.event.locationAddress)
        }
        
        if !auth.isUserLoggedIn() {
            self.display?.showNeedsToLogin(with: "dialog_login_required_message", cancelCompletion: {},loginCompletion: {
                let viewController = self.injector.getLoginViewController(dismissAfterSuccess: true, completionOnSuccess: {successBlock()})
                self.display?.present(viewController: viewController)
            })
        } else {
            successBlock()
        }

    }

    func mapViewWasPressed(latitude: Double, longitude: Double, zoomFactor: Float, address: String){
        let mapNavigationController = self.injector.getEventDetailMapController(latitude: latitude, longitude: longitude, zoomFactor: zoomFactor, address: address, locationName: self.event.locationName, tintColor: kColor_cityColor) as! UINavigationController
        let mapController = mapNavigationController.viewControllers.first as! SCMapViewController
        mapController.delegate = self
        mapController.title = self.event.title
        self.display?.present(viewController: mapNavigationController)
    }

    func directionsButtonWasPressed(latitude : Double, longitude : Double, address: String) {
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = address
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }

    func trackAdjustEvent(_ engagementOption: String) {
        //MARK: Add "EventEngagement" event
       
        var parameters = [String:String]()
        parameters[AnalyticsKeys.TrackedParamKeys.citySelected] = kSelectedCityName
        parameters[AnalyticsKeys.TrackedParamKeys.cityId] = kSelectedCityId
        parameters[AnalyticsKeys.TrackedParamKeys.engagementOption] = engagementOption
        parameters[AnalyticsKeys.TrackedParamKeys.eventId] = event.uid
        parameters[AnalyticsKeys.TrackedParamKeys.userStatus] = SCAuth.shared.isUserLoggedIn() ? AnalyticsKeys.TrackedParamKeys.loggedIn : AnalyticsKeys.TrackedParamKeys.notLoggedIn
        if SCAuth.shared.isUserLoggedIn(), let userProfile = SCUserDefaultsHelper.getProfile() {
            parameters[AnalyticsKeys.TrackedParamKeys.userZipcode] = userProfile.postalCode
        }
        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.eventEngagement, parameters: parameters)
    }
    
    func refreshUI() {
        setupUI()
    }
}

extension SCEventDetailPresenter: SCEventLightBoxDismissDelegate {
    func dismissBlurView() {
        self.display?.removeBlurView()
    }
}

enum EventEngagementOption : String {
    case addToCalendar = "Add to calendar"
    case favorite = "Favorite"
    case email = "email"
    case website = "website"
    case call = "call"
    case directions = "directions"
    case print = "print"
    case share = "share"
    case moreInformation = "more information"
}
