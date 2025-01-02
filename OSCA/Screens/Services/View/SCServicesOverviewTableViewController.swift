//
//  SCServicessOverviewTableViewController.swift
//  SmartCity
//
//  Created by Michael on 06.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

class SCServicesOverviewTableViewController: UITableViewController
{
    public var presenter: SCServicesOverviewPresenting!
    
    var items = [SCServicesOverviewSectionItem]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addRefreshToPull(on: self.tableView, topYPosition: 0.0)
        
        tableView.estimatedRowHeight = GlobalConstants.kNewsListRowHeight
        tableView.rowHeight = GlobalConstants.kNewsListRowHeight
        
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        self.presenter.viewWillAppear()
        
    }

    private func reloadData(){
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.items.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.items[section].listItems.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  self.items.count <= 1 ||  self.items[section].listItems.count == 0 ? 0.0 : GlobalConstants.kOverviewListSectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init()
        
        view.layer.shadowRadius = 3
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        view.backgroundColor = items[section].itemColor
        let label = UILabel.init(frame: CGRect(x: 20.0, y: 0.0, width: self.tableView.bounds.size.width - 20.0, height: GlobalConstants.kOverviewListSectionHeaderHeight))
        label.font = UIFont.boldSystemFont(ofSize: 18.0)
        label.text = items[section].itemTitle
        label.textColor = UIColor(named: "CLR_LABEL_TEXT_WHITE")!
        view.addSubview(label)
        return view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SCServicesOverviewTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SCServicesOverviewCell", for: indexPath) as! SCServicesOverviewTableViewCell
        
        // Configure the cell...
        let item = self.items[indexPath.section].listItems[indexPath.row]
        
        cell.serviceCellTitleLabel?.text = items[indexPath.section].itemTitle
        cell.serviceCellLabel?.text = item.itemTitle
        cell.serviceCellImageView?.load(from: item.itemImageURL)
        cell.contentID = item.itemID
        cell.favSelected = false
        cell.cellLockedImageString = item.itemLockedDueAuth ? "icon_locked_content" : item.itemLockedDueResidence  ? "icon_limited_content" :  nil
        cell.showNewRibbon(item.itemIsNew, color: item.itemColor)
        cell.delegate = self
        
        // show only fav button when signedin
        cell.serviceFavBtn.isHidden = !SCAuth.shared.isUserLoggedIn()
        cell.serviceFavBtn.backgroundColor = item.itemColor
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = self.items[indexPath.section].listItems[indexPath.row]
        
        self.presenter.didSelectListItem(item: item)
    }
}

extension SCServicesOverviewTableViewController: SCServicesOverviewDisplaying {
    
    func showNavigationBar(_ visible : Bool) {
        self.navigationController?.isNavigationBarHidden = !visible
    }
    
    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func present(viewController: UIViewController) {
        self.definesPresentationContext = true
        self.present(viewController, animated: true)
    }

    func updateServices(with items: [SCServicesOverviewSectionItem]) {
        self.items = items
        self.reloadData()
    }
    
    func showNeedsToLogin(with text : String, cancelCompletion: (() -> Void)?, loginCompletion: @escaping (() -> Void)) {
        self.showNeedsToLoginAlert(with: text, cancelCompletion: cancelCompletion, loginCompletion: loginCompletion)
    }

    func endRefreshing() {
        self.refreshControl?.endRefreshing()
    }
}

extension SCServicesOverviewTableViewController: SCServicesOverviewTableViewCellDelegate {
    
    func favoriteStateShouldChange(for contentID: String?, newFavSelected: Bool, cell: SCServicesOverviewTableViewCell) {
        if contentID != nil {
            //self.presenter.didChangeFavState(id: id, newState: newFavSelected, favoriteType: .service)
            
            // update cell
            cell.favSelected = newFavSelected
        }
    }
    
    func showLoginNeededNotificationScreen() {
        self.showUIAlert(with: "dialog_login_required_message")
    }
}

/**
 * This Extension add a support for PullToRefresh
 * for the content view of the SCUserInfoBoxTableViewController
 * Swipe down on get fresh new data!
 */
extension SCServicesOverviewTableViewController {
    
    func addRefreshToPull(on view: UIView, topYPosition: CGFloat){
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(named: "CLR_PULL_TO_REFRESH")
        
        let refreshView = UIView(frame: CGRect(x: 0, y: topYPosition, width: 0, height: 0))
        view.addSubview(refreshView)
        refreshView.addSubview(refreshControl)
        
        refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
        
    }
    
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.presenter.needsToReloadData()
    }
}



