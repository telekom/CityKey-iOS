//
//  ViewController.swift
//  Calendar
//
//  Created by Rutvik Kanbargi on 17/08/20.
//  Copyright © 2020 Rutvik Kanbargi. All rights reserved.
//

import UIKit

enum SCCalendarDayType {
    case past
    case today
    case futureWorkday
    case futureWeekend
    case empty

    func getDayViewConfig() -> CalendarCellConfig {
        switch self {
        case .past:
            return  CalendarCellConfig(backgroundColor: UIColor(named: "CLR_BCKGRND")!,
                                       labelColor: UIColor(named: "CLR_LABEL_TEXT_GRAY_GRAY")!)
        case .today:
            return  CalendarCellConfig(backgroundColor: kColor_cityColor.withAlphaComponent(0.2),
                                       labelColor: UIColor(named: "CLR_LABEL_TEXT_BLACK")!)
        case .futureWorkday:
            return CalendarCellConfig(backgroundColor: UIColor(named: "CLR_BCKGRND")!,
                                      labelColor: UIColor(named: "CLR_LABEL_TEXT_BLACK")!)
        case .futureWeekend:
            return CalendarCellConfig(backgroundColor: UIColor(named: "CLR_BCKGRND")!,
                                      labelColor: UIColor(named: "CLR_LABEL_TEXT_BLACK")!)
        case .empty:
            return CalendarCellConfig(backgroundColor: UIColor(named: "CLR_BCKGRND")!,
                                      labelColor: UIColor(named: "CLR_BCKGRND")!) // SMARTC-1399: past and empty days should be invisible, previous: CLR_LABEL_TEXT_GRAY_GRAY
        }
    }

    func getDeSelectedBackgroundColor() -> UIColor {
        switch self {
        case .today:
            return kColor_cityColor.withAlphaComponent(0.2)
        default:
            return  UIColor(named: "CLR_BCKGRND")!
        }
    }

    func isSelectable() -> Bool {
        switch self {
        case .today, .futureWeekend, .futureWorkday :
            return true
        case .empty, .past:
            return false
        }
    }
}

struct SCCalendarDate {
    let dayString : String
    let dayValue : Int // 20190801
    let type : SCCalendarDayType
    let wasteBins: [SCModelWasteBinType]
}

protocol CalendarActionDelegate: AnyObject {
    func willSwitchToMonth(name: String, monthValue: Int) // 201908
    func didSwitchToMonth()
    func didSelectDay(date: SCCalendarDate)
    func handlePreviousCalendarButtonInteraction(enabled: Bool)
    func handleNextCalendarButtonInteraction(enabled: Bool)
}

protocol CalendarDelegate: AnyObject {
    func didSwitchToMonthValue(_ monthValue: Int)
    func didSelectDay(date: SCCalendarDate)
}

class CalendarView: UIView {

    @IBOutlet weak var calendarOuterCollectionView: UICollectionView!
    @IBOutlet weak var monthNamelabel: UILabel!
    @IBOutlet weak var calendarOutercollectionViewHeight: NSLayoutConstraint!

    @IBOutlet weak var nextCalendarButton: UIButton!
    @IBOutlet weak var previousCalendarButton: UIButton!
    
