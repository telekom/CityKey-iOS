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
import Kingfisher

class SCNewsOverviewTableViewController: UITableViewController {
    
    public var presenter: SCNewsOverviewPresenting!

    private var items = [SCBaseComponentItem]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        tableView.prefetchDataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.presenter.viewWillAppear()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
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


    private func setupUI() {
        tableView.estimatedRowHeight = GlobalConstants.kNewsListRowHeight
        tableView.rowHeight = UITableView.automaticDimension
        navigationItem.backButtonTitle = LocalizationKeys.Common.navigationBarBack.localized()
        navigationItem.title = LocalizationKeys.SCNewsOverviewTableViewController.h001HomeTitleNews.localized()
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
        let cell: SCNewsOverviewTableViewCell = tableView.dequeueReusableCell(withIdentifier: "NewsOverviewMessageCell", for: indexPath) as! SCNewsOverviewTableViewCell
        
        //adaptive Font Size
        cell.newsCellTitleLabel?.adaptFontSize()
        cell.newsCellLabel?.adaptFontSize()

        let title = items[indexPath.row].itemTitle
        let teaser = items[indexPath.row].itemTeaser
        // Configure the cell...
        cell.newsCellTitleLabel?.text = items[indexPath.row].itemTitle
        cell.newsCellLabel.attributedText = teaser?.applyHyphenation()
        cell.newsCellImageView.image = UIImage(named: items[indexPath.row].itemThumbnailURL!.absoluteUrlString())
        
        cell.newsCellLabel.accessibilityElementsHidden = true
        cell.newsCellTitleLabel.accessibilityElementsHidden = true
        cell.newsCellImageView.accessibilityElementsHidden = true
        
        let accItemString = String(format:LocalizationKeys.SCNewsOverviewTableViewController.AccessibilityTableSelectedCell.localized().replaceStringFormatter(), String(indexPath.row + 1), String(items.count))
        cell.accessibilityTraits = .staticText
        cell.accessibilityHint = LocalizationKeys.SCNewsOverviewTableVC.accessibilityCellDblClickHint.localized()
        cell.accessibilityLabel = accItemString + ", " + (teaser ?? "") + ", " + title
        cell.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        cell.isAccessibilityElement = true
        
        cell.newsCellLabel.adjustsFontForContentSizeCategory = true
        cell.newsCellLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 17, maxSize: nil)
        cell.newsCellTitleLabel.adjustsFontForContentSizeCategory = true
        cell.newsCellTitleLabel.font = UIFont.SystemFont.medium.forTextStyle(style: .footnote, size: 12, maxSize: nil)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = self.items[indexPath.row]
        
        self.presenter.didSelectListItem(item: item)
    }
}

extension SCNewsOverviewTableViewController: UITableViewDataSourcePrefetching {

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let itemURLs = items.compactMap {
            $0.itemThumbnailURL?.absoluteUrl()
        }

        PrefetchNetworkImages.prefetchImagesFromNetwork(with: itemURLs)
    }
}

extension SCNewsOverviewTableViewController: SCNewsOverviewDisplaying {
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

    func updateNews(with dataItems: [SCBaseComponentItem]) {
        self.items = dataItems
        self.tableView.reloadData()
    }
}
