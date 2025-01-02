//
//  SCDefectReporterCategorySelectionViewControllerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 25/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA
class SCDefectReporterCategorySelectionViewControllerTests: XCTestCase {

    private func prepareSut(presenter: SCDefectReporterCategorySelectionPresenting? = nil) -> SCDefectReporterCategorySelectionViewController {
        let storyboard = UIStoryboard(name: "DefectReporter", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "SCDefectReporterCategorySelectionViewController") as! SCDefectReporterCategorySelectionViewController
        sut.presenter = presenter ?? SCDefectReporterCategorySelectionPresenterMock()
        sut.loadViewIfNeeded()
        return sut
    }
    
    func testViewDidLoad() {
        let presenter = SCDefectReporterCategorySelectionPresenterMock()
        let sut = prepareSut(presenter: presenter)
        sut.viewDidLoad()
        guard let presenter = sut.presenter as? SCDefectReporterCategorySelectionPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isViewDidLoadCalled)
    }
    
    func testViewWillAppear() {
        let mockBackButtonTitle = LocalizationKeys.Common.navigationBarBack.localized()
        let presenter = SCDefectReporterCategorySelectionPresenterMock()
        let sut = prepareSut(presenter: presenter)
        sut.viewWillAppear(true)
        XCTAssertEqual(mockBackButtonTitle, sut.navigationItem.backButtonTitle)
    }
    
    func testReloadCategoryList() {
        let mockCategoryList = [SCModelDefectCategory(serviceCode: "", serviceName: "",
                                                      subCategories: [SCModelDefectSubCategory(serviceCode: "", serviceName: "",
                                                                                               description: "", isAdditionalInfo: false)], description: nil)]
        let presenter = SCDefectReporterCategorySelectionPresenterMock()
        let sut = prepareSut(presenter: presenter)
        sut.viewDidLoad()
        sut.reloadCategoryList(mockCategoryList)
        XCTAssertEqual(mockCategoryList, sut.categoryList)
    }
    
    func testNumberOfRows() {
        let mockCategoryList = [SCModelDefectCategory(serviceCode: "", serviceName: "",
                                                      subCategories: [SCModelDefectSubCategory(serviceCode: "", serviceName: "",
                                                                                               description: "", isAdditionalInfo: false)], description: nil)]
        let sut = prepareSut()
        sut.categoryList = mockCategoryList
        let count = sut.tableView(sut.tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(1, count)
    }
    
    func testTableViewCellForRow() {
        let mockCategoryList = [SCModelDefectCategory(serviceCode: "", serviceName: "",
                                                      subCategories: [SCModelDefectSubCategory(serviceCode: "", serviceName: "",
                                                                                               description: "", isAdditionalInfo: false)], description: nil)]
        let sut = prepareSut()
        sut.categoryList = mockCategoryList
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertTrue(cell is SCDefectReporterCategoryCell)
    }
    
    func testCellSelection() {
        let mockCategoryList = [SCModelDefectCategory(serviceCode: "service code", serviceName: "service name",
                                                      subCategories: [SCModelDefectSubCategory(serviceCode: "test",
                                                                                               serviceName: "test",
                                                                                               description: "test", isAdditionalInfo: false)], description: nil)]
        let sut = prepareSut()
        sut.categoryList = mockCategoryList
        sut.tableView(sut.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        guard let presenter = sut.presenter as? SCDefectReporterCategorySelectionPresenterMock else {
            return
        }
        XCTAssertEqual(presenter.category, mockCategoryList[0])
    }
    
    func testSetNavigation() {
        let mockTitle = LocalizationKeys.SCDefectReporterCategorySelectionPresenter.dr001ChooseCategoryLabel.localized()
        let sut = prepareSut()
        sut.setNavigation(title: mockTitle)
        XCTAssertEqual(sut.navigationItem.title, mockTitle)
    }
}
