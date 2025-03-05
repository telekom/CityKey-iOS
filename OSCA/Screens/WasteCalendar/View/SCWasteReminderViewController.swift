/*
Created by Rutvik Kanbargi on 12/10/20.
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

protocol SCWasteReminderResultDelegate {
    func update(settings: SCHttpModelWasteReminder?, worker: SCWasteReminderWorking)
}

protocol SCWasteReminderDisplaying: AnyObject {
    func setupUI(title: String, switchStates: (onPickupDay: Bool, onOneDayBeforePickup: Bool, onTwoDayBeforePickup: Bool), time: String)
    func updatePushInfoUI(showPushSetting: Bool, showMoEngageSetting: Bool)
    func present(viewController: UIViewController)
}

class SCWasteReminderViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!

    @IBOutlet weak var selectTimeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeStackView: UIStackView!

    @IBOutlet weak var pickupDayLabel: UILabel!
    @IBOutlet weak var pickupDaySwitch: UISwitch!
    
    @IBOutlet weak var oneDayBeforePickupLabel: UILabel!
    @IBOutlet weak var oneDayBeforePickupSwitch: UISwitch!

    @IBOutlet weak var twoDayBeforePickupLabel: UILabel!
    @IBOutlet weak var twoDayBeforePickupSwitch: UISwitch!

    // Handles the user interaction for reminder settings
    @IBOutlet weak var reminderSettingContainerView: UIView!

    @IBOutlet weak var datePickerStackView: UIStackView!
    @IBOutlet weak var datePicker: UIDatePicker!

    // container stackview for Moenage and Push notification setting view
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var noteHintLabel: UILabel!
    
    // stackview for push notification setting view to hide/view settings
    @IBOutlet weak var pushNotificationSettingStackView: UIStackView!
    @IBOutlet weak var pushNotificationInformationLabel: UILabel!
    @IBOutlet weak var pushNotificationSettingButton: SCCustomButton!

    // stackview for disclaimer text view to hide/view settings
    @IBOutlet weak var disclaimerStackView: UIStackView!
    @IBOutlet weak var disclaimerTextLabel: UILabel!
    
    var presenter: SCWasteReminderPresenting?
    var delegate: SCWasteReminderResultDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUISwitch()
        presenter?.setDisplay(display: self)
        presenter?.viewDidLoad()
        addTapGesture()
        setupAccessibilityIDs()
        setupAccessibility()
        self.handleDynamicTypeChange()

        NotificationCenter.default.addObserver(self, selector: #selector(handleDynamicTypeChange), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    @objc private func handleDynamicTypeChange() {
        // Dynamic font
        navigationItem.backButtonTitle = LocalizationKeys.Common.navigationBarBack.localized()
        
        self.headerLabel.adjustsFontForContentSizeCategory = true
        self.headerLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .headline, size: 17, maxSize: nil)
        self.selectTimeLabel.adjustsFontForContentSizeCategory = true
        self.selectTimeLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: 30)
        self.timeLabel.adjustsFontForContentSizeCategory = true
        self.timeLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: 30)
        self.pickupDayLabel.adjustsFontForContentSizeCategory = true
        self.pickupDayLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: 30)
        self.oneDayBeforePickupLabel.adjustsFontForContentSizeCategory = true
        self.oneDayBeforePickupLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: 30)
        self.twoDayBeforePickupLabel.adjustsFontForContentSizeCategory = true
        self.twoDayBeforePickupLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: 30)
        self.noteHintLabel.adjustsFontForContentSizeCategory = true
        self.noteHintLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .headline, size: 17, maxSize: nil)
        self.disclaimerTextLabel.adjustsFontForContentSizeCategory = true
        self.disclaimerTextLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 14, maxSize: nil)
        self.pushNotificationInformationLabel.adjustsFontForContentSizeCategory = true
        self.pushNotificationInformationLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16, maxSize: nil)
        self.pushNotificationSettingButton.titleLabel?.adjustsFontForContentSizeCategory = true
        self.pushNotificationSettingButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 15, maxSize: nil)
        
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        didTapOnBack()
    }

    private func setupAccessibilityIDs() {
        navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    private func setupAccessibility() {
        headerLabel.accessibilityTraits = .header
        headerLabel.accessibilityLabel = headerLabel.text
        headerLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        noteHintLabel.accessibilityTraits = .header
        noteHintLabel.accessibilityLabel = noteHintLabel.text
        noteHintLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnTimeView))
        timeStackView.addGestureRecognizer(tapGesture)
    }
    
    private func setupUISwitch() {
        pickupDaySwitch.customise(tintColor: UIColor.switchStateOn,
                                  backgroundColor: UIColor.switchStateOff)
        oneDayBeforePickupSwitch.customise(tintColor: UIColor.switchStateOn,
                                           backgroundColor: UIColor.switchStateOff)
        twoDayBeforePickupSwitch.customise(tintColor: UIColor.switchStateOn,
                                           backgroundColor: UIColor.switchStateOff)
    }

    @objc private func didChangeTime(picker: UIDatePicker) {
        timeLabel.text = getTime(_for: datePicker.date)
    }

    @objc func didTapOnTimeView() {
        let isHidden = !datePicker.isHidden
        datePicker.isHidden = isHidden
        datePickerStackView.isHidden = isHidden
        if datePicker.isHidden {
            timeLabel.textColor = UIColor(named: "CLR_LABEL_TEXT_BLACK")
        } else {
            timeLabel.textColor = kColor_cityColor
        }
    }

    @IBAction func didTapOnMoengageSettings(_ sender: Any) {
        self.presenter?.didTapOnEnableMoengageBtn()
    }
    
    @IBAction func didTapOnPushSettings(_ sender: Any) {
        self.presenter?.didTapOnEnablePushBtn()
    }
    
    func didTapOnBack() {
        guard let presenter = presenter else {
            return
        }

        let settings = presenter.update(time: getTime(_for: datePicker.date),
                                        onPickupDay: pickupDaySwitch.isOn,
                                        onOneDayBeforePickup: oneDayBeforePickupSwitch.isOn,
                                        onTwoDayBeforePickup: twoDayBeforePickupSwitch.isOn)
        if presenter.isReminderSettingsChanged(settings: settings) {
            presenter.setReminder(settings: settings)
            delegate?.update(settings: settings, worker: presenter.getWorker())
        }
    }
}

extension SCWasteReminderViewController: SCWasteReminderDisplaying {

    func setupUI(title: String,
                 switchStates: (onPickupDay: Bool, onOneDayBeforePickup: Bool, onTwoDayBeforePickup: Bool),
                 time: String) {
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.datePickerMode = .time
        datePicker.locale = Locale(identifier: "en_GB")
        datePicker.isHidden = true
        datePickerStackView.isHidden = true
        datePicker.setDate(getTime(_for: time) ?? Date(), animated: false)
        datePicker.addTarget(self, action: #selector(didChangeTime(picker:)), for: .valueChanged)

        navigationItem.title = title

        headerLabel.text = "wc_005_header_label".localized()
        selectTimeLabel.text = "wc_005_time_label".localized()
        timeLabel.text = time
        pickupDayLabel.text = "wc_005_same_day_label".localized()
        pickupDaySwitch.onTintColor = UIColor(hexString: " #239D1D")
        pickupDaySwitch.setOn(switchStates.onPickupDay, animated: false)

        oneDayBeforePickupLabel.text = "wc_005_day_before_label".localized()
        oneDayBeforePickupSwitch.onTintColor = UIColor(hexString: " #239D1D")
        oneDayBeforePickupSwitch.setOn(switchStates.onOneDayBeforePickup, animated: false)

        twoDayBeforePickupLabel.text = "wc_005_two_days_before_label".localized()
        twoDayBeforePickupSwitch.onTintColor = UIColor(hexString: " #239D1D")
        twoDayBeforePickupSwitch.setOn(switchStates.onTwoDayBeforePickup, animated: false)

        noteHintLabel.text = "dialog_title_note".localized()
        noteHintLabel.adaptFontSize()

        pushNotificationInformationLabel.attributedText = presenter?.getPushNotificationSettingInfoText()
        pushNotificationInformationLabel.adaptFontSize()
        pushNotificationSettingButton.customizeBlueStyle()
        pushNotificationSettingButton.setTitle("wc_005_push_notificaion_setting_btn".localized(), for: .normal)

        disclaimerTextLabel.text = "wc_005_push_notification_disclaimer".localized()
        disclaimerTextLabel.adaptFontSize()
        
        reminderSettingContainerView.alpha = 0.2
    }
    
    func updatePushInfoUI(showPushSetting: Bool, showMoEngageSetting: Bool) {
    
        disclaimerTextLabel.isHidden = false
        noteHintLabel.isHidden = false && !showPushSetting
        pushNotificationInformationLabel.isHidden = !showPushSetting
        pushNotificationSettingButton.isHidden = !showPushSetting
        reminderSettingContainerView.alpha = !showPushSetting ? 1.0 : 0.2
        reminderSettingContainerView.isUserInteractionEnabled = !showPushSetting
    }
    
    func present(viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }

    
}
