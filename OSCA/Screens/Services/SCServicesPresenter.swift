//
//  SCServicesPresenter.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 13.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

struct SCServicesConfigPresentationModel {

    let servicesHeaderImageUrl: SCImageURL
    let cityCoatOfArmsImageUrl: SCImageURL
    let cityTintColor: UIColor

    let servicesFlags: SCServicesFlags

    static func fromModel(_ model: SCCityContentModel) -> SCServicesConfigPresentationModel {

        let tintColor = kColor_cityColor

        return SCServicesConfigPresentationModel(servicesHeaderImageUrl: model.city.serviceImageUrl,
                                           cityCoatOfArmsImageUrl: model.city.municipalCoatImageUrl,
                                           cityTintColor: tintColor,
                                           servicesFlags: model.cityConfig.toServicesPresentation())
    }
}

struct SCServicesPresentationModel {

    var allServices: [SCBaseComponentItem]
    var newServices: [SCBaseComponentItem]
    var mostRecentServices: [SCBaseComponentItem]
    var favoriteServices: [SCBaseComponentItem]

    var serviceCategories: [SCBaseComponentItem]

    static func fromModel(_ model: [SCModelServiceCategory], userContentWorker: SCUserContentSharedWorking) -> SCServicesPresentationModel {

        let tintColor = kColor_cityColor

        let allTitle = LocalizationKeys.SCServicesViewController.s001services002MarketplacesTitleOurs.localized()
        let newTitle = LocalizationKeys.SCServicesViewController.s001ServicesTitleNew.localized()
        let mostRecentTitle = LocalizationKeys.SCServicesViewController.s001Services002MarketplacesTitleMostUsed.localized()
        let categoriesTitle = LocalizationKeys.SCServicesViewController.s001services002MarketplacesTitleCategories.localized()

        let allServices = SCServicesPresentationModel.sortedAllServices(model: model).map {
            $0.toBaseCompontentItem(tintColor: tintColor, categoryTitle: allTitle, cellType: .tiles_icon, context: .none)
        }
        let newServices = SCServicesPresentationModel.sortedNewServices(model: model).map {
            $0.toBaseCompontentItem(tintColor: tintColor, categoryTitle: newTitle, cellType: .carousel_iconBigText, context: .none)
        }
        let mostRecentServices = SCServicesPresentationModel.sortedMostRecentServices(model: model).map {
            $0.toBaseCompontentItem(tintColor: tintColor, categoryTitle: mostRecentTitle, cellType: .carousel_iconSmallText, context: .none)
        }

        let serviceCategories: [SCBaseComponentItem] = model.map {
            $0.toBaseCompontentItem(tintColor: tintColor, categoryTitle: categoriesTitle, cellType: .tiles_small)
        }

        let favorites = [SCBaseComponentItem]()

        return SCServicesPresentationModel(allServices: allServices,
                                           newServices: newServices,
                                           mostRecentServices: mostRecentServices,
                                           favoriteServices: favorites,
                                           serviceCategories: serviceCategories)
    }
    
    //MARK: - Services methods
    private static func sortedAllServices(model: [SCModelServiceCategory]) -> [SCModelService] {
        var allServices = [SCModelService]();
        for category in model{
            for service in category.services{
                allServices.append(service)
            }
        }
        return allServices.sorted {
            $0.rank < $1.rank
        }
    }
    
    private static func sortedNewServices (model: [SCModelServiceCategory]) -> [SCModelService]{
        var newServices = [SCModelService]();
        for category in model{
            for service in category.services{
                if service.isNew {
                    newServices.append(service)
                }
            }
        }
        return newServices.sorted {
            $0.rank < $1.rank
        }
    }
    
    private static func sortedMostRecentServices (model: [SCModelServiceCategory]) -> [SCModelService]{
        // currently there is no indicator for the most used ones...
        return SCServicesPresentationModel.sortedAllServices(model:model)
    }
    

}

class SCServicesPresenter {

    weak private var display: SCServicesDisplaying?

    private let servicesWorker: SCServicesWorking
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let userContentSharedWorker: SCUserContentSharedWorking
    private let authProvider: SCAuthTokenProviding & SCLogoutAuthProviding
    private let refreshHandler : SCSharedWorkerRefreshHandling
    private let basicPOIGuideWorker: SCBasicPOIGuideWorking

    private let userCityContentSharedWorker: SCUserCityContentSharedWorking
    private let eGovServiceWorker : SCEgovServiceWorking

