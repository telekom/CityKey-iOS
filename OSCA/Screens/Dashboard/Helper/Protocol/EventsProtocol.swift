//
//  EventsProtocol.swift
//  OSCA
//
//  Created by Bhaskar N S on 09/06/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol SCEventWorking {
    func fetchEventList(cityID: Int, eventId: String, page: Int?, pageSize: Int?, startDate: Date?, endDate: Date?, categories: [SCModelCategory]?, completion: @escaping (SCWorkerError?, SCModelEventList?) -> ()?)
}

protocol SCFilterWorking {
    func fetchCategoryList(cityID: Int, completion: @escaping (SCWorkerError?, [SCModelCategory]?) -> ()?)
}

protocol SCOverviewEventWorking {
    func fetchEventListforOverview(cityID: Int, eventId: String, page: Int?, pageSize: Int?, startDate: Date?, endDate: Date?, categories: [SCModelCategory]? , completion: @escaping (SCWorkerError?, SCModelEventList?) -> ()?)
    func fetchEventListCount(cityID: Int, eventId: String, startDate: Date?, endDate: Date?, categories:[SCModelCategory]?, completion: @escaping (SCWorkerError?, Int) -> ()?)
}

protocol SCDashboardEventWorking {
    var dashboardEventListDataState: SCWorkerDataState { get }
    func resetDashboardEventListDataState()
    func fetchEventListForDashboard(cityID: Int, eventId: String, completion: @escaping (SCWorkerError?, SCModelEventList?) -> ()?)
    func fetchEventForDetail(cityID: Int, eventId: String, completion: @escaping (SCWorkerError?, SCModelEventList?) -> ()?)

}

protocol SCDetailEventWorking {
    func saveEventAsFavorite(cityID: Int, eventId: Int, markAsFavorite: Bool, completion: @escaping (SCWorkerError?) -> ()?)
}
