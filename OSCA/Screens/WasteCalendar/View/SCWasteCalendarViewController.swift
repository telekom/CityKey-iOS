/*
Created by Michael on 27.08.20.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

class SCWasteCalendarViewController: UIViewController {

    @IBOutlet weak var wasteCalendarTableView: UITableView!
    
    var presenter: SCWasteCalendarPresenting!
    private var dataSource: SCWasteCalendarDataSource!
    private var calendarView : CalendarView?
    private var wasteCalendarItems: [SCModelWasteCalendarItem]?
    private var filterView: SCFilterView?
    private var filterCategories: [String] = []
    private var label: UILabel?
    @IBOutlet weak var infoOverlayView: UIView!
    var backbutton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        self.addCalendarView()
        self.hideInfoOverlay()
        presenter.setDisplay(self)
        presenter.viewDidLoad()
        setupAccessibilityIDs()
        setupAccessibility()
        handleDynamicTypeChange()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleDynamicTypeChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }
    
    private func setupTableView() {
        registerCell()
        wasteCalendarTableView.contentInset = UIEdgeInsets(top: 0,
                                                           left: 0,
                                                           bottom: 50,
                                                           right: 0)
    }

    @objc private func handleDynamicTypeChange() {
        backbutton?.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: 24)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: { [weak self] in
            //Enable View's for accessbility
            self?.updateAccessbiltiyElements(isHidden: false)
            UIAccessibility.setFocusTo(self?.backbutton)
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }

    private func setupAccessibilityIDs() {
        navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    private func setupAccessibility() {
        navigationItem.rightBarButtonItem?.accessibilityTraits = .button
        navigationItem.rightBarButtonItem?.accessibilityLabel = LocalizationKeys.SCWasteCalendarViewController.accessibilityBtnExportCalendar.localized()
        navigationItem.rightBarButtonItem?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        setupCategoryContainerViewAccessibility()
        setupAddressContainerViewAccessibility()
        //disable View's for accessbility
        updateAccessbiltiyElements(isHidden: true)
    }
    
    // enable/disable views accessibility until the viewDidAppear is called
    private func updateAccessbiltiyElements(isHidden: Bool) {
        navigationController?.navigationBar.accessibilityElementsHidden = isHidden
        view.accessibilityElementsHidden = isHidden
        filterView?.accessibilityElementsHidden = isHidden
        calendarView?.accessibilityElementsHidden = isHidden
    }
    
    private func setupCategoryContainerViewAccessibility() {
        filterView?.categoryContainerView.accessibilityLabel = LocalizationKeys.SCWasteCalendarViewController.wc004PickupsFilterBtn.localized() + (filterView?.categoryLabel.text ?? "")
        filterView?.categoryContainerView.accessibilityTraits = .button
        filterView?.categoryContainerView.accessibilityHint = "accessibility_btn_tap_hint".localized() + "accessibility_filter_categories".localized()
        filterView?.categoryContainerView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
    
    private func setupAddressContainerViewAccessibility() {
        filterView?.addressContainerView.accessibilityLabel = LocalizationKeys.SCWasteCalendarViewController.wc004AddressFilterBtn.localized() + (filterView?.addressLabel.text ?? "")
        filterView?.addressContainerView.accessibilityTraits = .button
        filterView?.addressContainerView.accessibilityHint = "accessibility_btn_tap_hint".localized() + "accessibility_change_address".localized()
        filterView?.addressContainerView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
    
    private func addCalendarView() {
        guard let filterView = SCFilterView.getView() else {
            return
        }

        let headerView = UIView()
        headerView.backgroundColor = .clearBackground
        filterView.translatesAutoresizingMaskIntoConstraints = false
        filterView.delegate = self
        self.filterView = filterView
        headerView.addSubview(filterView)
        self.view.addSubview(headerView)

        filterView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 21).isActive = true
        filterView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -21).isActive = true
        filterView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 15).isActive = true
        filterView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -15).isActive = true

        wasteCalendarTableView.tableHeaderView = headerView
        wasteCalendarTableView.tableFooterView = UIView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let headerView = wasteCalendarTableView.tableHeaderView {
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var headerFrame = headerView.frame

            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                wasteCalendarTableView.tableHeaderView = headerView
            }
        }
    }

    private func registerCell() {
        let cellName = String(describing: SCWasteCalendarTableViewCell.self)
        let cellNib = UINib(nibName: cellName, bundle: nil)
        wasteCalendarTableView.register(cellNib, forCellReuseIdentifier: cellName)
        
        let headerCellName = String(describing: SCWasteCalendarTableViewHeaderCell.self)
        let headerCellNib = UINib(nibName: headerCellName, bundle: nil)
        wasteCalendarTableView.register(headerCellNib, forCellReuseIdentifier: headerCellName)

    }

    private func setDataSource(wasteCalendarItems: [SCModelWasteCalendarItem], wasteReminders: [SCHttpModelWasteReminder]) {
        dataSource = SCWasteCalendarDataSource(wasteCalendarItems: wasteCalendarItems, delegate: self, wasteReminders: wasteReminders)
        wasteCalendarTableView.dataSource = dataSource
        wasteCalendarTableView.delegate = dataSource
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        wasteCalendarTableView.reloadSections(IndexSet(0..<1), with: .automatic)
    }
    
    private func addBannerForNoRows(with text: String) {
        let calendarHeight = dataSource.getCalendarHeight(superViewWidth: wasteCalendarTableView.bounds.width)
        let centreY = UIDevice.current.orientation.isLandscape ? ((Float(UIScreen.main.bounds.height * 2))) : ((Float(UIScreen.main.bounds.height) -  Float(calendarHeight))/2.0) + Float(calendarHeight) - 25.0
        self.label = UILabel(frame: CGRect(x: 0.0, y: CGFloat(centreY), width: UIScreen.main.bounds.width, height: 50))
        wasteCalendarTableView.addSubview(self.label!)
        label?.text = text
        label?.numberOfLines = 0
        label?.textAlignment = .center
        wasteCalendarTableView.addSubview(self.label!)
    }
    
    private func updateBannerlabelText() {
        guard dataSource.tableView(wasteCalendarTableView, numberOfRowsInSection: 0) == 0 else {
            label?.removeFromSuperview()
            label = nil
            return
        }
        
        switch filterCategories.count {
        case 0:
            if let label = label {
                label.text = LocalizationKeys.SCWasteCalendarViewController.wc004FilterCategoryEmpty.localized()
                break
            }
            
            addBannerForNoRows(with: LocalizationKeys.SCWasteCalendarViewController.wc004FilterCategoryEmpty.localized())
            break
        case 1:
            if let label = label {
                label.text = LocalizationKeys.SCWasteCalendarViewController.wc004FilterCategoryEmptyData.localized()
                break
            }
            
            addBannerForNoRows(with: LocalizationKeys.SCWasteCalendarViewController.wc004FilterCategoryEmptyData.localized())
            break
        default:
            if let label = label {
                label.text = LocalizationKeys.SCWasteCalendarViewController.wc004FilterMultipleCategoryEmptyData.localized()
                break
            }
            
            addBannerForNoRows(with: LocalizationKeys.SCWasteCalendarViewController.wc004FilterMultipleCategoryEmptyData.localized())
            break
        }
    }
    
    @objc func addToCalendarTapped() {
        SCCalendarHelper.shared.askForPermissions { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.presenter.didTapExportWasteTypes(for: weakSelf.dataSource.getFilteredWastCalendarData())
        }
    }
    
    private func setNavBarButtons(backTitle: String) {
        navigationItem.hidesBackButton = true
        backbutton = UIButton(type: .system)
        backbutton?.setTitle(backTitle, for: .normal)
        backbutton?.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: 24)
        backbutton?.setImage(UIImage(named: "icon_nav_back"), for: .normal)
        backbutton?.imageEdgeInsets = UIEdgeInsets(top: 2, left: -8, bottom: 0, right: 2)
        backbutton?.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        let backBarButton = UIBarButtonItem(customView: backbutton!)
        navigationItem.leftBarButtonItem = backBarButton
    }
    
    @objc func backButtonPressed() {
        guard let navigationController = self.navigationController else { return }
        if navigationController.containsViewController(ofKind: SCWasteAddressViewController.self) {
            var navigationArray = navigationController.viewControllers
            let temp = navigationArray.last
            navigationArray.removeAll()
            navigationArray.append(temp!)
            self.navigationController?.viewControllers = navigationArray
            self.navigationController?.dismiss(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        wasteCalendarTableView.reloadSections(IndexSet(0..<1), with: .automatic)
        dataSource.calendarView?.reloadData(Date())
        label?.removeFromSuperview()
        label = nil
        updateBannerlabelText()
    }
}

extension SCWasteCalendarViewController: SCWasteCalendarDisplaying {
    func setupUI(title: String, backTitle: String) {
        navigationItem.title = title
        setNavBarButtons(backTitle: backTitle)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_add_to_calendar"), landscapeImagePhone: UIImage(named: "icon_add_to_calendar"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(addToCalendarTapped))
        wasteCalendarTableView.rowHeight = UITableView.automaticDimension

        self.filterView?.categoryPlaceholder.text = LocalizationKeys.SCWasteCalendarViewController.wc004PickupsFilterBtn.localized()
        filterView?.addressPlaceholder.text = LocalizationKeys.SCWasteCalendarViewController.wc004AddressFilterBtn.localized()
    }

    func push(viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }

    func present(viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }

    func updateWasteCalendarItems(_ wasteCalendarItems: [SCModelWasteCalendarItem], wasteReminders: [SCHttpModelWasteReminder]) {
        self.wasteCalendarItems = wasteCalendarItems
        if self.dataSource != nil {
            self.dataSource.updateDataSource(wasteCalendarItems:(wasteCalendarItems), wasteReminders: wasteReminders)
        } else {
            self.setDataSource(wasteCalendarItems: wasteCalendarItems, wasteReminders: wasteReminders)
        }
        dataSource.updateCalendar(calendarItems: wasteCalendarItems)
        wasteCalendarTableView.reloadData()
    }

    func updateDataSource(wasteReminders: [SCHttpModelWasteReminder]) {
        self.dataSource.update(wasteReminders: wasteReminders)
        wasteCalendarTableView.reloadData()
    }

    func updateCategoryFilterName(_ name : String, color : UIColor) {
        self.filterView?.categoryLabel.text = name
        self.filterView?.categoryLabel.textColor = color
        setupCategoryContainerViewAccessibility()
    }
    
    func updateAddress(street: String?) {
        filterView?.addressLabel.text = street
        setupAddressContainerViewAccessibility()
    }

    func updateFilterCategories(_ categories : [String]?) {
        self.filterCategories = categories ?? []
        if dataSource.updateFilterCategorieshIFNeeded(categories) {
            wasteCalendarTableView.reloadData()
        }
        
        updateBannerlabelText()
    }

    /**
     *
     * This Methods willshow  infoOverlay status informations
     *
     */
    func showActivityInfoOverlay() {
        self.infoOverlayView.isHidden = false
        self.wasteCalendarTableView.isHidden = true
        self.showActivityOverlay(on: self.infoOverlayView)
    }

    func showErrorInfoOverlay() {
        self.infoOverlayView.isHidden = false
        self.wasteCalendarTableView.isHidden = true
        self.showText(on: self.infoOverlayView, text: LocalizationKeys.SCWasteCalendarViewController.dialogTechnicalErrorMessage.localized(), title: nil, textAlignment: .center)
    }

    func hideInfoOverlay() {
        self.infoOverlayView.isHidden = true
        self.wasteCalendarTableView.isHidden = false
        self.hideOverlay(on: self.infoOverlayView)
    }
}

