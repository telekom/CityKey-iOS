//
//  SCDefectReporterCategorySelectionPresenterMock.swift
//  OSCATests
//
//  Created by Bhaskar N S on 25/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

@testable import OSCA

class SCDefectReporterCategorySelectionPresenterMock: SCDefectReporterCategorySelectionPresenting {
    var serviceFlow: Services
    private(set) var category: SCModelDefectCategory?
    private(set) var isViewDidLoadCalled: Bool = false
    private(set) var categoryList: [SCModelDefectCategory]? = []
    
    init(serviceFlow: Services = .defectReporter) {
        self.serviceFlow = serviceFlow
    }
    
    init(categoryList: [SCModelDefectCategory]? = nil, serviceFlow: Services = .defectReporter) {
        self.categoryList = categoryList
        self.serviceFlow = serviceFlow
    }
    func setDisplay(_ display: SCDefectReporterCategorySelectionViewDisplay) {
        
    }
    
    func didSelectCategory(_ category: SCModelDefectCategory) {
        self.category = category
    }
    
    func viewDidLoad() {
        isViewDidLoadCalled = true
    }
}
