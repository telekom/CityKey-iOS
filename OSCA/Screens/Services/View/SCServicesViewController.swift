//
//  SCServicesViewController.swift
//  SmartCity
//
//  Created by Michael on 04.10.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

/**
 * ViewController class for the Services / newsfeed in the first tab of the
 * Application
 */
class SCServicesViewController: UIViewController {

    public var presenter: SCServicesPresenting!
    
    //TODO: does this really needs to be public?
    public var headerheight : CGFloat {
        if UIDevice.current.orientation.isLandscape {
            return CGFloat(Int(self.view.bounds.height * 0.6))
        } else {
            return CGFloat(Int(self.view.bounds.height * 0.3))
        }
    }
    
    @IBOutlet weak var barBtnLocation: UIBarButtonItem!
    @IBOutlet weak var barBtnProfile: UIBarButtonItem!
    
    @IBOutlet weak var newsView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var contentScrollView: UIScrollView!
    
    @IBOutlet weak var infoOverlayView: UIView!
    
    @IBOutlet weak var newServicesHeaderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mostRecentHeaderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var favoritesHeaderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var categoriesHeaderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var allServicesHeaderHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var newServicesHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var categoriesViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var favoritesViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mostRecentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var allServicesHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var categoriesHeaderLabel: UILabel!
    @IBOutlet weak var favoritesHeaderLabel: UILabel!
    @IBOutlet weak var mostRecentHeaderLabel: UILabel!
    @IBOutlet weak var newServicesHeaderLabel: UILabel!
    @IBOutlet weak var allServicesHeaderLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var showAllBtn: UIButton!
    
    @IBOutlet weak var appPreviewBannerView: UIView!
    @IBOutlet weak var appPreviewBannerLabel: UILabel!

    private var newServicesViewController : SCCarouselComponentViewController?
    private var mostRecentViewController : SCCarouselComponentViewController?
    private var favoritesViewController : SCTilesListComponentViewController?
    private var categoriesViewController : SCTilesListComponentViewController?
    private var allServicesViewController : SCTilesListComponentViewController?

    private var headerTransition : SCHeaderTransition!
    
    private let kTopHeaderHeight : CGFloat = 45.0
    private let kHeaderHeight : CGFloat = 65.0

    private var serviceDesc: String?
    
    // the refreshControl
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contentScrollView.addSubview(self.headerView)
        
        self.contentScrollView.showsVerticalScrollIndicator = false
        self.contentScrollView.bringSubviewToFront(self.newsView)
        
        self.headerTransition = SCHeaderTransition.init(with: self)
        
        self.addRefreshToPull(on: self.contentScrollView, topYPosition: -self.headerheight)
        
        self.setupUI()
        
        //adaptive Font Size
        self.categoriesHeaderLabel.adaptFontSize()
        self.favoritesHeaderLabel.adaptFontSize()
        self.mostRecentHeaderLabel.adaptFontSize()
        self.newServicesHeaderLabel.adaptFontSize()
        self.allServicesHeaderLabel.adaptFontSize()

        self.editBtn.titleLabel?.adaptFontSize()
        self.showAllBtn.setTitle(LocalizationKeys.SCServicesViewController.s001services002MarketplacesBtnCategoriesShowAll.localized(), for: .normal)
        self.showAllBtn.titleLabel?.adaptFontSize()
        
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        
        self.shouldNavBarTransparent = true
        
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.presenter.viewDidAppear()
        handleAppPreviewBannerView()
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.barBtnLocation.accessibilityIdentifier = "btn_bar_location"
        self.categoriesHeaderLabel.accessibilityIdentifier = "lbl_header_categories"
        self.favoritesHeaderLabel.accessibilityIdentifier = "lbl_header_favorites"
        self.mostRecentHeaderLabel.accessibilityIdentifier = "lbl_header_most_recent"
        self.newServicesHeaderLabel.accessibilityIdentifier = "lbl_header_new_services"
        self.editBtn.accessibilityIdentifier = "btn_edit"
        self.showAllBtn.accessibilityIdentifier = "btn_showall"
        self.allServicesHeaderLabel.accessibilityIdentifier = "lbl_all_services"
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
        
        newServicesHeaderLabel.accessibilityTraits = .header
        newServicesHeaderLabel.accessibilityLabel = "\(SCUtilities.getHeaderStringWith(level: 2)) \(LocalizationKeys.SCServicesViewController.s001ServicesTitleNew.localized())"
        
