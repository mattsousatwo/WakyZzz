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
    case prefix = "ACTION_CONTACT_"
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

extension ActionContactManager {

    /**
     Create a new Action Contact to store contact information that is being used in an active action
     
     - Parameters:
        - type: The type of action used can be .text, .call, .email
        - contactInfo: can be email or phoneNumber as String
        - uuid: use Alarm.uuid as uuid. Will become ("ACTION_CONTACT_" + uuid)
     */
    func createNewActionContact(type: ActionType = .text,
                                contactInfo: String,
                                uuid: String) {
        
        let actionContact = ActionContact(context: context)
        
        actionContact.contactInfo = contactInfo
        actionContact.type = type.rawValue
        actionContact.uuid = (ACMKey.prefix.rawValue + uuid)
        
        savedActionContacts.append(actionContact)
        
        saveActionContactContext()
    }
    
    
}

extension ActionContactManager {
    
    func fetchAllActionContacts() {
        let request: NSFetchRequest<ActionContact> = ActionContact.fetchRequest()
        do {
            savedActionContacts = try context.fetch(request)
        } catch {
            print(error)
        }
    }
    
    /// Search for ActionContact by id and return else return nil
    func fetchActionContact(id: String) -> ActionContact? {
        let contactIsLoaded = savedActionContacts.contains(where: { $0.uuid == id } )
        
        if contactIsLoaded == true {
            if let foundContact = savedActionContacts.first(where: { $0.uuid == id }) {
                return foundContact
            }
        } else {
            let request: NSFetchRequest<ActionContact> = ActionContact.fetchRequest()
            request.predicate = NSPredicate(format: "uuid == %@", id)
            var contacts: [ActionContact] = []
            do {
                contacts = try context.fetch(request)
            } catch {
                print(error)
            }
            
            if contacts.count == 0 {
                return nil
            } else {
                if let foundContact = contacts.first(where: { $0.uuid == id }) {
                    return foundContact
                }
            }

        }
        
        return nil
    }
    
    
}


// Delete
extension ActionContactManager {
    
    /// Delete all elements for type
    func deleteAllActionContacts() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ACMKey.entity.rawValue)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(deleteRequest)
            savedActionContacts.removeAll()
        } catch {
            print(error)
        }
    }
    
    // Delete specific element
    func deleteActionContact(uuid: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: ACMKey.entity.rawValue)
        request.predicate = NSPredicate(format: "uuid == %@", uuid)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(deleteRequest)
            savedActionContacts.removeAll(where: { $0.uuid == uuid })
        } catch {
            print(error)
        }

    }
    
}
