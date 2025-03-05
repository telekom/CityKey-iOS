/*
Created by Michael on 01.11.18.
Copyright © 2018 Michael. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2018 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

/**
 * ViewController class for the dashboard / newsfeed in the first tab of the
 * Application
 */
class SCDashboardViewController: UIViewController {
    

    public var presenter: SCDashboardPresenting!
    
    @IBOutlet weak var barBtnLocation: UIBarButtonItem!
    @IBOutlet weak var barBtnProfile: UIBarButtonItem!
    
    @IBOutlet weak var newsView: UIView!
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerWelcomeLabel: UILabel!
    @IBOutlet weak var headerCityLabel: UILabel!
    @IBOutlet weak var headerWeatherLabel: UILabel!
    
    @IBOutlet weak var contentScrollView: UIScrollView!
    
    @IBOutlet weak var newsListHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var discountViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var offerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tipViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventListHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tipHeaderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var offerHeaderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var discountHeaderViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var discountsHeaderLabel: UILabel!
    @IBOutlet weak var offersHeaderLabel: UILabel!
    @IBOutlet weak var tipsHeaderLabel: UILabel!
    
    @IBOutlet weak var appPreviewBannerView: UIView!
    @IBOutlet weak var appPreviewBannerLabel: UILabel!

    private var newsListViewController : SCListComponentViewController?
    private var eventListViewController: SCListComponentViewController?
    private var tipViewController : SCCarouselComponentViewController?
    private var offerViewController : SCCarouselComponentViewController?
    private var discountViewController : SCCarouselComponentViewController?

    private let kHeaderHeight : CGFloat = 65.0

    private var headerTransition : SCHeaderTransition!
    var headerheight : CGFloat {
        get {
            if UIDevice.current.orientation.isLandscape {
                return CGFloat(Int(self.view.bounds.height * 0.9))
            } else {
                return CGFloat(Int(self.view.bounds.height * 0.7))
            }
        }
    }

    private var tooltip : SCToolTip?
    
    // the refreshControl
    private let refreshControl = UIRefreshControl()
    
    // MARK: - view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        
        self.contentScrollView.addSubview(self.headerView)

        self.contentScrollView.showsVerticalScrollIndicator = false
        self.contentScrollView.bringSubviewToFront(self.newsView)

        self.headerTransition = SCHeaderTransition(with: self)

        self.addRefreshToPull(on: self.contentScrollView, topYPosition: -self.headerheight)
        
        //adaptive Font Size
        self.discountsHeaderLabel.adaptFontSize()
        self.offersHeaderLabel.adaptFontSize()
        self.tipsHeaderLabel.adaptFontSize()

