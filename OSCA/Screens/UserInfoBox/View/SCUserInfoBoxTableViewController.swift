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

protocol SCUserInfoBoxTableVCDelegate : NSObjectProtocol, Refreshable
{
    func markAsRead(_ read : Bool, item: SCUserInfoBoxMessageItem)
    func deleteItem(_ item: SCUserInfoBoxMessageItem)
    func displayItem(_ item: SCUserInfoBoxMessageItem)
    func handleRefresh()
    func getFooterView() -> UIView?
}

class SCUserInfoBoxTableViewController: UITableViewController {
    
    var delegate: SCUserInfoBoxTableVCDelegate?

    var items = [SCUserInfoBoxMessageItem]()
    var backgroundEmptyImageView : UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func setupUI(){
        tableView.estimatedRowHeight = 96.0
        tableView.rowHeight = UITableView.automaticDimension
        
        self.addRefreshToPull(on: self.tableView, topYPosition: 0.0)
    }
    
    func reloadData(items: [SCUserInfoBoxMessageItem]){
        self.items = items
        self.tableView.reloadData()
    }
    
    func endRefreshing() {
        self.refreshControl?.endRefreshing()
    }

    private func addRefreshToPull(on view: UIView, topYPosition: CGFloat){
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.tintColor = UIColor(named: "CLR_PULL_TO_REFRESH")
        
        let refreshView = UIView(frame: CGRect(x: 0, y: topYPosition, width: 0, height: 0))
        view.addSubview(refreshView)
        refreshView.addSubview(self.refreshControl!)
        
        self.refreshControl!.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        
    }
    
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.delegate?.handleRefresh()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SCUserInfoBoxTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SCUserInfoBoxCell", for: indexPath) as! SCUserInfoBoxTableViewCell
        
        if indexPath.row < items.count {
            
            let item = items[indexPath.row]
            cell.configure(_for: item)
            
        }
    
       return cell
    }
    
    private func markAsRead(_ read : Bool, indexPath: IndexPath){
        
        if indexPath.row < items.count{
            self.delegate?.markAsRead(read, item: self.items[indexPath.row])
            let cell: SCUserInfoBoxTableViewCell = self.tableView.cellForRow(at: indexPath) as! SCUserInfoBoxTableViewCell
            cell.infoWasRead = read
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.markAsRead(true, indexPath: indexPath)
        
        let item = self.items[indexPath.row]
        self.reloadData(items: self.items)
        
        self.delegate?.displayItem(item)
   }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row < items.count {
            let item = items[indexPath.row]
            let targetState = !item.isRead
            let title = targetState ? "b_002_infobox_swiped_btn_read" : "b_002_infobox_swiped_btn_unread"

            let markAction = UIContextualAction(style: .normal, title: title.localized()) { (action, view, handler) in
                self.markAsRead(targetState, indexPath: indexPath)
                handler(true)
            }
            markAction.backgroundColor = kColor_cityColor
            let configuration = UISwipeActionsConfiguration(actions: [markAction])
            return configuration
        }

        return nil
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row < items.count{
            let item = items[indexPath.row]
            let deleteAction = UIContextualAction(style: .destructive, title: "b_002_infobox_swiped_btn_delete".localized()) { (action, view, handler) in
                /*
                self.items.remove(at: indexPath.row)
                SCUtilities.delay(withTime: 0.0, callback:{
                    self.tableView.reloadData()
                    self.refreshBackgroundView()
                })*/
                
                tableView.beginUpdates()
                self.items.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.endUpdates()

                
                self.delegate?.deleteItem(item)
                handler(true)
            }
            //deleteAction.backgroundColor = UIColor(named: "CLR_ICON_TINT_ERR")
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            return configuration
        }
        
        return nil

    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.items.count == 0 {
            return 500.0
        }
        return 0.0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if self.items.count == 0 {
            return self.delegate?.getFooterView()
//            let footerView = UIStoryboard(name: "UserInfoBoxScreen", bundle: nil).instantiateViewController(withIdentifier: "SCUserInfoBoxFooterViewController").view
//            return footerView
        }
        return nil
    }
}
