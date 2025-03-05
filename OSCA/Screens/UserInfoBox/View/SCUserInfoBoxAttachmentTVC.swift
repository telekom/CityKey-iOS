/*
Created by Michael on 12.12.19.
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

protocol SCUserInfoBoxAttachmentTVCDelegate : NSObjectProtocol
{
    func didSelectAttachment(name: String)
}

enum SCUserInfoBoxAttachmentItemType {
    case image
    case pdf
    case generic
}

class SCUserInfoBoxAttachmentTVC: UITableViewController {

    private let cellHeight : CGFloat = 58.0
    private var attachments = [SCUserInfoBoxAttachmentItem]()
    var delegate: SCUserInfoBoxAttachmentTVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = cellHeight
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func estimatedTableHeight() -> CGFloat{
        return CGFloat(attachments.count) * cellHeight
    }

    func refreshWithAttachments(_ attachments : [SCUserInfoBoxAttachmentItem]) {
        self.attachments = attachments
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return attachments.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "attachmentCell", for: indexPath) as! SCUserInfoBoxAttachmentCell

        cell.backView.backgroundColor = UIColor(named: "CLR_INFOVIEW_BCKGRND")!
        cell.topSeparator.backgroundColor = UIColor(named: "CLR_SEPARATOR")!
        cell.bottomSeparator.backgroundColor = UIColor(named: "CLR_SEPARATOR")!

        if indexPath.row < self.attachments.count {
            let att = attachments[indexPath.row]
            cell.attTitleLbl.text = att.itemName
            cell.attTitleLbl.adjustsFontForContentSizeCategory = true
            cell.attTitleLbl.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 15.0, maxSize: 22.0)
            cell.attTypeImageView.image = UIImage(named: "file_download_small")?.maskWithColor(color: kColor_cityColor)
        }
        cell.attTitleLbl.textColor = kColor_cityColor
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // check out of bounds
        if indexPath.row < self.attachments.count {
            let att = attachments[indexPath.row]
            self.delegate?.didSelectAttachment(name: att.itemName)
        }
    }

}
