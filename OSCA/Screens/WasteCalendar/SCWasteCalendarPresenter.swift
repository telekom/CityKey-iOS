//
//  SCWasteCalendarPresenter.swift
//  OSCA
//
//  Created by Michael on 27.08.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import TTGSnackbar

protocol SCWasteCalendarDisplaying: AnyObject , SCDisplaying{
    func setupUI(title: String, backTitle: String)
    func present(viewController: UIViewController)
    func push(viewController: UIViewController)
    func updateWasteCalendarItems(_ wasteCalendarItems: [SCModelWasteCalendarItem], wasteReminders: [SCHttpModelWasteReminder])
    func updateCategoryFilterName(_ name : String, color : UIColor)
    func updateFilterCategories(_ categories : [String]?)
    func updateAddress(street: String?)
    func showActivityInfoOverlay()
    func showErrorInfoOverlay()
    func hideInfoOverlay()
    func updateDataSource(wasteReminders: [SCHttpModelWasteReminder])
    func scrollToNextMonth()
}

protocol SCWasteCalendarPresenting: SCPresenting {
    func setDisplay(_ display: SCWasteCalendarDisplaying)
    func didTapOnCategoryFilter()
    func didTapOnAddress(delegate: SCWasteAddressViewResultDelegate)
    func update(address: SCModelWasteCalendarAddress)
    func displayReminderSettingFor(wasteType: SCWasteCalendarDataSourceItem, delegate: SCWasteReminderResultDelegate)
    func setReminder(worker: SCWasteReminderWorking, settings: SCHttpModelWasteReminder?)
    func update(reminders: [SCHttpModelWasteReminder])
    func updateWasteCalendarItems(_ items: [SCModelWasteCalendarItem])
    func didTapExportWasteTypes(for wasteTypes: [SCWasteCalendarDataSourceItem])
    func getServiceTitle() -> String
    var deeplinkData: String? { get set }
}

struct SCReminderSettings {
    let wasteTypeId: Int
    let time: String
    let onPickupDay: Bool
    let onOneDayBeforePickup: Bool
    let onTwoDayBeforePickup: Bool

    func getParameters() -> [String: Any] {
        var parameters = [String: Any]()
        parameters["wasteTypeId"] = wasteTypeId
        parameters["remindTime"] = time
        parameters["sameDay"] = onPickupDay
        parameters["oneDayBefore"] = onOneDayBeforePickup
        parameters["twoDaysBefore"] = onTwoDayBeforePickup
        return parameters
    }
}

class SCWasteCalendarPresenter: SCWasteCalendarPresenting {

    weak private var display: SCWasteCalendarDisplaying?

    private var wasteCalendarItems: [SCModelWasteCalendarItem] {
        didSet {
            self.dataCache.storeWasteCalendarItems(wasteCalendarItems, for: self.cityContentSharedWorker.getCityID())
        }
    }

    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let userContentSharedWorker: SCUserContentSharedWorking
    private let wasteCalendarWorker: SCWasteCalendarWorking & SCWasteFilterWorking
    
    private let injector: SCAdjustTrackingInjection & SCWasteCategoryFilterInjecting & SCWasteServiceInjecting
    
    private let dataCache: SCDataCaching
    private let cityID: Int

    private var currentFilterSelectedCategories: [SCModelCategoryObj]?

    private var categories : [SCModelCategoryObj]?
    private var calendarAddress: SCModelWasteCalendarAddress?

    private var reminderWorker: SCWasteReminderWorking?
    private var wasteReminders: [SCHttpModelWasteReminder]

    private let serviceData: SCBaseComponentItem
    var deeplinkData: String?
    private var dispatchGroup: DispatchGroup
    private var storedWasteTypeIds: SCModelWasteTypeIDs?
    
