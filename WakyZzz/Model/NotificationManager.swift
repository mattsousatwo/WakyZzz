//
//  NotificationManager.swift
//  WakyZzz
//
//  Created by Matthew Sousa on 4/27/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

import UserNotifications
import Foundation

class NotificationManager {
    
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    // Ask user for permisson to send notifications
    func requestNotificationAuthorization() {
        let authorizationOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        
        self.userNotificationCenter.requestAuthorization(options: authorizationOptions) { (success, error) in
            if let error = error {
                print("Error: ", error)
            }
            
        }
    }
    
    // Set up local notification
    func schedualeNotification(for alarm: Alarm? = nil) {
        // - Content
        let content = UNMutableNotificationContent()
        
        var title = "Test Alarm"
        var body = "Test Body"
        
        if let alarm = alarm {
            title = "\(alarm.time)"
            body = alarm.uuid
        }
        content.title = title
        content.body = body
        content.badge = NSNumber(value: 1)
        
        // - Trigger
        var year = 0
        var month = 0
        var day = 0
        var hour = 0
        var min = 0
        var sec = 0
        
        
        let calendar = NSCalendar.current
        if let date = alarm?.alarmDate {
            year = calendar.component(.year, from: date)
            month = calendar.component(.month, from: date)
            day = calendar.component(.day, from: date)
            hour = calendar.component(.hour, from: date)
            min = calendar.component(.minute, from: date)
            let currentSec = calendar.component(.second, from: date)
                sec = currentSec + 30
        }
        
        var components = calendar.dateComponents([.hour, .minute, .month, .year, .day, .second, .weekOfMonth], from: Date())
        components.minute = components.minute! + 1
        
        
//        var dateComponents = DateComponents()
//            dateComponents.timeZone = TimeZone(abbreviation: "EST")
//            dateComponents.year = year
//            dateComponents.month = month
//            dateComponents.day = day
//            dateComponents.hour = hour
//            dateComponents.minute = min
//            dateComponents.second = sec
        
        print("Trigger Components: \(components)")

        let  trigger = UNCalendarNotificationTrigger(dateMatching: components,
                                                     repeats: false)
        
//        let request = UNNotificationRequest(identifier: alarm.uuid,
//                                            content: content,
//                                            trigger: trigger)

        let request = UNNotificationRequest(identifier: "alarm.uuid",
                                            content: content,
                                            trigger: trigger)
        
        
        userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
        
    }

}
