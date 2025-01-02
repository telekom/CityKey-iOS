//
//  SCEventsOverviewPresenter.swift
//  SmartCity
//
//  Created by Michael on 08.10.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCEventsOverviewDisplaying: AnyObject , SCDisplaying{
    func setupUI()
    func present(viewController: UIViewController)
    func presentOnTop(viewController: UIViewController, completion: (() -> Void)?)
    func push(viewController: UIViewController, completion: (() -> Void)?)
    func showNavigationBar(_ visible : Bool)
    func updateEvents(with dataItems: [SCModelEvent], favItems: [SCModelEvent]?)
    func moreItemsAvailable(_ available : Bool)
    func moreItemsError()
    func showOverlayWithActivityIndicator()
    func showOverlayWithGeneralError()
    func hideOverlay()
    func updateDateFilterName(_ name : String, color : UIColor)
    func updateCategoryFilterName(_ name : String, color : UIColor)
}

protocol SCEventsOverviewPresenting: SCPresenting {
    func setDisplay(_ display: SCEventsOverviewDisplaying)
    
    func didSelectListItem(item: SCModelEvent, isCityChanged: Bool, cityId: Int?)
    func didPressGeneralErrorRetryBtn()
    func didPressLoadMoreItemsRetryBtn()
    func willReachEndOfList()
    
    func didTapOnDateFilter()
    func didTapOnCategoryFilter()
}


struct SCEventsOverviewData {
    var items = [SCModelEvent]()
    var estimatedItemCount: Int = 0
    var currentFilterStartDate: Date?
    var currentFilterEndDate: Date?
    var currentFilterSelectedCategories: [SCModelCategory]?
    
    func currentPage()->Int {
        let cpg = ((items.count - 1 ) / (GlobalConstants.events_fetch_data_page_size))
        return cpg < 0 ? 0 : cpg
    }
    
    func pageCount()->Int {
        let epg = Int((estimatedItemCount - 1) / GlobalConstants.events_fetch_data_page_size) + 1
        return epg
    }
}

struct SCFilterDescription {
    let filtername: String
    let color : UIColor
}

class SCEventsOverviewPresenter {
    weak private var display: SCEventsOverviewDisplaying?
    private var data: SCEventsOverviewData! {
        didSet {
            self.dataCache.storeEventOverviewData(eventOverviewData: self.data, for: self.cityContentSharedWorker.getCityID())
        }
    }
    
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let userCityContentSharedWorker: SCUserCityContentSharedWorking
    private let eventWorker: SCOverviewEventWorking & SCFilterWorking
    private let injector: SCEventOverviewInjecting & SCDisplayEventInjecting & SCAdjustTrackingInjection & SCCategoryFilterInjecting
    
    private let dataCache: SCDataCaching
    private let cityID: Int

    private var pageLoadinginProgress = false
    private var errorWhileLoading = false

