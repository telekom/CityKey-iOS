//
//  UITableViewController+Refresh.swift
//  SmartCity
//
//  Created by Alexander Lichius on 03.09.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

@objc protocol Refreshable {
    func refresh(sender:AnyObject)
}

extension Refreshable where Self: UITableViewController {

    func showEmptyView(_with message: String) {
        tableView.tableFooterView = UIView()
        tableView.tableFooterView?.frame.size.height = tableView.frame.size.height - tableView.contentInset.top
        let label = UILabel()
        label.text = message
        label.translatesAutoresizingMaskIntoConstraints = false
        let imageView = UIImageView()
        imageView.image = UIImage(named: "warningInfo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView?.addSubview(imageView)
        tableView.tableFooterView?.addSubview(label)
        if let footerView = tableView.tableFooterView {
            imageView.centerYAnchor.constraint(equalTo: footerView.centerYAnchor).isActive = true
            imageView.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16).isActive = true
            label.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
            label.heightAnchor.constraint(equalToConstant: 20).isActive = true
            label.widthAnchor.constraint(equalToConstant: 250).isActive = true
        }
    }
    
    func hideEmptyView() {
        self.tableView.tableFooterView = UIView()
    }
    
    func configureRefreshControl(with title: String) {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        if let refreshControl = self.refreshControl {
            self.tableView.addSubview(refreshControl)
        }
    }
    
    func endRefreshing() {
        self.refreshControl?.endRefreshing()
    }
}

extension Refreshable where Self: UIViewController {
    func configureRefreshControl(with title: String) {
        let views = self.view.subviews
        for view in views {
            if let scrollView = view as? UIScrollView {
                scrollView.refreshControl = UIRefreshControl()
                scrollView.refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
                if let refreshControl = scrollView.refreshControl {
                    scrollView.addSubview(refreshControl)
                }
            }
        }
    }
    
    func endRefreshing() {
        let views = self.view.subviews
        for view in views {
            if let scrollView = view as? UIScrollView {
                scrollView.refreshControl?.endRefreshing()
            }
        }
    }
}
