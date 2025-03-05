/*
Created by A118572539 on 30/12/21.
Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, A118572539
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

protocol SCColorSelectionDelegate: NSObject {
    func selectedColor(color: UIColor, name: String)
}

class SCCalendarGenericTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var presenter: SCCalendarGenericTableViewPresenting!
    var showImageIndex : IndexPath?
    
    override func viewDidLoad() {
        presenter.setDisplay(self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor.clear
        setupAccessibility()
        setupAccessibilityIDs()
        self.handleDynamicTypeChange()
        SCDataUIEvents.registerNotifications(for: self,
                                             on: UIContentSizeCategory.didChangeNotification,
                                             with: #selector(handleDynamicTypeChange))
    }
    
    private func setupAccessibilityIDs() {
        navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    private func setupAccessibility() {
        navigationItem.rightBarButtonItem?.accessibilityTraits = .button
        navigationItem.rightBarButtonItem?.accessibilityLabel = LocalizationKeys.SCWasteCalendarViewController.accessibilityBtnExportCalendar.localized()
        navigationItem.rightBarButtonItem?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
    
    @objc private func handleDynamicTypeChange() {
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshNavigationBarStyle()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        self.navigationItem.title = LocalizationKeys.SCCalendarGenericTableViewController.wc006CalendarColour.localized()
        let backButton = UIBarButtonItem()
        backButton.title = LocalizationKeys.Common.navigationBarBack.localized()
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor.calendarColor
            appearance.shadowColor = .clear
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            // Fallback on earlier versions
        }
    }
}

extension SCCalendarGenericTableViewController: SCCalendarGenericTableViewDisplaying {
    func setupUI(title: String, backTitle: String) {
        
    }
    
    func push(viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }

    func present(viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
}

extension SCCalendarGenericTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return LocalizationKeys.SCCalendarGenericTableViewController.wc006Colour.localized()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getTableViewItems().count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SCColorOptionCell", for: indexPath) as! SCColorOptionCell
        cell.colorTitleLabel.text = presenter.getTableViewItems()[indexPath.row]
        cell.colorButton.layer.cornerRadius = cell.colorButton.bounds.size.height / 2.0
        cell.colorButton.layer.backgroundColor = colorFromColorName(name: presenter.getTableViewItems()[indexPath.row]).cgColor
        cell.colorButton.clipsToBounds = true
        if presenter.getSelectedColorName() == presenter.getTableViewItems()[indexPath.row] {
            cell.rightImageView.isHidden = false
            cell.rightImageView.image = UIImage(named: "checkmark")
            showImageIndex = indexPath
            cell.accessibilityValue = "accessibility_hint_state_selected".localized()
        } else {
            cell.accessibilityHint = "accessibility_double_tap_select_hint".localized()
            cell.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        }
        // Accessbility
        cell.accessibilityTraits = .button
        cell.accessibilityLabel = cell.colorTitleLabel?.text
        cell.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let imageIndexPath = showImageIndex, let cell = tableView.cellForRow(at: imageIndexPath) as? SCColorOptionCell {
            cell.rightImageView.isHidden = true
        }
        
        showImageIndex = indexPath
        
        if let cell = tableView.cellForRow(at: indexPath) as? SCColorOptionCell {
            cell.colorButton.layer.backgroundColor = colorFromColorName(name: presenter.getTableViewItems()[indexPath.row]).cgColor
            cell.rightImageView.isHidden = false
            cell.rightImageView.image = UIImage(named: "checkmark")
            self.presenter?.colorSelected(with: colorFromColorName(name: cell.colorTitleLabel.text ?? "Blue"), name: cell.colorTitleLabel.text ?? "Blue")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.adaptFontSize()
            header.textLabel?.adjustsFontForContentSizeCategory = true
            header.textLabel?.font = UIFont.SystemFont.bold.forTextStyle(style: .title1, size: 13, maxSize: 25)
            header.backgroundColor = .calendarColor
        }
    }
}

extension SCCalendarGenericTableViewController {
    
    func colorFromColorName(name: String) -> UIColor {
        let colorName = name.capitalized
        switch colorName {
        case LocalizationKeys.SCExportEventOptionsViewPresenter.wc006RedColor.localized():
            return UIColor.systemRed
        case LocalizationKeys.SCExportEventOptionsViewPresenter.wc006OrangeColor.localized():
            return UIColor.systemOrange
        case LocalizationKeys.SCExportEventOptionsViewPresenter.wc006YellowColor.localized():
            return UIColor.systemYellow
        case LocalizationKeys.SCExportEventOptionsViewPresenter.wc006GreenColor.localized():
            return UIColor.systemGreen
        case LocalizationKeys.SCExportEventOptionsViewPresenter.wc006BlueColor.localized():
            return UIColor.systemBlue
        case LocalizationKeys.SCExportEventOptionsViewPresenter.wc006PurpleColor.localized():
            return UIColor.systemPurple
        case LocalizationKeys.SCExportEventOptionsViewPresenter.wc006BrownColor.localized():
            if #available(iOS 13.0, *) {
                return UIColor.systemBrown
            } else {
                return UIColor.brown
            }
        default:
            return UIColor.systemBlue
        }
    }
}
