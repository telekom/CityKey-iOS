//
//  SCExportEventOptionsViewController.swift
//  OSCA
//
//  Created by A118572539 on 20/12/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import EventKit
import EventKitUI
import UIKit

enum CalendarType {
    case newCalendar
    case existingCalendar
}

class SCExportEventOptionsViewController: UIViewController {
    
    @IBOutlet weak var calendarNameView: UIView!
    @IBOutlet weak var crossButton: UIImageView!
    @IBOutlet weak var calendarNameTextFiels: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var existingCalendarRadioView: SCToggelLabelView!
    @IBOutlet weak var newCalendarRadioView: SCToggelLabelView!
    @IBOutlet weak var existingCalendarOptionView: SCRadioLabelArrowView!
    @IBOutlet weak var newCalendarColorView: SCRadioLabelArrowView!
    @IBOutlet weak var wasteTypesTableView: UITableView!
    
    var presenter: SCExportEventOptionsViewPresenting!
    var selectedColorName = LocalizationKeys.SCExportEventOptionsViewController.wc006BlueColor.localized()
    var selectedColor = UIColor.systemBlue
    
    override func viewDidLoad() {
        wasteTypesTableView.delegate = self
        wasteTypesTableView.dataSource = self
        calendarNameTextFiels.delegate = self
        presenter.setDisplay(self)
        setupUI()
        setupViews()
        setupAccessibilityIDs()
        
        self.hideKeyboardWhenTappedAround()
        handleDynamicTypeChange()
        SCDataUIEvents.registerNotifications(for: self,
                                             on: UIContentSizeCategory.didChangeNotification,
                                             with: #selector(handleDynamicTypeChange))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshNavigationBarStyle()
        addGestureRecognizer()
        setupAccessibility()
        newCalendarColorView.titleLabel.text = selectedColorName
        newCalendarColorView.radioImageView.image = UIImage(color: selectedColor, size: newCalendarColorView.radioImageView.frame.size).maskWithColor(color: selectedColor)
        setupNavigationBar()
        self.navigationItem.rightBarButtonItem?.tintColor = .ausweisBlue
        self.navigationItem.leftBarButtonItem?.tintColor = .ausweisBlue
        
        if (calendarNameTextFiels.text ?? "").isEmpty {
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else if presenter.getExportWasteCalendarTypes().count != 0 {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    private func setupUI() {
        calendarNameTextFiels.text = LocalizationKeys.SCExportEventOptionsViewController.wc006MyWasteCalendar.localized()
        wasteTypesTableView.estimatedRowHeight = 60.0
        newCalendarColorView.alpha = 0.3
        newCalendarColorView.isUserInteractionEnabled = false
        calendarNameView.alpha = 0.3
        calendarNameView.isUserInteractionEnabled = false
        wasteTypesTableView.rowHeight = UITableView.automaticDimension
    }
    
    private func setupAccessibilityIDs() {
        self.calendarNameView.isAccessibilityElement = true
        self.calendarNameView.accessibilityIdentifier = "view_CalendarName"
        self.crossButton.accessibilityIdentifier = "btn_crossButton"
        self.calendarNameTextFiels.accessibilityIdentifier = "txtfld_CalendarName"
        self.existingCalendarRadioView.isAccessibilityElement = true
        self.existingCalendarRadioView.accessibilityIdentifier = "view_ExistingCalendar"
        self.newCalendarRadioView.isAccessibilityElement = true
        self.newCalendarRadioView.accessibilityIdentifier = "view_NewCalendar"
        self.existingCalendarOptionView.isAccessibilityElement = true
        self.existingCalendarOptionView.accessibilityIdentifier = "view_ExistingCalendarOptions"
        self.newCalendarColorView.isAccessibilityElement = true
        self.newCalendarColorView.accessibilityIdentifier = "view_NewCalendarColor"
        
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    private func setupAccessibility() {
        self.calendarNameView.accessibilityTraits = .staticText
        self.calendarNameView.accessibilityLabel = calendarNameTextFiels.text
        self.calendarNameView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.crossButton.isAccessibilityElement = true
        self.crossButton.accessibilityTraits = .button
        self.crossButton.accessibilityLabel = LocalizationKeys.SCExportEventOptionsViewController.e003ClearButton.localized()
        self.crossButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.calendarNameTextFiels.accessibilityTraits = .staticText
        self.calendarNameTextFiels.accessibilityLabel = calendarNameTextFiels.text
        self.calendarNameTextFiels.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.existingCalendarRadioView.accessibilityLabel = LocalizationKeys.SCExportEventOptionsViewController.wc006ChooseExistingCalendar.localized()
        self.existingCalendarRadioView.accessibilityValue = "accessibility_hint_state_selected".localized()
        self.existingCalendarRadioView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.newCalendarRadioView.accessibilityLabel = LocalizationKeys.SCExportEventOptionsViewController.wc006CreateANewCalendar.localized()
        self.newCalendarRadioView.accessibilityValue = "accessibility_value_deselected".localized()
        self.newCalendarRadioView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.existingCalendarOptionView.accessibilityLabel = presenter.getSelectedCalendar().title
        self.existingCalendarOptionView.accessibilityTraits = .button
        self.existingCalendarOptionView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.newCalendarColorView.accessibilityTraits = .button
        self.newCalendarColorView.accessibilityLabel = selectedColorName
        self.newCalendarColorView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.navigationItem.backButtonTitle?.accessibilityTraits = .button
        self.navigationItem.backButtonTitle?.accessibilityLabel = LocalizationKeys.SCExportEventOptionsViewController.appointmentWebCancelDialogBtnCancel.localized()
        self.navigationItem.backButtonTitle?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        newCalendarColorView.accessibilityTraits = .button
        newCalendarColorView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.navigationItem.rightBarButtonItem?.accessibilityTraits = .button
        self.navigationItem.backButtonTitle?.accessibilityLabel = LocalizationKeys.SCExportEventOptionsViewController.e005AddToCalendar.localized()
        self.navigationItem.backButtonTitle?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.calendarNameView.accessibilityHint = "accessiblity_calendar_nameview_hint".localized()
        self.calendarNameView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        updateAccessibilityRadioButtonStatus()
    }
    
    private func addGestureRecognizer() {
        // Calendar options gesture
        let calendarOptionsGesture = UITapGestureRecognizer(target: self, action: #selector(showCalendarOptions))
        existingCalendarOptionView.addGestureRecognizer(calendarOptionsGesture)
        
        // Color options for new calnedar gesture
        let colorOptionsGesture = UITapGestureRecognizer(target: self, action: #selector(showColorOptions))
        newCalendarColorView.addGestureRecognizer(colorOptionsGesture)
        
        // existingCalendarRadioView gesture
        let existingCalendarRadioViewGesture = UITapGestureRecognizer(target: self, action: #selector(existingCalendarOptionTapped))
        existingCalendarRadioView.addGestureRecognizer(existingCalendarRadioViewGesture)
        
        // newCalendarRadioView gesture
        let newCalendarRadioViewGesture = UITapGestureRecognizer(target: self, action: #selector(newCalendarOptionTapped))
        newCalendarRadioView.addGestureRecognizer(newCalendarRadioViewGesture)
        
        // Cross button
        let crossButtonViewGesture = UITapGestureRecognizer(target: self, action: #selector(crossButtonTapped))
        crossButton.addGestureRecognizer(crossButtonViewGesture)
    }
    
    @objc private func showCalendarOptions() {
        presenter.existingCalendarOptionsVC()
    }
    
    @objc private func showColorOptions() {
        presenter.newCalendarColorOptionsVC(delegate: self)
    }
    
    private func updateAccessibilityRadioButtonStatus() {
        if presenter.getCalendarType() == .existingCalendar {
            existingCalendarRadioView.accessibilityHint = "Radio Button, 1 of 2 \(LocalizationKeys.Accessibility.radioBtnTapHint.localized())" + "accessibility_deselect".localized()
            newCalendarRadioView.accessibilityHint = "Radio Button, 2 of 2 \(LocalizationKeys.Accessibility.radioBtnTapHint.localized())" + "accessibility_select".localized()
            newCalendarColorView.accessibilityHint = "accessibility_hint_disabled".localized()
            calendarNameView.accessibilityHint = "accessibility_hint_disabled".localized()
            existingCalendarOptionView.accessibilityHint = "Double tap to select Calendar"
            
        } else {
            existingCalendarRadioView.accessibilityHint = "Radio Button, 1 of 2 \(LocalizationKeys.Accessibility.radioBtnTapHint.localized())" + "accessibility_select".localized()
            
            newCalendarRadioView.accessibilityHint = "Radio Button, 2 of 2 \(LocalizationKeys.Accessibility.radioBtnTapHint.localized())" + "accessibility_deselect".localized()
            newCalendarColorView.accessibilityHint = "accessibility_change_calendar_color_hint".localized()
            existingCalendarOptionView.accessibilityHint = "accessibility_hint_disabled".localized()
        }
        existingCalendarOptionView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        calendarNameView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        newCalendarRadioView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        newCalendarColorView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        existingCalendarRadioView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
    
    @objc private func existingCalendarOptionTapped() {
        if !(presenter.getCalendarType() == .existingCalendar) {
            presenter.changeCalendarType(type: .existingCalendar)
            if presenter.getExportWasteCalendarTypes().count != 0 {
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
            existingCalendarRadioView.radioToggleImageView.image = UIImage(named: "radiobox-marked")
            existingCalendarRadioView.accessibilityValue = "accessibility_hint_state_selected".localized()
            existingCalendarRadioView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
            newCalendarRadioView.accessibilityValue = "accessibility_value_not_selected".localized()
            newCalendarRadioView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
            newCalendarRadioView.radioToggleImageView.image = UIImage(named: "radiobox-blank")

            existingCalendarOptionView.isUserInteractionEnabled = true
            existingCalendarOptionView.alpha = 1.0
            
            newCalendarColorView.alpha = 0.3
            newCalendarColorView.isUserInteractionEnabled = false
            
            calendarNameView.alpha = 0.3
            calendarNameView.isUserInteractionEnabled = false
            updateAccessibilityRadioButtonStatus()
        }
    }
    
    @objc private func newCalendarOptionTapped() {
        if !(presenter.getCalendarType() == .newCalendar) {
            presenter.changeCalendarType(type: .newCalendar)
            if (calendarNameTextFiels.text ?? "").isEmpty {
                navigationItem.rightBarButtonItem?.isEnabled = false
            } else if presenter.getExportWasteCalendarTypes().count != 0 {
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
            newCalendarRadioView.radioToggleImageView.image = UIImage(named: "radiobox-marked")
            newCalendarRadioView.accessibilityValue = "accessibility_hint_state_selected".localized()
            newCalendarRadioView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
            existingCalendarRadioView.accessibilityValue = "accessibility_value_not_selected".localized()
            existingCalendarRadioView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
            existingCalendarRadioView.radioToggleImageView.image = UIImage(named: "radiobox-blank")
            
            newCalendarColorView.alpha = 1.0
            newCalendarColorView.isUserInteractionEnabled = true
            
            calendarNameView.alpha = 1.0
            calendarNameView.isUserInteractionEnabled = true
            
            existingCalendarOptionView.isUserInteractionEnabled = false
            existingCalendarOptionView.alpha = 0.3
            updateAccessibilityRadioButtonStatus()
        }
    }
    
    @objc private func crossButtonTapped() {
        self.calendarNameTextFiels.text = ""
        self.calendarNameTextFiels.placeholder = LocalizationKeys.SCExportEventOptionsViewController.wc006CalendarName.localized()
        calendarNameTextFiels.becomeFirstResponder()
        crossButton.isHidden = true
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    
    @objc private func tapOnAddButton() {
        presenter.addEventsToCalendar()
    }
    
    @objc private func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupViews() {
        // Existing calendar section
        let defaultCalendar = SCCalendarHelper.shared.getDefaultCalendar()
        existingCalendarRadioView.titleLabel.text = LocalizationKeys.SCExportEventOptionsViewController.wc006ChooseExistingCalendar.localized()
        existingCalendarOptionView.titleLabel.text = defaultCalendar?.title
        if let color = defaultCalendar?.cgColor {
            existingCalendarOptionView.radioImageView.image = UIImage(color: UIColor(cgColor: color), size: existingCalendarOptionView.radioImageView.frame.size).maskWithColor(color: UIColor(cgColor: color))
        }
        existingCalendarOptionView.radioImageView.layer.cornerRadius = existingCalendarOptionView.radioImageView.frame.height/2.0
        existingCalendarOptionView.clipsToBounds = true
        
        // New calendar section
        newCalendarRadioView.radioToggleImageView.image = UIImage(named: "radiobox-blank")
        newCalendarRadioView.titleLabel.text = LocalizationKeys.SCExportEventOptionsViewController.wc006CreateANewCalendar.localized()
        newCalendarColorView.titleLabel.text = LocalizationKeys.SCExportEventOptionsViewController.wc006BlueColor.localized()
        newCalendarColorView.radioImageView.image = UIImage(color: .ausweisBlue, size: newCalendarColorView.radioImageView.frame.size).maskWithColor(color: UIColor.ausweisBlue)
        newCalendarColorView.radioImageView.layer.cornerRadius = newCalendarColorView.radioImageView.frame.height/2.0
        newCalendarColorView.clipsToBounds = true
        
        existingCalendarOptionView.clipsToBounds = true
        existingCalendarOptionView.layer.cornerRadius = 10.0
        
        calendarNameView.clipsToBounds = true
        calendarNameView.layer.cornerRadius = 10.0
        
        newCalendarColorView.clipsToBounds = true
        newCalendarColorView.layer.cornerRadius = 10.0
        
        calendarNameTextFiels.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: calendarNameTextFiels.frame.height))
        calendarNameTextFiels.leftViewMode = .always
    }
    
    private func setupNavigationBar() {
        self.navigationItem.title = LocalizationKeys.SCExportEventOptionsViewController.wc006AddEvents.localized()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: LocalizationKeys.SCExportEventOptionsViewController.wc006AddToCalendar.localized(), style: UIBarButtonItem.Style.done, target: self, action: #selector(tapOnAddButton))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: LocalizationKeys.SCExportEventOptionsViewController.appointmentWebCancelDialogBtnCancel.localized(), style: UIBarButtonItem.Style.plain, target: self, action: #selector(dismissViewController))
        if presenter.getExportWasteCalendarTypes().count == 0 {
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor.calendarColor
            appearance.shadowColor = .clear
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc private func handleDynamicTypeChange() {
        calendarNameTextFiels.adjustsFontForContentSizeCategory = true
        calendarNameTextFiels.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: 32)
        existingCalendarRadioView.setupDynamicFont()
        newCalendarRadioView.setupDynamicFont()
    }
}

extension SCExportEventOptionsViewController: SCExportEventOptionsViewDisplaying {
    func setupUI(title: String, backTitle: String) {
        
    }
    
    func push(viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }

    func present(viewController: UIViewController, completion: (() -> Void)? = nil) {
        present(viewController, animated: true, completion: completion)
    }
    
    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true)
    }
    
    func showSaveEventsAlert() {
        self.showUIAlert(with: LocalizationKeys.SCExportEventOptionsViewController.wc006AlertMessageSuccessfull.localized(), cancelTitle: nil, retryTitle: LocalizationKeys.SCExportEventOptionsViewController.dr004OkButton.localized(), retryHandler: {
            self.dismiss(animated: true, completion: nil)
        }, additionalButtonTitle: nil, additionButtonHandler: nil, alertTitle: LocalizationKeys.SCExportEventOptionsViewController.wc006SuccessfullyExported.localized())
    }
    
    func updateCellWithSelectedCalendar(calendar: EKCalendar) {
        existingCalendarOptionView.titleLabel.text = calendar.title
        existingCalendarOptionView.radioImageView.image = UIImage(color: UIColor(cgColor: calendar.cgColor), size: existingCalendarOptionView.radioImageView.frame.size).maskWithColor(color: UIColor(cgColor: calendar.cgColor))
        self.existingCalendarOptionView.accessibilityLabel = calendar.title
        
    }
    
    func getNewCalendarName() -> String? {
        return calendarNameTextFiels.text
    }
    
    func getNewCalendarColor() -> UIColor {
        return selectedColor
    }
    
    func getNewCalendarColorName() -> String {
        return selectedColorName
    }
}

extension SCExportEventOptionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getExportWasteCalendarTypes().count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SCWasteTypeLabelCell", for: indexPath) as! SCWasteTypeLabelCell
        cell.wasteTypeLabel?.text = presenter.getExportWasteCalendarTypes()[indexPath.row]
        cell.verticalView.backgroundColor = selectedColor
        cell.verticalView.layer.cornerRadius = 2.0
        
        // Accessbility
        cell.wasteTypeLabel.accessibilityTraits = .staticText
        cell.wasteTypeLabel.accessibilityLabel = cell.wasteTypeLabel?.text
        cell.wasteTypeLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension SCExportEventOptionsViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " && range.location == 0 {
            return false
        }
        
        if (string != "") || (calendarNameTextFiels.text?.count ?? 0 > 0 && !(string == "" && range.location == 0)) {
            crossButton.isHidden = false
            if presenter.getExportWasteCalendarTypes().count != 0 {
                navigationItem.rightBarButtonItem?.isEnabled = true
            }
        } else {
            crossButton.isHidden = true
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        return true
    }
}

extension SCExportEventOptionsViewController: SCColorSelectionDelegate {
    
    func selectedColor(color: UIColor, name: String) {
        selectedColor = color
        selectedColorName = name
        self.wasteTypesTableView.reloadData()
    }
}

class EKCalendarChooserCustom: EKCalendarChooser {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.view.subviews.first is UIRefreshControl {
            self.view.subviews.first?.removeFromSuperview()
        }
        navigationController?.setToolbarHidden(true, animated: false)
    }
}
