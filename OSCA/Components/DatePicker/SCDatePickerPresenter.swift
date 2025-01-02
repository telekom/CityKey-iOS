//
//  SCDatePickerPresenter.swift
//  SmartCity
//
//  Created by Michael on 25.08.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

enum dayType {
    case past
    case today
    case futureWorkday
    case futureWeekend
    case empty
}

struct SCDatePickerDay {
    let dayString : String
    let dayValue : Int // 20190801
    let type : dayType
}

protocol SCDatePickerDisplaying: AnyObject, SCDisplaying  {
    func setupUI()
    func reloadData()
    func unselectAllSelectedCells()
    func selectCells(monthIndex : Int, dayIndex : Int)
    func dismiss(completion: (() -> Void)?)
    func applyProgressStateToFilterBtn()
    func refreshFilterBtnWithCount(_ count : Int)
    func clearAllButton(isHidden: Bool)
}

protocol SCDatePickerDataSource {
    func setDisplay(_ display: SCDatePickerDisplaying)
    func numberOfMonthInDatePicker() -> Int
    func numberOfDaysForMonthIndex(monthIndex : Int) -> Int
    func isDaySelectable(_ day : SCDatePickerDay) -> Bool
    func isDaySelected(_ day : SCDatePickerDay) -> Bool
    func isFirstDayOfSelection(_ day : SCDatePickerDay) -> Bool
    func isLastDayOfSelection(_ day : SCDatePickerDay) -> Bool

    func day(for monthIndex : Int, dayIndex : Int) -> SCDatePickerDay
    func title(for monthIndex : Int) -> String
}

protocol SCDatePickerPresenting: SCPresenting, SCDatePickerDataSource {
    
    func dayWasSelected(_ day : SCDatePickerDay)
    func filterButtonWasPressed()
    func closeButtonWasPressed()
    func clearAllButtonWasPressed()
}

protocol SCDatePickerDelegate: AnyObject {
    func datePickerNeedsResultCount(startDay : Date?, endDay : Date?, completion: @escaping (_ count: Int) ->())
    func datePickerDidFinish(startDay : Date?, endDay : Date?, filterCount: Int, completion: @escaping (_ success: Bool) ->())
}

class SCDatePickerPresenter {
  
    weak var delegate: SCDatePickerDelegate?

    weak private var display: SCDatePickerDisplaying?
    private let injector: SCAdjustTrackingInjection
    private let preSelectedStartDate : Date?
    private let preSelectedEndDate : Date?
    
    private var filterCount = 0

    private var calenderMonths:[[SCDatePickerDay]] = []
    private var calenderMonthTitles:[String] = []
    private var selectedStartDay = -1
    private var selectedEndDay = -1
    private let calendar = Calendar(identifier: Calendar.Identifier.iso8601)

    private let maxMonth : Int
    private let emptyDateValue = -1

    let todayDate : Date
    
    init(injector: SCAdjustTrackingInjection, todayDate : Date, maxMonth : Int, preSelectedStartDate: Date?, preSelectedEndDate: Date?) {
        self.todayDate = todayDate
        
        self.maxMonth = maxMonth
        
        self.preSelectedStartDate = preSelectedStartDate
        self.preSelectedEndDate = preSelectedEndDate
        self.injector = injector
    }
    
    deinit {

    }
    
    
    func reloadData(_ today : Date?){
        
        self.calenderMonths = []
        self.calenderMonthTitles = []

        let calendarToday = today == nil ? Date() : today
        
        var year = calendar.component(.year, from: calendarToday!)
        var month = calendar.component(.month, from: calendarToday!)
        
        for _ in 0...maxMonth{
            
            let days = getDaysOfMonth(month, year: year, todayDate: Date() )
            self.calenderMonths.append(days)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM yyyy"

            let monthTitle = dateFormatter.string(from: self.firstDayOfMonth(month, year: year)!)
            self.calenderMonthTitles.append(monthTitle)

            month += 1
            
            if month > 12 {
                month = 1
                year += 1
            }
            
        }
        
        self.display?.reloadData()
        self.display?.clearAllButton(isHidden: selectedStartDay == emptyDateValue)
    }
    


