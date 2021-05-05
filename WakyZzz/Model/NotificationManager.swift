//
//  NotificationManager.swift
//  WakyZzz
//
//  Created by Matthew Sousa on 4/27/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

import UserNotifications
import Foundation
import UIKit


enum NotificationKey: String {
    // Categories
    case alarmCategoryID = "ALARM_ID"
    case snoozeAlarmLevel1ID = "SNOOZE_ALARM_LEVEL_1_ID"
    case snoozeAlarmLevel2ID = "SNOOZE_ALARM_LEVEL_2_ID"
    
    // Notification Identifier
    case snoozeNotificationPrefix = "SNOOZE_ALARM_"
    case snoozeNotificationPrefix2 = "SNOOZE_ALARM_2_"
    
    // Snooze Buttonsq
    case snoozeAlarmLevel0 = "SNOOZE_ALARM_LEVEL_0"
    case snoozeAlarmLevel1 = "SNOOZE_ALARM_LEVEL_1"
    
    // Stop Buttons
    case stopAlarmLevel0 = "STOP_ALARM_LEVEL_0"
    case stopSnoozeAlarmLevel1 = "STOP_SNOOZE_ALARM_LEVEL_1"
    case stopSnoozeAlarmLevel2 = "STOP_SNOOZE_ALARM_LEVEL_2"
    
    // Content
    case title = "WakyZzz"
    case subtitle = "Alarm: "
    case normalBody = "Times Up!"
    case snoozeBody1 = "level 1"
    case snoozeBody2 = "level 2"
    
    // User Info
    case alarmUUIDTag = "UUID"
    case originalTime = "ORIGINAL_TIME"
}


class NotificationManager {
    
    let userNotificationCenter = UNUserNotificationCenter.current()
    let formatter = DateFormatter()
    let calendar = NSCalendar.current
    
    init() {
        requestNotificationAuthorization()
        userNotificationCenter.setNotificationCategories([alarmCategory, snoozeCategory, snoozeCategoryLevel2])
        formatter.dateStyle = .full
        formatter.timeStyle = .medium
    }
    
}

/// Configuration
extension NotificationManager {
    
    // Ask user for permisson to send notifications
    func requestNotificationAuthorization() {
        let authorizationOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        
        self.userNotificationCenter.requestAuthorization(options: authorizationOptions) { (success, error) in
            if let error = error {
                print("Error: ", error)
            }
            
        }
    }
    
}

/// Notification Categories
extension NotificationManager {
    
    var alarmCategory: UNNotificationCategory {

        let snoozeAction = UNNotificationAction(identifier: NotificationKey.snoozeAlarmLevel0.rawValue,
                                                title: "Snooze",
                                                options: UNNotificationActionOptions(rawValue: 0))
        let stopAction = UNNotificationAction(identifier: NotificationKey.stopAlarmLevel0.rawValue,
                                              title: "Stop",
                                              options: UNNotificationActionOptions(rawValue: 0))
        
        return UNNotificationCategory(identifier: NotificationKey.alarmCategoryID.rawValue,
                                      actions: [snoozeAction, stopAction],
                                      intentIdentifiers: [],
                                      options: .customDismissAction)
    }
    
    var snoozeCategory: UNNotificationCategory {
        
        let snoozeAction = UNNotificationAction(identifier: NotificationKey.snoozeAlarmLevel1.rawValue,
                                                title: "Snooze",
                                                options: UNNotificationActionOptions(rawValue: 0))
        
        let stopSnoozeAction = UNNotificationAction(identifier: NotificationKey.stopSnoozeAlarmLevel1.rawValue,
                                                    title: "Stop",
                                                    options: UNNotificationActionOptions(rawValue: 0))
        
        return UNNotificationCategory(identifier: NotificationKey.snoozeAlarmLevel1ID.rawValue,
                                      actions: [snoozeAction, stopSnoozeAction],
                                      intentIdentifiers: [],
                                      options: .customDismissAction)
    }
    
