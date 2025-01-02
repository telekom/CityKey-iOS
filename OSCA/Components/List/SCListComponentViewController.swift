//
//  SCListComponentViewController.swift
//  SmartCity
//
//  Created by Michael on 06.10.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

protocol SCListComponentViewControllerDelegate : NSObjectProtocol
{
    func didSelectListItem(item: SCBaseComponentItem)
    func didSelectListEventItem(item: SCModelEvent)
    func didPressMoreBtn(listComponent : SCListComponentViewController)
}

class SCListComponentViewController: UIViewController {

    @IBOutlet weak var listHeaderView: UIView!
    
    @IBOutlet weak var listHeaderViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var backgroundView: UIView!
    
    weak var delegate: SCListComponentViewControllerDelegate?
    
    private var tableViewController : SCListTableViewController?
    
    private var listHeaderViewController : SCListHeaderViewController?
    
    private let tableCanBounce = false
    
    private let tableAdjustHeightToRows = true

    private var activityIndicator : UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.backgroundView.layer.cornerRadius = 10.0
        self.backgroundView.clipsToBounds = true
        self.view.layer.shadowRadius = 4
        self.view.layer.shadowOpacity = 0.4
        self.view.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        self.view.clipsToBounds = false
        self.view.backgroundColor = .clear
        self.tableViewController?.tableView.bounces = tableCanBounce
        self.listHeaderViewHeightConstraint.constant = GlobalConstants.kNewsListHeaderHeight

        self.listHeaderViewController?.delegate = self
        
        self.update(rowHeight: tableViewController?.tableView.rowHeight ?? GlobalConstants.kEventListRowHeight)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
            
        case let tableViewController as SCListTableViewController:
            self.tableViewController = tableViewController
            self.tableViewController?.delegate = self

        case let listHeaderViewController as SCListHeaderViewController:
            self.listHeaderViewController = listHeaderViewController
            
