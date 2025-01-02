//
//  SCDatePickerCell.swift
//  SmartCity
//
//  Created by Michael on 25.08.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit


class SCDatePickerCell: UICollectionViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var labelBackView: UIView!
    @IBOutlet weak var backRoundedCornerView: UIView!
    
    let pastDayTextColor = UIColor(named: "CLR_LABEL_TEXT_GRAY_SILVERGRAY")!
    let weekendDayTextColor = UIColor(named: "CLR_LABEL_TEXT_GRAY_DARKGRAY")
    let workDayTextColor = UIColor(named: "CLR_LABEL_TEXT_BLACK")!
    let selectedTextColor = UIColor(named: "CLR_LABEL_TEXT_WHITE")!
    let defaultBackColor = UIColor(named: "CLR_BCKGRND")!
    let todayBackColorAlpha : CGFloat = 0.15
    let firstLastSelectedBackColorDarkend : CGFloat = 15.0
    
    var todayBackColor = UIColor.lightGray
    var selectedBackColor = UIColor.gray
    var firstLastSelectedBackColor = UIColor.darkGray

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupAccessibilityIDs()
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        
        self.dayLabel.accessibilityIdentifier = "lbl_day"
    }

    var cityColor: UIColor?{
        didSet {
            if let color = cityColor {
                self.todayBackColor = color.withAlphaComponent(self.todayBackColorAlpha)
                self.selectedBackColor = color
                self.firstLastSelectedBackColor = color.darker(by: self.firstLastSelectedBackColorDarkend) ?? UIColor(named: "CLR_BCKGRND")!
            }
        }
    }
    
    var day : SCDatePickerDay?{
        didSet {
            self.refreshCellState()
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if oldValue != isHighlighted {
                self.refreshCellState()
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if oldValue != isSelected {
                self.refreshCellState()
            }
        }
    }

    var isFirstDayOfSelection: Bool = false {
        didSet {
            if oldValue != isFirstDayOfSelection {
                self.refreshCellState()
            }
        }
    }

    var isLastDayOfSelection: Bool = false {
        didSet {
            if oldValue != isLastDayOfSelection {
                self.refreshCellState()
            }
        }
    }
    
    var isFirstDayOfWeek: Bool = false {
        didSet {
             if oldValue != isFirstDayOfWeek {
                self.setNeedsLayout()
            }
        }
    }

    var isLastDayOfWeek: Bool = false {
        didSet {
             if oldValue != isLastDayOfWeek {
                self.setNeedsLayout()
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if isFirstDayOfWeek {
            self.dayLabel.frame = CGRect(x: 21.0, y: 0.0, width: self.bounds.size.width - 20.0, height: self.bounds.size.height)
        } else if isLastDayOfWeek {
            self.dayLabel.frame = CGRect(x: -1.0, y: 0.0, width: self.bounds.size.width - 22.0, height: self.bounds.size.height)
        } else {
            self.dayLabel.frame = CGRect(x: -1.0, y: 0.0, width: self.bounds.size.width + 2.0, height: self.bounds.size.height)
        }
        self.backView.frame = CGRect(x: -1.0, y: 0.0, width: self.bounds.size.width + 2.0, height: self.bounds.size.height)
        self.labelBackView.frame = self.dayLabel.frame
        self.backRoundedCornerView.frame = self.dayLabel.frame

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.backgroundColor = UIColor(named: "CLR_BCKGRND")!
    }
    
    private func refreshCellState(){

        guard let day = self.day else {
            self.dayLabel.text = ""
            self.dayLabel.textColor = UIColor(named: "CLR_LABEL_TEXT_BLACK")!
            self.dayLabel.backgroundColor = UIColor(named: "CLR_BCKGRND")
            self.backView.backgroundColor = UIColor(named: "CLR_BCKGRND")
            return
        }
        
        self.dayLabel.text = day.dayString.count > 0 ? String(format: "%02d", Int(day.dayString) ?? 0) : day.dayString
        
        var cellTextColor = UIColor.clear
        var cellBackColor = UIColor.clear
        var labelBackColor = UIColor.clear

        switch day.type {
        case .futureWeekend:
            cellTextColor = (isHighlighted || isSelected ? self.selectedTextColor : self.weekendDayTextColor)!
            
            cellBackColor = isHighlighted || isSelected ? self.selectedBackColor : self.defaultBackColor
            
            if (isFirstDayOfSelection || isLastDayOfSelection) {
                labelBackColor = isHighlighted || isSelected ?
                    self.firstLastSelectedBackColor : self.defaultBackColor
            }
        case .futureWorkday:
            cellTextColor = isHighlighted || isSelected ? self.selectedTextColor : self.workDayTextColor
            
            cellBackColor = isHighlighted || isSelected ? self.selectedBackColor : self.defaultBackColor
            
           if (isFirstDayOfSelection || isLastDayOfSelection) {
               labelBackColor = isHighlighted || isSelected ?
                   self.firstLastSelectedBackColor : self.defaultBackColor
           }
        case .today:
            cellTextColor = isHighlighted || isSelected ? self.selectedTextColor : self.workDayTextColor
            
            cellBackColor = isHighlighted || isSelected ? self.selectedBackColor : self.todayBackColor

            if (isFirstDayOfSelection) {
                labelBackColor = isHighlighted || isSelected ?
                    self.firstLastSelectedBackColor : self.todayBackColor
            } else {
                labelBackColor = self.todayBackColor
            }

        case .past:
            cellTextColor = self.pastDayTextColor
            cellBackColor = self.defaultBackColor
            labelBackColor = self.defaultBackColor
        default:
            cellTextColor = self.workDayTextColor
            cellBackColor = self.defaultBackColor
            labelBackColor = self.defaultBackColor
        }
        
        if (isFirstDayOfWeek && isFirstDayOfSelection){
            self.backView.backgroundColor = self.defaultBackColor
        } else if (isLastDayOfWeek && isLastDayOfSelection){
            self.backView.backgroundColor = self.defaultBackColor
        } else if (day.type == .today && !isFirstDayOfSelection){
            self.backView.backgroundColor = self.defaultBackColor
        } else {
            self.backView.backgroundColor = cellBackColor
        }
        self.labelBackView.backgroundColor = labelBackColor
        self.dayLabel.textColor = cellTextColor
        self.dayLabel.backgroundColor = .clear
        
        
        // round corrners
        if (isFirstDayOfSelection && isLastDayOfSelection) {
            self.labelBackView.layer.cornerRadius = 6.0
            self.labelBackView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner,.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
            self.clipsToBounds = true
            self.backRoundedCornerView.backgroundColor = self.defaultBackColor
        } else if (isFirstDayOfSelection) {
            self.labelBackView.layer.cornerRadius = 6.0
            self.labelBackView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
            self.clipsToBounds = true
            self.backRoundedCornerView.backgroundColor = self.defaultBackColor
        } else if (isLastDayOfSelection) {
            self.labelBackView.layer.cornerRadius = 6.0
            self.labelBackView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
            self.clipsToBounds = true
            self.backRoundedCornerView.backgroundColor = self.defaultBackColor
        } else if (day.type == .today) {
            self.labelBackView.layer.cornerRadius = 6.0
            self.labelBackView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner,.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
            self.clipsToBounds = true
            self.backRoundedCornerView.backgroundColor = self.defaultBackColor
        } else {
            self.labelBackView.layer.cornerRadius = 0.0
            self.clipsToBounds = false
            self.backRoundedCornerView.backgroundColor = .clear
        }
    }
}
