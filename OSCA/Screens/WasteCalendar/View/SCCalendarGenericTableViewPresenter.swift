//
//  CalendarGenericTableViewPresenter.swift
//  OSCA
//
//  Created by A118572539 on 30/12/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCCalendarGenericTableViewPresenting: SCPresenting {
    func getTableViewItems() -> [String]
    func colorSelected(with color: UIColor, name: String)
    func setDisplay(_ display: SCCalendarGenericTableViewDisplaying)
    func getSelectedColorName() -> String
}

protocol SCCalendarGenericTableViewDisplaying: SCDisplaying{
    func setupUI(title: String, backTitle: String)
    func present(viewController: UIViewController)
    func push(viewController: UIViewController)
}

class SCCalendarGenericTableViewPresenter {
    
    private var display: SCCalendarGenericTableViewDisplaying?
    private var selectedColor: String
    weak var delegate: SCColorSelectionDelegate?
    
    var items: [String]
    
    init(items: [String], selectedColorName: String, delegate: SCColorSelectionDelegate) {
        self.items = items
        self.delegate = delegate
        self.selectedColor = selectedColorName
    }
}

extension SCCalendarGenericTableViewPresenter: SCCalendarGenericTableViewPresenting {
    func viewDidLoad() {
        
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func getTableViewItems() -> [String] {
        return items
    }
    
    func setDisplay(_ display: SCCalendarGenericTableViewDisplaying) {
        self.display = display
    }
    
    func colorSelected(with color: UIColor, name: String) {
        delegate?.selectedColor(color: color, name: name)
    }
    
    func getSelectedColorName() -> String {
        return selectedColor
    }
}