        default:
            break
        }
    }
    
    func update(rowHeight : CGFloat) {
        self.tableViewController?.tableView.rowHeight = rowHeight
        self.tableViewController?.tableView.estimatedRowHeight = rowHeight
        self.tableViewController?.tableView.reloadData()
    }
    
    func update(headerText : String, accessibilityID : String) {
        self.listHeaderViewController?.update(headerText: headerText, accessibilityID : accessibilityID)
    }

    func update(noDataAvailabeText : String) {
        self.tableViewController?.noDataText = noDataAvailabeText
    }

    func update(moreBtnText : String, visible : Bool) {
        self.listHeaderViewController?.update(moreBtnText: moreBtnText, visible: visible)
    }

    func isMoreBtnVisible(_ visible : Bool) {
        self.listHeaderViewController?.isMoreBtnVisible(visible)
    }

    func update(itemList : [SCBaseComponentItem]?) {
        self.tableViewController?.titleAtTop = false
        self.tableViewController?.items = itemList ?? []
        self.tableViewController?.type = .news
        
        self.isMoreBtnVisible(self.tableViewController?.items.count ?? 0 > 0)
        
        self.tableViewController?.tableView.reloadData()

    }
    
    func update(eventList: [SCModelEvent], favorites: [SCModelEvent]) {
        self.tableViewController?.titleAtTop = false
        self.tableViewController?.eventItems = eventList
        self.tableViewController?.favoriteItems = favorites
        self.tableViewController?.type = .events
        self.tableViewController?.tableView.reloadData()
        self.isMoreBtnVisible(true)
    }
    
    func customizeHeaderLabelText(color: UIColor) {
        self.listHeaderViewController?.listHeaderLabel.textColor = color
    }
    
    func customizeHeaderMoreButton(color: UIColor) {
        self.listHeaderViewController?.moreBtn.setTitleColor(color, for: .normal)
    }
    
    func customizeCornerRadius(radius: CGFloat) {
        self.view.layer.cornerRadius = radius
    }
    
    func removeShadow() {
        self.view.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.view.layer.shadowRadius = 0.0
        self.view.layer.shadowOpacity = 0.0
        self.backgroundView.layer.cornerRadius = 0.0
        self.backgroundView.clipsToBounds = false
    }
    
    func startRefreshing() {
        if self.activityIndicator == nil {
            self.activityIndicator = UIView(frame: self.tableViewController!.view.bounds)
            self.activityIndicator?.backgroundColor = UIColor(named: "CLR_BCKGRND")!
            
            let indicator = UIActivityIndicatorView()
            indicator.center = CGPoint(x: self.activityIndicator!.center.x, y: 10.0) 
            
            if #available(iOS 13.0, *) {
                indicator.style = .medium
            } else {
                indicator.style = .gray
            }
            
            indicator.startAnimating()
            
            self.activityIndicator?.addSubview(indicator)
            self.tableViewController!.view.addSubview(self.activityIndicator!)
        }
    }

    func endRefreshing() {
        let eventItems = self.tableViewController?.eventItems
        let newsItems = self.tableViewController?.items
        let isVisible = eventItems?.count ?? 0 > 0 || newsItems?.count ?? 0 > 0
        self.isMoreBtnVisible(isVisible)
        
        if self.activityIndicator != nil {
            self.activityIndicator!.removeFromSuperview()
            self.activityIndicator = nil
        }
    }

    func customizeHeader(color : UIColor) {
        self.listHeaderViewController?.customize(color: color)
        
    }
    
    func customize(color : UIColor) {
        self.tableViewController?.customizeColor = color

    }
    func viewForPresentingActivityInfo() -> UIView?{
        return self.tableViewController?.tableView.superview
    }

    func estimatedContentHeight() -> CGFloat {
        if self.tableViewController?.items.count == 0 && self.tableViewController?.eventItems.count == 0 {
            let estimatedHeight = CGFloat((self.tableViewController?.noDataInfoHeight)! + GlobalConstants.kNewsListHeaderHeight)
            return estimatedHeight
        } else {
            guard let tableViewController = self.tableViewController else {
                return 0.0
            }
            switch tableViewController.type {
            case .news:
                let estimatedHeight = CGFloat((self.tableViewController?.tableView?.estimatedRowHeight)!  * CGFloat((self.tableViewController?.items.count)!) + GlobalConstants.kNewsListHeaderHeight)
                return estimatedHeight
            case .events:
                var additionalHeaderCount = 0
                let eventItemsCount = (self.tableViewController?.eventItems.count)! <= 4 ? self.tableViewController?.eventItems.count : 4
                let favoriteItemsCount = (self.tableViewController?.favoriteItems.count)! <= 2 ? self.tableViewController?.favoriteItems.count : 2
                if eventItemsCount! > 0 && favoriteItemsCount! > 0 {
                    additionalHeaderCount = 2
                } else {
                    additionalHeaderCount = 0
                }
                let displayedItemsCount = eventItemsCount! + favoriteItemsCount!
                let estimatedHeight = CGFloat((self.tableViewController?.tableView?.estimatedRowHeight)!  * CGFloat(displayedItemsCount) + GlobalConstants.kNewsListHeaderHeight) + (CGFloat(additionalHeaderCount) * GlobalConstants.kListHeaderHeight)
                return estimatedHeight
            }
            
        }
    }
    
    func routeToNewsDetail(with model: SCBaseComponentItem) {
        self.delegate?.didSelectListItem(item: model)
    }


 }

extension SCListComponentViewController : SCListHeaderViewControllerDelegate
{
    //
    // MARK: -  SCListHeaderViewControllerDelegate methods
    //
    func didPressMoreBtn() {
        self.delegate?.didPressMoreBtn(listComponent: self)
    }
}


extension SCListComponentViewController : SCListTableViewControllerDelegate
{
    func didSelectListEventItem(item: SCModelEvent) {
        self.delegate?.didSelectListEventItem(item: item)
    }
    
    //
    // MARK: -  SCListComponentViewControllerDelegate methods
    //
    func didSelectListItem(item: SCBaseComponentItem) {
        self.delegate?.didSelectListItem(item: item)
    }

}

