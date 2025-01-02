//
//  CityContentRepository.swift
//  OSCA
//
//  Created by Bhaskar N S on 04/05/23.
//  Copyright © 2023 Deutsche Telekom AG - VTI Organization. All rights reserved.
//
import Foundation
class CityContentRepository {
    private let webServiceRequest: WebServiceUsable
    private let widgetUtility: WidgetUtility
    
    init(webServiceRequest: WebServiceUsable = WebServiceRequest.shared,
         widgetUtility: WidgetUtility = WidgetUtility()) {
        self.webServiceRequest = webServiceRequest
        self.widgetUtility = widgetUtility
    }
    
    func fetchCitites(completionHandler: @escaping ([CityModel]?, Error?) -> Void) {
        #if INT
            let cityID = "10"
        #else
            let cityID = "8"
        #endif
        let apiPath = "/api/v2/smartcity/city/cityService?actionName=GET_AllCities&cityId=\(cityID)"
        guard let url = URL(string: widgetUtility.baseUrl(apiPath: apiPath)) else {
            return
        }
        webServiceRequest.fetchData(from: url, method: "GET", body: nil, needsAuth: false) { result in
            switch result {
            case .success(let fetchedData):
                guard let fetchedData = fetchedData else {
                    return
                }
                do {
                    let cities = try JSONDecoder().decode(CitiesModel.self, from: fetchedData)
                    completionHandler(cities.content, nil)
                } catch let error {
                    completionHandler(nil, NetworkError.systemError(error.localizedDescription))
                }

            case .failure(let error):
                completionHandler(nil, NetworkError.systemError(error.localizedDescription))
            }
        }
    }
}