    private let injector: SCServicesInjecting & SCWebContentInjecting & SCAdjustTrackingInjection & SCWasteServiceInjecting & SCCitizenSurveyServiceInjecting & SCBasicPOIGuideServiceInjecting & SCEgovServiceInjecting & SCWebContentInjecting
    
    private let dataCache: SCDataCaching

    private var presentation: SCServicesPresentationModel?
    private var config: SCServicesConfigPresentationModel?

    private var deepLinkedServiceToPresent: String?
    private var deeplinkMonthData: String?
    private let surveyWorker: SCCitizenSurveyWorking
	private let userDefaultsHelper: UserDefaultsHelping

    init(servicesWorker: SCServicesWorking, cityContentSharedWorker: SCCityContentSharedWorking, userContentSharedWorker: SCUserContentSharedWorking, authProvider: SCAuthTokenProviding & SCLogoutAuthProviding, injector: SCServicesInjecting & SCWebContentInjecting & SCAdjustTrackingInjection & SCWasteServiceInjecting & SCCitizenSurveyServiceInjecting & SCBasicPOIGuideServiceInjecting & SCEgovServiceInjecting, refreshHandler : SCSharedWorkerRefreshHandling, userCityContentSharedWorker: SCUserCityContentSharedWorking, basicPOIGuideWorker: SCBasicPOIGuideWorking, eGovServiceWorker : SCEgovServiceWorking, dataCache: SCDataCaching, surveyWorker: SCCitizenSurveyWorking, userDefaultsHelper: UserDefaultsHelping = UserdefaultHelper()) {

        self.servicesWorker = servicesWorker
        self.cityContentSharedWorker = cityContentSharedWorker
        self.userContentSharedWorker = userContentSharedWorker
        self.authProvider = authProvider
        self.refreshHandler = refreshHandler
        self.userCityContentSharedWorker = userCityContentSharedWorker
        self.basicPOIGuideWorker = basicPOIGuideWorker
        self.injector = injector
        self.dataCache = dataCache
        self.eGovServiceWorker = eGovServiceWorker
        self.surveyWorker = surveyWorker
		self.userDefaultsHelper = userDefaultsHelper

        self.setupNotifications()
    }

    deinit {
        SCDataUIEvents.discardNotifications(for: self)
    }

