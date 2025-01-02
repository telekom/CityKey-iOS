//
//  SCDefectReporterCategorySelectionPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 25/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCDefectReporterCategorySelectionPresenterTests: XCTestCase {
    weak private var display: SCDefectReporterCategorySelectionViewDisplay?
    private func prepareSut(serviceData: SCBaseComponentItem? = nil,
                            category: [SCModelDefectCategory]? = nil) -> SCDefectReporterCategorySelectionPresenter {
        let defaultServiceData = SCBaseComponentItem(itemID: "", itemTitle: "",
                                              itemHtmlDetail: false, itemColor: .blue)
        let presenter = SCDefectReporterCategorySelectionPresenter(serviceData: serviceData ?? defaultServiceData,
                                                                   injector: MockSCInjector(),
                                                                   worker: SCDefectReporterWorkerMock(),
                                                                   category: category ?? [])
        return presenter
    }
    
    func testViewDidLoad() {
        let mockTitle: String = LocalizationKeys.SCDefectReporterCategorySelectionPresenter.dr001ChooseCategoryLabel.localized()
        let sut = prepareSut()
        let display = SCDefectReporterCategorySelectionViewDisplayer()
        self.display = display
        sut.setDisplay(display)
        sut.viewDidLoad()
        XCTAssertEqual(mockTitle, display.navTitle)
        XCTAssertTrue(display.categoryList.isEmpty)
    }
    
    func testDidSelectCategoryWithSubcategory() {
        let category = [SCModelDefectCategory(serviceCode: "",
                                              serviceName: "",
                                              subCategories: [SCModelDefectSubCategory(serviceCode: "", serviceName: "",
                                                                                       description: "", isAdditionalInfo: false)],
                                              description: nil)]
        let sut = prepareSut(serviceData: nil, category: category)
        let display = SCDefectReporterCategorySelectionViewDisplayer()
        self.display = display
        sut.setDisplay(display)
        sut.didSelectCategory(SCModelDefectCategory(serviceCode: "",
                                                    serviceName: "",
                                                    subCategories: [SCModelDefectSubCategory(serviceCode: "", serviceName: "",
                                                                                             description: "", isAdditionalInfo: false)], description: nil))
        XCTAssertTrue(display.isPushCalled)
        
    }
    
    func testDidSelectCategoryWithOutSubcategory() {
        let category = [SCModelDefectCategory(serviceCode: "",
                                              serviceName: "",
                                              subCategories: [],
                                              description: nil)]
        let sut = prepareSut(serviceData: nil, category: category)
        let display = SCDefectReporterCategorySelectionViewDisplayer()
        self.display = display
        sut.setDisplay(display)
        sut.didSelectCategory(SCModelDefectCategory(serviceCode: "",
                                                    serviceName: "",
                                                    subCategories: [],
                                                    description: nil))
        XCTAssertTrue(display.isPresentCalled)
        
    }

}

class SCDefectReporterCategorySelectionViewDisplayer: SCDefectReporterCategorySelectionViewDisplay {
    private(set) var reloadCategoryListCalled: Bool = false
    private(set) var categoryList: [SCModelDefectCategory] = []
    private(set) var navTitle: String = ""
    private(set) var isPresentCalled: Bool = false
    private(set) var isPushCalled: Bool = false
    func reloadCategoryList(_ categoryList: [SCModelDefectCategory]) {
        self.categoryList = categoryList
        reloadCategoryListCalled = true
    }
    
    func setNavigation(title: String) {
        navTitle = title
    }
    
    func push(viewController: UIViewController) {
        isPushCalled = true
    }
    
    func present(viewController: UIViewController) {
        isPresentCalled = true
    }
}
