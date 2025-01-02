//
//  SCInjector.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 07.05.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCInjecting: AnyObject {
    
}

class SCInjector: SCInjecting {

    private let dataCache = SCDataCache()

    private let pushNotificationHandler : NotificationManagerDelegate
    private let adjustTrackingHandler : SCAdjustTrackingHandler
    private let moEngageAnalyticsHandler : MoEngageAnalyticsTracking


    private let authorizationSharedWorker = SCAuthorizationWorker(requestFactory: SCRequest())
    private let cityContentSharedWorker = SCCityContentSharedWorker(requestFactory: SCRequest())
    private let userContentSharedWorker : SCUserContentSharedWorker
    private let userCityContentSharedWorker : SCUserCityContentSharedWorker
    private let appContentSharedWorker : SCAppContentSharedWorker
    private let sharedWorkerRefreshHandler : SCSharedWorkerRefreshHandler
    private let basicPOIGuideWorker: SCBasicPOIGuideWorker
    private let executor: SCNetworkCallsExecutor
    private let egovServiceWorker: SCEgovServiceWorker


    private lazy var mainPresenter: SCMainPresenting = SCMainPresenter(mainWorker: SCMainWorker(requestFactory: SCRequest()), cityContentSharedWorker: self.cityContentSharedWorker, userContentSharedWorker: self.userContentSharedWorker, appContentSharedWorker: self.appContentSharedWorker, authProvider: SCAuth.shared, injector: self, refreshHandler: self.sharedWorkerRefreshHandler, userCityContentSharedWorker: userCityContentSharedWorker, basicPOIGuideWorker: self.basicPOIGuideWorker)

    private var toolsPresenter: SCToolsShowing?
    
    init() {
        self.appContentSharedWorker = SCAppContentSharedWorker(requestFactory: SCRequest())

        self.userContentSharedWorker = SCUserContentSharedWorker(requestFactory: SCRequest())
        
        self.userCityContentSharedWorker = SCUserCityContentSharedWorker(requestFactory: SCRequest(),
                                                                         cityIdentifier: self.cityContentSharedWorker,
                                                                         userIdentifier: self.userContentSharedWorker)
        
        self.basicPOIGuideWorker = SCBasicPOIGuideWorker(requestFactory: SCRequest())
        self.egovServiceWorker = SCEgovServiceWorker(requestFactory: SCRequest())
        self.executor = SCNetworkCallsExecutor()

        self.sharedWorkerRefreshHandler = SCSharedWorkerRefreshHandler(cityContentSharedWorker: self.cityContentSharedWorker, userContentSharedWorker: self.userContentSharedWorker, userCityContentSharedWorker: self.userCityContentSharedWorker, appContentSharedWorker: self.appContentSharedWorker, authProvider: SCAuth.shared, display: nil)

        SCFeatureToggler.shared.cityContentSharedWorker = self.cityContentSharedWorker
        SCFeatureToggler.shared.userContentSharedWorker = self.userContentSharedWorker
        
         // inject AuthWorker
        SCAuth.shared.worker = self.authorizationSharedWorker
        SCAuth.shared.userContentWorker = self.userContentSharedWorker
        SCAuth.shared.userCityContentWorker = self.userCityContentSharedWorker
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            switch delegate.notificationType {
            case .MoEngage:
                self.pushNotificationHandler = SCMoEngageHandler(userIDProvider: self.userContentSharedWorker, privacySettingsProvider: self.appContentSharedWorker, refreshHandler: self.sharedWorkerRefreshHandler, userContentSharedWorker: self.userContentSharedWorker)
            case .TPNS:
                self.pushNotificationHandler = SCTPNSHandler(userIDProvider: self.userContentSharedWorker, privacySettingsProvider: self.appContentSharedWorker, refreshHandler: self.sharedWorkerRefreshHandler, worker: SCTPNSWorker(client: SCTPNSClient(executor: executor)))
            }
        } else {
            self.pushNotificationHandler = SCTPNSHandler(userIDProvider: self.userContentSharedWorker, privacySettingsProvider: self.appContentSharedWorker, refreshHandler: self.sharedWorkerRefreshHandler, worker: SCTPNSWorker(client: SCTPNSClient(executor: executor)))
        }
        self.adjustTrackingHandler = SCAdjustTrackingHandler(privacySettingsProvider: self.appContentSharedWorker)
        self.moEngageAnalyticsHandler = SCMoEngageAnalyticsHandler(privacySettingsProvider: self.appContentSharedWorker)
    }
    
}

// MARK: -  Notification Handling
extension SCInjector {

    private func registerForNotifications() {
    }

}

// MARK: - AppDelegate Injection
extension SCInjector: SCAppDelegateInjection {
    
    func initializeNotificationForApplication(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?){
        self.pushNotificationHandler.initializeNotificationForApplication(application, launchOptions: launchOptions)
    }
    
    func didRegisterForRemoteNotificationsWithDeviceToken(_ deviceToken: Data) {
        self.pushNotificationHandler.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
    }
    
    func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
        self.pushNotificationHandler.didFailToRegisterForRemoteNotificationsWithError(error)
    }
    
    func refreshInfoBoxData(){
        // only refresh the date when initial loading was finished
        if (self.sharedWorkerRefreshHandler.isInitialLoadingFinished) {
            self.sharedWorkerRefreshHandler.reloadUserInfoBox()
        }
    }
    
    func initializeMoEngageForApplication(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        self.moEngageAnalyticsHandler.initializeMoengage(application, launchOptions: launchOptions)
    }

}

// MARK: - Adjust SDK Injection
extension SCInjector: SCAdjustTrackingInjection {
    func trackEvent(eventName: String){
        self.adjustTrackingHandler.trackEvent(eventName: eventName)
        
    }
    
    func trackEvent(eventName: String, parameters: [String : String]) {
        self.adjustTrackingHandler.trackEvent(eventName: eventName, parameters: parameters)
    }
    
    func appWillOpen(url: URL){
        self.adjustTrackingHandler.appWillOpen(url: url)
    }
}


// MARK: - Tools Injection
extension SCInjector: SCToolsInjecting {

    func setToolsShower(_ shower: SCToolsShowing) {
        self.toolsPresenter = shower
    }
    
    func getForceUpdateVersionViewController() -> UIViewController {
        guard let forceUpdateVC = UIStoryboard(name: "Dashboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "SCForceUpdateVersionViewController") as? SCForceUpdateVersionViewController else {
            fatalError("Could not instantiate SCForceUpdateVersionViewController")
        }
        
        return forceUpdateVC
    }
    
    func getVersionInformationViewController() -> UIViewController{
        guard let versionInfoVC = UIStoryboard(name: "Dashboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "SCVersionInformationViewController") as? SCVersionInformationViewController else {
            fatalError("Could not instantiate SCVersionInformationViewController")
        }
        return versionInfoVC
    }
    
    func getLocationViewController(presentationMode: SCLocationPresentationMode, includeNavController: Bool, completionAfterDismiss: (() -> Void)?) -> UIViewController {
        
        guard let navCtrl = UIStoryboard(name: "LocationScreen", bundle: nil).instantiateInitialViewController() as? UINavigationController,
            let locationViewController = navCtrl.viewControllers.first as? SCLocationViewController else {
                fatalError("Could not instantiate SCLocationViewController")
        }

        locationViewController.completionAfterDismiss = completionAfterDismiss
        locationViewController.presentationMode = presentationMode
        
        let worker = SCLocationWorker(requestFactory: SCRequest())
        let presenter = SCLocationPresenter(locationWorker: worker, appContentSharedWorker :  self.appContentSharedWorker, cityContentSharedWorker: self.cityContentSharedWorker, injector: self, userCityContentSharedWorker: self.userCityContentSharedWorker, refreshHandler: self.sharedWorkerRefreshHandler, egovServiceWorker: self.egovServiceWorker)

        locationViewController.presenter = presenter
        
        return includeNavController ? navCtrl : locationViewController
    }
    
    func getRegistrationViewController(completionOnSuccess: ((_ eMail : String, _ isErrorPresent: Bool?, _ errorMessage: String?) -> Void)?) -> UIViewController {
        
        guard let registrationViewController = UIStoryboard(name: "RegistrationScreen", bundle: Bundle.main).instantiateViewController(withIdentifier: "SCRegistrationVC") as? SCRegistrationVC else {
            fatalError("Could not instantiate SCRegistrationVC")
        }
        registrationViewController.presenter = SCRegistrationPresenter(registrationWorker: SCRegistrationWorker(requestFactory: SCRequest()), appContentSharedWorker: self.appContentSharedWorker, injector: self, completionOnSuccess: completionOnSuccess)
        
        return registrationViewController
    }
    
    func getLoginViewController(dismissAfterSuccess: Bool, completionOnSuccess: (() -> Void)?) -> UIViewController {
        
        guard let navCtrl = UIStoryboard(name: "LoginScreen", bundle: nil).instantiateInitialViewController() as? UINavigationController,
            let loginViewController = navCtrl.viewControllers.first as? SCLoginViewController else {
                fatalError("Could not instantiate SCLoginViewController")
        }

        let presenter = SCLoginPresenter(loginWorker: SCLoginWorker(requestFactory: SCRequest(), authProvider: SCAuth.shared), userContentSharedWorker: self.userContentSharedWorker, appContentSharedWorker: self.appContentSharedWorker, cityContentSharedWorker: self.cityContentSharedWorker, injector: self, refreshHandler: self.sharedWorkerRefreshHandler)
        presenter.completionOnSuccess = completionOnSuccess
        presenter.dismissAfterSuccess = dismissAfterSuccess
        
        loginViewController.presenter = presenter
        
        return navCtrl
    }
    
    func getProfileViewController() -> UIViewController {
        
        guard let navCtrl = UIStoryboard(name: "ProfileScreen", bundle: nil).instantiateInitialViewController() as? UINavigationController,
            let profileController = navCtrl.viewControllers.first as? SCProfileViewController else {
                fatalError("Could not instantiate SCProfileViewController")
        }
        
        let profileWorker = SCProfileWorker(requestFactory: SCRequest())
        let profilePresenter = SCProfilePresenter(profileWorker: profileWorker, userContentSharedWorker: self.userContentSharedWorker, appContentSharedWorker: self.appContentSharedWorker, authProvider: SCAuth.shared, injector: self)
        
        profileController.presenter = profilePresenter
        
        return navCtrl
    }
    
    func getFeedbackController() -> UIViewController {
        let viewController : SCFeedbackViewController = UIStoryboard(name: "ProfileScreen", bundle: nil).instantiateViewController(withIdentifier: "SCFeedbackViewController") as! SCFeedbackViewController
        let feedbackWorker = SCFeedbackWorker(requestFactory: SCRequest())
        let presenter = SCFeedbackPresenter(injector: self, feedbackWorker: feedbackWorker, cityContentSharedWorker: self.cityContentSharedWorker, userContentSharedWorker: self.userContentSharedWorker)
        viewController.presenter = presenter
        return viewController
    }
    