    private func setupNotifications() {
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeLocation, with: #selector(didChangeLocation))
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeCityContent, with: #selector(didChangeContent))
        SCDataUIEvents.registerNotifications(for: self, on: .userDidSignOut, with: #selector(didLogout))
        SCDataUIEvents.registerNotifications(for: self, on: .userDidSignIn, with: #selector(didChangeContent))
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeUserDataState, with: #selector(didChangeContent))
        SCDataUIEvents.registerNotifications(for: self, on: .cityContentLoadingFailed, with: #selector(didChangeContent))
        SCDataUIEvents.registerNotifications(for: self, on: .citiesLoadingFailed, with: #selector(didChangeContent))
        SCDataUIEvents.registerNotifications(for: self, on: .userDataLoadingFailed, with: #selector(didChangeContent))
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeServiceContentState, with: #selector(didChangeContent))
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeAppointmentsDataState, with: #selector(didChangeAppointmentsData))
        SCDataUIEvents.registerNotifications(for: self, on: .didLaunchPOI, with: #selector(didLaunchPOI))
        SCDataUIEvents.registerNotifications(for: self, on: .didUpdateAppPreviewMode, with: #selector(handleAppPreviewModeChange))
    }
    
    @objc private func handleAppPreviewModeChange() {
        self.display?.handleAppPreviewBannerView()
        refreshAppDataOnModeChange()
    }

    @objc private func didLogout() {
        self.display?.resetUI()
        self.refreshUIContent()
    }

    @objc private func didChangeContent() {
        self.refreshUIContent()
    }
    
    @objc private func didChangeLocation() {
        self.display?.resetUI()
        self.refreshUIContent()
        self.preloadPOICategories()
    }
    
    @objc private func didChangeAppointmentsData() {
        injectAppointmentBadgeInPresentation()
    }
    
    @objc private func didLaunchPOI() {
        preloadPOICategories()
    }

    private func refreshUIContent(){
        
        // SO THIS A SAMPLE IMPLEMTATION HOW TO REFRESH THE UI
        
        let servicesState = self.cityContentSharedWorker.servicesDataState

        // handle casess when no data were initialized
        if !servicesState.dataInitialized{
            self.presentation = nil
            
            switch servicesState.dataLoadingState {
            case .needsToBefetched:
                self.display?.showActivityInfoOverlay()
            case .fetchingInProgress:
                self.display?.showActivityInfoOverlay()
            case .fetchFailed, .backendActionNotAvailableForCity:
                self.clearUI()
                self.display?.endRefreshing()
                self.display?.showErrorInfoOverlay()
            case .fetchedWithSuccess:
                // this combination should not exist...
                self.display?.endRefreshing()
                self.display?.showErrorInfoOverlay()
            }
        } else {
            // if there are data available
            
            if servicesState.dataLoadingState != .fetchingInProgress{
                self.display?.endRefreshing()
            }
            self.display?.hideInfoOverlay()
            if let serviceModel = self.cityContentSharedWorker.getServices(for: self.cityContentSharedWorker.getCityID()){
                let cityDataState = self.cityContentSharedWorker.cityContentDataState
                if cityDataState.dataInitialized {
                    
                    let presentationModel = SCServicesPresentationModel.fromModel(serviceModel, userContentWorker: self.userContentSharedWorker)
                    
                    for component in presentationModel.allServices {
                    
                        if component.itemFunction == "egov" {
                            debugPrint("Found eGov service for the current city, preloading the group icons")
                            preloadeGovGroupIcons()
                            break;
                        }                        
                    }
                    
                    self.updateUI(with: presentationModel)
                    self.executeDeepLinking()
                }
            } else {
                // when data are intitilized then this should also not happen
                self.clearUI()
                self.display?.showErrorInfoOverlay()
            }
        }
        
        
        // Update always the config for service top image
        if let cityContent = self.cityContentSharedWorker.getCityContentData(for: self.cityContentSharedWorker.getCityID()){
                self.updateUI(with: SCServicesConfigPresentationModel.fromModel(cityContent))
            self.display?.setServiceDesc(cityContent.cityServiceDesc)

        }

        // Update Appointment bagde count in presentation
        injectAppointmentBadgeInPresentation()
    }

    private func injectAppointmentBadgeInPresentation() {
        let badgeCount = userCityContentSharedWorker.getAppointments().filter { $0.isRead == false }.count
        if badgeCount != 0, var presentation = presentation {
            for i in 0..<presentation.allServices.count {
                if presentation.allServices[i].itemFunction?.lowercased() == "termine" {
                    presentation.allServices[i].badgeCount = badgeCount
                }
            }
            updateUI(with: presentation)
        }
    }

    private func updateUI(with presentation: SCServicesPresentationModel) {
        debugPrint("SCServicesPresenter->updateUI SCServicesPresentationModel")

        self.presentation = presentation

        self.display?.updateAllServices(with: presentation.allServices)
        self.display?.updateNewServices(with: presentation.newServices)
        self.display?.updateMostRecents(with: presentation.mostRecentServices)
        self.display?.updateFavorites(with: presentation.favoriteServices)
        self.display?.updateCategories(with: presentation.serviceCategories)

        self.display?.configureContent()
        self.prefetchServicesImages(items: presentation.allServices)
    }

    func prefetchServicesImages(items: [SCBaseComponentItem]) {
        let urls = items.compactMap {
            $0.itemImageURL?.absoluteUrl()
        }

        PrefetchNetworkImages.prefetchImagesFromNetwork(with: urls)
    }
    
    private func clearUI() {
        self.display?.updateAllServices(with: [])
        self.display?.updateNewServices(with: [])
        self.display?.updateMostRecents(with: [])
        self.display?.updateFavorites(with: [])
        self.display?.updateCategories(with: [])

        self.display?.configureContent()
    }

    private func updateUI(with config: SCServicesConfigPresentationModel) {
        debugPrint("SCServicesPresenter->updateUI SCServicesConfigPresentationModel")

        self.config = config

        self.display?.setHeaderImageURL(config.servicesHeaderImageUrl)
        self.display?.setCoatOfArmsImageURL(config.cityCoatOfArmsImageUrl)
        self.display?.customize(color: config.cityTintColor)

    }
    
    private func findServicePerName(name: String) -> SCBaseComponentItem? {
        if let presentation = self.presentation {
            for service in presentation.allServices {
                if service.itemFunction == name {
                    return service
                }
            }
        }
        return nil
    }

    private func executeDeepLinking() {
        let servicesState = self.cityContentSharedWorker.servicesDataState
        let cityDataState = self.cityContentSharedWorker.cityContentDataState

        if self.deepLinkedServiceToPresent != nil && servicesState.dataInitialized && cityDataState.dataInitialized && self.display != nil{
            self.showDeepLinkedService(name: self.deepLinkedServiceToPresent!, month: deeplinkMonthData)
            self.deepLinkedServiceToPresent = nil
            self.deeplinkMonthData = nil
        }
    }
    
    private func refreshAppDataOnModeChange() {
        self.cityContentSharedWorker.triggerCitiesUpdate { error in
            guard error == nil else {
                self.showRetryDialogLoadingDefaultLocation(for: error)
                return
            }
            self.cityContentSharedWorker.updateSelectedCityIdIfNotFoundInCitiesList { error in
                guard error == nil else {
                    return
                }
                self.refreshHandler.reloadContent(force: true)
                self.refreshUIContent()
            }
        }
    }
    
    private func showRetryDialogLoadingDefaultLocation(for error: SCWorkerError?) {
        guard let error = error else {
            return
        }
        self.display?.showErrorDialog(error,
                                      retryHandler: { self.refreshAppDataOnModeChange() },
                                      showCancelButton: false,
                                      additionalButtonTitle: nil,
                                      additionButtonHandler: nil)
    }
}

// MARK: - SCPresenting

extension SCServicesPresenter: SCPresenting {
    func viewDidLoad() {
        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.openService)
        self.refreshUIContent()
        
    }

    func viewWillAppear() {
        self.display?.cancelFavDeletionMode()
    }

    func viewDidAppear() {
        self.refreshUIContent()
        self.executeDeepLinking()
    }
}

// MARK: - SCServicesPresenting

extension SCServicesPresenter: SCServicesPresenting {

    func showDeepLinkedService(name: String, month: String?) {
        if self.display != nil {
            switch name {
            case "/appointment/overview":
                let servicesState = self.cityContentSharedWorker.servicesDataState
                let cityDataState = self.cityContentSharedWorker.cityContentDataState
                if servicesState.dataInitialized && cityDataState.dataInitialized {
                    if let item = findServicePerName(name: "termine") {

                        // if only show the appointment  overview if the
                        // tile is not locked or the usert is logged in
                        if SCAuth.shared.isUserLoggedIn() || !item.itemLockedDueAuth {
                            let appointmentService = SCAppointmentServiceDetail(serviceData: item,
                                                                              injector: injector, userCityContentSharedWorker: userCityContentSharedWorker)
                            let serviceDetailViewController = self.injector.getServicesDetailController(for: item, serviceDetailProvider: appointmentService, isDisplayOverviewScreen: false)
                            let appointmentOverview = self.injector.getAppointmentOverviewController(serviceData: item)
                            self.display?.pushDeepLinked(viewControllers: [serviceDetailViewController, appointmentOverview])
                        }
                    }
                } else {
                    self.deepLinkedServiceToPresent = name
                }
            case "/waste/overview":
                let servicesState = self.cityContentSharedWorker.servicesDataState
                let cityDataState = self.cityContentSharedWorker.cityContentDataState
                if servicesState.dataInitialized && cityDataState.dataInitialized {
                    if let item = findServicePerName(name: "waste") {

                        // if only show the waste  overview if the
                        // tile is not locked or the usert is logged in
                        injector.trackEvent(eventName: AnalyticsKeys.Widget.WasteCalendar.wasteWidgetTapped)
                        if SCAuth.shared.isUserLoggedIn() || !item.itemLockedDueAuth {
                            let serviceDetailViewController = self.injector.getWasteServicesDetailController(for: item,
                                                                                                             openCalendar: true,
                                                                                                             with: month)
                            self.display?.pushDeepLinked(viewControllers: [serviceDetailViewController])
                        }
                    }
                } else {
                    self.deepLinkedServiceToPresent = name
                }
                
            case "/polls/list":
                let servicesState = self.cityContentSharedWorker.servicesDataState
                let cityDataState = self.cityContentSharedWorker.cityContentDataState
                if servicesState.dataInitialized && cityDataState.dataInitialized {
                    if let item = findServicePerName(name: "bürgerumfragen") {
                        if SCAuth.shared.isUserLoggedIn() || !item.itemLockedDueAuth {
                            let serviceDetailController = self.injector.getServicesDetailController(for: item, serviceDetailProvider: SCCitizenSurveyService(serviceData: item, injector: injector, cityContentSharedWorker: cityContentSharedWorker, surveyWorker: SCCitizenSurveyWorker(requestFactory: SCRequest())),
                                                                                                    isDisplayOverviewScreen: true)
                            
                            self.display?.pushDeepLinked(viewControllers: [serviceDetailController])
                        }
                        else{
                            self.display?.showNeedsToLogin(with: "dialog_login_required_message", cancelCompletion: {},loginCompletion: {
                                self.injector.showLogin {
                                    self.showDeepLinkedService(name: "/polls/list", month: nil)
                                }
                            })
                        }
                    }
                } else {
                    self.deepLinkedServiceToPresent = name
                }

            case "/defectreporter":
                let servicesState = self.cityContentSharedWorker.servicesDataState
                let cityDataState = self.cityContentSharedWorker.cityContentDataState
                if servicesState.dataInitialized && cityDataState.dataInitialized {
                    if let item = findServicePerName(name: "mängelmelder") {
                        if SCAuth.shared.isUserLoggedIn() || !item.itemLockedDueAuth {
                            let defectReporterViewController = self.injector.getServicesDetailController(for: item, serviceDetailProvider: SCDefectReporterServiceDetail(serviceData: item, injector: self.injector, cityContentSharedWorker: self.cityContentSharedWorker, defectReporterWorker: SCDefectReporterWorker(requestFactory: SCRequest())), isDisplayOverviewScreen: false)
                            self.display?.pushDeepLinked(viewControllers: [defectReporterViewController])
                        }
                    }
                } else {
                    self.deepLinkedServiceToPresent = name
                }
                
            case "/egov":
                let servicesState = self.cityContentSharedWorker.servicesDataState
                let cityDataState = self.cityContentSharedWorker.cityContentDataState
                if servicesState.dataInitialized && cityDataState.dataInitialized {
                    if let item = findServicePerName(name: "egov") {
                        if SCAuth.shared.isUserLoggedIn() || !item.itemLockedDueAuth {
                            let egovServiceDetailsController = self.injector.getEgovServicesDetailController(for: item, serviceDetailProvider: SCAusweisAuthServiceDetail(serviceData: item, injector: self.injector, userCityContentSharedWorker: self.userCityContentSharedWorker))
                            self.display?.pushDeepLinked(viewControllers: [egovServiceDetailsController])
                        }
                    }
                } else {
                    self.deepLinkedServiceToPresent = name
                }

            default:
                break
            }
        } else {
            // when there is currently no display set, then we will store the deplink Service Name and present it later
            self.deepLinkedServiceToPresent = name
            deeplinkMonthData = month
        }
    }

    func setDisplay(_ display: SCServicesDisplaying) {
        self.display = display
    }

    func needsToReloadData() {
        self.refreshHandler.reloadContent(force: true)
        self.refreshUIContent()
    }

    func locationButtonWasPressed() {
        self.display?.cancelFavDeletionMode()
        self.injector.showLocationSelector()
    }

    func profileButtonWasPressed() {
        self.display?.cancelFavDeletionMode()
        self.injector.showProfile()
    }

    func editFavoritesButtonWasPressed() {
        self.display?.toggleFavoritesEditing()
    }

    func showAllButtonWasPressed() {
        self.display?.cancelFavDeletionMode()
        self.display?.push(viewController: self.injector.getServicesOverviewController(for: nil))
    }

    func itemSelected(_ item: SCBaseComponentItem) {
        self.display?.cancelFavDeletionMode()

        debugPrint("itemSelected:", item.itemTitle, item.itemContext, item)
        trackServiceTappedEvent(with: item.serviceType)
        guard item.itemFunction == nil else {
            
            if item.templateId == 1 {
                if item.itemDetail != nil {
                    self.showWebview(title: item.itemTitle,  urlString: item.itemDetail!, itemLockedDueAuth: item.itemLockedDueAuth)
                    return
                }
                
            } else {
                if item.itemFunction!.isAbsoluteUrlString() {
                    self.showWebview(title: item.itemTitle,  urlString: item.itemFunction!, itemLockedDueAuth: item.itemLockedDueAuth)
                    return
                }
                
                switch item.itemFunction {
                case "TEVISWEBVIEW":
                    //self.showTevisWebview()
                    return

                case "termine", "waste", "bürgerumfragen", "certificate", "market-stand", "poi",
                    "egov", "mängelmelder", "egov-light", "Fahrradparken":
                    displayServiceDetailViewController(item: item)
                    return

                case .none, .some(_):
                    let imageUrl = item.headerImageURL != nil ? item.headerImageURL : item.itemImageURL
                    self.showContent(displayContentType: .service, navTitle: item.itemTitle, title: LocalizationKeys.SCServicesViewController.s001ServicesTitle.localized(),
                                     teaser: "", subtitle: "", details: item.itemDetail,
                                     imageURL: imageUrl,
                                     photoCredit : item.itemImageCredit, contentURL: nil,
                                     tintColor : item.itemColor, serviceFunction: item.itemFunction,
                                     lockedDueAuth: item.itemLockedDueAuth,
                                     lockedDueResidence: item.itemLockedDueResidence,
                                     btnActions: item.itemBtnActions,
                                     itemServiceParams: item.itemServiceParams,
                                     seviceType: item.serviceType)
                    
                    if item.itemFunction?.lowercased() == "tourism" {
                        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.openServiceDestinations)
                    } else if item.itemFunction?.lowercased() == "termindetails" {
                        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.openServiceAppointments)
                    }

                    break
                }
            }
            debugPrint("function not handled: \(item.itemFunction ?? "unknown")")
            return
        }
        
        if item.itemContext == .overview {

            self.showServiceOverview(for: item)

        } else {

        }
    }

    func getServicesFlags() -> SCServicesFlags {
        return self.config?.servicesFlags ?? SCServicesFlags.showNone()
    }
    
    private func trackServiceTappedEvent(with type: String?) {
        var parameters = [String: String]()
        parameters[AnalyticsKeys.TrackedParamKeys.citySelected] = kSelectedCityName
        parameters[AnalyticsKeys.TrackedParamKeys.cityId] = kSelectedCityId
        parameters[AnalyticsKeys.TrackedParamKeys.userStatus] = SCAuth.shared.isUserLoggedIn() ? AnalyticsKeys.TrackedParamKeys.loggedIn : AnalyticsKeys.TrackedParamKeys.notLoggedIn
        parameters[AnalyticsKeys.TrackedParamKeys.serviceType] = type ?? ""
        injector.trackEvent(eventName: AnalyticsKeys.EventName.webTileTapped,
                            parameters: parameters)
    }
}

// MARK: - private helpers for SCServicesPresenting
extension SCServicesPresenter {

    private func displayServiceDetailViewController(item: SCBaseComponentItem) {

        var successBlock = {}

        switch item.itemFunction {
        case "termine":
            successBlock = {
                self.injector.trackEvent(eventName: AnalyticsKeys.EventName.openServiceAppointments)

                let appointmentViewController = self.injector.getServicesDetailController(for: item, serviceDetailProvider: SCAppointmentServiceDetail(serviceData: item, injector: self.injector, userCityContentSharedWorker: self.userCityContentSharedWorker), isDisplayOverviewScreen: false)
                self.display?.push(viewController: appointmentViewController)
            }

        case "waste":
            successBlock = {
                self.injector.trackEvent(eventName: AnalyticsKeys.EventName.openServiceWasteCalendar)

                let wasteViewController = self.injector.getWasteServicesDetailController(for: item, openCalendar: false, with: nil)
                self.display?.push(viewController: wasteViewController)
            }

        case "bürgerumfragen":
            successBlock = {
                self.injector.trackEvent(eventName: AnalyticsKeys.EventName.openServiceSurveyDetail)

                let surveyViewController = self.injector.getServicesDetailController(for: item, serviceDetailProvider: SCCitizenSurveyService(serviceData: item, injector: self.injector, cityContentSharedWorker: self.cityContentSharedWorker, surveyWorker: SCCitizenSurveyWorker(requestFactory: SCRequest())), isDisplayOverviewScreen: false)
                self.display?.push(viewController: surveyViewController)
            }
            
        case "poi":
            successBlock = {
                
                self.injector.trackEvent(eventName: AnalyticsKeys.EventName.openServicePoiGuide)
                SCDataUIEvents.postNotification(for: .didLaunchPOI)
                
                let poiGuideViewController = self.injector.getBasicPOIGuideListMapViewController(with: self.basicPOIGuideWorker.getCityPOI() ?? [], poiCategory: self.basicPOIGuideWorker.getCityPOICategories() ?? [], item: item)
                self.display?.push(viewController: poiGuideViewController)
                
            }

        case "certificate", "market-stand", "egov-light":

            successBlock = {

                let ausweisAuthServiceViewController = self.injector.getServicesDetailController(for: item, serviceDetailProvider: SCAusweisAuthServiceDetail(serviceData: item, injector: self.injector, userCityContentSharedWorker: self.userCityContentSharedWorker), isDisplayOverviewScreen: false)
                self.display?.push(viewController: ausweisAuthServiceViewController)
            }
            
        case "egov" :

            successBlock = {
                self.injector.trackEvent(eventName: AnalyticsKeys.EventName.openServiceEgov)

                let egovServiceDetailsController = self.injector.getEgovServicesDetailController(for: item, serviceDetailProvider: SCAusweisAuthServiceDetail(serviceData: item, injector: self.injector, userCityContentSharedWorker: self.userCityContentSharedWorker))
                self.display?.push(viewController: egovServiceDetailsController)
            }

        case "mängelmelder":
            successBlock = {
                self.injector.trackEvent(eventName: AnalyticsKeys.EventName.openServiceDefectReporter)

                let defectReporterViewController = self.injector.getServicesDetailController(for: item, serviceDetailProvider: SCDefectReporterServiceDetail(serviceData: item, injector: self.injector, cityContentSharedWorker: self.cityContentSharedWorker, defectReporterWorker: SCDefectReporterWorker(requestFactory: SCRequest())), isDisplayOverviewScreen: false)
                self.display?.push(viewController: defectReporterViewController)
            }
        case "Fahrradparken":
            successBlock = {
                //TODO: Add "openServiceFahrradparken" to adjust analytics
                self.injector.trackEvent(eventName: AnalyticsKeys.EventName.openServiceFahrradparken)
                let fahrradparkenServiceProvider = SCFahrradparkenServiceDetail(serviceData: item,
                                                                                injector: self.injector,
                                                                                cityContentSharedWorker: self.cityContentSharedWorker)
                let defectReporterViewController = self.injector.getServicesDetailController(for: item,
                                                                                             serviceDetailProvider: fahrradparkenServiceProvider,
                                                                                             isDisplayOverviewScreen: false)
                self.display?.push(viewController: defectReporterViewController)
            }
            
        case .none, .some(_):
            break
        }

        if !SCAuth.shared.isUserLoggedIn() && item.itemLockedDueAuth {
            self.display?.showNeedsToLogin(with: "dialog_login_required_message", cancelCompletion: {},loginCompletion: {
                self.injector.showLogin {
                    successBlock()
                }
            })
        } else {
            successBlock()
        }
    }

    private func showWebview(title : String?, urlString : String, itemLockedDueAuth: Bool) {
        
        let successBlock = {
            if UIApplication.shared.canOpenURL(urlString.absoluteUrl()) {
                SCInternalBrowser.showURL(urlString.absoluteUrl(), withBrowserType: .safari, title: title)
            }
        }

        if !SCAuth.shared.isUserLoggedIn() && itemLockedDueAuth {
            self.display?.showNeedsToLogin(with: "dialog_login_required_message", cancelCompletion: {},loginCompletion: {
                self.injector.showLogin {
                    successBlock()
                }
            })
        } else {
            successBlock()
        }
    }

    private func showServiceOverview(for item: SCBaseComponentItem?) {

        let viewController = self.injector.getServicesOverviewController(for: item)

        self.display?.push(viewController: viewController)
    }

    private func showContent(displayContentType : SCDisplayContentType,
                             navTitle : String,
                             title : String,
                             teaser : String,
                             subtitle : String,
                             details : String?,
                             imageURL : SCImageURL?,
                             photoCredit : String?,
                             contentURL : URL?,
                             tintColor : UIColor?,
                             serviceFunction :  String? = nil,
                             lockedDueAuth : Bool? = false,
                             lockedDueResidence : Bool? = false,
                             btnActions: [SCComponentDetailBtnAction]? = nil,
                             itemServiceParams : [String:String]? = nil,
                             seviceType: String? = nil) {
        
        let successBlock = {
            let contentViewController = SCDisplayContent.getMessageDetailController(displayContentType : displayContentType,
                                                                                 navTitle : navTitle,
                                                                                 title : "",
                                                                                 teaser : teaser,
                                                                                 subtitle: subtitle,
                                                                                 details : details,
                                                                                 imageURL : imageURL,
                                                                                 photoCredit : photoCredit,
                                                                                 contentURL : contentURL,
                                                                                 tintColor : tintColor,
                                                                                    serviceFunction: serviceFunction,
                                                                                 lockedDueAuth : lockedDueAuth,
                                                                                 lockedDueResidence : lockedDueResidence,
                                                                                 btnActions: btnActions,
                                                                                 injector: self.injector as! SCInjector,
                                                                                 serviceType: seviceType,
                                                                                    itemServiceParams: itemServiceParams, beforeDismissCompletion: { SCUtilities.delay(withTime: 0.1, callback: {self.display?.showNavigationBar(true)})})
             
             
             
             self.display?.push(viewController: contentViewController)
        }
        
        if !SCAuth.shared.isUserLoggedIn() && lockedDueAuth ?? false {
            self.display?.showNeedsToLogin(with: "dialog_login_required_message", cancelCompletion: {},loginCompletion: {
                self.injector.showLogin {
                    successBlock()
                }
            })
        } else {
            successBlock()
        }
     }

    private func getServicesSectionItems(from serviceCategories: [SCModelServiceCategory], with categoryItemID: String?) -> [SCServicesOverviewSectionItem] {

        var items = [SCServicesOverviewSectionItem]()

        for categories in serviceCategories {

            var subItems = [SCBaseComponentItem]()
            let tintColor = self.config?.cityTintColor ?? UIColor(named: "CLR_OSCA_BLUE")!

            // add all categories or only the selected
            if categoryItemID == nil || categories.id == categoryItemID {
                for services in categories.services {
                    subItems.append(SCBaseComponentItem(itemID : services.id, itemTitle: services.serviceTitle, itemTeaser : nil, itemSubtitle: nil, itemImageURL: services.imageURL, itemImageCredit: nil, itemThumbnailURL: nil, itemIconURL: services.iconURL, itemURL: nil, itemDetail: services.serviceDescription, itemHtmlDetail: true ,itemCategoryTitle : "s_001_services_002_marketplaces_title_categories".localized(),itemColor : tintColor, itemCellType: .not_specified, itemLockedDueAuth: !(!services.authNeeded || SCAuth.shared.isUserLoggedIn()), itemLockedDueResidence:!SCFeatureToggler.shared.isUserResidentOfSelectedCity() && services.residence , itemIsNew: services.isNew, itemFunction : services.serviceFunction, itemContext: .overview))
                }

                let item = SCServicesOverviewSectionItem(itemID : categories.id, itemTitle: categories.categoryTitle, itemColor: tintColor, listItems: subItems.sorted {$0.itemTitle < $1.itemTitle})

                items.append(item)
            }
        }
        return items.sorted {
            $0.itemTitle < $1.itemTitle
        }
    }
    
    private func preloadeGovGroupIcons() {
        eGovServiceWorker.getEgovGroups(cityId: "\(self.cityContentSharedWorker.getCityID())") { eGovGroupModels, error in
            
            for group in eGovGroupModels {
                
                debugPrint("Downloading image eGov Icon -> \(group.groupIcon) ")
                SCImageLoader.sharedInstance.prefetchImage(imageURL: SCImageURL(urlString: group.groupIcon, persistence: false))
            
            }
        }
    }
    
    private func preloadPOICategories() {
        
        if let serviceModel = self.cityContentSharedWorker.getServices(for: self.cityContentSharedWorker.getCityID()){
            let presentationModel = SCServicesPresentationModel.fromModel(serviceModel, userContentWorker: self.userContentSharedWorker)
            
            for component in presentationModel.allServices {
            
                if component.itemFunction?.lowercased() == "poi" {
                    basicPOIGuideWorker.getCityPOICategories(cityId: "\(cityContentSharedWorker.getCityID())") { [weak self] (poiCategories, error) in
                        guard let strongSelf = self else { return }
                        if error == nil{
                            SCDataUIEvents.postNotification(for: .didChangePOICategory)
                            strongSelf.updatePOICategory()
                        }
                    }
                }
            }
        }
    }
    
    private func updatePOICategory() {

        let poiCategoryId = userDefaultsHelper.getPOICategoryID()
        let poiCategories = basicPOIGuideWorker.getCityPOICategories() ?? []
        
        for category in poiCategories{
            
            if let obj = category.categoryList.filter({ $0.categoryId == poiCategoryId }).first {
                userDefaultsHelper.setPOICategory(poiCategory: obj.categoryName)
                SCDataUIEvents.postNotification(for: .didUpdatePOICategory)
            }
        }
    }
}
