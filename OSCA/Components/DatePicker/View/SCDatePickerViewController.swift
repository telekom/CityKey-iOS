//
//  SCDatePickerViewController.swift
//  SmartCity
//
//  Created by Michael on 25.08.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCDatePickerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    public var presenter: SCDatePickerPresenting!

    @IBOutlet weak var clearAllButton: UIBarButtonItem!
    @IBOutlet weak var bottomSeperatorView: UIView!
    @IBOutlet weak var filterBtn: SCCustomButton!
    @IBOutlet weak var lblHeaderMon: UILabel!
    @IBOutlet weak var lblHeaderTue: UILabel!
    @IBOutlet weak var lblHeaderWed: UILabel!
    @IBOutlet weak var lblHeaderThu: UILabel!
    @IBOutlet weak var lblHeaderFri: UILabel!
    @IBOutlet weak var lblHeaderSat: UILabel!
    @IBOutlet weak var lblHeaderSun: UILabel!
    @IBOutlet weak var calendarCollectionView: UICollectionView!{
        didSet{
            calendarCollectionView.dataSource = self
            calendarCollectionView.delegate = self
        }
    }
    
    private let leftRightPadding : CGFloat = 21.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.calendarCollectionView.allowsMultipleSelection = true

        self.setupAccessibilityIDs()
        self.setupAccessibility()
        
        self.shouldNavBarTransparent = false

        self.presenter.setDisplay(self)

        self.presenter.viewDidLoad()
        
     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshNavigationBarStyle()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [weak self] context in
            self?.reloadData()
        }
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        
        self.clearAllButton.accessibilityIdentifier = "btn_clear_all"
        self.filterBtn.accessibilityIdentifier = "btn_filter"
        self.lblHeaderMon.accessibilityIdentifier = "lbl_header_mon"
        self.lblHeaderTue.accessibilityIdentifier = "lbl_header_tue"
        self.lblHeaderWed.accessibilityIdentifier = "lbl_header_wed"
        self.lblHeaderThu.accessibilityIdentifier = "lbl_header_thu"
        self.lblHeaderFri.accessibilityIdentifier = "lbl_header_fri"
        self.lblHeaderSat.accessibilityIdentifier = "lbl_header_sat"
        self.lblHeaderSun.accessibilityIdentifier = "lbl_header_sun"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }

    private func setupAccessibility(){
        self.clearAllButton.accessibilityTraits = .button
        self.clearAllButton.accessibilityLabel = "accessibility_btn_clear_all".localized()
        self.clearAllButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }

    // MARK: UICollectionViewDelegate
    //set the section number
     internal func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.presenter!.numberOfMonthInDatePicker()
    }

    //cell numbers
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.presenter!.numberOfDaysForMonthIndex(monthIndex: section)
    }
    
    /*
     Sections
     */
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath)
        
        if let customHeader = headerView as? SCDatePickerSectionHeaderViewCollectionReusableView{
            customHeader.titleLabel.text = self.presenter.title(for: indexPath.section)
            customHeader.titleLabel.textColor = UIColor(named: "CLR_LABEL_TEXT_BLACK")!

            return customHeader
        }
        return headerView
    }
    
    //Add cells to collectionView
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "dayCell",for: indexPath) as! SCDatePickerCell
        
        let day = self.presenter.day(for: indexPath.section, dayIndex: indexPath.row)
        viewCell.cityColor = kColor_cityColor
        viewCell.isSelected = self.presenter.isDaySelected(day)
        viewCell.isFirstDayOfSelection = self.presenter.isFirstDayOfSelection(day)
        viewCell.isLastDayOfSelection = self.presenter.isLastDayOfSelection(day)
        viewCell.isLastDayOfSelection = self.presenter.isLastDayOfSelection(day)

        viewCell.isFirstDayOfWeek = (indexPath.row % 7 == 0)
        viewCell.isLastDayOfWeek = ((indexPath.row + 1) % 7 == 0)

        viewCell.day = day
        return viewCell
    }
    
    //CellSize
    func  collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath ) -> CGSize {
        let numberOfItemsPerRow = 7
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace - (2 * self.leftRightPadding)) / CGFloat(numberOfItemsPerRow))
        
        let additionalwidth = (indexPath.row % 7 == 0) || ((indexPath.row + 1) % 7 == 0) ? Int(self.leftRightPadding) : 0
        return CGSize(width: size + additionalwidth, height: 35 )
    }
    
    //Section Minimum Space
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout:UICollectionViewLayout,minimumLineSpacingForSectionAt section:Int) -> CGFloat{
        return 5.0
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath){
        let day = self.presenter.day(for: indexPath.section, dayIndex: indexPath.row)
        self.presenter.dayWasSelected(day)
    }

    func collectionView(_ collectionView: UICollectionView,
                        didDeselectItemAt indexPath: IndexPath){

        let day = self.presenter.day(for: indexPath.section, dayIndex: indexPath.row)
        self.presenter.dayWasSelected(day)
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionHeader", for: indexPath as IndexPath)
        
        return headerView
    }
    
    private func indexPathIsValid(indexPath: IndexPath) -> Bool {
        return indexPath.section <  numberOfSections(in: self.calendarCollectionView) && indexPath.row < self.calendarCollectionView.numberOfItems(inSection: indexPath.section)
    }

    @IBAction func clearAllBtnWasPressed(_ sender: Any) {
        self.presenter.clearAllButtonWasPressed()
    }
    
    @IBAction func filterBtnWasPressed(_ sender: Any) {
        self.presenter.filterButtonWasPressed()
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        self.presenter.closeButtonWasPressed()
    }
    
    func getRightBarButtonItem() -> UIBarButtonItem {
        let barBtn =  UIBarButtonItem(title: "e_003_clear_button".localized(), style: .plain, target: self, action: #selector(clearAllBtnWasPressed(_:)))
        barBtn.tintColor = kColor_cityColor
        return barBtn
    }
}

