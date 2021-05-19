//
//  ActionContact+CoreDataProperties.swift
//  WakyZzz
//
//  Created by Matthew Sousa on 5/19/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//
//

import Foundation
import CoreData


extension ActionContact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ActionContact> {
        return NSFetchRequest<ActionContact>(entityName: "ActionContact")
    }

    @NSManaged public var type: String?
    @NSManaged public var contactInfo: String?
    @NSManaged public var uuid: String?

}

extension ActionContact : Identifiable {

}
