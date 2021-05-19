//
//  Alarm+CoreDataClass.swift
//  WakyZzz
//
//  Created by Matthew Sousa on 5/5/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Alarm)
public class Alarm: NSManagedObject {
    
    let am = AlarmManager()
    
    var alarmTime: Date? {
        let date = Date()
        let calendar = Calendar.current
        let h = time/3600
        let m = time/60 - h * 60
        
        var components = calendar.dateComponents([.hour, .minute, .month, .year, .day, .second, .weekOfMonth], from: date as Date)
        
        components.hour = Int(h)
        components.minute = Int(m)
        
        let createdDate = calendar.date(from: components)
        
        if let createdDate = createdDate {
            originalTime = am.format(date: createdDate)
        }
        
        return createdDate
    }
    
    // Caption for TableView Cell
    var caption: String {
        am.formatter.dateStyle = .none
        am.formatter.timeStyle = .short
        var caption = String()
        if let time = self.alarmTime {
            let formattedDate = am.formatter.string(from: time)
                caption = formattedDate
        }
        return caption
    }
    
    // Subcaption for table view cell - repeating days / one time alarm
    var subcaption: String {
        var captions = [String]()
        var days: [Day] = []
        var sortedDays: [Day] = []
        
        if let repeatingDays = am.decode(days: self.repeatingDays) {
            
            for (key, bool) in repeatingDays {
                if bool == true {
                    days.append(key)
                }
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

    // Repeating Days of the week
    var decodedRepeatingDays: [Day : Bool] {
        var days: [Day : Bool] = [:]
        if let daysString = self.repeatingDays {
            if let decodedDays = am.decode(days: daysString) {
                days = decodedDays
            }
        } else {
            let control: [Day : Bool] = [.sunday: false,
                                         .monday: false,
                                         .tuesday: false,
                                         .wednesday: false,
                                         .thursday: false,
                                         .friday: false,
                                         .saturday: false]
            days = control
            am.update(alarm: self, days: control)
        }
        return days
    }
    
    // Dictionary of days that repeat 
    var selectedDays : [Day : Bool] {
        var days: [Day: Bool] = [:]
        for (day, value) in self.decodedRepeatingDays {
            if self.decodedRepeatingDays[day] == true {
                days[day] = value
            }
        }
        return days
    }
    
    // Set new day to value
    func set(_ day: Day, repeat value: Bool) {
        var control: [Day : Bool] = [.sunday: false,
                                     .monday: false,
                                     .tuesday: false,
                                     .wednesday: false,
                                     .thursday: false,
                                     .friday: false,
                                     .saturday: false]
        control = decodedRepeatingDays
        control[day] = value
        
        am.update(alarm: self, days: control)
        
        
        
    }

    // Tell weather an Alarm will repeat or will be a one time alarm
    var isRepeating: Bool {
        for (_, value) in decodedRepeatingDays {
            if value == true {
                return true
            }
        }
        return false
    }
}
