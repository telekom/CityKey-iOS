/*
Created by Rutvik Kanbargi on 10/09/20.
Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 
In accordance with Sections 4 and 6 of the License, the following exclusions apply:

    1. Trademarks & Logos – The names, logos, and trademarks of the Licensor are not covered by this License and may not be used without separate permission.
    2. Design Rights – Visual identities, UI/UX designs, and other graphical elements remain the property of their respective owners and are not licensed under the Apache License 2.0.
    3: Non-Coded Copyrights – Documentation, images, videos, and other non-software materials require separate authorization for use, modification, or distribution.

These elements are not considered part of the licensed Work or Derivative Works unless explicitly agreed otherwise. All elements must be altered, removed, or replaced before use or distribution. All rights to these materials are reserved, and Contributor accepts no liability for any infringing use. By using this repository, you agree to indemnify and hold harmless Contributor against any claims, costs, or damages arising from your use of the excluded elements.

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Rutvik Kanbargi
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

protocol SCWasteAddressDisplaying: SCDisplaying {
    
    func setupNavigationBar(title: String, backTitle: String)
    func setupUI(title: String)
    func updateAddress(street: String, houseNumber: String)
    func updateListViewWith(items: [String])
    func enableSubmitButton()
    func disableSubmitButton()
    func handleStreetTextFieldError(isValid: Bool)
    func handleHouseNumberTextFieldError(validationState: SCWasteAddressHouseNumberValidationState)
    func successfullyUpdateWasteCalendar(items: [SCModelWasteCalendarItem], address: SCModelWasteCalendarAddress, wasteReminders: [SCHttpModelWasteReminder])
    func successfullyInitializeWasteCalendar(items: [SCModelWasteCalendarItem], address: SCModelWasteCalendarAddress, wasteReminders: [SCHttpModelWasteReminder], categories: [SCModelCategoryObj])
    func resetButtonState()
    func showResetReminderAlert(with cancelCompletion: (() -> Void)?, okCompletion: (() -> Void)?)
    func dismiss()
    func setHouseNumberContainerViewHeight()
    func present(viewController: UIViewController)
    func push(viewController: UIViewController)
}

protocol SCWasteAddressViewResultDelegate: AnyObject {
    func setWasteCalendar(items: [SCModelWasteCalendarItem], address: SCModelWasteCalendarAddress, wasteReminders: [SCHttpModelWasteReminder])
}

class SCWasteAddressViewController: UIViewController {

    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var submitBtn: SCCustomButton!
    @IBOutlet weak var streetNameContainerView: UIView!
    @IBOutlet weak var houseNumberContainerView: UIView!

    @IBOutlet weak var houseNumberContainerViewHeight: NSLayoutConstraint!

    private var streetNameTextField: SCTextfieldComponent?
    private var houseNumberTextField: SCTextfieldComponent?
    private var cityTextField: SCTextfieldComponent?
    private let houseNumberViewHeight: CGFloat = 94

    var presenter: SCWasteAddressPresenting?
    weak var delegate: SCWasteAddressViewResultDelegate?

    private var streetNameListView: SCListView?
    private var houseNumberListView: SCListView?
    @IBOutlet weak var closeBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        presenter?.setDisplay(display: self)
        presenter?.viewDidLoad()
        addListView()
        setupAccessibilityIDs()
        setupAccessibility()
        
        self.handleDynamicTypeChange()
                
        NotificationCenter.default.addObserver(self, selector: #selector(handleDynamicTypeChange), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }

    private func addListView() {
        let listView = SCListView(items: presenter?.getStreetList() ?? [], frame: .zero, delegate: self)
        self.view.addSubview(listView)
        listView.translatesAutoresizingMaskIntoConstraints = false

        listView.leadingAnchor.constraint(equalTo: streetNameContainerView.leadingAnchor, constant: 0).isActive = true
        listView.trailingAnchor.constraint(equalTo: streetNameContainerView.trailingAnchor, constant: 0).isActive = true
        listView.topAnchor.constraint(equalTo: streetNameContainerView.bottomAnchor, constant: -31).isActive = true
        listView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        self.view.sendSubviewToBack(listView)
        self.streetNameListView = listView
    }

    private func setupUI() {
        houseNumberTextField?.setEnabled(false)
        houseNumberContainerViewHeight.constant = 0
        houseNumberContainerView.isHidden = true
        cityTextField?.initialText = presenter?.getCityName()
        cityTextField?.setEnabled(false)
        submitBtn.btnState = .disabled
    }
    
    func showHouseNumberListView() {
        let listView = SCListView(items: presenter?.getHouseNumberList() ?? [], frame: .zero, delegate: self)
        self.view.addSubview(listView)
        listView.translatesAutoresizingMaskIntoConstraints = false

        listView.leadingAnchor.constraint(equalTo: houseNumberContainerView.leadingAnchor).isActive = true
        listView.trailingAnchor.constraint(equalTo: houseNumberContainerView.trailingAnchor).isActive = true
        listView.topAnchor.constraint(equalTo: houseNumberContainerView.bottomAnchor, constant: 0).isActive = true
        listView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        self.houseNumberListView = listView
    }

    // TODO: setup accessibility ids for automated testing
    private func setupAccessibilityIDs() {
        navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    private func setupAccessibility() {
        streetNameTextField?.accessibilityTraits = .staticText
        streetNameTextField?.accessibilityLabel = streetNameTextField?.text
        streetNameTextField?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        houseNumberTextField?.accessibilityTraits = .staticText
        houseNumberTextField?.accessibilityLabel = houseNumberTextField?.text
        houseNumberTextField?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        cityTextField?.accessibilityTraits = .staticText
        cityTextField?.accessibilityLabel = cityTextField?.text
        cityTextField?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        closeBtn.accessibilityLabel = "accessibility_btn_close".localized()
        closeBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
    
    @objc private func handleDynamicTypeChange() {
        // Dynamic font
        
        // Setup Dynamic font for Street name
        streetNameTextField?.textField.adjustsFontForContentSizeCategory = true
        streetNameTextField?.textField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 16, maxSize: 25)
        streetNameTextField?.placeholderLabel.adjustsFontForContentSizeCategory = true
        streetNameTextField?.placeholderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 13, maxSize: 25)
        streetNameTextField?.errorLabel.adjustsFontForContentSizeCategory = true
        streetNameTextField?.errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        // Setup Dynamic font for house number
        houseNumberTextField?.textField.adjustsFontForContentSizeCategory = true
        houseNumberTextField?.textField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 16, maxSize: 25)
        houseNumberTextField?.placeholderLabel.adjustsFontForContentSizeCategory = true
        houseNumberTextField?.placeholderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 13, maxSize: 25)
        houseNumberTextField?.errorLabel.adjustsFontForContentSizeCategory = true
        houseNumberTextField?.errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        // Setup Dynamic font for city
        cityTextField?.textField.adjustsFontForContentSizeCategory = true
        cityTextField?.textField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 16, maxSize: 25)
        cityTextField?.placeholderLabel.adjustsFontForContentSizeCategory = true
        cityTextField?.placeholderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 13, maxSize: 25)
        cityTextField?.errorLabel.adjustsFontForContentSizeCategory = true
        cityTextField?.errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        submitBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        submitBtn.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18, maxSize: 30)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let textField as SCTextfieldComponent:
            textField.delegate = self

            switch segue.identifier {
            case "streetNameSegue":
                streetNameTextField = presenter?.configure(textField: textField, segueID: segue.identifier) as? SCTextfieldComponent

            case "houseNameSegue":
                houseNumberTextField = presenter?.configure(textField: textField, segueID: segue.identifier) as? SCTextfieldComponent
                
            case "cityTextSegue":
                cityTextField = presenter?.configure(textField: textField, segueID: segue.identifier) as? SCTextfieldComponent

            default: break
            }

        default:
            break
        }
    }

    @IBAction func didTapOnClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    private func handleTextFieldError(textField: SCTextfieldComponent, showValidationState: Bool, isValid: Bool, message: String) {
        
        textField.validationState = .unmarked
        textField.hideError()

        if showValidationState == true {
            let text = textField.text ?? ""
            guard !(text.isEmpty) else { return }
            
            textField.validationState = isValid ? .ok : .wrong
            
            if !isValid {
                textField.showError(message: message)
            }
        }
    }
    
    private func handleTextFieldErrorAndButtonState(component: SCTextfieldComponent) {
        presenter?.selected(house: component.text ?? "")
        
        let houseNumberValidationState = presenter?.selectedHouseNumberValidationState() ?? .valid

        handleTextFieldError(textField: component,
                             showValidationState: houseNumberValidationState != .notVerifiable,
                             isValid: houseNumberValidationState == .valid,
                             message: LocalizationKeys.SCWasteAddressViewController.wc004FtuHouseError.localized())
        presenter?.handleSubmitButtonState()
    }

    private func hideListView(listView: SCListView?) {
        if let listView = listView {
            self.view.sendSubviewToBack(listView)
            listView.alpha = 0
        }
    }

    @objc func filterStreetWith(component: SCTextfieldComponent) {
        if let text = component.text {
            presenter?.filterStreet(name: text)
        }
    }

    @IBAction func didTapOnSubmit(_ sender: UIButton) {
        submitBtn.btnState = .progress
        presenter?.updateWasteCalendar()
    }
}

extension SCWasteAddressViewController: SCListViewDelegate {

    func didSelect(item: String, component: SCListView) {
        if component == streetNameListView {
            presenter?.isAddressSelectedFromList = true
            streetNameTextField?.text = item
            presenter?.selected(street: item)
            streetNameTextField?.validationState = .ok
            streetNameTextField?.hideError()
            hideListView(listView: streetNameListView)
            houseNumberTextField?.setEnabled(true)
            streetNameTextField?.resignResponder()
            setHouseNumberContainerViewHeight()
            houseNumberTextField?.text = ""
            hideListView(listView: houseNumberListView)
            if presenter?.isHouseNumberListEmpty() == true {
                presenter?.handleSubmitButtonState()
            } else {
                houseNumberTextField?.becomeResponder()
                UIAccessibility.post(notification: .layoutChanged, argument: houseNumberTextField)
            }
        } else if let houseTextField = houseNumberTextField {
            houseTextField.text = item
            presenter?.selected(house: item)
            houseTextField.validationState = .ok
            houseTextField.hideError()
            hideListView(listView: houseNumberListView)
            houseTextField.resignResponder()
            handleTextFieldErrorAndButtonState(component: houseTextField)
            UIAccessibility.post(notification: .layoutChanged, argument: submitBtn)
        }
    }

    func didScroll(component: SCListView) {
        if component == streetNameListView {
            streetNameTextField?.resignResponder()
        } else {
            houseNumberTextField?.resignResponder()
        }
    }
}

extension SCWasteAddressViewController: SCTextfieldComponentDelegate {
    func textFieldComponentShouldReturn(component: SCTextfieldComponent) -> Bool {
        if component == streetNameTextField {
            if presenter?.isHouseNumberListEmpty() == false {
                houseNumberTextField?.becomeResponder()
            } else {
                streetNameTextField?.resignResponder()
            }
        } else if component == houseNumberTextField {
            houseNumberTextField?.resignResponder()
        }

        return true
    }

    func textFieldComponentEditingBegin(component: SCTextfieldComponent) {
        if component == streetNameTextField, let listView = streetNameListView {
            self.view.bringSubviewToFront(listView)
            listView.alpha = component.text == "" ? 0 : 1
        }
    }

    func textFieldComponentDidChange(component: SCTextfieldComponent) {
        if component == streetNameTextField, let text = component.text {
            if text == "" {
                updateListViewWith(items: [])
                presenter?.resetAddressList()
                streetNameListView?.alpha = 0
                presenter?.selected(street: text)
                streetNameTextField?.hideError()
                streetNameTextField?.validationState = .unmarked
                return
            }

            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(filterStreetWith(component:)), object: component)
            debugPrint("Canceled previous request")
            perform(#selector(filterStreetWith(component:)), with: component, afterDelay: 0.5)
            debugPrint("Initiated new request")
            updateListViewWith(items: [])
            presenter?.resetAddressList()
//            streetNameListView?.alpha = 1
            presenter?.isAddressSelectedFromList = false
            houseNumberTextField?.initialText = ""
            houseNumberTextField?.setEnabled(false)
            houseNumberTextField?.hideError()
            houseNumberTextField?.validationState = .unmarked
        } else if component == houseNumberTextField, component.text != "" {
            if let newHouseList = presenter?.filterHouseNumber(number: component.text ?? "") {
                if let houseListView = houseNumberListView, newHouseList.count > 0 {
                    houseNumberListView?.update(items: newHouseList)
                    self.view.bringSubviewToFront(houseListView)
                    houseListView.alpha = 1
                } else if newHouseList.count > 0 {
                    showHouseNumberListView()
                    houseNumberListView?.update(items: newHouseList)
                    accessibilityFocus(listView: houseNumberListView)
                }
            }
            handleTextFieldErrorAndButtonState(component: component)
        } else {
            presenter?.selected(house: "")
            houseNumberTextField?.hideError()
            houseNumberTextField?.validationState = .unmarked
            hideListView(listView: houseNumberListView)
            handleTextFieldErrorAndButtonState(component: component)
        }
    }
    
    fileprivate func accessibilityFocus(listView: SCListView?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            UIAccessibility.post(notification: .layoutChanged,
                                 argument: listView)
        })
    }

    func textFieldComponentEditingEnd(component: SCTextfieldComponent) {
        if component == streetNameTextField {
            presenter?.selected(street: component.text ?? "")
            handleTextFieldError(textField: component,
                                 showValidationState: true,
                                 isValid: presenter?.isSelectedStreetValid() ?? false,
                                 message: LocalizationKeys.SCWasteAddressViewController.wc004FtuStreetError.localized())
        } else if component == houseNumberTextField {
            presenter?.selected(house: component.text ?? "")
            
            
            let houseNumberValidationState = presenter?.selectedHouseNumberValidationState() ?? .valid
            handleTextFieldError(textField: component,
                                 showValidationState: houseNumberValidationState != .notVerifiable,
                                 isValid: houseNumberValidationState == .valid,                            message: LocalizationKeys.SCWasteAddressViewController.wc004FtuHouseError.localized())
            
        }

        presenter?.handleSubmitButtonState()
    }
}

extension SCWasteAddressViewController: SCWasteAddressDisplaying {

    func setupNavigationBar(title: String, backTitle: String) {
//        bannerImage.image = bannerImage.image?.tintedHeaderImage(tintColor: UIColor(named: "CLR_OSCA_BLUE")!)
        bannerImage.backgroundColor = kColor_cityColor
        self.navigationItem.title = title
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: backTitle, style: .plain, target: nil, action: nil)
    }

    func setupUI(title: String) {
//        submitBtn.customizeBlueStyle()
        submitBtn.customizeCityColorStyle()
        submitBtn.titleLabel?.adaptFontSize()
        submitBtn.setTitle(title, for: .normal)
    }

    func updateAddress(street: String, houseNumber: String) {
        streetNameTextField?.initialText = street
        houseNumberTextField?.initialText = houseNumber
        houseNumberTextField?.setEnabled(true)
    }

    func updateListViewWith(items: [String]) {
        streetNameListView?.update(items: items)
        streetNameListView?.alpha = items.count > 0 ? 1 : 0
        accessibilityFocus(listView: streetNameListView)
    }

    func enableSubmitButton() {
        submitBtn.btnState = .normal
    }

    func disableSubmitButton() {
        submitBtn.btnState = .disabled
    }

    func handleStreetTextFieldError(isValid: Bool) {
        if let streetTF = streetNameTextField {
            handleTextFieldError(textField: streetTF,
                                 showValidationState: true,
                                 isValid: isValid,
                                 message: LocalizationKeys.SCWasteAddressViewController.wc004FtuStreetError.localized())
        }
    }

    func handleHouseNumberTextFieldError(validationState: SCWasteAddressHouseNumberValidationState) {
        if let houseTF = houseNumberTextField {
            handleTextFieldError(textField: houseTF,
                                 showValidationState: validationState != .notVerifiable,
                                 isValid: validationState == .valid,
                                 message: LocalizationKeys.SCWasteAddressViewController.wc004FtuHouseError.localized())
        }
    }

    func setHouseNumberContainerViewHeight() {
        if presenter?.isHouseNumberListEmpty() == true {
            houseNumberContainerViewHeight.constant = 0
            houseNumberContainerView.isHidden = true
        } else {
            houseNumberContainerViewHeight.constant = houseNumberViewHeight
            houseNumberContainerView.isHidden = false
        }
    }

    func resetButtonState() {
        submitBtn.btnState = .normal
    }

    func successfullyUpdateWasteCalendar(items: [SCModelWasteCalendarItem], address: SCModelWasteCalendarAddress, wasteReminders: [SCHttpModelWasteReminder]) {
        dismiss(animated: true, completion: nil)
        delegate?.setWasteCalendar(items: items, address: address, wasteReminders: wasteReminders)
    }
    
    func successfullyInitializeWasteCalendar(items: [SCModelWasteCalendarItem], address: SCModelWasteCalendarAddress, wasteReminders: [SCHttpModelWasteReminder], categories: [SCModelCategoryObj]) {
        self.presenter?.displaycategorySelectionViewController(items: items, address: address, wasteReminders: wasteReminders, categories: categories)
    }
    
    func present(viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
    
    func push(viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: false)
    }
    
    func showResetReminderAlert(with cancelCompletion: (() -> Void)? = nil, okCompletion: (() -> Void)? = nil) {


        let alert = UIAlertController(title: LocalizationKeys.SCWasteAddressViewController.wc004ChangeAddressResetReminderTitle.localized(),
                                      message: LocalizationKeys.SCWasteAddressViewController.wc004ChangeAddressResetReminderInfo.localized(),
                                      preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: LocalizationKeys.SCWasteAddressViewController.wc004ChangeAddressResetReminderCancel.localized(), style: .cancel, handler: { (action) -> Void in
            DispatchQueue.main.async {
                cancelCompletion?()
            }})
        let ok = UIAlertAction(title: LocalizationKeys.SCWasteAddressViewController.wc004ChangeAddressResetReminderOk.localized(), style: .default, handler: { (action) -> Void in
            DispatchQueue.main.async {
                okCompletion?()
            }})
        
        alert.addAction(cancel)
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func dismiss(){
        self.dismiss(animated: true, completion: nil)
    }
}
