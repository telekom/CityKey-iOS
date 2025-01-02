//
//  QRCodeViewController.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 28/07/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCQRCodeViewController: UIViewController {

    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var waitingNumberPlaceHolderLabel: UILabel!
    @IBOutlet weak var waitingNumberLabel: UILabel!

    var presenter: SCQRCodePresenting?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func setupUI() {
        title = LocalizationKeys.QRCodeViewController.apnmt004QrcodeTitle.localized()
        waitingNumberPlaceHolderLabel.text = LocalizationKeys.QRCodeViewController.apnmt004QrcodeWaitingNoLabel.localized()
        
        // SMARTC-17194 iOS: Paderborn Appointments | QR Code is not completely visible in iPhone 5s
//        waitingNumberLabel.font = UIFont(name: waitingNumberLabel.font.fontName, size: (self.view.frame.width == 320) ? 80 : waitingNumberLabel.font.pointSize)
        
        
        // SMARTC-18502 Design / iOS : Show QR code- Waiting number font is different from design
        
        waitingNumberLabel.font = UIFont.boldSystemFont(ofSize: (self.view.frame.width == 320) ? 80 : 104)

        waitingNumberLabel.text = presenter?.getWaitingNumber()
        qrCodeImage.image = presenter?.getQRCodeImage()
    }

    @IBAction func didTapOnClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
