//
//  SCDefectReporterSubcategoryViewControllerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 25/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCDefectReporterSubcategoryViewControllerTests: XCTestCase {
    private func prepareSut(presenter: SCDefectReporterSubCategoryPresenting? = nil, serviceFlow: Services = .defectReporter) -> SCDefectReporterSubcategoryViewController {
        let storyboard = UIStoryboard(name: "DefectReporter", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "SCDefectReporterSubcategoryViewController") as! SCDefectReporterSubcategoryViewController
        sut.presenter = presenter ?? SCDefectReporterSubCategoryPresenerMock(serviceFlow: serviceFlow)
        sut.loadViewIfNeeded()
        return sut
    }
    
    func testViewDidLoad() {
        let presenter = SCDefectReporterSubCategoryPresenerMock()
        let sut = prepareSut(presenter: presenter)
        sut.viewDidLoad()
        guard let presenter = sut.presenter as? SCDefectReporterSubCategoryPresenerMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isViewDidLoadCalled)
    }
    
    func testViewWillAppear() {
        let mockBackButtonTitle = LocalizationKeys.Common.navigationBarBack.localized()
        let presenter = SCDefectReporterSubCategoryPresenerMock()
        let sut = prepareSut(presenter: presenter)
        sut.viewWillAppear(true)
        XCTAssertEqual(mockBackButtonTitle, sut.navigationItem.backButtonTitle)
    }
    
    func testReloadSubCategoryList() {
        let subCategory: [SCModelDefectSubCategory] = [SCModelDefectSubCategory(serviceCode: "test1", serviceName: "ServiceName1", description: "", isAdditionalInfo: false),
                                                       SCModelDefectSubCategory(serviceCode: "test2", serviceName: "serviceName2", description: "", isAdditionalInfo: false)]
        let sut = prepareSut()
        sut.reloadSubCategoryList(subCategory)
        XCTAssertEqual(subCategory, sut.subCategoryList)
    }
    
    func testSetNavigation() {
        let mockTitle = "test1"
        let sut = prepareSut()
        sut.setNavigation(title: mockTitle)
        XCTAssertEqual(sut.navigationItem.title, mockTitle)
    }
    
    func testNumberOfRows() {
        let mockCategoryList: [SCModelDefectSubCategory] = [SCModelDefectSubCategory(serviceCode: "", serviceName: "",
                                                                                     description: "", isAdditionalInfo: false)]
        let sut = prepareSut()
        sut.subCategoryList = mockCategoryList
        let count = sut.tableView(sut.tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(1, count)
    }
    
    func testTableViewCellForRow() {
        let mockCategoryList = [SCModelDefectSubCategory(serviceCode: "", serviceName: "",
                                                         description: "", isAdditionalInfo: false)]
        let sut = prepareSut()
        sut.subCategoryList = mockCategoryList
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertTrue(cell is SCDefectReporterCategoryCell)
    }
    
    func testCellSelection() {
        let mockCategoryList = [SCModelDefectSubCategory(serviceCode: "", serviceName: "",
                                                         description: "", isAdditionalInfo: false)]
        let sut = prepareSut()
        sut.subCategoryList = mockCategoryList
        sut.tableView(sut.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        guard let presenter = sut.presenter as? SCDefectReporterSubCategoryPresenerMock else {
            return
        }
        XCTAssertEqual(presenter.subCategory, mockCategoryList[0])
    }
}

class SCDefectReporterSubCategoryPresenerMock :SCDefectReporterSubCategoryPresenting {
    private(set) var subCategory: SCModelDefectSubCategory?
    private(set) var isViewDidLoadCalled: Bool = false
    var serviceFlow: Services
    
    init(serviceFlow: Services = .defectReporter) {
        self.serviceFlow = serviceFlow
    }
    func viewDidLoad() {
        isViewDidLoadCalled = true
    }
    
    func setDisplay(_ display: SCDefectReporterSubCategoryViewDisplay) {
        
    }
    
    func didSelectSubCategory(_ category: SCModelDefectSubCategory) {
        self.subCategory = category
    }
}
