//
//  Alarm+CoreDataProperties.swift
//  WakyZzz
//
//  Created by Matthew Sousa on 5/5/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//
//

import Foundation
import CoreData


extension Alarm {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Alarm> {
        return NSFetchRequest<Alarm>(entityName: "Alarm")
    }

    @NSManaged public var time: Int32
    @NSManaged public var enabled: Bool
    @NSManaged public var uuid: String?
    @NSManaged public var snoozeCount: Int16
    @NSManaged public var originalTime: String?
    @NSManaged public var repeatingDays: String?

    
}
