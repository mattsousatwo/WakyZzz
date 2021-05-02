//
//  Alarm.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import Foundation

class Alarm: NotificationManager { 
    
    static let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var time = 8 * 360
    var repeatDays = [false, false, false, false, false, false, false]
    var enabled = true
    var uuid = UUID().uuidString
    var snoozeCount = 0 
    var originalTime: Date? = nil 
    
    var isRepeating: Bool {
        if repeatDays.contains( true ) {
            return true
        } else {
            return false 
        }
    }
    
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
    
    /// Adds one minuete to alarm and schedules a new alarm 
    func addOneMinuteToAlarm() {
        let calendar = Calendar.current
        if let alarmDate = self.alarmDate {
            if let newDate = calendar.date(byAdding: .minute, value: 1, to: alarmDate) {
                
                let snoozeAlarm = Alarm()
                snoozeAlarm.setTime(date: newDate)
                snoozeAlarm.snoozeCount = 1
                snoozeAlarm.originalTime = self.originalTime
                snoozeAlarm.enabled = true
                schedualeNotifications(for: snoozeAlarm)
            }
        }
    }
    
    func setSnoozeNotification() {
        snoozeCount += 1
        scheduleNotificationForSnooze(alarm: self)
    }
    
    
    var caption: String {        
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self.alarmDate!)
    }
    
    var repeating: String {
        var captions = [String]()
        for i in 0 ..< repeatDays.count {
            if repeatDays[i] {
                captions.append(Alarm.daysOfWeek[i])
            }
        }
        return captions.count > 0 ? captions.joined(separator: ", ") : "One time alarm"
    }
    
    // Get repeating days of the week as Int - [1, 4] = ["Mon", "Thu"]
    var repeatingDaysOfWeek: [Int] {
        var days: [Int] = []
        for i in 0 ..< repeatDays.count {
            if repeatDays[i] == true {
                days.append(i)
            }
        }
        return days
    }
    
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

