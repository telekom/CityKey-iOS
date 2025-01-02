//
//  SCSelectionDisplayingProtocolDefinitions.swift
//  SmartCity
//
//  Created by Alexander Lichius on 22.10.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

protocol SCSelectionDisplaying: SCDisplaying {
    func updateCategories(categories: [SCModelCategory], preselectedItems: [SCModelCategory]?)
    func setProgressStateToFilterEventsButton()
    func setNormalStateToFilterEventsButton()
    func updateButtonStatus()
    func dismiss(completion: (() -> Void)?)
    func clearAllButton(isHidden: Bool)
    func setTitleForShowEventsButton(title: String)
    func setupUI(title: String)
    func startActivityIndicator()
    func stopActivityIndicator()
    func hideUnhideSelectAllButton(isHidden: Bool)
    func getSourceFlowType() -> ControllerSource
}
