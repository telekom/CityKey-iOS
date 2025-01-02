//
//  SCWasteCalendarWorker.swift
//  OSCA
//
//  Created by Michael on 27.08.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCWasteCalendarWorking {
    func getWasteCalendar(for cityId: Int,
                          street: String?,
                          houseNr: String?,
                          completion: @escaping (([SCModelWasteCalendarItem]?, SCModelWasteCalendarAddress?, [SCHttpModelWasteReminder], SCWorkerError?) -> Void))
    
    func searchStreetAndHouseNr(for cityId: Int,
                                filterString : String,
                                completion: @escaping (([SCModelWasteCalendarAddressResult]?, SCWorkerError?) -> Void))
     
    func getUserWasteAddress(for cityId: Int,
                                completion: @escaping ((SCModelWasteCalendarAddress?, SCWorkerError?) -> Void))

    func setCategories(_ categories : [SCModelCategoryObj]?)

    func setReminder(for cityId: Int, settings: SCHttpModelWasteReminder)
    
    func getWasteTypeForUser(for cityId: Int,
                             completion: @escaping ((SCModelWasteTypeIDs?, SCWorkerError?) -> Void))

    func saveWasteTypeForUser(for cityId: Int,
                              wasteTypeIds: [Int]?,
                              completion: @escaping ((_ successful: Bool, SCWorkerError?) -> Void))
    
    func getWasteCalendarCategoriesObj(for cityId: Int,
                                    completion: @escaping (([SCModelCategoryObj]?, SCWorkerError?) -> Void))

}

protocol SCWasteReminderWorking {
    var reminderDataState: SCWorkerDataState { get }
}

protocol SCWasteFilterWorking {
    func fetchCategoryList(cityID: Int, completion: @escaping (SCWorkerError?, [SCModelCategoryObj]?) -> ()?)
}

class SCWasteCalendarWorker: SCWorker {
    private let wasteCalendarApiPath = "/api/v2/smartcity/wasteCalendar"
    private var categories : [SCModelCategoryObj]?
    internal var reminderDataState = SCWorkerDataState()
}

extension SCWasteCalendarWorker: SCWasteCalendarWorking, SCWasteReminderWorking {
    //TODO: use this api to get all waste calendar details
    func getWasteCalendar(for cityId: Int,
                         street: String?,
                         houseNr: String?,
                         completion: @escaping (([SCModelWasteCalendarItem]?, SCModelWasteCalendarAddress?, [SCHttpModelWasteReminder], SCWorkerError?) -> Void)) {
        
        let queryDictionary = ["cityId": String(cityId),
                              "actionName": "POST_WasteCalendarData"] as [String : String]
        
        let url = GlobalConstants.appendURLPathToSOLUrl(path: self.wasteCalendarApiPath,
                                                       parameter: queryDictionary)

        var body : Data? = nil
        
        let bodyDict = ["streetName" : street ?? "", "houseNumber" : houseNr ?? ""] as [String : Any]
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: bodyDict, options: []) else {
            completion(nil, nil, [], SCWorkerError.technicalError)
            return
        }
        body = bodyData