        allServicesHeaderLabel.accessibilityTraits = .header
        allServicesHeaderLabel.accessibilityLabel = "\(SCUtilities.getHeaderStringWith(level: 2)) \(LocalizationKeys.SCServicesViewController.s001services002MarketplacesTitleOurs.localized())"
        
        mostRecentHeaderLabel.accessibilityTraits = .header
        mostRecentHeaderLabel.accessibilityLabel = "\(SCUtilities.getHeaderStringWith(level: 2)) \(LocalizationKeys.SCServicesViewController.s001Services002MarketplacesTitleMostUsed.localized())"
        
        categoriesHeaderLabel.accessibilityTraits = .header
        categoriesHeaderLabel.accessibilityLabel = "\(SCUtilities.getHeaderStringWith(level: 2)) \(LocalizationKeys.SCServicesViewController.s001services002MarketplacesTitleCategories.localized())"
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshNavigationBarStyle()
        
        self.headerTransition.tintNavigationBar()
        
        self.presenter.viewWillAppear()
        
        UIAccessibility.delayAndSetFocusTo(barBtnLocation)

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
            
        case let carouselViewController as SCCarouselComponentViewController:
            carouselViewController.delegate = self
            switch segue.identifier {
            case "SegueNewBox":
                self.newServicesViewController = carouselViewController
            case "SegueRecentBox":
                self.mostRecentViewController = carouselViewController
            default:
                break
            }

        case let tilesListViewController as SCTilesListComponentViewController:
            tilesListViewController.delegate = self
            switch segue.identifier {
            case "SegueServicesFavBox":
                self.favoritesViewController = tilesListViewController
            case "SegueCategoriesBox":
                self.categoriesViewController = tilesListViewController
            case "SegueAllServicesBox":
                self.allServicesViewController = tilesListViewController
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
    func setupUI(){
        
        self.newServicesHeaderLabel.text = LocalizationKeys.SCServicesViewController.s001ServicesTitleNew.localized()
        self.allServicesHeaderLabel.text = LocalizationKeys.SCServicesViewController.s001services002MarketplacesTitleOurs.localized()
        self.mostRecentHeaderLabel.text = LocalizationKeys.SCServicesViewController.s001Services002MarketplacesTitleMostUsed.localized()
        self.categoriesHeaderLabel.text =  LocalizationKeys.SCServicesViewController.s001services002MarketplacesTitleCategories.localized()
        
        self.setupFavoritesUI()
        
        self.navigationController?.navigationBar.topItem?.title = nil
        
        // Set the Data Fields in the Services Header
        self.updateHeaderView()
        
        categoriesHeaderLabel.adjustsFontForContentSizeCategory = true
        categoriesHeaderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 17, maxSize: 20)
        favoritesHeaderLabel.adjustsFontForContentSizeCategory = true
        favoritesHeaderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 17, maxSize: 20)
        mostRecentHeaderLabel.adjustsFontForContentSizeCategory = true
        mostRecentHeaderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 17, maxSize: 20)
        newServicesHeaderLabel.adjustsFontForContentSizeCategory = true
        newServicesHeaderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 17, maxSize: 20)
        allServicesHeaderLabel.adjustsFontForContentSizeCategory = true
        allServicesHeaderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 17, maxSize: 20)
        
        self.headerTransition.layoutHeaderView()

        self.headerTransition.tintNavigationBar()
    }
    /**
     *
     * Method that updates the favorites UI, reload component data
     *
     */
    func setupFavoritesUI() {
        
        favoritesHeaderLabel.text = LocalizationKeys.SCServicesViewController.s001Services002MarketplacesTitleFavorites.localized()
        editBtn.setTitle(LocalizationKeys.SCServicesViewController.s001Services002MarketplacesBtnFavoritesEdit.localized(), for: .disabled)
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
    
    @IBAction func editBtnWasPressed(_ sender: Any) {
        self.presenter.editFavoritesButtonWasPressed()
    }
    
    @IBAction func showAllBtnWasPressed(_ sender: Any) {
        self.presenter.showAllButtonWasPressed()
    }
    
    // MARK: - Private methods
    
    /**
     *
     * This Methods resizes the content height of the favorites section
     *
     */
    private func resizeFavorites() {
        
        UIView.animate(withDuration: 1.0, delay: 1.0,
                       options: [.curveEaseOut], animations: {
                        self.favoritesViewController?.update(cellSize: self.favoritesTilesListCellSize())
                        self.favoritesViewHeightConstraint.constant = self.favoritesViewController?.estimatedContentHeight(for: 2) ?? 0.0
                        self.view.setNeedsLayout()
        }, completion: nil)
        
    }

    
    private func addRefreshToPull(on view: UIView, topYPosition: CGFloat){
    
        let refreshView = UIView(frame: CGRect(x: 0, y: topYPosition, width: 0, height: 0))
        view.addSubview(refreshView)
        refreshView.addSubview(refreshControl)
        
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
    }
    
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.presenter.needsToReloadData()
    }
}

