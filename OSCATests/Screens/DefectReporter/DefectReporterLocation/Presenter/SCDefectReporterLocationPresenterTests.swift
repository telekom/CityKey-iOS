//
//  SCDefectReporterLocationPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 22/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA
import CoreLocation

class SCDefectReporterLocationPresenterTests: XCTestCase {
    weak private var display: SCDefectReporterLocationViewDisplayer!
    private func prepareSut(utilities: SCUtilityUsable? = nil) -> SCDefectReporterLocationPresenter {
        let serviceData = SCBaseComponentItem(itemID: "", itemTitle: "",
                                              itemHtmlDetail: false, itemColor: .blue)
        let defectcategory = SCModelDefectCategory(serviceCode: "", serviceName: "",
                                                   subCategories: [],
                                                   description: nil)
        let presenter: SCDefectReporterLocationPresenter = SCDefectReporterLocationPresenter(serviceData: serviceData,
                                                                                             injector: MockSCInjector(),
                                                                                             cityContentSharedWorker: SCCityContentSharedWorkerMock(),
                                                                                             category: defectcategory,
                                                                                             utilities: utilities ?? SCUtilitiesMock())
        return presenter
    }
    
    func testCloseButtonWasPressed() {
        let sut = prepareSut()
        let displayer = SCDefectReporterLocationViewDisplayer()
        display = displayer
        sut.setDisplay(displayer)
        sut.closeButtonWasPressed()
        XCTAssertTrue(display.isDismissCalled)
    }
    
    func testSavePositionBtnWasPressed() {
        let mockIndex = 1
        let mockUtitlies = SCUtilitiesMock(tabIndex: mockIndex)
        let sut = prepareSut(utilities: mockUtitlies)
        let displayer = SCDefectReporterLocationViewDisplayer()
        display = displayer
        sut.setDisplay(displayer)
        sut.savePositionBtnWasPressed()
        XCTAssertTrue(mockUtitlies.dismissAnyPresentedControllerCalled)
    }
    
    

}

extension MockSCInjector: SCDefectReporterInjecting {
    func getDefectReporterLocationViewController(category: SCModelDefectCategory, subCategory: SCModelDefectSubCategory?, serviceData: SCBaseComponentItem, includeNavController: Bool, service: Services, completionAfterDismiss: (() -> Void)?) -> UIViewController {
        return UIViewController()
    }
    
    func getDefectReporterSubCategoryViewController(category: SCModelDefectCategory, subCategoryList: [SCModelDefectSubCategory], serviceData: SCBaseComponentItem, service: Services) -> UIViewController {
        return UIViewController()
    }
    
    func getDefectReporterFormViewController(category: SCModelDefectCategory, subCategory: SCModelDefectSubCategory?, serviceData: SCBaseComponentItem, serviceFlow: Services) -> UIViewController {
        return UIViewController()
    }
    
    func getDefectReporterFormSubmissionViewController(category: SCModelDefectCategory, subCategory: SCModelDefectSubCategory?, uniqueId: String, serviceFlow: Services, email: String?) -> UIViewController {
        return UIViewController()
    }
    
    func getDefectReportTermsViewController(for url: String, title: String?, insideNavCtrl: Bool) -> UIViewController {
        return UIViewController()
    }
    
    func getFahrradparkenReportedLocationViewController(category: SCModelDefectCategory, subCategory: SCModelDefectSubCategory?, serviceData: SCBaseComponentItem, includeNavController: Bool, service: Services, completionAfterDismiss: (() -> Void)?) -> UIViewController {
        return UIViewController()
    }
    
    func getFahrradParkenReportedLocationDetailsViewController(with location: FahrradparkenLocation, serviceData: SCBaseComponentItem, compltionHandler: (() -> Void)?) -> UIViewController {
        return UIViewController()
    }
}

class SCDefectReporterLocationViewDisplayer: SCDefectReporterLocationViewDisplay {
    private(set) var isDismissCalled: Bool = false
    private(set) var isPushCalled: Bool = false
    private(set) var title: String = ""
    private(set) var message: String = ""
    private(set) var location: CLLocation?
    func dismiss(completion: (() -> Void)?) {
        isDismissCalled = true
    }
    
    func push(viewController: UIViewController) {
        isPushCalled = true
    }
    
    func showLocationFailedMessage(messageTitle: String, withMessage: String) {
        self.title = messageTitle
        self.message = withMessage
    }
    
    func reloadDefectLocationMap(location: CLLocation) {
        self.location = location
    }
}
