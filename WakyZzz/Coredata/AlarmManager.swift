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
    
    var context: NSManagedObjectContext?
    var entity: NSEntityDescription?
    
    init() {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        context = appDel.persistentContainer.viewContext
    }
    
    func saveSelectedContext() {
        guard let context = context else { return }
        do {
            try context.save()
        } catch {
            print(error)
        }
        print(#function)
    }
    
}
