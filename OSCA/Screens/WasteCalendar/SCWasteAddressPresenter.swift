//
//  SCWasteAddressPresenter.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 11/09/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import Foundation

enum SCWasteAddressHouseNumberValidationState {
    case valid
    case notValid
    case notVerifiable
}

protocol SCWasteAddressPresenting: SCPresenting {
    var isAddressSelectedFromList: Bool { get set }
    func configure(textField: SCTextFieldConfigurable, segueID: String?) -> SCTextFieldConfigurable?
    func setDisplay(display: SCWasteAddressDisplaying)
    func getCityName() -> String?
    func filterStreet(name: String)
    func filterHouseNumber(number: String) -> [String]
    func getStreetList() -> [String]
    func getHouseNumberList() -> [String]
    func selected(street: String)
    func selected(house: String)
    func handleSubmitButtonState()

    func isSelectedStreetValid() -> Bool
    func selectedHouseNumberValidationState() -> SCWasteAddressHouseNumberValidationState
    func updateWasteCalendar()
    func resetAddressList()
    func isHouseNumberListEmpty() -> Bool
    func displaycategorySelectionViewController(items: [SCModelWasteCalendarItem], address: SCModelWasteCalendarAddress, wasteReminders: [SCHttpModelWasteReminder], categories: [SCModelCategoryObj])

}

class SCWasteAddressPresenter {

    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let wasteCalendarWorker: SCWasteCalendarWorking & SCWasteFilterWorking
    private var display: SCWasteAddressDisplaying?
    private var selectedStreet: String = ""
    private var selectedHouse: String = ""

    private var filterData = [SCModelWasteCalendarAddressResult]()
    private var wasteAddress: SCModelWasteCalendarAddress?
    private let dataCache: SCDataCaching
    
    private let injector: SCWasteCategoryFilterInjecting & SCServicesInjecting

    internal var isAddressSelectedFromList: Bool = false

    private let serviceData: SCBaseComponentItem
    
    init(cityContentSharedWorker: SCCityContentSharedWorking,
         wasteCalendarWorker: SCWasteCalendarWorking & SCWasteFilterWorking,
         wasteAddress: SCModelWasteCalendarAddress?,
         injector: SCWasteCategoryFilterInjecting & SCServicesInjecting,
         dataCache: SCDataCaching,
         serviceData: SCBaseComponentItem) {
        self.cityContentSharedWorker = cityContentSharedWorker
        self.wasteCalendarWorker = wasteCalendarWorker
        self.wasteAddress = wasteAddress
        self.dataCache = dataCache
        self.injector = injector
        self.serviceData = serviceData
    }

    private func setupUI() {
        display?.setupNavigationBar(title: LocalizationKeys.SCWasteAddressPresenter.wc004FtuTitle.localized(), backTitle: LocalizationKeys.Common.navigationBarBack.localized())
        display?.setupUI(title: LocalizationKeys.SCWasteAddressPresenter.wc004FtuShowResultBtn.localized())
        display?.disableSubmitButton()

        setAddress()
    }

    private func isValid(street: String) -> Bool {
        guard !street.isEmpty else { return false }
        return filterData.contains(where: { $0.streetName.caseInsensitiveCompare(street) == .orderedSame })
    }

    private func updateStreetFilterResultWith(streetName: String) {
        display?.updateListViewWith(items: self.getStreetList())
        display?.handleStreetTextFieldError(isValid: isValid(street: streetName))
    }

