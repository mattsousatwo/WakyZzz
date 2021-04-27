//
//  Alarm.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import Foundation
import UserNotifications

class Alarm { 
    
    static let userNotifications = UNUserNotificationCenter.current()
    
    static let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var time = 8 * 360
    var repeatDays = [false, false, false, false, false, false, false]
    var enabled = true
    
    var alarmDate: Date? {
        let date = Date()
        let calendar = Calendar.current
        let h = time/3600
        let m = time/60 - h * 60
        
        var components = calendar.dateComponents([.hour, .minute, .month, .year, .day, .second, .weekOfMonth], from: date as Date)
        
        components.hour = h
        components.minute = m
        
        return calendar.date(from: components)
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
    
    func setTime(date: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .month, .year, .day, .second, .weekOfMonth], from: date as Date)
        
        time = components.hour! * 3600 + components.minute! * 60        
    }

}


// Local Notifications
extension Alarm {
    
    // Set up local notification
    func schedualeNotification() {
        
        let content = UNMutableNotificationContent()
        content.title = "\(self.time)"
//        content.body = "  "
        var day = 0
        var month = 0
        var year = 0
        
        let calendar = NSCalendar.current
        if let date = self.alarmDate {
            day = calendar.component(.day, from: date)
            month = calendar.component(.month, from: date)
            year = calendar.component(.year, from: date)
            
            
        }
        

//        let  trigger = UNCalendarNotificationTrigger(dateMatching: <#T##DateComponents#>, repeats: <#T##Bool#>)
    }
    
    
    
}
