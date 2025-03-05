/*
Created by Michael on 08.10.19.
Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

class SCEventsOverviewViewController: UIViewController {

    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateViewTopLabel: SCTopAlignLabel!
    @IBOutlet weak var dateViewBottomLabel: UILabel!
    
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryViewBottomLabel: UILabel!
    @IBOutlet weak var categoryViewTopLabel: UILabel!

    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    @IBOutlet weak var imgViewCalendar: UIImageView!
    @IBOutlet weak var imgViewCategories: UIImageView!
    
    @IBOutlet weak var dateCtaegoryViewHeightConstraint: NSLayoutConstraint!

    public var presenter: SCEventsOverviewPresenting!

    internal var tableViewController :  SCEventsOverviewTVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.shouldNavBarTransparent = false
        self.setupAccessibilityIDs()
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        handleDynamicTypeChange()
        self.setupAccessibility()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleDynamicTypeChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }
    
    @objc private func handleDynamicTypeChange() {
        // Dynamic font
        self.navigationItem.title = LocalizationKeys.SCEventsOverviewVC.e002PageTitle.localized()
        self.navigationItem.backButtonTitle = LocalizationKeys.Common.navigationBarBack.localized()

        dateViewTopLabel.adjustsFontForContentSizeCategory = true
        dateViewTopLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 22)
        dateViewBottomLabel.adjustsFontForContentSizeCategory = true
        dateViewBottomLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 22)
        categoryViewTopLabel.adjustsFontForContentSizeCategory = true
        categoryViewTopLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 22)
        categoryViewBottomLabel.adjustsFontForContentSizeCategory = true
        categoryViewBottomLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 22)
        errorLabel.adjustsFontForContentSizeCategory = true
        errorLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 20)
        retryButton.titleLabel?.adjustsFontForContentSizeCategory = true
        retryButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 14, maxSize: 25)
        
        let contentSize = traitCollection.preferredContentSizeCategory
        if contentSize.isAccessibilityCategory {
            
            dateCtaegoryViewHeightConstraint.constant = 100
            dateViewTopLabel.numberOfLines = 0
            categoryViewTopLabel.numberOfLines = 0

        } else {
            dateCtaegoryViewHeightConstraint.constant = 68
            dateViewTopLabel.numberOfLines = 1
            categoryViewTopLabel.numberOfLines = 1
       }
    }
    
    private func refreshImagesForLightDarkMode(){
        if let imageDP = self.imgViewCalendar?.image {self.imgViewCalendar?.image = imageDP.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)
        }

        if let imageImp = self.imgViewCategories?.image {self.imgViewCategories?.image = imageImp.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)
        }

    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                self.refreshImagesForLightDarkMode()
            }
        }
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        
        self.categoryViewBottomLabel.accessibilityIdentifier = "lbl_category_bottom"
        self.categoryViewTopLabel.accessibilityIdentifier = "lbl_category_top"
        self.dateViewTopLabel.accessibilityIdentifier = "lbl_date_top"
        self.dateViewBottomLabel.accessibilityIdentifier = "lbl_date_bottom"
        self.retryButton.accessibilityIdentifier = "btn_retry_error"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    func setupAccessibility() {
        setupDateViewAccessibility()
        setupCategoryViewAccessibility()
    }
    
    private func setupDateViewAccessibility() {
        dateView.isAccessibilityElement = true
        dateView.accessibilityLabel = (dateViewTopLabel.text ?? "") + (dateViewBottomLabel.text ?? "")
        dateView.accessibilityTraits = .button
        dateView.accessibilityHint = "accessibility_event_date_filter_hint".localized()
        dateView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
    
    private func setupCategoryViewAccessibility() {
        categoryView.isAccessibilityElement = true
        categoryView.accessibilityLabel = (categoryViewTopLabel.text ?? "") + (categoryViewBottomLabel.text ?? "")
        categoryView.accessibilityTraits = .button
        categoryView.accessibilityHint = "accessibility_event_category_filter_hint".localized()
        categoryView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshNavigationBarStyle()
        self.presenter.viewWillAppear()
        
    }

    /**
     *
     * Method to get referenced of the embedded viewController
     *
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
      switch segue.destination {
            
        case let tvc as SCEventsOverviewTVC:
            tvc.delegate = self
            self.tableViewController = tvc
            break
        default:
            break
        }
    }

    
    @objc func handleDateTap(_ sender: UITapGestureRecognizer? = nil) {
        self.presenter.didTapOnDateFilter()
    }
    
    @objc func handleCategoryTap(_ sender: UITapGestureRecognizer? = nil) {
        self.presenter.didTapOnCategoryFilter()
    }
    
    @IBAction func retryBtnWasPressed(_ sender: Any) {
        self.presenter.didPressGeneralErrorRetryBtn()
    }
    
}

extension SCEventsOverviewViewController: SCEventsOverviewDisplaying {
    func showNavigationBar(_ visible : Bool) {
        self.navigationController?.isNavigationBarHidden = !visible
    }
    
    func setupUI() {
        self.navigationItem.title = LocalizationKeys.SCEventsOverviewVC.e002PageTitle.localized()
        self.topSeparatorView.backgroundColor = UIColor(named: "CLR_BORDER_SILVERGRAY")!
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: LocalizationKeys.Common.navigationBarBack.localized(), style: .plain, target: nil, action: nil)
        
        self.dateView.layer.cornerRadius = 5.0
        self.dateView.clipsToBounds = true
        self.dateView.layer.borderWidth = 1
        self.dateView.layer.borderColor = UIColor(named: "CLR_BORDER_SILVERGRAY")!.cgColor
        self.dateViewTopLabel.text = LocalizationKeys.SCEventsOverviewVC.e002FilterDateLabel.localized()
        
        let tapOnDate = UITapGestureRecognizer(target: self, action: #selector(self.handleDateTap(_:)))
        self.dateView.addGestureRecognizer(tapOnDate)
        self.dateView.isUserInteractionEnabled = true
        
        self.categoryView.layer.cornerRadius = 5.0
        self.categoryView.clipsToBounds = true
        self.categoryView.layer.borderWidth = 1
        self.categoryView.layer.borderColor = UIColor(named: "CLR_BORDER_SILVERGRAY")!.cgColor
        self.categoryViewTopLabel.text = LocalizationKeys.SCEventsOverviewVC.e002FilterCategoriesLabel.localized()
        
        let tapOnCategory = UITapGestureRecognizer(target: self, action: #selector(self.handleCategoryTap))
        self.categoryView.addGestureRecognizer(tapOnCategory)
        self.categoryView.isUserInteractionEnabled = true
        
        self.overlayView.isHidden = true
        self.tableViewController?.cityColor = kColor_cityColor
        self.tableViewController?.moreItemsAvailable(false)
        
        self.errorLabel.adaptFontSize()
        self.errorLabel.text = LocalizationKeys.SCDashboardPresenter.h001EventsLoadError.localized()
        self.retryButton.setTitle(" " + "e_002_page_load_retry".localized(), for: .normal)
        self.retryButton.setTitleColor(kColor_cityColor, for: .normal)
        self.retryButton.titleLabel?.adaptFontSize()
        self.retryButton.setImage(UIImage(named: "action_resend_email")?.maskWithColor(color: kColor_cityColor), for: .normal)
        
        self.refreshImagesForLightDarkMode()

    }

    
    func present(viewController: UIViewController) {
        self.present(viewController, animated: true)
    }

    func presentOnTop(viewController: UIViewController, completion: (() -> Void)? = nil) {
        SCUtilities.topViewController().present(viewController, animated: true, completion: completion)
    }
    
    func push(viewController: UIViewController, completion: (() -> Void)? = nil) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func updateEvents(with dataItems: [SCModelEvent], favItems: [SCModelEvent]?) {
        self.tableViewController?.updateEvents(with: dataItems, favItems: favItems)
    }

    func moreItemsAvailable(_ available : Bool) {
        self.tableViewController?.moreItemsAvailable(available)
    }

    func moreItemsError() {
        self.tableViewController?.moreItemsError()
    }

    func showOverlayWithActivityIndicator() {
        self.activityIndicator.isHidden = false
        self.overlayView.isHidden = false
        self.errorLabel.isHidden = true
        self.retryButton.isHidden = true
    }

    func showOverlayWithGeneralError() {
        self.activityIndicator.isHidden = true
        self.errorLabel.isHidden = false
        self.retryButton.isHidden = false
        self.overlayView.isHidden = false
    }

    func hideOverlay() {
        self.overlayView.isHidden = true
    }

    func updateDateFilterName(_ name : String, color : UIColor) {
        self.dateViewBottomLabel.text = name
        self.dateViewBottomLabel.textColor = color
        setupDateViewAccessibility()
   }

    func updateCategoryFilterName(_ name : String, color : UIColor) {
        self.categoryViewBottomLabel.text = name
        self.categoryViewBottomLabel.textColor = color
        setupCategoryViewAccessibility()
    }

}


extension SCEventsOverviewViewController: SCEventsOverviewTVCDelegate {
    func didSelectListItem(item: SCModelEvent) {
        self.presenter.didSelectListItem(item: item, isCityChanged: false, cityId: nil)
    }

    func didPressLoadMoreItemsRetryBtn() {
        self.presenter.didPressLoadMoreItemsRetryBtn()
    }

    func willReachEndOfList() {
        self.presenter.willReachEndOfList()
    }
    
    
}


