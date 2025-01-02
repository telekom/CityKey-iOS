//
//  SCDefectReporterSubCategoryPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 25/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCDefectReporterSubCategoryPresenterTests: XCTestCase {
    weak private var display: SCDefectReporterSubCategoryViewDisplay?
    private func prepareSut(serviceData: SCBaseComponentItem? = nil,
                            category: SCModelDefectCategory? = nil,
                            subCategory: [SCModelDefectSubCategory] = []) -> SCDefectReporterSubCategoryPresenter {
        let defaultServiceData = SCBaseComponentItem(itemID: "", itemTitle: "",
                                              itemHtmlDetail: false, itemColor: .blue)
        let presenter = SCDefectReporterSubCategoryPresenter(serviceData: serviceData ?? defaultServiceData,
                                                             injector: MockSCInjector(),
                                                             worker: SCDefectReporterWorkerMock(),
                                                             category: category ?? SCModelDefectCategory(serviceCode: "", serviceName: "", subCategories: [], description: nil),
                                                             subCategory: subCategory)
        return presenter
    }
    
    func testViewDidLoad() {
        let mockCategory = SCModelDefectCategory(serviceCode: "test", serviceName: "testName", subCategories: [], description: nil)
        let sut = prepareSut(category: mockCategory)
        let display = SCDefectReporterSubCategoryViewDisplayer()
        self.display = display
        sut.setDisplay(display)
        sut.viewDidLoad()
        XCTAssertEqual(mockCategory.serviceName, display.navTitle)
        XCTAssertTrue(display.subCategoryList.isEmpty)
    }
    
    func testDidSelectSubCategory() {
        let subCategory = SCModelDefectSubCategory(serviceCode: "test", serviceName: "TestName",
                                                   description: "", isAdditionalInfo: false)
        let sut = prepareSut()
        let display = SCDefectReporterSubCategoryViewDisplayer()
        self.display = display
        sut.setDisplay(display)
        sut.didSelectSubCategory(subCategory)
        XCTAssertTrue(display.isPresentCalled)
    }
}

class SCDefectReporterSubCategoryViewDisplayer: SCDefectReporterSubCategoryViewDisplay {
    private(set) var reloadCategoryListCalled: Bool = false
    private(set) var subCategoryList: [SCModelDefectSubCategory] = []
    private(set) var navTitle: String = ""
    private(set) var isPresentCalled: Bool = false
    private(set) var isPushCalled: Bool = false
    func reloadSubCategoryList(_ subCategoryList: [SCModelDefectSubCategory]) {
        self.subCategoryList = subCategoryList
    }
    
    func setNavigation(title: String) {
        self.navTitle = title
    }
    
    func push(viewController: UIViewController) {
        isPushCalled = true
    }
    
    func present(viewController: UIViewController) {
        isPresentCalled = true
    }
    
    
}