    func getFeedbackConfirmationViewController() -> UIViewController {
        let viewController : SCFeedbackConfirmationViewController = UIStoryboard(name: "ProfileScreen", bundle: nil).instantiateViewController(withIdentifier: "SCFeedbackConfirmationViewController") as! SCFeedbackConfirmationViewController
        let presenter = SCFeedbackConfirmationPresenter(injector: self)
        viewController.presenter = presenter
        return viewController
    }
}

// MARK: - Tools Presenting
extension SCInjector: SCToolsShowing {
    func showLocationSelector() {
        self.toolsPresenter?.showLocationSelector()
    }
    func showRegistration() {
        self.toolsPresenter?.showRegistration()
    }
    func showProfile() {
        self.toolsPresenter?.showProfile()
    }
    func showLogin(completionOnSuccess: (() -> Void)?) {
        self.toolsPresenter?.showLogin(completionOnSuccess: completionOnSuccess)
    }
}

// MARK: - LegalInfo Presenting
extension SCInjector: SCLegalInfoInjecting {
    
    func getDataPrivacyController(preventSwipeToDismiss: Bool, shouldPushSettingsController: Bool) -> UIViewController {
        
        let viewController : UINavigationController = UIStoryboard(name: "DataPrivacyScreen", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let dataPrivacyViewController = viewController.viewControllers.first as! SCDataPrivacyViewController

        dataPrivacyViewController.presenter = SCDataPrivacyPresenter(appContentSharedWorker: self.appContentSharedWorker, injector: self, showCloseBtn: false, preventSwipeToDismiss: preventSwipeToDismiss, shouldPushSettingsController: shouldPushSettingsController)
            
//            SCDataPrivacyPresenter(appContentSharedWorker: self.appContentSharedWorker, injector: self, showCloseBtn: insideNavCtrl, presentationType: presentationType)
        
        return dataPrivacyViewController
    }
    
    func getInfoNoticeController(title: String, content: String, insideNavCtrl: Bool) -> UIViewController {
        let viewController : UINavigationController = UIStoryboard(name: "InfoNoticeScreen", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let infoNoticeViewController = viewController.viewControllers.first as! SCInfoNoticeViewController

        infoNoticeViewController.presenter = SCInfoNoticePresenter(title: title, content: content, injector: self)
        
        if insideNavCtrl {
            return viewController
        }
        return infoNoticeViewController
    }
    
    func getDataPrivacyNoticeController(insideNavCtrl: Bool) -> UIViewController {
        
        let viewController : SCDataPrivacyNoticeViewController = UIStoryboard(name: "DataPrivacyScreen", bundle: nil).instantiateViewController(withIdentifier: "SCDataPrivacyNoticeViewController") as! SCDataPrivacyNoticeViewController    
        let presenter = SCDataPrivacyNoticePresenter(appContentSharedWorker: self.appContentSharedWorker, injector: self)
        viewController.presenter = presenter
        
        if insideNavCtrl {
            let navController = UINavigationController(rootViewController: viewController)
            if #available(iOS 13.0, *) {
                navController.isModalInPresentation = true
            }
            return navController
        }
                
        if #available(iOS 13.0, *) {
            viewController.isModalInPresentation = true
        }

        return viewController
    }
    

    func getDataPrivacyFirstRunController(preventSwipeToDismiss : Bool, completionHandler: (() -> Void)?) -> UIViewController {
        
        let viewController : SCDataPrivacyFirstRunViewController = UIStoryboard(name: "DataPrivacyScreen", bundle: nil).instantiateViewController(withIdentifier: "SCDataPrivacyFirstRunViewController") as! SCDataPrivacyFirstRunViewController
        let presenter = SCDataPrivacyFirstRunPresenter(appContentSharedWorker: self.appContentSharedWorker, injector: self, preventSwipeToDismiss: preventSwipeToDismiss)
        viewController.presenter = presenter
        viewController.presenter.completionHandler = completionHandler
        let navController = UINavigationController(rootViewController: viewController)
        navController.navigationBar.tintColor = UIColor.labelTextBlackCLR
        return navController

    }
    
    func getDataPrivacySettingsController(shouldPushDataPrivacyController: Bool,
                                          preventSwipeToDismiss: Bool,
                                          isFirstRunSettings: Bool, completionHandler: (() -> Void)?) -> UIViewController {
        
        
        let viewController : SCDataPrivacySettingsViewController = UIStoryboard(name: "DataPrivacyScreen", bundle: nil).instantiateViewController(withIdentifier: "SCDataPrivacySettingsViewController") as! SCDataPrivacySettingsViewController
        let presenter = SCDataPrivacySettingsPresenter(appContentSharedWorker: self.appContentSharedWorker, injector: self, shouldPushDataPrivacyController: shouldPushDataPrivacyController, preventSwipeToDismiss: preventSwipeToDismiss, isFirstRunSettings: isFirstRunSettings)
        viewController.presenter = presenter
        viewController.presenter.completionHandler = completionHandler
        return viewController
    }

    func registerRemotePushForApplication() {
        self.pushNotificationHandler.registerPushForApplication()
    }

}

// MARK: - Main Injection
extension SCInjector: SCMainInjecting {

    func registerPushForApplication(){
        self.pushNotificationHandler.registerPushForApplication()
    }

    func getMainTabBarController() -> UIViewController {
        guard let mainTabBarController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SCMainTabBarController") as? SCMainTabBarController else {
            fatalError("Could not instantiate MainTabBarController")
        }
        self.sharedWorkerRefreshHandler.display = mainTabBarController
        mainTabBarController.presenter = self.mainPresenter
        return mainTabBarController
    }

    func getMainPresenter() -> SCMainPresenting {
        return self.mainPresenter
    }

    func configureMainTabViewController(_ viewController: UIViewController) {

        if let dashboardViewController = viewController as? SCDashboardViewController {
            dashboardViewController.presenter = self.getDashboardPresenter()
        }
        if let marketplaceViewController = viewController as? SCMarketplaceViewController {
            marketplaceViewController.presenter = self.getMarketplacePresenter()
        }
        if let servicesViewController = viewController as? SCServicesViewController {
            servicesViewController.presenter = self.getServicesPresenter()
        }
        if let userInfoBoxViewController = viewController as? SCUserInfoBoxViewController {
            userInfoBoxViewController.presenter = self.getUserInfoBoxPresenter()
        }
        if let cityImprintViewController = viewController as? SCCityImprintViewController {
            cityImprintViewController.presenter = self.getCityImprintPresenter()
        }
    }
    
    private func getDashboardPresenter() -> SCDashboardPresenting {

        let dashboardWorker = SCDashboardWorker(requestFactory: SCRequest())
        let eventWorker = SCEventWorker(requestFactory: SCRequest())
        let userCityContentSharedWorker = self.getUserCityContentSharedWorker()
        let userContentSharedWorker = self.userContentSharedWorker
        let dashboardPresenter = SCDashboardPresenter(dashboardWorker: dashboardWorker,
                                                      cityContentSharedWorker: self.cityContentSharedWorker,
                                                      userContentSharedWorker: userContentSharedWorker,
                                                      userCityContentSharedWorker: userCityContentSharedWorker,
                                                      dashboardEventWorker: eventWorker,
                                                      appContentSharedWorker: self.appContentSharedWorker,
                                                      injector: self,
                                                      refreshHandler: self.sharedWorkerRefreshHandler,
                                                      authProvider: SCAuth.shared)

        return dashboardPresenter
    }
    
    private func getMarketplacePresenter() -> SCMarketplacePresenting {
        let marketplaceWorker = SCMarketplaceWorker(requestFactory: SCRequest())
        let marketplacePresenter = SCMarketplacePresenter(marketplaceWorker: marketplaceWorker, cityContentSharedWorker: self.cityContentSharedWorker, userContentSharedWorker: self.userContentSharedWorker, authProvider: SCAuth.shared, injector: self, refreshHandler: self.sharedWorkerRefreshHandler)
        
        return marketplacePresenter
    }

    private func getServicesPresenter() -> SCServicesPresenting {
        let servicesWorker = SCServicesWorker(requestFactory: SCRequest())
        let servicesPresenter = SCServicesPresenter(servicesWorker: servicesWorker,
                                                    cityContentSharedWorker: self.cityContentSharedWorker,
                                                    userContentSharedWorker: self.userContentSharedWorker,
                                                    authProvider: SCAuth.shared,
                                                    injector: self,
                                                    refreshHandler: self.sharedWorkerRefreshHandler,
                                                    userCityContentSharedWorker: self.userCityContentSharedWorker,
                                                    basicPOIGuideWorker: self.basicPOIGuideWorker,
                                                    eGovServiceWorker: self.egovServiceWorker,
                                                    dataCache: dataCache,surveyWorker: SCCitizenSurveyWorker(requestFactory: SCRequest()))

        return servicesPresenter
    }
    
    private  func getUserInfoBoxPresenter() -> SCUserInfoBoxPresenting {
        let userInfoBoxPresenter = SCUserInfoBoxPresenter(userInfoBoxWorker: SCUserInfoBoxWorker(requestFactory: SCRequest()), userContentSharedWorker: self.userContentSharedWorker, appContentSharedWorker: self.appContentSharedWorker,  authProvider: SCAuth.shared, injector: self, refreshHandler: self.sharedWorkerRefreshHandler, auth: SCAuth.shared)
        return userInfoBoxPresenter
    }

    private  func getCityImprintPresenter() -> SCCityImprintPresenter {
        let cityImprintPresenter = SCCityImprintPresenter(cityContentSharedWorker: self.cityContentSharedWorker, injector: self)
        return cityImprintPresenter
    }
    
    func getFTUFlowViewController() -> UIViewController{
        guard let ftuFlowNavCtrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SCFTUFlowNav") as? SCFTUFlowNavigationController else {
                fatalError("Could not instantiate SCFTUFlowNavigationController")
        }
        
        let ftuFlowPresenter = SCFTUFlowPresenter(appContentSharedWorker: self.appContentSharedWorker, cityContentSharedWorker: self.cityContentSharedWorker, refreshHandler: self.sharedWorkerRefreshHandler, authProvider: SCAuth.shared, injector: self)
        
        ftuFlowNavCtrl.presenter = ftuFlowPresenter
        
        return ftuFlowNavCtrl
    }

}

// MARK: - Login Injection
extension SCInjector: SCLoginInjecting {

