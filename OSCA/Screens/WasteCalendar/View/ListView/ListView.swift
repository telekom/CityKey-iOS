/*
Created by Rutvik Kanbargi on 11/09/20.
Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Rutvik Kanbargi
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

protocol SCListViewDelegate: AnyObject {
    func didSelect(item: String, component: SCListView)
    func didScroll(component: SCListView)
}

class SCListView: UIView, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    private let tableView: UITableView
    private var items: [String]

    private weak var delegate: SCListViewDelegate?

    init(items: [String], frame: CGRect, delegate: SCListViewDelegate?) {
        self.items = items
        self.delegate = delegate
        tableView = UITableView()
        super.init(frame: frame)
        setupTableView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "SCListTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SCListTableViewCell")
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none

        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        tableView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
    }

    func update(items: [String]) {
        self.items = items
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SCListTableViewCell.self), for: indexPath) as? SCListTableViewCell else {
            return UITableViewCell()
        }
        cell.itemNameLabel.text = items[indexPath.row]
        cell.itemNameLabel.adjustsFontForContentSizeCategory = true
        cell.itemNameLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: 30)
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelect(item: items[indexPath.row], component: self)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.didScroll(component: self)
    }
}
