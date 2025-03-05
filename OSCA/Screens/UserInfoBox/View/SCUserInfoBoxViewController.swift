/*
Created by Michael on 15.03.19.
Copyright © 2019 Michael. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2019 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

class SCUserInfoBoxViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var barBtnGeoLocation: UIBarButtonItem!
    @IBOutlet weak var barBtnProfile: UIBarButtonItem!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var appPreviewBannerView: UIView!
    @IBOutlet weak var appPreviewBannerLabel: UILabel!

    public var presenter: SCUserInfoBoxPresenting!
    

    private var infoBoxTableVC : SCUserInfoBoxTableViewController!

    var firstTimeViewController : SCFirstTimeUsageVC?
    var isVisible: Bool {
        return isViewLoaded && view.window != nil
    }
    private var navigationTitle : String?
    private var footerViewController: FooterViewDelegate!
    private var footerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        self.shouldNavBarTransparent = true
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        registerForNotifications()
    }
    
    private func registerForNotifications() {
        SCDataUIEvents.registerNotifications(for: self, on: UIContentSizeCategory.didChangeNotification, with: #selector(handleDynamicType))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshNavigationBarStyle()
        UIAccessibility.delayAndSetFocusTo(barBtnGeoLocation)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleAppPreviewBannerView()
        self.presenter.viewDidAppear()
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [weak self] context in
            self?.layoutConstraintOnOrientation()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if self.shouldNavBarTransparent || self.firstTimeViewController != nil{
            return .lightContent
        }
        
        if #available(iOS 13.0, *) {
            switch traitCollection.userInterfaceStyle {
                case .light, .unspecified:
                    return .darkContent
                case .dark:
                    return .lightContent
            @unknown default:
               return .darkContent
           }
        } else {
            return .default
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
            
        case let infoBoxTableVC as SCUserInfoBoxTableViewController:
            self.infoBoxTableVC = infoBoxTableVC
            self.infoBoxTableVC.delegate = self
            
        default:
            break
        }
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.barBtnGeoLocation.accessibilityIdentifier = "btn_location"
        self.barBtnProfile.accessibilityIdentifier = "btn_profile"
        self.segmentedControl.accessibilityIdentifier = "segmetedControl"
        
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }

    private func setupAccessibility(){
        self.barBtnGeoLocation.accessibilityTraits = .button
        self.barBtnGeoLocation.accessibilityLabel = "accessibility_btn_select_location".localized()
        self.barBtnGeoLocation.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.barBtnProfile.accessibilityTraits = .button
        self.barBtnProfile.accessibilityLabel = "accessibility_btn_open_profile".localized()
        self.barBtnProfile.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }

    /**
     *
     * Action for the Profile Notifications button
     *
     */
    @IBAction func barBtnProfilenWasPressed(_ sender: Any) {
        self.presenter.profileButtonWasPressed()
    }
    
    @IBAction func barBtnGeoLocationWasPressed(_ sender: Any) {
        self.presenter.locationButtonWasPressed()
    }
    
    /**
     *
     * Action for the Segmented Control
     *
     */

    @IBAction func segmentedControlWasPressed(_ sender: Any) {
        self.presenter.segmentedControlWasPressed(index : self.segmentedControl.selectedSegmentIndex)
    }
    
    /**
     *
     * Action for the Retry Button
     *
     */
    @IBAction func errorRetryBtnWasPressed(_ sender: Any) {
        self.presenter.needsToReloadData()
    }
    
    private func layoutConstraintOnOrientation() {
        if UIDevice.current.orientation.isLandscape {
            firstTimeViewController?.loginCenterXConstraint.constant = 60
            firstTimeViewController?.registerCenterXConstraint.constant = 60
        } else {
            firstTimeViewController?.loginCenterXConstraint.constant = 0
            firstTimeViewController?.registerCenterXConstraint.constant = 0
        }
    }
    
    private func setupSegmentedControlUI() {
        let firstTitle = "b_001_infobox_btn_filter_unread".localized()
        segmentedControl.setTitle(firstTitle, forSegmentAt: 0)

        let secondTitle = "b_001_infobox_btn_filter_all".localized()
        segmentedControl.setTitle(secondTitle, forSegmentAt: 1)
        segmentedControl.backgroundColor = UIColor.clear
        segmentedControl.layer.borderColor = UIColor(named: "CLR_BORDER_SILVERGRAY")!.cgColor
        segmentedControl.selectedSegmentTintColor = kColor_cityColor
        segmentedControl.layer.borderWidth = 1
        segmentedControl.layer.cornerRadius = 1

        let font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 12, maxSize: 18)
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "CLR_LABEL_TEXT_BLACK")!,
                                   NSAttributedString.Key.font: font]
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for:.normal)

        let titleTextAttributes1 = [NSAttributedString.Key.foregroundColor: UIColor(named: "CLR_LABEL_TEXT_WHITE")!,
                                    NSAttributedString.Key.font: font]
        segmentedControl.setTitleTextAttributes(titleTextAttributes1, for:.selected)

        let widthOfFirstTitle = firstTitle.size(withAttributes: titleTextAttributes).width
        let widthOfSecondTitle = firstTitle.size(withAttributes: titleTextAttributes).width

        let segmentWidth = widthOfFirstTitle < widthOfSecondTitle ? widthOfSecondTitle : widthOfFirstTitle
        segmentedControl.setWidth(segmentWidth + 52, forSegmentAt: 0)
        segmentedControl.setWidth(segmentWidth + 52, forSegmentAt: 1)
    }
    
    @objc private func handleDynamicType() {
        setupSegmentedControlUI()
    }
}

