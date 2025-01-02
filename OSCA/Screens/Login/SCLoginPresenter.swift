//
//  SCLoginPresenter.swift
//  SmartCity
//
//  Created by Michael on 29.05.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

struct SCLoginValidationResult {
    let allValid: Bool
    let emailResult: SCValidationResult?
    let passwordResult: SCValidationResult?
}

protocol SCLoginDisplaying: AnyObject, SCDisplaying {
    func setupNavigationBar(title: String, backTitle: String)
    func setupLoginBtn(title: String)
    func setupRememberLoginBtn(title: String)
    func setupRegisterBtn(title: String, linkTitle: String)
    func setupRecoverLoginBtn(title: String)
    func setupEMailField(title: String)
    func setupPasswordField(title: String)
    
    func refreshTopPlaceholderLabel()
    func showPWDError(message: String)
    func hidePWDError()
    func showEMailError(message: String)
    func hideEMailError()
    func showInfoText(message: String)
    func hideInfoText()

    func showPasswordSelected(_ selected: Bool)
    func showRememberLoginSelected(_ selected: Bool)

    func eMailFieldContent() -> String?
    func pwdFieldContent() -> String?

    func presentOnTop(viewController: UIViewController, completion: (() -> Void)?)
    func present(viewController: UIViewController)
    func push(viewController: UIViewController)
    func navigationController() -> UINavigationController?
    
    func passwordFieldMaxLenght(_ lenght : Int)
    func eMailFieldMaxLenght(_ lenght : Int)

    func setLoginButtonState(_ state : SCCustomButtonState)
    func loginButtonState() -> SCCustomButtonState
}

protocol SCLoginProviding {
    var completionOnSuccess: (() -> Void)? {get set}
    var completionOnCancel: (() -> Void)? {get set}
    var dismissAfterSuccess: Bool {get set}
}

protocol SCLoginPresenting: SCPresenting, SCLoginProviding {
    func setDisplay(_ display: SCLoginDisplaying)
    
    func registerWasPressed()
    func recoverPwdWasPressed()
    func rememberLoginWasPressed()
    func pwdShowPasswordWasPressed()
    func loginWasPressed()
    func cancelWasPressed()
    
    func helpFAQWasPressed()
    func imprintButtonWasPressed()
    func securityButtonWasPressed()
    func dataPrivacySettingsButtonWasPressed()
    func accessibilityStatementButtonWasPressed()
    func feedbackWasPressed()
    func softwareLicensekWasPressed()
    
    func eMailFieldDidBeginEditing()
    func eMailFieldDidChange()
    func passwordFieldDidBeginEditing()
    func passwordFieldDidChange()
    
    func isLoginRemembered() -> Bool
}

class SCLoginPresenter {

    weak private var display : SCLoginDisplaying?
    
    private let loginWorker: SCLoginWorking
    private let injector: SCLoginInjecting & SCToolsInjecting & SCLegalInfoInjecting & SCAdjustTrackingInjection & SCRegistrationInjecting & SCServicesInjecting & SCWebContentInjecting
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let userContentSharedWorker: SCUserContentSharedWorking
    private let refreshHandler : SCSharedWorkerRefreshHandling
    private let appContentSharedWorker: SCAppContentSharedWorking
    
    private weak var presentedVC: UIViewController?

    var completionOnSuccess: (() -> Void)? = nil
    var completionOnCancel: (() -> Void)? = nil

    var dismissAfterSuccess: Bool = true
    private var widgetUtility: WidgetUtility
    var showPwdSelected: Bool = false {
        didSet {
            self.display?.showPasswordSelected(showPwdSelected)
        }
    }

    var rememberLoginSelected: Bool = false {
        didSet {
            self.display?.showRememberLoginSelected(rememberLoginSelected)
        }
    }
    

    init(loginWorker: SCLoginWorking, userContentSharedWorker: SCUserContentSharedWorking, appContentSharedWorker: SCAppContentSharedWorking, cityContentSharedWorker: SCCityContentSharedWorking, injector: SCLoginInjecting & SCToolsInjecting & SCLegalInfoInjecting & SCAdjustTrackingInjection & SCRegistrationInjecting & SCServicesInjecting & SCWebContentInjecting, refreshHandler : SCSharedWorkerRefreshHandling, widgetUtility: WidgetUtility = WidgetUtility()) {
        
        self.loginWorker = loginWorker
        self.injector = injector
        self.cityContentSharedWorker = cityContentSharedWorker
        self.appContentSharedWorker = appContentSharedWorker
        self.userContentSharedWorker = userContentSharedWorker
        self.refreshHandler = refreshHandler
        self.widgetUtility = widgetUtility
        self.setupNotifications()
    }
    
