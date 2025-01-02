//
//  WastCalendarRepository.swift
//  SCWidgetExtension
//
//  Created by Bhaskar N S on 11/08/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//
import Foundation
import UIKit

class WasteCalendarRepository {
    private let cityNewsApiPath = "/api/v2/smartcity/wasteCalendar"
    private let widgetUtility: WidgetUtility
    private let webServiceRequest: WebServiceUsable
    private let group: DispatchGroup
    private var wasteCalendarItemList: [SCModelWasteCalendarItem]?
    private var wasteCalendarAddress: SCModelWasteCalendarAddress?
    private var wasteReminderList: [SCHttpModelWasteReminder]?
    private var wasteTypeIds: SCModelWasteTypeIDs?
    private let authProvidier: AuthProviding
    
    init(widgetUtility: WidgetUtility = WidgetUtility(),
         webServiceRequest: WebServiceUsable = WebServiceRequest.shared,
         group: DispatchGroup = DispatchGroup(),
         authProvidier: AuthProviding = AuthProvider()) {
        self.widgetUtility = widgetUtility
        self.webServiceRequest = webServiceRequest
        self.group = group
        self.authProvidier = authProvidier
    }
    
    func notify(completionHandler: ((WasteCalendarDayWiseModel) -> Void)?) {
        group.notify(queue: .main) {
            guard let wasteCalendarItemList = self.wasteCalendarItemList,
                  let wasteTypeIds = self.wasteTypeIds else {
                completionHandler?(WasteCalendarDayWiseModel(isWasteCalendarConfigured: .error,
                                                             todayPickups: WasteCalendarPickup(day: "", wasteList: []),
                                                             tomorrowPickups: WasteCalendarPickup(day: "", wasteList: []),
                                                             dayAfterTomorrowPickups: WasteCalendarPickup(day: "", wasteList: [])))
                return
            }
            self.convertTo(wasteCalendarItems: wasteCalendarItemList,
                           filterCategories: wasteTypeIds.wasteTypeIds,
                           completionHandler: completionHandler)
        }
    }
    func getRecentWasteData(for cityId: Int, street: String?, houseNumber: String?, completionHandler:((WasteCalendarDayWiseModel) -> Void)?) {
        authProvidier.isUserLoggIn { [weak self] isLoggedIn in
            guard let strongSelf = self,
                  isLoggedIn else {
                SCFileLogger.shared.write("WasteCalendarWidget -> No AccessToken or No login -> getRecentWasteData", withTag: .logout)
                completionHandler?(WasteCalendarDayWiseModel(isWasteCalendarConfigured: .userNotLoggedIn,
                                                             todayPickups: WasteCalendarPickup(day: "", wasteList: []),
                                                             tomorrowPickups: WasteCalendarPickup(day: "", wasteList: []),
                                                             dayAfterTomorrowPickups: WasteCalendarPickup(day: "", wasteList: [])))
                
                return
            }
            strongSelf.getWasteCalendar(for: cityId, street: street, houseNr: houseNumber) { wasteCalendarList, address, reminderList, error in
                strongSelf.group.leave()
            }
            strongSelf.getWasteTypeForUser(for: cityId) { ids, error in
                strongSelf.wasteTypeIds = ids
                strongSelf.group.leave()
            }
            strongSelf.notify(completionHandler: completionHandler)
        }
    }
    
    func getWasteCalendar(for cityId: Int,
                         street: String?,
                         houseNr: String?,
                          completion: @escaping (([SCModelWasteCalendarItem]?, SCModelWasteCalendarAddress?, [SCHttpModelWasteReminder], Error?) -> Void)) {
        let apiPath = "/api/v2/smartcity/wasteCalendar?actionName=POST_WasteCalendarData&cityId=\(cityId)"
        guard let url = URL(string: widgetUtility.baseUrl(apiPath: apiPath)) else {
            return
        }
        
        var body: Data?
        
        let bodyDict = ["streetName" : street ?? "", "houseNumber" : houseNr ?? ""] as [String : Any]
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: bodyDict, options: []) else {
            completion(nil, nil, [], nil)
            return
        }
        body = bodyData
        group.enter()
        webServiceRequest.fetchData(from: url, method: "POST", body: body, needsAuth: true) { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let data):
                guard let data = data else { return }
                
