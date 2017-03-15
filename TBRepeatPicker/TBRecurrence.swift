//
//  TBRecurrence.swift
//  TBRepeatPicker
//
//  Created by 洪鑫 on 15/10/7.
//  Copyright © 2015年 Teambition. All rights reserved.
//

import Foundation

@objc public enum TBRPFrequency: Int {
    case daily = 0
    case weekly = 1
    case monthly = 2
    case yearly = 3
}

@objc public enum TBRPWeekPickerNumber: Int {
    case first = 0
    case second = 1
    case third = 2
    case fourth = 3
    case fifth = 4
    case last = 5
}

@objc public enum TBRPWeekPickerDay: Int {
    case sunday = 0
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    case day = 7
    case weekday = 8
    case weekendDay = 9
}

public class TBRecurrence: NSObject {
    /** The frequency of recurrence, must be one of the following cases:
    * TBRPFrequency.Daily
    * TBRPFrequency.Weekly
    * TBRPFrequency.Monthly
    * TBRPFrequency.Yearly
    */
    public var frequency: TBRPFrequency = .daily
    
    /** The interval between each frequency iteration. For example, when in a daily frequency, an interval of 1 means that event will occur every day, and an interval of 3 means that event will occur every 3 days. The default interval is 1.
    */
    public var interval: Int = 1
    
    /** The selected weekdays when frequency is weekly. Elements in this array are all integers in a range between 0 to 6, 0 means Sunday, which is the first day of week, and the integers from 1 to 6 respectively mean the days from Monday to Saturday. This property value is valid only for a frequency type of TBRPFrequency.Weekly.
    */
    public var selectedWeekdays = [Int]() {
        didSet {
            selectedWeekdays = selectedWeekdays.sorted { $0 < $1 }
        }
    }
    
    /** A boolean value decides whether the recurrence is constructed by week number or not when frequency is weekly or yearly. For example, we can get a recurrence like "Second Friday" with it. This property value is valid only for a frequency type of TBRPFrequency.Monthly or TBRPFrequency.Yearly.
    */
    public var byWeekNumber = false
    
    /** The selected monthdays when frequency is monthly. Elements in this array are all integers in a range between 1 to 31, which respectively mean the days from 1st to 31st of a month. This property value is valid only for a frequency type of TBRPFrequency.Monthly.
    */
    public var selectedMonthdays = [Int]() {
        didSet {
            selectedMonthdays = selectedMonthdays.sorted { $0 < $1 }
        }
    }
    
    /** The selected months when frequency is yearly. Elements in this array are all integers in a range between 1 to 12, which respectively mean the months from January to December. This property value is valid only for a frequency type of TBRPFrequency.Yearly.
    */
    public var selectedMonths = [Int]() {
        didSet {
            selectedMonths = selectedMonths.sorted { $0 < $1 }
        }
    }
    
    /** The week number when the recurrence is constructed by week number, must be one of the following cases:
    * TBRPWeekPickerNumber.First
    * TBRPWeekPickerNumber.Second
    * TBRPWeekPickerNumber.Third
    * TBRPWeekPickerNumber.Fourth
    * TBRPWeekPickerNumber.Fifth
    * TBRPWeekPickerNumber.Last
    
    This property value is valid only for a frequency type of TBRPFrequency.Monthly or TBRPFrequency.Yearly.
    */
    public var pickedWeekNumber: TBRPWeekPickerNumber = .first
    
    /** The day of week when the recurrence is constructed by week number, must be one of the following cases:
    * TBRPWeekPickerDay.Sunday
    * TBRPWeekPickerDay.Monday
    * TBRPWeekPickerDay.Tuesday
    * TBRPWeekPickerDay.Wednesday
    * TBRPWeekPickerDay.Thursday
    * TBRPWeekPickerDay.Friday
    * TBRPWeekPickerDay.Saturday
    * TBRPWeekPickerDay.Day
    * TBRPWeekPickerDay.Weekday
    * TBRPWeekPickerDay.WeekendDay
    
    This property value is valid only for a frequency type of TBRPFrequency.Monthly or TBRPFrequency.Yearly.
    */
    public var pickedWeekday: TBRPWeekPickerDay = .sunday
    