    var snoozeCategoryLevel2: UNNotificationCategory {
        
        let stopSnoozeAction = UNNotificationAction(identifier: NotificationKey.stopSnoozeAlarmLevel2.rawValue,
                                                    title: "Stop",
                                                    options: UNNotificationActionOptions(rawValue: 0))
        
        return UNNotificationCategory(identifier: NotificationKey.snoozeAlarmLevel2ID.rawValue,
                                      actions: [stopSnoozeAction],
                                      intentIdentifiers: [],
                                      options: .customDismissAction)
    }
}


// Adding Dates
extension NotificationManager {

    // Compare dates years
    func withinYearApart(_ one: Date, _ two: Date) -> Bool {
        var component = DateComponents()
        component.year = 1
        
        if let controlDate = nextDate(from: one, component: component) {
            if controlDate < two {
                return false
            } else {
                return true
            }
        }
        return false
    }
    
    // return nextDate with component
    func nextDate(from date: Date, component: DateComponents) -> Date? {
        return calendar.date(byAdding: component, to: date)
        
    }
    
    
}


/// Schedule Notifications
extension NotificationManager {
    
    // Schedule notification using the alarms time
    func schedualeNotifications(for alarm: OldAlarm) {
        guard let alarmDate = alarm.alarmDate else { return }
        
        // - Content
        let content = UNMutableNotificationContent()
            content.title = NotificationKey.title.rawValue
            content.subtitle = NotificationKey.subtitle.rawValue + "\(alarm.caption)"
            content.body = NotificationKey.normalBody.rawValue
            content.badge = NSNumber(value: 1)
            content.categoryIdentifier = NotificationKey.alarmCategoryID.rawValue
        content.userInfo = [NotificationKey.alarmUUIDTag.rawValue : alarm.uuid]
        
        
        // - Trigger
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: alarmDate)
        components.second = 0
        
        
        
        switch alarm.repeatingDaysOfWeek.count {
        case 0:
            addNotification(components: components,
                            identifier: "\(alarm.uuid)",
                            content: content)
            
            print("---\n\n    Added Notification, repeatingDaysOfWeek.count == 0 \nSet Alarm Trigger at \(components) - UUID: \(alarm.uuid)\n\n---")
        default:
            /// Get repeating days of the week
            components.year = nil
            components.month = nil
            components.day = nil
            for day in alarm.repeatingDaysOfWeek {
                components.weekday = day.value
                
                addNotification(components: components,
                                identifier: "\(alarm.uuid)",
                                content: content,
                                repeats: true)
            }
            
        }
        
    }
    
    /// Schedule Notification for a snooze alarm - create an alarm one/two min later than original alarm
    func scheduleNotificationForSnooze(alarm: OldAlarm) {
        
        let snoozeCount = alarm.snoozeCount
        guard let originalTime = alarm.originalTime else { return }
        var originalTimeAsString: String {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            return formatter.string(from: originalTime)
        }
        
        
        let content = UNMutableNotificationContent()
        content.title = NotificationKey.title.rawValue
        content.subtitle = NotificationKey.subtitle.rawValue + originalTimeAsString
        content.badge = NSNumber(value: 1)
        content.userInfo = [NotificationKey.alarmUUIDTag.rawValue: alarm.uuid,
                            NotificationKey.originalTime.rawValue: originalTime]

        let calendar = NSCalendar.current
        
        guard let snoozeDate = calendar.date(byAdding: .minute, value: 1, to: Date()) else { return }
            
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: snoozeDate)
        components.second = 0
        
        switch snoozeCount {
        case 1:
            content.categoryIdentifier = NotificationKey.snoozeAlarmLevel1ID.rawValue
            content.body = NotificationKey.snoozeBody1.rawValue
            
            addNotification(components: components,
                            identifier: (NotificationKey.snoozeNotificationPrefix.rawValue + alarm.uuid),
                            content: content)
            
        case 2:
            content.categoryIdentifier = NotificationKey.snoozeAlarmLevel2ID.rawValue
            content.body = NotificationKey.snoozeBody2.rawValue
            
            addNotification(components: components,
                            identifier: (NotificationKey.snoozeNotificationPrefix2.rawValue + alarm.uuid),
                            content: content)
        default:
            break
        }
        
        
        
    }
    
    /// Create Reminder Notification - 30 mins
    func scheduleReminder() {
        
    }
    
    // Register Notification
    func addNotification(components: DateComponents, identifier: String, content: UNMutableNotificationContent, repeats: Bool = false) {
        let trigger = UNCalendarNotificationTrigger(dateMatching: components,
                                                     repeats: repeats)
        
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)
        
        print("Notification: \(trigger), \nComponents: \(components), \nIdentifier: \(identifier)")
        
        if repeats == true {
            print("\ntrigger.date = \(trigger.dateComponents), nextDate = \(formatter.string(from: trigger.nextTriggerDate()!)) \n")
        }
        
        userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
            
        }
    }
    
}

