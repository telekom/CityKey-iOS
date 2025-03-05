/*
Created by Rutvik Kanbargi on 13/10/20.
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

import Foundation
import UIKit

protocol SCWasteReminderPresenting: SCPresenting {
    func setDisplay(display: SCWasteReminderDisplaying)
    func update(time: String,
                onPickupDay: Bool,
                onOneDayBeforePickup: Bool,
                onTwoDayBeforePickup: Bool) -> SCHttpModelWasteReminder
    func setReminder(settings: SCHttpModelWasteReminder)
    func getWorker() -> SCWasteReminderWorking
    func isReminderSettingsChanged(settings: SCHttpModelWasteReminder) -> Bool
    func getMoEnegaeSettingInfoText() -> NSMutableAttributedString
    func getPushNotificationSettingInfoText() -> NSMutableAttributedString
    func didTapOnEnableMoengageBtn()
    func didTapOnEnablePushBtn()
}

class SCWasteReminderPresenter {

    private weak var display: SCWasteReminderDisplaying?
    let wasteType: SCWasteCalendarDataSourceItem
    let wasteCalendarWorker: SCWasteCalendarWorking & SCWasteReminderWorking
    let cityContentSharedWorker: SCCityContentSharedWorking
    let privacySettings: SCAppContentPrivacySettingsOberserving
    let injector: SCLegalInfoInjecting
    var reminder: SCHttpModelWasteReminder?

    init(wasteType: SCWasteCalendarDataSourceItem,
         reminders: SCHttpModelWasteReminder?,
         wasteCalendarWorker: SCWasteCalendarWorking & SCWasteReminderWorking,
     cityContentSharedWorker: SCCityContentSharedWorking, privacySettings: SCAppContentPrivacySettingsOberserving, injector: SCLegalInfoInjecting) {
        self.wasteType = wasteType
        self.wasteCalendarWorker = wasteCalendarWorker
        self.cityContentSharedWorker = cityContentSharedWorker
        self.privacySettings = privacySettings
        self.injector = injector
        self.reminder = reminders
        
        // catch all privacy setting changes
        privacySettings.observePrivacySettings(completion: { [weak self ] (moengageOptOut, adjustOptOut) in
            guard let weakSelf = self else { return }
            weakSelf.refreshPushSettingsInfo()
        })

        self.setupNotifications()
    }
    
    private func setupNotifications() {
        SCDataUIEvents.registerNotifications(for: self, on: .appMovedToForeground, with: #selector(appMovedToForeground))
    }

    @objc private func appMovedToForeground() {
        self.refreshPushSettingsInfo()
    }

    func getDefaultSwitchStates() -> (onPickupDay: Bool, onOneDayBeforePickup: Bool, onTwoDayBeforePickup: Bool) {
        guard let reminder = reminder else {
            return (false, false, false)
        }
        return (reminder.sameDay, reminder.oneDayBefore, reminder.twoDaysBefore)
    }

    func getTimeText() -> String {
        return reminder?.remindTime ?? "07:00"
    }
    
    private func isReminderSwitchStateChanged(settings: SCHttpModelWasteReminder) -> Bool {
        settings.sameDay || settings.oneDayBefore || settings.twoDaysBefore
    }
    
    func refreshPushSettingsInfo(){
        SCNotificationManager.shared.isPushEnabled(completion:{(enabled) in
            DispatchQueue.main.async {
                self.display?.updatePushInfoUI(showPushSetting: !enabled, showMoEngageSetting: self.privacySettings.privacyOptOutMoEngage)
            }
        })
    }

}

extension SCWasteReminderPresenter: SCWasteReminderPresenting {

    func isReminderSettingsChanged(settings: SCHttpModelWasteReminder) -> Bool {
        if reminder == nil {
            return isReminderSwitchStateChanged(settings: settings)
        }
        return reminder != settings
    }

    func getWorker() -> SCWasteReminderWorking {
        return wasteCalendarWorker
    }

    func update(time: String, onPickupDay: Bool, onOneDayBeforePickup: Bool, onTwoDayBeforePickup: Bool) -> SCHttpModelWasteReminder {
        return SCHttpModelWasteReminder(wasteTypeId: wasteType.wasteTypeId,
                                             wasteType: wasteType.itemName,
                                             color: reminder?.color ?? "",
                                             remindTime: time,
                                             sameDay: onPickupDay,
                                             oneDayBefore: onOneDayBeforePickup,
                                             twoDaysBefore: onTwoDayBeforePickup)
    }

    func setReminder(settings: SCHttpModelWasteReminder) {
        wasteCalendarWorker.setReminder(for: cityContentSharedWorker.getCityID(), settings: settings)
    }

    func setDisplay(display: SCWasteReminderDisplaying) {
        self.display = display
    }

    func viewDidLoad() {
        display?.setupUI(title: wasteType.itemName,
                         switchStates: getDefaultSwitchStates(),
                         time: getTimeText())
        self.refreshPushSettingsInfo()
    }

    func getMoEnegaeSettingInfoText() -> NSMutableAttributedString {
        let fontBold = UIFont.systemFont(ofSize: 14, weight: .bold)
        let attributedText = NSMutableAttributedString(string: LocalizationKeys.SCWasteReminderPresenting.wc005MoengageLabel.localized(), attributes: [.font: fontBold])
        let font = UIFont.systemFont(ofSize: 14, weight: .regular)
        let infoText = NSAttributedString(string: LocalizationKeys.SCWasteReminderPresenting.wc005MoengageSettingInfoLabel.localized(), attributes: [.font: font])
        attributedText.append(infoText)
        return attributedText
    }

    func getPushNotificationSettingInfoText() -> NSMutableAttributedString {
        let fontBold = UIFont.systemFont(ofSize: 14, weight: .bold)
        let attributedText = NSMutableAttributedString(string: LocalizationKeys.SCWasteReminderPresenting.wc005PushNotificaionLabel.localized(), attributes: [.font: fontBold])
        let font = UIFont.systemFont(ofSize: 14, weight: .regular)
        let infoText = NSAttributedString(string: LocalizationKeys.SCWasteReminderPresenting.wc005PushNotificationSettingInfoLabel.localized(), attributes: [.font: font])
        attributedText.append(infoText)
        return attributedText
    }
    
    func didTapOnEnableMoengageBtn(){
        
//        let dataPrivacyVC = self.injector.getDataPrivacyController(presentationType: .trackingPermission ,insideNavCtrl: true)
//        self.display?.present(viewController: dataPrivacyVC)
    }
    
    func didTapOnEnablePushBtn(){
        UIApplication.shared.open(NSURL(string: UIApplication.openSettingsURLString)! as URL, options: [ : ], completionHandler: { Success in
        })
    }


    func viewWillAppear() {}

    func viewDidAppear() {}
}