    private func setAddress() {
        if let address = wasteAddress {
            selectedStreet = address.streetName
            selectedHouse = address.houseNumber
            display?.updateAddress(street: address.streetName, houseNumber: address.houseNumber)

            let cityID = cityContentSharedWorker.getCityID()
            wasteCalendarWorker.searchStreetAndHouseNr(for: cityID, filterString: address.streetName) {
                [weak self] (result, error) in

                guard let presenterSelf = self else {
                    return
                }

                guard error == nil else {
                    presenterSelf.filterData = []
                    //TODO: Are we gonna show error message?
                    DispatchQueue.main.async {
                        presenterSelf.display?.handleStreetTextFieldError(isValid: presenterSelf.isValid(street: presenterSelf.selectedStreet))
                        presenterSelf.display?.handleHouseNumberTextFieldError(validationState: presenterSelf.selectedHouseNumberValidationState())
                        presenterSelf.display?.setHouseNumberContainerViewHeight()
                    }
                    return
                }

                DispatchQueue.main.async {
                    presenterSelf.filterData = result ?? []
                    presenterSelf.display?.updateListViewWith(items: presenterSelf.getStreetList())
                    presenterSelf.display?.handleStreetTextFieldError(isValid: presenterSelf.isValid(street: presenterSelf.selectedStreet))
                    presenterSelf.display?.handleHouseNumberTextFieldError(validationState: presenterSelf.selectedHouseNumberValidationState())
                    presenterSelf.display?.setHouseNumberContainerViewHeight()
                    presenterSelf.handleSubmitButtonState()
                }
            }
        }
    }
}

extension SCWasteAddressPresenter: SCWasteAddressPresenting {

    func resetAddressList() {
        filterData = []
    }

    func setDisplay(display: SCWasteAddressDisplaying) {
        self.display = display
    }

    func getStreetList() -> [String] {
        return filterData.map { $0.streetName }
    }
    
    func getHouseNumberList() -> [String] {
        guard let street = filterData.first(where: { $0.streetName.caseInsensitiveCompare(selectedStreet) == .orderedSame }) else {
            return []
        }
        
        return street.houseNumberList
    }

    func getCityName() -> String? {
        return cityContentSharedWorker.getCityContentData(for: cityContentSharedWorker.getCityID())?.city.name
    }

    func configure(textField: SCTextFieldConfigurable, segueID: String?) -> SCTextFieldConfigurable? {

        switch segueID {
        case "streetNameSegue":
            textField.configure(placeholder: LocalizationKeys.SCWasteAddressPresenter.wc004FtuStreetName.localized(), fieldType: .text, maxCharCount: 256, autocapitalization: .none)
            return textField

        case "houseNameSegue":
            textField.configure(placeholder: LocalizationKeys.SCWasteAddressPresenter.wc004FtuHouseNumber.localized(), fieldType: .text, maxCharCount: 256, autocapitalization: .none)
            return textField

        case "cityTextSegue":
            textField.configure(placeholder: LocalizationKeys.SCWasteAddressPresenter.wc004FtuCity.localized(), fieldType: .text, maxCharCount: 256, autocapitalization: .allCharacters)
            return textField

        default:
            return nil
        }
    }

    func filterStreet(name: String) {
        let cityID = cityContentSharedWorker.getCityID()
        wasteCalendarWorker.searchStreetAndHouseNr(for: cityID, filterString: name) {
            [weak self] (result, error) in
            
            guard let presenterSelf = self else {
                return
            }
            
            guard error == nil else {
                presenterSelf.filterData = []
                //TODO: Are we gonna show error message?
                DispatchQueue.main.async {
                    presenterSelf.updateStreetFilterResultWith(streetName: name)
                }
                return
            }
            
            DispatchQueue.main.async {
                // Checking if user has selected the address from existing result then discard new result and proceed
                if !presenterSelf.isAddressSelectedFromList {
                    if name == "" {
                        self?.filterData = []
                    } else {
                        self?.filterData = result ?? []
                    }
                    if !name.isEmpty {
                        self?.updateStreetFilterResultWith(streetName: name)
                    }
                } else {
                    self?.updateStreetFilterResultWith(streetName: presenterSelf.selectedStreet)
                }
                self?.display?.setHouseNumberContainerViewHeight()
                self?.selectedHouse = ""
            }
        }
    }
    
    func filterHouseNumber(number: String) -> [String] {
        return getHouseNumberList().filter { $0.starts(with: number) }
    }

    func selected(house: String) {
        selectedHouse = house
    }

    func selected(street: String) {
        selectedStreet = street
    }

    func handleSubmitButtonState() {
        if isSelectedStreetValid() && isHouseNumberListEmpty() {
            display?.enableSubmitButton()
        } else if isSelectedStreetValid() && selectedHouseNumberValidationState() != .notValid  {
            display?.enableSubmitButton()
        } else {
            display?.disableSubmitButton()
        }
    }

