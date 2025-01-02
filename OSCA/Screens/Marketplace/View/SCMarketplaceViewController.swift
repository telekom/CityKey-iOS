//
//  SCMarketplaceViewController.swift
//  SmartCity
//
//  Created by Michael on 04.10.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

/**
 * ViewController class for the Marketplace / newsfeed in the first tab of the
 * Application
 */
class SCMarketplaceViewController: UIViewController {
    
    public var presenter: SCMarketplacePresenting!
    
    //TODO: does this really needs to be public?

    var headerheight : CGFloat {
        if UIDevice.current.orientation.isLandscape {
            return CGFloat(Int(self.view.bounds.height * 0.6))
        } else {
            return CGFloat(Int(self.view.bounds.height * 0.3))
        }
    }

    @IBOutlet weak var barBtnLocation: UIBarButtonItem!
    
    @IBOutlet weak var newsView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var contentScrollView: UIScrollView!
    
    @IBOutlet weak var discountHeaderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var newMarketplaceHeaderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var favoritesHeaderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mostRecentHeaderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var branchesHeaderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var allMarketplaceHeaderHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var discountsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var newMarketplaceHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var branchesViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var favoritesViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mostRecentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var allMarketplaceHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var discountsHeaderLabel: UILabel!
    @IBOutlet weak var branchesHeaderLabel: UILabel!
    @IBOutlet weak var favoritesHeaderLabel: UILabel!
    @IBOutlet weak var mostRecentHeaderLabel: UILabel!
    @IBOutlet weak var newMarketplaceHeaderLabel: UILabel!
    @IBOutlet weak var allMarketplaceHeaderLabel: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var showAllBtn: UIButton!
    
    private var discountsViewController : SCCarouselComponentViewController?
    private var newMarketplaceViewController : SCCarouselComponentViewController?
    private var mostRecentViewController : SCCarouselComponentViewController?
    private var favoritesViewController : SCTilesListComponentViewController?
    private var branchesViewController : SCTilesListComponentViewController?
    private var allMarketplaceViewController : SCTilesListComponentViewController?

    private var headerTransition : SCHeaderTransition!
    
    private let kTopHeaderHeight : CGFloat = 45.0
    private let kHeaderHeight : CGFloat = 65.0

    
    // the refreshControl
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shouldNavBarTransparent = true
        self.contentScrollView.addSubview(self.headerView)
        
        self.contentScrollView.showsVerticalScrollIndicator = false
        self.contentScrollView.bringSubviewToFront(self.newsView)
        
        self.headerTransition = SCHeaderTransition.init(with: self)
        
        self.addRefreshToPull(on: self.contentScrollView, topYPosition: -self.headerheight)
        
        //adaptive Font Size
        self.discountsHeaderLabel.adaptFontSize()
        self.branchesHeaderLabel.adaptFontSize()
        self.mostRecentHeaderLabel.adaptFontSize()
        self.favoritesHeaderLabel.adaptFontSize()
        self.newMarketplaceHeaderLabel.adaptFontSize()

        self.btnEdit.titleLabel?.adaptFontSize()
        self.showAllBtn.setTitle("s_001_services_002_marketplaces_btn_categories_show_all".localized(), for: .normal)
        self.showAllBtn.titleLabel?.adaptFontSize()

        self.setupUI()
        
        self.setupAccessibilityIDs()
        
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.barBtnLocation.accessibilityIdentifier = "btn_bar_location"
        self.branchesHeaderLabel.accessibilityIdentifier = "lbl_header_branches"
        self.favoritesHeaderLabel.accessibilityIdentifier = "lbl_header_favorites"
        self.mostRecentHeaderLabel.accessibilityIdentifier = "lbl_header_most_recent"
        self.newMarketplaceHeaderLabel.accessibilityIdentifier = "lbl_header_new_marketplace"
        self.btnEdit.accessibilityIdentifier = "btn_edit"
        self.showAllBtn.accessibilityIdentifier = "btn_showall"
        self.allMarketplaceHeaderLabel.accessibilityIdentifier = "lbl_all_marketplaces"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshNavigationBarStyle()
        
        self.headerTransition.tintNavigationBar()
        