extension SCWasteCalendarViewController: SCWasteCalendarDataSouceDelegate {

    func didSwitchToMonthValue(_ monthValue: Int){
        if  dataSource.updateFilterMonthIFNeeded(monthValue){
            wasteCalendarTableView.reloadData()
        }
        
        updateBannerlabelText()
    }

    func selected(date: SCCalendarDate) {
        if let index =  self.dataSource.indexPathForDataBaseString(String(date.dayValue)) {
            self.wasteCalendarTableView.scrollToRow(at: index, at: .top, animated: true)
        }
    }

    func selected(wasteType: SCWasteCalendarDataSourceItem) {
        presenter?.displayReminderSettingFor(wasteType: wasteType, delegate: self)
    }
    
    func scrollToNextMonth() {
        self.dataSource.calendarView?.scrollToNextMonth()
    }
}


extension SCWasteCalendarViewController: SCFilterViewDelegate {

    func didTapOnAddress() {
        presenter.didTapOnAddress(delegate: self)
    }

    func didTapOnCategory() {
        self.presenter?.didTapOnCategoryFilter()
    }
}

extension SCWasteCalendarViewController: SCWasteAddressViewResultDelegate {

    func setWasteCalendar(items: [SCModelWasteCalendarItem], address: SCModelWasteCalendarAddress, wasteReminders: [SCHttpModelWasteReminder]) {
        presenter?.update(address: address)
        presenter?.update(reminders: wasteReminders)
        presenter.updateWasteCalendarItems(items)
        updateWasteCalendarItems(items, wasteReminders: wasteReminders)
        self.presenter.didTapOnCategoryFilter()
    }
}

extension SCWasteCalendarViewController: SCWasteReminderResultDelegate {

    func update(settings: SCHttpModelWasteReminder?, worker: SCWasteReminderWorking) {
        presenter?.setReminder(worker: worker, settings: settings)
    }
}
