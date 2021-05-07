//
//  AlarmManager.swift
//  WakyZzz
//
//  Created by Matthew Sousa on 5/5/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

import Foundation
import CoreData
import UIKit

enum AMKey: String {
    case entity = "Alarm"
}

class AlarmManager: CoredataCoder {
    
//    let nm = NotificationManager()
    
    var allAlarms: [Alarm] = []
    
    var context: NSManagedObjectContext
    var entity: NSEntityDescription
    
    lazy var calendar = Calendar.current
    
    override init() {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        context = appDel.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: AMKey.entity.rawValue, in: context)!
    }
    
    // Save Context
    func saveSelectedContext() {
        do {
            try context.save()
        } catch {
            print(error)
        }
        print(#function)
    }
    
}

// Create
extension AlarmManager {

    // Create a new alarm using properties - alarm is disabled by default & a uuid is created if not specified
    func createNewAlarm(uuid: String? = nil,
                        enabled: Bool? = nil,
                        originalTime: String? = nil,
                        snoozeCount: SnoozeCount? = nil,
                        time: Date? = nil,
                        days: [Day : Bool]? = nil) -> Alarm {
        let alarm = Alarm(context: context)
        
        if let uuid = uuid {
            alarm.uuid = uuid
        } else {
            alarm.uuid = UUID().uuidString
        }
        
        if let enabled = enabled {
            alarm.enabled = enabled
        } else {
            alarm.enabled = false
        }
        
        if let originalTime = originalTime {
            alarm.originalTime = originalTime
        }
        
        if let snoozeCount = snoozeCount {
            alarm.snoozeCount = snoozeCount.rawValue
        } else {
            alarm.snoozeCount = 0
        }
        
        if let time = time {
            setTime(alarm: alarm, time: time)
        }
        
        if let days = days {
            if let encodedDays = encode(days: days) {
                alarm.repeatingDays = encodedDays
            }
        }
        
        if alarm.hasChanges {
            saveSelectedContext()
        }
        
        allAlarms.append(alarm)
        return alarm
        
    }
    
}

extension AlarmManager {
    
    enum SnoozeCount: Int16 {
        case zero = 0
        case one = 1
        case two = 2
    }
    
    // Update alarm properties
    func update(alarm: Alarm,
                uuid: String? = nil,
                enabled: Bool? = nil,
                originalTime: String? = nil,
                snoozeCount: SnoozeCount? = nil,
                time: Date? = nil,
                days: [Day : Bool]? = nil) {
        
        if let uuid = uuid {
            alarm.uuid = uuid
        }
        
        if let enabled = enabled {
            alarm.enabled = enabled
        }
        
        if let originalTime = originalTime {
            alarm.originalTime = originalTime
        }
        
        if let snoozeCount = snoozeCount {
            alarm.snoozeCount = snoozeCount.rawValue
        }
        
        if let time = time {
            setTime(alarm: alarm, time: time)
        }
        
        if let days = days {
            if let daysDict = encode(days: days) {
                alarm.repeatingDays = daysDict
            }
        }
        
        if alarm.hasChanges {
            saveSelectedContext()
        }
    }
    
    // Set time of alarm 
    func setTime(alarm: Alarm?, time: Date? = nil) {
        if let alarm = alarm {
            if let time = time {
                let components = calendar.dateComponents([.hour, .minute, .month, .year, .day, .second, .weekOfMonth], from: time)
                let s = components.hour! * 3600 + components.minute! * 60
                alarm.time = Int32(s)
            } else {
                let components = calendar.dateComponents([.hour, .minute, .month, .year, .day, .second, .weekOfMonth], from: Date())
                let s = components.hour! * 3600 + components.minute! * 60
                alarm.time = Int32(s)
            }
        }
    }
        
}

// Fetch
extension AlarmManager {
    
    // Sort Fetched Alarms
    func sortAlarmsByTime() {
        if allAlarms.count != 0 {
            allAlarms.sort() { $0.time > $1.time }
        }
    }
    
    // Fetch all alarms
    func fetchAllAlarms() {
        let request: NSFetchRequest<Alarm> = Alarm.fetchRequest()
        do {
            allAlarms = try context.fetch(request)
        } catch {
            print(error)
        }
        sortAlarmsByTime()
    }
    
    // Fetch Alarm with a uuid tag
    func fetchAlarm(with uuid: String) -> Alarm? {
        let alarmExists = allAlarms.contains(where: { $0.uuid == uuid })
        var alarm: Alarm?
        
        switch alarmExists {
        case true:
            if let foundAlarm = allAlarms.first(where: { $0.uuid == uuid }) {
                alarm = foundAlarm
            }
        default:
            let request: NSFetchRequest<Alarm> = Alarm.fetchRequest()
            request.predicate = NSPredicate(format: "uuid == %@", uuid)
            var alarms: [Alarm] = []
            do {
                alarms = try context.fetch(request)
            } catch {
                print(error)
            }
            if alarms.count != 0 {
                if let firstAlarm = alarms.first {
                    alarm = firstAlarm
                    allAlarms.append(firstAlarm)
                }
            } else {
                return nil
            }
        }
        return alarm
    }
    
}

// Delete
extension AlarmManager {
    
    /// Delete all elements for type
    func deleteAllAlarms() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: AMKey.entity.rawValue)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(deleteRequest)
            allAlarms.removeAll()
        } catch {
            print(error)
        }
    }
    
    // Delete specific element
    func deleteAlarm(uuid: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: AMKey.entity.rawValue)
        request.predicate = NSPredicate(format: "uuid == %@", uuid)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(deleteRequest)
            allAlarms.removeAll(where: { $0.uuid == uuid })
        } catch {
            print(error)
        }

    }
    
}

extension AlarmManager {
    
    // Get Alarm for row
    func alarm(at indexPath: IndexPath) -> Alarm? {
        return indexPath.row < allAlarms.count ? allAlarms[indexPath.row] : nil
    }
}


// Notifications
extension AlarmManager {
    
//    func setNotifications(for alarm: Alarm) {
//        if alarm.enabled == true {
//            nm.schedualeNotifications(for: alarm)
//        }
//    }
    
//    func setSnoozeNotifications(for alarm: Alarm) {
//        incrementSnoozeCount(of: alarm)
//        nm.scheduleNotificationForSnooze(alarm: alarm)
//
//    }
    
//    func disableNotifications(for alarm: Alarm) {
//        guard let uuid = alarm.uuid else { return }
//        switch alarm.enabled {
//        case true:
//            update(alarm: alarm, enabled: false)
//            nm.disable(alarm: uuid)
//        case false:
//            nm.disable(alarm: uuid)
//        }
//    }
    
}