        self.presenter.viewWillAppear()

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
            case "SegueMarketplaceDiscountsBox":
                self.discountsViewController = carouselViewController
            case "SegueMPNewBox":
                self.newMarketplaceViewController = carouselViewController
            case "SegueMPRecentBox":
                self.mostRecentViewController = carouselViewController
            default:
                break
            }
            
        case let tilesListViewController as SCTilesListComponentViewController:
            tilesListViewController.delegate = self
            switch segue.identifier {
            case "SegueMPFavBox":
                self.favoritesViewController = tilesListViewController
            case "SegueBranchesBox":
                self.branchesViewController = tilesListViewController
            case "SegueMPAllBox":
                self.allMarketplaceViewController = tilesListViewController
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
        
        discountsHeaderLabel.text = "h_001_home_title_discounts".localized()
        allMarketplaceHeaderLabel.text = "s_002_marketplaces_title_ours".localized()
        newMarketplaceHeaderLabel.text = "s_002_marketplaces_title_new".localized()
        mostRecentHeaderLabel.text = "s_001_services_002_marketplaces_title_most_used".localized()
        branchesHeaderLabel.text =  "s_002_marketplaces_title_branches".localized()
        favoritesHeaderLabel.text = "s_001_services_002_marketplaces_title_favorites".localized()
        
        btnEdit.setTitle("s_001_services_002_marketplaces_btn_favorites_edit".localized(), for: .normal)
        
        self.navigationController?.navigationBar.topItem?.title = nil
        
        // Set the Data Fields in the Marketplace Header
        for subView in self.headerView.subviews {
            if subView.restorationIdentifier == "Marketplace_Title_Label"{
                let label = subView as! UILabel
                label.adaptFontSize()
                label.text = "s_002_marketplaces_title".localized()
            }
            
            if subView.restorationIdentifier == "Marketplace_Description_Label"{
                let label = subView as! UILabel
                label.adaptFontSize()
                label.text = "s_002_marketplaces_subtitle".localized()
            }
        }
        
        self.headerTransition.layoutHeaderView()

        SCUtilities.delay(withTime: 0.0, callback: {self.headerTransition.tintNavigationBar()})
    }

    /**
     *
     * Action for the Search Location Button
     *
     */
    
    // MARK: - User actions
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
    
    /**
     *
     * Action for the Favorite Edit button
     *
     */
    
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
     * @param animates if set to true the resizing process will be animated
     */
     private func resizeFavorites() {
        
        UIView.animate(withDuration: 1.0, delay: 1.0,
                       options: [.curveEaseOut], animations: {
                        self.favoritesViewController?.update(cellSize: self.favoritesTilesListCellSize())
                        self.favoritesViewHeightConstraint.constant = self.favoritesViewController?.estimatedContentHeight(for: 2) ?? 0.0
                        self.view.setNeedsLayout()
        }, completion: nil)
  
    }

}

// MARK: - SCServicesDisplaying
extension SCMarketplaceViewController: SCMarketplaceDisplaying {
    
    func setHeaderImageURL(_ url: SCImageURL?) {
        self.headerImageView.load(from: url) 
    }
    
    func setCoatOfArmsImageURL(_ url: SCImageURL) {
         self.addNavBarImage(imageUrl: url)
    }
    
    func customize(color: UIColor) {
        // TODO: are we missing something here?
    }
    
    func updateAllMarketplace(with dataItems: [SCBaseComponentItem]) {
        self.allMarketplaceViewController?.update(itemList: dataItems)
    }
    
    func updateNewMarketplace(with dataItems: [SCBaseComponentItem]) {
        self.newMarketplaceViewController?.update(itemList: dataItems)
    }
    
    func updateDiscounts(with dataItems: [SCBaseComponentItem]) {
        self.discountsViewController?.update(itemList: dataItems)
    }
    
    func updateRecents(with dataItems: [SCBaseComponentItem]) {
        self.mostRecentViewController?.update(itemList: dataItems)
    }
    
    func updateBranches(with dataItems: [SCBaseComponentItem]) {
        self.branchesViewController?.update(itemList: dataItems)
    }
    
    func updateFavorites(with dataItems: [SCBaseComponentItem]) {
        self.favoritesViewController?.update(itemList: dataItems)
        
        self.updateFavoritesUI(itemsCount: dataItems.count)
        
    }
    
