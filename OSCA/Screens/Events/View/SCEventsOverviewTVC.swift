/*
Created by Michael on 08.10.19.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit
import Kingfisher

protocol SCEventsOverviewTVCDelegate : AnyObject {
    
    func didSelectListItem(item: SCModelEvent)
    func didPressLoadMoreItemsRetryBtn()
    func willReachEndOfList()
    
}

class SCEventsOverviewTVC: UITableViewController {
    
    private var items = [SCModelEvent]()
    private var favItems: [SCModelEvent]?
    
    private let eventsListRowHeight: CGFloat = 86.0
    
    weak var delegate : SCEventsOverviewTVCDelegate?
    
    var cityColor: UIColor = .gray{
        didSet {
            self.loadMoreErrorBtn.setTitleColor(cityColor, for: .normal)
            self.loadMoreErrorBtn.setImage(UIImage(named: "action_resend_email")?.maskWithColor(color: cityColor), for: .normal)
        }
    }
    
    @IBOutlet var tableFooterView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadMoreErrorLabel: UILabel!
    @IBOutlet weak var loadMoreErrorBtn: UIButton!
    
    @IBOutlet var noDataSectionFooter: UIView!
    @IBOutlet weak var noDataSectionFooterTopLabel: UILabel!
    @IBOutlet weak var noDataSectionFooterBottomLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()
        self.setupUI()
        tableView.prefetchDataSource = self
        self.handleDynamicTypeChange()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDynamicTypeChange), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleDynamicTypeChange() {
        // Dynamic font
        self.navigationItem.title = LocalizationKeys.SCEventsOverviewVC.e002PageTitle.localized()
        self.navigationItem.backButtonTitle = LocalizationKeys.Common.navigationBarBack.localized()
        
        tableView.estimatedRowHeight = self.eventsListRowHeight
        tableView.rowHeight = !traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? self.eventsListRowHeight : UITableView.automaticDimension
        
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        
        self.activityIndicator.accessibilityIdentifier = "act_indicator"
    }
    
    private func setupUI() {
        tableView.estimatedRowHeight = self.eventsListRowHeight
        tableView.rowHeight = self.eventsListRowHeight
        
        //self.navigationItem.title = "h_001_home_title_news".localized()
        
        self.loadMoreErrorLabel.adaptFontSize()
        self.loadMoreErrorLabel.text = LocalizationKeys.SCEventsOverviewTVC.e002PageLoadError.localized()
        self.loadMoreErrorBtn.setTitle(" " + LocalizationKeys.SCEventsOverviewTVC.e002PageLoadError.localized(), for: .normal)
        self.loadMoreErrorBtn.titleLabel?.adaptFontSize()
        self.loadMoreErrorBtn.setImage(UIImage(named: "action_resend_email")?.maskWithColor(color: cityColor), for: .normal)
        
        
        self.noDataSectionFooterTopLabel.accessibilityIdentifier = "lbl_nodata_top"
        self.noDataSectionFooterBottomLabel.accessibilityIdentifier = "lbl_nodata_bottom"
        self.noDataSectionFooterTopLabel.adaptFontSize()
        self.noDataSectionFooterBottomLabel.adaptFontSize()
        
        self.noDataSectionFooterTopLabel.text = LocalizationKeys.SCEventsOverviewTVC.e002NoEventsMsg.localized()
        self.noDataSectionFooterBottomLabel.text = LocalizationKeys.SCEventsOverviewTVC.e002NoEventsHintMsg.localized()
        
        activityIndicator.backgroundColor = UIColor(named: "CLR_BCKGRND")
        if #available(iOS 13.0, *) {
            activityIndicator.style = .medium
        } else {
            activityIndicator.style = .gray
        }
        
    }
    
    func updateEvents(with dataItems: [SCModelEvent], favItems: [SCModelEvent]?) {
        self.items = dataItems
        self.favItems = favItems
        self.tableView.reloadData()
    }
    
    func moreItemsAvailable(_ moreItems : Bool){
        
        if moreItems {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            self.loadMoreErrorBtn.isHidden = true
            self.loadMoreErrorLabel.isHidden = true
            self.tableView.tableFooterView = self.tableFooterView
        } else {
            self.activityIndicator.stopAnimating()
            self.tableView.tableFooterView = nil
        }
    }
    
    func moreItemsError(){
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        self.tableView.tableFooterView = self.tableFooterView
        self.loadMoreErrorBtn.isHidden = false
        self.loadMoreErrorLabel.isHidden = false
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return section == 0 ? (favItems?.count ?? 0) : items.count
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (section == 1) && (self.items.count == 0)  ? 220.0 : 0.0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return (section == 1) && (self.items.count == 0) ? noDataSectionFooter : nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (self.favItems?.count ?? 0) == 0 ? 0.0 : 44.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.backgroundColor = UIColor(named: "CLR_BCKGRND")!
        let label = UILabel.init(frame: CGRect(x: 20.0, y: 0.0, width: self.tableView.bounds.size.width - 20.0, height: 44))
        label.font = UIFont.boldSystemFont(ofSize: 12.0)
        label.text = section == 0 ? LocalizationKeys.SCEventsOverviewTVC.h001EventsFavoritesHeader.localized() : LocalizationKeys.SCEventsOverviewTVC.h001EventsHeader.localized()
        
        label.adjustsFontForContentSizeCategory = true
        label.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 12, maxSize: 20)
        
        let contentSize = traitCollection.preferredContentSizeCategory
        if contentSize.isAccessibilityCategory {
            label.frame.size.height = label.text?.estimatedHeight(withConstrainedWidth: label.frame.size.width, font: label.font) ?? 44
        } else {
            label.frame.size.height = 44
        }
        label.textColor = UIColor(named: "CLR_LABEL_TEXT_GRAY_GRAY")!
        label.adaptFontSize()
        view.addSubview(label)
        return view
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == tableView.numberOfSections - 1 {
            if indexPath.row + 1 == items.count {
                self.delegate?.willReachEndOfList()
            }
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SCEventsOverviewCell = tableView.dequeueReusableCell(withIdentifier: "EventsOverviewMessageCell", for: indexPath) as! SCEventsOverviewCell
        
        
        // check out of bounds
        if (indexPath.section == 0 && indexPath.row >= (favItems?.count ?? 0)) ||
            (indexPath.section > 0 && indexPath.row >= items.count){
            return cell
        }
        
        let item = indexPath.section == 0 ? favItems![indexPath.row] : items[indexPath.row]
        //adaptive Font Size
        cell.eventCellTitleLabel?.adaptFontSize()
        cell.eventCellLabel?.adaptFontSize()
        cell.eventCellDateLabel?.adaptFontSize()
        
        // Configure the cell...
        cell.eventCellTitleLabel?.text = item.locationName
        cell.eventCellTitleLabel.isHidden = !cell.eventCellTitleLabel.text!.isEmpty ? false : true
        cell.eventCellLabel?.attributedText = NSMutableAttributedString(string: item.title)
        
        cell.eventCellDateLabel.layer.masksToBounds = true
        cell.eventCellDateLabel.layer.cornerRadius = 5.0
        cell.eventCellDateLabel.backgroundColor =  kColor_cityColor
        cell.eventCellDateLabel.text = "  " + self.formattedDate(startDateString: item.startDate, endDateString: item.endDate) + "  "
        
        if let imageurl = item.thumbnailURL {
            cell.eventCellImageView.image = UIImage(named: imageurl.absoluteUrlString())
            // Make image circular
            cell.eventCellImageView.layer.cornerRadius = 5.0
            cell.eventCellImageView.clipsToBounds = true
            cell.eventCellImageView.layer.borderWidth = 0
            cell.eventCellImageView.layer.borderColor = UIColor(named: "CLR_BCKGRND")!.cgColor
        } else {
            cell.eventCellImageView.image = nil
        }
        cell.reminerImageView.isHidden = true
        
        //if indexPath.section > 0 && favItems != nil && favItems!.contains(where: { $0.uid == item.uid }) {
        // change due to SMARTC-6371
        if indexPath.section == 0 {
            cell.favouriteImageView.image = UIImage(named: "icon_favourite_small")?.maskWithColor(color: cityColor)
        } else {
            cell.favouriteImageView.image = nil
        }
        switch EventStatus(rawValue: item.status?.uppercased() ?? "AVAILABLE") {
            
        case .cancelled:
            let strikeThroughText = NSMutableAttributedString(string: item.title)
            strikeThroughText.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, strikeThroughText.length))
            cell.eventCellLabel.attributedText = strikeThroughText
            cell.setupEventStatusLabel(.appointmentRejected,
                                       statusText: LocalizationKeys.SCEventsOverviewTVC.e007CancelledEvents.localized())
        case .postponed:
            let strikeThroughText = NSMutableAttributedString(string: item.title)
            cell.eventCellLabel.attributedText = strikeThroughText
            cell.setupEventStatusLabel(.postponeEventStatus,
                                       statusText:  LocalizationKeys.SCEventsOverviewTVC.e007EventsNewDateLabel.localized())
            
        case .soldout:
            let strikeThroughText = NSMutableAttributedString(string: item.title)
            cell.eventCellLabel.attributedText = strikeThroughText
            cell.setupEventStatusLabel(.appointmentRejected,
                                       statusText: LocalizationKeys.SCEventsOverviewTVC.e007EventsSoldOutLabel.localized())
            
        default:
            
            if let attrText = cell.eventCellLabel.attributedText{
                let mutableText = NSMutableAttributedString(attributedString: attrText)
                mutableText.removeAttribute(NSMutableAttributedString.Key.strikethroughStyle, range: NSMakeRange(0, mutableText.length))
                cell.eventCellLabel.attributedText = mutableText
                cell.eventStatusLabel.isHidden = true
                
            }
            
        }
        
        cell.eventCellLabel.adjustsFontForContentSizeCategory = true
        cell.eventCellLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 16, maxSize: nil)
        cell.eventCellTitleLabel.adjustsFontForContentSizeCategory = true
        cell.eventCellTitleLabel.font = UIFont.SystemFont.medium.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        cell.eventCellDateLabel.adjustsFontForContentSizeCategory = true
        cell.eventCellDateLabel.font = UIFont.SystemFont.medium.forTextStyle(style: .footnote, size: 14, maxSize: nil)
        cell.eventStatusLabel.adjustsFontForContentSizeCategory = true
        cell.eventStatusLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 10, maxSize: 13)
        
        let contentSize = traitCollection.preferredContentSizeCategory
        if contentSize.isAccessibilityCategory {
            
            cell.eventCellLabel.numberOfLines = 0
            cell.eventCellTitleLabel.numberOfLines = 0
            cell.eventCellDateLabel.numberOfLines = 0
            cell.eventStatusLabel.numberOfLines = 0
            cell.eventCellImageViewHeightConstraint.isActive = false
            cell.eventCellImageViewAspectRatioConstraint.isActive = true
            cell.eventStackBottomConstraint.isActive = true
        } else {
            
            cell.eventCellLabel.numberOfLines = 1
            cell.eventCellTitleLabel.numberOfLines = 1
            cell.eventCellDateLabel.numberOfLines = 1
            cell.eventStatusLabel.numberOfLines = 1
            cell.eventCellImageViewHeightConstraint.isActive = true
            cell.eventCellImageViewAspectRatioConstraint.isActive = false
            cell.eventStackBottomConstraint.isActive = false
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // check out of bounds
        if (indexPath.section == 0 && indexPath.row >= (favItems?.count ?? 0)) ||
            (indexPath.section > 0 && indexPath.row >= items.count){
            return
        }
        
        let item = indexPath.section == 0 ? favItems![indexPath.row] : items[indexPath.row]
        
        self.delegate?.didSelectListItem(item: item)
    }
    
    private func formattedDate(startDateString : String, endDateString : String) -> String{
        
        guard let startDate = dateFromString(dateString: startDateString) else {
            return ""
        }
        
        guard let endDate = dateFromString(dateString: endDateString) else {
            return ""
        }
        
        if isSameDayFromDate(startDate: startDate, endDate: endDate) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, dd.MMMM yyyy"
            return formatter.string(from: startDate)
        } else if ((getYear(_for: startDate)) != (getYear(_for: endDate))) {
            let firstDayformatter = DateFormatter()
            let secondDayformatter = DateFormatter()
            firstDayformatter.dateFormat = "EE, dd.MMM yyyy - "
            secondDayformatter.dateFormat = "EE, dd.MMM yyyy"
            return firstDayformatter.string(from: startDate) + secondDayformatter.string(from:endDate)
        } else {
            let firstDayformatter = DateFormatter()
            let secondDayformatter = DateFormatter()
            firstDayformatter.dateFormat = "EE, dd.MMM - "
            secondDayformatter.dateFormat = "EE, dd.MMM yyyy"
            return firstDayformatter.string(from: startDate) + secondDayformatter.string(from:endDate)
        }
        
    }
    
    @IBAction func loadMoreErrorBtnWasPressed(_ sender: Any) {
        self.delegate?.didPressLoadMoreItemsRetryBtn()
    }
}

extension SCEventsOverviewTVC: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let itemURLs = items.compactMap {
            $0.thumbnailURL?.absoluteUrl()
        }
        
        PrefetchNetworkImages.prefetchImagesFromNetwork(with: itemURLs)
    }
}
