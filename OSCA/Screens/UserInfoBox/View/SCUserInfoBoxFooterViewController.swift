//
//  SCUserInfoBoxFooterViewController.swift
//  SmartCity
//
//  Created by Alexander Lichius on 11.02.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//



import UIKit

class SCUserInfoBoxFooterViewController: UIViewController {

    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var noItemsImageView: UIImageView!
    @IBOutlet weak var noItemsLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorRetryBtn: UIButton!
    @IBOutlet weak var errorTitleLbl: UILabel!
    @IBOutlet weak var errorSubtitleLbl: UILabel!
    @IBOutlet weak var noItemImageViewCenterXConstraint: NSLayoutConstraint!
    
    weak var delegate: FooterViewDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLayoutConstraint()
        self.setupAccessibilityIDs()
        self.setupUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [weak self] context in
            guard let strongSelf = self else {
                return
            }
            strongSelf.updateLayoutConstraint()
        }
    }
    
    private func updateLayoutConstraint() {
        if UIDevice.current.orientation.isLandscape {
            noItemImageViewCenterXConstraint.constant = 68
        } else {
            noItemImageViewCenterXConstraint.constant = -68
        }
    }
    
    private func setupAccessibilityIDs() {
        self.overlayView.accessibilityIdentifier = "overlay_view"
        self.noItemsImageView.accessibilityIdentifier = "img_no_items"
        self.noItemsLabel.accessibilityIdentifier = "lbl_no_items"
        self.activityIndicator.accessibilityIdentifier = "activity_indicator"
        self.errorRetryBtn.accessibilityIdentifier = "btn_retry"
        self.errorTitleLbl.accessibilityIdentifier = "lbl_error_title"
        self.errorSubtitleLbl.accessibilityIdentifier = "lbl_error_subtitle"
    }
    
    func setupUI() {
        self.noItemsLabel.adaptFontSize()
        self.noItemsLabel.text = "b_001_infobox_no_messages".localized()
        self.errorTitleLbl.adaptFontSize()
        self.errorTitleLbl.text = "b_005_infobox_error_info_title".localized()
        self.errorSubtitleLbl.adaptFontSize()
        self.errorSubtitleLbl.text = "b_005_infobox_error_info_subtitle".localized()
        self.errorRetryBtn.setTitle(" " + "b_005_infobox_error_btn_reload".localized(), for: .normal)
        self.errorRetryBtn.setTitleColor(kColor_cityColor, for: .normal)
        self.errorRetryBtn.titleLabel?.adaptFontSize()
        self.errorRetryBtn.setImage(UIImage(named: "action_resend_email")?.maskWithColor(color: kColor_cityColor), for: .normal)
        
        if #available(iOS 13.0, *) {
            activityIndicator.style = .medium
        } else {
            activityIndicator.style = .gray
        }
    }
}

extension SCUserInfoBoxFooterViewController: FooterViewDelegate {
    
    func updateOverlay(state : SCInfoBoxOverlayState) {
        switch state {
        case .error:
             self.overlayView.isHidden = false
             self.errorRetryBtn.isHidden = false
             self.errorTitleLbl.isHidden = false
             self.errorSubtitleLbl.isHidden = false
             self.activityIndicator.stopAnimating()
             self.activityIndicator.isHidden = true
             self.noItemsLabel.isHidden = true
             self.noItemsImageView.isHidden = true
         case .noItems:
             self.overlayView.isHidden = false
             self.errorRetryBtn.isHidden = true
             self.errorTitleLbl.isHidden = true
             self.errorSubtitleLbl.isHidden = true
             self.activityIndicator.stopAnimating()
             self.activityIndicator.isHidden = true
             self.noItemsLabel.isHidden = false
             self.noItemsLabel.text = "b_001_infobox_no_messages".localized()
             self.noItemsImageView.isHidden = false
         case .noUnreadItems:
             self.overlayView.isHidden = false
             self.errorRetryBtn.isHidden = true
             self.errorTitleLbl.isHidden = true
             self.errorSubtitleLbl.isHidden = true
             self.activityIndicator.stopAnimating()
             self.activityIndicator.isHidden = true
             self.noItemsLabel.isHidden = false
             self.noItemsLabel.text = "b_001_infobox_no_unread_messages".localized()
             self.noItemsImageView.isHidden = false
        case .loading:
             self.overlayView.isHidden = false
             self.errorRetryBtn.isHidden = true
             self.errorTitleLbl.isHidden = true
             self.errorSubtitleLbl.isHidden = true
             self.activityIndicator.startAnimating()
             self.activityIndicator.isHidden = false
             self.noItemsLabel.isHidden = true
             self.noItemsImageView.isHidden = true
        case .none:
             self.activityIndicator?.stopAnimating()
             self.overlayView?.isHidden = true
        }
    }
        
    func showEmptyView() {
        //self.overlayView.isHidden = false
        self.errorRetryBtn.isHidden = true
        self.errorTitleLbl.isHidden = true
        self.errorSubtitleLbl.isHidden = true
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        //self.noItemsLabel.isHidden = false
        //self.noItemsLabel.text = "b_001_infobox_no_messages".localized()
        //self.noItemsImageView.isHidden = false
    }
    
    func getView() -> UIView {
        return self.view
    }

}
