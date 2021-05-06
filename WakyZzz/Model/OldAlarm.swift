//
//  Alarm.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import Foundation

enum Day: String, CaseIterable, Encodable, Decodable {
    case sunday = "Sun"
    case monday = "Mon"
    case tuesday = "Tue"
    case wednesday = "Wed"
    case thursday = "Thu"
    case friday = "Fri"
    case saturday = "Sat"
    
    var component: DateComponents {
        var components = DateComponents()
        
        switch self {
        case .sunday:
            components.weekday = 1
            return components
        case .monday:
            components.weekday = 2
            return components
        case .tuesday:
            components.weekday = 3
            return components
        case .wednesday:
            components.weekday = 4
            return components
        case .thursday:
            components.weekday = 5
            return components
        case .friday:
            components.weekday = 6
            return components
        case .saturday:
            components.weekday = 7
            return components
        }
    }
    
    var value: Int {
        switch self {
        case .sunday:
            return 1
        case .monday:
            return 2
        case .tuesday:
            return 3
        case .wednesday:
            return 4
        case .thursday:
            return 5
        case .friday:
            return 6
        case .saturday:
            return 7
        }
    }
    
    // convert saved days from CD 
    func convert(_ intArray: [Int]) -> [Day] {
        var container: [Day] = []
        for day in Day.allCases {
            for int in intArray {
                if day.value == int {
                    container.append(day)
                }
            }
        }
        return container

    }
}

class OldAlarm: NotificationManager {
    
    // Properties
    var time = 8 * 360
    var repeatDays: [Day : Bool] = [.sunday: false,
                                    .monday: false,
                                    .tuesday: false,
                                    .wednesday: false,
                                    .thursday: false,
                                    .friday: false,
                                    .saturday: false]
    var enabled = true
    var uuid = UUID().uuidString
    var snoozeCount = 0 
    var originalTime: Date? = nil 
    
    // - Computed Properties -
    // If Alarm is repeating or not
    var isRepeating: Bool {
        for (_, bool) in repeatDays {
            if bool == true {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    // date for alarm
    var alarmDate: Date? {
        let date = Date()
        let calendar = Calendar.current
        let h = time/3600
        let m = time/60 - h * 60
        
        var components = calendar.dateComponents([.hour, .minute, .month, .year, .day, .second, .weekOfMonth], from: date as Date)
        
        components.hour = h
        components.minute = m
        
        let createdDate = calendar.date(from: components)
        originalTime = createdDate
        
        return createdDate
    }
    
    // Time as String
    var caption: String {        
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self.alarmDate!)
    }
    
    // repeating days as String
    var repeating: String {
        var captions = [String]()
        var days: [Day] = []
        var sortedDays: [Day] = []
        
        
        for (key, bool) in repeatDays {
            if bool == true {
                days.append(key)
            }
        }
        
        if days.count != 0 {
            sortedDays = days.sorted { (one, two) -> Bool in
                return one.value < two.value
            }
            for day in sortedDays {
                captions.append(day.rawValue)
            }
        }
        return captions.count > 0 ? captions.joined(separator: ", ") : "One time alarm"
    }
    
    // Get repeating days of the week as Int - [1, 4] = ["Mon", "Thu"]
    var repeatingDaysOfWeek: [Day] {
        var days: [Day] = []
        for (key, bool) in repeatDays {
            if bool == true {
                days.append(key)
            }
        }
        return days
    }
}

// Methods
extension OldAlarm {
    
    // Set notification for snooze alarm
    func setSnoozeNotification() {
        snoozeCount += 1
        scheduleNotificationForSnooze(alarm: self)
    }
    
    // Set time of alarm
    func setTime(date: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .month, .year, .day, .second, .weekOfMonth], from: date as Date)
        
        time = components.hour! * 3600 + components.minute! * 60
        
    }

    // Set notifications for alarm
    func setNotifications() {
        if self.enabled == true {
            schedualeNotifications(for: self)
        }
    }
    
    // Disable all notifications for alarm
    func disableNotifications() {
        if self.enabled == false {
            disable(alarm: self.uuid)
        } else {
            self.enabled = false
            disable(alarm: self.uuid)
        }
    }
    

}
