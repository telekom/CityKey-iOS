//
//  SCNoAppointmentMessageView.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 11/08/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCNoAppointmentMessageView: UIView {

    @IBOutlet weak var noAppointmentLabel: UILabel!

    class func getView() -> SCNoAppointmentMessageView? {
        return UINib(nibName: "SCNoAppointmentMessageView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? SCNoAppointmentMessageView
    }
}