    func getForgottenViewController(email: String, completionOnSuccess: ((_ eMail : String, _ emailWasAlreadySentBefore: Bool, _ isError:Bool?, _ errorMessage: String?) -> Void)?) -> UIViewController {
        guard let recoverPwdController = UIStoryboard(name: "PwdRestoreUnlockScreen", bundle: Bundle.main).instantiateViewController(withIdentifier: "RestoreUnlockVC") as? SCPWDRestoreUnlockVC else {
            fatalError("Could not instantiate SCPWDRestoreUnlockVC")
        }
        recoverPwdController.presenter = SCPWDRestoreUnlockPresenter(email: email, screenType: .pwdForgotten, restoreUnlockWorker: SCPWDRestoreUnlockWorker(requestFactory: SCRequest()), injector: self, completionOnSuccess: completionOnSuccess)
        return recoverPwdController
    }
    
    func getTempBlockedViewController(email: String) -> UIViewController {
        guard let tempBlockedController = UIStoryboard(name: "TempBlockedScreen", bundle: Bundle.main).instantiateViewController(withIdentifier: "SCTempBlockedVC") as? SCTempBlockedVC else {
            fatalError("Could not instantiate SCTempBlockedVC")
        }
        tempBlockedController.presenter = SCTempBlockedPresenter(email: email, injector: self)
        return tempBlockedController
    }

}

extension SCInjector: SCPWDRestoreUnlockInjecting {
    func getRestoreUnlockFinishedViewController(email: String) -> UIViewController {

        guard let finishViewController = UIStoryboard(name: "PwdRestoreUnlockScreen", bundle: Bundle.main).instantiateViewController(withIdentifier: "RestoreUnlockFinishedVC") as? SCPWDRestoreUnlockFinishedVC else {
            fatalError("Could not instantiate SCRegistrationFinishedVC")
        }
        finishViewController.presenter = SCPWDRestoreUnlockFinishedPresenter(email: email, restoreUnlockFinishedWorker: SCPWDRestoreUnlockFinishedWorker(requestFactory: SCRequest()), injector: self)
        return finishViewController
    }
}

extension SCInjector: SCRegistrationInjecting {
    
    func getRegistrationConfirmEMailVC(registeredEmail: String, shouldHideTopImage : Bool, presentationType : SCRegistrationConfirmEMailType, isError:Bool?, errorMessage: String?, completionOnSuccess: (() -> Void)?) -> UIViewController {
        
        let viewController : UINavigationController = UIStoryboard(name: "RegistrationScreen", bundle: Bundle.main).instantiateViewController(withIdentifier: "SCRegistrationConfirmEMailVC") as! UINavigationController
        let confirmViewController = viewController.viewControllers.first as! SCRegistrationConfirmEMailVC

        confirmViewController.presenter = SCRegistrationConfirmEMailPresenter(registeredEmail: registeredEmail, shouldHideTopImage: shouldHideTopImage,isError: isError,errorMessage: errorMessage, presentationType: presentationType, registrationConfirmWorker: SCRegistrationConfirmEMailWorker(requestFactory: SCRequest()), injector: self, completionOnSuccess: completionOnSuccess)
       
        return viewController
    }

    func getRegistrationConfirmEMailFinishedVC(shouldHideTopImage : Bool, presentationType : SCRegistrationConfirmEMailType, completionOnSuccess: (() -> Void)?) -> UIViewController {
        guard let finishViewController = UIStoryboard(name: "RegistrationScreen", bundle: Bundle.main).instantiateViewController(withIdentifier: "SCRegistrationConfirmEMailFinishedVC") as? SCRegistrationConfirmEMailFinishedVC else {
            fatalError("Could not instantiate SCRegistrationConfirmEMailFinishedVC")
        }
        
        finishViewController.presenter = SCRegistrationConfirmEMailFinishedPresenter(injector: self, shouldHideTopImage: shouldHideTopImage, presentationType: presentationType, completionOnSuccess: completionOnSuccess)
        return finishViewController
    }
    
    func getProfileEditDateOfBirthViewController(in flow: DateOfBirth, completionHandler: ((String?) -> Void)?) -> UIViewController {
        guard let editDateOfBirthVC: SCEditDateOfBirthVC
            = UIStoryboard(name: "EditProfileScreen",bundle: nil)
                .instantiateViewController(withIdentifier: "SCEditDateOfBirthVC") as? SCEditDateOfBirthVC else {
                    fatalError("Could not instantiate SCEditDateOfBirthVC")
        }
        
        let editDateOfBirthWorker = SCEditDateOfBirthWorker(requestFactory: SCRequest())
        
        let editDateOfBirthPresenter = SCEditDateOfBirthPresenter(profile: SCUserDefaultsHelper.getProfile(), editDateOfBirthWorker: editDateOfBirthWorker, injector: self, flow: flow, completionHandler: completionHandler)
        
        editDateOfBirthVC.presenter = editDateOfBirthPresenter
                
        return editDateOfBirthVC
    }
}

// MARK: - Profile Injection
extension SCInjector: SCProfileInjecting {
    
    func getProfileEditOverviewViewController(email: String) -> UIViewController{
        guard let editing: SCEditProfileOverviewTVCTableViewController
            = UIStoryboard(name: "EditProfileScreen",bundle: nil)
                .instantiateViewController(withIdentifier: "EditingOverview") as? SCEditProfileOverviewTVCTableViewController else {
                    fatalError("Could not instantiate SCEditProfileOverviewTVCTableViewController")
        }
        
        let profileEditOverviewWorker = SCEditProfileOverviewWorker(requestFactory: SCRequest())
        let profileEditOverviewPresenter = SCEditProfileOverviewPresenter(email: email, profileEditOverviewWorker: profileEditOverviewWorker, injector: self)
        
        editing.presenter = profileEditOverviewPresenter

        
        return editing
    }
    
    func getProfileEditPersonalDataOverviewViewController(postcode: String, profile: SCModelProfile) -> UIViewController{
        guard let editing: SCEditPersonalDataOverviewTVCTableViewController
            = UIStoryboard(name: "EditProfileScreen",bundle: nil)
                .instantiateViewController(withIdentifier: "EditingPersonalDataOverview") as? SCEditPersonalDataOverviewTVCTableViewController else {
                    fatalError("Could not instantiate SCEditPersonalDataOverviewTVCTableViewController")
        }
        
        let personalDataEditOverviewWorker = SCEditPersonalDataOverviewWorker(requestFactory: SCRequest())
        let personalDataEditOverviewPresenter = SCEditPersonalDataOverviewPresenter(postcode: postcode, profile: profile, personalDataEditOverviewWorker: personalDataEditOverviewWorker, userContentSharedWorker: self.userContentSharedWorker, authProvider: SCAuth.shared, injector: self)
        
        editing.presenter = personalDataEditOverviewPresenter

        
        return editing
    }
    
}

// MARK: - Profile Injection
extension SCInjector: SCEditProfileInjecting {
    func getDeleteAccountViewController() -> UIViewController {
        guard let deleteAccountViewController: SCDeleteAccountViewController = UIStoryboard(name: "DeleteAccount", bundle: nil).instantiateViewController(withIdentifier: "SCDeleteAccountViewController") as? SCDeleteAccountViewController else {
                fatalError("Could not instantiate SCDeleteAccountViewController")
        }
        
        //get the appropriate worker, do we need one?
        //get the presenter
        let deleteAccountPresenter = SCDeleteAccountPresenter(injector: self)
        deleteAccountViewController.presenter = deleteAccountPresenter
        
        return deleteAccountViewController
    }
    
    
    func getProfileEditEMailViewController(email: String) -> UIViewController {
        guard let editingEMail: SCEditEMailVC
            = UIStoryboard(name: "EditProfileScreen",bundle: nil)
                .instantiateViewController(withIdentifier: "SCEditEMailVC") as? SCEditEMailVC else {
                    fatalError("Could not instantiate SCEditEMailVC")
        }

        let editingEMailWorker = SCEditEMailWorker(requestFactory: SCRequest())
        let editingEMailPresenter = SCEditEMailPresenter(email: email, editEMailWorker: editingEMailWorker, authProvider: SCAuth.shared, injector: self)
        
        editingEMail.presenter = editingEMailPresenter
        
        
        return editingEMail
    }
    
    func getProfileEditPasswordViewController(email: String) -> UIViewController {
        guard let editingPassword: SCEditPasswordVC
            = UIStoryboard(name: "EditProfileScreen",bundle: nil)
                .instantiateViewController(withIdentifier: "SCEditPasswordVC") as? SCEditPasswordVC else {
                    fatalError("Could not instantiate SCEditPasswordVC")
        }
        
        let editingPasswordWorker = SCEditPasswordWorker(requestFactory: SCRequest())
        let editingPasswordPresenter = SCEditPasswordPresenter(email: email, editPasswordWorker: editingPasswordWorker, injector: self)
        
        editingPassword.presenter = editingPasswordPresenter
        
        
        return editingPassword
    }
    
    func getProfileEditResidenceViewController(postcode: String) -> UIViewController {
        guard let editingResidence: SCEditResidenceVC
            = UIStoryboard(name: "EditProfileScreen",bundle: nil)
                .instantiateViewController(withIdentifier: "SCEditResidenceVC") as? SCEditResidenceVC else {
                    fatalError("Could not instantiate SCEditPasswordVC")
        }
        
        let editingResidenceWorker = SCEditResidenceWorker(requestFactory: SCRequest())
        let editingResidencePresenter = SCEditResidencePresenter(postcode: postcode, profile: SCUserDefaultsHelper.getProfile()!,  editResidenceWorker: editingResidenceWorker, injector: self)
        
        editingResidence.presenter = editingResidencePresenter
        
        
        return editingResidence
    }
}

extension SCInjector: SCDeleteAccountInjecting {
    func getDeleteAccountErrorController() -> UIViewController {
        guard let deleteAccountErrorController = UIStoryboard(name: "DeleteAccount", bundle: nil).instantiateViewController(withIdentifier: "SCDeleteAccountErrorViewController") as? SCDeleteAccountErrorViewController else {
            fatalError("Could not instantiate SCDeleteAccountErrorViewController")
        }
        return deleteAccountErrorController
    }
    
    func getDeleteAccountSuccessController() -> UIViewController {
        guard let deleteAccountSuccessViewController = UIStoryboard(name: "DeleteAccount", bundle: nil).instantiateViewController(withIdentifier: "SCDeleteAccountSuccessViewController") as? SCDeleteAccountSuccessViewController else {
            fatalError("Could not instantiate SCDeleteAccountSuccessViewController")
        }
        
        let deleteAccountAuthProvider = SCAuth.shared
        let deleteAccountSuccessPresenter = SCDeleteAccountSuccessPresenter(injector: self, authProvider: deleteAccountAuthProvider)
        deleteAccountSuccessViewController.presenter = deleteAccountSuccessPresenter
        return deleteAccountSuccessViewController
    }
    
