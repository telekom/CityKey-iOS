/*
Created by Harshada Deshmukh on 18/05/22.
Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Harshada Deshmukh
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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
