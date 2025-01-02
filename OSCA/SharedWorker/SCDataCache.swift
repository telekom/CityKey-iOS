//
//  SCDataCache.swift
//  SmartCity
//
//  Created by Michael on 19.11.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCDataCaching {
    
    // Cached Data for WasteCalendar
    func wasteCalendarItems(for cityID: Int) -> [SCModelWasteCalendarItem]?
    func storeWasteCalendarItems(_ : [SCModelWasteCalendarItem], for cityID: Int)
    func getWasteCalendarAddress(cityID: Int) -> SCModelWasteCalendarAddress?
    func storeWasteCalendar(address: SCModelWasteCalendarAddress, for cityID: Int)

    // Cached filtered events for EventOverview
    func eventsOverviewData(for cityID: Int) -> SCEventsOverviewData?
    func storeEventOverviewData(eventOverviewData: SCEventsOverviewData, for cityID: Int)
    
    // Cached Barcode for MonheimPass
    func storeLibraryID(libraryId: SCModelBarcodeID, for userID: String)
    func getLibraryID(for userID: String) -> SCModelBarcodeID?


    // Cached visited survey for data privacy flag
    func isDataPrivacyAccepted(for surveyId: Int, cityID: String) -> Bool?
    func setDataPrivacyAccepted(for surveyId: Int, cityID: String)

    // clear complete cache
    func clearCache()

}

class SCDataCache: NSObject {

    private var wasteCalendarItems : [SCModelWasteCalendarItem]?
    private var wasteCalendarItemsCityID: Int?
    private var wasteCalendarAddress: SCModelWasteCalendarAddress?
    private var currentEventsOverviewData: SCEventsOverviewData?
    private var currentEventsOverviewDataCityID: Int?
    private var barcode: SCModelBarcodeID?
    private var barcodeUserID: String?
    private var citizenSurveyDict = [Int: Bool]()
    private var citizenSurveyCityID: String?
}

extension SCDataCache: SCDataCaching {

    func wasteCalendarItems(for cityID: Int) -> [SCModelWasteCalendarItem]?{
        if cityID != self.wasteCalendarItemsCityID {
            self.wasteCalendarItems = nil
        }

        return self.wasteCalendarItems
    }

    func storeWasteCalendarItems(_ wasteCalendarItems : [SCModelWasteCalendarItem], for cityID: Int) {
        self.wasteCalendarItems = wasteCalendarItems
        self.wasteCalendarItemsCityID = cityID
    }

    func getWasteCalendarAddress(cityID: Int) -> SCModelWasteCalendarAddress? {
        if cityID != wasteCalendarItemsCityID {
            return nil
        }
        return wasteCalendarAddress
    }

    func storeWasteCalendar(address: SCModelWasteCalendarAddress, for cityID: Int) {
        wasteCalendarAddress = address
        wasteCalendarItemsCityID = cityID
    }

    func eventsOverviewData(for cityID: Int) -> SCEventsOverviewData? {

        if cityID != self.currentEventsOverviewDataCityID {
            self.currentEventsOverviewData = nil
        }

        return self.currentEventsOverviewData
    }

    func storeEventOverviewData(eventOverviewData: SCEventsOverviewData, for cityID: Int) {
        self.currentEventsOverviewData = eventOverviewData
        self.currentEventsOverviewDataCityID = cityID
    }

    func storeLibraryID(libraryId: SCModelBarcodeID, for userID: String) {
        self.barcode = libraryId
        self.barcodeUserID = userID
    }

    func getLibraryID(for userID: String) -> SCModelBarcodeID? {
        if userID != self.barcodeUserID {
            self.barcode = nil
        }

        return self.barcode
    }

    func setDataPrivacyAccepted(for surveyId: Int, cityID: String) {
        citizenSurveyDict[surveyId] = true
        citizenSurveyCityID = cityID
    }

    func isDataPrivacyAccepted(for surveyId: Int, cityID: String) -> Bool? {
        if cityID != citizenSurveyCityID {
            citizenSurveyDict.removeAll()
        }
        return citizenSurveyDict[surveyId]
    }

    func clearCache() {
        self.currentEventsOverviewData = nil
        self.currentEventsOverviewDataCityID = nil
        self.barcode = nil
        self.barcodeUserID = nil
        citizenSurveyDict.removeAll()
    }
}
