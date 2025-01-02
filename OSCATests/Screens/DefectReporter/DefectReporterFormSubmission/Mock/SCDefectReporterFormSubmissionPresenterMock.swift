//
//  SCDefectReporterFormSubmissionPresenterMock.swift
//  OSCATests
//
//  Created by Bhaskar N S on 26/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

@testable import OSCA

class SCDefectReporterFormSubmissionPresenterMock: SCDefectReporterFormSubmissionPresenting {
    func showFeedbackLabel() -> Bool {
        return true
    }
    
    private(set) var isViewDidLoadCalled: Bool = false
    private(set) var isOkBtnWasPressedCalled: Bool = false
    var cityName: String = "Bad Honnef"
    func setDisplay(_ display: SCDefectReporterFormSubmissionViewDisplay) {
        
    }
    
    func okBtnWasPressed() {
        isOkBtnWasPressedCalled = true
    }
    
    func getCityName() -> String? {
        return cityName
    }
    
    func getCityId() -> Int {
        return 0
    }
    
    func viewDidLoad() {
        isViewDidLoadCalled = true
    }
    
    func getServiceFlow() -> Services {
        return .defectReporter
    }
}
