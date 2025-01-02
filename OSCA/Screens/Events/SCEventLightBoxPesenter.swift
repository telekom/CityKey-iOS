//
//  SCEventLightBoxPesenter.swift
//  SmartCity
//
//  Created by Alexander Lichius on 05.12.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

protocol SCEventLightBoxPresenting: SCPresenting {
    func closeButtonWasTapped()
    func setDisplay(display: SCEventLightBoxDisplaying)
}

class SCEventLightBoxPresenter {
    weak private var display: SCEventLightBoxDisplaying?
    var imageURL: SCImageURL!
    var imageCredit: String!
    
    
    private func setupUI() {
        self.display?.setupImage(_with: self.imageURL)
        self.display?.setupCreditLabel(_with: self.imageCredit)
    }
}

extension SCEventLightBoxPresenter: SCEventLightBoxPresenting {
    func closeButtonWasTapped() {
        self.display?.dismiss()
    }
    
    func setDisplay(display: SCEventLightBoxDisplaying) {
        self.display = display
    }
    
    func viewDidLoad() {
        self.setupUI()
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
}