    func isSelectedStreetValid() -> Bool {
        isValid(street: selectedStreet)
    }

    func selectedHouseNumberValidationState() -> SCWasteAddressHouseNumberValidationState {
        guard !selectedHouse.isEmpty else { return .notValid }

        if let street = filterData.first(where: { $0.streetName.caseInsensitiveCompare(selectedStreet) == .orderedSame }) {
            
            if street.houseNumberList.count > 0 {
                let houseNumberFound = street.houseNumberList.contains(where: { $0 == selectedHouse })
                return houseNumberFound ? .valid : .notValid
            } else {
                if selectedHouse.first!.isNumber == false {
                    return .notValid
                }
            }
        }

        return .notVerifiable
    }

    func isHouseNumberListEmpty() -> Bool {
        if let street = filterData.first(where: { $0.streetName.caseInsensitiveCompare(selectedStreet) == .orderedSame }) {
           return street.houseNumberList.isEmpty
        }
        return true
    }

    
    func updateWasteCalendar() {
        let updateCompletion =  { [weak self] in
            self?.wasteCalendarWorker.getWasteCalendar(for: (self?.cityContentSharedWorker.getCityID())!, street: self?.selectedStreet, houseNr: self?.selectedHouse) {
            [weak self] (wasteCalendarItems, address, wasteReminders, error) in

                DispatchQueue.main.async {
                    self?.display?.resetButtonState()
                    guard error == nil,
                        let wasteCalendarItems = wasteCalendarItems,
                        let address = address else {
                            //TODO: Display error dialog
                            self?.display?.showErrorDialog(error!, retryHandler: nil)
                            return
                    }

                    if (self?.wasteAddress) != nil {
                    self?.display?.successfullyUpdateWasteCalendar(items: wasteCalendarItems, address: address, wasteReminders: wasteReminders)
                    } else {
                        
                        self?.wasteCalendarWorker.getWasteCalendarCategoriesObj(for: (self?.cityContentSharedWorker.getCityID())!, completion: { [weak self] (categories, error) in
                            self?.display?.successfullyInitializeWasteCalendar(items: wasteCalendarItems, address: address, wasteReminders: wasteReminders, categories: categories ?? [])
                        })
                        
                    }
                }
            }
        }
        
        // show info when an existing address is changed {
        if let oldWasteAddress  = self.wasteAddress{
            if oldWasteAddress.houseNumber != self.selectedHouse || oldWasteAddress.streetName != selectedStreet  {
                self.display?.showResetReminderAlert(with: {[weak self] in self?.display?.dismiss()}, okCompletion: {updateCompletion()})
            } else {
                // old address is equal to new one
                self.display?.dismiss()
            }
            return
        }
        
        updateCompletion()
    }

    func displaycategorySelectionViewController(items: [SCModelWasteCalendarItem], address: SCModelWasteCalendarAddress, wasteReminders: [SCHttpModelWasteReminder], categories: [SCModelCategoryObj]) {
        let wasteCalendarViewController = injector.getWasteCalendarViewController(wasteCalendarItems: items, calendarAddress: address, wasteReminders: wasteReminders, item: self.serviceData, month: nil)
        display?.push(viewController: wasteCalendarViewController)
        
        self.wasteCalendarWorker.setCategories(categories)
        
        if let navigationController = self.injector.getCategoryFilterViewController(
            screenTitle: LocalizationKeys.SCWasteAddressPresenter.wc004FilterCategoryTitle.localized(),
            selectBtnText: LocalizationKeys.SCWasteAddressPresenter.wc004FilterCategoryShowResult.localized(),
            selectAllButtonHidden: false,
            filterWorker:self.wasteCalendarWorker,
            preselectedCategories: [],
            delegate: (wasteCalendarViewController as! SCWasteCalendarViewController).presenter as! SCWasteCategorySelectionDelegate) as? UINavigationController {
            wasteCalendarViewController.present(navigationController, animated: true)
        }
    }

    func viewDidLoad() {
        setupUI()
    }

    func viewDidAppear() {}

    func viewWillAppear() {}
}