// MARK: - SCDatePickerPresenting
extension SCDatePickerViewController: SCDatePickerDisplaying {
    
    func setupUI(){
        self.navigationItem.title = "e_003_page_title".localized()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
 
        self.lblHeaderMon.text = formatter.string(from: Date(timeIntervalSince1970: 345600))
        self.lblHeaderTue.text = formatter.string(from: Date(timeIntervalSince1970: 432000))
        self.lblHeaderWed.text = formatter.string(from: Date(timeIntervalSince1970: 518400))
        self.lblHeaderThu.text = formatter.string(from: Date(timeIntervalSince1970: 0))
        self.lblHeaderFri.text = formatter.string(from: Date(timeIntervalSince1970: 86400))
        self.lblHeaderSat.text = formatter.string(from: Date(timeIntervalSince1970: 172800))
        self.lblHeaderSun.text = formatter.string(from: Date(timeIntervalSince1970: 259200))
        
        self.bottomSeperatorView.backgroundColor = UIColor(named: "CLR_BORDER_SILVERGRAY")!
        self.filterBtn.customizeCityColorStyle()
        self.filterBtn.setTitle(" " + "e_003_show_events_button".localized() + " ", for: .normal)

        self.clearAllButton(isHidden: true)

        self.reloadData()
    }
    
    func reloadData(){
        self.calendarCollectionView.reloadData()
    }

    func unselectAllSelectedCells(){
        guard let calendarCollectionView = self.calendarCollectionView else {
            return
        }
        guard let indexPathsForSelectedItems = calendarCollectionView.indexPathsForSelectedItems else {
            return
        }
        for indexPath in indexPathsForSelectedItems {
            if indexPathIsValid(indexPath: indexPath){
                if let cell = self.calendarCollectionView?.cellForItem(at: indexPath) as? SCDatePickerCell {
                    cell.isFirstDayOfSelection = false
                    cell.isLastDayOfSelection = false
                }
                calendarCollectionView.deselectItem(at: indexPath, animated: false)
                
            }
        }
    }

    func selectCells(monthIndex : Int, dayIndex : Int){
        if indexPathIsValid(indexPath: IndexPath(row: dayIndex, section: monthIndex)){
            if let cell = self.calendarCollectionView?.cellForItem(at: IndexPath(row: dayIndex, section: monthIndex)) as? SCDatePickerCell {
                let day = self.presenter.day(for: monthIndex, dayIndex: dayIndex)
                cell.isFirstDayOfSelection = self.presenter.isFirstDayOfSelection(day)
                cell.isLastDayOfSelection = self.presenter.isLastDayOfSelection(day)
            }
            self.calendarCollectionView?.selectItem(at: IndexPath(row: dayIndex, section: monthIndex), animated: true, scrollPosition: .left)
        }
    }

    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }

    func applyProgressStateToFilterBtn(){
        self.filterBtn.btnState = .progress
    }
    
    func refreshFilterBtnWithCount(_ count : Int){
        self.filterBtn.btnState = .normal
        
        let btnText = count >= 0 ?  "e_004_events_filter_categories_show_events".localized().replacingOccurrences(of: "%d", with: String(count)) : "e_003_show_events_button".localized()
        
        self.filterBtn.setTitle(" " + btnText + " ", for: .normal)
        
    }
    
    func clearAllButton(isHidden: Bool) {
        self.navigationItem.rightBarButtonItem = isHidden ? nil : self.getRightBarButtonItem()
    }

}
