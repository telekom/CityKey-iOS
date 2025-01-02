//
//  SCSelectionCollectionViewController.swift
//  SmartCity
//
//  Created by Alexander Lichius on 10.10.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

enum ControllerSource {
    case WasteFilter
    case EventsFilter
}

class SCSelectionViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var clearAllButton: UIBarButtonItem!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var showEventsButton: SCCustomButton!
    @IBOutlet weak var selectAllButton: SCCustomButton!
    @IBOutlet weak var bottomSeparatorView: UIView!
    @IBOutlet weak var topSeparatorView: UIView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.hidesWhenStopped = true
        }
    }

    let font = UIFont.systemFont(ofSize: 16)
    let cornerRadius: CGFloat = 4.0
    let leftRightPadding: CGFloat = 10
    let minimumInterItemSpacing: CGFloat = 16
    let borderWidth: CGFloat = 1

    let reuseIdentifier = "SelectionCollectionViewCell"
    var categoryItems: [SCModelCategory] = []
    var selectedItems: [IndexPath] = []
    var expectedItemCount: Int = 0
    var presenter: SCCategorySelectionPresenting!
    var selectionDelegate: SCCategorySelectionDelegate!
    var isSelectAllButtonSelected: Bool = false
    public var sourceFlow: ControllerSource?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shouldNavBarTransparent = false
        self.showEventsButton.customizeCityColorStyle()
        self.selectAllButton.customizeCityColorStyleLight()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        let flowlayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowlayout?.estimatedItemSize = .zero
        self.presenter.setDisplay(display: self)
        self.presenter.viewDidLoad()
        
        self.setupAccessibilityIDs()
        self.setupAccessibility()

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
        // Saving the filter used for waste calendar
        if sourceFlow == .WasteFilter {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(prepareCategoryFilterArray()){
                UserDefaults.standard.set(encoded, forKey: presenter.getCityName())
            }
        }

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
        for item in 0...(collectionView.visibleCells.count - 1) {
            let indexPath = IndexPath(row: item, section: 0)
            if let cell = self.collectionView.cellForItem(at: indexPath) {
                self.configureForSelectedState(cell: cell)
                if !selectedItems.contains(indexPath) {
                    self.selectedItems.append(indexPath)
                    self.updateButtonStatus()
                }
            }
        }
        
        if collectionView.numberOfItems(inSection: 0) - collectionView.visibleCells.count > 0 {
            for row in 0...(collectionView.numberOfItems(inSection: 0) - collectionView.visibleCells.count) - 1 {
                let invisibleCellsIndexpath = IndexPath(row: collectionView.visibleCells.count + row, section: 0)
                collectionView.scrollToItem(at: invisibleCellsIndexpath, at: .top, animated: false)
                SCUtilities.delay(withTime: 0.01, callback: {
                    if let cell = self.collectionView.cellForItem(at: invisibleCellsIndexpath) {
                        self.configureForSelectedState(cell: cell)
                        if !self.selectedItems.contains(invisibleCellsIndexpath) {
                            self.selectedItems.append(invisibleCellsIndexpath)
                        }
                        self.updateButtonStatus()
                    }
                })
            }
        }
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
    
    func prepareCategoryFilterArray() -> [SCModelCategory]{
        var filterArray: [SCModelCategory] = []
        for indexPath in selectedItems {
            filterArray.append(categoryItems[indexPath.row])
        }
        return filterArray
    }
    
    func preparePreselectedItems(preselectedItems: [SCModelCategory]?) {
        guard let preselectedItems = preselectedItems else {
            self.updateButtonStatus()
            return
            
        }
        for category in preselectedItems {
            if let index = categoryItems.firstIndex(where: { $0.categoryName ==  category.categoryName }) {
                self.selectedItems.append(IndexPath(row: index, section: 0))
            }
        }
        self.updateButtonStatus()
    }
    
    func getRightBarButtonItem() -> UIBarButtonItem {
        let rightBarButtonItem = UIBarButtonItem(title: "e_004_events_filter_categories_clear".localized(), style: .plain, target: self, action: #selector(clearAllButtonTapped(_:)))
        rightBarButtonItem.tintColor = kColor_cityColor
        return rightBarButtonItem
    }
    
}

