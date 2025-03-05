/*
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/
//
//  SCUserCityContentSharedWorker.swift
//  SmartCity
//
//  Created by Alexander Lichius on 08.11.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol SCUserCityContentDeleting {
    func clearData()
}

protocol SCUserCityContentSharedWorking : SCUserCityContentDeleting {

    var favoriteEventsDataState: SCWorkerDataState { get }
    var appointmentsDataState: SCWorkerDataState { get }

    func getUserCityContentData() -> SCUserCityContentModel?
    func triggerFavoriteEventsUpdate(errorBlock: @escaping (SCWorkerError?)->())
    
    func appendFavorite(event: SCModelEvent)
    func removeFavorite(event: SCModelEvent)

    func markAppointmentsAsRead()
    func getAppointments() -> [SCModelAppointment]
    func update(appointments: [SCModelAppointment])
    func isAppointmentsDataAvailable() -> Bool
    func triggerAppointmentsUpdate(errorBlock: @escaping (SCWorkerError?) -> ())
}

class SCUserCityContentSharedWorker: SCWorker {
    private var favoriteEvents: [SCModelEvent]?
    
    private var contentForUserID: String?
    private var contentForCityID: Int = 0

    private var cityIdentifier: SCCityContentCityIdentifing
    private var userIdentifier: SCUserContentUserIdentifing

    internal var favoriteEventsDataState = SCWorkerDataState()
    internal var appointmentsDataState = SCWorkerDataState()

    private var appointments: [SCModelAppointment]
    private let appointmentWorker: SCAppointmentWorking

    init(requestFactory: SCRequestCreating, cityIdentifier: SCCityContentCityIdentifing, userIdentifier: SCUserContentUserIdentifing) {
        self.cityIdentifier = cityIdentifier
        self.userIdentifier = userIdentifier
        appointments = []
        appointmentWorker = SCAppointmentWorker(requestFactory: requestFactory)
        super.init(requestFactory: requestFactory)
    }
}

extension SCUserCityContentSharedWorker: SCUserCityContentSharedWorking {
    
    func getUserCityContentData() -> SCUserCityContentModel? {
        let cityID = self.cityIdentifier.getCityID()
        let userID = self.userIdentifier.getUserID()

        self.invalidateContentIfNeeded(cityID: cityID, userID: userID)
        return SCUserCityContentModel(favorites: self.favoriteEvents)
    }
    
    func appendFavorite(event: SCModelEvent) {
        if self.favoriteEvents == nil {
            self.favoriteEvents = []
        }
        self.favoriteEvents!.append(event)
        self.favoriteEventsDataStateDidChange()
    }
    
    func markAppointmentsAsRead() {
        
        for i in self.appointments.indices {
            self.appointments[i].isRead = true
        }

        NotificationCenter.default.post(name: .didChangeAppointmentsDataState, object: nil)
    }

    
    func removeFavorite(event: SCModelEvent) {
        guard self.favoriteEvents != nil, self.favoriteEvents!.count > 0 else { return }
        let eventId = event.uid
        self.favoriteEvents?.removeAll(where: { (event) -> Bool in
            event.uid == eventId
        })
        self.favoriteEventsDataStateDidChange()
    }
    
    func triggerFavoriteEventsUpdate(errorBlock: @escaping (SCWorkerError?) -> ()) {
        
        guard  self.favoriteEventsDataState.dataLoadingState != .fetchingInProgress  else {
            SCUtilities.delay(withTime: 0.0, callback: {errorBlock(nil)})
            
            return
        }
        
        let cityID = self.cityIdentifier.getCityID()
        let userID = self.userIdentifier.getUserID()

        self.invalidateContentIfNeeded(cityID: cityID, userID: userID)

        self.favoriteEventsDataState.dataLoadingState = .fetchingInProgress
        self.favoriteEventsDataStateDidChange()


        self.fetchFavoriteEvents(cityID: cityID) { (workerError, eventArray) in
            
            
            // only set favorite events when userid exists anymore
            if self.userIdentifier.getUserID() != nil {
                if workerError == nil {
                    self.favoriteEventsDataState.dataInitialized = true
                    self.favoriteEventsDataState.dataLoadingState = .fetchedWithSuccess
                    self.favoriteEvents = eventArray
                    self.favoriteEventsDataStateDidChange()
                    errorBlock(nil)
                } else {
                    errorBlock(workerError)
                    self.favoriteEventsDataState.dataLoadingState = .fetchFailed
                    self.favoriteEventsDataStateDidChange()
                }
            }
        }
    }

    func favoriteEventsDataStateDidChange() {
        NotificationCenter.default.post(name: .didChangeFavoriteEventsDataState, object: nil)
    }

    func clearData() {
        if self.favoriteEvents != nil {
            self.favoriteEvents = nil
            self.favoriteEventsDataState = SCWorkerDataState()
            self.favoriteEventsDataStateDidChange()
        }

        if appointments.count != 0 {
            appointments = []
            appointmentsDataState = SCWorkerDataState()
            postAppointmentsDateStateChange()
        }
    }

    func getAppointments() -> [SCModelAppointment] {
        return appointments
    }

    func isAppointmentsDataAvailable() -> Bool {
        return appointments.isEmpty == false
    }

    func triggerAppointmentsUpdate(errorBlock: @escaping (SCWorkerError?) -> ()) {
        guard  appointmentsDataState.dataLoadingState != .fetchingInProgress,
            let userID = userIdentifier.getUserID() else {
            SCUtilities.delay(withTime: 0.0, callback: {errorBlock(nil)})
            return
        }

        let cityID = cityIdentifier.getCityID()

        invalidateContentIfNeeded(cityID: cityID, userID: userID)
        appointmentsDataState.dataLoadingState = .fetchingInProgress

        appointmentWorker.getAppointments(for: "\(cityID)") {
            [weak self] (appointmentList, error) in

            if self?.userIdentifier.getUserID() != nil {
                if error == nil {
                    self?.appointmentsDataState.dataInitialized = true
                    self?.appointmentsDataState.dataLoadingState = .fetchedWithSuccess
                    self?.appointments = appointmentList ?? []
                    errorBlock(nil)
                } else {
                    self?.appointmentsDataState.dataLoadingState = .fetchFailed
                    errorBlock(error)
                }
            }
            self?.postAppointmentsDateStateChange()
            errorBlock(nil)
        }
    }

    private func postAppointmentsDateStateChange() {
        NotificationCenter.default.post(name: .didChangeAppointmentsDataState, object: nil)
    }

    func update(appointments: [SCModelAppointment]) {
        self.appointments = appointments
        postAppointmentsDateStateChange()
    }
}

extension SCUserCityContentSharedWorker {
    
    private func invalidateContentIfNeeded(cityID: Int, userID: String?) {
        if  cityID != self.contentForCityID || userID == nil || userID != self.contentForUserID {
            self.clearData()
            self.contentForCityID = cityID
            self.contentForUserID = userID
        }
    }
    
    private func fetchFavoriteEvents(cityID: Int, completion: @escaping (SCWorkerError?, [SCModelEvent]?) -> Void) {
        let apiPath = "/api/v2/smartcity/event"
        let queryDictionary = ["cityId": String(cityID), "actionName": "GET_EventFavorite"]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: apiPath, parameter: queryDictionary)
        
        request.fetchData(from: url, method: "GET", body: nil, needsAuth: true) { (response) in
            switch response {
            case .success(let fetchedData):
                do {
                    let httpModel = try JSONDecoder().decode(SCHttpModelResponse<[SCHttpEventModel]>.self, from: fetchedData)
                    let favorites = SCHttpEventModelResult.toEventModel(httpModel.content).eventList
                    completion(nil, favorites)
                } catch {
                    debugPrint("SCUserCityContentSharedWorker->fetchUserData: parsing failed with \(error) for endpoint \(url)")
                    SCFileLogger.shared.write("Harshada -> fetchFavoriteEvents | SCUserContentSharedWorker: requestFailed-> \(String(describing: error)) for \(url)", withTag: .logout)

                    completion(SCWorkerError.technicalError, nil)
                }
            case .failure(let error):
                debugPrint("SCUserContentSharedWorker->fetchUserData: request failed failed with \(error) for endpoint \(url)")
                SCFileLogger.shared.write("Harshada -> fetchFavoriteEvents | SCUserContentSharedWorker: requestFailed-> \(String(describing: error)) for \(url)", withTag: .logout)

                completion(self.mapRequestError(error), nil)
            }
        }
    }
}
