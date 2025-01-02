//
//  SCProfilePresenter
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 02.04.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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

