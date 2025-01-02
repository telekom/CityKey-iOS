//
//  SCUserInfoBoxAttachmentTVC.swift
//  SmartCity
//
//  Created by Michael on 12.12.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
