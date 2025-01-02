//
//  SCMainPresenter
//  SmartCity+
//
//  Created by Robert Swoboda - Telekom on 22.05.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

enum SCMainTabBarItemType: Int {
    case home = 0
    case marketplace = 1
    case services = 2
    case userinfo = 3
    case cityImprint = 4
}

protocol SCMainDisplaying: AnyObject, SCDisplaying  {
    func setTabBarItemTitle(_ title: String, for itemType: SCMainTabBarItemType)
    func setTabBarColor(_ color: UIColor)
    func setTabBarItemBadge(for itemType: SCMainTabBarItemType, value: Int, color: UIColor)
    func removeTab(for itemType: SCMainTabBarItemType)
    func restoreAllTabs()
    func selectedController() -> UIViewController?
    func showActivityLayer(_ show : Bool)
    
    func present(viewController: UIViewController)
    func navigationController() -> UINavigationController?
}

protocol SCMainPresenting: SCPresenting {
    func setDisplay(_ display: SCMainDisplaying)
    func injectPresenters(into viewControllers: [UIViewController])
    func getSharedWorkerRefreshHandler() -> SCSharedWorkerRefreshHandling
}

struct SCMainCityPresentationModel {

    let headerImageUrl: SCImageURL
    let coatOfArmsImageURL: SCImageURL

    let areServicesAvailable: Bool
    let areMarketplacesAvailable: Bool
    
    static func fromModel(_ model: SCCityContentModel) -> SCMainCityPresentationModel {
        return SCMainCityPresentationModel(headerImageUrl: model.city.cityImageUrl, coatOfArmsImageURL: model.city.municipalCoatImageUrl,
                                           areServicesAvailable: model.cityConfig.showServicesOption ?? false,
                                           areMarketplacesAvailable: model.cityConfig.showMarketplacesOption ?? false)
    }
}

class SCMainPresenter {
    weak private var display : SCMainDisplaying?

    private let mainWorker: SCMainWorking
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let userContentSharedWorker: SCUserContentSharedWorking
    private let appContentSharedWorker: SCAppContentSharedWorking
    private let authProvider: SCAuthTokenProviding & SCLogoutAuthProviding
    private let injector: SCMainInjecting & SCToolsInjecting & SCRegistrationInjecting & SCAdjustTrackingInjection & MoEngageAnalyticsInjection
    private let refreshHandler : SCSharedWorkerRefreshHandling
    
    private let userCityContentSharedWorker: SCUserCityContentSharedWorking
    private let basicPOIGuideWorker: SCBasicPOIGuideWorking
    
    private var locationSegue: UIStoryboardSegue? // we need a strong reference for dismissing
    private var pushRegistrationDone = false

    private weak var presentedVC: UIViewController?
    private var appStatus: AppStatus = .none
    private var isAppLaunchTracked: Bool = false

    init(mainWorker: SCMainWorking, cityContentSharedWorker: SCCityContentSharedWorking, userContentSharedWorker: SCUserContentSharedWorking, appContentSharedWorker: SCAppContentSharedWorking, authProvider: SCAuthTokenProviding & SCLogoutAuthProviding, injector: SCMainInjecting & SCToolsInjecting & SCRegistrationInjecting & SCAdjustTrackingInjection & MoEngageAnalyticsInjection, refreshHandler: SCSharedWorkerRefreshHandling, userCityContentSharedWorker: SCUserCityContentSharedWorking, basicPOIGuideWorker: SCBasicPOIGuideWorking) {

        self.mainWorker = mainWorker
        self.cityContentSharedWorker = cityContentSharedWorker
        self.userContentSharedWorker = userContentSharedWorker
        self.appContentSharedWorker = appContentSharedWorker
        self.authProvider = authProvider
        self.refreshHandler = refreshHandler
        self.userCityContentSharedWorker = userCityContentSharedWorker
        self.basicPOIGuideWorker = basicPOIGuideWorker
        
        self.injector = injector
        self.injector.setToolsShower(self)
        
        self.setupNotifications()
    }

    deinit {
        SCDataUIEvents.discardNotifications(for: self)
    }