        self.shouldNavBarTransparent = true
        self.setupUI()
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        
        SCDataUIEvents.registerNotifications(for: self, on: UIContentSizeCategory.didChangeNotification, with: #selector(handleDynamicTypeChange))

        #if !RELEASE && !STABLE
        // SMARTC-18143 iOS : Implement Logging for login/logout functionality
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(gesture:)))
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
        
        
        let  threeTapGesture = UITapGestureRecognizer(target: self, action: #selector(threeTapped(gesture:)))
        threeTapGesture.numberOfTapsRequired = 3
        view.addGestureRecognizer(threeTapGesture)
        
        
        doubleTapGesture.require(toFail: threeTapGesture)
        
        #endif

    }
    
    @objc func handleDynamicTypeChange(notification: NSNotification) {
        setupUI()
    }
    
    // SMARTC-18143 iOS : Implement Logging for login/logout functionality
    @objc func doubleTapped(gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == .ended  {
            SCFileLogger.shared.presentShareActivity(forTag: .ausweis)
        }
    }
    
    @objc func threeTapped(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended  {
            SCFileLogger.shared.presentShareActivity(forTag: .logout)
        }
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.headerWelcomeLabel.accessibilityIdentifier = "lbl_header_welcome"
        self.headerCityLabel.accessibilityIdentifier = "lbl_header_city"
        self.headerWeatherLabel.accessibilityIdentifier = "lbl_header_weather"
        self.discountsHeaderLabel.accessibilityIdentifier = "lbl_header_discounts"
        self.offersHeaderLabel.accessibilityIdentifier = "lbl_header_offers"
        self.tipsHeaderLabel.accessibilityIdentifier = "lbl_header_tips"
       
        self.barBtnProfile.accessibilityIdentifier = "btn_profile"

        self.barBtnLocation.accessibilityIdentifier = "btn_location"

        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }

    private func setupAccessibility(){
        self.barBtnLocation.accessibilityTraits = .button
        self.barBtnLocation.accessibilityLabel = LocalizationKeys.Common.accessibilityBtnSelectLocation.localized()
        self.barBtnLocation.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.barBtnProfile.accessibilityTraits = .button
        self.barBtnProfile.accessibilityLabel = LocalizationKeys.Common.accessibilityBtnOpenProfile.localized()
        self.barBtnProfile.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.headerWelcomeLabel.accessibilityElementsHidden = true
        self.headerCityLabel.accessibilityLabel = (self.headerWelcomeLabel.text ?? "") +  (self.headerCityLabel.text ?? "")
        self.headerCityLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshNavigationBarStyle()
        
        self.headerTransition.tintNavigationBar()
        
        self.presenter.viewWillAppear()
        
        UIAccessibility.delayAndSetFocusTo(barBtnLocation)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleAppPreviewBannerView()
        UIAccessibility.post(notification: .screenChanged, argument: self.barBtnLocation)
        self.presenter.viewDidAppear()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.headerTransition.layoutHeaderView()
        self.configureContent()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if self.shouldNavBarTransparent {
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

    
    /**
     *
     * Method to get referenced of the embedded viewController
     *
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
            
        case let listViewController as SCListComponentViewController:
            listViewController.delegate = self
            
            switch segue.identifier {
            case "SegueNewsBox":
                self.newsListViewController = listViewController
            case "SegueEventBox":
                self.eventListViewController = listViewController
            default:
                break
            }
            
        case let carouselViewController as SCCarouselComponentViewController:
            carouselViewController.delegate = self
            switch segue.identifier {
            case "SegueTipBox":
                self.tipViewController = carouselViewController
            case "SegueOfferBox":
                self.offerViewController = carouselViewController
            case "SegueDiscountBox":
                self.discountViewController = carouselViewController
            default:
                break
            }
            
        default:
            break
        }
    }
    
    
    /**
     *
     * Method that updates the UI, reload component data and fill
     * the properties of the headerview
     *
     */
    private func setupUI() {
        
        newsListViewController?.update(headerText: LocalizationKeys.SCDashboardVC.h001HomeTitleNews.localized(), accessibilityID: "label_news")
        newsListViewController?.update(noDataAvailabeText : LocalizationKeys.SCDashboardVC.h001HomeNoNews.localized())
        newsListViewController?.update(moreBtnText: LocalizationKeys.SCDashboardVC.h001HomeBtnMoreNews.localized(), visible: true)
        tipsHeaderLabel.text = LocalizationKeys.SCDashboardVC.h001HomeTitleTips.localized()
        offersHeaderLabel.text = LocalizationKeys.SCDashboardVC.h001HomeTitleOffers.localized()
        discountsHeaderLabel.text =  LocalizationKeys.SCDashboardVC.h001HomeTitleDiscounts.localized()
        
        navigationController?.navigationBar.topItem?.title = nil
        navigationItem.backBarButtonItem?.title = LocalizationKeys.Common.navigationBarBack.localized()
        
        if (UIScreen.main.bounds.size.width) != 320 {
        headerWelcomeLabel.adjustsFontForContentSizeCategory = true
        headerWelcomeLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 18, maxSize: 32)
        }
        headerWeatherLabel.adjustsFontForContentSizeCategory = true
        headerWeatherLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .title3, size: 20, maxSize: nil)
        
        self.headerTransition.layoutHeaderView()
    }

    private func addRefreshToPull(on view: UIView, topYPosition: CGFloat) {
        
        let refreshView = UIView(frame: CGRect(x: 0, y: topYPosition, width: 0, height: 0))
        view.addSubview(refreshView)
        refreshView.addSubview(refreshControl)
        
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.presenter.needsToReloadData()
    }
    // MARK: - Private methods

    /**
     *
     * This Methods will reset the UI, set the scrollview to the top and the
     * carousels to the first item
     *
     */
    func resetUI(){
        var navBarHeight : CGFloat = 0.0

        if let navigationController = self.navigationController {
            navBarHeight = navigationController.navigationBar.frame.size.height + navigationController.navigationBar.frame.origin.y
        }
        
        self.navigationController?.popToRootViewController(animated: false)

        // BUGFIX: on  reset ui we have to add the navBarHeight ?????
        let contentOffset = CGPoint(x: 0, y: -self.contentScrollView.contentInset.top - navBarHeight)
        self.contentScrollView.setContentOffset(contentOffset,animated: false)
        self.offerViewController?.scrollToFirstItem(animated: false)
        self.discountViewController?.scrollToFirstItem(animated: false)
        self.tipViewController?.scrollToFirstItem(animated: false)
        self.headerTransition.tintNavigationBar()
        self.shouldNavBarTransparent = true
        self.configureContent()
        UIAccessibility.post(notification: .screenChanged, argument: self.barBtnLocation)

        DispatchQueue.main.async {
            self.refreshNavigationBarStyle()
        }
    }
    
    /**
     *
     * Action for the Search Location Button
     *
     */

    @IBAction func barBtnGeoLocationWasPressed(_ sender: Any) {
       self.presenter.locationButtonWasPressed()
    }
    
    /**
     *
     * Action for the Profile Notifications button
     *
     */
    @IBAction func barBtnProfilenWasPressed(_ sender: Any) {
       self.presenter.profileButtonWasPressed()
    }
    
    func routeToNewsDetail(with model: SCBaseComponentItem) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.newsListViewController?.routeToNewsDetail(with: model)
        }
    }
}

