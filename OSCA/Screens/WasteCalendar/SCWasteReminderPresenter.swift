//
//  SCWasteReminderPresenter.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 13/10/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
