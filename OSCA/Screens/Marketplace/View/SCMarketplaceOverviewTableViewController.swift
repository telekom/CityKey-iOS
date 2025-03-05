/*
Created by Michael on 06.11.18.
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

class SCMarketplaceOverviewTableViewController: UITableViewController
{
    public var presenter: SCMarketplaceOverviewPresenting!
    
    var items = [SCMarketplaceOverviewSectionItem]()
        
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
        let cell: SCMarketplaceOverviewTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SCMarketplaceOverviewCell", for: indexPath) as! SCMarketplaceOverviewTableViewCell
        
        // Configure the cell...
        let item = self.items[indexPath.section].listItems[indexPath.row]

        cell.marketplaceCellTitleLabel?.text = items[indexPath.section].itemTitle
        cell.marketplaceCellLabel?.text = item.itemTitle
        cell.marketplaceCellImageView?.load(from: item.itemImageURL)
        cell.contentID = item.itemID
        cell.favSelected = false
        cell.cellLockedImageString = item.itemLockedDueAuth ? "icon_locked_content" : item.itemLockedDueResidence  ? "icon_limited_content" :  nil
        cell.showNewRibbon(item.itemIsNew, color: item.itemColor)
        cell.delegate = self
        
        // show only fav button when signedin
        cell.marketplaceFavBtn.isHidden = !SCAuth.shared.isUserLoggedIn()
        cell.marketplaceFavBtn.backgroundColor = item.itemColor
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = self.items[indexPath.section].listItems[indexPath.row]

        self.presenter.didSelectListItem(item: item)
    }
}

extension SCMarketplaceOverviewTableViewController: SCMarketplaceOverviewDisplaying {
    
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

    func updateMarketplaces(with items: [SCMarketplaceOverviewSectionItem]) {
        self.items = items
        self.reloadData()
    }
    
    func endRefreshing() {
        self.refreshControl?.endRefreshing()
    }
}

extension SCMarketplaceOverviewTableViewController: SCMarketplaceOverviewTableViewCellDelegate {
    
    func favoriteStateShouldChange(for contentID: String?, newFavSelected: Bool, cell: SCMarketplaceOverviewTableViewCell) {
        if contentID != nil {
            //self.presenter.didChangeFavState(id: id, newState: newFavSelected, favoriteType: .marketplace)

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
extension SCMarketplaceOverviewTableViewController {
    
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
