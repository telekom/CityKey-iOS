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
*///
//  SCAppointmentWorkerTests.swift
//  OSCATests
//
//  Created by Rutvik Kanbargi on 23/07/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCAppointmentWorkerTests: XCTestCase {

    var sut: SCAppointmentWorking?

    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}

    
    func test_getAppointmentReturnsSuccess_withEmptyAppointment() {
        let expect = expectation(description: "empty response")
        sut = SCAppointmentWorker(requestFactory: MockRequest(json: emptyResponseJson))
        sut?.getAppointments(for: "", completion: { (appointment, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(appointment)
            XCTAssertEqual(appointment?.count, 0)
            expect.fulfill()
        })
        
        waitForExpectations(timeout: 2.0) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func test_getAppointmentReturnsSuccess_withOneAppointment() {
        let expect = expectation(description: "empty response")
        sut = SCAppointmentWorker(requestFactory: MockRequest(json: successResponseJson))
        sut?.getAppointments(for: "", completion: { (appointment, error) in
            XCTAssertNil(error)
            XCTAssertEqual(appointment?.count, 1)
            XCTAssertEqual(appointment?.first?.apptStatus, AppointmentStatus.confirmed)
            XCTAssertEqual(appointment?.first?.street, "Continentalstraße 44")
            XCTAssertEqual(appointment?.first?.place, "08766 Hockenheim")
            expect.fulfill()
        })
        
        waitForExpectations(timeout: 2.0) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func test_getAppointmentReturnsFailure() {
        let expect = expectation(description: "empty response")
        sut = SCAppointmentWorker(requestFactory: MockRequest(json: failureResponseJson))
        sut?.getAppointments(for: "", completion: { (appointment, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(appointment)
            expect.fulfill()
        })
        
        waitForExpectations(timeout: 2.0) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}


private class MockRequest: SCRequestCreating {

    private let json: String

    init(json: String) {
        self.json = json
    }

    func createRequest() -> SCDataFetching {
        MockDataFetching(json: json)
    }
}

private class MockDataFetching: SCDataFetching {

    private let json: String

    init(json: String) {
        self.json = json
    }

    func fetchData(from url: URL, method: String, body: Data?, needsAuth: Bool, completion: @escaping ((SCRequestResult) -> ())) {

        let data = Data(json.utf8)
        do {
            let appointmentData = try JSONDecoder().decode(SCHttpModelResponse<[SCHttpModelAppointment]>.self, from: data)
            _ = appointmentData.content.map { $0.toModel() }
            completion(.success(data))
        } catch {
            let error = SCRequestError.requestFailed(400, SCRequestErrorDetails(errorCode: "", userMsg: "Failed to parse the data", errorClientTrace: ""))
            completion(.failure(error))
        }
    }
    
    func uploadData(from url: URL, method: String, body: Data?, needsAuth: Bool, additionalHeaders: [String : String], completion: @escaping ((SCRequestResult) -> ())) {
        
    }
    
    func cancel() {}
}

private let emptyResponseJson = """
{
    "content": []
}
"""
private let failureResponseJson = """
{
    "content": {"err" : "error"}
}
"""

private let successResponseJson = """
{
    "content": [
            {
                "title":"Appointment title",
                "apptStatus":"bestätigung",
                "uuid":"7e1038bc-1ad3-4da5-8347-82a10aee9c92",
                "waitingNo":"8366",
                "isRead": true,
                "startTime":"2020-04-15 10:00:00",
                "endTime":"2020-04-15 11:45:00",
                "notes":"Addition details",
                "reason":[{
                            "sNumber":1,
                            "description":"Bugatti Veyron"
                        },
                        {
                            "sNumber":2,
                            "description":"sample reason"
                        }],
                "documents":[
                            "Führerschein",
                            "Personalausweis"
                            ],
                "contacts":{
                            "description":"KFZ",
                            "email":"kfz@musterstadt.de",
                            "telefon":"0231556677",
                            "notes":""
                            },
                "attendee":[{
                            "firstName":"Testvin",
                            "lastName":"Siedeltest"
                            }],
                "location":{
                            "description":"Hockenheimring",
                            "street":"Continentalstraße",
                            "houseNumber":"44",
                            "postalCode":"08766",
                            "place":"Hockenheim"
                            }
                }
        ]
}
"""
