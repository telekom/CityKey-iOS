//
//  SCWasteCategorySelectionPresenter.swift
//  SmartCity
//
//  Created by Harshada Deshmukh on 18/05/22.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

protocol SCWasteCategorySelectionPresenting: SCPresenting {
    func setDisplay(display: SCWasteSelectionDisplaying)
    func startPresenting(withPreselectedCategories: [SCModelCategoryObj]?)
    func filterButtonWasPressed(filterCategories: [SCModelCategoryObj], expectedItemCount: Int)
    func filterCategoriesChanged(filterCategories: [SCModelCategoryObj])
    func storeWasteTypeID(categories: [SCModelCategoryObj])
    func getCityName() -> String
}

protocol SCWasteCategorySelectionDelegate: AnyObject {
    
    func saveWasteTypeID(_ categories: [SCModelCategoryObj], completion: @escaping (Bool?, SCWorkerError?) -> ()?)

    func categorySelectorNeedsResultCount(categories: [SCModelCategoryObj], completion: @escaping (_ count: Int) -> ())
    
    func categorySelectorDidFinish(categories: [SCModelCategoryObj], filterCount: Int, completion: @escaping (_ success: Bool) ->())
}

class SCWasteCategorySelectionPresenter {
    var worker: SCWasteFilterWorking
    var cityContentSharedWorker: SCCityContentSharedWorking
    var injector: SCEventOverviewInjecting & SCAdjustTrackingInjection
    var display: SCWasteSelectionDisplaying
    var selectionDelegate: SCWasteCategorySelectionDelegate
    var preselectedCategories: [SCModelCategoryObj]?
    var expectedItemCount: Int?
    var screenTitle: String
    var selectBtnText: String
    var selectAllButtonHidden: Bool
    private var widgetUtility: WidgetUtility

    init (display: UINavigationController,
          screenTitle: String,
          selectBtnText: String,
          selectAllButtonHidden: Bool,
          worker: SCWasteFilterWorking,
          sharedContentWorker: SCCityContentSharedWorker,
          delegate: SCWasteCategorySelectionDelegate,
          injector: SCEventOverviewInjecting & SCAdjustTrackingInjection,
          widgetUtility: WidgetUtility = WidgetUtility()) {
        self.worker = worker
        self.cityContentSharedWorker = sharedContentWorker
        self.selectionDelegate = delegate
        self.injector = injector
        self.display = display.topViewController as! SCWasteSelectionDisplaying
        self.screenTitle = screenTitle
        self.selectBtnText = selectBtnText
        self.selectAllButtonHidden = selectAllButtonHidden
        self.widgetUtility = widgetUtility
    }
}

extension SCWasteCategorySelectionPresenter: SCWasteCategorySelectionPresenting {
    

    func startPresenting(withPreselectedCategories: [SCModelCategoryObj]?) {
        let cityID = self.cityContentSharedWorker.getCityID()
        display.startActivityIndicator()
        self.worker.fetchCategoryList(cityID: cityID) { (workerError, categoryList) -> ()? in
            self.display.stopActivityIndicator()
            if let categoryList = categoryList {
                self.display.updateCategories(categories: categoryList, preselectedItems: withPreselectedCategories)
            } else if let workerError = workerError {
                self.display.showErrorDialog(workerError, retryHandler: nil, showCancelButton: true, additionalButtonTitle: nil, additionButtonHandler: nil)
            }
            return nil
        }
    }
    
    
    func filterButtonWasPressed(filterCategories: [SCModelCategoryObj], expectedItemCount: Int) {
        // Saving the filter used for waste calendar
        selectionDelegate.saveWasteTypeID(filterCategories) { (success, error) in
            
            if success != nil {

                self.selectionDelegate.categorySelectorDidFinish(categories: filterCategories, filterCount: self.expectedItemCount ?? 0) { (success) in
                }
                
                SCUtilities.delay(withTime: 0.5, callback: {
                    self.widgetUtility.reloadAllTimeLines()
                    self.display.dismiss(completion: nil)
                })
                
            } else if error != nil {

                SCUtilities.topViewController().showUIAlert(with: LocalizationKeys.SCDisplayingDefaultImplementation.dialogTechnicalErrorMessage.localized(), cancelTitle: LocalizationKeys.SCDefectReporterFormPresenter.dr003DialogButtonOk.localized(), retryTitle: nil, retryHandler: nil, additionalButtonTitle: nil, additionButtonHandler: nil, alertTitle: LocalizationKeys.SCDisplayingDefaultImplementation.dialogTechnicalErrorTitle.localized())
            }
            
            return nil
        }
        
    }
    
    func filterCategoriesChanged(filterCategories: [SCModelCategoryObj]) {
        self.display.clearAllButton(isHidden: !(filterCategories.count > 0))
        self.selectionDelegate.categorySelectorNeedsResultCount(categories: filterCategories) { (count) in
            
            let countString = count >= 0 ?  self.selectBtnText.replacingOccurrences(of: "%d", with: String(count)) : self.selectBtnText.replacingOccurrences(of: "(%d)", with: "")
            self.display.setTitleForShowEventsButton(title: (countString))
            self.expectedItemCount = count
            self.display.setNormalStateToFilterEventsButton()
        }
    }
    
    func storeWasteTypeID(categories: [SCModelCategoryObj]) {
        self.selectionDelegate.saveWasteTypeID(categories) { (success, error) in
            
            SCUtilities.delay(withTime: 0.5, callback: {
                self.display.dismiss(completion: nil)
            })
        }
    }
    
   func setDisplay(display: SCWasteSelectionDisplaying) {
        self.display = display
    }
    
    func getCityName() -> String {
        return cityContentSharedWorker.getCityContentData(for: cityContentSharedWorker.getCityID())?.city.name ?? ""
    }
    
    func viewDidLoad() {
        //self.injector.trackEvent(eventName: "OpenEventsCategoryFilter")
        self.display.setTitleForShowEventsButton(title: self.selectBtnText.replacingOccurrences(of: "%d", with: "0"))
        
        // retriving the saved filter on basis of city

        display.hideUnhideSelectAllButton(isHidden: selectAllButtonHidden)
        self.startPresenting(withPreselectedCategories: preselectedCategories)
        self.display.setupUI(title: self.screenTitle)
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
}
