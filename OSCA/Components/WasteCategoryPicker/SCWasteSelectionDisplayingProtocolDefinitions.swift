//
//  SCWasteSelectionDisplayingProtocolDefinitions.swift
//  SmartCity
//
//  Created by Harshada Deshmukh on 18/05/22.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

protocol SCWasteSelectionDisplaying: SCDisplaying {
    func updateCategories(categories: [SCModelCategoryObj], preselectedItems: [SCModelCategoryObj]?)
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
}
