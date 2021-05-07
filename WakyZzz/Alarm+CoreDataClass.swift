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


}