    deinit {
        SCDataUIEvents.discardNotifications(for: self)
    }
    
    
    private func setupUI() {
        self.display?.hideInfoText()
        self.display?.setupNavigationBar(title: "l_001_login_title".localized(), backTitle: "")
        self.display?.setupLoginBtn(title: "l_001_login_btn_login".localized())
        self.display?.setupRememberLoginBtn(title: "l_001_login_checkbox_stay_loggedin".localized())
        self.display?.setupRegisterBtn(title: "l_001_login_info_not_registered".localized(), linkTitle: "l_001_login_btn_register".localized())
        self.display?.setupRecoverLoginBtn(title: "l_001_login_btn_forgot_password".localized())
        self.display?.setupEMailField(title: "l_001_login_hint_email".localized())
        self.display?.setupPasswordField(title: "l_001_login_hint_password".localized())
        self.showPwdSelected = false
        self.rememberLoginSelected = false
        self.display?.refreshTopPlaceholderLabel()
        
        self.display?.passwordFieldMaxLenght(255)
        self.display?.eMailFieldMaxLenght(255)
        
        if let logoutReason = self.loginWorker.lastLogoutResason() {
            
            switch logoutReason {
           
            case .initiatedByUser:
                self.display?.showInfoText(message:"l_001_login_hint_active_logout".localized())
            
            case .updateSuccessful:
                self.display?.hideInfoText()

            case .kmliNotChcked:
                self.display?.showInfoText(message: "l_001_login_hint_kmli_not_checked".localized())

            case .wasNotLoggedInBefore:
                self.display?.hideInfoText()

            case .technicalReason:
                self.display?.showInfoText(message:"l_001_login_hint_technical_logout".localized())
                
            case .accountDeleted, .invalidRefreshToken:
                self.display?.hideInfoText()
                
            }
            self.loginWorker.clearLogoutResason()
        }
    }
    
    private func setupNotifications() {
    }
    
    private func validateInputFields() -> Bool{
        
        self.display?.hidePWDError()
        self.display?.hideEMailError()
        
        let result = self.validateCredentials(email: self.display?.eMailFieldContent() ?? "",
                                              password: self.display?.pwdFieldContent() ?? "")
        
        if let nameMessage = result.emailResult?.message {
            self.display?.showEMailError(message: nameMessage)
        }
        if let pwdMessage = result.passwordResult?.message {
            self.display?.showPWDError(message: pwdMessage.localized())
        }
        
        return result.allValid
    }
    
    func validateCredentials(email: String, password: String) -> SCLoginValidationResult {
        
        var emailResult: SCValidationResult?
        var passwordResult: SCValidationResult?
        
        if email.count == 0 {
            emailResult = SCValidationResult(isValid: false,
                                             message: "l_001_login_error_fill_in".localized())
        } else {
            emailResult = SCValidationResult(isValid: true, message: nil)
        }
        
        if password.count == 0 {
            passwordResult = SCValidationResult(isValid: false,
                                                message: "l_001_login_error_fill_in".localized())
        } else {
            passwordResult = SCValidationResult(isValid: true, message: nil)
        }
        
        let allValid = (emailResult?.isValid ?? false) && (passwordResult?.isValid ?? false)
        
        return SCLoginValidationResult(allValid: allValid,
                                       emailResult: emailResult,
                                       passwordResult: passwordResult)
    }
    

    
    private func accountTempLocked(){
        let navCtrl = UINavigationController()
        navCtrl.viewControllers = [self.injector.getTempBlockedViewController(email: self.display?.eMailFieldContent() ?? "")]
        self.display?.presentOnTop(viewController: navCtrl, completion: nil)
        self.display?.setLoginButtonState(.normal)

    }