    init(initialEventItems: [SCModelEvent], cityContentSharedWorker: SCCityContentSharedWorking, userCityContentSharedWorker: SCUserCityContentSharedWorking, eventWorker: SCOverviewEventWorking & SCFilterWorking, injector: SCEventOverviewInjecting & SCDisplayEventInjecting & SCAdjustTrackingInjection & SCCategoryFilterInjecting, dataCache: SCDataCaching) {
        
        self.cityContentSharedWorker = cityContentSharedWorker
        self.userCityContentSharedWorker = userCityContentSharedWorker
        
        self.eventWorker = eventWorker
        self.injector = injector
        self.dataCache = dataCache
        
        if let cachedEventItems =  self.dataCache.eventsOverviewData(for: self.cityContentSharedWorker.getCityID()) {
            self.data = cachedEventItems
        } else {
            self.data = SCEventsOverviewData()
            self.data.items = initialEventItems
            self.data.estimatedItemCount = initialEventItems.count + 1 // because there are maybe more items than the initial ones. We will later get the real count from the backend
        }

        self.cityID = self.cityContentSharedWorker.getCityID()
        self.loadDataCountWithFilter(startDate: self.data.currentFilterStartDate, endDate: self.data.currentFilterEndDate, categories: self.data.currentFilterSelectedCategories)
        self.loadDataForPage(0, completion: {_ in })
        
        self.setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(favoritesDidChange), name: .didChangeFavoriteEventsDataState, object: nil)
        SCDataUIEvents.registerNotifications(for: self, on: .userDidSignOut, with: #selector(didChangeLoginLogout))
        SCDataUIEvents.registerNotifications(for: self, on: .userDidSignIn, with: #selector(didChangeLoginLogout))
    }
    
    @objc private func didChangeLoginLogout(notification: Notification) {
        self.updateUI()
    }

    @objc private func favoritesDidChange(notification: Notification) {
        self.updateUI()
    }

    
    func dateFilterDescription(startDate: Date?, endDate: Date?) -> SCFilterDescription{
        
        guard let filterStartDay = startDate else {
            return SCFilterDescription(filtername: LocalizationKeys.SCEventsOverviewPresenter.e002FilterEmptyLabel.localized(), color: UIColor(named: "CLR_LABEL_TEXT_GRAY_DARKGRAY")!)
        }
        
        let filterEndDay = endDate == nil ? filterStartDay : endDate!
            
        let firstDayformatter = DateFormatter()
        let secondDayformatter = DateFormatter()

        firstDayformatter.dateFormat = "dd.MMM - "
        secondDayformatter.dateFormat = "dd.MMM"
            
        return SCFilterDescription(filtername: firstDayformatter.string(from: filterStartDay) + secondDayformatter.string(from:filterEndDay), color: kColor_cityColor)
    }

    private func updateDateFilterLabel() {
        let filter = self.dateFilterDescription(startDate: self.data.currentFilterStartDate, endDate: self.data.currentFilterEndDate)

        self.display?.updateDateFilterName(filter.filtername, color: filter.color)
    }
    
    func categoryFilterDescription(categories : [SCModelCategory]?) -> SCFilterDescription{
        
        guard let filterCategories = categories else {
            return SCFilterDescription(filtername: LocalizationKeys.SCEventsOverviewPresenter.e002FilterEmptyLabel.localized(), color: UIColor(named: "CLR_LABEL_TEXT_GRAY_DARKGRAY")!)
        }
        
        if filterCategories.count == 0 {
            return SCFilterDescription(filtername: LocalizationKeys.SCEventsOverviewPresenter.e002FilterEmptyLabel.localized(), color: UIColor(named: "CLR_LABEL_TEXT_GRAY_DARKGRAY")!)
        }
        
        var labelString: String = ""
        for category in filterCategories {
            if labelString.count > 0 {
                labelString += ","
            }
            labelString.append(category.categoryName)
        }

        return SCFilterDescription(filtername: labelString, color: kColor_cityColor)
    }

    private func updateCategoryFilterLabel() {
        let filter = self.categoryFilterDescription(categories: self.data.currentFilterSelectedCategories)
        self.display?.updateCategoryFilterName(filter.filtername, color: filter.color)
    }
    
    private func updateUI() {
        updateDateFilterLabel()
        updateCategoryFilterLabel()

        if self.pageLoadinginProgress && self.data.items.count == 0{
            self.display?.showOverlayWithActivityIndicator()
        } else if self.data.items.count  == 0 && self.errorWhileLoading {
            self.display?.showOverlayWithGeneralError()
        } else {
            self.display?.hideOverlay()
            
            let favItems = self.userCityContentSharedWorker.getUserCityContentData()?.favorites
            self.display?.updateEvents(with: self.data.items, favItems: favItems)
            if self.errorWhileLoading {
                self.display?.moreItemsError()
            } else {
                self.display?.moreItemsAvailable(self.data.currentPage() < (self.data.pageCount() - 1))
            }
        }

    }

    private func loadFirstPage(){
        self.loadDataForPage(0, completion: {_ in })
    }

    private func loadNextPage(){
        let nextPage = self.data.currentPage() + 1
        
        if nextPage < self.data.pageCount() {
            self.loadDataForPage(nextPage, completion: {_ in })
        }
    }
    
    private func loadDataForPage(_ page : Int, completion: @escaping (_ success: Bool) ->()){
        
        if self.pageLoadinginProgress {
            return
        }
        
        self.pageLoadinginProgress = true
        self.errorWhileLoading = false

        self.eventWorker.fetchEventListforOverview(cityID: self.cityID, eventId: "0", page: page, pageSize: GlobalConstants.events_fetch_data_page_size, startDate: self.data.currentFilterStartDate, endDate: self.data.currentFilterEndDate, categories: self.data.currentFilterSelectedCategories, completion: { (error, eventList) -> ()? in
            
            guard error == nil else {
                
                if  case .noInternet = error! {
                    self.display?.showErrorDialog(SCWorkerError.noInternet, retryHandler: {self.loadFirstPage()}, showCancelButton: true, additionalButtonTitle: nil, additionButtonHandler: nil)
                }
                
                self.errorWhileLoading = true
                self.pageLoadinginProgress = false
                self.updateUI()
                completion(false)

                return nil
            }
            
            if let eventList = eventList {
                if page == 0 {
                    self.data.items = [SCModelEvent]()
                }
                
                self.data.items.append(contentsOf: eventList.eventList)
            }
            self.pageLoadinginProgress = false
            self.updateUI()
            SCUtilities.delay(withTime: 0.0, callback: {
                completion(true)
            })
            return nil
        })
    }
    
    private func loadDataCountWithFilter(startDate : Date?, endDate : Date?, categories: [SCModelCategory]?){
        
        self.eventWorker.fetchEventListCount(cityID: self.cityID,eventId: "0", startDate: startDate, endDate: endDate, categories: categories, completion: { (error, itemCount) -> ()? in
            
            guard error == nil else {
                // SMARTC-21163 : iOS: unexpected alert displayed when we visit to the dates filter for events
                // Commented below line to hide alert on error to fix this issue
//                self.display?.showErrorDialog(error!, retryHandler: {self.loadDataCountWithFilter(startDate: startDate, endDate: endDate, categories: categories)})
                return nil
            }
            self.data.estimatedItemCount = itemCount
            self.updateUI()
            return nil
        })
    }


}

extension SCEventsOverviewPresenter: SCPresenting {
    func viewDidLoad() {
        self.display?.setupUI()
        self.updateUI()
    }
    