    // MARK: - Initialization
    public init(occurrenceDate: Date? = nil) {
        super.init()

        guard let occurrenceDate = occurrenceDate else {
            return
        }

        let occurrenceDateDayIndexInWeek = Calendar.dayIndexInWeek(occurrenceDate)
        let occurrenceDateDayIndexInMonth = Calendar.dayIndexInMonth(occurrenceDate)
        let occurrenceDateMonthIndexInYear = Calendar.monthIndexInYear(occurrenceDate)
        
        selectedWeekdays = [occurrenceDateDayIndexInWeek - 1]
        selectedMonthdays = [occurrenceDateDayIndexInMonth]
        selectedMonths = [occurrenceDateMonthIndexInYear]
    }
    
    public func recurrenceCopy() -> TBRecurrence {
        let recurrence = TBRecurrence()
        
        recurrence.frequency = frequency
        recurrence.interval = interval
        recurrence.selectedWeekdays = selectedWeekdays
        recurrence.byWeekNumber = byWeekNumber
        recurrence.selectedMonthdays = selectedMonthdays
        recurrence.selectedMonths = selectedMonths
        recurrence.pickedWeekNumber = pickedWeekNumber
        recurrence.pickedWeekday = pickedWeekday
        
        return recurrence
    }
    
    class func isEqualRecurrence(_ recurrence1: TBRecurrence?, recurrence2: TBRecurrence?) -> Bool {
        if recurrence1 == nil && recurrence2 == nil {
            return true
        } else if recurrence1?.frequency == recurrence2?.frequency && recurrence1?.interval == recurrence2?.interval {
            if recurrence1?.frequency == .daily {
                return true
            } else if recurrence1?.frequency == .weekly {
                let selectedWeekdays1 = recurrence1?.selectedWeekdays.sorted { $0 < $1 }
                let selectedWeekdays2 = recurrence2?.selectedWeekdays.sorted { $0 < $1 }
                
                return selectedWeekdays1! == selectedWeekdays2!
            } else if recurrence1?.frequency == .monthly {
                if recurrence1?.byWeekNumber == recurrence2?.byWeekNumber {
                    if recurrence1?.byWeekNumber == true {
                        return recurrence1?.pickedWeekNumber == recurrence2?.pickedWeekNumber && recurrence1?.pickedWeekday == recurrence2?.pickedWeekday
                    } else {
                        let selectedMonthdays1 = recurrence1?.selectedMonthdays.sorted { $0 < $1 }
                        let selectedMonthdays2 = recurrence2?.selectedMonthdays.sorted { $0 < $1 }
                        
                        return selectedMonthdays1! == selectedMonthdays2!
                    }
                } else {
                    return false
                }
            } else if recurrence1?.frequency == .yearly {
                if recurrence1?.byWeekNumber == recurrence2?.byWeekNumber {
                    let selectedMonths1 = recurrence1?.selectedMonths.sorted { $0 < $1 }
                    let selectedMonths2 = recurrence2?.selectedMonths.sorted { $0 < $1 }
                    
                    if recurrence1?.byWeekNumber == true {
                        return selectedMonths1! == selectedMonths2! && recurrence1?.pickedWeekNumber == recurrence2?.pickedWeekNumber && recurrence1?.pickedWeekday == recurrence2?.pickedWeekday
                    } else {
                        return selectedMonths1! == selectedMonths2!
                    }
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    // preset recurrence initialization
    public class func dailyRecurrence(occurenceDate: Date? = nil) -> TBRecurrence {
        return occurenceDate.map({ self.initCustomDaily(occurrenceDate: $0) }) ?? initDaily()
    }
    
    public class func weeklyRecurrence() -> TBRecurrence {
        return initWeekly(1, selectedWeekdays: [])
    }
    
    public class func biWeeklyRecurrence() -> TBRecurrence {
        return initWeekly(2, selectedWeekdays: [])
    }
    
    public class func monthlyRecurrence() -> TBRecurrence {
        return initMonthly(1, selectedMonthdays: [])
    }
    
    public class func yearlyRecurrence() -> TBRecurrence {
        return initYearly(1, selectedMonths: [])
    }
    
    public class func weekdayRecurrence() -> TBRecurrence {
        return initWeekly(1, selectedWeekdays: [1, 2, 3, 4, 5])
    }
    
    // custom recurrence initialization
    public class func initDaily(_ interval: Int = 1) -> TBRecurrence {
        let dailyRecurrence = TBRecurrence()
        dailyRecurrence.frequency = .daily
        dailyRecurrence.interval = max(interval, 1)
        return dailyRecurrence
    }

    public class func initCustomDaily(_ interval: Int = 1, occurrenceDate: Date) -> TBRecurrence {
        let dailyRecurrence = TBRecurrence(occurrenceDate: occurrenceDate)
        dailyRecurrence.frequency = .daily
        dailyRecurrence.interval = max(interval, 1)
        return dailyRecurrence
    }
    
    public class func initWeekly(_ interval: Int = 1, selectedWeekdays: [Int] = []) -> TBRecurrence {
        let weeklyRecurrence = TBRecurrence()
        weeklyRecurrence.frequency = .weekly
        weeklyRecurrence.interval = max(1, interval)

        let selectedWeekdays = selectedWeekdays.filter({ 0...6 ~= $0 }).unique
        if selectedWeekdays.count > 0 {
            weeklyRecurrence.selectedWeekdays = selectedWeekdays
        }
        
        return weeklyRecurrence
    }
    
    public class func initMonthly(_ interval: Int = 1, selectedMonthdays: [Int] = []) -> TBRecurrence {
        let monthlyRecurrence = TBRecurrence()
        monthlyRecurrence.frequency = .monthly
        monthlyRecurrence.byWeekNumber = false
        monthlyRecurrence.interval = max(1, interval)

        let selectedMonthdays = selectedMonthdays.filter({ 1...31 ~= $0 }).unique
        if selectedMonthdays.count > 0 {
            monthlyRecurrence.selectedMonthdays = selectedMonthdays
        }
        
        return monthlyRecurrence
    }
    
    public class func initMonthlyByWeekNumber(_ interval: Int = 1, pickedWeekNumber: TBRPWeekPickerNumber, pickedWeekday: TBRPWeekPickerDay) -> TBRecurrence {
        let monthlyRecurrence = TBRecurrence()
        monthlyRecurrence.frequency = .monthly
        monthlyRecurrence.byWeekNumber = true
        monthlyRecurrence.interval = max(1, interval)
        
        monthlyRecurrence.pickedWeekNumber = pickedWeekNumber
        monthlyRecurrence.pickedWeekday = pickedWeekday
        
        return monthlyRecurrence
    }
    
    public class func initYearly(_ interval: Int = 1, selectedMonths: [Int] = []) -> TBRecurrence {
        let yearlyRecurrence = TBRecurrence()
        yearlyRecurrence.frequency = .yearly
        yearlyRecurrence.byWeekNumber = false
        yearlyRecurrence.interval = max(1, interval)

        let selectedMonths = selectedMonths.filter({ 1...12 ~= $0 }).unique
        if selectedMonths.count > 0 {
            yearlyRecurrence.selectedMonths = selectedMonths
        }
        
        return yearlyRecurrence
    }
    
    public class func initYearlyByWeekNumber(_ interval: Int = 1, pickedWeekNumber: TBRPWeekPickerNumber, pickedWeekday: TBRPWeekPickerDay) -> TBRecurrence {
        let yearlyRecurrence = TBRecurrence()
        yearlyRecurrence.frequency = .yearly
        yearlyRecurrence.byWeekNumber = true
        yearlyRecurrence.interval = max(1, interval)

        yearlyRecurrence.pickedWeekNumber = pickedWeekNumber
        yearlyRecurrence.pickedWeekday = pickedWeekday
        
        return yearlyRecurrence
    }
    
    // MARK: - Helper
    public func isDailyRecurrence() -> Bool {
        return frequency == .daily && interval == 1
    }
    
    public func isWeeklyRecurrence() -> Bool {
        return frequency == .weekly && selectedWeekdays.isEmpty && interval == 1
    }
    
    public func isBiWeeklyRecurrence() -> Bool {
        return frequency == .weekly && selectedWeekdays.isEmpty && interval == 2
    }
    
    public func isMonthlyRecurrence() -> Bool {
        return frequency == .monthly && interval == 1 && !byWeekNumber && selectedMonthdays.isEmpty
    }
    
    public func isYearlyRecurrence() -> Bool {
        return frequency == .yearly && interval == 1 && byWeekNumber == false && selectedMonths.isEmpty
    }
    
    public func isWeekdayRecurrence() -> Bool {
        return frequency == .weekly && interval == 1 && selectedWeekdays == [1, 2, 3, 4, 5]
    }
    
    public func isCustomRecurrence() -> Bool {
        return !isDailyRecurrence() && !isWeeklyRecurrence() && !isBiWeeklyRecurrence() && !isMonthlyRecurrence() && !isYearlyRecurrence()
    }
}
