//
//  ActiveContact+CoreDataProperties.swift
//  WakyZzz
//
//  Created by Matthew Sousa on 5/26/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//
//

import Foundation
import CoreData


extension ActiveContact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ActiveContact> {
        return NSFetchRequest<ActiveContact>(entityName: "ActiveContact")
    }

    @NSManaged public var contactInfo: String?
    @NSManaged public var uuid: String?
    @NSManaged public var parentUUID: String?

}

extension ActiveContact : Identifiable {

}