        request.fetchData(from: url, method: "POST", body: body, needsAuth: true) { (result) in
            switch result {
            case .success(let fetchedData):
                do {
                    let wasteData = try JSONDecoder().decode(SCHttpModelResponse<SCHttpModelWasteCalendar>.self, from: fetchedData)
                    let wasteCalendar = wasteData.content
                    completion(wasteCalendar.calendar.map{ $0.toModel()}, wasteCalendar.address, wasteCalendar.reminders, nil)
                } catch {
                    completion(nil, nil, [], SCWorkerError.technicalError)
                }

            case .failure(let error):
                debugPrint("SCWasteCalendarWorker: requestFailed", error)
                completion(nil, nil, [], self.mapRequestError(error))
            }
        }

    }

    func searchStreetAndHouseNr(for cityId: Int,
                                filterString : String,
                                completion: @escaping (([SCModelWasteCalendarAddressResult]?, SCWorkerError?) -> Void)) {

        let queryDictionary = ["cityId": String(cityId),
                               "filterStr": filterString,
                               "actionName": "GET_StreetNameAndHouseNumber"] as [String : String]

        let url = GlobalConstants.appendURLPathToSOLUrl(path: self.wasteCalendarApiPath,
                                                       parameter: queryDictionary)

        request.fetchData(from: url, method: "GET", body: nil, needsAuth: false) { (result) in
            switch result {
            case .success(let fetchedData):
                do {
                    let resultData = try JSONDecoder().decode(SCHttpModelResponse<[SCModelWasteCalendarAddressResult]>.self, from: fetchedData)
                    completion(resultData.content, nil)
                } catch {
                    completion(nil, SCWorkerError.technicalError)
                }

            case .failure(let error):
                debugPrint("SCWasteCalendarWorker: requestFailed", error)
                completion(nil, self.mapRequestError(error))
            }
        }
    }

    func getUserWasteAddress(for cityId: Int,
                                completion: @escaping ((SCModelWasteCalendarAddress?, SCWorkerError?) -> Void)) {

        let queryDictionary = ["cityId": String(cityId),
                               "actionName": "GET_UserWasteAdd"] as [String : String]

        let url = GlobalConstants.appendURLPathToSOLUrl(path: self.wasteCalendarApiPath,
                                                       parameter: queryDictionary)

        request.fetchData(from: url, method: "GET", body: nil, needsAuth: true) { (result) in
            switch result {
            case .success(let fetchedData):
                do {
                    let resultData = try JSONDecoder().decode(SCHttpModelResponse<SCModelWasteCalendarAddress>.self, from: fetchedData)
                    completion(resultData.content, nil)
                } catch {
                    completion(nil, SCWorkerError.technicalError)
                }

            case .failure(let error):
                debugPrint("SCWasteCalendarWorker: requestFailed", error)
                completion(nil, self.mapRequestError(error))
            }
        }
    }

    func setCategories(_ categories : [SCModelCategoryObj]?) {
        self.categories = categories
    }

    func setReminder(for cityId: Int, settings: SCHttpModelWasteReminder) {
        let queryDictionary = ["cityId": String(cityId),
                               "actionName": "POST_WasteCalendarReminder"] as [String : String]

        let url = GlobalConstants.appendURLPathToSOLUrl(path: wasteCalendarApiPath,
                                                        parameter: queryDictionary)
        guard let body = try? JSONSerialization.data(withJSONObject: settings.getParameters(), options: []) else {
            return
        }

        request.fetchData(from: url, method: "POST", body: body, needsAuth: true) { (result) in
            switch result {
            case .success( _):
                self.reminderDataState.dataLoadingState = .fetchedWithSuccess

            case .failure( _):
                self.reminderDataState.dataLoadingState = .fetchFailed
            }

            SCDataUIEvents.postNotification(for: .didSetWasteReminderDataState)
        }
    }
    
    func saveWasteTypeForUser(for cityId: Int,
                       wasteTypeIds: [Int]?,
                       completion: @escaping ((_ successful: Bool, SCWorkerError?) -> Void)) {
        
        let queryDictionary = ["cityId": String(cityId),
                              "actionName": "PUT_WasteTypeForUser"] as [String : String]
        
        let url = GlobalConstants.appendURLPathToSOLUrl(path: self.wasteCalendarApiPath,
                                                       parameter: queryDictionary)

        var body : Data? = nil
        
        let bodyDict = ["wasteTypeIds": wasteTypeIds ?? []] as [String : Any]
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: bodyDict, options: []) else {
            completion(false, SCWorkerError.technicalError)
            return
        }
        body = bodyData

        request.fetchData(from: url, method: "PUT", body: body, needsAuth: true) { (result) in

            switch result {
            case .success(let fetchedData):
                do {
                    let resultData = try JSONDecoder().decode(SCHttpModelResponse<SCModelStoreWasteType>.self, from: fetchedData)
                    completion(resultData.content.isSuccessful, nil)
                } catch {
                    completion(false, SCWorkerError.technicalError)
                }

            case .failure(let error):
                debugPrint("SCWasteCalendarWorker: requestFailed", error)
                completion(false, self.mapRequestError(error))
            }
        }
    }
    //TODO: use this to get use selected waste types
    func getWasteTypeForUser(for cityId: Int,
                             completion: @escaping ((SCModelWasteTypeIDs?, SCWorkerError?) -> Void)) {
        
        let queryDictionary = ["cityId": String(cityId),
                              "actionName": "GET_UserWasteType"] as [String : String]
        
        let url = GlobalConstants.appendURLPathToSOLUrl(path: self.wasteCalendarApiPath,
                                                       parameter: queryDictionary)
        
        request.fetchData(from: url, method: "GET", body: nil, needsAuth: true) { (result) in
            switch result {
            case .success(let fetchedData):
                do {
                    let wasteTypeIds = try JSONDecoder().decode(SCHttpModelResponse<SCModelWasteTypeIDs>.self, from: fetchedData)
                    completion(wasteTypeIds.content, nil)
                } catch {
                    completion(nil, SCWorkerError.technicalError)
                }

            case .failure(let error):
                debugPrint("SCWasteCalendarWorker: requestFailed", error)
                completion(nil, self.mapRequestError(error))
            }
        }

    }
    
    func getWasteCalendarCategoriesObj(for cityId: Int,
                                       completion: @escaping (([SCModelCategoryObj]?, SCWorkerError?) -> Void)) {
       
        let queryDictionary = ["cityId": String(cityId),
                              "actionName": "GET_WasteTypeObj"] as [String : String]
        
        let url = GlobalConstants.appendURLPathToSOLUrl(path: self.wasteCalendarApiPath,
                                                       parameter: queryDictionary)

        request.fetchData(from: url, method: "GET", body: nil, needsAuth: false) { (result) in

            switch result {
            case .success(let fetchedData):
                do {
                    let categoryData = try JSONDecoder().decode(SCHttpModelResponse<[SCModelCategoryObj]>.self, from: fetchedData)
                    self.categories = categoryData.content
                    completion(self.categories, nil)
                } catch {
                    completion(nil, SCWorkerError.technicalError)
                }

            case .failure(let error):
                debugPrint("SCWasteCalendarWorker: requestFailed", error)
                completion(nil, self.mapRequestError(error))
            }
        }

    }
      
}

extension SCWasteCalendarWorker: SCWasteFilterWorking {
    
    func fetchCategoryList(cityID: Int, completion: @escaping (SCWorkerError?, [SCModelCategoryObj]?) -> ()?) {
        completion(nil, categories)
    }
}