extension SCSelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categoryItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = categoryItems[indexPath.row]
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let cellLabel: UILabel
        if let label = cell.contentView.subviews.first as? UILabel { cellLabel = label } else {
            cellLabel = UILabel()
        }
        cellLabel.text = item.categoryName
        cellLabel.font = font
        cellLabel.textColor = UIColor(named: "CLR_LABEL_TEXT_BLACK")!
        cellLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(cellLabel)
        cell.layer.cornerRadius = cornerRadius
        cellLabel.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor).isActive = true
        cellLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
        cellLabel.accessibilityTraits = .button
        if !selectedItems.contains(indexPath) {
            cellLabel.accessibilityLabel =  LocalizationKeys.SCWasteSelectionViewController.accessibilityLabelPickupReadStateNotSelected.localized().replacingLastOccurrenceOfString("%s", with: item.categoryName).replaceStringFormatter()
        } else {
            cellLabel.accessibilityLabel =  LocalizationKeys.SCWasteSelectionViewController.accessibilityLabelPickupReadStateSelected.localized().replacingLastOccurrenceOfString("%s", with: item.categoryName).replaceStringFormatter()
        }
        cellLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
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

extension SCSelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            let label = cell.contentView.subviews[0] as? UILabel
            let item: SCModelCategory = self.categoryItems[indexPath.row]
            label?.accessibilityTraits = .button
            if selectedItems.contains(indexPath) {
                configureForNotSelectedState(cell: cell)
                selectedItems.remove(at: selectedItems.firstIndex(of: indexPath)!)
                selectAllButton.setTitle("wc_004_filter_category_select_all".localized(), for: .normal)
                isSelectAllButtonSelected = false
                //self.presenter.removeSelectedItem()
                label?.accessibilityLabel =  LocalizationKeys.SCWasteSelectionViewController.accessibilityLabelPickupChangeStateDeSelect.localized().replacingLastOccurrenceOfString("%s", with: item.categoryName).replaceStringFormatter()
            } else {
                configureForSelectedState(cell: cell)
                selectedItems.append(indexPath)
                if selectedItems.count == collectionView.numberOfItems(inSection: 0) {
                    self.selectAllButton.setTitle("wc_004_filter_category_deselect_all".localized(), for: .normal)
                    isSelectAllButtonSelected = true
                }
                //self.presenter.addSelectedItem()
                label?.accessibilityLabel =  LocalizationKeys.SCWasteSelectionViewController.accessibilityLabelPickupChangeStateSelect.localized().replacingLastOccurrenceOfString("%s", with: item.categoryName).replaceStringFormatter()
            }
            label?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        }
        self.updateButtonStatus() // move to displaying protocol
    }
}

extension SCSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //calculate the size
        let item: SCModelCategory = self.categoryItems[indexPath.row]
        let font = UIFont.systemFont(ofSize: 16.0)
        let size = font.sizeOfString(string: item.categoryName, constrainedToHeight: 35)
        let adjustedSize = CGSize(width: size.width+36, height: 35)
        return adjustedSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: leftRightPadding, bottom: 0, right: leftRightPadding)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16.0
    }
}

extension SCSelectionViewController: SCSelectionDisplaying {
    
    func getSourceFlowType() -> ControllerSource {
        if let sourceFlow = sourceFlow {
            return sourceFlow
        }
        
        return .WasteFilter
    }
    
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
    
    func updateCategories(categories: [SCModelCategory], preselectedItems: [SCModelCategory]?) {
        // Will sort categories with acsending order
        if sourceFlow == .WasteFilter {
            self.categoryItems = categories.sorted(by: {
                $0.categoryName.lowercased() < $1.categoryName.lowercased()
            })
        } else {
            self.categoryItems = categories
        }
        
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
    
class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }

            layoutAttribute.frame.origin.x = leftMargin

            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }

        return attributes
    }
}

extension UIFont {
    func sizeOfString (string: String, constrainedToHeight height: Double) -> CGSize {
        return NSString(string: string).boundingRect(
            with: CGSize(width: .greatestFiniteMagnitude, height: height),
            options: .usesLineFragmentOrigin,
            attributes: [.font: self],
            context: nil).size
    }
}