// MARK: - SCDashboardDisplaying
extension SCDashboardViewController: SCDashboardDisplaying {
    
    func setHeaderImageURL(_ url: SCImageURL?) {
        if let imageUrl = url {
            self.headerImageView.load(from: imageUrl)
        } else {
            self.headerImageView.image = nil
        }
    }
    
    func setCoatOfArmsImageURL(_ url: SCImageURL) {
        self.addNavBarImage(imageUrl: url)
    }
    
    func setWelcomeText(_ text: String) {
        self.headerWelcomeLabel.adaptFontSize()
        self.headerWelcomeLabel.text = text
        self.setupAccessibility()
    }
    
    func setCityName(_ name: String) {
        self.headerCityLabel.adaptFontSize()
        self.headerCityLabel.text = name
        self.setupAccessibility()
        kSelectedCityName = name
    }
    
    func setWeatherInfo(_ info: String) {
        self.headerWeatherLabel.adaptFontSize()
        self.headerWeatherLabel.text = info
        self.setupAccessibility()
    }
    
    func customize(color: UIColor) {
        newsListViewController?.customizeHeader(color: color)
    }
    
    func updateNews(with dataItems: [SCBaseComponentItem]) {
        self.newsListViewController?.update(itemList: dataItems)
        self.configureContent()
    }
    
    func updateEvents(with dataItems: [SCModelEvent]?, favorites: [SCModelEvent]?) {
        let moreBtnVisisble = true
        self.eventListViewController?.customize(color: kColor_cityColor)
        self.eventListViewController?.update(eventList: dataItems ?? [SCModelEvent](), favorites: favorites ?? [SCModelEvent]())
        eventListViewController?.update(headerText: LocalizationKeys.SCDashboardVC.h001HomeTitleEvents.localized(), accessibilityID: "home_module_event_list_header")
        eventListViewController?.update(moreBtnText: LocalizationKeys.SCDashboardVC.h001HomeBtnAllEvents.localized(),visible: moreBtnVisisble)
        self.eventListViewController?.customizeHeader(color: .clear)
        self.eventListViewController?.customizeHeaderLabelText(color: UIColor(named: "CLR_LABEL_TEXT_BLACK")!)
        eventListViewController?.update(noDataAvailabeText : LocalizationKeys.SCDashboardVC.h001EventsNoEventsMsg.localized())
        self.eventListViewController?.removeShadow()
        self.configureContent()
        
        if dataItems == nil {
            self.eventListViewController?.startRefreshing()
            self.eventListViewController?.customizeHeaderMoreButton(color: kColor_cityColor.withAlphaComponent(0.35))
        } else {
            self.eventListViewController?.endRefreshing()
            self.eventListViewController?.customizeHeaderMoreButton(color: kColor_cityColor)
        }

    }
    
