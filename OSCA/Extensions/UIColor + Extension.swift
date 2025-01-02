//
//  UIColor + Extension.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 20/07/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension UIColor {

    static var appointmentReservation: UIColor {
        return UIColor(hexString: "FF8700")
    }

    static var appointmentRejected: UIColor {
        return UIColor(hexString: "D0021B")
    }

    static var clearBackground: UIColor {
        return UIColor(named: "CLR_BCKGRND") ?? UIColor.clear
    }

    static var appointmentExpired: UIColor {
        return UIColor(named: "CLR_BORDER_DARKGRAY") ?? UIColor.clear
    }

    static var appointmentChanging: UIColor {
        return UIColor(hexString: "0F69CB")
    }
    
    static var appointmentStatusText: UIColor {
        return UIColor(named: "CLR_LABEL_TEXT_WHITE") ?? UIColor.clear
    }

    static var appointmentStatusTextExpired: UIColor {
        return UIColor(named: "CLR_LABEL_TEXT_CANCELLED") ?? UIColor.clear
    }

    static var seperatorCLR: UIColor {
        return UIColor(hexString: "a4aab3")
    }

    static var coolGray: UIColor {
        return UIColor(hexString: "ededed")
    }

    static var labelTextBlackCLR: UIColor {
        return UIColor(named: "CLR_LABEL_TEXT_BLACK") ?? .white
    }
    
    static var ausweisBlue : UIColor {
        return UIColor(named: "CLR_AUSWEIS_BLUE") ?? UIColor.blue
    }
    
    static var oscaColor : UIColor {
        return UIColor(named: "CLR_OSCA_BLUE") ?? UIColor.blue
    }
    
    static var calendarColor: UIColor {
        return UIColor(named: "CLR_NAVBAR_EXPORT") ?? UIColor.white
    }
    
    static var postponeEventStatus: UIColor {
        return UIColor(hexString: "#739B3B")
    }
    
    static var switchStateOn: UIColor {
        return UIColor(named: "CLR_SWITCH_SELECTED_TRUE") ?? UIColor.green
    }
    
    static var switchStateOff: UIColor {
        return UIColor(named: "CLR_SWITCH_SELECTED_FALSE") ?? UIColor.gray
    }
    
    static var switchDisabled: UIColor {
        return UIColor(named: "CLR_SWITCH_DISABLED") ?? UIColor.lightGray
    }
    
    static var swithStateOnWithDisabled: UIColor {
        return UIColor(named: "CLR_SWITCH_SELECTED_TRUE_DISABLED") ?? UIColor.green
    }
}