    private func setupNotifications() {
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeLocation, with: #selector(didChangeLocation))
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeCityContent, with: #selector(didChangeContent))
        SCDataUIEvents.registerNotifications(for: self, on: .userDidSignOut, with: #selector(didChangeLoginLogout))
        SCDataUIEvents.registerNotifications(for: self, on: .userDidSignIn, with: #selector(didChangeLoginLogout))
        SCDataUIEvents.registerNotifications(for: self, on: .didReceiveInfoBoxData, with: #selector(didChangeContent))
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeUserDataState, with: #selector(didChangeContent))
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeUserInfoItems, with: #selector(didChangeContent))
        SCDataUIEvents.registerNotifications(for: self, on: .appMovedToForeground, with: #selector(appMovedToForeground))
        SCDataUIEvents.registerNotifications(for: self, on: .isInitialLoadingFinished, with: #selector(didFinishInitialLoading))
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeAppointmentsDataState, with: #selector(didChangeAppointmentsData))
        SCDataUIEvents.registerNotifications(for: self, on: .cityNotAvailable, with: #selector(cityNotAvailable))
        SCDataUIEvents.registerNotifications(for: self, on: UIApplication.didEnterBackgroundNotification, with: #selector(refreshAppLaunchTrackedData))
        SCDataUIEvents.registerNotifications(for: self, on: UIApplication.didBecomeActiveNotification, with: #selector(trackAppLaunch))
    }

    @objc private func didFinishInitialLoading() {
        self.display?.showActivityLayer(false)
        
        if !authProvider.isUserLoggedIn() && SCUserDefaultsHelper.getIsSomeoneEverLoggedIn() {
            self.showProfile()
        }
    }

    @objc private func didChangeFavorites() {
        self.refreshUIContent()
    }
    
    @objc private func didChangeAppointmentsData() {
        self.refreshUIContent()
    }
    
    @objc private func didChangeContent() {
        self.refreshUIContent()
        self.registerForPush()
    }
    @objc private func didChangeLoginLogout() {
        self.refreshUIContent()
    }
    
    @objc private func didChangeLocation() {
        self.display?.showActivityLayer(false)
        self.refreshUIContent()
    }

    @objc private func appMovedToForeground() {
        
        self.refreshHandler.renewSession {
            
            self.refreshHandler.reloadContent(force: true)
        }
            
        self.refreshUIContent()
    }
    
    @objc private func cityNotAvailable() {
        self.cityContentSharedWorker.setStoredCityID(for: SCUserDefaultsHelper.getDefaultCityId())
        self.showLocationSelectorModal()
    }
    
    private func refreshUIContent(){
        if let contentModel = self.cityContentSharedWorker.getCityContentData(for: self.cityContentSharedWorker.getCityID()){
            
            let presentationModel = SCMainCityPresentationModel.fromModel(contentModel)
            
            let unreadUserInfoCount = SCAuth.shared.isUserLoggedIn() ? self.userContentSharedWorker.getInfoBoxData()?.filter { $0.isRead == false }.count : 0
            
            let appointmentBadgeCount = SCAuth.shared.isUserLoggedIn() ? self.userCityContentSharedWorker.getAppointments().filter { $0.isRead == false }.count : 0
            
            self.updateUI(with: presentationModel, unreadUserInfoCount: unreadUserInfoCount ?? 0, appointmentBadgeCount: appointmentBadgeCount)
            //Reverted code
            /*
             totalUnreadNotificationCount(unreadUserInfoCount: unreadUserInfoCount ?? 0, appointmentBadgeCount: appointmentBadgeCount)
             */
            trackAppLaunch()
        }
    }
    
    /*
     private func totalUnreadNotificationCount(unreadUserInfoCount: Int, appointmentBadgeCount: Int) {
         let unreadNotificationCount = unreadUserInfoCount + appointmentBadgeCount
         UserDefaults(suiteName: WidgetUtility().getAppGroupId())?.set(unreadNotificationCount, forKey: "count")
     }
     */


    private func preloadDefaultLocation(completionHandler: (() -> Void)? = nil) {
        self.cityContentSharedWorker.triggerCitiesUpdate { (error) in
            if error == nil {
                
                guard let cityId = self.cityContentSharedWorker.getCities()?.first?.cityID else { return }
                
                self.cityContentSharedWorker.triggerCityContentUpdate(for: cityId) { (error) in
                    if error == nil {
                        if let contentModel = self.cityContentSharedWorker.getCityContentData(for: cityId) {
                        
                            let presentationModel = SCMainCityPresentationModel.fromModel(contentModel)
                        
                            let unreadUserInfoCount = self.userContentSharedWorker.getInfoBoxData()?.filter { $0.isRead == false }.count
                            let appointmentBadgeCount = self.userCityContentSharedWorker.getAppointments().filter { $0.isRead == false }.count

                            DispatchQueue.main.async {
                                if let city = self.cityContentSharedWorker.cityInfo(for: cityId ) {
                                    
                                    SCUserDefaultsHelper.setCityStatus(status: true)
                                    SCUserDefaultsHelper.setDefaultCity(name: city.name, id: city.cityID)

                                    SCImageLoader.sharedInstance.getImage(with: city.serviceImageUrl, completion: nil)
                                    SCImageLoader.sharedInstance.getImage(with: city.marketplaceImageUrl, completion: nil)
                                    SCImageLoader.sharedInstance.getImage(with: city.cityImageUrl, completion: { (_, _) in
                                        self.updateUI(with: presentationModel,
                                                      unreadUserInfoCount: unreadUserInfoCount ?? 0,
                                                      appointmentBadgeCount: appointmentBadgeCount)
                                        self.display?.navigationController()?.dismiss(animated: true, completion: nil)
                                        self.display?.showActivityLayer(false)
                                        completionHandler?()
                                    })
                                }
                            }
                        }
                    } else {
                        self.showRetryDialogLoadingDefaultLocation(for: error!)
                    }
                }
            } else {
                self.showRetryDialogLoadingDefaultLocation(for: error!)
            }
        }
    }
    
    private func showRetryDialogLoadingDefaultLocation(for error: SCWorkerError) {
        self.display?.showErrorDialog(error, retryHandler: { self.preloadDefaultLocation() }, showCancelButton: false, additionalButtonTitle: nil, additionButtonHandler: nil)
    }

    private func updateUI(with presentation: SCMainCityPresentationModel, unreadUserInfoCount: Int, appointmentBadgeCount: Int) {
        self.display?.restoreAllTabs()
        self.updateTabBarTitles()
        self.updateTabBarColor(kColor_cityColor)
        self.updateTabBarTabs(with: presentation)
        self.updateUserinfoBadge(count: unreadUserInfoCount, color: kColor_cityColor)
        updateAppointmentBadge(count: appointmentBadgeCount, color: kColor_cityColor)
    }

    private func updateTabBarTitles() {
        self.display?.setTabBarItemTitle("h_001_navigation_bar_btn_home".localized(), for: .home)
        self.display?.setTabBarItemTitle("h_001_navigation_bar_btn_market_place".localized(), for: .marketplace)
        self.display?.setTabBarItemTitle("h_001_navigation_bar_btn_citizen_services".localized(), for: .services)
        self.display?.setTabBarItemTitle("h_001_navigation_bar_btn_infobox".localized(), for: .userinfo)
        self.display?.setTabBarItemTitle("h_001_navigation_bar_btn_imprint".localized(), for: .cityImprint)
    }

    private func updateTabBarColor(_ color:  UIColor) {
        self.display?.setTabBarColor(color)
    }

    private func updateUserinfoBadge(count: Int, color: UIColor) {
        self.display?.setTabBarItemBadge(for: .userinfo, value: count, color: color)
    }

    private func updateAppointmentBadge(count: Int, color: UIColor) {
        self.display?.setTabBarItemBadge(for: .services, value: count, color: color)
    }

    private func updateTabBarTabs(with presentation: SCMainCityPresentationModel) {
        
        if !presentation.areServicesAvailable {
            self.display?.removeTab(for: .services)
        }

        if !presentation.areMarketplacesAvailable {
            self.display?.removeTab(for: .marketplace)
        }

    }
    
    private func registerForPush() {
        if appContentSharedWorker.firstTimeUsageFinished {
            injector.registerPushForApplication()
        }
    }
}

extension SCMainPresenter: SCPresenting {

    func viewDidLoad() {
        // We will only load the content when the ftu was finished
        // otherwise the FirstTime Usage Process will be started
        // in the app delegate.
        self.display?.showActivityLayer(true)
        
        SCVersionHelper.checkAppUpgrade { appStatus in
            self.appStatus = appStatus
            SCVersionHelper.validateAppVersion(request: SCRequest(), injector: self.injector)

            if self.appContentSharedWorker.firstTimeUsageFinished {
                if self.cityContentSharedWorker.getCityID() != kNoCityIDAvaiable {
                    
                    self.refreshHandler.renewSession {
                    
                        self.refreshHandler.reloadContent(force: true)
                    }
                    
                } else {
                    self.preloadDefaultLocation()
                }
            } else {
                self.preloadDefaultLocation() {
                    if !self.appContentSharedWorker.firstTimeUsageFinished {
                        // Show the complete first time flow
                        self.display?.present(viewController: self.injector.getFTUFlowViewController())
                    }
                }
            }
            
            self.refreshUIContent()
        }
    }

    func viewWillAppear() {
//        self.registerForPush()
    }

    func viewDidAppear() {
        showWhatsNewScreen()
    }

    func showWhatsNewScreen() {
        guard let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as? String else{
            return
        }
        UserDefaults.standard.register(defaults: ["storedBuildVersion" : "-1"])
        
        if (SCVersionHelper.appVersion() == "1.3.5" &&
            buildNumber != UserDefaults.standard.string(forKey: "storedBuildVersion")) &&
            appContentSharedWorker.firstTimeUsageFinished && appStatus != .freshInstall {
            guard let versionInfoVC = UIStoryboard(name: "Dashboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "SCVersionInformationViewController") as? SCVersionInformationViewController else {
                fatalError("Could not instantiate SCVersionInformationViewController")
            }
            self.display?.present(viewController: versionInfoVC)
        }
        UserDefaults.standard.set(buildNumber, forKey: "storedBuildVersion")
    }
}

extension SCMainPresenter: SCMainPresenting {

    func injectPresenters(into viewControllers: [UIViewController]) {

        for viewController in viewControllers {

            if let navigationController = viewController as? UINavigationController,
                let tabViewController = navigationController.viewControllers.first {
                self.injector.configureMainTabViewController(tabViewController)
            }
        }
    }

    func setDisplay(_ display: SCMainDisplaying) {
        self.display = display
    }

    func getSharedWorkerRefreshHandler() -> SCSharedWorkerRefreshHandling {
        return refreshHandler
    }
}

extension SCMainPresenter: SCToolsShowing {
    
    public func showLocationSelector() {
        self.showLocationSelectorModal()
    }
    
    public func showRegistration() {
        let navCtrl = UINavigationController()

        let registrationViewController = self.injector.getRegistrationViewController(completionOnSuccess: { (email, isError, errorMessage) in
            navCtrl.dismiss(animated: true, completion: {
                let confirmViewController = self.injector.getRegistrationConfirmEMailVC(registeredEmail:email, shouldHideTopImage: false, presentationType: .confirmMailForRegistration,isError: isError, errorMessage: errorMessage, completionOnSuccess: {
                    self.presentedVC?.dismiss(animated: true, completion:{self.showLogin(completionOnSuccess: nil)})
                    self.presentedVC = nil
                })
                self.presentedVC = confirmViewController
                self.display?.present(viewController: confirmViewController)
            })
        })
        

        navCtrl.viewControllers = [registrationViewController]
        
        
        self.display?.present(viewController: navCtrl)
    }
    
    func showProfile() {
        
        if SCAuth.shared.isUserLoggedIn() {
            
            let viewController = self.injector.getProfileViewController()
            self.display?.present(viewController: viewController)
            
        } else {
            
            self.showLogin {
            // SMARTC-16614 Improvement: Don't show profile page after login
            // Comment below line for this issue
                self.showProfile()
                self.setupMoEngageUserAttributes()
            }
        }
    }
    
    func showLogin(completionOnSuccess: (() -> Void)?) {
        let viewController = self.injector.getLoginViewController(dismissAfterSuccess: true, completionOnSuccess: completionOnSuccess)
        self.display?.present(viewController: viewController)
    }
    
    private func showLocationSelectorModal() {
        let presentationMode: SCLocationPresentationMode = SCAuth.shared.isUserLoggedIn() ? .signedIn : .notSignedIn
        
        let locationViewController = self.injector.getLocationViewController(presentationMode: presentationMode, includeNavController: true, completionAfterDismiss: nil)
        
        self.display?.present(viewController: locationViewController)
    }
    
    @objc private func trackAppLaunch() {
        let cityData = self.cityContentSharedWorker.getCityContentData(for: self.cityContentSharedWorker.getCityID())
        if !isAppLaunchTracked && cityData != nil {
            ///setting MoEngage User Attribute necessary once data is loaded.
            setupMoEngageUserAttributes()
            self.injector.trackEvent(eventName: AnalyticsKeys.EventName.appLaunched)
            isAppLaunchTracked = true
        }
    }

    private func setupMoEngageUserAttributes() {
        injector.setupMoEngageUserAttributes()
    }
    
    @objc private func refreshAppLaunchTrackedData() {
        isAppLaunchTracked = false
    }
}