    init(wasteCalendarItems: [SCModelWasteCalendarItem],
         calendarAddress: SCModelWasteCalendarAddress?,
         cityContentSharedWorker: SCCityContentSharedWorking,
         userContentSharedWorker: SCUserContentSharedWorking,
         wasteCalendarWorker: SCWasteCalendarWorking & SCWasteFilterWorking,
         injector: SCAdjustTrackingInjection & SCWasteCategoryFilterInjecting & SCWasteServiceInjecting,
         dataCache: SCDataCaching,
         wasteReminders: [SCHttpModelWasteReminder],
         serviceData: SCBaseComponentItem,
         dispatchGroup: DispatchGroup = DispatchGroup()) {

        self.cityContentSharedWorker = cityContentSharedWorker
        self.userContentSharedWorker = userContentSharedWorker
        
        self.wasteCalendarWorker = wasteCalendarWorker
        self.injector = injector
        self.dataCache = dataCache
        self.cityID = self.cityContentSharedWorker.getCityID()
        self.calendarAddress = calendarAddress
        self.wasteCalendarItems = wasteCalendarItems
        self.wasteReminders = wasteReminders
        self.serviceData = serviceData
        self.dispatchGroup = dispatchGroup
        self.updateCategoryData()
        registerNotification()
    }

    private func registerNotification() {
        SCDataUIEvents.registerNotifications(for: self, on: .didSetWasteReminderDataState, with: #selector(didSetReminder))
    }

    @objc private func didSetReminder() {
        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.setWasteReminder)
        switch reminderWorker?.reminderDataState.dataLoadingState {
        case .fetchFailed:
            showToastWith(message: LocalizationKeys.SCWasteCalendarPresenter.wc005ErrorToastMessage.localized())
            getWasteCalendar()

        default:
            break
        }
    }

    private func showToastWith(message: String) {
        let snackBar = TTGSnackbar(message: message,
                                   duration: .middle)
        snackBar.setCustomStyle()
        snackBar.show()
    }

    private func getWasteCalendar() {
        wasteCalendarWorker.getWasteCalendar(for: cityID, street: nil, houseNr: nil) {
            [weak self] (wasteCalendarItemList, wasteAddress, wasteReminderList, error) in

            guard error == nil else {
                self?.display?.showErrorDialog(error!)
                return
            }

            self?.wasteCalendarItems = wasteCalendarItemList ?? []
            self?.calendarAddress = wasteAddress
            self?.wasteReminders = wasteReminderList
            self?.display?.updateWasteCalendarItems(wasteCalendarItemList ?? [], wasteReminders: wasteReminderList)
        }
    }

    private func updateCategoryData() {
        dispatchGroup.enter()
        self.wasteCalendarWorker.getWasteCalendarCategoriesObj(for: self.cityID, completion: {
            [weak self] (categories, error) in
            self?.dispatchGroup.leave()
            guard error == nil else {
                self?.display?.showErrorDialog(error!, retryHandler:  { self?.updateCategoryData()})
                return
            }

            self?.categories = categories
            // Do we need to update entire UI or just to update the Category filter label?
            self?.updateUI()
        })
    }

    private func updateUI() {
        self.display?.updateWasteCalendarItems(self.wasteCalendarItems, wasteReminders: wasteReminders)
        self.updateCategoryFilterLabel()
        updateAddressLabel()
    }
    
    private func getCityName() -> String? {
        return cityContentSharedWorker.getCityContentData(for: cityContentSharedWorker.getCityID())?.city.name
    }

    func categoryFilterDescription(selectedCategories : [SCModelCategoryObj]?) -> SCFilterDescription{
        
        let totalCategoriesCount = categories?.count
        
        guard let filterCategories = selectedCategories else {
            return SCFilterDescription(filtername: LocalizationKeys.SCWasteCalendarPresenter.wc004FilterCategoryNothingSelected.localized(), color: UIColor(named: "CLR_LABEL_TEXT_GRAY_DARKGRAY")!)
        }
        
        if filterCategories.count == 0 {
            return SCFilterDescription(filtername: LocalizationKeys.SCWasteCalendarPresenter.wc004FilterCategoryNothingSelected.localized(), color: UIColor(named: "CLR_LABEL_TEXT_GRAY_DARKGRAY")!)
        }
        
        if totalCategoriesCount == filterCategories.count {
            return SCFilterDescription(filtername: LocalizationKeys.SCWasteCalendarPresenter.wc004FilterCategoryAllSelected.localized(), color: UIColor(named: "CLR_LABEL_TEXT_GRAY_DARKGRAY")!)
        }
        
        return SCFilterDescription(filtername: LocalizationKeys.SCWasteCalendarPresenter.wc004FilterCategorySelectedCount.localized().replacingOccurrences(of: "%d", with: String(filterCategories.count)), color: UIColor(named: "CLR_LABEL_TEXT_GRAY_DARKGRAY")!)
    }