// MARK: - SCServicesDisplaying
extension SCServicesViewController: SCServicesDisplaying {
    
    func showDeepLinkedService(name: String, month: String?) {
        self.presenter.showDeepLinkedService(name: name, month: month)
    }

    func setHeaderImageURL(_ url: SCImageURL?) {
        headerImageView.image = UIImage(named: url?.absoluteUrlString() ?? "")
    }
    
    func setCoatOfArmsImageURL(_ url: SCImageURL) {
        self.addNavBarImage(imageUrl: url)
    }
    
    func setServiceDesc(_ serviceDesc: String?) {
        self.serviceDesc = serviceDesc
        self.updateHeaderView()
    }
    
    func updateHeaderView() {
        // Set the Data Fields in the Services Header
        // TODO: why no direct outlet from the headerView?
        for subView in self.headerView.subviews {
            if subView.restorationIdentifier == "Service_Title_Label"{
                let label = subView as! UILabel
                label.adaptFontSize()
                label.text = LocalizationKeys.SCServicesViewController.s001ServicesTitle.localized()
                label.accessibilityTraits = .header
            }
            
            if subView.restorationIdentifier == "Service_Description_Label"{
                let label = subView as! UILabel
                label.adaptFontSize()
//                label.attributedText = "s_001_services_subtitle".localized().applyHyphenation()
                label.attributedText = self.serviceDesc?.applyHyphenation()
                label.adjustsFontForContentSizeCategory = true
                label.font = UIFont.SystemFont.regular.forTextStyle(style: .title3, size: 18, maxSize: 35)
            }
        }
    }
    
    func customize(color: UIColor) {
        // are we missing something here?
    }
    
    func updateNewServices(with dataItems: [SCBaseComponentItem]) {
        self.newServicesViewController?.update(itemList: dataItems)
    }
    
    func updateAllServices(with dataItems: [SCBaseComponentItem]) {
        self.allServicesViewController?.update(itemList: dataItems)
    }
    
    func updateMostRecents(with dataItems: [SCBaseComponentItem]) {
        self.mostRecentViewController?.update(itemList: dataItems)
    }
    
    func updateFavorites(with dataItems: [SCBaseComponentItem]) {
        self.favoritesViewController?.update(itemList: dataItems)
        
        self.updateFavoritesUI(itemsCount: dataItems.count)
    }
    
    func updateCategories(with dataItems: [SCBaseComponentItem]) {
        self.categoriesViewController?.update(itemList: dataItems)
    }
    
    /**
     *
     * This Methods resizes the content height of the lists and carousel components
     *
     */
    func configureContent() {
        debugPrint("SCServicesViewController->resizeContent")
        
        let cityConfig = self.presenter.getServicesFlags()
        
        var firstSection = true
        
        // Resize New Services Section
        self.newServicesViewController?.update(cellSize: self.newServicesCarouselCellSize())
        if cityConfig.showNewServices {
            self.newServicesHeaderHeightConstraint.constant = kTopHeaderHeight
            self.newServicesHeightConstraint.constant = self.newServicesViewController?.estimatedContentHeight() ?? 0.0
            
            firstSection = false
        } else {
            self.newServicesHeightConstraint.constant = 0.0
            self.newServicesHeaderHeightConstraint.constant = 0.0
        }
        
        // Resize Most Recent Section
        self.mostRecentViewController?.update(cellSize: self.mostRecentCarouselCellSize())
        if cityConfig.showMostUsedServices{
            self.mostRecentHeaderHeightConstraint.constant = firstSection ? kTopHeaderHeight : kHeaderHeight
            self.mostRecentHeightConstraint.constant = self.mostRecentViewController?.estimatedContentHeight() ?? 0.0
            firstSection = false
        } else {
            self.mostRecentHeightConstraint.constant = 0.0
            self.mostRecentHeaderHeightConstraint.constant = 0.0
        }
        
        // Resize Favorites Section
        if cityConfig.showFavouriteServices{
            self.favoritesHeaderHeightConstraint.constant = firstSection ? kTopHeaderHeight : kHeaderHeight
            self.resizeFavorites()
            firstSection = false
        } else {
            self.favoritesViewHeightConstraint.constant = 0.0
            self.favoritesHeaderHeightConstraint.constant = 0.0
        }
        
        // Resize All Services Section
        self.allServicesViewController?.update(cellSize: self.allServicesTilesListCellSize())
        if cityConfig.showOurServices{
            self.allServicesHeaderHeightConstraint.constant = firstSection ? kTopHeaderHeight : kHeaderHeight
            self.allServicesHeightConstraint.constant = self.allServicesViewController?.estimatedContentHeight(for: 1) ?? 0.0
            firstSection = false
        } else {
            self.allServicesHeightConstraint.constant = 0.0
            self.allServicesHeaderHeightConstraint.constant = 0.0
        }
        
        // Resize Categories Section
        self.categoriesViewController?.update(cellSize: self.categoriesTilesListCellSize())
        if cityConfig.showCategories{
            self.categoriesHeaderHeightConstraint.constant = firstSection ? kTopHeaderHeight : kHeaderHeight
            self.categoriesViewHeightConstraint.constant = self.categoriesViewController?.estimatedContentHeight(for: 3) ?? 0.0
            firstSection = false
        } else {
            self.categoriesViewHeightConstraint.constant = 0.0
            self.categoriesHeaderHeightConstraint.constant = 0.0
        }
        
        self.view.updateConstraintsIfNeeded()
    }
    
