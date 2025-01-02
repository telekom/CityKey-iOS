//
//  SCDashboardPresenter.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 05.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

struct DeeplinkEventDetailModel {
    var eventId: String
    var cityId: Int?
    var isCityChanged: Bool = false
}

struct SCDashboardCityPresentationModel {
    
    let cityName: String
    let dashboardHeaderImageUrl: SCImageURL
    let cityCoatOfArmsImageUrl: SCImageURL
    let dashboardFlags: SCDashboardFlags

    static func fromModel(_ cityContentModel: SCCityContentModel) -> SCDashboardCityPresentationModel {
        return SCDashboardCityPresentationModel(cityName: cityContentModel.city.name,
                                                dashboardHeaderImageUrl: cityContentModel.city.cityImageUrl,
                                                cityCoatOfArmsImageUrl: cityContentModel.city.municipalCoatImageUrl,
                                                dashboardFlags: cityContentModel.cityConfig.toDashboardPresentation())
    }
}


class SCDashboardPresenter {
    weak private var display: SCDashboardDisplaying?

    private let dashboardWorker: SCDashboardWorking
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let userCityContentSharedWorker: SCUserCityContentSharedWorking
    private let userContentSharedWorker: SCUserContentSharedWorking
    private let eventWorker: SCDashboardEventWorking
    private var appContentSharedWorker: SCAppContentSharedWorking

    let injector: SCDashboardInjecting & SCDisplayEventInjecting & SCAdjustTrackingInjection & SCLegalInfoInjecting
    
    var events: [SCModelEvent]?
    var news: [SCModelMessage]?
    private var dashboardFlags: SCDashboardFlags?

    private var favoritedEvents:[SCModelEvent]?
    
    private let refreshHandler : SCSharedWorkerRefreshHandling

    private var validateIfLocationToolTipNeedsToBeDisplayed: Bool
    private let appSharedDefaults: AppSharedDefaults
    private let authProvider: SCLoginAuthProviding
    private var deeplinkEventModel: DeeplinkEventDetailModel?
    private var isInitialDataLoaded: Bool = false
    private var isFavouriteEventLoaded: Bool = false
    private var isCityContentChanged: Bool = false
    private var isHomeEventTracked: Bool = false
    
    init(dashboardWorker: SCDashboardWorking,
         cityContentSharedWorker: SCCityContentSharedWorking,
         userContentSharedWorker: SCUserContentSharedWorking,
         userCityContentSharedWorker: SCUserCityContentSharedWorking,
         dashboardEventWorker: SCDashboardEventWorking,
         appContentSharedWorker: SCAppContentSharedWorking,
         injector: SCDashboardInjecting & SCDisplayEventInjecting & SCAdjustTrackingInjection & SCLegalInfoInjecting,
         refreshHandler : SCSharedWorkerRefreshHandling,
         validateIfLocationToolTipNeedsToBeDisplayed: Bool = true,
         appSharedDefaults: AppSharedDefaults = AppSharedDefaults(),
         authProvider: SCLoginAuthProviding) {
        
        self.cityContentSharedWorker = cityContentSharedWorker
        self.userCityContentSharedWorker = userCityContentSharedWorker
        self.userContentSharedWorker = userContentSharedWorker
        self.appContentSharedWorker = appContentSharedWorker
        self.dashboardWorker = dashboardWorker
        self.eventWorker = dashboardEventWorker
        self.refreshHandler = refreshHandler
        self.injector = injector
        self.validateIfLocationToolTipNeedsToBeDisplayed = validateIfLocationToolTipNeedsToBeDisplayed
        self.appSharedDefaults = appSharedDefaults
        self.authProvider = authProvider
        self.setupNotifications()
    }
    
    deinit {
        SCDataUIEvents.discardNotifications(for: self)
    }
    