/// Disable Notification
extension NotificationManager {
    
    // Disable notifications for alarm
    func disable(alarm uuid: String) {
        userNotificationCenter.removeDeliveredNotifications(withIdentifiers: [uuid])
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [uuid])
        print("Disable alarm: \(uuid)")
        
    }
    
    func diableSnoozeAlarm() {
        userNotificationCenter.removeDeliveredNotifications(withIdentifiers: [NotificationKey.snoozeAlarmLevel1.rawValue])
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [NotificationKey.snoozeAlarmLevel1.rawValue])
        print("Disable alarm: \(NotificationKey.snoozeAlarmLevel1.rawValue)")
    }
    
}

/// Response from notification
extension NotificationManager {
    
    // Will control response from Notification
    func handle(response: UNNotificationResponse, alarms: [OldAlarm] ) {
        let userInfo = response.notification.request.content.userInfo
        let alarmUUID = userInfo[NotificationKey.alarmUUIDTag.rawValue] as! String
        
        switch response.actionIdentifier {
        case NotificationKey.snoozeAlarmLevel0.rawValue:
            
            // edit alarms time
            // reset to 1 min later
            guard let alarm = alarms.first(where: { $0.uuid == alarmUUID }) else { break }
            
            alarm.setSnoozeNotification()
            
            print("Notification: \(NotificationKey.snoozeAlarmLevel0)")
            
            break
        case NotificationKey.stopAlarmLevel0.rawValue:
            UIApplication.shared.applicationIconBadgeNumber = 0
            // Disable alarm if does not repeat
            // else leave enabled
            guard let alarm = alarms.first(where: {$0.uuid == alarmUUID}) else { break }
            switch alarm.isRepeating {
            case true:
                break
            case false:
                disable(alarm: alarmUUID)
            }
            
            print("Notification: \(NotificationKey.stopAlarmLevel0)")
            break
            
        case NotificationKey.snoozeAlarmLevel1.rawValue:
            // If snooze alarm was pressed
            guard let alarm = alarms.first(where: { $0.uuid == alarmUUID }) else { break }
            alarm.setSnoozeNotification()
            
            print("Notification: \(NotificationKey.snoozeAlarmLevel1)")
            
        break
            
            
        case NotificationKey.stopSnoozeAlarmLevel1.rawValue:
            // disable alarm
            UIApplication.shared.applicationIconBadgeNumber = 0
            guard let alarm = alarms.first(where: {$0.uuid == alarmUUID}) else { break }
            switch alarm.isRepeating {
            case true:
                break
            case false:
                disable(alarm: alarmUUID)
            }
            
            print("Notification: \(NotificationKey.stopSnoozeAlarmLevel1)")
            
            break
            
        case NotificationKey.stopSnoozeAlarmLevel2.rawValue:
            // If snooze alarm was pressed
            
            // MARK: Play Evil Sound
            
            // use Random Act of Kindness
            print("Notification: \(NotificationKey.stopSnoozeAlarmLevel2)")
        break
            
        default:
            break
        }
        
    }

}
