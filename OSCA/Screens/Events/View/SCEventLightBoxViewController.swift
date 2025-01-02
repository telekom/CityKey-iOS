//
//  SCEventLightBoxViewController.swift
//  SmartCity
//
//  Created by Alexander Lichius on 05.12.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCEventLightBoxDisplaying: AnyObject, SCDisplaying {
    func setupImage(_with imageUrl: SCImageURL)
    func setupCreditLabel(_with text: String)
    func dismiss()
}

protocol SCEventLightBoxDismissDelegate {
    func dismissBlurView()
}

class SCEventLightBoxViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var creditLabel: UILabel!
    var presenter: SCEventLightBoxPresenting!
    var dismissDelegate: SCEventLightBoxDismissDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.definesPresentationContext = true
        //self.modalPresentationStyle = .currentContext
        self.presenter.setDisplay(display: self)
        self.presenter.viewDidLoad()
        self.view.bringSubviewToFront(self.closeButton)
        self.view.bringSubviewToFront(self.creditLabel)
        
    }

    @IBAction func closeButtonWasTapped(_ sender: Any) {
        self.dismissDelegate.dismissBlurView()
        self.presenter.closeButtonWasTapped()
    }
}

extension SCEventLightBoxViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}

extension SCEventLightBoxViewController: SCEventLightBoxDisplaying {
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupImage(_with imageUrl: SCImageURL) {
        self.imageView.load(from: imageUrl, maxWidth: self.view.frame.width)
    }
    
    func setupCreditLabel(_with text: String) {
        self.creditLabel.text = text
    }
}