                do {
                    let wasteData = try JSONDecoder().decode(SCHttpModelResponse<SCHttpModelWasteCalendar>.self, from: data)
                    let wasteCalendar = wasteData.content
                    SCFileLogger.shared.write("WasteCalendarWidget -> success response -> getWasteCalendar", withTag: .logout)
                    strongSelf.wasteCalendarItemList = wasteCalendar.calendar.map{ $0.toModel()}
                    strongSelf.wasteCalendarAddress = wasteCalendar.address
                    strongSelf.wasteReminderList = wasteCalendar.reminders
                    completion(wasteCalendar.calendar.map{ $0.toModel()}, wasteCalendar.address, wasteCalendar.reminders, nil)
                } catch let error as NSError {
                    SCFileLogger.shared.write("WasteCalendarWidget -> parsing failed -> getWasteCalendar", withTag: .logout)
                    completion(nil, nil, [], error)
                }
            case .failure(let error):
                SCFileLogger.shared.write("WasteCalendarWidget -> failed response \(error) -> getWasteCalendar", withTag: .logout)
                completion(nil, nil, [], error)
            }
        }
    }
    
    func getWasteTypeForUser(for cityId: Int,
                             completion: @escaping ((SCModelWasteTypeIDs?, NetworkError?) -> Void)) {
        let apiPath = "/api/v2/smartcity/wasteCalendar?cityId=\(cityId)&actionName=GET_UserWasteType"
        
        guard let url = URL(string: widgetUtility.baseUrl(apiPath: apiPath)) else {
            return
        }
        group.enter()
        webServiceRequest.fetchData(from: url, method: "GET", body: nil, needsAuth: true) { (result) in
            switch result {
            case .success(let fetchedData):
                guard let fetchedData = fetchedData else {
                    return
                }
                do {
                    let wasteTypeIds = try JSONDecoder().decode(SCHttpModelResponse<SCModelWasteTypeIDs>.self, from: fetchedData)
                    SCFileLogger.shared.write("WasteCalendarWidget -> success response -> getWasteTypeForUser", withTag: .logout)
                    completion(wasteTypeIds.content, nil)
                } catch {
                    SCFileLogger.shared.write("WasteCalendarWidget -> parsing fialed -> getWasteTypeForUser", withTag: .logout)
                    completion(nil, NetworkError.systemError(""))
                }

            case .failure(let error):
                SCFileLogger.shared.write("WasteCalendarWidget -> failure response \(error) -> getWasteTypeForUser", withTag: .logout)
                completion(nil, NetworkError.systemError(error.localizedDescription))
            }
        }

    }
    
    private func convertTo(wasteCalendarItems: [SCModelWasteCalendarItem], filterCategories: [Int], completionHandler: ((WasteCalendarDayWiseModel) -> Void)?) {
        let recentDays = getRecentThreeDates()
        let months = getMonthAssociatedWithDates()
        let rawItems = wasteCalendarItems.sorted{ $0.dateBaseString < $1.dateBaseString}
        var todayPickupList: [SCWasteCalendarItem] = []
        var tomorrowPickupList: [SCWasteCalendarItem] = []
        var dayAfterTomorrowPickupList: [SCWasteCalendarItem] = []
        var todayPickupStatus: String = "wc_no_pickups_scheduled".localized()
        var tomorrowPickupStatus: String = "wc_no_pickups_scheduled".localized()
        var dayAfterTomorrowPickupStatus: String = "wc_no_pickups_scheduled".localized()
        for item in rawItems {
            let itemPickupDate = stringFromDate(date: item.date)
            if itemPickupDate == recentDays.today {
                for wasteType in item.wasteTypeList {
                    todayPickupStatus = "wc_no_pickups_scheduled_filter_active".localized()
                    if filterCategories.contains(wasteType.wasteTypeId) {
                        
                        todayPickupList.append(SCWasteCalendarItem(dateBaseString: item.dateBaseString,
                                                                   dayHeader: false,
                                                                   itemName: wasteType.wasteType,
                                                                   color: UIColor(hex : wasteType.color),
                                                                   wasteTypeId: wasteType.wasteTypeId))
                    }
                }
            } else if stringFromDate(date: item.date) == recentDays.tomorrow {
                for wasteType in item.wasteTypeList {
                    tomorrowPickupStatus = "wc_no_pickups_scheduled_filter_active".localized()
                    if filterCategories.contains(wasteType.wasteTypeId) {
                        tomorrowPickupList.append(SCWasteCalendarItem(dateBaseString: item.dateBaseString,
                                                                      dayHeader: false,
                                                                      itemName: wasteType.wasteType,
                                                                      color: UIColor(hex : wasteType.color),
                                                                      wasteTypeId: wasteType.wasteTypeId))
                    }
                }
            } else if stringFromDate(date: item.date) == recentDays.dayAfterTomorrow {
                for wasteType in item.wasteTypeList {
                    dayAfterTomorrowPickupStatus = "wc_no_pickups_scheduled_filter_active".localized()
                    if filterCategories.contains(wasteType.wasteTypeId) {
                        dayAfterTomorrowPickupList.append(SCWasteCalendarItem(dateBaseString: item.dateBaseString,
                                                                              dayHeader: false,
                                                                              itemName: wasteType.wasteType,
                                                                              color: UIColor(hex : wasteType.color),
                                                                              wasteTypeId: wasteType.wasteTypeId))
                    }
                }
            }
        }
        todayPickupList.sort { $0.itemName < $1.itemName }
        tomorrowPickupList.sort { $0.itemName < $1.itemName }
        dayAfterTomorrowPickupList.sort { $0.itemName < $1.itemName }
        completionHandler?(WasteCalendarDayWiseModel(isWasteCalendarConfigured: .configured,
                                                     todayPickups: WasteCalendarPickup(day: "waste_calendar_today".localized(),
                                                                                       month: months.todayMonth,
                                                                                       wasteList: todayPickupList,
                                                                                      statusMessage: todayPickupStatus),
                                                     tomorrowPickups: WasteCalendarPickup(day: "waste_calendar_tomorrow".localized(),
                                                                                          month: months.tomorrowMonth,
                                                                                          wasteList: tomorrowPickupList,
                                                                                          statusMessage: tomorrowPickupStatus),
                                                     dayAfterTomorrowPickups: WasteCalendarPickup(day: getDayAfterTomrrowDate(dateString: recentDays.dayAfterTomorrow),
                                                                                                  month: months.dayAfterTomorrowMonth,
                                                                                                  wasteList: dayAfterTomorrowPickupList,
                                                                                                 statusMessage: dayAfterTomorrowPickupStatus)))
    }
    
    func getRecentThreeDates() -> (today: String, tomorrow: String, dayAfterTomorrow: String) {
        let today = fetchDate(day: .today)
        let tomorrow = fetchDate(day: .tomorrow)
        let dayAfterTomorrow = fetchDate(day: .dayAfterTomorrow)
        return (stringFromDate(date: today),
                stringFromDate(date: tomorrow),
                stringFromDate(date: dayAfterTomorrow))
    }
    
    func getMonthAssociatedWithDates() -> (todayMonth: String, tomorrowMonth: String, dayAfterTomorrowMonth: String) {
        let today = fetchDate(day: .today)
        let tomorrow = fetchDate(day: .tomorrow)
        let dayAfterTomorrow = fetchDate(day: .dayAfterTomorrow)
        return (monthFromDate(date: today),
                monthFromDate(date: tomorrow),
                monthFromDate(date: dayAfterTomorrow))
    }

    func fetchDate(day: WasteCalendarDay) -> Date {
        // Get right now as it's `DateComponents`.
        let now = Calendar.current.dateComponents(in: .current, from: Date())

        // Create the start of the day in `DateComponents` by leaving off the time.
        let today = DateComponents(year: now.year, month: now.month, day: now.day! + day.rawValue)
        let dateToday = Calendar.current.date(from: today)!
        return dateToday
    }
    
    func monthFromDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMM"
        return formatter.string(from: date)
    }

    func stringFromDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: date)
    }
    
    func dateFromString(stringDate: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/mm/yy"
        return formatter.date(from: stringDate) ?? Date()
    }
    
    func getDayAfterTomrrowDate(dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let date = formatter.date(from: dateString)

        let dispalyFormat = DateFormatter()
        dispalyFormat.dateFormat = "dd.MM.yy"
        return dispalyFormat.string(from: date!)
        
    }
}