    /**
     *
     * This Methods willshow  infoOverlay status informations
     *
     */
    func showActivityInfoOverlay(){
        self.infoOverlayView.isHidden = false
        self.showActivityOverlay(on: self.infoOverlayView)
    }
    
    func showErrorInfoOverlay(){
        self.infoOverlayView.isHidden = false
        self.showText(on: self.infoOverlayView, text: LocalizationKeys.SCServicesViewController.s001ServicesErrorModuleMsg.localized(), title: nil, textAlignment: .left)
    }
    
    func hideInfoOverlay(){
        self.infoOverlayView.isHidden = true
        self.hideOverlay(on: self.infoOverlayView)
    }
    
    /**
     *
     * This Methods will reset the UI, set the scrollview to the top and the
     * carousels to the first item
     *
     */
    func resetUI() {
        var navBarHeight : CGFloat = 0.0
        
        if let navigationController = self.navigationController {
            navBarHeight = navigationController.navigationBar.frame.size.height + navigationController.navigationBar.frame.origin.y
        }
        self.navigationController?.popToRootViewController(animated: false)
        
        // BUGFIX: on  reset ui we have to add the navBarHeight ?????
        let contentOffset = CGPoint(x: 0, y: -self.contentScrollView.contentInset.top - navBarHeight)
        self.contentScrollView.setContentOffset(contentOffset,animated: false)
        self.mostRecentViewController?.scrollToFirstItem(animated: false)
        self.newServicesViewController?.scrollToFirstItem(animated: false)
        
        self.shouldNavBarTransparent = true
        self.headerTransition.tintNavigationBar()
        
        DispatchQueue.main.async {
            self.refreshNavigationBarStyle()
        }

    }

    func toggleFavoritesEditing() {
        
        if let vc = self.favoritesViewController {
            if vc.isDeleteModeStarted(){
                self.cancelFavDeletionMode()
            } else {
                vc.startDeleteMode()
            }
        }
    }
    
    func cancelFavDeletionMode() {
        self.favoritesViewController?.cancelDeleteMode()
        self.updateFavoritesUI(itemsCount: self.favoritesViewController?.items.count ?? 0)
        self.resizeFavorites()
    }

    
    func pushDeepLinked(viewControllers: [UIViewController]) {
        
        if let navController = self.navigationController {
            
            var i = 0
            for vc in viewControllers{
                i += 1

                // only animate the last viewcontroller
                navController.pushViewController(vc, animated: false)
                
            }
        }
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

    func showNeedsToLogin(with text : String, cancelCompletion: (() -> Void)?, loginCompletion: @escaping (() -> Void)) {
        self.showNeedsToLoginAlert(with: text, cancelCompletion: cancelCompletion, loginCompletion: loginCompletion)
    }
    
    func showNotAvailableAlert() {
        self.showUIAlert(with: "Diese Funktion ist derzeit nicht verfügbar. / Not available at present.")
    }
    
    func endRefreshing() {
        self.refreshControl.endRefreshing()
    }
    
    private func updateFavoritesUI(itemsCount: Int) {
        if itemsCount > 0 {
            self.editBtn.isEnabled = true
            if favoritesViewController?.isDeleteModeStarted()  ?? false{
                editBtn.setTitle(LocalizationKeys.SCServicesViewController.s001services002MarketplacesBtnFaoritesSave.localized(), for: .normal)
            } else {
                editBtn.setTitle(LocalizationKeys.SCServicesViewController.s001Services002MarketplacesBtnFavoritesEdit.localized(), for: .normal)
            }
        } else {
            self.editBtn.isEnabled = false
            favoritesViewController?.cancelDeleteMode()
            editBtn.setTitle(LocalizationKeys.SCServicesViewController.s001Services002MarketplacesBtnFavoritesEdit.localized(), for: .normal)
        }
    }
    
    func handleAppPreviewBannerView() {
        view.bringSubviewToFront(appPreviewBannerView)
        appPreviewBannerLabel.text = LocalizationKeys.AppPreviewUI.h001HomeAppPreviewBannerText.localized()
        appPreviewBannerView.isHidden = isPreviewMode ? false : true
    }
}

// MARK: - SCCarouselComponentViewControllerDelegate + SCTilesListComponentViewControllerDelegate
/**
 * Extension of the SCServicesViewController for handling
 * the delegate mehtods of the caroul and list components
 */
extension SCServicesViewController : SCCarouselComponentViewControllerDelegate, SCTilesListComponentViewControllerDelegate
{
    
