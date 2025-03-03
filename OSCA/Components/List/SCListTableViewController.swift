/*
Created by Michael on 06.10.18.
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

enum ControllerType {
    case news
    case events
}

protocol SCListTableViewControllerDelegate : NSObjectProtocol
{
    func didSelectListItem(item: SCBaseComponentItem)
    func didSelectListEventItem(item: SCModelEvent)
}

class SCListTableViewController: UITableViewController {

    let noDataInfoHeight = GlobalConstants.kListNoDataHeight
    let headerHeight = GlobalConstants.kListHeaderHeight
    
    var items = [SCBaseComponentItem]()
    var type: ControllerType = .news
    var eventItems = [SCModelEvent]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    var favoriteItems: [SCModelEvent] = []
    weak var delegate : SCListTableViewControllerDelegate?
    var titleAtTop =  true
    var noDataText =  ""
    var favoritesHeaderText = "h_001_events_favorites_header".localized()
    var eventsHeaderText = "h_001_events_header".localized()
    var customizeColor : UIColor = .gray

    override func viewDidLoad() {
        super.viewDidLoad()

        handleDynamicTypeChange()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleDynamicTypeChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }
    
    @objc private func handleDynamicTypeChange() {
        // Dynamic font
        tableView.estimatedRowHeight = (type == .events) ? GlobalConstants.kEventListRowHeight : GlobalConstants.kNewsListRowHeight
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if type == .events { return 2 }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //check the number of favorites
        
        if type == .events {
            let numberOfFavorites = favoriteItems.count
            let numberOfEvents = eventItems.count
            if numberOfFavorites >= 2 {
                return section == 0 ? 2 : (numberOfEvents <= 4 ? eventItems.count : 4)
            } else if numberOfFavorites == 1 {
                return section == 0 ? 1 : (numberOfEvents <= 4 ? eventItems.count : 4)
            } else {
                return section == 0 ? 0 : (numberOfEvents <= 4 ? numberOfEvents : 4)
            }
        }
        return items.count
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if type == .events {
            if favoriteItems.count == 0 {
                return 0.0
            }
            switch section {
            case 0:
                return favoriteItems.count > 0 ? headerHeight : 0.0
            case 1:
                return eventItems.count > 0 ? headerHeight : 0.0
            default:
                return 0.0
            }
        }
        return items.count == 0 ? 0.0 : 0.0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init()
        if type == .events {
            if favoriteItems.count == 0 {
                return nil
            }
            switch section {
            case 0:
                let label = UILabel.init(frame: CGRect(x: 21.0, y: 0.0, width: self.tableView.bounds.size.width - 21.0, height: headerHeight))
                label.font = UIFont.systemFont(ofSize: 12.0, weight: .bold)
                label.text = favoritesHeaderText
                label.textColor = UIColor(named: "CLR_LABEL_TEXT_GRAY_GRAY")!
                handleDynamicChangeFor(label, lblHeight: headerHeight)
                view.addSubview(label)
                    return view
            case 1:
                let label = UILabel.init(frame: CGRect(x: 21.0, y: 0.0, width: self.tableView.bounds.size.width - 21.0, height: headerHeight))
                label.font = UIFont.systemFont(ofSize: 12.0, weight: .bold)
                label.text = eventsHeaderText
                label.textColor = UIColor(named: "CLR_LABEL_TEXT_GRAY_GRAY")!
                handleDynamicChangeFor(label, lblHeight: headerHeight)
                view.addSubview(label)
                return view
            default:
                break
            }
        }
        
        let label = UILabel.init(frame: CGRect(x: 21.0, y: 0.0, width: self.tableView.bounds.size.width - 21.0, height: noDataInfoHeight))
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.text = noDataText
        label.textColor = UIColor(named: "CLR_LABEL_TEXT_BLACK")!
        handleDynamicChangeFor(label, lblHeight: noDataInfoHeight)
        view.addSubview(label)
        return view
    }
    
    func handleDynamicChangeFor(_ label: UILabel, lblHeight: CGFloat){
        label.adjustsFontForContentSizeCategory = true
        label.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 12, maxSize: 20)
        
        let contentSize = traitCollection.preferredContentSizeCategory
        if contentSize.isAccessibilityCategory {
            label.frame.size.height = label.text?.estimatedHeight(withConstrainedWidth: label.frame.size.width, font: label.font) ?? lblHeight
        } else {
            label.frame.size.height = lblHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if type == .events {
            if section == 1 && eventItems.count == 0 {
                return 30
            } else {
                return 0.0
            }
        } else {
            if self.items.count == 0 {
                return 60.0
            }
        }
        return 0.0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if type == .events {
            let view = UIView.init()
            if eventItems.count == 0 {
                let label = UILabel.init(frame: CGRect(x: 21.0, y: 0.0, width: self.tableView.bounds.size.width - 21.0, height: 21))
                label.font = UIFont.systemFont(ofSize: 14.0)
                label.text = self.noDataText
                label.textColor = UIColor(named: "CLR_LABEL_TEXT_BLACK")!
                handleDynamicChangeFor(label, lblHeight: 21)
                view.addSubview(label)
            }
            return view
        } else {
            let view = UIView.init()
            if items.count == 0 {
                let label = UILabel.init(frame: CGRect(x: 21.0, y: 0.0, width: self.tableView.bounds.size.width - 21.0, height: view.bounds.size.height))
                label.autoresizingMask = .flexibleHeight
                label.font = UIFont.systemFont(ofSize: 14.0)
                label.text = self.noDataText
                label.textColor = UIColor(named: "CLR_LABEL_TEXT_BLACK")!
                handleDynamicChangeFor(label, lblHeight: view.bounds.size.height)
                view.addSubview(label)
            }
            return view
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if type == .events {
            let cell: SCListEventTableViewCell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! SCListEventTableViewCell

            var eventItem : SCModelEvent?
            
            if indexPath.section == 0 {
                if favoriteItems.count > indexPath.row {
                    eventItem = favoriteItems[indexPath.row]
                }
            } else {
                if eventItems.count > indexPath.row {
                    eventItem = eventItems[indexPath.row]
                }
            }
            
            guard let item = eventItem else {
                return cell
            }
            
            let startDate : Date? = dateFromString(dateString: item.startDate)
            let endDate  : Date? = dateFromString(dateString: item.endDate)
            let dateBox = SCDateBox.instantiate()
            if isSameDayFromDate(startDate: startDate, endDate: endDate) {
                if let startDate = startDate {
                    dateBox.configure(_with: startDate)
                }
            } else {
                if let startDate = startDate, let endDate = endDate {
                    dateBox.configure(_with: startDate, endDate: endDate)
                }
            }
            cell.accessibilityIdentifier = "event_cell_" + String(indexPath.row)
            cell.dateBoxView.addSubview(dateBox)
            cell.dateBoxView.layer.cornerRadius = 4.0
            dateBox.backgroundColor = self.customizeColor
            dateBox.topAnchor.constraint(equalTo: cell.dateBoxView.topAnchor).isActive = true
            dateBox.leadingAnchor.constraint(equalTo: cell.dateBoxView.leadingAnchor).isActive = true
            dateBox.bottomAnchor.constraint(equalTo: cell.dateBoxView.bottomAnchor).isActive = true
            dateBox.trailingAnchor.constraint(equalTo: cell.dateBoxView.trailingAnchor).isActive = true
            dateBox.setNeedsLayout()
            cell.configure(item)
            cell.eventNameLabel?.adaptFontSize()
            cell.locationLabel?.adaptFontSize()
            cell.eventNameLabel.attributedText = item.title.applyHyphenation()
            cell.eventNameLabel.lineBreakMode = .byTruncatingTail
            
            cell.configureFavorite(active: indexPath.section == 0, customizeColor: customizeColor)
            cell.configureReminder(active: false)
            
            
            let accItemString = String(format:"accessibility_table_selected_cell".localized().replaceStringFormatter(), String(indexPath.row + 1), String(self.tableView.numberOfRows(inSection: indexPath.section)))

            cell.accessibilityTraits = .link
            cell.accessibilityHint = "accessibility_cell_dbl_click_hint".localized()
            cell.accessibilityLabel = accItemString + ", " + dateBox.getAccessibilityContent() + ", " +  item.locationName + ", " +  item.title
            cell.accessibilityLanguage = SCUtilities.preferredContentLanguage()
            cell.isAccessibilityElement = true
            
            cell.eventNameLabel.adjustsFontForContentSizeCategory = true
            cell.eventNameLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 14, maxSize: 25)
            cell.locationLabel.adjustsFontForContentSizeCategory = true
            cell.locationLabel.font = UIFont.SystemFont.medium.forTextStyle(style: .footnote, size: 12, maxSize: 18)
            cell.eventStatusLabel.adjustsFontForContentSizeCategory = true
            cell.eventStatusLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 10, maxSize: 13)
            dateBox.handleDynamicTypeChange()
            
            let contentSize = traitCollection.preferredContentSizeCategory
            if contentSize.isAccessibilityCategory {
                cell.eventStackBottomConstraint.isActive = true
                cell.eventNameLabel.numberOfLines = 0
                cell.locationLabel.numberOfLines = 0
                cell.eventStatusLabel.numberOfLines = 0

            } else {
                cell.eventStackBottomConstraint.isActive = false
                cell.eventNameLabel.numberOfLines = 1
                cell.locationLabel.numberOfLines = 1
                cell.eventStatusLabel.numberOfLines = 1
            }
            
            return cell
        }
        let firstCellID = titleAtTop ? "MessageCellLeftImage" : "MessageCellLeftImageBottomTitle"
        let secondCellID = titleAtTop ? "MessageCellRightImage" : "MessageCellRightImageBottomTitle"
        let cellIdentifier = (indexPath.row % 2 != 0) ? firstCellID : secondCellID
        let cell: SHListMessageCell =  tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SHListMessageCell

        // Configure the cell...
        let item = items[indexPath.row]

        cell.accessibilityIdentifier = "message_cell_" + String(indexPath.row)
        
        //adaptive Font Size
        cell.messageLabel?.adaptFontSize()
        cell.titleLabel?.adaptFontSize()
        cell.messageLabel.attributedText = item.itemTeaser?.applyHyphenation()

        cell.titleLabel?.text = item.itemTitle
        cell.seperator.isHidden = (items.count - 1) == indexPath.row

        let imageURL = item.itemThumbnailURL
        
        if let imageURL = imageURL {
            cell.messageImageView.image = UIImage(named: imageURL.absoluteUrlString())
        }
        
        let accItemString = String(format:"accessibility_table_selected_cell".localized().replaceStringFormatter(), String(indexPath.row + 1), String(items.count))

        cell.accessibilityTraits = .link
        cell.accessibilityHint = "accessibility_cell_dbl_click_hint".localized()
        cell.accessibilityLabel = accItemString + ", " + (item.itemTeaser ?? "") + ", " + item.itemTitle
        cell.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        cell.isAccessibilityElement = true

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if type == .news{
            self.delegate?.didSelectListItem(item: self.items[indexPath.row])
       } else if type == .events {
            let item = indexPath.section == 0 ? self.favoriteItems[indexPath.row] : self.eventItems[indexPath.row]
            self.delegate?.didSelectListEventItem(item: item)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if type == .events {
            return UITableView.automaticDimension
        }
        return GlobalConstants.kNewsListRowHeight
    }

}