extension SCUserInfoBoxViewController: SCUserInfoBoxDisplaying {
    
    func setFooterViewController(controller: FooterViewDelegate) {
        self.footerViewController = controller
        self.footerView = controller.getView()
    }
    
    var userInfoBoxPresenter: SCUserInfoBoxPresenting {
        get {
            return self.presenter
        }
        set {
            self.presenter = newValue
        }
    }

    func setupUI(title: String){
        self.infoBoxTableVC.setupUI()
        self.navigationItem.title = title
        self.navigationTitle = title
        self.topSeparatorView.backgroundColor = UIColor(named: "CLR_SEPARATOR")!
        setupSegmentedControlUI()
    }

    func updateUI(items: [SCUserInfoBoxMessageItem]) {
        if #available(iOS 13.0, *) {
            segmentedControl.selectedSegmentTintColor = kColor_cityColor
        } else {
            segmentedControl.tintColor = kColor_cityColor
        }
        self.infoBoxTableVC.reloadData(items: items)
    }
    
    func updateOverlay(state: SCInfoBoxOverlayState) {
        self.footerViewController.updateOverlay(state: state)
    }
    
    func showEmptyView() {
        
    }
    
    func refreshNavBar(){
        if self.isFirstTimeUsageVisible() {
            self.shouldNavBarTransparent = true
            self.refreshNavigationBarStyle()
            self.showNavigationBar(false)
        } else {
            self.showNavigationBar(true)
            self.shouldNavBarTransparent = false
            self.refreshNavigationBarStyle()
        }
    }
    
    func isFirstTimeUsageVisible() -> Bool{
        return self.firstTimeViewController != nil
    }
    
    func addFirstTimeUsage() {
        
        if self.firstTimeViewController == nil {
            
            self.navigationItem.title = nil
            
            // Add first time viewcontroller
            self.firstTimeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SCFirstTimeUsageVC") as? SCFirstTimeUsageVC
            self.firstTimeViewController?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            self.firstTimeViewController?.view.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height)
                        
            self.firstTimeViewController?.addScreen(with: "FTU-screen4", description: "x_003_welcome_info".localized(), header: "x_003_welcome_info_title".localized(), screenNo: 4)
           
            self.firstTimeViewController?.setUpControlsVisibility(false, isPageControlAvailable: false)
            self.firstTimeViewController?.navigationController?.interactivePopGestureRecognizer?.isEnabled = false

            self.firstTimeViewController?.delegate = self
            self.view.autoresizesSubviews = true
            
            self.firstTimeViewController?.view.accessibilityViewIsModal = true
            self.view.addSubview((self.firstTimeViewController?.view)!)
            
            // disable some element when ftu screen is shown
            self.segmentedControl.accessibilityElementsHidden = true
            self.infoBoxTableVC.accessibilityElementsHidden = true


        }
        
        SCUtilities.delay(withTime: 0.0, callback:{
            self.refreshNavBar()
        })
    }
    
    func removeFirstTimeUsage() {
        
        self.navigationItem.title = self.navigationTitle
        
        // remove first time viewcontroller
        if self.firstTimeViewController != nil {
            self.firstTimeViewController!.delegate = nil
            self.firstTimeViewController!.view.removeFromSuperview()
            self.firstTimeViewController = nil
        }
        SCUtilities.delay(withTime: 0.0, callback:{
            self.refreshNavBar()
        })
    }
    
    func endRefreshing() {
        self.infoBoxTableVC.endRefreshing()
    }
    
    func showNavigationBar(_ visible : Bool) {
        self.navigationController?.isNavigationBarHidden = !visible
    }
    
    func present(viewController: UIViewController) {
        self.definesPresentationContext = true
        self.present(viewController, animated: true)
    }

    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func handleAppPreviewBannerView() {
        view.bringSubviewToFront(appPreviewBannerView)
        appPreviewBannerLabel.text = LocalizationKeys.AppPreviewUI.h001HomeAppPreviewBannerText.localized()
        appPreviewBannerView.isHidden = isPreviewMode ? false : true
    }
    
}

extension SCUserInfoBoxViewController : SCUserInfoBoxTableVCDelegate {
    func refresh(sender: AnyObject) {
        self.handleRefresh()
    }
    
    func markAsRead(_ read : Bool, item: SCUserInfoBoxMessageItem) {
        self.presenter.markAsRead(read, item: item)
    }
    
    func deleteItem(_ item: SCUserInfoBoxMessageItem) {
        self.presenter.deleteItem(item)
    }

    func displayItem(_ item: SCUserInfoBoxMessageItem) {
        self.presenter.displayItem(item)
    }

    func handleRefresh() {
        self.presenter.needsToReloadData()
    }
    
    func getFooterView() -> UIView? {
        return self.footerViewController.getView()
    }
}

extension SCUserInfoBoxViewController : SCFirstTimeUsageVCDelegate {
    /**
     *
     * Action for the FTU button
     *
     */
    func loginBtnWasPressed() {
        self.presenter.loginButtonWasPressed()
    }
    
    func registerBtnWasPressed() {
        self.presenter.registerButtonWasPressed()
    }

}




