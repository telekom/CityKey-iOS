//
//  SCUserInfoBoxTableViewController.swift
//  SmartCity
//
//  Created by Michael on 06.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

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
