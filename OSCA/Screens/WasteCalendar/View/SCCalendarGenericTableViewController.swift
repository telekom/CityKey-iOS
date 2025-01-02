//
//  CalendarGenericTableViewController.swift
//  OSCA
//
//  Created by A118572539 on 30/12/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