    private func confirmEMail(isErrorPresent: Bool?, errorMessage: String?){
        let confirmViewController = self.injector.getRegistrationConfirmEMailVC(registeredEmail:self.display?.eMailFieldContent() ?? "", shouldHideTopImage: false, presentationType: .confirmMailSentBeforeRegistration, isError: isErrorPresent, errorMessage: errorMessage, completionOnSuccess: {
            self.presentedVC?.dismiss(animated: true, completion:{})
            self.presentedVC = nil
        })
        self.presentedVC = confirmViewController
        self.display?.presentOnTop(viewController: confirmViewController, completion: nil)
        
    }
    
    func login(email: String, password: String, remember: Bool) {
        self.display?.setLoginButtonState(.progress)

        self.loginWorker.login(email: email,
                               password: password,
                               remember: remember,
                               completion: { (error) in
                                
            DispatchQueue.main.async {
                

                guard error == nil else {
                    switch error! {
                    case .fetchFailed(let errorDetail):
                        self.display?.setLoginButtonState(.disabled)
                        self.handleFetchFailedErrorDetail(errorDetail)
                    default:
                        self.display?.setLoginButtonState(.normal)
                        self.display?.showErrorDialog(error!, retryHandler: {self.login(email: email, password: password, remember: remember)})
                        break
                    }
                    return
                }
                
                self.userContentSharedWorker.triggerUserDataUpdate { (error) in
                    
                    
                    guard error == nil else {
                        self.display?.setLoginButtonState(.disabled)
                        self.display?.showErrorDialog(error!, retryHandler: {self.login(email: email, password: password, remember: remember)})
                        return
                    }
                    
                    self.display?.setLoginButtonState(.normal)
                    
                    if error != nil ||  self.userContentSharedWorker.getUserData() == nil{
                        
                        self.loginWorker.logout(completion: {
                            self.display?.showPWDError(message:"dialog_technical_error_message".localized())
                            self.display?.showEMailError(message:"dialog_technical_error_message".localized())
                            
                        })
                        
                        return
                    }

                    let finalizeLogin = {
                        self.widgetUtility.reloadAllTimeLines()
                        self.refreshHandler.reloadContent(force: false)
                        // when logged in, we will send a notification
                        SCDataUIEvents.postNotification(for: .userDidSignIn)

                                                                // and dismiss the screen
                        if self.dismissAfterSuccess {
                            self.display?.navigationController()?.dismiss(animated: true, completion: {
                                self.completionOnSuccess?()
                            })
                            
                        } else {
                            self.completionOnSuccess?()
                            self.display?.navigationController()?.dismiss(animated: true)
                            
                        }
                    }
                    
                    if !self.appContentSharedWorker.firstTimeUsageFinished {
                        let userData = self.userContentSharedWorker.getUserData()
                        //TODO: Add "LoginComplete" event
                        if let userProfile = userData?.profile {
                            SCUserDefaultsHelper.setProfile(profile: userProfile)

                            let parameters : [String : String] =
                            [AnalyticsKeys.TrackedParamKeys.userYob: userProfile.birthdate?.extractYear() ?? "",
                             AnalyticsKeys.TrackedParamKeys.userStatus: SCAuth.shared.isUserLoggedIn() ? AnalyticsKeys.TrackedParamKeys.loggedIn : AnalyticsKeys.TrackedParamKeys.notLoggedIn,
                             AnalyticsKeys.TrackedParamKeys.userZipcode: userProfile.postalCode,
                             AnalyticsKeys.TrackedParamKeys.citySelected: kSelectedCityName,
                             AnalyticsKeys.TrackedParamKeys.cityId: kSelectedCityId]
                            self.injector.trackEvent(eventName: AnalyticsKeys.EventName.loginComplete, parameters: parameters)
                        }
                       
                        if let postalCode = userData?.profile.postalCode {
                            
                            if let cityID = self.cityContentSharedWorker.cityIDForPostalCode(postalcode: postalCode) {
                                
                                self.cityContentSharedWorker.triggerCityContentUpdate(for: cityID, errorBlock: { (error) in
                                    SCDataUIEvents.postNotification(for: .didChangeLocation)
                                    finalizeLogin()
                                })
                                return
                            }
                        }
                        
                    }
                    finalizeLogin()
                }
            }
        })

    }
    