    func getDeleteAccountConfirmationController() -> UIViewController {
        guard let deleteAccountConfirmationController = UIStoryboard(name: "DeleteAccount",bundle: nil)
            .instantiateViewController(withIdentifier: "SCDeleteAccountConfirmationViewController") as? SCDeleteAccountConfirmationViewController else {
                fatalError("Could not instantiate SCDeleteAccountConfirmationViewController")
        }
        
        let deleteAccountAuthProvider = SCAuth.shared
        let deleteAccountConfirmationWorker = SCDeleteAccountConfirmationWorker(requestFactory: SCRequest())
        let deleteAccountConfirmationPresenter = SCDeleteAccountConfirmationPresenter(authProvider: deleteAccountAuthProvider, injector: self, loginInjector: self, sharedWorkerInjecting: self, worker: deleteAccountConfirmationWorker)
        deleteAccountConfirmationController.presenter = deleteAccountConfirmationPresenter
        return deleteAccountConfirmationController
    }
}

// MARK: - Edit EMail Injection
extension SCInjector: SCEditEMailInjecting {
    func getEditEMailFinishedViewController(email: String) -> UIViewController {
        
        guard let editingFinishedEMail: SCEditEMailFinishedVC
            = UIStoryboard(name: "EditProfileScreen",bundle: nil)
                .instantiateViewController(withIdentifier: "SCEditEMailFinishedVC") as? SCEditEMailFinishedVC else {
                    fatalError("Could not instantiate SCEditEMailFinishedVC")
        }
        
        let editingEMailFinishedPresenter = SCEditEMailFinishedPresenter(email: email, injector: self)
        editingFinishedEMail.presenter = editingEMailFinishedPresenter
        
        
        return editingFinishedEMail
    }

}

// MARK: - Edit EMail Injection
extension SCInjector: SCEditPasswordInjecting {
    
    func getEditPasswordFinishedViewController(email: String) -> UIViewController {
        
        guard let editingFinishedPassword: SCEditPasswordFinishedVC
            = UIStoryboard(name: "EditProfileScreen",bundle: nil)
                .instantiateViewController(withIdentifier: "SCEditPasswordFinishedVC") as? SCEditPasswordFinishedVC else {
                    fatalError("Could not instantiate SCEditPasswordFinishedVC")
        }
        
        let editingPasswordFinishedWorker = SCEditPasswordFinishedWorker(requestFactory: SCRequest())
        let editingPasswordFinishedPresenter = SCEditPasswordFinishedPresenter(email: email, editingFinishedWorker: editingPasswordFinishedWorker, authProvider: SCAuth.shared, injector: self)
        
        editingFinishedPassword.presenter = editingPasswordFinishedPresenter
        
        
        return editingFinishedPassword
    }
    
    
    func getPWDForgottenViewController(email: String,  completionOnSuccess: ((_ eMail : String, _ emailWasAlreadySentBefore: Bool, _ isError:Bool?, _ errorMessage: String?) -> Void)?) -> UIViewController {
        guard let recoverPwdController = UIStoryboard(name: "PwdRestoreUnlockScreen", bundle: Bundle.main).instantiateViewController(withIdentifier: "RestoreUnlockVC") as? SCPWDRestoreUnlockVC else {
            fatalError("Could not instantiate SCPWDRestoreUnlockVC")
        }
        recoverPwdController.presenter = SCPWDRestoreUnlockPresenter(email: email, screenType: .pwdForgotten, restoreUnlockWorker: SCPWDRestoreUnlockWorker(requestFactory: SCRequest()), injector: self, completionOnSuccess: completionOnSuccess)
        return recoverPwdController
    }

}

// MARK: - Shared Worker Injection
extension SCInjector: SCSharedWorkerInjecting {
    func getCityContentSharedWorker() -> SCCityContentSharedWorking {
        return self.cityContentSharedWorker
    }

    func getAppContentSharedWorker() -> SCAppContentSharedWorking {
        return self.appContentSharedWorker
    }
    
    func getUserContentSharedWorker() -> SCUserContentSharedWorking {
        return self.userContentSharedWorker
    }

    func getAuthorizationSharedWorker() -> SCAuthorizationWorking {
        return self.authorizationSharedWorker
    }
    
    func getUserCityContentSharedWorker() -> SCUserCityContentSharedWorking {
        return self.userCityContentSharedWorker
    }
}

// MARK: - Dashboard Injection
extension SCInjector: SCDashboardInjecting {
    func getNewsOverviewController(with itemList: [SCBaseComponentItem]) -> UIViewController {
        let viewController : SCNewsOverviewTableViewController = UIStoryboard(name: "NewsOverviewScreen", bundle: nil).instantiateInitialViewController() as! SCNewsOverviewTableViewController

        let presenter = SCNewsOverviewPresenter(newsItems: itemList, injector: self)
        viewController.presenter = presenter
        
        return viewController
    }

    func getEventsOverviewController(with eventList: SCModelEventList) -> UIViewController {
        let viewController : SCEventsOverviewViewController = UIStoryboard(name: "EventsOverviewScreen", bundle: nil).instantiateInitialViewController() as! SCEventsOverviewViewController
        
        let worker = SCEventWorker(requestFactory: SCRequest())

        let presenter = SCEventsOverviewPresenter(initialEventItems: eventList.eventList, cityContentSharedWorker: self.cityContentSharedWorker, userCityContentSharedWorker: self.userCityContentSharedWorker , eventWorker: worker, injector: self, dataCache: self.dataCache)
        viewController.presenter = presenter
        
        return viewController
    }
}

// MARK: - Marketplace Injection
extension SCInjector: SCMarketplaceInjecting {
    func getMarketplaceOverviewController(for item: SCBaseComponentItem?) -> UIViewController {

        
        let presenter = SCMarketplaceOverviewPresenter(selectedBranchID: item?.itemID, cityContentSharedWorker: self.cityContentSharedWorker, userContentSharedWorker: self.userContentSharedWorker, authProvider: SCAuth.shared, injector: self, refreshHandler: self.sharedWorkerRefreshHandler)
        let viewController : SCMarketplaceOverviewTableViewController = UIStoryboard(name: "MarketplaceOverviewScreen", bundle: nil).instantiateInitialViewController() as! SCMarketplaceOverviewTableViewController
        
        viewController.presenter = presenter
        viewController.navigationItem.title = item?.itemTitle
        
        return viewController
    }
}

// MARK: - Services Injection
extension SCInjector: SCServicesInjecting {
    
    func getServicesMoreInfoViewController(for serviceDetailProvider: SCServiceDetailProvider, injector: SCServicesInjecting) -> UIViewController {
        let viewController = UIStoryboard(name: "ServicesOverviewScreen", bundle: nil).instantiateViewController(withIdentifier: String(describing: SCServicesMoreInfoViewController.self)) as! SCServicesMoreInfoViewController
        let presenter = SCServicesMoreInfoViewPresenter(injector: injector, serviceDetails: serviceDetailProvider, cityContentSharedWorker: self.cityContentSharedWorker)
        viewController.presenter = presenter
        return viewController
    }
    
    func getWasteCalendarViewController(wasteCalendarItems: [SCModelWasteCalendarItem], calendarAddress: SCModelWasteCalendarAddress?, wasteReminders: [SCHttpModelWasteReminder], item: SCBaseComponentItem, month: String?) -> UIViewController {
        let wasteCalendarVC = UIStoryboard(name: "WasteCalendar", bundle: nil).instantiateViewController(withIdentifier: String(describing: SCWasteCalendarViewController.self)) as! SCWasteCalendarViewController
        let presenter = SCWasteCalendarPresenter(wasteCalendarItems: wasteCalendarItems, calendarAddress: calendarAddress, cityContentSharedWorker: self.cityContentSharedWorker, userContentSharedWorker: self.userContentSharedWorker, wasteCalendarWorker: SCWasteCalendarWorker(requestFactory: SCRequest()), injector: self, dataCache: self.dataCache, wasteReminders: wasteReminders, serviceData: item)
        presenter.deeplinkData = month
        wasteCalendarVC.presenter = presenter
        return wasteCalendarVC
    }

    func getServicesDetailController(for item: SCBaseComponentItem, serviceDetailProvider: SCServiceDetailProvider, isDisplayOverviewScreen: Bool) -> UIViewController {
        let appointmentDashboardController: SCServiceDetailViewController = UIStoryboard(name: "ServicesOverviewScreen", bundle: nil).instantiateViewController(withIdentifier: String(describing: SCServiceDetailViewController.self)) as! SCServiceDetailViewController
        let presenter = SCServiceDetailPresenter(userCityContentSharedWorker: userCityContentSharedWorker, injector: self, serviceData: item, serviceDetail: serviceDetailProvider,
        displayServicePageDirectly: false, isDisplayOverviewScreen: isDisplayOverviewScreen)
        appointmentDashboardController.presenter = presenter
        return appointmentDashboardController
    }

    func getWasteServicesDetailController(for item: SCBaseComponentItem, openCalendar: Bool, with month: String?) -> UIViewController {
        let serviceDetailViewController: SCServiceDetailViewController = UIStoryboard(name: "ServicesOverviewScreen", bundle: nil).instantiateViewController(withIdentifier: String(describing: SCServiceDetailViewController.self)) as! SCServiceDetailViewController
        let wasteCalendarService = getWasteService(serviceData: item,
                                                   wasteCalendarWorker: SCWasteCalendarWorker(requestFactory: SCRequest()),
                                                   delegate: serviceDetailViewController)
        let presenter = SCServiceDetailPresenter(userCityContentSharedWorker: userCityContentSharedWorker, injector: self, serviceData: item, serviceDetail: wasteCalendarService,
        displayServicePageDirectly: openCalendar)
        presenter.wasateCalendarMonth = month
        serviceDetailViewController.presenter = presenter
        return serviceDetailViewController
    }

    func getAppointmentOverviewController(serviceData: SCBaseComponentItem) -> UIViewController {
        let appointmentOverviewController: SCAppointmentOverviewController = UIStoryboard(name: "TEVIS", bundle: nil).instantiateViewController(withIdentifier: String(describing: SCAppointmentOverviewController.self)) as! SCAppointmentOverviewController
        let presenter = SCAppointmentOverviewPresenter(userCityContentSharedWorker: userCityContentSharedWorker,
                                                       cityContentCityIdentifier: cityContentSharedWorker,
                                                       appointmentWorker: SCAppointmentWorker(requestFactory: SCRequest()),
                                                       injector: self,
                                                       serviceData: serviceData, appointmentDeletor: appointmentOverviewController)
        appointmentOverviewController.presenter = presenter
        return appointmentOverviewController
    }

