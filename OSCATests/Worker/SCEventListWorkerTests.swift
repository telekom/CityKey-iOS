//
//  SCEventListWorkerTests.swift
//  SmartCityTests
//
//  Created by Alexander Lichius on 07.10.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCEventListWorkerTests: XCTestCase {

    func testStartEndDateURL() {
        //dateFormat = "yyyy-MM-dd"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let startDate =  dateFormatter.date(from: "2019-12-15")
        let endDate = dateFormatter.date(from: "2019-12-15")
        let cityID = 5
        let apiPath = "/api/city/content/events"
        let urlString = SCEventUrlHelper.urlPartStringFor(apiPath, cityID, "123", nil, nil, startDate, endDate, nil, "actionName")
        XCTAssertEqual(    "https://dev.api.smartcity.t-systems.net/api/city/content/events?cityId=5&eventId=123&start=2019-12-15&end=2019-12-15&actionName=actionName", urlString)
    }
    
    func testStartDateUrl() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let startDate =  dateFormatter.date(from: "2019-11-15")
        let cityID = 5
        let apiPath = "/api/city/content/events"
        let urlString = SCEventUrlHelper.urlPartStringFor(apiPath, cityID, "123", nil, nil, startDate, nil, nil, "actionName")
    XCTAssertEqual("https://dev.api.smartcity.t-systems.net/api/city/content/events?cityId=5&eventId=123&start=2019-11-15&actionName=actionName", urlString)
    }
    
    func testPagingUrl() {
        let cityID = 5
        let page = 5
        let pageSize = 10
        let apiPath = "/api/city/content/events"
        let urlString = SCEventUrlHelper.urlPartStringFor(apiPath, cityID, "123", page, pageSize, nil, nil, nil, "actionName")
    XCTAssertEqual("https://dev.api.smartcity.t-systems.net/api/city/content/events?cityId=5&eventId=123&pageNo=5&pageSize=10&actionName=actionName", urlString)
    }
    
//    func testPagingUrlWithCategories() {
//        let cityName = "Monheim am Rhein"
//        let categories = ["Musik", "Outdoor", "Open Air"]
//        let page = 5
//        let pageSize = 10
//        let apiPath = "/api/city/content/events"
//        let urlString = SCEventUrlHelper.urlPartStringFor(apiPath, cityName, page, pageSize, nil, nil, categories)
//        XCTAssertEqual("https://osca.all-ip.t-online.de/dev/api/city/content/events?cityName=Monheim%20am%20Rhein&pageNo=5&pageSize=10&categories=Musik&categories=Outdoor&categories=Open%20Air", urlString)
//    }

}
