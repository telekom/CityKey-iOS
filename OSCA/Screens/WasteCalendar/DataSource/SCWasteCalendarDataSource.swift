//
//  SCWasteCalendarDataSource.swift
//  OSCA
//
//  Created by Michael on 27.08.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCWasteCalendarDataSouceDelegate: AnyObject {
    func selected(date: SCCalendarDate)
    func didSwitchToMonthValue(_ monthValue: Int)
    func selected(wasteType: SCWasteCalendarDataSourceItem)
}

struct SCWasteCalendarDataSourceItem {
    let dateBaseString: String
    let dayHeader: Bool
    let itemName: String
    let color: UIColor?
    let wasteTypeId: Int
}

class SCWasteCalendarDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    private var wasteCalendarRawItems: [SCModelWasteCalendarItem]
    private var wasteCalendarDCItems: [SCWasteCalendarDataSourceItem]
    private var wasteCalendarDCItemsForExport: [SCWasteCalendarDataSourceItem]
    private weak var delegate: SCWasteCalendarDataSouceDelegate?
    var calendarView = CalendarView.getView()
    private var filterMonth: Int?
    private var filterCategories: [String]
    private var wasteReminders: [SCHttpModelWasteReminder] {
        didSet {
            reminderDictionary.removeAll()
            for reminder in wasteReminders {
                reminderDictionary[reminder.wasteTypeId] = reminder
            }
        }
    }
    
    private var reminderDictionary = [Int: SCHttpModelWasteReminder]()
    
    init(wasteCalendarItems: [SCModelWasteCalendarItem],
         delegate: SCWasteCalendarDataSouceDelegate?,
         wasteReminders: [SCHttpModelWasteReminder]) {
        self.wasteCalendarDCItems = []
        self.wasteCalendarDCItemsForExport = []
        self.wasteCalendarRawItems = wasteCalendarItems
        self.filterCategories = []
        self.delegate = delegate
        self.wasteReminders = wasteReminders
        
        super.init()
        self.convertTo(wasteCalendarItems: wasteCalendarItems, filterMonth: self.filterMonth, filterCategories: self.filterCategories)
    }
    
    public func getFilteredWastCalendarData() -> [SCWasteCalendarDataSourceItem] {
        return wasteCalendarDCItemsForExport
    }
    
    func indexPathForDataBaseString(_ dateBaseString : String) -> IndexPath? {
        var i = 0
        for item in self.wasteCalendarDCItems {
            if item.dateBaseString == dateBaseString && item.dayHeader {
                return IndexPath(item: i, section: 0)
            }
            i += 1
        }
        return  nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.wasteCalendarDCItems.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int)
    -> CGFloat {
        return  (getCalendarHeight(superViewWidth: tableView.bounds.width) + 100)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        calendarView?.setCalendarHeight(superViewWidth: tableView.bounds.width)
        calendarView?.delegate = self
        return calendarView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        // If there is an issue with the table view index
        let item = indexPath.row < self.wasteCalendarDCItems.count ? self.wasteCalendarDCItems[indexPath.row] : SCWasteCalendarDataSourceItem(dateBaseString: "", dayHeader: true, itemName: "", color: nil, wasteTypeId: 0)
        
        if item.dayHeader {
            // handle day header
            let cellID = String(describing: SCWasteCalendarTableViewHeaderCell.self)
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SCWasteCalendarTableViewHeaderCell else {
                return UITableViewCell()
            }
            
            if item.dateBaseString.count > 0 {
                cell.set(title: wasteCalendarDateString(date: Date.dateFromHash(Int(item.dateBaseString)!)!))
            } else {
                cell.set(title:"")
            }
            return cell
        } else {
            // handle waste bin info
            let cellID = String(describing: SCWasteCalendarTableViewCell.self)
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SCWasteCalendarTableViewCell else {
                return UITableViewCell()
            }
            
            cell.set(wasteType: item.itemName, symbolColor: item.color ?? .black, isReminderSet: isReminderSet(wasteTypeID: item.wasteTypeId))
            return cell
        }
    }
    
    private func isReminderSet(wasteTypeID: Int) -> Bool {
        return reminderDictionary[wasteTypeID] != nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = tableView.cellForRow(at: indexPath) as? SCWasteCalendarTableViewCell {
            delegate?.selected(wasteType: wasteCalendarDCItems[indexPath.row])
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    public func getCalendarHeight(superViewWidth: CGFloat) -> CGFloat {
        let height = superViewWidth - (21 * 4) - (10*6)
        return height
    }

    func updateCalendar(calendarItems: [SCModelWasteCalendarItem]) {
        
        calendarView?.update(calendarItems: calendarItems)
        
    }

    func updateDataSource(wasteCalendarItems: [SCModelWasteCalendarItem], wasteReminders: [SCHttpModelWasteReminder]) {
        self.wasteCalendarRawItems = wasteCalendarItems
        self.wasteReminders = wasteReminders
        convertTo(wasteCalendarItems: self.wasteCalendarRawItems, filterMonth: nil, filterCategories: self.filterCategories)
        convertTo(wasteCalendarItems: self.wasteCalendarRawItems, filterMonth: self.filterMonth, filterCategories: self.filterCategories)
    }

    func update(wasteReminders: [SCHttpModelWasteReminder]) {
        self.wasteReminders = wasteReminders
    }

    func updateFilterMonthIFNeeded(_ month : Int?) -> Bool{
        self.filterMonth = month
        convertTo(wasteCalendarItems: self.wasteCalendarRawItems, filterMonth: self.filterMonth, filterCategories: self.filterCategories)
        return true
    }

    func updateFilterCategorieshIFNeeded(_ categories : [String]?)  -> Bool {
        self.filterCategories = categories ?? []
        convertTo(wasteCalendarItems: self.wasteCalendarRawItems, filterMonth: nil, filterCategories: self.filterCategories)
        convertTo(wasteCalendarItems: self.wasteCalendarRawItems, filterMonth: self.filterMonth, filterCategories: self.filterCategories)
        self.calendarView?.update(filterCategories : filterCategories)
        return true
    }

    private func convertTo(wasteCalendarItems: [SCModelWasteCalendarItem], filterMonth: Int?, filterCategories: [String]) {
        let rawItems = wasteCalendarItems.sorted{ $0.dateBaseString < $1.dateBaseString}
        
        let filteredMonthItems = filterMonth == nil ?  rawItems : rawItems.filter {
            Int($0.dateBaseString.prefix(6)) == filterMonth
        }

        let items = filteredMonthItems
        var dcItems : [SCWasteCalendarDataSourceItem] = []
        var lastDateBaseString = ""
        for item in items {
            if item.date >= Date().startOfDay {
                for wasteType in item.wasteTypeList {
                    if filterCategories.contains(wasteType.wasteType) {
                        if item.dateBaseString != lastDateBaseString{
                            lastDateBaseString = item.dateBaseString
                            // add header on each day change
                            dcItems.append(SCWasteCalendarDataSourceItem(dateBaseString: item.dateBaseString, dayHeader: true, itemName: "", color: nil, wasteTypeId: -1))
                        }
                        dcItems.append(SCWasteCalendarDataSourceItem(dateBaseString: item.dateBaseString, dayHeader: false, itemName: wasteType.wasteType, color: UIColor(hexString : wasteType.color), wasteTypeId: wasteType.wasteTypeId))
                    }
                }
            }
        }

        self.wasteCalendarDCItems = dcItems.sorted{ ($0.dateBaseString, $0.itemName) < ($1.dateBaseString, $1.itemName)}
        self.wasteCalendarDCItemsForExport = filterMonth == nil ? self.wasteCalendarDCItems : wasteCalendarDCItemsForExport
    }
    
    func getFilteredMonth() -> Int? {
        filterMonth
    }
}


extension SCWasteCalendarDataSource: CalendarDelegate {
    func didSwitchToMonthValue(_ monthValue: Int) {
        self.delegate?.didSwitchToMonthValue(monthValue)
    }
    
    func didSelectDay(date: SCCalendarDate) {
        delegate?.selected(date: date)
    }
}