    @IBOutlet weak var mondayLabel: UILabel! {
        didSet {
            mondayLabel.text = Date.getWeekDay(index: 1)
            mondayLabel.accessibilityElementsHidden = true
            mondayLabel.adjustsFontForContentSizeCategory = true
            mondayLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 14, maxSize: 20)
        }
    }

    @IBOutlet weak var tuesdayLabel: UILabel! {
        didSet {
            tuesdayLabel.text = Date.getWeekDay(index: 2)
            tuesdayLabel.accessibilityElementsHidden = true
            tuesdayLabel.adjustsFontForContentSizeCategory = true
            tuesdayLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 14, maxSize: 20)
        }
    }

    @IBOutlet weak var wednesdayLabel: UILabel! {
        didSet {
            wednesdayLabel.text = Date.getWeekDay(index: 3)
            wednesdayLabel.accessibilityElementsHidden = true
            wednesdayLabel.adjustsFontForContentSizeCategory = true
            wednesdayLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 14, maxSize: 20)
        }
    }

    @IBOutlet weak var thursdayLabel: UILabel! {
        didSet {
            thursdayLabel.text = Date.getWeekDay(index: 4)
            thursdayLabel.accessibilityElementsHidden = true
            thursdayLabel.adjustsFontForContentSizeCategory = true
            thursdayLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 14, maxSize: 20)
        }
    }

    @IBOutlet weak var fridayLabel: UILabel! {
        didSet {
            fridayLabel.text = Date.getWeekDay(index: 5)
            fridayLabel.accessibilityElementsHidden = true
            fridayLabel.adjustsFontForContentSizeCategory = true
            fridayLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 14, maxSize: 20)
        }
    }

    @IBOutlet weak var saturdayLabel: UILabel! {
        didSet {
            saturdayLabel.text = Date.getWeekDay(index: 6)
            saturdayLabel.accessibilityElementsHidden = true
            saturdayLabel.adjustsFontForContentSizeCategory = true
            saturdayLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 14, maxSize: 20)
        }
    }

    @IBOutlet weak var sundayLabel: UILabel! {
        didSet {
            sundayLabel.text = Date.getWeekDay(index: 0)
            sundayLabel.accessibilityElementsHidden = true
            sundayLabel.adjustsFontForContentSizeCategory = true
            sundayLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 14, maxSize: 20)
        }
    }

    private var calenderMonths:[[SCCalendarDate]] = []
    private var calenderMonthTitles:[String] = []
    private var calenderMonthValues:[Int] = []
    private var maxMonth : Int = 12
    private let calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    private var wasteData: [String: [SCModelWasteBinType]] = [:]
    private var selectedMonthValue : Int?
    private var dataSource: CalendarOuterCollectionViewDataSource?

    private let numberOfItemPerRow = 7
    private let margineSpace: CGFloat = 21
    private var filterCategories: [String]?
    
    weak var delegate: CalendarDelegate?

    class func getView() -> CalendarView? {
        let calView =  UINib(nibName: "CalendarView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? CalendarView
        calView?.setup()
        return calView
    }

    func update(calendarItems : [SCModelWasteCalendarItem]) {
        
        wasteData = calendarItems.reduce(into: [String: [SCModelWasteBinType]]()) {
            $0[$1.dateBaseString] = $1.wasteTypeList
        }
        
       let lastCalendarItem = calendarItems.max { (first, second) -> Bool in
            first.date < second.date
        }
        
        if let lastCalendarItemDate = lastCalendarItem?.date {
            debugPrint("Last Calendar item date => \(lastCalendarItemDate)")
            
             maxMonth = getNumberMonthAllowed(lastCalendarItemDate) ?? 12
            debugPrint("Maximum month => \(maxMonth)")
        }

        reloadData(Date())
    }

    func update(filterCategories : [String]) {
        
        self.filterCategories = filterCategories
        reloadData(Date())
    }

    func setCalendarHeight(superViewWidth: CGFloat) {
        let height = superViewWidth - (margineSpace * 4) - (10*6)
        calendarOutercollectionViewHeight.constant = height
    }

    private func registerCell() {
        let cellID = String(describing: CalendarOuterCollectionViewCell.self)
        let nib = UINib(nibName: cellID, bundle: nil)
        calendarOuterCollectionView.register(nib, forCellWithReuseIdentifier: cellID)
    }

    private func setup() {
        registerCell()
        nextCalendarButton.setImage(UIImage(named: "calendar-arrow-right")?.maskWithColor(color: UIColor(named: "CLR_ICON_SCND_ACTION")!), for: .normal)
        nextCalendarButton.addCornerRadius()
        nextCalendarButton.addBorder()
        calendarOuterCollectionView.delaysContentTouches = false

        previousCalendarButton.setImage(UIImage(named: "calendar-arrow-left")?.maskWithColor(color: UIColor(named: "CLR_ICON_SCND_ACTION")!), for: .normal)
        previousCalendarButton.addCornerRadius()
        previousCalendarButton.addBorder()
        
        // for accessibility handling
        setupAccessibilityIDs()
        setupAccessibility()
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        nextCalendarButton.accessibilityIdentifier = "btn_next_calendar"
        previousCalendarButton.accessibilityIdentifier = "btn_previous_calendar"
    }

    private func setupAccessibility(){
        nextCalendarButton.accessibilityTraits = .button
        nextCalendarButton.accessibilityLabel = LocalizationKeys.SCWasteCalendarViewController.accessibilityBtnNextMonth.localized()
        nextCalendarButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        previousCalendarButton.accessibilityTraits = .button
        previousCalendarButton.accessibilityLabel = LocalizationKeys.SCWasteCalendarViewController.accessibilityBtnPreviousMonth.localized()
        previousCalendarButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
    
    private func setDataSource() {
        dataSource = CalendarOuterCollectionViewDataSource(calenderMonths: calenderMonths,
                                                           calenderMonthTitles: calenderMonthTitles,
                                                           calenderMonthValues: calenderMonthValues,
                                                           delegate: self)
        calendarOuterCollectionView.delegate = dataSource
        calendarOuterCollectionView.dataSource = dataSource
        calendarOuterCollectionView.reloadData()
    }

    @IBAction func didTapOnPreviousMonth(_ sender: UIButton) {
        scrollCalendarBy(value: -1)
    }

    @IBAction func didTapOnNextMonth(_ sender: UIButton) {
        scrollCalendarBy(value: 1)
    }

    private func scrollCalendarBy(value: Int) {
        let index = calendarOuterCollectionView.indexPathsForVisibleItems
        guard let indexPath = index.first else {
            return
        }

        if value > 0, indexPath.item != maxMonth {
                let newIndexPath = IndexPath(item: indexPath.item + value, section: indexPath.section)
                calendarOuterCollectionView.scrollToItem(at: newIndexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        } else if value < 0, indexPath.item != 0 {
            let newIndexPath = IndexPath(item: indexPath.item + value, section: indexPath.section)
            calendarOuterCollectionView.scrollToItem(at: newIndexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        }
    
        debugPrint("Current index of calendar => \(indexPath.item)")
    }

    func scrollToNextMonth() {
        scrollCalendarBy(value: 1)
    }
}

extension CalendarView: CalendarActionDelegate {

    func willSwitchToMonth(name: String, monthValue: Int) {
        let year = monthValue / 100
        monthNamelabel.text = "\(name) \(year)"

        if selectedMonthValue == nil {
            self.selectedMonthValue = monthValue
            self.didSwitchToMonth()
        } else {
            self.selectedMonthValue = monthValue
        }
        
        monthNamelabel.adjustsFontForContentSizeCategory = true
        monthNamelabel.font = UIFont.SystemFont.medium.forTextStyle(style: .body, size: 24, maxSize: 28)
    }

    func didSwitchToMonth() {
        self.delegate?.didSwitchToMonthValue(self.selectedMonthValue!)
    }

    func didSelectDay(date: SCCalendarDate) {
        self.delegate?.didSelectDay(date: date)
    }

    func handleNextCalendarButtonInteraction(enabled: Bool) {
        nextCalendarButton.isUserInteractionEnabled = enabled
        animate(button: nextCalendarButton, alpha: enabled ? 1.0 : 0.3)
    }

    func handlePreviousCalendarButtonInteraction(enabled: Bool) {
        previousCalendarButton.isUserInteractionEnabled = enabled
        animate(button: previousCalendarButton, alpha: enabled ? 1.0 : 0.3)
    }

    private func animate(button: UIButton, alpha: CGFloat) {
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        button.alpha = alpha
            },completion: nil)
    }
}

extension CalendarView {

    func reloadData(_ today : Date?) {
        self.calenderMonths = []
        self.calenderMonthTitles = []

        let calendarToday = today == nil ? Date() : today
        
        var year = calendar.component(.year, from: calendarToday!)
        var month = calendar.component(.month, from: calendarToday!)

        for _ in 0...maxMonth {
            let days = getDaysOfMonth(month, year: year, todayDate: Date(), wasteData: wasteData)
            self.calenderMonths.append(days)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM"

            let monthTitle = dateFormatter.string(from: self.firstDayOfMonth(month, year: year)!)
            self.calenderMonthTitles.append(monthTitle)
            self.calenderMonthValues.append(year*100+month) //202008

            month += 1

            if month > 12 {
                month = 1
                year += 1
            }
        }

        setDataSource()
    }

    func getDaysOfMonth(_ month: Int,
                        year: Int,
                        todayDate: Date,
                        wasteData: [String: [SCModelWasteBinType]]) -> [SCCalendarDate] {
        var _days = [SCCalendarDate]()
        
        if let firstDayOfMonth = self.firstDayOfMonth(month, year: year) {
            let firstWeekdayOfMonth = calendar.component(.weekday, from: firstDayOfMonth)
            let firstWeekday = (firstWeekdayOfMonth + 7 - self.calendar.firstWeekday) % 7 + 1
            let daysCount = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!.count
            
            let previousMonth = calendar.date(byAdding: .month, value: -1, to: firstDayOfMonth)!
            debugPrint("Previous month => \(previousMonth)")
            debugPrint("Previous month day => \(String(describing: endOfCurrentMonth(previousMonth)))")
            let endDateOfPreviousMonth = endOfCurrentMonth(previousMonth)!
            let endDay = calendar.component(.day, from: endDateOfPreviousMonth)
            debugPrint("Previous month day => \(endDay)")
            
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstDayOfMonth)!
            debugPrint("Next month => \(nextMonth)")
            debugPrint("Next month day => \(String(describing: startOfCurrentMonth(nextMonth)))")
            
            let startDateOfNextMonth = startOfCurrentMonth(nextMonth)!
            let startDay = calendar.component(.day, from: startDateOfNextMonth)
            debugPrint("Next month day => \(startDay)")
            
            for i in 1...42 {
                // previous month date calculation
                if i < firstWeekday {
                    let dayValue = (endDay - firstWeekday + i + 1)
                    debugPrint("Previous month date => \(dayValue)")
                    let dayHash = year * 10000 + getPrevious(monthValue: month) * 100 + dayValue
                    _days.append(SCCalendarDate(dayString: "\(dayValue)",
                        dayValue: dayHash,
                        type: .empty,
                        wasteBins: []))
                } else if i > daysCount + firstWeekday - 1 { // next
                    let dayValue = startDay + (i - (daysCount + firstWeekday))
                    let dayHash = year * 10000 + getNext(monthValue: month) * 100 + dayValue
                    _days.append(SCCalendarDate(dayString: "\(dayValue)",
                        dayValue: dayHash,
                        type: .empty,
                        wasteBins: []))
                } else {
                    let day = i - firstWeekday + 1
                    let newDayHash = year * 10000 + month * 100 + day
                    
                    var wasteBinForDay = wasteData[newDayHash.description] ?? []
                    
                    if let categories = filterCategories, categories.count >= 0 {
                        wasteBinForDay.removeAll {  !(categories.contains($0.wasteType) ) }
                    }
                    
                    if newDayHash < Date.hashForDate(todayDate) {
                        _days.append(SCCalendarDate(dayString: String(describing: day),
                                                    dayValue: newDayHash,
                                                    type: .past,
                                                    wasteBins: wasteBinForDay))
                    } else if newDayHash == Date.hashForDate(todayDate){
                        _days.append(SCCalendarDate(dayString: String(describing: day),
                                                    dayValue: newDayHash,
                                                    type: .today,
                                                    wasteBins: wasteBinForDay))
                    } else {
                        if (i % 7 == 0)  || ((i + 1) % 7 == 0){
                            _days.append(SCCalendarDate(dayString: String(describing: day),
                                                        dayValue: newDayHash,
                                                        type: .futureWeekend,
                                                        wasteBins: wasteBinForDay))
                        } else {
                            _days.append(SCCalendarDate(dayString: String(describing: day),
                                                        dayValue: newDayHash,
                                                        type: .futureWorkday,
                                                        wasteBins: wasteBinForDay))
                        }
                    }
                }
            }
        }
        return _days
    }

    private func getNext(monthValue: Int) -> Int {
        if monthValue >= 12 {
            return 1
        } else {
            return monthValue + 1
        }
    }

    private func getPrevious(monthValue: Int) -> Int {
        if monthValue <= 1 {
            return 12
        } else {
            return monthValue - 1
        }
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

}


func endOfCurrentMonth(_ nowDayDate: Date) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    let calendar = Calendar.current
    var components = DateComponents()
    components.month = 1
    components.day = -1

    //startOfCurrentMonth
    let currentMonth = calendar.dateComponents([.year, .month], from: nowDayDate)
    let startOfMonth = calendar.date(from: currentMonth)
    let endOfMonth = calendar.date(byAdding: components, to: startOfMonth!)
    return endOfMonth
}

func startOfCurrentMonth(_ nowDayDate: Date) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month], from: nowDayDate)
    let startOfMonth = calendar.date(from: components)
    return startOfMonth
}

func getNumberMonthAllowed(_ nowDayDate: Date) -> Int? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    let compStart: DateComponents = Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: Date()))
    let startDate = Calendar.current.date(from: compStart)!

    let calendar = Calendar.current
    let maxMonthIndex = calendar.dateComponents([.month], from:startDate, to: nowDayDate).month
    return maxMonthIndex
}