    /**
     *
     * This Methods resizes the content height of the lists and carousel components
     *
     * @param animates if set to true the resizing process will be animated
     */
    func configureContent() {
        
        let cityConfig = self.presenter.getMarketplaceFlags()
        
        var firstSection = true
        
        // Resize Discount Services Section
        self.discountsViewController?.update(cellSize: self.discountsCarouselCellSize())
        if cityConfig.showDiscounts{
            self.discountHeaderHeightConstraint.constant = kTopHeaderHeight
            self.discountsHeightConstraint.constant = self.discountsViewController?.estimatedContentHeight() ?? 0.0
            firstSection = false
        } else {
            self.discountHeaderHeightConstraint.constant = 0.0
            self.discountsHeightConstraint.constant = 0.0
        }
        
        // Resize New Section
        self.newMarketplaceViewController?.update(cellSize: self.newMarketplaceCarouselCellSize())
        if cityConfig.showNewMarketplaces{
            self.newMarketplaceHeaderHeightConstraint.constant = firstSection ? kTopHeaderHeight : kHeaderHeight
            self.newMarketplaceHeightConstraint.constant =  self.newMarketplaceViewController?.estimatedContentHeight() ?? 0.0
            firstSection = false
        } else {
            self.newMarketplaceHeightConstraint.constant = 0.0
            self.newMarketplaceHeaderHeightConstraint.constant = 0.0
        }
        
        // Resize Most Recent Section
        self.mostRecentViewController?.update(cellSize: self.mostRecentCarouselCellSize())
        if cityConfig.showMostUsedMarketplaces{
            self.mostRecentHeaderHeightConstraint.constant = firstSection ? kTopHeaderHeight : kHeaderHeight
            self.mostRecentHeightConstraint.constant =  self.mostRecentViewController?.estimatedContentHeight() ?? 0.0
            firstSection = false
        } else {
            self.mostRecentHeightConstraint.constant = 0.0
            self.mostRecentHeaderHeightConstraint.constant = 0.0
        }
        
        // Resize Favorites Section
        if cityConfig.showFavoriteMarketplaces{
            self.favoritesHeaderHeightConstraint.constant = firstSection ? kTopHeaderHeight : kHeaderHeight
            self.resizeFavorites()
            firstSection = false
        } else {
            self.favoritesViewHeightConstraint.constant = 0.0
            self.favoritesHeaderHeightConstraint.constant = 0.0
        }
        
        // Resize All Marketplaces Section
        self.allMarketplaceViewController?.update(cellSize: self.allMarketplaceTilesListCellSize())
        if cityConfig.showOurMarketplaces{
            self.allMarketplaceHeaderHeightConstraint.constant = firstSection ? kTopHeaderHeight : kHeaderHeight
            self.allMarketplaceHeightConstraint.constant = self.allMarketplaceViewController?.estimatedContentHeight(for: 1) ?? 0.0
            firstSection = false
        } else {
            self.allMarketplaceHeightConstraint.constant = 0.0
            self.allMarketplaceHeaderHeightConstraint.constant = 0.0
        }
        
        // Resize Branches Section
        self.branchesViewController?.update(cellSize: self.branchesTilesListCellSize())
        if cityConfig.showBranches{
            self.branchesHeaderHeightConstraint.constant = firstSection ? kTopHeaderHeight : kHeaderHeight
            self.branchesViewHeightConstraint.constant = self.branchesViewController?.estimatedContentHeight(for: 3) ?? 0.0
            firstSection = false
        } else {
            self.branchesViewHeightConstraint.constant = 0.0
            self.branchesHeaderHeightConstraint.constant = 0.0
        }
        
        self.view.updateConstraintsIfNeeded()
    }
    
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
        
        // BUGFIX: on  reset ui we have to add the navBarHeight ?????
        let contentOffset = CGPoint(x: 0, y: -self.contentScrollView.contentInset.top - navBarHeight)
        self.contentScrollView.setContentOffset(contentOffset,animated: false)
        self.mostRecentViewController?.scrollToFirstItem(animated: false)
        self.newMarketplaceViewController?.scrollToFirstItem(animated: false)
        
        self.shouldNavBarTransparent = false
        
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

    func endRefreshing() {
        self.refreshControl.endRefreshing()
    }
    