    private func setupNotifications() {
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeLocation, with: #selector(didChangeLocation))
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeCityContent, with: #selector(didChangeCityConfig))
        SCDataUIEvents.registerNotifications(for: self, on: .userDidSignOut, with: #selector(didChangeLoginLogout))
        SCDataUIEvents.registerNotifications(for: self, on: .userDidSignIn, with: #selector(didChangeLoginLogout))
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeNewsContentState, with: #selector(didChangeNewsContentState))
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeUserDataState, with: #selector(didChangeEventFavorites))
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeUserDataState, with: #selector(checkForDPNChanged))
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeFavoriteEventsDataState, with: #selector(didChangeEventFavorites))
        SCDataUIEvents.registerNotifications(for: self, on: .isInitialLoadingFinished, with: #selector(didFinishInitialLoading))
        SCDataUIEvents.registerNotifications(for: self, on: .updateEventWorkerFetchState, with: #selector(updateEventFetchStatus))
        SCDataUIEvents.registerNotifications(for: self, on: .didUpdateAppPreviewMode, with: #selector(handleAppPreviewModeChange))
        SCDataUIEvents.registerNotifications(for: self, on: .didShowToolTip, with: #selector(showChangeLocationToolTipIfNeeded))
    }
    
    @objc private func handleAppPreviewModeChange() {
        self.display?.handleAppPreviewBannerView()
    }

    @objc private func updateEventFetchStatus() {
        eventWorker.resetDashboardEventListDataState()
    }

    @objc private func didFinishInitialLoading() {
        isInitialDataLoaded = true
        handleDeeplink()
    }

    @objc private func didChangeNewsContentState() {
        self.refreshUIContent()
    }

    @objc private func didChangeCityConfig() {
        isCityContentChanged = true
        self.refreshUIContent()
        trackOpenHome()
        handleDeeplink()
    }
    
    @objc private func didChangeLoginLogout() {
        self.refreshEventFavoriteSection()
        self.refreshUIContent()
    }
    
    @objc private func didChangeEventFavorites() {
        self.refreshEventFavoriteSection()
        isFavouriteEventLoaded = true
        handleDeeplink()
    }
    
    @objc private func didChangeLocation() {
        self.news = nil
        self.events = nil
        self.eventWorker.resetDashboardEventListDataState()
        self.display?.resetUI()
        self.refreshUIContent()
    }
    
    private func refreshEventFavoriteSection() {
        if (cityContentSharedWorker.getCityContentData(for: self.cityContentSharedWorker.getCityID())) != nil {
            let userCityContentData = self.userCityContentSharedWorker.getUserCityContentData()
            self.favoritedEvents = userCityContentData?.favorites
        } else {
            self.favoritedEvents = nil
        }
        self.updateEvents()
    }
    
    private func refreshUIContent() {
        
        self.updateCityConfig()
        self.updateWeather()
        self.updateNews()
        self.updateEvents()
        self.refreshEventFavoriteSection()

        
        if self.cityContentSharedWorker.newsDataState.dataLoadingState != .fetchingInProgress && self.cityContentSharedWorker.cityContentDataState.dataLoadingState != .fetchingInProgress {
            self.display?.endRefreshing()
        }

    }
    
    private func updateCityConfig() {
        
        if let contentModel = self.cityContentSharedWorker.getCityContentData(for: self.cityContentSharedWorker.getCityID()) {
            let presentation = SCDashboardCityPresentationModel.fromModel(contentModel)
            

            // Set Day or Night picture for home screen as per sunrise & sunset time
            let isSunriseOrSunset = self.cityContentSharedWorker.checkIfDayOrNightTime()
            
            if isSunriseOrSunset != .sunset {
                self.display?.setHeaderImageURL(presentation.dashboardHeaderImageUrl)
            } else {
                self.display?.setHeaderImageURL(contentModel.cityNightPicture)
            }
            
            self.display?.setCoatOfArmsImageURL(presentation.cityCoatOfArmsImageUrl)
            
            display?.setWelcomeText(LocalizationKeys.SCDashboardPresenter.h001HomeTitlePart.localized())
            self.display?.setCityName(presentation.cityName)

            self.display?.customize(color: kColor_cityColor)
            
            self.display?.configureContent()

            self.dashboardFlags = presentation.dashboardFlags
        }
    }
    
    private func updateWeather(){
        let weather = self.cityContentSharedWorker.getWeather(for: self.cityContentSharedWorker.getCityID())
        self.display?.setWeatherInfo(weather)
    }

    private func updateNews() {
        
        let newsState = self.cityContentSharedWorker.newsDataState
        let stickyNewsCount = self.cityContentSharedWorker.getCityContentData(for: self.cityContentSharedWorker.getCityID())?.cityConfig.stickyNewsCount ?? 4
        saveErrorMessageForWidget(newsState: newsState)
        // handle casess when no data were initialized
        if !newsState.dataInitialized{
            
            switch newsState.dataLoadingState {
            case .needsToBefetched:
                self.display?.showNewsActivityInfoOverlay()
            case .fetchingInProgress:
                self.display?.showNewsActivityInfoOverlay()
            case .fetchFailed:
                display?.showNewsErrorInfoOverlay(infoText: LocalizationKeys.SCDashboardPresenter.h001HomeNewsError.localized())
            case .backendActionNotAvailableForCity:
                display?.showNewsErrorInfoOverlay(infoText: LocalizationKeys.SCDashboardPresenter.h001HomeNewsActionError.localized())
            case .fetchedWithSuccess:
                // this combination should not exist...
                display?.showNewsErrorInfoOverlay(infoText: LocalizationKeys.SCDashboardPresenter.h001HomeNewsError.localized())
            }
            
            self.display?.updateNews(with: [])

        } else {
            self.display?.hideNewsInfoOverlay()
            
            if let newsModel = self.cityContentSharedWorker.getNews(for: self.cityContentSharedWorker.getCityID()){
                self.display?.updateNews(with: self.mapMessagesToItems(for: .news, messages: self.stickyNews( messages: newsModel, newsCount: stickyNewsCount)))
                self.news =  self.allNews(messages: newsModel)
                prefetchNewsImages(news: self.news ?? [])
            } else {
                // when data are intitilized then this should also not happen
                display?.showNewsErrorInfoOverlay(infoText: LocalizationKeys.SCDashboardPresenter.h001HomeNewsError.localized())
            }
        }

    }


    private func updateEvents() {

        let loadEvents = {
            self.eventWorker.fetchEventListForDashboard(cityID: self.cityContentSharedWorker.getCityID(), eventId: "0") { (error, eventList) -> ()? in
                
                if error != nil {
                    self.events = []
                } else {
                    if let eventList = eventList {
                        self.events = eventList.eventList
                    }
                }
                self.updateEvents()
                return nil
            }
         }
        
        
        let eventDataState =  self.eventWorker.dashboardEventListDataState

        // handle casess when no data were initialized
        if !eventDataState.dataInitialized{
            
            switch eventDataState.dataLoadingState {
            case .needsToBefetched:
                self.display?.showEventsActivityInfoOverlay()
                // no data avaiable and never been tried to load
                loadEvents()
            case .fetchingInProgress:
                self.display?.showEventsActivityInfoOverlay()
            case .fetchFailed:
                display?.showEventsErrorInfoOverlay(infoText: LocalizationKeys.SCDashboardPresenter.h001EventsLoadError.localized())
            case .backendActionNotAvailableForCity:
                display?.showEventsErrorInfoOverlay(infoText: LocalizationKeys.SCDashboardPresenter.h001EventsLoadActionError.localized())
            case .fetchedWithSuccess:
                // this combination should not exist...
                display?.showEventsErrorInfoOverlay(infoText: LocalizationKeys.SCDashboardPresenter.h001EventsLoadError.localized())
            }

            self.display?.updateEvents(with: [], favorites: [])

        } else {
            self.display?.hideEventsInfoOverlay()
            self.display?.updateEvents(with: self.events, favorites: self.favoritedEvents)
            self.prefetchEventsImages(events: self.events ?? [])
        }
    }
    
    private func allNews(messages : [SCModelMessage]) -> [SCModelMessage] {
       var allNews = [SCModelMessage]();
        
        for message in messages{
            if message.type == .news {
                allNews.append(message)
            }
        }
        return allNews.sorted {
            $0.date > $1.date
        }
        
    }

    private func stickyNews(messages : [SCModelMessage], newsCount : Int) -> [SCModelMessage] {
        var stickyNews = [SCModelMessage]()
        var i = 0
        var finished = false
        let messages = messages.sorted {
            $0.date > $1.date
        }
        
        // add sticky news
        for message in messages where (message.type == .news && message.sticky) {
            if i >= newsCount{
                finished = true
                break
            }
            i += 1
            stickyNews.append(message)
        }
        
        // if there are not enough sticky news then add some other news
        if !finished {
            for message in messages where (message.type == .news && !message.sticky) {
                if i >= newsCount{
                    finished = true
                    break
                }
                i += 1
                stickyNews.append(message)
            }
        }
        
        return stickyNews
    }

    private func mapMessagesToItems(for type: SCModelMessageType, messages: [SCModelMessage]) -> [SCBaseComponentItem]{
        
        var items = [SCBaseComponentItem]()
        var itemCategoryTitle = ""
        var itemCellType = SCBaseComponentItemCellType.not_specified

        let dateFormatter = DateFormatter()
 
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        switch type {
        case .info:
            itemCategoryTitle = LocalizationKeys.SCDashboardVC.h001HomeTitleNews.localized()
            itemCellType = .not_specified
        case .news:
            itemCategoryTitle = LocalizationKeys.SCDashboardVC.h001HomeTitleNews.localized()
            itemCellType = .not_specified
        case .tip:
            itemCategoryTitle = LocalizationKeys.SCDashboardVC.h001HomeTitleTips.localized()
            itemCellType = .carousel_big
        case .offer:
            itemCategoryTitle = LocalizationKeys.SCDashboardVC.h001HomeTitleOffers.localized()
            itemCellType = .carousel_big
        case .discount:
            itemCategoryTitle = LocalizationKeys.SCDashboardVC.h001HomeTitleDiscounts.localized()
            itemCellType = .carousel_small
        case .unknown:
            itemCategoryTitle = ""
            itemCellType = .not_specified
        case .event:
            itemCategoryTitle = "h_001_home_title_events"
            itemCellType = .not_specified
        }
        
        for message in messages {
            var titleText: String = ""
            if type == .news || type == .event {
                titleText = stringFromDate(date: message.date)//dateFormatter.string(from: message.date) // get the date from appropriate helper
            } else {
                titleText = message.title
            }
            //let titleText = type == .news ? dateFormatter.string(from: message.date) : message.title
            
            if (message.type == type){
                items.append(SCBaseComponentItem(itemID: message.id, itemTitle: titleText, itemTeaser: message.shortText, itemSubtitle: message.subtitleText, itemImageURL: message.imageURL,itemImageCredit: message.imageCredit, itemThumbnailURL: message.thumbnailURL, itemIconURL: message.imageURL, itemURL: message.contentURL, itemDetail: message.detailText, itemHtmlDetail: false, itemCategoryTitle: itemCategoryTitle, itemColor : kColor_cityColor, itemCellType: itemCellType, itemLockedDueAuth: false, itemLockedDueResidence:false, itemIsNew: false, itemFunction : nil, itemContext:.none))
            }
        }
        
        return items
    }
    
    @objc private func showChangeLocationToolTipIfNeeded() {
        SCUtilities.delay(withTime: 2.0, callback:{
            if (self.validateIfLocationToolTipNeedsToBeDisplayed &&
                !self.appContentSharedWorker.isToolTipShown &&
                self.appContentSharedWorker.switchLocationToolTipShouldBeShown &&
                self.cityContentSharedWorker.getCities()?.count ?? 0 > 1) {
                self.validateIfLocationToolTipNeedsToBeDisplayed = false
                self.appContentSharedWorker.isToolTipShown = true
                self.display?.showChangeLocationToolTip()
            }
        })
    }
}

extension SCDashboardPresenter: SCPresenting {
    
    func viewDidLoad() {
        self.refreshUIContent()

    }
    
    func viewWillAppear() {}
    
    func viewDidAppear() {}
    
    @objc func checkForDPNChanged() {
        
        if userContentSharedWorker.userDataState.dataLoadingState != .fetchedWithSuccess { return }
        guard self.userContentSharedWorker.getUserData()?.profile.dpnAccepted == true else {
            
            // added a little delay so that the initial setup is done
            if !(SCUtilities.topViewController(ignoreAlertController: true) is SCForceUpdateVersionViewController) {
                Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { timer  in
                    let viewController = self.injector.getDataPrivacyNoticeController(insideNavCtrl: true)
                    self.display?.presentDPNViewController(viewController: viewController)
                }
            }
            return
        }
    }
}


extension SCDashboardPresenter: SCDashboardPresenting {

    func setDisplay(_ display: SCDashboardDisplaying) {
        self.display = display
    }
    
    func getDashboardFlags() -> SCDashboardFlags {
        return self.dashboardFlags ?? SCDashboardFlags.showNone()
    }

    func didSelectCarouselItem(item: SCBaseComponentItem) {
        self.validateIfLocationToolTipNeedsToBeDisplayed = false
        self.display?.hideChangeLocationToolTip()
        
        self.showContent(displayContentType: .news, navTitle: item.itemCategoryTitle ?? "", title: item.itemTitle, teaser: item.itemTeaser ?? "", subtitle: item.itemSubtitle ?? "", details: item.itemDetail ?? "", imageURL: item.itemImageURL, photoCredit : item.itemImageCredit, topBtnTitle: nil, bottomBtnTitle: nil, contentURL:item.itemURL, tintColor : item.itemColor)
    }
    
    func didSelectListItem(item: SCBaseComponentItem) {
        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.openNewsDetailPage)
        self.validateIfLocationToolTipNeedsToBeDisplayed = false
        self.display?.hideChangeLocationToolTip()
        self.showContent(displayContentType: .news, navTitle: item.itemCategoryTitle ?? "", title: item.itemTitle, teaser: item.itemTeaser ?? "", subtitle: item.itemSubtitle ?? "", details: item.itemDetail ?? "", imageURL: item.itemImageURL, photoCredit : item.itemImageCredit, topBtnTitle: nil, bottomBtnTitle: nil, contentURL:item.itemURL, tintColor : item.itemColor)
    }
    
    func didSelectListEventItem(item: SCModelEvent, isCityChanged: Bool, cityId: Int?) {
        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.openEventDetailPage)
        self.validateIfLocationToolTipNeedsToBeDisplayed = false
        self.display?.hideChangeLocationToolTip()
        if item != nil {
            self.display?.push(viewController: self.injector.getEventDetailController(with: item, isCityChanged: isCityChanged, cityId: cityId))
        }

    }

    private func shouldProceedToEventDetail() -> Bool {
        if !authProvider.isUserLoggedIn() {
            return true
        } else {
            return isInitialDataLoaded && isFavouriteEventLoaded && isCityContentChanged
        }
    }

    func handleDeeplink() {
        guard shouldProceedToEventDetail() else {
            return
        }
        guard let model = deeplinkEventModel, let cityId = model.cityId else {
            return
        }
        deeplinkEventModel = nil // clearing deeplink data
        isCityContentChanged = false
        cityContentSharedWorker.triggerCityContentUpdate(for: cityId) { [weak self] error in
            guard error == nil, let strongSelf = self else {
                return
            }
            strongSelf.refreshHandler.reloadContent(force: true)
            strongSelf.routeToEventDetailWith(eventId: model.eventId,
                                              cityId: model.cityId,
                                              isCityChanged: model.isCityChanged)
            
        }
        
    }
    func fetchEventDetail(eventId: String, cityId: Int?, isCityChanged: Bool) {
        isCityContentChanged = false
        if isCityChanged,
           let cityId = cityId {
            if cityContentSharedWorker.cityContentDataState.dataLoadingState == .fetchingInProgress {
                deeplinkEventModel = DeeplinkEventDetailModel(eventId: eventId, cityId: cityId, isCityChanged: isCityChanged)
            } else {
                cityContentSharedWorker.triggerCityContentUpdate(for: cityId) { [weak self] error in
                    guard error == nil, let strongSelf = self else {
                        return
                    }
                    strongSelf.refreshHandler.reloadContent(force: true)
                    DispatchQueue.main.async {
                        if strongSelf.isInitialDataLoaded && strongSelf.isCityContentChanged {
                            strongSelf.routeToEventDetailWith(eventId: eventId, cityId: cityId, isCityChanged: isCityChanged)
                        } else {
                            strongSelf.deeplinkEventModel = DeeplinkEventDetailModel(eventId: eventId, cityId: cityId, isCityChanged: isCityChanged)
                        }
                    }
                }
            }
        } else {
            routeToEventDetailWith(eventId: eventId, cityId: cityId, isCityChanged: isCityChanged)
        }
    }
    
    private func routeToEventDetailWith(eventId: String, cityId: Int?, isCityChanged: Bool) {
        guard let cityId = cityId else { return }
        self.eventWorker.fetchEventForDetail(cityID: cityId, eventId: eventId) { (error, eventList) in
            var item: [SCModelEvent]?
            if error != nil {
                item = []
            } else {
                if let eventList = eventList {
                    item = eventList.eventList
                    if let event = item?.first {
                        self.didSelectListEventItem(item: event, isCityChanged: isCityChanged, cityId: cityId)
                    }
                    
                }
            }
            return nil
        }
    }

    func didPressMoreNewsBtn() {
        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.openNewsList)
        self.validateIfLocationToolTipNeedsToBeDisplayed = false
        self.display?.hideChangeLocationToolTip()
        if let news = self.news {
            let newsViewController = self.injector.getNewsOverviewController(with: self.mapMessagesToItems(for: .news, messages: news))
            
            self.display?.push(viewController: newsViewController)
        }
        
    }
    
    func didPressMoreEventsBtn() {
        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.openEventsList)
        self.validateIfLocationToolTipNeedsToBeDisplayed = false
        self.display?.hideChangeLocationToolTip()
        if let events = self.events {
            let eventsViewController = self.injector.getEventsOverviewController(with: SCModelEventList(eventList: events))
            eventsViewController.shouldHideNavBarShadowOnPushPop = true
            self.display?.push(viewController: eventsViewController)
        }

    }

    func prefetchNewsImages(news: [SCModelMessage]) {
        let urls = news.compactMap {
            $0.thumbnailURL?.absoluteUrl()
        }

        PrefetchNetworkImages.prefetchImagesFromNetwork(with: urls)
    }

    func prefetchEventsImages(events: [SCModelEvent]) {
        let urls = events.compactMap {
            $0.thumbnailURL?.absoluteUrl()
        }

        PrefetchNetworkImages.prefetchImagesFromNetwork(with: urls)
    }
    
    func locationButtonWasPressed() {
        self.appContentSharedWorker.switchLocationToolTipShouldBeShown = false
        self.display?.hideChangeLocationToolTip()
        //self.injector.trackEvent(eventName: "ClickQuestionmarkBtn")
        self.injector.showLocationSelector()
    }
     
    func profileButtonWasPressed() {
        self.display?.hideChangeLocationToolTip()
        self.injector.showProfile()
    }
    
    func needsToReloadData() {
        self.display?.hideChangeLocationToolTip()
        self.refreshHandler.reloadContent(force: true)
        self.refreshUIContent()
    }
    
    private func showContent(displayContentType : SCDisplayContentType,
                             navTitle : String,
                             title : String,
                             teaser : String,
                             subtitle : String,
                             details : String?,
                             imageURL : SCImageURL?,
                             photoCredit : String?,
                             topBtnTitle : String?,
                             bottomBtnTitle : String?,
                             contentURL : URL?,
                             tintColor : UIColor?,
                             serviceFunction :  String? = nil,
                             lockedDueAuth : Bool? = false,
                             lockedDueResidence : Bool? = false,
                             btnActions: [SCComponentDetailBtnAction]? = nil) {
        
        self.display?.hideChangeLocationToolTip()
        let contentViewController = SCDisplayContent.getMessageDetailController(displayContentType : displayContentType,
                                                                            navTitle : navTitle,
                                                                            title : title,
                                                                            teaser : teaser,
                                                                            subtitle: subtitle,
                                                                            details : details,
                                                                            imageURL : imageURL,
                                                                            photoCredit : photoCredit,
                                                                            contentURL : contentURL,
                                                                            tintColor : tintColor,
                                                                            lockedDueAuth : lockedDueAuth,
                                                                            lockedDueResidence : lockedDueResidence,
                                                                            btnActions: btnActions ,
                                                                                injector: self.injector as! (SCInjecting & SCAdjustTrackingInjection & SCWebContentInjecting),
                                                                            beforeDismissCompletion: { SCUtilities.delay(withTime: 0.1, callback: {self.display?.showNavigationBar(true)})})
        
        
        
        self.display?.push(viewController: contentViewController)
    }

    private func saveErrorMessageForWidget(newsState: SCWorkerDataState) {
        if #available(iOS 14, *) {
            var errorMessage: String?
            if !newsState.dataInitialized {
                switch newsState.dataLoadingState {
                case .fetchFailed:
                    errorMessage = LocalizationKeys.SCDashboardPresenter.h001HomeNewsError.localized()
                case .backendActionNotAvailableForCity:
                    errorMessage = LocalizationKeys.SCDashboardPresenter.h001HomeNewsActionError.localized()
                case .fetchedWithSuccess:
                    // this combination should not exist...
                    errorMessage = LocalizationKeys.SCDashboardPresenter.h001HomeNewsError.localized()
                default:
                    break
                }
            }
            appSharedDefaults.saveNewsError(message: errorMessage)
        }
    }
    
    func trackOpenHome() {
        if !isHomeEventTracked && isInitialDataLoaded {
            self.injector.trackEvent(eventName: AnalyticsKeys.EventName.openHome)
            isHomeEventTracked = true
        }
    }
}

