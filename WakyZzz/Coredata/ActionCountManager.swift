//
//  ActionCountManager.swift
//  WakyZzz
//
//  Created by Matthew Sousa on 6/22/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ActionCountManager {
    
    var count: ActionCount?
    
    var context: NSManagedObjectContext
    var entity: NSEntityDescription
    
    init() {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        context = appDel.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: "ActionCount", in: context)!
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    /// Create a new count 
    func createCount() -> ActionCount {
        let count = ActionCount(context: context)
        count.count = 0
        self.count = count
        saveContext()
        return count
    }
    
    /// Fetch Count
    func fetchCount() {
        let request: NSFetchRequest<ActionCount> = ActionCount.fetchRequest()
        do {
            let fetchedCount = try context.fetch(request)
            if let fetchedCount = fetchedCount.first {
                count = fetchedCount
            }
        } catch {
            print(error)
        }

    }
    
    /// Fetch or create new count
    func getCount() -> ActionCount {
        fetchCount()
        if let count = count {
            return count
        }
        return createCount()
    }
    
    /// Add one to count
    func updateCount() {
        let count = getCount()
        count.count += 1
        saveContext()
        
    }
    
}