    func didPressDeleteBtnForItem(item: SCBaseComponentItem, component: SCTilesListComponentViewController) {
        
        // TODO: we should improve this: When the TileListComponent is in delete mode
        // then we assume that we should remove favorites
        //self.presenter.removeContentFromFavorites(id: item.itemID, favoriteType: .service)
        
        component.delete(item: item)
    }
    
    func switchedToDeleteMode(component: SCTilesListComponentViewController) {
        editBtn.setTitle(LocalizationKeys.SCServicesViewController.s001services002MarketplacesBtnFaoritesSave.localized(), for: .normal)
        
    }
    
    func switchedToSelectMode(component: SCTilesListComponentViewController) {
        editBtn.setTitle(LocalizationKeys.SCServicesViewController.s001Services002MarketplacesBtnFavoritesEdit.localized(), for: .normal)
    }
    
    func didSelectTilesListItem(item: SCBaseComponentItem, component: SCTilesListComponentViewController){
        self.presenter.itemSelected(item)
    }
    
    func didSelectCarouselItem(item: SCBaseComponentItem) {
        self.presenter.itemSelected(item)
    }
}

// MARK: - All the layout informations
extension SCServicesViewController {
    
    // width and the height of the content cells for the all services
    func allServicesTilesListCellSize() -> CGSize {
        let width : CGFloat = CGFloat(roundf(Float( UIScreen.main.bounds.size.width - GlobalConstants.kTilesListContentOffset)))
        let height : CGFloat = CGFloat(roundf(Float(160.0 * GlobalConstants.kBaseAdaptiveScreenFactor)))
        return CGSize(width: width, height: height)
    }
    
    // width and the height of the content cells for the new services
    func newServicesCarouselCellSize() -> CGSize {
        let width : CGFloat = CGFloat(roundf(Float(288.0 * GlobalConstants.kBaseAdaptiveScreenFactor)))
        let height : CGFloat = CGFloat(roundf(Float(160.0 * GlobalConstants.kBaseAdaptiveScreenFactor)))
        return CGSize(width: width, height: height)
    }
    
    // width and height of the content cells for the most recents
    func mostRecentCarouselCellSize() -> CGSize {
        let width : CGFloat = CGFloat(roundf(Float(144.0 * GlobalConstants.kBaseAdaptiveScreenFactor)))
        let height : CGFloat = CGFloat(roundf(Float(144.0 * GlobalConstants.kBaseAdaptiveScreenFactor)))
        return CGSize(width: width, height: height)
    }
    
    // width and height of the content cells for the favorites
    func favoritesTilesListCellSize() -> CGSize {
        let width : CGFloat = CGFloat(roundf(Float(175.0 * GlobalConstants.kBaseAdaptiveTilesScreenFactorFactor)))
        let height : CGFloat = CGFloat(roundf(Float(175.0 * GlobalConstants.kBaseAdaptiveTilesScreenFactorFactor)))
        return CGSize(width: width, height: height)
    }
    
    // width and height of the content cells for the categories
    func categoriesTilesListCellSize() -> CGSize {
        let width : CGFloat = CGFloat(roundf(Float(115.0 * GlobalConstants.kBaseAdaptiveTilesScreenFactorFactor)))
        let height : CGFloat = CGFloat(roundf(Float(115.0 * GlobalConstants.kBaseAdaptiveTilesScreenFactorFactor)))
        return CGSize(width: width, height: height)
    }
}