    /**
     *
     * This Methods willshow  infoOverlay status informations for News
     *
     */
    func showNewsActivityInfoOverlay(){
        if let view = self.newsListViewController?.viewForPresentingActivityInfo(){
            self.showActivityOverlay(on: view, backColor: UIColor(named: "CLR_BCKGRND")!)
        }
    }
    
    func showNewsErrorInfoOverlay(infoText: String){
        if let view = self.newsListViewController?.viewForPresentingActivityInfo(){
            self.showText(on: view, text: infoText, title: nil, textAlignment: .left, backColor: UIColor(named: "CLR_BCKGRND")!)
        }
    }
    
    func hideNewsInfoOverlay(){
        if let view = self.newsListViewController?.viewForPresentingActivityInfo(){
            self.hideOverlay(on: view)
        }
    }

    /**
     *
     * This Methods willshow  infoOverlay status informations for Events
     *
     */
    func showEventsActivityInfoOverlay(){
        if let view = self.eventListViewController?.viewForPresentingActivityInfo(){
            self.showActivityOverlay(on: view, backColor: UIColor(named: "CLR_BCKGRND")!)
        }
    }
    
    func showEventsErrorInfoOverlay(infoText: String){
        if let view = self.eventListViewController?.viewForPresentingActivityInfo(){
            self.showText(on: view, text: infoText, title: nil, textAlignment: .center, backColor: UIColor(named: "CLR_BCKGRND")!)
        }
    }
    
    func hideEventsInfoOverlay(){
        if let view = self.eventListViewController?.viewForPresentingActivityInfo(){
            self.hideOverlay(on: view)
        }
    }
    
    /**
     *
     * This Methods resizes the content height of the lists and carousel components
     *
     * @param animates if set to true the resizing process will be animated
     */
    func configureContent() {
 
        let cityConfig = self.presenter.getDashboardFlags()

        self.tipViewController?.update(cellSize: self.tipsCarouselCellSize())
        if cityConfig.showTips{
            self.tipHeaderViewHeightConstraint.constant = kHeaderHeight
            self.tipViewHeightConstraint.constant =  self.tipViewController?.estimatedContentHeight() ?? 0.0
        } else {
            self.tipViewHeightConstraint.constant = 0.0
            self.tipHeaderViewHeightConstraint.constant = 0.0
        }

        
        self.offerViewController?.update(cellSize: self.offerCarouselCellSize())
        if cityConfig.showOffers{
            self.offerHeaderViewHeightConstraint.constant = kHeaderHeight
            self.offerViewHeightConstraint.constant =  self.offerViewController?.estimatedContentHeight() ?? 0.0
        } else {
            self.offerViewHeightConstraint.constant = 0.0
            self.offerHeaderViewHeightConstraint.constant = 0.0
        }
        
        self.discountViewController?.update(cellSize: self.discountCarouselCellSize())
        if cityConfig.showDiscounts{
            self.discountHeaderViewHeightConstraint.constant = kHeaderHeight
            self.discountViewHeightConstraint.constant =  self.discountViewController?.estimatedContentHeight() ?? 0.0
        } else {
            self.discountViewHeightConstraint.constant = 0.0
            self.discountHeaderViewHeightConstraint.constant = 0.0
        }
        
        self.newsListViewController?.update(rowHeight: self.newsListRowHeight())
        self.newsListHeightConstraint.constant = (self.newsListViewController?.estimatedContentHeight())!
        
        self.eventListViewController?.update(rowHeight: self.eventListRowHeight())
        self.eventListHeightConstraint.constant = (self.eventListViewController?.estimatedContentHeight())!
        
        self.view.updateConstraintsIfNeeded()

    }
    
    
    func navigationController() -> UINavigationController? {
        return self.navigationController
    }
    
    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showNavigationBar(_ visible : Bool) {
        self.navigationController?.isNavigationBarHidden = !visible
    }

    func present(viewController: UIViewController) {
        self.definesPresentationContext = true
        self.present(viewController, animated: true)
    }
    
