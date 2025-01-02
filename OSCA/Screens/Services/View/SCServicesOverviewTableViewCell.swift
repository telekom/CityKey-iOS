//
//  SCServicesOverviewTableViewCell.swift
//  SmartCity
//
//  Created by Michael on 06.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

protocol SCServicesOverviewTableViewCellDelegate : NSObjectProtocol
{
    func favoriteStateShouldChange(for contentID : String?, newFavSelected: Bool, cell: SCServicesOverviewTableViewCell)
    func showLoginNeededNotificationScreen()
}


class SCServicesOverviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var serviceCellTitleLabel: UILabel!
    @IBOutlet weak var serviceCellLabel: UILabel!
    @IBOutlet weak var serviceCellImageView: UIImageView!
    @IBOutlet weak var serviceCellImageBackView: UIView!
    @IBOutlet weak var serviceFavBtn: UIButton!
    @IBOutlet weak var lockImageView: UIImageView!
    @IBOutlet weak var ribbonImageView: UIImageView!
    @IBOutlet weak var ribbonLabel: UILabel!
    
    var contentID: String?
    var favSelected: Bool = false {
        didSet {
            if favSelected {
                let image = UIImage(named: "icon_fav2_active")?.maskWithColor(color: UIColor(named: "CLR_LABEL_TEXT_WHITE")!)
                self.serviceFavBtn.setImage(image , for: .normal)
            } else {
                let image = UIImage(named: "icon_fav2_available")?.maskWithColor(color: UIColor(named: "CLR_LABEL_TEXT_WHITE")!)
                self.serviceFavBtn.setImage(image, for: .normal)
            }
        }
    }
    
    var cellLockedImageString: String? {
        didSet {
            if cellLockedImageString == nil {
                lockImageView.image = nil
            } else {
                lockImageView.image = UIImage(named: cellLockedImageString!)
            }
        }
    }

    weak var delegate : SCServicesOverviewTableViewCellDelegate?

    func showNewRibbon(_ show : Bool, color: UIColor){
        if !show {
            self.ribbonImageView.isHidden = true
            self.ribbonLabel.isHidden = true
        } else {
            self.ribbonImageView.isHidden = false
            self.ribbonLabel.isHidden = false
            
            let newImage = UIImage(named:"ribbon_top_left")!.maskWithColor(color: color)
            self.ribbonImageView.image = newImage
            self.ribbonLabel.text = LocalizationKeys.SCServicesOverviewTableViewCell.s001002003004RibbonLabelNewItem.localized()
            self.ribbonLabel.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 4));
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.serviceCellImageBackView!.layer.cornerRadius = 10.0
        self.serviceCellImageBackView!.clipsToBounds = true
     
        self.setupAccessibilityIDs()
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.serviceCellTitleLabel.accessibilityIdentifier = "lbl_title"
        self.serviceCellLabel.accessibilityIdentifier = "lbl_detail"
        self.serviceCellImageView.accessibilityIdentifier = "img_service"
        self.serviceFavBtn.accessibilityIdentifier = "btn_favorites"
        self.lockImageView.accessibilityIdentifier = "img_lock"
        self.ribbonImageView.accessibilityIdentifier = "img_ribbon"
        self.ribbonLabel.accessibilityIdentifier = "lbl_ribbon"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func favBtnWasPressed(_ sender: Any) {
        // We can only change the favorite state when the user is logged in
        if (SCAuth.shared.isUserLoggedIn()){
            self.delegate?.favoriteStateShouldChange(for: self.contentID, newFavSelected: !favSelected, cell: self)
        } else {
            self.delegate?.showLoginNeededNotificationScreen()
        }
    }

}
