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
