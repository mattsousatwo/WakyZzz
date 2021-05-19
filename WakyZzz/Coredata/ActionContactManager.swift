//
//  ActionContactManager.swift
//  WakyZzz
//
//  Created by Matthew Sousa on 5/19/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

import Foundation
import CoreData
import UIKit

enum ACMKey: String {
    case entity = "ActionContact"
}


class ActionContactManager {
    
    var savedActionContacts: [ActionContact] = []
    
    var context: NSManagedObjectContext
    var entity: NSEntityDescription
    
    init() {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        context = appDel.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: ACMKey.entity.rawValue, in: context)!
    }
    
    func saveActionContactContext() {
        do {
            try context.save()
        } catch {
            print(error)
        }
        print(#function)
    }
    
}
