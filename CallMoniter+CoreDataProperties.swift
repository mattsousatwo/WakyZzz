//
//  CallMoniter+CoreDataProperties.swift
//  WakyZzz
//
//  Created by Matthew Sousa on 6/22/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//
//

import Foundation
import CoreData


extension CallMoniter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CallMoniter> {
        return NSFetchRequest<CallMoniter>(entityName: "CallMoniter")
    }

    @NSManaged public var isComplete: Bool
    @NSManaged public var parentUUID: String?
    @NSManaged public var uuid: String?

}

extension CallMoniter : Identifiable {

}
