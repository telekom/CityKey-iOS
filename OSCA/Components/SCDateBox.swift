//
//  SCDateBox.swift
//  SmartCity
//
//  Created by Alexander Lichius on 24.09.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

enum Month: String {
    case Monday
}

class SCDateBox: UIView {
    
    @IBOutlet weak var dayNameMonthLabel: UILabel!
    @IBOutlet weak var dayNumberLabel: UILabel!
    @IBOutlet weak var leftColumn: UIView!
    @IBOutlet weak var dashColumn: UIView!
    @IBOutlet weak var rightColumn: UIView!
    @IBOutlet weak var startDateDayLabel: UILabel!
    @IBOutlet weak var startDateNumberLabel: UILabel!
    @IBOutlet weak var startDateMonthLabel: UILabel!
    @IBOutlet weak var endDateDayLabel: UILabel!
    @IBOutlet weak var endDateNumberLabel: UILabel!
    @IBOutlet weak var endDateMonthLabel: UILabel!
    
    var startDate : Date?
    var endDate : Date?

    // This prevents a color change when the cell gets selected. A cell will change also all backgroundColors of the subviews
    override var backgroundColor: UIColor? {
        didSet {
            if backgroundColor != nil && backgroundColor!.cgColor.alpha == 0 {
                backgroundColor = oldValue
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupAccessibility()
        handleDynamicTypeChange()
    }
    
    
    private func setupAccessibility(){
        self.dayNameMonthLabel.accessibilityElementsHidden = true
        self.dayNumberLabel.accessibilityElementsHidden = true
        self.startDateDayLabel.accessibilityElementsHidden = true
        self.startDateNumberLabel.accessibilityElementsHidden = true
        self.startDateMonthLabel.accessibilityElementsHidden = true
        self.endDateDayLabel.accessibilityElementsHidden = true
        self.endDateNumberLabel.accessibilityElementsHidden = true
        self.endDateMonthLabel.accessibilityElementsHidden = true
    }

    func getAccessibilityContent() -> String{
        
        guard let startDate = self.startDate else {
            return ""
        }
        
        var content = accessibilityConformStringFromDate(date: startDate)
        
        if endDate != nil {
            content +=  "accessibility_label_date_until".localized() + ", " + accessibilityConformStringFromDate(date: endDate!)
        }
        
        return content
    }

    func configure(_with date: Date) {
        self.hideColumns(hide: true)
        self.hideDateLabels(hide: false)
        self.layer.cornerRadius = 4.0
        self.backgroundColor = UIColor(named: "CLR_OSCA_BLUE")!
        let calendarDate = Calendar.current.dateComponents([.day], from: date)
        dayNumberLabel.attributedText = String(calendarDate.day!).applyHyphenation()
        var dayNameMonthText = getDayName(_for: date)
        dayNameMonthText.append(", ")
        dayNameMonthText.append(getMonthName(_for: date))
        dayNameMonthLabel.attributedText = dayNameMonthText.applyHyphenation()
        dayNumberLabel.textAlignment = .center
        dayNameMonthLabel.textAlignment = .center
        self.startDate = date
        self.endDate = nil
    }
    
    func configure(_with startDate: Date, endDate: Date) {
        self.hideDateLabels(hide: true)
        self.hideColumns(hide: false)
        self.layer.cornerRadius = 4.0
        self.backgroundColor = UIColor(named: "CLR_OSCA_BLUE")!
        let startCalendarDate = Calendar.current.dateComponents([.day], from: startDate)
        let endCalendarDate = Calendar.current.dateComponents([.day], from: endDate)
        self.startDateNumberLabel.attributedText = String(startCalendarDate.day!).applyHyphenation()
        self.endDateNumberLabel.attributedText = String(endCalendarDate.day!).applyHyphenation()
        self.startDateDayLabel.text = getDayName(_for: startDate)
        self.endDateDayLabel.text = getDayName(_for: endDate)
        self.startDateMonthLabel.text = getMonthName(_for: startDate)
        self.endDateMonthLabel.text = getMonthName(_for: endDate)
        self.startDate = startDate
        self.endDate = endDate
    }
    
    func hideColumns(hide: Bool) {
        self.dashColumn.isHidden = hide
        self.leftColumn.isHidden = hide
        self.rightColumn.isHidden = hide
    }
    
    func hideDateLabels(hide: Bool) {
        self.dayNameMonthLabel.isHidden = hide
        self.dayNumberLabel.isHidden = hide
    }
    
    @objc func handleDynamicTypeChange() {
        // Dynamic font
        
        dayNumberLabel.adjustsFontForContentSizeCategory = true
        dayNumberLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 18, maxSize: 25)
        dayNameMonthLabel.adjustsFontForContentSizeCategory = true
        dayNameMonthLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 10, maxSize: 20)
        startDateNumberLabel.adjustsFontForContentSizeCategory = true
        startDateNumberLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 11, maxSize: 15)
        endDateNumberLabel.adjustsFontForContentSizeCategory = true
        endDateNumberLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 11, maxSize: 15)
        startDateDayLabel.adjustsFontForContentSizeCategory = true
        startDateDayLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 10, maxSize: 13)
        endDateDayLabel.adjustsFontForContentSizeCategory = true
        endDateDayLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 10, maxSize: 13)
        startDateMonthLabel.adjustsFontForContentSizeCategory = true
        startDateMonthLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 10, maxSize: 13)
        endDateMonthLabel.adjustsFontForContentSizeCategory = true
        endDateMonthLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 10, maxSize: 13)
            
        dayNumberLabel.numberOfLines = 0
        dayNameMonthLabel.numberOfLines = 0
        startDateNumberLabel.numberOfLines = 0
        endDateNumberLabel.numberOfLines = 0
        startDateDayLabel.numberOfLines = 0
        endDateDayLabel.numberOfLines = 0
        startDateMonthLabel.numberOfLines = 0
        endDateMonthLabel.numberOfLines = 0
    }

}