    func firstDayOfMonth(_ month : Int, year : Int) -> Date?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let startOfMonth = ("\(year)-\(month)-01")
        if let firstDayOfMonth = dateFormatter.date(from: startOfMonth) {
            return firstDayOfMonth
        }
        return nil
    }
    
    func getDaysOfMonth(_ month: Int, year: Int, todayDate: Date) -> [SCDatePickerDay]{
        var _days = [SCDatePickerDay]()
        
        if let firstDayOfMonth = self.firstDayOfMonth(month, year: year) {
            
            let weeksCount = calendar.range(of: .weekOfMonth, in: .month, for: firstDayOfMonth)!.count
            let firstWeekdayOfMonth = calendar.component(.weekday, from: firstDayOfMonth)
            let firstWeekday = (firstWeekdayOfMonth + 7 - self.calendar.firstWeekday) % 7 + 1
            let daysCount = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!.count
            
            for i in 1...weeksCount*7
            {
                if i < firstWeekday || i > daysCount + firstWeekday - 1
                {
                    _days.append(SCDatePickerDay(dayString: "", dayValue: 0, type: .empty))
                } else
                {
                    
                    let day = i - firstWeekday + 1
                    let newDayHash = year * 10000 + month * 100 + day
                    
                    if newDayHash < Date.hashForDate(todayDate){
                        _days.append(SCDatePickerDay(dayString: String(describing: day), dayValue: newDayHash, type: .past))
                    } else if newDayHash == Date.hashForDate(todayDate){
                        _days.append(SCDatePickerDay(dayString: String(describing: day), dayValue: newDayHash, type: .today))
                    } else {
                        
                        if (i % 7 == 0)  || ((i + 1) % 7 == 0){
                            _days.append(SCDatePickerDay(dayString: String(describing: day), dayValue: newDayHash, type: .futureWeekend))
                        
                        } else {
                            _days.append(SCDatePickerDay(dayString: String(describing: day), dayValue: newDayHash, type: .futureWorkday))
                            
                        }
                    }
                }
            }
        }
        return _days
    }

    private func refreshSelectedCells() {
        self.display?.unselectAllSelectedCells()
        
        for month in 0...self.calenderMonths.count - 1{
            let days = self.calenderMonths[month]
            for dayOfMonth in 0...days.count - 1{
                let day = days[dayOfMonth]
                if self.isDaySelected(day) {
                    self.display?.selectCells(monthIndex: month, dayIndex: dayOfMonth)
                }
                
            }
        }
    }
    
    private func refreshFilterItemCount(){
        let startDay = Date.dateFromHash(selectedStartDay)
        let endDay = Date.dateFromHash(selectedEndDay)
        
        self.delegate?.datePickerNeedsResultCount(startDay: startDay, endDay: endDay, completion: { (count) in
            self.display?.refreshFilterBtnWithCount(count)
            self.filterCount = count
        })
    }
}

extension SCDatePickerPresenter: SCPresenting {
    func viewDidLoad() {
        //self.injector.trackEvent(eventName: "OpenEventsDateFilter")
        self.display?.setupUI()
        self.reloadData(Date())
        SCUtilities.delay(withTime: 0.0, callback: {
            if let startDate = self.preSelectedStartDate{
                self.selectedStartDay = Date.hashForDate(startDate)
            }
            
            if let endDate = self.preSelectedEndDate{
                self.selectedEndDay = Date.hashForDate(endDate)
            }

            self.refreshSelectedCells()
            self.refreshFilterItemCount()
            self.display?.clearAllButton(isHidden: self.selectedStartDay == self.emptyDateValue)
        })
    }
    
    func viewWillAppear() {
    }
    
    func viewDidAppear() {
    }
}

