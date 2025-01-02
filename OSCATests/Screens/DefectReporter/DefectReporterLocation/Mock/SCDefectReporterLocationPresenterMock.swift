//
//  SCDefectReporterLocationPresenterMock.swift
//  OSCATests
//
//  Created by Bhaskar N S on 22/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

@testable import OSCA
class SCDefectReporterLocationPresenterMock: SCDefectReporterLocationPresenting {
    var serviceFlow: Services
    private(set) var isViewDidLoadCalled: Bool = false
    private(set) var isViewWillLoadCalled: Bool = false
    private(set) var isCloseButtonCalled: Bool = false
    private(set) var isSaveLocationCalled: Bool = false
    init(serviceFlow: Services = .defectReporter) {
        self.serviceFlow = serviceFlow
    }
    func setDisplay(_ display: SCDefectReporterLocationViewDisplay) {
        
    }
    
    func closeButtonWasPressed() {
        isCloseButtonCalled = true
    }
    
    func savePositionBtnWasPressed() {
        isSaveLocationCalled = true
    }
    
    func viewDidLoad() {
        isViewDidLoadCalled = true
    }
    
    func viewWillAppear() {
        isViewWillLoadCalled = true
    }
}