    func getTEVISViewController(for system: String, serviceData : SCBaseComponentItem) -> UIViewController {
        let viewController : UINavigationController = UIStoryboard(name: "TEVIS", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let presenter = SCTevisViewPresenter(userContentSharedWorker: self.userContentSharedWorker, cityContentSharedWorker: self.cityContentSharedWorker, tevisUrl: system, userCityContentSharedWorker: self.userCityContentSharedWorker, serviceData: serviceData, injector: self)
        let tevisViewController = viewController.viewControllers[0] as! SCTevisViewController
        tevisViewController.presenter = presenter
        return viewController
    }

    func getServicesOverviewController(for item: SCBaseComponentItem?) -> UIViewController {

        let presenter = SCServicesOverviewPresenter(selectedServiceCategoryID: item?.itemID, cityContentSharedWorker: self.cityContentSharedWorker, userContentSharedWorker: self.userContentSharedWorker, authProvider: SCAuth.shared, injector: self, refreshHandler: self.sharedWorkerRefreshHandler)
        let viewController : SCServicesOverviewTableViewController = UIStoryboard(name: "ServicesOverviewScreen", bundle: nil).instantiateInitialViewController() as! SCServicesOverviewTableViewController
        
        viewController.presenter = presenter
        viewController.navigationItem.title = item?.itemTitle

        return viewController
    }
    
    func getAusweisAuthServicesDetailController(for serviceWebDetails: SCModelEgovServiceWebDetails) -> UIViewController {

        let navigationController : UINavigationController = UIStoryboard(name: "AusweisAuth", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let viewController = navigationController.viewControllers[0] as! SCAusweisAuthWebViewController
        let presenter = SCAusweisAuthWebPresenter(cityContentSharedWorker: self.cityContentSharedWorker, injector: self , serviceWebDetails: serviceWebDetails )
        viewController.presenter = presenter
        viewController.hidesBottomBarWhenPushed = true
        return viewController
    }

    func getDefectReporterCategoryViewController(categoryList: [SCModelDefectCategory], serviceData: SCBaseComponentItem, serviceFlow: Services) -> UIViewController {
        
        let defectReporterCategorySelectionViewController = UIStoryboard(name: "DefectReporter", bundle: nil).instantiateViewController(withIdentifier: String(describing: SCDefectReporterCategorySelectionViewController.self)) as! SCDefectReporterCategorySelectionViewController
        let presenter = SCDefectReporterCategorySelectionPresenter(serviceData: serviceData, injector: self, worker: SCDefectReporterWorker(requestFactory: SCRequest()), category: categoryList)
        presenter.serviceFlow = serviceFlow
        defectReporterCategorySelectionViewController.presenter = presenter
        return defectReporterCategorySelectionViewController
    }

    func getDefectReporterMoreViewController() -> UIViewController {
        
        let defectReporterMoreInfoViewController = UIStoryboard(name: "DefectReporter", bundle: nil).instantiateViewController(withIdentifier: String(describing: SCDefectReporterMoreInfoViewController.self)) as! SCDefectReporterMoreInfoViewController
        defectReporterMoreInfoViewController.presenter = SCDefectReporterMoreInfoPresenter(injector: self)
        return defectReporterMoreInfoViewController
    }
    
    func getEgovServicesDetailController(for item: SCBaseComponentItem, serviceDetailProvider: SCServiceDetailProvider) -> UIViewController {
        
        let egovServiceDetailsController : SCEgovServiceDetailsViewController = UIStoryboard(name: "EgovServiceDetails", bundle: nil).instantiateViewController(withIdentifier: String(describing: SCEgovServiceDetailsViewController.self)) as! SCEgovServiceDetailsViewController
        let presenter = SCEgovServiceDetailsPresenter(userCityContentSharedWorker: self.userCityContentSharedWorker, cityContentSharedWorker: self.cityContentSharedWorker ,injector: self, serviceData: item, serviceDetail: serviceDetailProvider, worker: self.egovServiceWorker)
        egovServiceDetailsController.presenter = presenter
        return egovServiceDetailsController
        
    }

}

extension SCInjector: SCCategoryFilterInjecting {
    func getCategoryFilterViewController(screenTitle: String, selectBtnText: String, selectAllButtonHidden: Bool? = true, filterWorker: SCFilterWorking, preselectedCategories: [SCModelCategory]?, delegate: SCCategorySelectionDelegate) -> UIViewController {
        let navigationController = UIStoryboard(name: "EventsOverviewScreen", bundle: nil).instantiateViewController(withIdentifier: "SCSelectionViewController") as! UINavigationController
        let eventCategoryViewController = navigationController.topViewController as! SCSelectionViewController
        let presenter = SCCategorySelectionPresenter(display: navigationController, screenTitle:screenTitle, selectBtnText: selectBtnText, selectAllButtonHidden: selectAllButtonHidden ?? true, worker: filterWorker, sharedContentWorker: self.cityContentSharedWorker, delegate: delegate, injector: self)
        presenter.preselectedCategories = preselectedCategories
        eventCategoryViewController.presenter = presenter
        return navigationController
    }
}

extension SCInjector: SCWasteCategoryFilterInjecting {
    
    func getCategoryFilterViewController(screenTitle: String, selectBtnText: String, selectAllButtonHidden: Bool? = true, filterWorker: SCWasteFilterWorking, preselectedCategories: [SCModelCategoryObj]?, delegate: SCWasteCategorySelectionDelegate) -> UIViewController {
        let navigationController = UIStoryboard(name: "EventsOverviewScreen", bundle: nil).instantiateViewController(withIdentifier: "SCWasteSelectionViewController") as! UINavigationController
        let eventCategoryViewController = navigationController.topViewController as! SCWasteSelectionViewController
        let presenter = SCWasteCategorySelectionPresenter(display: navigationController, screenTitle:screenTitle, selectBtnText: selectBtnText, selectAllButtonHidden: selectAllButtonHidden ?? true, worker: filterWorker, sharedContentWorker: self.cityContentSharedWorker, delegate: delegate, injector: self)
        presenter.preselectedCategories = preselectedCategories
        eventCategoryViewController.presenter = presenter
        return navigationController
    }
}

extension SCInjector: SCAppointmentInjecting {
    func getAppointmentDetailController(for appointment: SCModelAppointment,
                                        cityID: Int,
                                        serviceData: SCBaseComponentItem,
                                        appointmentDelegate: (SCAppointmentDeleting & SCAppointmentStatusChanging)?) -> SCAppointmentDetailViewController {
        let appointmentDetailController: SCAppointmentDetailViewController = UIStoryboard(name: "TEVIS", bundle: nil).instantiateViewController(withIdentifier: String(describing: SCAppointmentDetailViewController.self)) as! SCAppointmentDetailViewController
        appointmentDetailController.presenter = SCAppointmentDetailPresenter(appointment: appointment,
                                                                             appointmentWorker: SCAppointmentWorker(requestFactory: SCRequest()),
                                                                             cityID: cityID,
                                                                             injector: self,
                                                                             serviceData: serviceData, appointmentDelegate: appointmentDelegate)
        return appointmentDetailController
    }
}

// MARK: - User InfoBox Injection
extension SCInjector: SCUserInfoBoxInjecting {
    func getUserInfoboxDetailController(with infoBoxItem: SCModelInfoBoxItem, completionAfterDelete: (() -> Void)?) -> UIViewController {
        let navigationController = UIStoryboard(name: "UserInfoBoxDetailScreen", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let detailViewController = navigationController.viewControllers.first as! SCUserInfoBoxDetailViewController
        let detailWorker: SCUserInfoBoxDetailWorking = SCUserInfoBoxWorker(requestFactory: SCRequest())
        
        let presenter = SCUserInfoBoxDetailPresenter(infoBoxItem: infoBoxItem, worker: detailWorker, completionAfterDelete: completionAfterDelete)
        detailViewController.presenter = presenter
        
        return detailViewController
    }
}

// MARK: - WebContent Injection
extension SCInjector: SCWebContentInjecting {

    func getWebContentViewController(for url : String, title : String?, insideNavCtrl: Bool) -> UIViewController{

        let viewController : UINavigationController = UIStoryboard(name: "WebContentScreen", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let webContentViewController = viewController.viewControllers.first as! SCWebContentViewController
        webContentViewController.url = url.absoluteUrl()
        webContentViewController.title = title
        
        if insideNavCtrl {
            return viewController
        }

        return webContentViewController
    }
    
    func getWebContentViewController(for url : String, title : String?, insideNavCtrl: Bool,
                                     itemServiceParams: [String: String]?, serviceFunction: String?) -> UIViewController {
        let viewController : UINavigationController = UIStoryboard(name: "WebContentScreen", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let webContentViewController = viewController.viewControllers.first as! SCWebContentViewController
        webContentViewController.url = url.absoluteUrl()
        webContentViewController.title = title
        webContentViewController.itemServiceParams = itemServiceParams
        webContentViewController.serviceFuncation = serviceFunction
        
        if insideNavCtrl {
            return viewController
        }

        return webContentViewController
    }
    
    
    func getWebContentViewController(forHtmlString htmlString: String, title : String?, insideNavCtrl: Bool) -> UIViewController {
     
        let viewController : UINavigationController = UIStoryboard(name: "WebContentScreen", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let webContentViewController = viewController.viewControllers.first as! SCWebContentViewController
        webContentViewController.htmlString = htmlString
        webContentViewController.title = title
        
        if insideNavCtrl {
            return viewController
        }
        return webContentViewController
    }
    
    func getTextViewContentViewController(forHtmlString htmlString: String, title : String?, insideNavCtrl: Bool) -> UIViewController {
     
        let textViewContentViewController = UIStoryboard(name: "SCTextViewController", bundle: nil).instantiateViewController(withIdentifier: "SCTextViewController") as! SCTextViewController
        textViewContentViewController.content = htmlString
        textViewContentViewController.title = title
        
        if insideNavCtrl {
            return UINavigationController(rootViewController: textViewContentViewController)
        }
        return textViewContentViewController
    }
    
    func getTextInWebViewContentViewController(forHtmlString htmlString: String, title : String?, insideNavCtrl: Bool) -> UIViewController {
        let textInWebViewContentViewController = UIStoryboard(name: "SCTextViewController", bundle: nil).instantiateViewController(withIdentifier: "SCTextInWebViewController") as! SCTextInWebViewController
        textInWebViewContentViewController.content = htmlString
        textInWebViewContentViewController.title = title
        if insideNavCtrl {
            return UINavigationController(rootViewController: textInWebViewContentViewController)
        }
        return textInWebViewContentViewController
    }

}

// MARK: - global location  Injection
extension SCInjector: SCLocationInjecting {
    
}

// MARK: - Event Overview  Injection
extension SCInjector: SCEventOverviewInjecting {
    func getDatePickerController(preSelectedStartDate: Date?, preSelectedEndDate: Date?, delegate: SCDatePickerDelegate) -> UIViewController{
        guard let navCtrl = UIStoryboard(name: "DatePicker", bundle: nil).instantiateInitialViewController() as? UINavigationController,
            let  datePickerController = navCtrl.viewControllers.first as? SCDatePickerViewController else {
                fatalError("Could not instantiate SCDatePickerViewController")
        }
        
        let datePickerPresenter = SCDatePickerPresenter(injector: self, todayDate: Date(), maxMonth: 13, preSelectedStartDate: preSelectedStartDate, preSelectedEndDate: preSelectedEndDate)
        datePickerPresenter.delegate = delegate
        datePickerController.presenter = datePickerPresenter

        return navCtrl
    }
}

// MARK: - Event Detail  Injection
extension SCInjector:  SCEventDetailInjecting{
    func getEventDetailMapController(latitude: Double, longitude: Double, zoomFactor: Float, address: String, locationName: String, tintColor: UIColor) -> UIViewController{
        
        let mapNavigationController = UIStoryboard(name: "MapViewScreen", bundle: nil).instantiateInitialViewController() as! UINavigationController
        if let mapVC = mapNavigationController.viewControllers.first as? SCMapViewController {
            mapVC.setupMap(latitude: latitude, longitude: longitude, locationName: locationName, locationAddress: address, markerTintColor: tintColor, mapInteractionEnabled: true,
                           showDirectionsBtn: true)
        }

        
        
        
        return mapNavigationController
    }
    
    func getEventLightBoxController(_with imageURL: SCImageURL, _and credit: String) -> UIViewController {
        let lightBoxController = UIStoryboard(name: "SCEventLightBox", bundle: nil).instantiateInitialViewController() as! SCEventLightBoxViewController
        //instantiate presenter
        let presenter = SCEventLightBoxPresenter()
        presenter.imageURL = imageURL
        presenter.imageCredit = credit
        lightBoxController.presenter = presenter
        
        return lightBoxController
    }
}


extension SCInjector: SCDisplayEventInjecting {

    func getEventDetailController(with event: SCModelEvent, isCityChanged: Bool, cityId: Int?) -> UIViewController{
        let navigationController = UIStoryboard(name: "EventDetailScreen", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let eventViewController = navigationController.viewControllers.first as! SCEventDetailViewController
        let eventDetailWorker: SCDetailEventWorking = SCEventWorker(requestFactory: SCRequest())
        let eventWorker: SCDashboardEventWorking = SCEventWorker(requestFactory: SCRequest())
        let sharedUserCityContentWorker = self.userCityContentSharedWorker

        let presenter = SCEventDetailPresenter(cityID:self.cityContentSharedWorker.getCityID() , event: event,eventWorker: eventWorker, injector: self, worker: eventDetailWorker, userCityContentSharedWorker: sharedUserCityContentWorker, userContentSharedWorker: self.userContentSharedWorker, cityContentSharedWorker: self.cityContentSharedWorker, isCityChanged: isCityChanged, cityId: cityId)
        eventViewController.presenter = presenter
        
        return eventViewController
    }
}

extension SCInjector: SCQRCodeInjecting {
    
    func getQRCodeController(for appointment: SCModelAppointment) -> UIViewController {
        let qrCodeNavigationController = UIStoryboard(name: "TEVIS", bundle: nil).instantiateViewController(withIdentifier: "QRCodeNavigation") as! UINavigationController
        let qrCodeController = qrCodeNavigationController.viewControllers.first as! SCQRCodeViewController
        let presenter = SCQRCodePresenter(appointment: appointment)
        qrCodeController.presenter = presenter
        return qrCodeNavigationController
    }
}

extension SCInjector: SCMapViewInjecting {

    func getMapController(latitude: Double, longitude: Double, zoomFactor: Float, address: String, locationName: String, tintColor: UIColor) -> UIViewController {
        let mapNavigationController = UIStoryboard(name: "MapViewScreen", bundle: nil).instantiateInitialViewController() as! UINavigationController
        if let mapVC = mapNavigationController.viewControllers.first as? SCMapViewController {
            mapVC.setupMap(latitude: latitude, longitude: longitude, locationName: locationName, locationAddress: address, markerTintColor: tintColor, mapInteractionEnabled: true,
                           showDirectionsBtn: true)
        }

        return mapNavigationController
    }
}

extension SCInjector: SCWasteServiceInjecting {
    
    func getCalendarOptionsTableViewController(items: [String], selectedColorName: String, delegate: SCColorSelectionDelegate) -> UIViewController {
        let tableViewController = UIStoryboard(name: "WasteCalendar", bundle: nil).instantiateViewController(withIdentifier: String(describing: SCCalendarGenericTableViewController.self)) as! SCCalendarGenericTableViewController
        tableViewController.presenter = SCCalendarGenericTableViewPresenter(items: items, selectedColorName: selectedColorName, delegate: delegate)
        return tableViewController
    }
    
    
    func getExportEventOptionsVC(exportWasteTypes: [SCWasteCalendarDataSourceItem]) -> UIViewController {
        let exportEventsOptionsVC = UIStoryboard(name: "WasteCalendar", bundle: nil).instantiateViewController(withIdentifier: String(describing: SCExportEventOptionsViewController.self)) as! SCExportEventOptionsViewController
        exportEventsOptionsVC.presenter = SCExportEventOptionsViewPresenter(exportWasteTypes: exportWasteTypes, injector: self)
        let navController = UINavigationController(rootViewController: exportEventsOptionsVC)
        return navController
    }
    
    func getWasteAddressController(delegate: SCWasteAddressViewResultDelegate?, wasteAddress: SCModelWasteCalendarAddress?, item: SCBaseComponentItem) -> UIViewController {
        let wasteAddressNavController = UIStoryboard(name: "FTUWasteCalendar", bundle: nil).instantiateInitialViewController() as! UINavigationController
        if let wasteAddressController = wasteAddressNavController.viewControllers.first as? SCWasteAddressViewController {
            wasteAddressController.presenter = SCWasteAddressPresenter(
                                                cityContentSharedWorker: cityContentSharedWorker,
                                                wasteCalendarWorker: SCWasteCalendarWorker(requestFactory: SCRequest()),
                                                wasteAddress: wasteAddress,
                                                injector: self,
                                                dataCache: dataCache,
                                                serviceData: item)
            wasteAddressController.delegate = delegate
        }

        return wasteAddressNavController
    }

    func getWasteReminderController(wasteType: SCWasteCalendarDataSourceItem, delegate: SCWasteReminderResultDelegate?, reminders: SCHttpModelWasteReminder?) -> UIViewController {
        let wasteReminderViewController = UIStoryboard(name: "WasteCalendar", bundle: nil).instantiateViewController(withIdentifier: String(describing: SCWasteReminderViewController.self)) as! SCWasteReminderViewController
        wasteReminderViewController.presenter = SCWasteReminderPresenter(wasteType: wasteType,
                                                                         reminders: reminders,
                                                                         wasteCalendarWorker: SCWasteCalendarWorker(requestFactory: SCRequest()),
                                                                         cityContentSharedWorker: cityContentSharedWorker, privacySettings: appContentSharedWorker,
                                                                         injector: self)
        wasteReminderViewController.delegate = delegate
        return wasteReminderViewController
    }
}

extension SCInjector: SCServiceDetailProviderInjecting {

    func getWasteService(serviceData: SCBaseComponentItem, wasteCalendarWorker: SCWasteCalendarWorking, delegate: SCWasteAddressViewResultDelegate) -> SCWasteCalendarService {
        return SCWasteCalendarService(serviceData: serviceData, injector: self, wasteCalendarWorker: wasteCalendarWorker, cityContentSharedWorker: cityContentSharedWorker, dataCache: dataCache, delegate: delegate)
    }
}

extension SCInjector: SCCitizenSurveyServiceInjecting {

    func getCitizenSurveyPageViewController(survey: SCModelCitizenSurvey) -> UIViewController {
        let citizenSurveyPageViewController = UIStoryboard(name: "CitizenSurvey", bundle: nil).instantiateViewController(withIdentifier: String(describing: SCCitizenSurveyPageViewController.self)) as! SCCitizenSurveyPageViewController
        citizenSurveyPageViewController.presenter = SCCitizenSurveyPageViewPresenter(citizenSurvey: survey, surveyWorker: SCCitizenSurveyWorker(requestFactory: SCRequest()), injector: self, cityContentSharedWorker: cityContentSharedWorker)
        return citizenSurveyPageViewController
    }

    func getCitizenSurveyDetailViewController(survey: SCModelCitizenSurveyOverview, serviceData: SCBaseComponentItem) -> UIViewController {
        let citizenSurveyDetailViewController = UIStoryboard(name: "CitizenSurvey", bundle: nil).instantiateViewController(withIdentifier: String(describing: SCCitizenSurveyDetailViewController.self)) as! SCCitizenSurveyDetailViewController
        citizenSurveyDetailViewController.presenter = SCCitizenSurveyDetailPresenter(survey: survey, serviceData: serviceData, singleSurveyWorker: SCCitizenSingleSurveyWorker(requestFactory: SCRequest()), cityID: self.cityContentSharedWorker.getCityID(), injector: self, dataCache: dataCache)
        return citizenSurveyDetailViewController
    }

    func getCitizenSurveyOverViewController(surveyList: [SCModelCitizenSurveyOverview], serviceData: SCBaseComponentItem) -> UIViewController {
        let citizenSurveyOverviewController = UIStoryboard(name: "CitizenSurvey", bundle: nil).instantiateViewController(withIdentifier: String(describing: SCCitizenSurveyOverviewController.self)) as! SCCitizenSurveyOverviewController
        citizenSurveyOverviewController.presenter = SCCitizenSurveyOverviewPresenter(surveyList: surveyList, cityContentSharedWorker: cityContentSharedWorker, surveyWorker: SCCitizenSurveyWorker(requestFactory: SCRequest()), injector: self, serviceData: serviceData)
        return citizenSurveyOverviewController
    }

    func getCitizenSurveyDataPrivacyViewController(survey: SCModelCitizenSurveyOverview, delegate: SCCitizenSurveyDetailViewDelegate?, dataPrivacyNotice: DataPrivacyNotice) -> UIViewController {
        let citizenSurveyDataPrivacyNavController = UIStoryboard(name: "CitizenSurvey", bundle: nil).instantiateViewController(withIdentifier: "SCCitizenSurveyDataPrivacyNavController") as! UINavigationController

        if let dataPrivacyController = citizenSurveyDataPrivacyNavController.viewControllers.first as? SCCitizenSurveyDataPrivacyViewController {
            dataPrivacyController.presenter = SCCitizenSurveyDataPrivacyPresenter(survey: survey, dataCache: dataCache, delegate: delegate, cityContentSharedWorker: cityContentSharedWorker, dataPrivacyNotice: dataPrivacyNotice)
        }

        return citizenSurveyDataPrivacyNavController
    }
}


extension SCInjector: SCBasicPOIGuideServiceInjecting{
    
//    func getBasicPOIGuideCategoryViewController(with poiCategory: [POICategoryInfo], presentationMode: SCBasicPOIGuidePresentationMode, includeNavController: Bool, completionAfterDismiss: (() -> Void)?) -> UIViewController {
    func getBasicPOIGuideCategoryViewController(with poiCategory: [POICategoryInfo], includeNavController: Bool, completionAfterDismiss: (() -> Void)?) -> UIViewController {

        guard let navCtrl = UIStoryboard(name: "BasicPOIGuide", bundle: Bundle.main).instantiateViewController(withIdentifier: "SCBasicPOIGuideCategoryNavVC") as? UINavigationController,
            let basicPOIGuideCategorySelectionVC = navCtrl.viewControllers.first as? SCBasicPOIGuideCategorySelectionVC else {
                fatalError("Could not instantiate SCBasicPOIGuideCategorySelectionVC")
            
        }

        basicPOIGuideCategorySelectionVC.completionAfterDismiss = completionAfterDismiss
//        basicPOIGuideCategorySelectionVC.presentationMode = presentationMode
        
//        let presenter = SCBasicPOIGuideCategorySelectionPresenter(basicPOIGuideWorker: self.basicPOIGuideWorker, appContentSharedWorker: self.appContentSharedWorker, cityContentSharedWorker: self.cityContentSharedWorker, injector: self, userCityContentSharedWorker: self.userCityContentSharedWorker, refreshHandler: self.sharedWorkerRefreshHandler, poiCategory: poiCategory)

        let presenter = SCBasicPOIGuideCategorySelectionPresenter(basicPOIGuideWorker: self.basicPOIGuideWorker, cityContentSharedWorker: self.cityContentSharedWorker, injector: self, poiCategory: poiCategory)

        basicPOIGuideCategorySelectionVC.presenter = presenter
        
        return includeNavController ? navCtrl : basicPOIGuideCategorySelectionVC
    }
    
    func getBasicPOIGuideListMapViewController(with poi: [POIInfo], poiCategory: [POICategoryInfo], item: SCBaseComponentItem) -> UIViewController {

        let navigationController = UIStoryboard(name: "BasicPOIGuide", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let basicPOIGuideListMapFilterViewController = navigationController.viewControllers.first as! SCBasicPOIGuideListMapFilterViewController
        let basicPOIGuideWorker: SCBasicPOIGuideWorking = SCBasicPOIGuideWorker(requestFactory: SCRequest())

        let presenter = SCBasicPOIGuideListMapFilterPresenter(cityID: self.cityContentSharedWorker.getCityID(), poi: poi, poiCategory: poiCategory, injector: self, basicPOIGuideWorker: basicPOIGuideWorker, cityContentSharedWorker: self.cityContentSharedWorker, item: item)

        basicPOIGuideListMapFilterViewController.presenter = presenter
        return basicPOIGuideListMapFilterViewController
    }
}

// MARK: - SCBasicPOIGuide Detail  Injection
extension SCInjector:  SCBasicPOIGuideDetailInjecting{
    func getBasicPOIGuideDetailMapController(latitude: Double, longitude: Double, zoomFactor: Float, address: String, locationName: String, tintColor: UIColor) -> UIViewController{
        
        let mapNavigationController = UIStoryboard(name: "MapViewScreen", bundle: nil).instantiateInitialViewController() as! UINavigationController
        if let mapVC = mapNavigationController.viewControllers.first as? SCMapViewController {
            mapVC.setupMap(latitude: latitude, longitude: longitude, locationName: locationName, locationAddress: address, markerTintColor: tintColor, mapInteractionEnabled: true,
                           showDirectionsBtn: true)
        }

        return mapNavigationController
    }
    
    func getBasicPOIGuideLightBoxController(_with imageURL: SCImageURL, _and credit: String) -> UIViewController {
        let lightBoxController = UIStoryboard(name: "SCEventLightBox", bundle: nil).instantiateInitialViewController() as! SCEventLightBoxViewController
        //instantiate presenter
        let presenter = SCEventLightBoxPresenter()
        presenter.imageURL = imageURL
        presenter.imageCredit = credit
        lightBoxController.presenter = presenter
        
        return lightBoxController
    }
}


extension SCInjector: SCDisplayBasicPOIGuideInjecting {
    func getBasicPOIGuideDetailController(with poi: POIInfo) -> UIViewController{
                
        let navigationController = UIStoryboard(name: "BasicPOIGuideDetail", bundle: nil).instantiateInitialViewController() as! UINavigationController
        let poiGuideViewController = navigationController.viewControllers.first as! SCBasicPOIGuideDetailViewController
//        let sharedUserCityContentWorker = self.userCityContentSharedWorker

        let presenter = SCBasicPOIGuideDetailPresenter(cityID:self.cityContentSharedWorker.getCityID(), poi: poi, injector: self) //, userCityContentSharedWorker: sharedUserCityContentWorker, userContentSharedWorker: self.userContentSharedWorker)
        poiGuideViewController.presenter = presenter
        
        return poiGuideViewController
    }
}

// MARK: - SCAusweisAuthService Injection

extension SCInjector: SCAusweisAuthServiceInjecting {
        
   
    func getAusweisAuthWorkFlowViewController(tcTokenURL : String, cityContentSharedWorker: SCCityContentSharedWorking , injector : SCAusweisAuthServiceInjecting) -> UIViewController {
        
        let viewController = (UIStoryboard(name: "AusweisAuthWorkflow", bundle: nil).instantiateInitialViewController() as! UINavigationController).viewControllers.first as! SCAusweisAuthWorkFlowViewController
        
        let service = SCAusweisAppSDKService.shared
        
        let handler = SCAusweisAppSDKServiceHandler(service: service)
        handler.service = service
        
        let worker = SCAusweisAuthWorker(tcTokenURL: tcTokenURL)
        worker.handler = handler
        
        service.handler = handler // weak assignment
        handler.worker = worker // weak assignment
        
        let presenter = SCAusweisAuthWorkflowPresenter(worker: worker, cityContentSharedWorker: self.cityContentSharedWorker, injector: self)
        worker.workflowPresenter = presenter // weak assignment
        viewController.presenter = presenter
        return viewController
        
    }
    
    func getAusweisAuthLoadingViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController {
        
        let viewController = UIStoryboard(name: "AusweisAuthWorkflow", bundle: nil).instantiateViewController(withIdentifier: "SCAusweisAuthLoadingViewController") as! SCAusweisAuthLoadingViewController
        let presenter = SCAusweisAuthLoadingPresenter(worker: worker, cityContentSharedWorker: self.cityContentSharedWorker, injector: self)
        viewController.presenter = presenter
        return viewController

    }

    func getAusweisAuthServiceOverviewViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController {

        let viewController = UIStoryboard(name: "AusweisAuthWorkflow", bundle: nil).instantiateViewController(withIdentifier: "SCAusweisAuthServiceOverviewController") as! SCAusweisAuthServiceOverviewController
        let presenter = SCAusweisAuthServiceOverviewPresenter(worker: worker, injector: self)
        viewController.presenter = presenter
        return viewController


    }
    
    func getAusweisAuthEnterPINViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController {
        
        let viewController = UIStoryboard(name: "AusweisAuthWorkflow", bundle: nil).instantiateViewController(withIdentifier: "SCAusweisAuthEnterPinViewController") as! SCAusweisAuthEnterPinViewController
        let presenter = SCAusweisAuthEnterPinPresenter(worker: worker, injector: injector)
        viewController.presenter = presenter
        return viewController
        
    }


    func getAusweisAuthInsertCardViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController {
        
        let viewController = UIStoryboard(name: "AusweisAuthWorkflow", bundle: nil).instantiateViewController(withIdentifier: "SCAusweisAuthInsertCardViewController") as! SCAusweisAuthInsertCardViewController
        let presenter = SCAusweisAuthInsertCardPresenter(worker: worker, injector: injector)
        viewController.presenter = presenter
        return viewController
        
    }
    
    
    func getAusweisAuthSuccessViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController {
        
        let viewController = UIStoryboard(name: "AusweisAuthWorkflow", bundle: nil).instantiateViewController(withIdentifier: "SCAusweisAuthSuccessViewController") as! SCAusweisAuthSuccessViewController
        let presenter = SCAusweisAuthSuccessPresenter(worker: worker, injector: self)
        viewController.presenter = presenter
        return viewController
        
    }

    func getAusweisAuthFailureViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController {
        
        let viewController = UIStoryboard(name: "AusweisAuthWorkflow", bundle: nil).instantiateViewController(withIdentifier: "SCAusweisAuthFailureViewController") as! SCAusweisAuthFailureViewController
        let presenter = SCAusweisAuthFailurePresenter(worker: worker, injector: self)
        viewController.presenter = presenter
        return viewController
    }

    func getAusweisAuthProviderInfoViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController {
        
        let viewController = UIStoryboard(name: "AusweisAuthWorkflow", bundle: nil).instantiateViewController(withIdentifier: "SCAusweisAuthProviderInfoViewController") as! SCAusweisAuthProviderInfoViewController
        let presenter = SCAusweisAuthProviderInfoPresenter(worker: worker, injector: self)
        viewController.presenter = presenter
        return viewController
        
    }

    func getAusweisAuthHelpViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController {
        
        
        let viewController = UIStoryboard(name: "AusweisAuthWorkflow", bundle: nil).instantiateViewController(withIdentifier: "SCAusweisAuthHelpViewController") as! SCAusweisAuthHelpViewController
        let presenter = SCAusweisAuthHelpPresenter(worker: worker, injector: injector)
        viewController.presenter = presenter
        return viewController
    }

    func getAusweisAuthNeedCANViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController {
        
        let viewController = UIStoryboard(name: "AusweisAuthWorkflow", bundle: nil).instantiateViewController(withIdentifier: "SCAusweisAuthNeedCanViewController") as! SCAusweisAuthNeedCanViewController
        let presenter = SCAusweisAuthNeedCanPresenter(worker: worker, injector: injector)
        viewController.presenter = presenter
        return viewController

    }

    func getAusweisAuthEnterCANViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController {
        
        let viewController = UIStoryboard(name: "AusweisAuthWorkflow", bundle: nil).instantiateViewController(withIdentifier: "SCAusweisAuthEnterCanViewController") as! SCAusweisAuthEnterCanViewController
        let presenter = SCAusweisAuthEnterCanPresenter(worker: worker, injector: injector)
        viewController.presenter = presenter
        return viewController

    }

    func getAusweisAuthNeedPUKViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController {
        
        let viewController = UIStoryboard(name: "AusweisAuthWorkflow", bundle: nil).instantiateViewController(withIdentifier: "SCAusweisAuthNeedPukViewController") as! SCAusweisAuthNeedPukViewController
        let presenter = SCAusweisAuthNeedPukPresenter(worker: worker, injector: injector)
        viewController.presenter = presenter
        return viewController
        
    }

    func getAusweisAuthEnterPUKViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController {
        
        let viewController = UIStoryboard(name: "AusweisAuthWorkflow", bundle: nil).instantiateViewController(withIdentifier: "SCAusweisAuthEnterPukViewController") as! SCAusweisAuthEnterPukViewController
        let presenter = SCAusweisAuthEnterPukPresenter(worker: worker, injector: injector)
        viewController.presenter = presenter
        return viewController
        
    }
    
    func getAusweisAuthCardBlockedViewController( injector : SCAusweisAuthServiceInjecting , worker : SCAusweisAuthWorking) -> UIViewController {
        
        let viewController = UIStoryboard(name: "AusweisAuthWorkflow", bundle: nil).instantiateViewController(withIdentifier: "SCAusweisAuthCardBlockedViewController") as! SCAusweisAuthCardBlockedViewController
        let presenter = SCAusweisAuthCardBlockedPresenter(worker: worker, injector: injector)
        viewController.presenter = presenter
        return viewController
        
    }


}

// MARK: - SCDefectReporter Injection

extension SCInjector: SCDefectReporterInjecting {
    
    func getDefectReporterLocationViewController(category: SCModelDefectCategory, subCategory: SCModelDefectSubCategory?, serviceData: SCBaseComponentItem, includeNavController: Bool, service: Services, completionAfterDismiss: (() -> Void)?) -> UIViewController {

        guard let navCtrl = UIStoryboard(name: "DefectReporter", bundle: Bundle.main).instantiateViewController(withIdentifier: "SCDefectReporterLocationNavVC") as? UINavigationController,
            let defectReporterLocationViewController = navCtrl.viewControllers.first as? SCDefectReporterLocationViewController else {
                fatalError("Could not instantiate SCDefectReporterLocationViewController")
            
        }

        defectReporterLocationViewController.completionAfterDismiss = completionAfterDismiss

        defectReporterLocationViewController.presenter = SCDefectReporterLocationPresenter(serviceData: serviceData, injector: self, cityContentSharedWorker: self.cityContentSharedWorker, category: category, subCategory: subCategory)

        return includeNavController ? navCtrl : defectReporterLocationViewController
    }
    
    func getFahrradParkenReportedLocationDetailsViewController(with location: FahrradparkenLocation, serviceData: SCBaseComponentItem, compltionHandler: (() -> Void)?) -> UIViewController {
        
        let fahrradparkenLocationDetailsVC = UIStoryboard(name: "Fahrradparken", bundle: nil).instantiateViewController(withIdentifier: String(describing: FahrradparkenReportedLocationDetailVC.self)) as! FahrradparkenReportedLocationDetailVC
        let presenter = FahrradparkenReportedLocationDetailPresenter(reportedLocation: location, serviceData: serviceData, completionHandler: compltionHandler)
        fahrradparkenLocationDetailsVC.presenter = presenter
        return fahrradparkenLocationDetailsVC
    }
    
    func getFahrradparkenReportedLocationViewController(category: SCModelDefectCategory, subCategory: SCModelDefectSubCategory?, serviceData: SCBaseComponentItem, includeNavController: Bool, service: Services, completionAfterDismiss: (() -> Void)?) -> UIViewController {
        guard let navCtrl = UIStoryboard(name: "Fahrradparken", bundle: Bundle.main).instantiateViewController(withIdentifier: "FahrrahdparkenReportedLocationNavVC") as? UINavigationController,
            let fahrradparkenReportedLocationViewController = navCtrl.viewControllers.first as? FahrrahdparkenReportedLocationVC else {
                fatalError("Could not instantiate SCDefectReporterLocationViewController")
            
        }
        
        fahrradparkenReportedLocationViewController.completionAfterDismiss = completionAfterDismiss
        fahrradparkenReportedLocationViewController.presenter = FahrradparkenReportedLocationPresenter(injector: self,
                                                                                                       fahrradParkenReporterWorker: SCFahrradParkenReporterWoker(requestFactory: SCRequest()),
                                                                                                       serviceData: serviceData,
                                                                                                       category: category,
                                                                                                       subCategory: subCategory,
                                                                                                       serviceFlow: service,
                                                                                                       cityContentSharedWorker: cityContentSharedWorker)
        return includeNavController ? navCtrl : fahrradparkenReportedLocationViewController
    }
    
    func getDefectReporterSubCategoryViewController(category: SCModelDefectCategory, subCategoryList: [SCModelDefectSubCategory], serviceData: SCBaseComponentItem, service: Services) -> UIViewController {

        let defectReporterSubcategoryViewController = UIStoryboard(name: "DefectReporter", bundle: nil).instantiateViewController(withIdentifier: String(describing: SCDefectReporterSubcategoryViewController.self)) as! SCDefectReporterSubcategoryViewController
        let presenter = SCDefectReporterSubCategoryPresenter(serviceData: serviceData, injector: self, worker: SCDefectReporterWorker(requestFactory: SCRequest()), category: category, subCategory: subCategoryList)
        presenter.serviceFlow = service
        defectReporterSubcategoryViewController.presenter = presenter
        return defectReporterSubcategoryViewController
    }
    
    func getDefectReporterFormViewController(category: SCModelDefectCategory, subCategory: SCModelDefectSubCategory?, serviceData: SCBaseComponentItem, serviceFlow: Services) -> UIViewController {
        
        let defectReporterFormViewController = UIStoryboard(name: "DefectReporter", bundle: nil).instantiateViewController(withIdentifier: String(describing: SCDefectReporterFormViewController.self)) as! SCDefectReporterFormViewController
        defectReporterFormViewController.subCategory = subCategory
        defectReporterFormViewController.category = category
        var serviceProvider: SCServiceDetailProvider
        switch serviceFlow {
        case .defectReporter:
            serviceProvider = SCDefectReporterServiceDetail(serviceData: serviceData, injector: self, cityContentSharedWorker: cityContentSharedWorker, defectReporterWorker: SCDefectReporterWorker(requestFactory: SCRequest()))
        case .fahrradParken(_):
            serviceProvider = SCFahrradparkenServiceDetail(serviceData: serviceData, injector: self,
                                                           cityContentSharedWorker: cityContentSharedWorker)
        }
        defectReporterFormViewController.presenter = SCDefectReporterFormPresenter(serviceData: serviceData, injector: self,
                                                                                   appContentSharedWorker: self.appContentSharedWorker,
                                                                                   cityContentSharedWorker: self.cityContentSharedWorker,
                                                                                   userContentSharedWorker: self.userContentSharedWorker,
                                                                                   category: category, subCategory: subCategory,
                                                                                   serviceDetail: serviceProvider,
                                                                                   serviceFlow: serviceFlow)
        return defectReporterFormViewController
        
    }
    
    func getDefectReporterFormSubmissionViewController(category: SCModelDefectCategory, subCategory: SCModelDefectSubCategory?, uniqueId: String, serviceFlow: Services, email: String?) -> UIViewController {
        
        let defectReporterFormSubmissionViewController = UIStoryboard(name: "DefectReporter", bundle: nil).instantiateViewController(withIdentifier: String(describing: SCDefectReporterFormSubmissionViewController.self)) as! SCDefectReporterFormSubmissionViewController
        defectReporterFormSubmissionViewController.presenter = SCDefectReporterFormSubmissionPresenter(injector: self, cityContentSharedWorker: self.cityContentSharedWorker, uniqueId: uniqueId, category: category, subCategory: subCategory, serviceFlow: serviceFlow, reporterEmailId: email)
        return defectReporterFormSubmissionViewController
    }
    
    func getDefectReportTermsViewController(for url : String, title : String?, insideNavCtrl: Bool) -> UIViewController{

        guard let navCtrl = UIStoryboard(name: "DefectReporter", bundle: Bundle.main).instantiateViewController(withIdentifier: "SCDefectReporterTermsNavVC") as? UINavigationController,
            let defectReportTermsViewController = navCtrl.viewControllers.first as? SCDefectReportTermsViewController else {
                fatalError("Could not instantiate SCDefectReportTermsViewController")
            
        }

        defectReportTermsViewController.url = url.absoluteUrl()
        defectReportTermsViewController.title = title
        
        return insideNavCtrl ? navCtrl : defectReportTermsViewController

    }
}


// MARK: - SCEgovService Injection

extension SCInjector: SCEgovServiceInjecting {

    func getEgovServicesListViewController(for serviceDetailProvider: SCServiceDetailProvider , worker : SCEgovServiceWorking , injector : SCEgovServiceInjecting & SCServicesInjecting & SCAdjustTrackingInjection, group : SCModelEgovGroup ) -> UIViewController {
    
        let viewController = UIStoryboard(name: "EgovServiceDetails", bundle: nil).instantiateViewController(withIdentifier: "SCEgovServicesListViewController") as! SCEgovServicesListViewController
        let presenter = SCEgovServicesListPresenter(userCityContentSharedWorker: self.userCityContentSharedWorker, injector: injector, serviceDetail: serviceDetailProvider, worker: worker, group: group)
        viewController.presenter = presenter
        return viewController
    }
    
    func getEgovServiceHelpViewController(for serviceDetailProvider: SCServiceDetailProvider , worker : SCEgovServiceWorking , injector : SCEgovServiceInjecting & SCServicesInjecting) -> UIViewController {
        
        let viewController = UIStoryboard(name: "EgovServiceDetails", bundle: nil).instantiateViewController(withIdentifier: "SCEgovServiceHelpViewController") as! SCEgovServiceHelpViewController
        let presenter = SCEgovServiceHelpPresenter(worker: worker, injector: injector, serviceDetails: serviceDetailProvider, cityContentSharedWorker: self.cityContentSharedWorker)
        viewController.presenter = presenter
        return viewController
    }
    
    func getEgovSearchViewController(worker : SCEgovSearchWorking , injector : SCEgovServiceInjecting & SCServicesInjecting & SCAdjustTrackingInjection, serviceDetail: SCServiceDetailProvider) -> UIViewController {
        
        let viewController = UIStoryboard(name: "EgovServiceDetails", bundle: nil).instantiateViewController(withIdentifier: "SCEgovSearchViewController") as! SCEgovSearchViewController
            
        let presenter = SCEgovSearchPresenter(injector: self, cityContentSharedWorker: self.cityContentSharedWorker, worker: worker, searchHistoryManager: SCEgovSearchHistoryManager(), serviceDetail: serviceDetail)
        
        viewController.presenter = presenter
        
        return viewController
        
    }

    
    func getEgovServiceLongDescriptionViewController(service: SCModelEgovService) -> UIViewController {
        
        let viewController = UIStoryboard(name: "EgovServiceDetails", bundle: nil).instantiateViewController(withIdentifier: "SCEgovServiceLongDescriptionViewController") as! SCEgovServiceLongDescriptionViewController
        let presenter = SCEgovServiceLongDescriptionPresenter(service: service, injector: self)
        viewController.presenter = presenter
        return viewController
    }

}

extension SCInjector: MoEngageAnalyticsInjection {
    func setupMoEngageUserAttributes() {
        moEngageAnalyticsHandler.setupMoEngageUserAttributes()
    }
}
