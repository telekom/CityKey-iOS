//
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
