/*
Created by Harshada Deshmukh on 18/05/22.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Harshada Deshmukh
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

class SCWasteSelectionViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var clearAllButton: UIBarButtonItem!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var showEventsButton: SCCustomButton!
    @IBOutlet weak var selectAllButton: SCCustomButton!
    @IBOutlet weak var bottomSeparatorView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var selectAllButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var showEventsButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.hidesWhenStopped = true
        }
    }

    let font = UIFont.SystemFont.medium.forTextStyle(style: .body, size: 16, maxSize: 32)
    let cornerRadius: CGFloat = 4.0
    let leftRightPadding: CGFloat = 10
    let minimumInterItemSpacing: CGFloat = 16
    let borderWidth: CGFloat = 1

    let reuseIdentifier = "SelectionCollectionViewCell"
    var categoryItems: [SCModelCategoryObj] = []
    var selectedItems: [IndexPath] = []
    var expectedItemCount: Int = 0
    var presenter: SCWasteCategorySelectionPresenting!
    var selectionDelegate: SCWasteCategorySelectionDelegate!
    var isSelectAllButtonSelected: Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shouldNavBarTransparent = false
        self.showEventsButton.customizeCityColorStyle()
        self.selectAllButton.customizeCityColorStyleLight()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        stackView.axis = UIDevice.current.orientation.isLandscape ? .horizontal : .vertical
        let flowlayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowlayout?.estimatedItemSize = .zero
        self.presenter.setDisplay(display: self)
        self.presenter.viewDidLoad()
        
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        self.handleDynamicTypeChange()
        collectionView.register(UINib(nibName: "WasteCategoryCell", bundle: nil), forCellWithReuseIdentifier: "WasteCategoryCell")
        SCDataUIEvents.registerNotifications(for: self,
                                             on: UIContentSizeCategory.didChangeNotification,
                                             with: #selector(handleDynamicTypeChange))
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        stackView.axis = UIDevice.current.orientation.isLandscape ? .horizontal : .vertical
    }
    
    @objc private func handleDynamicTypeChange() {
        collectionView.reloadData()
        showEventsButton.titleLabel?.adjustsFontForContentSizeCategory = true
        showEventsButton.titleLabel?.font = UIFont.SystemFont.medium.forTextStyle(style: .body, size: 16, maxSize: 30)
        showEventsButton.titleLabel?.numberOfLines = 0
        let showEventsButtonHeight = showEventsButton.titleLabel?.text?.estimatedHeight(withConstrainedWidth: showEventsButton.frame.width, font: (showEventsButton.titleLabel?.font)!) ?? GlobalConstants.kWasteCalendarButtonHeight
        showEventsButtonHeightConstraint.constant = showEventsButtonHeight <= GlobalConstants.kWasteCalendarButtonHeight ? GlobalConstants.kWasteCalendarButtonHeight : showEventsButtonHeight
        
        selectAllButton.titleLabel?.adjustsFontForContentSizeCategory = true
        selectAllButton.titleLabel?.font = UIFont.SystemFont.medium.forTextStyle(style: .body, size: 16, maxSize: 30)
        selectAllButton.titleLabel?.numberOfLines = 0
        let selectAllButtonHeight = selectAllButton.titleLabel?.text?.estimatedHeight(withConstrainedWidth: selectAllButton.frame.width, font: (showEventsButton.titleLabel?.font)!) ?? GlobalConstants.kWasteCalendarButtonHeight
        selectAllButtonHeightConstraint.constant = selectAllButtonHeight <= GlobalConstants.kWasteCalendarButtonHeight ? GlobalConstants.kWasteCalendarButtonHeight : selectAllButtonHeight
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if selectedItems.count == collectionView.numberOfItems(inSection: 0) {
            self.selectAllButton.setTitle("wc_004_filter_category_deselect_all".localized(), for: .normal)
            isSelectAllButtonSelected = true
        } else {
            self.selectAllButton.setTitle("wc_004_filter_category_select_all".localized(), for: .normal)
            isSelectAllButtonSelected = false
        }

        if selectedItems.count == 0 {
            clearAllButton(isHidden: true)
        }
        
        self.refreshNavigationBarStyle()
        self.navigationItem.rightBarButtonItem?.tintColor = kColor_cityColor
        
    }

    private func setupAccessibilityIDs() {
        if self.clearAllButton != nil{
            self.clearAllButton.accessibilityIdentifier = "btn_clear_all"
        }
        self.closeButton.accessibilityIdentifier = "btn_close_selector"
        self.showEventsButton.accessibilityIdentifier = "btn_show_events"
        self.selectAllButton.accessibilityIdentifier = "btn_select_all_button"
    }
    
    private func setupAccessibility(){
        if self.clearAllButton != nil{
            self.clearAllButton.accessibilityTraits = .button
            self.clearAllButton.accessibilityLabel = "accessibility_btn_clear_all".localized()
            self.clearAllButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        }
        self.closeButton.accessibilityTraits = .button
        self.closeButton.accessibilityLabel = "accessibility_btn_close".localized()
        self.closeButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(completion: nil)
    }
    
    @IBAction func clearAllButtonTapped(_ sender: Any) {
        for indexPath in selectedItems {
            if let cell = self.collectionView.cellForItem(at: indexPath) {
                configureForNotSelectedState(cell: cell)
            }
        }
        self.navigationItem.rightBarButtonItem = nil
        self.selectedItems.removeAll()
        self.updateButtonStatus()
        selectAllButton.setTitle("wc_004_filter_category_select_all".localized(), for: .normal)
        isSelectAllButtonSelected = false
    }
    
    @IBAction func showEventsButtonTapped(_ sender: Any) {
        self.presenter.filterButtonWasPressed(filterCategories: prepareCategoryFilterArray(), expectedItemCount: expectedItemCount)
    }
    
    @IBAction func selectDeselectAll(_ sender: Any) {
        if isSelectAllButtonSelected {
            updateNotSelectedCategoriesData()
        } else {
           updateSelectedCategoriesData()
        }
    }
    
    func updateSelectedCategoriesData() {
        isSelectAllButtonSelected = true
        selectAllButton.setTitle("wc_004_filter_category_deselect_all".localized(), for: .normal)
        for item in 0...(collectionView.numberOfItems(inSection: 0) - 1) {
            let indexPath = IndexPath(row: item, section: 0)
            if let _ = self.collectionView.cellForItem(at: indexPath) {
                if !selectedItems.contains(indexPath) {
                    self.selectedItems.append(indexPath)
                    self.updateButtonStatus()
                }
            } else {
                if !selectedItems.contains(indexPath) {
                    self.selectedItems.append(indexPath)
                    self.updateButtonStatus()
                }
            }
        }
        collectionView.reloadData()
    }
    
    func updateNotSelectedCategoriesData() {
        isSelectAllButtonSelected = false
        selectAllButton.setTitle("wc_004_filter_category_select_all".localized(), for: .normal)
        for item in 0...(collectionView.numberOfItems(inSection: 0) - 1) {
            let indexPath = IndexPath(row: item, section: 0)
            if let cell = self.collectionView.cellForItem(at: indexPath) {
                self.configureForNotSelectedState(cell: cell)
            }
        }
        
        self.selectedItems.removeAll()
        self.updateButtonStatus()
        
        if collectionView.numberOfItems(inSection: 0) - collectionView.visibleCells.count > 0 {
            for row in 0...(collectionView.numberOfItems(inSection: 0) - collectionView.visibleCells.count) - 1 {
                
                let invisibleCellsIndexpath = IndexPath(row: collectionView.visibleCells.count + row, section: 0)
                collectionView.scrollToItem(at: invisibleCellsIndexpath, at: .top, animated: false)
                SCUtilities.delay(withTime: 0.01, callback: {
                    if let cell = self.collectionView.cellForItem(at: invisibleCellsIndexpath) {
                        self.configureForNotSelectedState(cell: cell)
                        self.updateButtonStatus()
                    }
                })
            }
        }
    }
    
    func configureForNotSelectedState(cell: UICollectionViewCell) {
        let label = cell.contentView.subviews[0] as? UILabel
        cell.backgroundColor = UIColor(named: "CLR_BCKGRND")!
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor(named: "CLR_BORDER_DARKGRAY")!.cgColor
        label?.textColor = UIColor(named: "CLR_LABEL_TEXT_BLACK")!
        
    }
    
    func configureForSelectedState(cell: UICollectionViewCell) {
        let label = cell.contentView.subviews[0] as? UILabel
        cell.backgroundColor = kColor_cityColor
        cell.layer.borderWidth = 0.0
        label?.textColor = UIColor(named: "CLR_LABEL_TEXT_WHITE")!
    }
    
    func prepareCategoryFilterArray() -> [SCModelCategoryObj]{
        var filterArray: [SCModelCategoryObj] = []
        for indexPath in selectedItems {
            filterArray.append(categoryItems[indexPath.row])
        }
        return filterArray
    }
    
    func preparePreselectedItems(preselectedItems: [SCModelCategoryObj]?) {
        guard let preselectedItems = preselectedItems else {
            self.updateButtonStatus()
            return
            
        }
        for category in preselectedItems {
            if let index = categoryItems.firstIndex(where: { $0.name ==  category.name }) {
                self.selectedItems.append(IndexPath(row: index, section: 0))
            }
        }
        self.updateButtonStatus()
    }
    
    func getRightBarButtonItem() -> UIBarButtonItem {
        let rightBarButtonItem = UIBarButtonItem(title: "e_004_events_filter_categories_clear".localized(), style: .plain, target: self, action: #selector(clearAllButtonTapped(_:)))
        rightBarButtonItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.SystemFont.medium.forTextStyle(style: .body, size: 16, maxSize: 24)], for: .normal)
        rightBarButtonItem.tintColor = kColor_cityColor
        return rightBarButtonItem
    }
    
}

extension SCWasteSelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categoryItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = categoryItems[indexPath.row]
        guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "WasteCategoryCell", for: indexPath) as? WasteCategoryCell else {
            return UICollectionViewCell()
        }
        cell.cellLabel.text = item.name
        cell.layer.cornerRadius = cornerRadius
        cell.cellLabel.font = font
        cell.cellLabel.sizeToFit()
        cell.cellLabel.textAlignment = .center
        cell.cellLabel.textColor = UIColor(named: "CLR_LABEL_TEXT_BLACK")!
        cell.cellLabel.accessibilityTraits = .button
        cell.cellLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        if !selectedItems.contains(indexPath) {
            cell.cellLabel.accessibilityLabel =  LocalizationKeys.SCWasteSelectionViewController.accessibilityLabelPickupReadStateNotSelected.localized().replacingLastOccurrenceOfString("%s", with: item.name).replaceStringFormatter()
        } else {
            cell.cellLabel.accessibilityLabel =  LocalizationKeys.SCWasteSelectionViewController.accessibilityLabelPickupReadStateSelected.localized().replacingLastOccurrenceOfString("%s", with: item.name).replaceStringFormatter()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if selectedItems.contains(indexPath) {
            configureForSelectedState(cell: cell)
        } else {
            configureForNotSelectedState(cell: cell)
        }
    }
    
}

extension SCWasteSelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            let label = cell.contentView.subviews[0] as? UILabel
            let item: SCModelCategoryObj = self.categoryItems[indexPath.row]
            label?.accessibilityTraits = .button
            if selectedItems.contains(indexPath) {
                configureForNotSelectedState(cell: cell)
                selectedItems.remove(at: selectedItems.firstIndex(of: indexPath)!)
                selectAllButton.setTitle("wc_004_filter_category_select_all".localized(), for: .normal)
                isSelectAllButtonSelected = false
                //self.presenter.removeSelectedItem()
                label?.accessibilityLabel =  LocalizationKeys.SCWasteSelectionViewController.accessibilityLabelPickupChangeStateDeSelect.localized().replacingLastOccurrenceOfString("%s", with: item.name).replaceStringFormatter()
            } else {
                configureForSelectedState(cell: cell)
                selectedItems.append(indexPath)
                if selectedItems.count == collectionView.numberOfItems(inSection: 0) {
                    self.selectAllButton.setTitle("wc_004_filter_category_deselect_all".localized(), for: .normal)
                    isSelectAllButtonSelected = true
                }
                //self.presenter.addSelectedItem()
                label?.accessibilityLabel =  LocalizationKeys.SCWasteSelectionViewController.accessibilityLabelPickupChangeStateSelect.localized().replacingLastOccurrenceOfString("%s", with: item.name).replaceStringFormatter()
            }
            label?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        }
        self.updateButtonStatus() // move to displaying protocol
    }
}

extension SCWasteSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //calculate the size
        let item: SCModelCategoryObj = self.categoryItems[indexPath.row]
        let cellPadding: CGFloat = 10.0
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = font
        label.adaptFontSize()
        label.text = item.name
        label.sizeToFit()
        let labelSize = label.frame.size
        let labelWidth = min(labelSize.width + cellPadding,
                             UIScreen.main.bounds.width - 36)
        let cellSize = CGSize(width: labelWidth,
                              height: calculateLabelHeight(for: indexPath, width: labelWidth))
        return cellSize
    }
    
    private func calculateLabelHeight(for indexPath: IndexPath, width: CGFloat) -> CGFloat {
        // Implement your own logic to calculate the height based on label content
        // You can use the indexPath to fetch the relevant data for the label
        
        // Example: Set a default height and adjust based on the label's content
        let item: SCModelCategoryObj = self.categoryItems[indexPath.row]
        let defaultHeight: CGFloat = 35
        let labelContent = item.name // Replace with your own label content
        
        // Calculate the height based on the label's content
        let labelWidth: CGFloat = width // Adjust the width based on your desired label width
        let labelFont = font // Replace with your desired font
        
        let labelSize = CGSize(width: labelWidth, height: .greatestFiniteMagnitude)
        let labelOptions = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedLabelHeight = NSString(string: labelContent).boundingRect(
            with: labelSize,
            options: labelOptions,
            attributes: [NSAttributedString.Key.font: labelFont],
            context: nil
        ).height
        return max(defaultHeight, estimatedLabelHeight) + 10.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: leftRightPadding, bottom: 0, right: leftRightPadding)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16.0
    }
}

extension SCWasteSelectionViewController: SCWasteSelectionDisplaying {
        
    func setupUI(title: String) {

        self.navigationItem.title = title
        self.navigationItem.rightBarButtonItem?.title = "e_004_events_filter_categories_clear".localized()
        self.bottomSeparatorView.backgroundColor = UIColor(named: "CLR_BORDER_COOLGRAY")!
        self.topSeparatorView.backgroundColor = UIColor(named: "CLR_BORDER_COOLGRAY")!
        self.collectionView.contentInset = UIEdgeInsets(top: 29.0, left: 0.0, bottom: 0.0, right: 0.0)
        self.view.bringSubviewToFront(self.topSeparatorView)
    }

    func setTitleForShowEventsButton(title: String) {
        self.showEventsButton.setTitle(title, for: .normal)
    }
    
    func clearAllButton(isHidden: Bool) {
        self.navigationItem.rightBarButtonItem = isHidden ? nil : self.getRightBarButtonItem()
    }
    
    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }
    
    func updateButtonStatus() {
        let filterArray = prepareCategoryFilterArray()
        self.presenter.filterCategoriesChanged(filterCategories: filterArray)
    }
    
    func setProgressStateToFilterEventsButton() {
        self.showEventsButton.btnState = .progress
    }
    
    func setNormalStateToFilterEventsButton() {
        self.showEventsButton.btnState = .normal
    }
    
    func updateCategories(categories: [SCModelCategoryObj], preselectedItems: [SCModelCategoryObj]?) {
        // Will sort categories with acsending order
        self.categoryItems = categories.sorted(by: {
            $0.name.lowercased() < $1.name.lowercased()
        })
        self.preparePreselectedItems(preselectedItems: preselectedItems)
        self.collectionView.reloadData()
    }
    
    func startActivityIndicator() {
        activityIndicator.startAnimating()
    }

    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func hideUnhideSelectAllButton(isHidden: Bool) {
        self.selectAllButton.isHidden = isHidden
    }
}