    func viewWillAppear() {
        self.updateUI()
    }
    
    func viewDidAppear() {
    }
}

extension SCEventsOverviewPresenter: SCEventsOverviewPresenting {
    
    
    func willReachEndOfList() {
        if !self.errorWhileLoading {
            self.loadNextPage()
        }
    }
    
    func didPressLoadMoreItemsRetryBtn(){
        self.display?.moreItemsAvailable(true)
        self.loadNextPage()
    }
    
    func setDisplay(_ display: SCEventsOverviewDisplaying) {
        self.display = display
    }
    
    func didSelectListItem(item: SCModelEvent, isCityChanged: Bool, cityId: Int?) {
        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.openEventDetailPage)
        let viewController = self.injector.getEventDetailController(with: item, isCityChanged: isCityChanged, cityId: cityId)
        self.display?.push(viewController: viewController, completion: nil)
    }
    
    func didTapOnDateFilter(){
        //self.injector.trackEvent(eventName: "ClickEventDateFilterBtn")
        let picker = self.injector.getDatePickerController(preSelectedStartDate: self.data.currentFilterStartDate, preSelectedEndDate: self.data.currentFilterEndDate, delegate: self)
        self.display?.present(viewController: picker)
    }
    
    func didTapOnCategoryFilter(){
        //self.injector.trackEvent(eventName: "ClickEventCategoryFilterBtn")
        if let navigationController = self.injector.getCategoryFilterViewController(
            screenTitle: LocalizationKeys.SCEventsOverviewPresenter.e004EventsFilterCategoriesTitle.localized(),
            selectBtnText: LocalizationKeys.SCEventsOverviewPresenter.e004EventsFilterCategoriesShowEvents.localized(),
            selectAllButtonHidden: true,
            filterWorker: self.eventWorker,
            preselectedCategories: self.data.currentFilterSelectedCategories,
            delegate: self) as? UINavigationController {
            if let selectionVC = navigationController.topViewController as? SCSelectionViewController {
                selectionVC.sourceFlow = .EventsFilter
            }
            self.display?.present(viewController: navigationController)
        }
    }
    
    func didPressGeneralErrorRetryBtn() {
        self.data.items = [SCModelEvent]()
        self.loadFirstPage()
        self.updateUI()
    }

}

extension SCEventsOverviewPresenter: SCDatePickerDelegate {
    func datePickerNeedsResultCount(startDay: Date?, endDay: Date?, completion: @escaping (Int) -> ()) {
        let listEndDate = endDay == nil ? startDay : endDay
        
        self.eventWorker.fetchEventListCount(cityID: self.cityContentSharedWorker.getCityID(),
                                             eventId: "0", startDate: startDay, endDate: listEndDate, categories: self.data.currentFilterSelectedCategories, completion: { (error, itemCount) -> ()? in
            
            guard error == nil else {
                completion(-1)
                return nil
            }
            completion(itemCount)
            return nil
        })
    }
    
    func datePickerDidFinish(startDay: Date?, endDay: Date?, filterCount: Int, completion: @escaping (_ success: Bool) ->()) {
        self.data.currentFilterStartDate = startDay
        let listEndDate = endDay == nil ? startDay : endDay
        self.data.currentFilterEndDate = listEndDate
        self.data.estimatedItemCount = filterCount
        self.data.items = [SCModelEvent]()
        self.loadDataForPage(0, completion: { (success) in
            completion(success)
        })
        
        self.updateUI()
    }
    
    
}

extension SCEventsOverviewPresenter: SCCategorySelectionDelegate {
    func categorySelectorNeedsResultCount(categories: [SCModelCategory], completion: @escaping (Int) -> ()) {
        self.eventWorker.fetchEventListCount(cityID: self.cityContentSharedWorker.getCityID(), eventId: "0", startDate: self.data.currentFilterStartDate, endDate: self.data.currentFilterEndDate, categories: categories) { (workerError, count) -> ()? in
            if workerError != nil {
                completion(-1)
            } else {
                completion(count)
            }
            return nil
        }
    }
    
    func categorySelectorDidFinish(categories: [SCModelCategory], filterCount: Int, completion: @escaping (_ success: Bool) ->()) {
        self.data.currentFilterSelectedCategories = categories
        self.data.estimatedItemCount = filterCount
        self.data.items = [SCModelEvent]()

        self.loadDataForPage(0, completion: { (success) in
            completion(success)
        })
        
        self.updateUI()
    }
    
    
}
