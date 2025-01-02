//
//  SCDateHelper.swift
//  SmartCity
//
//  Created by Alexander Lichius on 24.09.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

func getMonthName(_for date: Date)  -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM"
    return formatter.string(from: date)
}

func getDayName(_for date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "E"
    return formatter.string(from: date)
}

func getYear(_for date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy"
    return formatter.string(from: date)
}

func getTime(_for date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
}

func getTime(_for string: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.date(from: string)
}

func stringFromDate(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd. MMMM yyyy"
    return formatter.string(from: date)
}

func accessibilityConformStringFromDate(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .full
    formatter.timeStyle = .none
    return formatter.string(from: date)
}

func kommunixStringFromDate(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY-MM-dd"
    let dateString = formatter.string(from: date)
    return dateString
}

func infoBoxDateStringFromCreationDate(date: Date) -> String {
    let today = Date()
    if isSameDayFromDate(startDate: date, endDate: today) {
        return getTime(_for: date)
    } else {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}

func wasteCalendarDateString(date: Date) -> String {
    let today = Date()
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
    if isSameDayFromDate(startDate: date, endDate: today) {
        return "date_format_today_name".localized()
    } else if isSameDayFromDate(startDate: date, endDate: tomorrow) {
        return "date_format_tomorrow_name".localized()
    } else {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd. MMMM "
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}


func dateFromString(dateString: String) -> Date? {
    
    let dateformatter = dateFormatter()
    let newDate = dateformatter.date(from: dateString)
    if let date = newDate {
        return date
    }
    return nil
}

func birthdayDateFromString(dateString: String) -> Date? {
    let dateformatter = birthdayDateFormatter()
    let date = dateformatter.date(from: dateString)
    if let date = date {
        return date
    }
    return nil
}

func birthdayStringFromDate(birthdate: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd. MMMM yyyy" //"dd.MM.yyyy"
    let birthdayString = dateFormatter.string(from: birthdate)
    return birthdayString
}

func transactionDateString(date: Date) -> String {
    return birthdayStringFromDate(birthdate: date)
}

func isSameDayFromDate(startDate: Date?, endDate: Date?) -> Bool {
    if let startDate = startDate, let endDate = endDate {
        return Calendar.current.isDate(startDate, inSameDayAs: endDate)
    }
    return true
}

func dateFormatter() -> DateFormatter {
    let dateformatter = DateFormatter()
    dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateformatter.locale = Locale(identifier: Locale.current.identifier)
    return dateformatter
}

func birthdayDateFormatter() -> DateFormatter {
    let dateformatter = DateFormatter()
    dateformatter.dateFormat = "yyyy-MM-dd".localized()
    return dateformatter
}

func appointmentDate(from string: String) -> (day: String, date:String)? {
    if let date = dateFromString(dateString: string) {
        let dateString = birthdayStringFromDate(birthdate: date)
        let day = getDayName(_for: date)
        return (day, dateString)
    }
    return nil
}

func appointmentTime(from string: String) -> String? {
    if let date = dateFromString(dateString: string) {
        return getTime(_for: date)
    }
    return nil
}

func defectReportDateFormatter() -> DateFormatter {
    let dateformatter = DateFormatter()
    dateformatter.dateFormat = "dd. MMMM yyyy"//"d MMMM. yyyy - h:mm a".localized()
    return dateformatter
}

func defectReportStringFromDate(date: Date) -> String {
    let dateFormatter = defectReportDateFormatter()
    let defectReportString = dateFormatter.string(from: date)
    return defectReportString
}

func appointmentDateStringFromDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.yyyy"
    let dateString = dateFormatter.string(from: date)
    return dateString
}

func birthdateStringFrom(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.yyyy"
    let dateString = dateFormatter.string(from: date)
    return dateString
}

func getLocalizedMonths() -> [String] {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.current
    return dateFormatter.monthSymbols
}

extension Date {

    static func getWeekDay(index: Int) -> String? {
        guard index < 7 else {
            return nil
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale.autoupdatingCurrent
        return calendar.shortWeekdaySymbols[index]
    }

    func isHistoric() -> Bool {
        return Date() > self
    }

    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    
    func difference(from date: Date) -> Int {
        let calendar = Calendar.current
        let startOfSelf = calendar.startOfDay(for: self)
        let startOfDate = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: startOfSelf, to: startOfDate).day ?? 0
    }
    
    func extractYear() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: self)
    }
}

extension String {
    func extractYear() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: self) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            return dateFormatter.string(from: date)
        }
        return nil
    }
}
