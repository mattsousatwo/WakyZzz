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

class AlarmManager {
    
    var allAlarms: [Alarm] = []
    
    var context: NSManagedObjectContext
    var entity: NSEntityDescription
    
    init() {
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
    func createNewAlarm(uuid: String? = nil, date: String? = nil, enabled: Bool? = nil, originalTime: String? = nil, snoozeCount: Int? = nil, time: Int16? = nil, days: [Day]? = nil) -> Alarm {
        let alarm = Alarm(context: context)
        
        if let uuid = uuid {
            alarm.uuid = uuid
        } else {
            alarm.uuid = UUID().uuidString
        }
        
        if let date = date {
            alarm.alarmDate = date
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
            alarm.snoozeCount = Int16(snoozeCount)
        } else {
            alarm.snoozeCount = 0
        }
        
        
        if let time = time {
            alarm.time = time
        }
        
//        if let days = days {
            // Convert days into String
            // alarm.repeatingDays = convertedDays
//
//        }
        
        
        if alarm.hasChanges {
            saveSelectedContext()
        }
        
        allAlarms.append(alarm)
        return alarm
        
    }
    
    
}

// Fetch
extension AlarmManager {
    
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
    
    func fetchAllAlarms() {
        let request: NSFetchRequest<Alarm> = Alarm.fetchRequest()
        do {
            allAlarms = try context.fetch(request)
        } catch {
            print(error)
        }
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
        } catch {
            print(error)
        }
    }
    
    // Delete specific element - MIGHT NOT BE WORKING 
    func deleteAlarm(uuid: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: AMKey.entity.rawValue)
        request.predicate = NSPredicate(format: "uuid == %@", uuid)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(deleteRequest)
        } catch {
            print(error)
        }

    }
    

    
}
