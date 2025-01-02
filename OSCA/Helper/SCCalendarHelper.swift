//
//  SCCalendarHelper.swift
//  SmartCity
//
//  Created by Michael on 30.10.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

enum CalendarEventSaveState {
    case saved
    case notSaved
    case alreadyExist
    case unknown
}


/**
 * This class contains class methods for interacting with the calendar
 */

class SCCalendarHelper: NSObject {

    public static let shared = SCCalendarHelper()
    
    private let eventStore = EKEventStore()


    override init() {
        super.init()
    }
    
    func askForPermissions(completion: @escaping (() -> Void)){

        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            DispatchQueue.main.async {
              completion()
            }
        case .denied:
            // When we have have no permission, then we should present an info dialog
            let alertController = UIAlertController(title: "c_001_cities_dialog_gps_title".localized(), message: "dialog_calendar_permission_denied".localized(), preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "dialog_button_ok".localized(), style: .default)
            let settingsAction = UIAlertAction(title: "c_001_cities_cannot_access_location_btn_poitive".localized(), style: .default) { (action:UIAlertAction!) in
                
                if let url = URL(string:UIApplication.openSettingsURLString) {
                    
                    // this would be the path to the privacy settings
                    // but it seems like we cant distinguish
                    // "app permission disabled" from "location services disabled"
                    // let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION") {
                    
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
            SCUtilities.topViewController().present(alertController, animated: true, completion:nil)
            
        case .notDetermined:
            // 3
            eventStore.requestAccess(to: .event, completion:
                {(granted: Bool, error: Error?) -> Void in
                    if granted {
                        DispatchQueue.main.async {
                          completion()
                        }
                    } else {
                        print("Access denied")
                    }
            })
        default:
            // When we have have no permission, then we should present an info dialog
            let alertController = UIAlertController(title: "c_001_cities_dialog_gps_title".localized(), message: "dialog_calendar_permission_denied".localized(), preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "dialog_button_ok".localized(), style: .default)
            let settingsAction = UIAlertAction(title: "c_001_cities_cannot_access_location_btn_poitive".localized(), style: .default) { (action:UIAlertAction!) in
                
                if let url = URL(string:UIApplication.openSettingsURLString) {
                    
                    // this would be the path to the privacy settings
                    // but it seems like we cant distinguish
                    // "app permission disabled" from "location services disabled"
                    // let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION") {
                    
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)
            SCUtilities.topViewController().present(alertController, animated: true, completion:nil)
        }

    }
    
    private func insertEvent(title: String, url: String, startDate: Date, endDate: Date, note: String, location: String){
        let event = EKEvent(eventStore: self.eventStore)
        
        event.title = title
        event.url = URL(string: url)
        event.startDate = startDate
        event.endDate = endDate
        event.location = location
        event.notes = note

        let eventModalVC = EKEventEditViewController()
        eventModalVC.event = event
        eventModalVC.eventStore = eventStore
        eventModalVC.editViewDelegate = self
        
        SCUtilities.topViewController().present(eventModalVC, animated: true, completion: nil)
    }
    
    private func insertEventInCalendar(calendar: EKCalendar, title: String, url: String, startDate: Date, endDate: Date, note: String, location: String) -> CalendarEventSaveState {
        let newEvent = EKEvent(eventStore: self.eventStore)
        
        newEvent.title = title
        newEvent.url = URL(string: url)
        newEvent.startDate = startDate
        newEvent.endDate = endDate
        newEvent.isAllDay = true
        newEvent.location = location
        newEvent.notes = note
        newEvent.calendar = calendar
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let existingEvents = eventStore.events(matching: predicate)
        
        let eventAlreadyExists = existingEvents.contains(where: {event in newEvent.title == event.title && newEvent.startDate == event.startDate && newEvent.endDate == event.endDate})
        
        // Matching event found, don't add it again, just display alert
        if eventAlreadyExists {
            return .alreadyExist
        } else {
            do {
                try eventStore.save(newEvent, span: .thisEvent)
                return .saved
            } catch let error as NSError {
                return .notSaved
            }
        }
    }
    
    /**
     *
     * Method to add a calendar event
     *
     * @param title for the shared message
     * @param url to share
     * @param startDate Date when the calendar entry should start
     * @param endDate Date when the calendar entry should end
     * @param note Any Notes for the event
     * @param note Location of the event
     */
    
    func addEvent(title: String, url: String, startDate: Date, endDate: Date, note: String, location: String) {
        self.askForPermissions {
            self.insertEvent(title: title, url: url, startDate: startDate, endDate: endDate, note: note, location: location)
        }
    }
    
    func addEventToCalendar(calendar: EKCalendar, title: String, url: String, startDate: Date, endDate: Date, note: String, location: String) -> CalendarEventSaveState {
        let saveState = self.insertEventInCalendar(calendar: calendar, title: title, url: url, startDate: startDate, endDate: endDate, note: note, location: location)
        return saveState
    }
    
    func getExistingCalendars() -> [EKCalendar] {
        return eventStore.calendars(for: .event).filter { calendar in
            calendar.allowsContentModifications == true
        }
    }
    
    func getDefaultCalendar() -> EKCalendar? {
        return eventStore.defaultCalendarForNewEvents
    }
    
    func createNewCalendar(for type: EKEntityType, title: String, color: CGColor) -> EKCalendar {
        let newCalendar = EKCalendar(for: type, eventStore: eventStore)
        newCalendar.title = title
        newCalendar.cgColor = color
        guard let source = bestPossibleEKSource() else {
            return EKCalendar()// source is required, otherwise calendar cannot be saved
        }
        newCalendar.source = source
        
        do {
            try? eventStore.saveCalendar(newCalendar, commit: true)
        }
        return newCalendar
    }
    
    func bestPossibleEKSource() -> EKSource? {
        let sourcesInEventStore = eventStore.sources
        let filteredEventStores = sourcesInEventStore.filter{
            (source: EKSource) -> Bool in
            source.sourceType.rawValue == EKSourceType.local.rawValue || source.title.elementsEqual("iCloud")
        }
        if filteredEventStores.count > 0 {
            return filteredEventStores.first!
        } else {
            return sourcesInEventStore.filter{
                (source: EKSource) -> Bool in
                source.sourceType.rawValue == EKSourceType.subscribed.rawValue
            }.first!
        }
    }
    
    func getCalendarChooser() -> UIViewController {
        let vc = EKCalendarChooserCustom(selectionStyle: .single, displayStyle: .writableCalendarsOnly, entityType: .event, eventStore: eventStore)
        return vc
    }
}

extension SCCalendarHelper: EKEventEditViewDelegate {
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
    }
}
