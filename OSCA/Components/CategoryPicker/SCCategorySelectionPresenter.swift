//
//  SCCategorySelectionPresenter.swift
//  SmartCity
//
//  Created by Alexander Lichius on 11.10.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

protocol SCCategorySelectionPresenting: SCPresenting {
    func setDisplay(display: SCSelectionDisplaying)
    func startPresenting(withPreselectedCategories: [SCModelCategory]?)
    func filterButtonWasPressed(filterCategories: [SCModelCategory], expectedItemCount: Int)
    func filterCategoriesChanged(filterCategories: [SCModelCategory])
    func getCityName() -> String
}

protocol SCCategorySelectionDelegate: AnyObject {
    func categorySelectorNeedsResultCount(categories: [SCModelCategory], completion: @escaping (_ count: Int) -> ())
    
    func categorySelectorDidFinish(categories: [SCModelCategory], filterCount: Int, completion: @escaping (_ success: Bool) ->())
}

class SCCategorySelectionPresenter {
    var worker: SCFilterWorking
    var cityContentSharedWorker: SCCityContentSharedWorking
    var injector: SCEventOverviewInjecting & SCAdjustTrackingInjection
    var display: SCSelectionDisplaying
    var selectionDelegate: SCCategorySelectionDelegate
    var preselectedCategories: [SCModelCategory]?
    var expectedItemCount: Int?
    var screenTitle: String
    var selectBtnText: String
    var selectAllButtonHidden: Bool

    init (display: UINavigationController, screenTitle: String, selectBtnText: String, selectAllButtonHidden: Bool, worker: SCFilterWorking, sharedContentWorker:SCCityContentSharedWorker, delegate: SCCategorySelectionDelegate, injector: SCEventOverviewInjecting & SCAdjustTrackingInjection) {
        self.worker = worker
        self.cityContentSharedWorker = sharedContentWorker
        self.selectionDelegate = delegate
        self.injector = injector
        self.display = display.topViewController as! SCSelectionDisplaying
        self.screenTitle = screenTitle
        self.selectBtnText = selectBtnText
        self.selectAllButtonHidden = selectAllButtonHidden
    }
}

extension SCCategorySelectionPresenter: SCCategorySelectionPresenting {

    func startPresenting(withPreselectedCategories: [SCModelCategory]?) {
        let cityID = self.cityContentSharedWorker.getCityID()
        display.startActivityIndicator()
        self.worker.fetchCategoryList(cityID: cityID) { (workerError, categoryList) -> ()? in
            self.display.stopActivityIndicator()
            if let categoryList = categoryList {
                self.display.updateCategories(categories: categoryList, preselectedItems: withPreselectedCategories)
                if self.display.getSourceFlowType() == .WasteFilter {
                    UserDefaults.standard.set(categoryList.count, forKey: "\(cityID)")
                }
            } else if let workerError = workerError {
                self.display.showErrorDialog(workerError, retryHandler: nil, showCancelButton: true, additionalButtonTitle: nil, additionButtonHandler: nil)
            }
            return nil
        }
    }
    
    func filterButtonWasPressed(filterCategories: [SCModelCategory], expectedItemCount: Int) {
        self.selectionDelegate.categorySelectorDidFinish(categories: filterCategories, filterCount: self.expectedItemCount ?? 0) { (success) in
        }
        
        SCUtilities.delay(withTime: 0.5, callback: {
            self.display.dismiss(completion: nil)
        })
    }
    
    func filterCategoriesChanged(filterCategories: [SCModelCategory]) {
        self.display.clearAllButton(isHidden: !(filterCategories.count > 0))
        self.selectionDelegate.categorySelectorNeedsResultCount(categories: filterCategories) { (count) in
            
            let countString = count >= 0 ?  self.selectBtnText.replacingOccurrences(of: "%d", with: String(count)) : self.selectBtnText.replacingOccurrences(of: "(%d)", with: "")
            self.display.setTitleForShowEventsButton(title: (countString))
            self.expectedItemCount = count
            self.display.setNormalStateToFilterEventsButton()
        }
    }
    
    func setDisplay(display: SCSelectionDisplaying) {
        self.display = display
    }
    
    func getCityName() -> String {
        return cityContentSharedWorker.getCityContentData(for: cityContentSharedWorker.getCityID())?.city.name ?? ""
    }
    
    func viewDidLoad() {
        //self.injector.trackEvent(eventName: "OpenEventsCategoryFilter")
        self.display.setTitleForShowEventsButton(title: self.selectBtnText.replacingOccurrences(of: "%d", with: "0"))
        
        // retriving the saved filter on basis of city
        if self.display.getSourceFlowType() == .WasteFilter {
            if let objects = UserDefaults.standard.value(forKey: getCityName()) as? Data {
                let decoder = JSONDecoder()
                if let objectsDecoded = try? decoder.decode(Array.self, from: objects) as [SCModelCategory] {
                    preselectedCategories = objectsDecoded
                }
            }
        }
        
        display.hideUnhideSelectAllButton(isHidden: selectAllButtonHidden)
        self.startPresenting(withPreselectedCategories: preselectedCategories)
        self.display.setupUI(title: self.screenTitle)
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
}
