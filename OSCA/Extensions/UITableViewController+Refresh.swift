/*
Created by Alexander Lichius on 03.09.19.
Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Alexander Lichius
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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