    private func updateCategoryFilterLabel() {
        let filter = self.categoryFilterDescription(selectedCategories: self.currentFilterSelectedCategories)
        self.display?.updateCategoryFilterName(filter.filtername, color: filter.color)
    }

    private func updateAddressLabel() {
        let address = "\(calendarAddress?.streetName ?? "") \(calendarAddress?.houseNumber ?? "")"
        display?.updateAddress(street: address)
    }
    
    private func getWasteTypeForUser() {
        // retriving the saved filter for user
        self.dispatchGroup.enter()
        self.wasteCalendarWorker.getWasteTypeForUser(for: (self.cityContentSharedWorker.getCityID()), completion: { [weak self] (storedWasteTypeIds, error) in
            guard error == nil else {
//                self?.display?.showErrorDialog(error!)
                self?.didTapOnCategoryFilter()
                return
            }
            self?.storedWasteTypeIds = storedWasteTypeIds
            self?.dispatchGroup.leave()
        })
    }
    
    private func notifiyWhenDone() {
        var selectedCategories : [SCModelCategoryObj] = []
        storedWasteTypeIds?.wasteTypeIds.forEach { wasteTypeId in
            if let wasteTypeCategory = self.categories?.filter({ $0.id == wasteTypeId }).first {
                selectedCategories.append(wasteTypeCategory)
            }
        }
        
        if selectedCategories.count != 0 {
            self.currentFilterSelectedCategories = selectedCategories
            self.display?.updateFilterCategories(selectedCategories.map({ (wasteCategory: SCModelCategoryObj) -> String in
                wasteCategory.name
            }))
        } else {
            self.currentFilterSelectedCategories = []
            self.display?.updateFilterCategories([])
        }
        
        self.updateUI()
        storedWasteTypeIds = nil
    }
    
}

extension SCWasteCalendarPresenter: SCPresenting {

    func viewDidLoad() {
        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.openWasteCalendar)
        self.display?.setupUI(title: getServiceTitle(),
                              backTitle: LocalizationKeys.Common.navigationBarBack.localized())
        updateUI()
        // retriving the saved filter for user
        getWasteTypeForUser()
        
        dispatchGroup.notify(queue: .main) {
            self.notifiyWhenDone()
        }

    }

    func viewWillAppear() {
        self.updateCategoryFilterLabel()
    }
    
    func viewDidAppear() {
        handleDeeplink()
    }
    
    private func handleDeeplink() {
        guard let wasteCalendarMonth = deeplinkData,
        let month = Int(wasteCalendarMonth) else {
            return
        }
        if wasteCalendarMonth != monthFromDate(date: Date()) {
            self.deeplinkData = nil // clearing deeplink data after handling
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.display?.scrollToNextMonth()
            }
        }
    }
    
    private func monthFromDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMM"
        return formatter.string(from: date)
    }
}

extension SCWasteCalendarPresenter {
    func didTapExportWasteTypes(for wasteTypes: [SCWasteCalendarDataSourceItem]) {
        let viewController = self.injector.getExportEventOptionsVC(exportWasteTypes: wasteTypes)
        self.display?.present(viewController: viewController)
    }
    
    func setDisplay(_ display: SCWasteCalendarDisplaying) {
        self.display = display
    }
 
    func didTapOnCategoryFilter() {
        self.wasteCalendarWorker.setCategories(self.categories)
        if let navigationController = self.injector.getCategoryFilterViewController(
            screenTitle: LocalizationKeys.SCWasteCalendarPresenter.wc004FilterCategoryTitle.localized(),
            selectBtnText: LocalizationKeys.SCWasteCalendarPresenter.wc004FilterCategoryShowResult.localized(),
            selectAllButtonHidden: false,
            filterWorker:self.wasteCalendarWorker,
            preselectedCategories: self.currentFilterSelectedCategories,
            delegate: self) as? UINavigationController {
            self.display?.present(viewController: navigationController)
        }
    }

