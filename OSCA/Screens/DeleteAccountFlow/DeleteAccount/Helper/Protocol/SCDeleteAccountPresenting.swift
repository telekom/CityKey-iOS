//
//  SCDeleteAccountPresenting.swift
//  OSCA
//
//  Created by Bhaskar N S on 26/06/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

protocol SCDeleteAccountPresenting: AnyObject, SCPresenting {
    func setDisplay(_ display: SCDeleteAccountDisplaying)
    func deleteAccountButtonWasPressed()
    func closeButtonWasPressed()
}
