//
//  SCDefectReporterMoreInfoProtocol.swift
//  OSCA
//
//  Created by Bhaskar N S on 22/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCDefectReporterMoreInfoViewDisplay : SCDisplaying, AnyObject {
    func setNavigationTitle(_ title : String)
    func pushViewController(_ viewController : UIViewController)
}

protocol SCDefectReporterMoreInfoPresenting : SCPresenting {
    func setDisplay(_ display : SCDefectReporterMoreInfoViewDisplay)
}
