//
//  SCDefectReporterMoreInfoPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 22/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCDefectReporterMoreInfoPresenterTests: XCTestCase {
    weak private var display: SCDefectReporterMoreInfoViewDisplay!
    private func prepareSut() -> SCDefectReporterMoreInfoPresenter {
        let presenter = SCDefectReporterMoreInfoPresenter(injector: MockSCInjector())
        return presenter
    }
    
    func testSetDisplay() {
        let sut = prepareSut()
        let displayer = SCDefectReporterMoreInfoViewDisplayer()
        display = displayer
        sut.setDisplay(displayer)
        XCTAssertNotNil(display)
    }
}

class SCDefectReporterMoreInfoViewDisplayer: SCDefectReporterMoreInfoViewDisplay {
    func setNavigationTitle(_ title: String) {
        
    }
    
    func pushViewController(_ viewController: UIViewController) {
        
    }
}

extension MockSCInjector: SCServicesInjecting {

    func getWasteCalendarViewController(wasteCalendarItems: [SCModelWasteCalendarItem], calendarAddress: SCModelWasteCalendarAddress?, wasteReminders: [SCHttpModelWasteReminder], item: SCBaseComponentItem, month: String?) -> UIViewController {
        UIViewController()
    }
    
    func getTEVISViewController(for system: String, serviceData: SCBaseComponentItem) -> UIViewController {
        UIViewController()
    }
    
    func getServicesOverviewController(for item: SCBaseComponentItem?) -> UIViewController {
        UIViewController()
    }
    
    func getServicesDetailController(for item: SCBaseComponentItem, serviceDetailProvider: SCServiceDetailProvider, isDisplayOverviewScreen: Bool) -> UIViewController {
        UIViewController()
    }
    
    func getAppointmentOverviewController(serviceData: SCBaseComponentItem) -> UIViewController {
        UIViewController()
    }
    
    func getWasteServicesDetailController(for item: SCBaseComponentItem, openCalendar: Bool, with month: String?) -> UIViewController {
        UIViewController()
    }
    
    func getDefectReporterCategoryViewController(categoryList: [SCModelDefectCategory], serviceData: SCBaseComponentItem, serviceFlow: Services) -> UIViewController {
        UIViewController()
    }
    
    func getDefectReporterMoreViewController() -> UIViewController {
        UIViewController()
    }
    
    func getAusweisAuthServicesDetailController(for serviceWebDetails: SCModelEgovServiceWebDetails) -> UIViewController {
        UIViewController()
    }
    
    func getEgovServicesDetailController(for item: SCBaseComponentItem, serviceDetailProvider: SCServiceDetailProvider) -> UIViewController {
        UIViewController()
    }
    
    func getServicesMoreInfoViewController(for serviceDetailProvider: SCServiceDetailProvider, injector: SCServicesInjecting) -> UIViewController {
        UIViewController()
    }
}