    func presentDPNViewController(viewController : UIViewController) {
        
        var presentedControllerClassName = ""
        
        if let navController = presentedViewController as? UINavigationController {
            presentedControllerClassName =  NSStringFromClass(type(of: navController.viewControllers.first!))
        }
        if presentedControllerClassName == "OSCA.SCDataPrivacyNoticeViewController" { return }
        
        if let navController = presentedViewController?.presentedViewController as? UINavigationController {
            presentedControllerClassName =  NSStringFromClass(type(of: navController.viewControllers.first!))
        }
        if presentedControllerClassName == "OSCA.SCDataPrivacyNoticeViewController" { return }
        
        if let presentedVC = self.presentedViewController {
            presentedVC.present(viewController, animated: true, completion: nil )
        } else {
            present(viewController: viewController)
        }

    }
    
    func endRefreshing() {
        self.refreshControl.endRefreshing()
    }
    
    func endRefreshingEventContent() {
        self.eventListViewController?.endRefreshing()
    }
    
    func showChangeLocationToolTip(){
        
        if tooltip == nil {
            tooltip = SCToolTip()
            tooltip?.showToolTip(forItem: barBtnLocation, text: LocalizationKeys.SCDashboardVC.h001HomeToolTipSwitchLocation.localized())
        }

        // Hiding ToolTip after 3 seconds after showing it
        SCUtilities.delay(withTime: 6.0) {
            self.hideChangeLocationToolTip()
        }
    }
    
    func hideChangeLocationToolTip(){
        self.tooltip?.hideToolTip()
        self.tooltip = nil
    }
    
    func handleAppPreviewBannerView() {
        contentScrollView.bringSubviewToFront(appPreviewBannerView)
        appPreviewBannerLabel.text = LocalizationKeys.AppPreviewUI.h001HomeAppPreviewBannerText.localized()
        appPreviewBannerView.isHidden = isPreviewMode ? false : true
    }
    
}

 // MARK: - SCListComponentViewControllerDelegate and SCCarouselComponentViewControllerDelegate methods
extension SCDashboardViewController : SCListComponentViewControllerDelegate, SCCarouselComponentViewControllerDelegate
{
    func didPressMoreBtn(listComponent: SCListComponentViewController) {
        switch listComponent {
        case self.newsListViewController:
            self.presenter.didPressMoreNewsBtn()
        default:
            self.presenter.didPressMoreEventsBtn()
        }
    }
    
    func didSelectCarouselItem(item: SCBaseComponentItem) {
        self.presenter.didSelectListItem(item: item)
    }
    
   
    func didSelectListItem(item: SCBaseComponentItem) {
        self.presenter.didSelectListItem(item: item)
    }
    
    func didSelectListEventItem(item: SCModelEvent){
        self.presenter.didSelectListEventItem(item: item, isCityChanged: false, cityId: nil)
    }

}

 // MARK: - all layout informations
extension SCDashboardViewController {
    // height of the content row for the new
    private func newsListRowHeight() -> CGFloat {
        return GlobalConstants.kNewsListRowHeight
    }
    
    private func eventListRowHeight() -> CGFloat {
        let contentSize = traitCollection.preferredContentSizeCategory
        if contentSize.isAccessibilityCategory {
            return 120.0
        } else {
            return GlobalConstants.kEventListRowHeight
        }
    }
    
    // width and height of the content cells for the tips
    private func tipsCarouselCellSize() -> CGSize {
        let width : CGFloat = CGFloat(roundf(Float(288.0 * GlobalConstants.kBaseAdaptiveScreenFactor)))
        let height : CGFloat = CGFloat(roundf(Float(288.0 * GlobalConstants.kBaseAdaptiveScreenFactor)))
        return CGSize(width: width, height: height)
    }
    
    // width and height of the content cells for the offers
    private func offerCarouselCellSize() -> CGSize {
        let width : CGFloat = CGFloat(roundf(Float(288.0 * GlobalConstants.kBaseAdaptiveScreenFactor)))
        let height : CGFloat = CGFloat(roundf(Float(288.0 * GlobalConstants.kBaseAdaptiveScreenFactor)))
        return CGSize(width: width, height: height)
    }
    
    // width and height of the content cells for the discounts
    private func discountCarouselCellSize() -> CGSize {
        let width : CGFloat = CGFloat(roundf(Float(200.0 * GlobalConstants.kBaseAdaptiveScreenFactor)))
        let height : CGFloat = CGFloat(roundf(Float(200.0 * GlobalConstants.kBaseAdaptiveScreenFactor)))
        return CGSize(width: width, height: height)
    }
}