    func didTapOnAddress(delegate: SCWasteAddressViewResultDelegate) {
        display?.present(viewController: injector.getWasteAddressController(delegate: delegate,
                                                                            wasteAddress: calendarAddress,
                                                                            item: serviceData))
    }

    func displayReminderSettingFor(wasteType: SCWasteCalendarDataSourceItem, delegate: SCWasteReminderResultDelegate) {
        display?.push(viewController: injector.getWasteReminderController(wasteType: wasteType, delegate: delegate, reminders: getReminderOf(wasteType: wasteType.itemName)))
    }

    func update(address: SCModelWasteCalendarAddress) {
        calendarAddress = address
        updateAddressLabel()
    }

    func setReminder(worker: SCWasteReminderWorking, settings: SCHttpModelWasteReminder?) {
        reminderWorker = worker
        updateExistingReminders(settings: settings)
        display?.updateDataSource(wasteReminders: self.wasteReminders)
        didSetReminder()
    }

    private func updateExistingReminders(settings: SCHttpModelWasteReminder?) {
        guard let settings = settings else {
            return
        }

        if let index = wasteReminders.firstIndex(where: {$0.wasteType == settings.wasteType}) {
            if deleteReminder(settings: settings) {
                wasteReminders.remove(at: index)
            } else {
                wasteReminders[index] = settings
            }
        } else {
            if !deleteReminder(settings: settings) {
                wasteReminders.append(settings)
            }
        }
    }

    private func deleteReminder(settings: SCHttpModelWasteReminder) -> Bool {
        !settings.sameDay && !settings.oneDayBefore && !settings.twoDaysBefore
    }

    private func getReminderOf(wasteType: String) -> SCHttpModelWasteReminder? {
        if let index = wasteReminders.firstIndex(where: {$0.wasteType == wasteType}) {
            return wasteReminders[index]
        }
        return nil
    }

    func update(reminders: [SCHttpModelWasteReminder]) {
        self.wasteReminders = reminders
    }
    
    func updateWasteCalendarItems(_ items: [SCModelWasteCalendarItem]) {
        self.wasteCalendarItems = items
    }
    
    func getServiceTitle() -> String {
        return serviceData.itemTitle
    }
}

extension SCWasteCalendarPresenter: SCWasteCategorySelectionDelegate {

    func categorySelectorNeedsResultCount(categories: [SCModelCategoryObj], completion: @escaping (Int) -> ()) {
        return completion(categories.count)
    }
    
    func categorySelectorDidFinish(categories: [SCModelCategoryObj], filterCount: Int, completion: @escaping (_ success: Bool) ->()) {
        self.currentFilterSelectedCategories = categories
        self.display?.updateFilterCategories(categories.map{$0.name})
        self.updateUI()
    }
    
    func saveWasteTypeID(_ categories: [SCModelCategoryObj], completion: @escaping (Bool?, SCWorkerError?) -> ()?) {
       
        let cityID = self.cityContentSharedWorker.getCityID()
        let wasteTypeIds = (categories.map{ ($0.id) })
        self.wasteCalendarWorker.saveWasteTypeForUser(for: cityID, wasteTypeIds: wasteTypeIds) { (successful, error) in

            guard error == nil else {
                SCUtilities.topViewController().showUIAlert(with: LocalizationKeys.SCDisplayingDefaultImplementation.dialogTechnicalErrorMessage.localized(), cancelTitle: LocalizationKeys.SCDefectReporterFormPresenter.dr003DialogButtonOk.localized(), retryTitle: nil, retryHandler: nil, additionalButtonTitle: nil, additionButtonHandler: nil, alertTitle: LocalizationKeys.SCDisplayingDefaultImplementation.dialogTechnicalErrorTitle.localized())

                return
            }

            completion(successful, nil)
        }
        
    }
}