    private func handleFetchFailedErrorDetail(_ detail : SCWorkerErrorDetails){
        let errorCode = detail.errorCode ?? ""
        
        switch errorCode {
        case "user.blocked.temp":
            self.display?.setLoginButtonState(.normal)
            self.accountTempLocked()
        case "email.not.verified":
            self.display?.setLoginButtonState(.normal)
            self.confirmEMail(isErrorPresent: nil, errorMessage: nil)
        case "resend.too.soon":
            self.display?.setLoginButtonState(.normal)
            self.confirmEMail(isErrorPresent: true, errorMessage: detail.message)
        default:
            self.display?.showPWDError(message:detail.message)
            self.display?.showEMailError(message:detail.message)
        }
    }
    
    // when the login btn is not in state progress then check if all criterias
    // are fulfilled to show an enabled button state
    private func updateLoginButtonStateWhenNotInProgress(){
        if self.display?.loginButtonState() != .progress {
            if self.display?.eMailFieldContent()?.count ?? 0 > 0 && self.display?.pwdFieldContent()?.count ?? 0 > 0 {
                self.display?.setLoginButtonState(.normal)
            } else {
                self.display?.setLoginButtonState(.disabled)
            }
        }
    }
}

extension SCLoginPresenter: SCPresenting {
    
    func viewDidLoad() {
        debugPrint("SCLoginPresenter->viewDidLoad")
        self.setupUI()
        self.display?.setLoginButtonState(.disabled)
        //self.injector.trackEvent(eventName: "OpenLogin")
    }
}

extension SCLoginPresenter: SCLoginPresenting {
    func setDisplay(_ display: SCLoginDisplaying) {
        self.display = display
    }
    
    func registerWasPressed(){
        let navCtrl = UINavigationController()

        let registrationViewController = self.injector.getRegistrationViewController(completionOnSuccess: { (email, isError, errorMessage) in
            navCtrl.dismiss(animated: true, completion: {
                let confirmViewController = self.injector.getRegistrationConfirmEMailVC(registeredEmail:email, shouldHideTopImage: false, presentationType: .confirmMailForRegistration, isError: isError, errorMessage: errorMessage,  completionOnSuccess: {
                    self.loginWorker.clearLogoutResason()
                    self.display?.hideInfoText()
                    self.presentedVC?.dismiss(animated: true, completion:{})
                    self.presentedVC = nil
                })
                self.presentedVC = confirmViewController
                self.display?.presentOnTop(viewController: confirmViewController, completion: nil)
            })
        })
        
        navCtrl.viewControllers = [registrationViewController]
        self.display?.presentOnTop(viewController: navCtrl, completion: nil)
    }
    
    func recoverPwdWasPressed(){
        //self.injector.trackEvent(eventName: "ClickForgotPasswordBtn")
        let navCtrl = UINavigationController()
        navCtrl.viewControllers = [self.injector.getForgottenViewController(email: self.display?.eMailFieldContent() ?? "", completionOnSuccess: { (email, emailWasAlreadySentBefore, isError, errorMessage) in
            navCtrl.dismiss(animated: true, completion: {
                let confirmViewController = self.injector.getRegistrationConfirmEMailVC(registeredEmail:email, shouldHideTopImage: false, presentationType: emailWasAlreadySentBefore ? .confirmMailSentBeforeRegistration : .confirmMailForPWDReset,isError: isError, errorMessage: errorMessage, completionOnSuccess: {
                    self.presentedVC?.dismiss(animated: true, completion:{})
                    self.presentedVC = nil
                })
                self.presentedVC = confirmViewController
                self.display?.presentOnTop(viewController: confirmViewController, completion: nil)
            })
        })]
        self.display?.presentOnTop(viewController: navCtrl, completion: nil)
    }
    
    func rememberLoginWasPressed(){
        //self.injector.trackEvent(eventName: "ClickSaveLoginCheckbox")
        self.rememberLoginSelected = !self.rememberLoginSelected
    }
    
    func pwdShowPasswordWasPressed(){
        self.showPwdSelected = !self.showPwdSelected
    }
    
    func cancelWasPressed(){
        self.display?.navigationController()?.dismiss(animated: true, completion: {
            self.completionOnCancel?()

        })
    }
    