extension SCDatePickerPresenter: SCDatePickerDataSource {

    func numberOfMonthInDatePicker() -> Int {
        return self.maxMonth
    }
    
    func numberOfDaysForMonthIndex(monthIndex : Int) -> Int {
        return calenderMonths[monthIndex].count
    }

    func isDaySelectable(_ day : SCDatePickerDay) -> Bool {
        if day.type == .empty || day.type == .past{
            return false
        }
        return true
    }
    
    func isDaySelected(_ day : SCDatePickerDay) -> Bool {
        if !self.isDaySelectable(day){
            return false
        }
        let validEndDayValue = self.selectedEndDay == -1 ? self.selectedStartDay : self.selectedEndDay
        return day.dayValue >= self.selectedStartDay && day.dayValue <= validEndDayValue
    }

    func isFirstDayOfSelection(_ day : SCDatePickerDay) -> Bool {
        if !self.isDaySelectable(day){
            return false
        }
        return day.dayValue == self.selectedStartDay
    }

    func isLastDayOfSelection(_ day : SCDatePickerDay) -> Bool {
        if !self.isDaySelectable(day){
            return false
        }
        let validEndDayValue = self.selectedEndDay == -1 ? self.selectedStartDay : self.selectedEndDay
        return day.dayValue == validEndDayValue
    }

    func day(for monthIndex : Int, dayIndex : Int) -> SCDatePickerDay{
        if monthIndex < self.calenderMonths.count && dayIndex < self.calenderMonths[monthIndex].count {
            let days = self.calenderMonths[monthIndex]
           return days[dayIndex]
        }
        return SCDatePickerDay(dayString: "", dayValue: 0, type: .empty)
    }
    
    func title(for monthIndex : Int) -> String{
        if monthIndex < self.calenderMonthTitles.count {
            return self.calenderMonthTitles[monthIndex]
        }
        return ""
    }

}

extension SCDatePickerPresenter: SCDatePickerPresenting {
    
    func setDisplay(_ display: SCDatePickerDisplaying) {
        self.display = display
    }

    internal func dayWasSelected(_ day : SCDatePickerDay){
        if !self.isDaySelectable(day){
            return
        }
        let dateValue = day.dayValue
        if self.selectedStartDay == emptyDateValue {
            self.selectedStartDay = dateValue
            self.refreshSelectedCells()
        } else if self.selectedEndDay == emptyDateValue {
            // if we select an already selected day then we will unselect all
            if self.selectedStartDay == dateValue {
                self.selectedStartDay = emptyDateValue
                self.refreshSelectedCells()
            } else {
                if dateValue < self.selectedStartDay {
                    self.selectedEndDay = selectedStartDay
                    self.selectedStartDay = dateValue
                } else {
                    self.selectedEndDay = dateValue
                }
                self.refreshSelectedCells()
            }
        } else {
            selectedStartDay = dateValue
            selectedEndDay = emptyDateValue
            self.refreshSelectedCells()
        }
        

        self.display?.clearAllButton(isHidden: selectedStartDay == emptyDateValue)
        self.refreshFilterItemCount()
    }

    func closeButtonWasPressed() {
        self.display?.dismiss(completion: nil)
    }
    
    func clearAllButtonWasPressed() {
        selectedStartDay = emptyDateValue
        selectedEndDay = emptyDateValue
        self.refreshSelectedCells()
        self.refreshFilterItemCount()
        self.display?.clearAllButton(isHidden: true)
    }
    
    func filterButtonWasPressed(){
        let startDay = Date.dateFromHash(selectedStartDay)
        let endDay = Date.dateFromHash(selectedEndDay)
        
        self.delegate?.datePickerDidFinish(startDay: startDay, endDay: endDay, filterCount: self.filterCount, completion: { (success) in })
        
        SCUtilities.delay(withTime: 0.5, callback: {
            self.display?.dismiss(completion: nil)
        })

    }

}
