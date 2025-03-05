/*
Created by Robert Swoboda - Telekom on 02.04.19.
Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Robert Swoboda
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

protocol SCProfileDisplaying: AnyObject, SCDisplaying  {
    func setResidenceName(_ residenceName: String)
    func setBirthDate(_ birthDate: String)
    func setEmail(_ email: String)
    func setPassword(_ password: String)
    func setAppPreviewMode(_ isCSPUser: Bool, isPreviewMode: Bool)

    func dismiss(completion: (() -> Void)?)
    func push(viewController: UIViewController)
    
    func endRefreshing()
    
    func setLogoutButtonState(_ state : SCCustomButtonState)

}

protocol SCProfilePresenting: SCPresenting {
    func setDisplay(_ display: SCProfileDisplaying)
    
    func closeButtonWasPressed()
    func editAccountButtonWasPressed()
    func editPersonalDataButtonWasPressed()
    func logoutButtonWasPressed()
    func helpFAQWasPressed()
    func imprintButtonWasPressed()
    func securityButtonWasPressed()
    func dataPrivacySettingsButtonWasPressed()
    func accessibilityStatementButtonWasPressed()
    func feedbackWasPressed()
    func softwareLicenseWasPressed()
    func refreshData()
}

class SCProfilePresenter {
    
    weak private var display: SCProfileDisplaying?
    
    private let profileWorker: SCProfileWorking
    private let userContentSharedWorker: SCUserContentSharedWorking
    private let appContentSharedWorker: SCAppContentSharedWorking
    private let authProvider: SCLogoutAuthProviding & SCLoginAuthProviding
    private let injector: SCProfileInjecting & SCToolsShowing & SCLegalInfoInjecting & SCAdjustTrackingInjection & SCWebContentInjecting & SCToolsInjecting
    
    private var email: String?
    private var postcode: String?
    private var profile: SCModelProfile?
    private let widgetUtility: WidgetUtility

    init(profileWorker: SCProfileWorking, userContentSharedWorker: SCUserContentSharedWorking, appContentSharedWorker: SCAppContentSharedWorking, authProvider: SCLogoutAuthProviding & SCLoginAuthProviding, injector: SCProfileInjecting & SCToolsShowing & SCLegalInfoInjecting & SCAdjustTrackingInjection & SCWebContentInjecting & SCToolsInjecting, widgetUtility: WidgetUtility = WidgetUtility()) {
        
        self.profileWorker = profileWorker
        self.userContentSharedWorker = userContentSharedWorker
        self.appContentSharedWorker = appContentSharedWorker
        self.authProvider = authProvider
        self.injector = injector
        self.widgetUtility = widgetUtility
        
        self.setupNotifications()
    }
    
    deinit {
        SCDataUIEvents.discardNotifications(for: self)
    }
    
    private func setupNotifications() {
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeUserDataState, with: #selector(onDidReceiveUserData))
        SCDataUIEvents.registerNotifications(for: self, on: .userDidSignOut, with: #selector(onDidReceiveUserLoggedOut))
    }
    
    @objc private func onDidReceiveUserData() {
        debugPrint("SCProfilePresenter->onDidReceiveUserData")
        self.display?.endRefreshing()
        self.updateContent()
    }
    
    @objc private func onDidReceiveUserLoggedOut() {
        self.display?.dismiss(completion: {
            if self.authProvider.logoutReason() != .accountDeleted{
                self.injector.showProfile()
            }
        })
    }
    
    private func updateContent() {
        debugPrint("SCProfilePresenter->updateContent")

        guard let userData = self.userContentSharedWorker.getUserData() else {
            self.triggerUserDataUpdate()
            return
        }
        self.updateUI(profile: userData.profile)
        self.email = userData.profile.email
        self.postcode = userData.profile.postalCode
        self.profile = userData.profile
        SCUserDefaultsHelper.setProfile(profile: self.profile!)
    }
    
    private func triggerUserDataUpdate() {
        debugPrint("SCProfilePresenter->triggerUserDataUpdate")
        
        if authProvider.isUserLoggedIn(){
            self.userContentSharedWorker.triggerUserDataUpdate { (error) in
                
                self.display?.endRefreshing()
                
                if let error = error {
                    self.display?.showErrorDialog(error,
                                                  retryHandler : { self.triggerUserDataUpdate() },
                                                  additionalButtonTitle: LocalizationKeys.Profile.p001ProfileBtnLogout.localized(),
                                                  additionButtonHandler : {self.logout()})
                }
            }
       }
    }
    
    private func updateUI(profile: SCModelProfile) {
        let residenceName = profile.postalCode + " " + profile.cityName
        self.display?.setResidenceName(residenceName)
        
        var dobText = ""
        if let birthdate = profile.birthdate {
            dobText = birthdayStringFromDate(birthdate: birthdate)
        } else {
            dobText = LocalizationKeys.Profile.p001ProfileNoDateOfBirthAdded.localized()
        }
        
        self.display?.setBirthDate(dobText)
        self.display?.setEmail(profile.email)
        self.display?.setPassword("••••••••••••••••••••")
        self.display?.setAppPreviewMode(profile.isCspUser ?? false, isPreviewMode: isPreviewMode)
    }
    
    private func clearUI() {
        
        self.display?.setResidenceName("")
        self.display?.setBirthDate("")
        self.display?.setEmail("")
        self.display?.setPassword("")
    }

    private func stringFromBirthDate(_ date: Date) -> String {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        return formatter.string(from: date)
    }
    
    private func logout(){
        self.display?.setLogoutButtonState(.progress)
        self.authProvider.logout(logoutReason: .initiatedByUser,completion:  {
            self.display?.setLogoutButtonState(.normal)
            self.display?.dismiss(completion: {
                self.widgetUtility.reloadAllTimeLines()
                self.injector.showProfile()
            })
        })
    }
    
    private func updatePersonalDetailsContent() {
        debugPrint("SCProfilePresenter->updatePersonalDetailsContent")

        self.profile = SCUserDefaultsHelper.getProfile()
        self.updateUI(profile: self.profile!)
    }
}

extension SCProfilePresenter: SCPresenting {
    func viewDidLoad() {
        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.openProfile)
        self.clearUI()
        self.updateContent()
        self.display?.setLogoutButtonState(.normal)
    }
    
    func viewWillAppear() {
        self.updatePersonalDetailsContent()
    }
    
    func viewDidAppear() {
    }
}

extension SCProfilePresenter : SCProfilePresenting {
    
    func setDisplay(_ display: SCProfileDisplaying) {
        self.display = display
    }
    
    func closeButtonWasPressed() {
        self.display?.dismiss(completion: nil)
    }
    
    func editAccountButtonWasPressed() {
        self.presentUserAccountEditing()
    }
    
    func editPersonalDataButtonWasPressed() {
        self.presentPersonalDataEditing()
    }

    func helpFAQWasPressed() {
        self.presentHelpFAQ()
    }

    func imprintButtonWasPressed() {
        self.presentImprint()
    }
    
    func securityButtonWasPressed() {
         self.presentPrivacy()
    }
    
    func dataPrivacySettingsButtonWasPressed() {
     
        self.presentPrivacySettings()
    }
    
    func accessibilityStatementButtonWasPressed() {
        self.presentAccessibilityStatement()
    }
    
    func feedbackWasPressed() {
        self.presentFeedbackVC()
    }
    
    func softwareLicenseWasPressed() {
        self.presentSoftwareLicenseVC()
    }
    
    func logoutButtonWasPressed() {
        //self.injector.trackEvent(eventName: "ClickLogoutBtn")
        self.logout()
    }
    
    func refreshData() {
        self.triggerUserDataUpdate()
    }
}

extension SCProfilePresenter {
    
    internal func presentUserAccountEditing() {
        self.display?.push(viewController: self.injector.getProfileEditOverviewViewController(email: self.email ?? ""))
    }
    
    internal func presentPersonalDataEditing() {
        self.profile = SCUserDefaultsHelper.getProfile()
        self.display?.push(viewController: self.injector.getProfileEditPersonalDataOverviewViewController(postcode: self.profile?.postalCode ?? "", profile: self.profile!))

    }
    
    internal func presentHelpFAQ() {
                
        var helpURL = "https://citykey.app/faq"
        if SCUtilities.preferredContentLanguage() == "en" {
            helpURL.append("-\(SCUtilities.preferredContentLanguage())")
        }
        SCInternalBrowser.showURL(helpURL.absoluteUrl(), withBrowserType: .safari,
                                  title: LocalizationKeys.Profile.p001ProfileHelpWebviewTitle.localized())
        
    }

    
    internal func presentImprint() {
        if let legalNotice = self.appContentSharedWorker.getLegalNotice(){
            SCInternalBrowser.showURL(legalNotice.absoluteUrl(), withBrowserType: .safari,
                                      title: LocalizationKeys.Profile.i001ImprintTitle.localized())
        }
    }

    internal func presentPrivacy() {
        
//      let dataPrivacy = self.injector.getDataPrivacyController(presentationType: .dataPrivacy, insideNavCtrl: false)
        let dataPrivacy = self.injector.getDataPrivacyController(preventSwipeToDismiss: false, shouldPushSettingsController: true)
        self.display?.push(viewController: dataPrivacy)
    }

    internal func presentPrivacySettings() {
        
        let dataPrivacy = self.injector.getDataPrivacySettingsController(shouldPushDataPrivacyController: true, preventSwipeToDismiss: false, isFirstRunSettings: false, completionHandler: nil)
        self.display?.push(viewController: dataPrivacy)
    }
    

    internal func presentAccessibilityStatement() {
        
        let fileName =  "accessibility_stmt_\(SCUtilities.preferredContentLanguage()).html"
        let filePath = "\(Bundle.main.bundlePath)/\(fileName)"
        if let htmlString = try? String(contentsOfFile: filePath) {
            let accessibilityStmtViewController = self.injector.getWebContentViewController(forHtmlString: htmlString,
                                                                                            title: LocalizationKeys.Profile.p001ProfileAccessibilityStmtWebviewTitle.localized(),
                                                                                            insideNavCtrl: false)
            self.display?.push(viewController: accessibilityStmtViewController)
        }

    }
    
    internal func presentFeedbackVC() {
        let feedbackVC = self.injector.getFeedbackController()
        self.display?.push(viewController: feedbackVC)
    }
    
    internal func presentSoftwareLicenseVC() {
        let fileName =  "software_license_\(SCUtilities.preferredContentLanguage()).html"
        let filePath = "\(Bundle.main.bundlePath)/\(fileName)"
        if let htmlString = try? String(contentsOfFile: filePath) {
            let webContentController = self.injector.getTextInWebViewContentViewController(forHtmlString: htmlString,
                                                                                           title: LocalizationKeys.Profile.p001ProfileSoftwareLicenseTitle.localized(),
                                                                                           insideNavCtrl: false)
            self.display?.push(viewController: webContentController)
            
        }
    }

}

