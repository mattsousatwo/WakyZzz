//
//  ActionCount+CoreDataProperties.swift
//  WakyZzz
//
//  Created by Matthew Sousa on 6/22/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//
//

import Foundation
import CoreData


extension ActionCount {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ActionCount> {
        return NSFetchRequest<ActionCount>(entityName: "ActionCount")
    }

    @NSManaged public var count: Int16

}

extension ActionCount : Identifiable {

}
