//
//  SCExportEventOptionsViewPresenter.swift
//  OSCA
//
//  Created by A118572539 on 30/12/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import EventKit
import EventKitUI

protocol SCExportEventOptionsViewDisplaying: SCDisplaying{
    func setupUI(title: String, backTitle: String)
    func present(viewController: UIViewController, completion: (() -> Void)?)
    func push(viewController: UIViewController)
    func dismiss(completion: (() -> Void)?)
    func showSaveEventsAlert()
    func updateCellWithSelectedCalendar(calendar: EKCalendar)
    func getNewCalendarName() -> String?
    func getNewCalendarColor() -> UIColor
    func getNewCalendarColorName() -> String
}

protocol SCExportEventOptionsViewPresenting: SCPresenting {
    func getExistingCalendars() -> [EKCalendar]
    func createNewCalendar() -> EKCalendar
    func getExportWasteCalendarTypes() -> [String]
    func existingCalendarOptionsVC()
    func newCalendarColorOptionsVC(delegate: SCColorSelectionDelegate)
    func setDisplay(_ display: SCExportEventOptionsViewDisplaying)
    func changeCalendarType(type: CalendarType)
    func getCalendarType() -> CalendarType
    func addEventsToCalendar()
    func getSelectedCalendar() -> EKCalendar
}


class SCExportEventOptionsViewPresenter: NSObject {
    
    static let CalendarColors = [LocalizationKeys.SCExportEventOptionsViewPresenter
        .wc006RedColor.localized(),
                                 LocalizationKeys.SCExportEventOptionsViewPresenter.wc006OrangeColor.localized(),
                                 LocalizationKeys.SCExportEventOptionsViewPresenter.wc006YellowColor.localized(),
                                 LocalizationKeys.SCExportEventOptionsViewPresenter.wc006GreenColor.localized(),
                                 LocalizationKeys.SCExportEventOptionsViewPresenter.wc006BlueColor.localized(),
                                 LocalizationKeys.SCExportEventOptionsViewPresenter.wc006PurpleColor.localized(),
                                 LocalizationKeys.SCExportEventOptionsViewPresenter.wc006BrownColor.localized()]
    
    private var display: SCExportEventOptionsViewDisplaying?
    
    private var exportWasteTypes: [SCWasteCalendarDataSourceItem]
    private var injector: SCWasteServiceInjecting
    
    private var selectedCalendar: EKCalendar? = SCCalendarHelper.shared.getDefaultCalendar()
    private var calendarType: CalendarType = .existingCalendar
    
    init(exportWasteTypes: [SCWasteCalendarDataSourceItem], injector: SCWasteServiceInjecting) {
        self.exportWasteTypes = exportWasteTypes
        self.injector = injector
    }
    
    private func saveEventsToCalendar(calendar: EKCalendar) {
        let wasteTypes = exportWasteTypes.filter({$0.itemName != ""}).map({$0})
        var eventState = [CalendarEventSaveState]()
        for event in wasteTypes {
            if let date = Date.dateFromHash(Int(event.dateBaseString)!) {
                eventState.append(SCCalendarHelper.shared.addEventToCalendar(calendar: calendar, title: event.itemName, url: "", startDate: date, endDate: date, note: "", location: ""))
            }
        }
        
        if eventState.filter({ $0 == .saved }).count == wasteTypes.count {
            display?.showSaveEventsAlert()
        } else if eventState.filter({ $0 == .saved }).count == 0 {
            display?.showErrorDialog(with: LocalizationKeys.SCExportEventOptionsViewPresenter.wc006EventsNotAdded.localized(), retryHandler: nil, showCancelButton: true, additionalButtonTitle: nil, additionButtonHandler: nil)
        }
    }
}

extension SCExportEventOptionsViewPresenter: SCExportEventOptionsViewPresenting {

    func existingCalendarOptionsVC() {
        let calendarChooser = SCCalendarHelper.shared.getCalendarChooser() as! EKCalendarChooser
        
        // customization
        calendarChooser.showsDoneButton = true
        calendarChooser.showsCancelButton = true

        calendarChooser.delegate = self

        let navigationViewController = UINavigationController(rootViewController: calendarChooser)
        navigationViewController.setToolbarHidden(true, animated: false)
        navigationViewController.interactivePopGestureRecognizer?.isEnabled = false
        display?.present(viewController: navigationViewController, completion: nil)
    }
    
    func newCalendarColorOptionsVC(delegate: SCColorSelectionDelegate) {
        let colorItems = SCExportEventOptionsViewPresenter.CalendarColors
        let existingCalendarOptionVC = injector.getCalendarOptionsTableViewController(items: colorItems, selectedColorName: display?.getNewCalendarColorName() ?? LocalizationKeys.SCExportEventOptionsViewPresenter.wc006BlueColor.localized(), delegate: delegate)
        display?.push(viewController: existingCalendarOptionVC)
    }
    
    func getExportWasteCalendarTypes() -> [String] {
        let wasteTypes = exportWasteTypes.filter({$0.itemName != ""}).map({$0.itemName})
        let uniqueWasteTypes = Array(NSOrderedSet(array: wasteTypes).array as! [String])
        return uniqueWasteTypes
    }
    
    func getExistingCalendars() -> [EKCalendar] {
        return SCCalendarHelper.shared.getExistingCalendars()
    }
    
    func getSelectedCalendar() -> EKCalendar {
        return selectedCalendar!
    }
    
    func changeCalendarType(type: CalendarType) {
        calendarType = type
    }
    
    func getCalendarType() -> CalendarType {
        return calendarType
    }
    
    func createNewCalendar() -> EKCalendar {
        return SCCalendarHelper.shared.createNewCalendar(for: .event, title: self.display?.getNewCalendarName() ?? "", color: self.display?.getNewCalendarColor().cgColor ?? UIColor.systemBlue.cgColor)
    }
    
    func setDisplay(_ display: SCExportEventOptionsViewDisplaying) {
        self.display = display
    }
    
    func addEventsToCalendar() {
        switch calendarType {
        case .existingCalendar:
            guard let selectedCalendar = selectedCalendar else {
                return
            }
            saveEventsToCalendar(calendar: selectedCalendar)
        case .newCalendar:
            saveEventsToCalendar(calendar: createNewCalendar())
        }
    }
    
    func viewDidLoad() {
        
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
}

extension SCExportEventOptionsViewPresenter: EKCalendarChooserDelegate {
    
    func calendarChooserDidFinish(_ calendarChooser: EKCalendarChooser) {
        if let chosenCalendar = calendarChooser.selectedCalendars.first {
            self.selectedCalendar = chosenCalendar
            self.display?.updateCellWithSelectedCalendar(calendar: chosenCalendar)
        }
        display?.dismiss(completion: nil)
    }
    
    func calendarChooserSelectionDidChange(_ calendarChooser: EKCalendarChooser) {
        print("Changed selection")
    }
    
    func calendarChooserDidCancel(_ calendarChooser: EKCalendarChooser) {
        print("Cancel tapped")
        display?.dismiss(completion: nil)
    }
}
