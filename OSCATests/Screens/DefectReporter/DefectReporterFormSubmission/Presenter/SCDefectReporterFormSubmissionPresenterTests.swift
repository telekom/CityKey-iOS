//
//  SCDefectReporterFormSubmissionPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 26/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCDefectReporterFormSubmissionPresenterTests: XCTestCase {
    weak private var display: SCDefectReporterFormSubmissionViewDisplay?
    private func prepareSut(uniqueId: String? = nil,
                            category: SCModelDefectCategory? = nil,
                            subCategory: SCModelDefectSubCategory? = nil,
                            utitlies: SCUtilityUsable = SCUtilitiesMock(),
                            serviceFlow: Services = .defectReporter) -> SCDefectReporterFormSubmissionPresenter {
        let presenter = SCDefectReporterFormSubmissionPresenter(injector: MockSCInjector(),
                                                                cityContentSharedWorker: SCCityContentSharedWorkerMock(),
                                                                uniqueId: uniqueId ?? "123",
                                                                category: category ?? SCModelDefectCategory(serviceCode: "serviceCode",
                                                                                                            serviceName: "serviceName",
                                                                                                            subCategories: [SCModelDefectSubCategory(serviceCode: "",
                                                                                                                                                     serviceName: "",
                                                                                                                                                     description: "",
                                                                                                                                                     isAdditionalInfo: false)],
                                                                                                            description: nil),
                                                                subCategory: subCategory,
                                                                utitlies: utitlies, serviceFlow: serviceFlow, reporterEmailId: nil)
        return presenter
    }
    
    func testViewDidLoad() {
        let subCategory = SCModelDefectSubCategory(serviceCode: "subServiceCode",
                                                     serviceName: "subServiceName",
                                                     description: "",
                                                     isAdditionalInfo: false)
        let category = SCModelDefectCategory(serviceCode: "serviceCode",
                                             serviceName: "serviceName",
                                             subCategories: [SCModelDefectSubCategory(serviceCode: "",
                                                                                      serviceName: "",
                                                                                      description: "",
                                                                                      isAdditionalInfo: false)],
                                             description: nil)
        let uniqueId = "123"
        
        let sut = prepareSut(uniqueId: uniqueId, category: category, subCategory: subCategory)
        sut.viewDidLoad()
        XCTAssertEqual(sut.subCategory!.serviceName, "subServiceName")
        XCTAssertEqual(sut.category, category)
        XCTAssertEqual(sut.subCategory, subCategory)
    }
    
    func testGetCityName() {
        let sut = prepareSut()
        XCTAssertEqual("Bad Honnef", sut.getCityName())
    }
}

class SCDefectReporterFormSubmissionViewDisplayer: SCDefectReporterFormSubmissionViewDisplay {
    private(set) var navTitle: String = ""
    private(set) var category: SCModelDefectCategory?
    private(set) var subCategory: SCModelDefectSubCategory?
    private(set) var uniqueId: String = ""
    private(set) var isDismissCalled: Bool = false
    
    func setNavigation(title: String) {
        navTitle = title
    }
    
    func setupUI(category: SCModelDefectCategory, subCategory: SCModelDefectSubCategory?, uniqueId: String) {
        self.category = category
        self.subCategory = subCategory
        self.uniqueId = uniqueId
    }
    
    func dismiss(completion: (() -> Void)?) {
        isDismissCalled = true
    }
}