    func loginWasPressed(){
        //self.injector.trackEvent(eventName: "ClickLoginBtn")
        //TODO: Add "LoginComplete" event
        if let userProfile = SCUserDefaultsHelper.getProfile() {
            let parameters : [String : String] =
            [AnalyticsKeys.TrackedParamKeys.userYob: userProfile.birthdate?.extractYear() ?? "",
             AnalyticsKeys.TrackedParamKeys.userStatus: SCAuth.shared.isUserLoggedIn() ? AnalyticsKeys.TrackedParamKeys.loggedIn : AnalyticsKeys.TrackedParamKeys.notLoggedIn,
             AnalyticsKeys.TrackedParamKeys.userZipcode: userProfile.postalCode,
             AnalyticsKeys.TrackedParamKeys.citySelected: kSelectedCityName,
             AnalyticsKeys.TrackedParamKeys.cityId: kSelectedCityId]
            self.injector.trackEvent(eventName: AnalyticsKeys.EventName.loginComplete, parameters: parameters)
        }
        
        self.display?.hidePWDError()
        self.display?.hideEMailError()

        guard self.validateInputFields()  else {
            return
        }
        
        // Track user checked KMLI/ not checked KMLI
        self.injector.trackEvent(eventName: rememberLoginSelected ? AnalyticsKeys.EventName.logInWithKeep : AnalyticsKeys.EventName.logInWithoutKeep)

        // call backend
        self.login(email: (self.display?.eMailFieldContent())!,
                        password: (self.display?.pwdFieldContent())!,
                        remember: self.rememberLoginSelected)
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
    
    func softwareLicensekWasPressed() {
        self.presentSoftwareLicenseVC()
    }
    
    
    func eMailFieldDidBeginEditing(){
    }
    
    func eMailFieldDidChange(){
        self.display?.hidePWDError()
        self.display?.hideEMailError()
        self.display?.refreshTopPlaceholderLabel()
        self.updateLoginButtonStateWhenNotInProgress()
    }
    
    func passwordFieldDidBeginEditing(){
    }
    
    func passwordFieldDidChange(){
        self.display?.hidePWDError()
        self.display?.hideEMailError()
        self.display?.refreshTopPlaceholderLabel()
        self.updateLoginButtonStateWhenNotInProgress()
    }
    
    func isLoginRemembered() -> Bool {
        return rememberLoginSelected
    }

}

extension SCLoginPresenter {
    
    internal func presentHelpFAQ() {
        var helpURL = "https://citykey.app/faq"
        if SCUtilities.preferredContentLanguage() == "en" {
            helpURL.append("-\(SCUtilities.preferredContentLanguage())")
        }
        SCInternalBrowser.showURL(helpURL.absoluteUrl(), withBrowserType: .safari, title: "p_001_profile_help_webview_title".localized())
    }

    internal func presentImprint() {
        if let legalNotice = self.appContentSharedWorker.getLegalNotice(){
            SCInternalBrowser.showURL(legalNotice.absoluteUrl(), withBrowserType: .safari, title: "i_001_imprint_title".localized())
        }
    }

    internal func presentPrivacy() {
        
//      let dataPrivacy = self.injector.getDataPrivacyController(presentationType: .dataPrivacy, insideNavCtrl: false)
        let dataPrivacy = self.injector.getDataPrivacyController(preventSwipeToDismiss: false, shouldPushSettingsController: true)
        self.display?.push(viewController: dataPrivacy)
    }

    internal func presentPrivacySettings() {
        
        let dataPrivacy = self.injector.getDataPrivacySettingsController(shouldPushDataPrivacyController: true, preventSwipeToDismiss: false,
                                                                         isFirstRunSettings: false, completionHandler: nil)
        self.display?.push(viewController: dataPrivacy)
    }
    
    internal func presentAccessibilityStatement() {
        
        let fileName =  "accessibility_stmt_\(SCUtilities.preferredContentLanguage()).html"
        let filePath = "\(Bundle.main.bundlePath)/\(fileName)"
        if let htmlString = try? String(contentsOfFile: filePath) {
            let accessibilityStmtViewController = self.injector.getWebContentViewController(forHtmlString: htmlString, title: "p_001_profile_accessibility_stmt_webview_title".localized(), insideNavCtrl: false)
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
                                                                                           title: "p_001_profile_software_license_title".localized(),
                                                                                           insideNavCtrl: false)
            self.display?.push(viewController: webContentController)

        }
    }

}