    private func updateFavoritesUI(itemsCount: Int) {
        
        if itemsCount > 0 {
            self.btnEdit.isEnabled = true
            if favoritesViewController?.isDeleteModeStarted() ?? false {
                btnEdit.setTitle("s_001_services_002_marketplaces_btn_favorites_save".localized(), for: .normal)
            } else {
                btnEdit.setTitle("s_001_services_002_marketplaces_btn_favorites_edit".localized(), for: .normal)
            }
        } else {
            self.btnEdit.isEnabled = false
            favoritesViewController?.cancelDeleteMode()
            btnEdit.setTitle("s_001_services_002_marketplaces_btn_favorites_edit".localized(), for: .normal)
        }
    }
}

/**
 * This Extension add a support for PullToRefresh
 * for the content view of the SCMarketplaceViewController
 * Swipe down on get fresh new data!
 */
extension SCMarketplaceViewController {
    
    func addRefreshToPull(on view: UIView, topYPosition: CGFloat){
        
        self.refreshControl.tintColor = UIColor.white
        
        let refreshView = UIView(frame: CGRect(x: 0, y: topYPosition, width: 0, height: 0))
        view.addSubview(refreshView)
        refreshView.addSubview(self.refreshControl)
        
        self.refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        self.presenter.needsToReloadData()
    }
}


/**
 * Extension of the SCMarketplaceViewController for handling
 * the delegate mehtods of the caroul and list components
 */
extension SCMarketplaceViewController : SCCarouselComponentViewControllerDelegate, SCTilesListComponentViewControllerDelegate
{
    func didPressDeleteBtnForItem(item: SCBaseComponentItem, component: SCTilesListComponentViewController) {
        // we should improve this: When the TileListComponent is in delete mode
        // then we assume that we should remove favorites
        //self.presenter.removeContentFromFavorites(id: item.itemID, favoriteType: .marketplace)

        component.delete(item: item)
    }
    
    func switchedToDeleteMode(component: SCTilesListComponentViewController) {
        btnEdit.setTitle("s_001_services_002_marketplaces_btn_favorites_save".localized(), for: .normal)
        
    }
    
    func switchedToSelectMode(component: SCTilesListComponentViewController) {
        btnEdit.setTitle("s_001_services_002_marketplaces_btn_favorites_edit".localized(), for: .normal)
    }
    
    func didSelectTilesListItem(item: SCBaseComponentItem, component: SCTilesListComponentViewController){
        self.presenter.itemSelected(item)
    }
    
    func didSelectCarouselItem(item: SCBaseComponentItem) {
        // TODO: this is workaround code
        // decision if present content or push overview is based on itemContext
        // used in different classes (e.g. ServicesViewController)
        // refactor asap
        var modifiedItem = item
        modifiedItem.itemContext = .favorites
        
        self.presenter.itemSelected(modifiedItem)
    }
}


// MARK: - Layout information
extension SCMarketplaceViewController {
    
    // width and the height of the content cells for the all Marketplaces
    func allMarketplaceTilesListCellSize() -> CGSize {
        let width : CGFloat = CGFloat(roundf(Float( UIScreen.main.bounds.size.width - GlobalConstants.kTilesListContentOffset)))
        let height : CGFloat = CGFloat(roundf(Float(160.0 * GlobalConstants.kBaseAdaptiveScreenFactor)))
        return CGSize(width: width, height: height)
    }
    
    // width and the height of the content cells for the discounts
    func discountsCarouselCellSize() -> CGSize {
        let width : CGFloat = CGFloat(roundf(Float(200.0 * GlobalConstants.kBaseAdaptiveScreenFactor)))
        let height : CGFloat = CGFloat(roundf(Float(192.0 * GlobalConstants.kBaseAdaptiveScreenFactor)))
        return CGSize(width: width, height: height)
    }
    
    
    // width and the height of the content cells for the new Marketplace
    func newMarketplaceCarouselCellSize() -> CGSize {
        let width : CGFloat = CGFloat(roundf(Float(272.0 * GlobalConstants.kBaseAdaptiveScreenFactor)))
        let height : CGFloat = CGFloat(roundf(Float(192.0 * GlobalConstants.kBaseAdaptiveScreenFactor)))
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
    
    // width and height of the content cells for the branches
    func branchesTilesListCellSize() -> CGSize {
        let width : CGFloat = CGFloat(roundf(Float(115.0 * GlobalConstants.kBaseAdaptiveTilesScreenFactorFactor)))
        let height : CGFloat = CGFloat(roundf(Float(115.0 * GlobalConstants.kBaseAdaptiveTilesScreenFactorFactor)))
        return CGSize(width: width, height: height)
    }
}
