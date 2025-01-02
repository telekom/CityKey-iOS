//
//  SCEventWorker.swift
//  SmartCity
//
//  Created by Alexander Lichius on 25.09.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

class SCEventWorker: SCWorker {
    let apiPathEvents = "/api/v2/smartcity/event"
    
    var dashboardEventListDataState = SCWorkerDataState()
}

extension SCEventWorker: SCEventWorking {
    func fetchEventList(cityID: Int, eventId: String, page: Int?, pageSize: Int?, startDate: Date?, endDate: Date?, categories: [SCModelCategory]?, completion: @escaping (SCWorkerError?, SCModelEventList?) -> ()?) {
        
        let sol_page = (page != nil) ? page! + 1: nil
        
        let urlString = SCEventUrlHelper.urlPartStringFor(apiPathEvents, cityID, eventId, sol_page, pageSize, startDate, endDate, categories, "GET_Event")
        

        let url = URL(string: urlString)!
        
        request.fetchData(from: url, method: "GET", body: nil, needsAuth: false) { (result) in
            switch result {
            case .success(let fetchedData):
                do {
                    let items = try JSONDecoder().decode(SCHttpModelResponse<[SCHttpEventModel]>.self, from: fetchedData)
                    completion(nil, SCHttpEventModelResult.toEventModel(items.content))
                } catch {
                    completion(SCWorkerError.technicalError, nil)
                    NotificationCenter.default.post(name: .eventContentLoadingFailed, object: nil)
                }
                
                break
                
            case .failure(let error):
                let workerError = self.mapRequestError(error)
                NotificationCenter.default.post(name: .eventContentLoadingFailed, object: nil)
                completion(workerError, nil)
                break
            }
        }
    }
}
    

extension SCEventWorker: SCFilterWorking {
    
    func fetchCategoryList(cityID: Int, completion: @escaping (SCWorkerError?, [SCModelCategory]?) -> ()?) {
        let queries = ["cityId":String(cityID), "actionName": "GET_EventCategory"]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: apiPathEvents, parameter: queries)
        
        request.fetchData(from: url, method: "GET", body: nil, needsAuth: false) { (result) in
            switch result {
            case .success(let fetchedData):
                do {
                    let categories = try JSONDecoder().decode(SCHttpModelResponse<[SCHttpModelCategories]>.self, from: fetchedData)
                    completion(nil, SCHttpEventCategoriesResult.toCategoriesList(categories.content))
                } catch {
                    completion(SCWorkerError.technicalError, nil)
                }
                break
                
            case .failure(let error):
                let workerError = self.mapRequestError(error)
                completion(workerError, nil)
                break
            }
        }
    }
    
}

extension SCEventWorker: SCOverviewEventWorking {    

    func fetchEventListforOverview(cityID: Int, eventId: String, page: Int?, pageSize: Int?, startDate: Date?, endDate: Date?, categories: [SCModelCategory]?, completion: @escaping (SCWorkerError?, SCModelEventList?) -> ()?) {
        self.fetchEventList(cityID: cityID, eventId: eventId, page: page, pageSize: pageSize, startDate: startDate, endDate: endDate, categories: categories, completion: completion)
    }
    
    func fetchEventListCount(cityID: Int, eventId: String, startDate: Date?, endDate: Date?, categories: [SCModelCategory]?, completion: @escaping (SCWorkerError?, Int) -> ()?) {
        let urlString = SCEventUrlHelper.urlPartStringFor(apiPathEvents, cityID, eventId, nil, nil, startDate, endDate, categories, "GET_EventCount")
        let url = URL(string: urlString)!
        
        self.cancelRequests()
        
        cancelableRequest.fetchData(from: url, method: "GET", body: nil, needsAuth: false) { (result) in
            switch result {
            case .success(let fetchedData):
                do {
                    let itemCount = try JSONDecoder().decode(SCHttpModelResponse<Int>.self, from: fetchedData)
                    completion(nil, itemCount.content)
                    } catch {
                    completion(SCWorkerError.technicalError, 0)
                }
            case .failure(let error):
                let workerError = self.mapRequestError(error)
                completion(workerError, -1)
            }
        }
    }

}



extension SCEventWorker: SCDashboardEventWorking {
    func resetDashboardEventListDataState(){
        self.dashboardEventListDataState = SCWorkerDataState()
    }

    func fetchEventListForDashboard(cityID: Int, eventId: String, completion: @escaping (SCWorkerError?, SCModelEventList?) -> ()?) {
        
        self.dashboardEventListDataState.dataLoadingState = .fetchingInProgress
        
        self.fetchEventList(cityID: cityID, eventId: eventId, page: 0, pageSize: GlobalConstants.events_fetch_data_page_size, startDate: nil, endDate: nil, categories: nil, completion: {(error, eventlist) in
            
            if error != nil {
                switch error {
                case .fetchFailed(let errorDetails):
                    self.dashboardEventListDataState.dataLoadingState = SCWorkerDataLoadingState.getStateFor(errorCode : errorDetails.errorCode)
                default:
                    self.dashboardEventListDataState.dataLoadingState = .fetchFailed

                }

              } else {
                 self.dashboardEventListDataState.dataInitialized = true
                 self.dashboardEventListDataState.dataLoadingState = .fetchedWithSuccess
             }
            return completion(error, eventlist)
        })
    }
    
    func fetchEventForDetail(cityID: Int, eventId: String, completion: @escaping (SCWorkerError?, SCModelEventList?) -> ()?) {
//        self.dashboardEventListDataState.dataLoadingState = .fetchingInProgress
        
        self.fetchEventList(cityID: cityID, eventId: eventId, page: 0, pageSize: GlobalConstants.events_fetch_data_page_size, startDate: nil, endDate: nil, categories: nil, completion: {(error, eventlist) in
            guard error == error else {
                completion(error, nil)
                return nil
              }
            completion(nil, eventlist)
          return nil
        })
    }
}

extension SCEventWorker: SCDetailEventWorking {
    func saveEventAsFavorite(cityID: Int, eventId: Int, markAsFavorite: Bool, completion: @escaping (SCWorkerError?) -> ()?) {
        
        let queryDictionary = ["cityId": String(cityID), "actionName": "POST_EventFavorite", "eventId": String(eventId), "markFavorite": String(markAsFavorite)]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: apiPathEvents, parameter: queryDictionary)

        request.fetchData(from: url, method: "POST", body: nil, needsAuth: true)
            { (result) in
                switch result {
                    
                case .success:
                     completion(nil)
                     break
                case .failure(let error):
                    completion(self.mapRequestError(error))
            }
        }
    }
}
