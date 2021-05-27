//
//  ActiveContactManager.swift
//  WakyZzz
//
//  Created by Matthew Sousa on 5/26/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class ActiveContactManager {
    
    var activeContact: ActiveContact?
    
    var context: NSManagedObjectContext
    var entity: NSEntityDescription
    
    
    init() {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        context = appDel.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: "ActiveContact", in: context)!
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print(error)
        }
        print(#function)
    }
}

extension ActiveContactManager {
    
    /// Create a new ActiveContact & set activeContact as newly created contact
    func createNewActiveContact(contactInfo: String,
                                parentUUID: String,
                                uuid: String? = nil) {
        let contact = ActiveContact(context: context)
        
        contact.contactInfo = contactInfo
        contact.parentUUID = parentUUID
        if let uuid = uuid {
            contact.uuid = uuid
        } else {
            contact.uuid = UUID().uuidString
        }
        
        activeContact = contact
        
        saveContext()
    }
    
    /// Create a new ActiveContact & set activeContact as newly created contact
    func createActive(contact: ActionContact, uuid: String? = nil) {
        let contact = ActiveContact(context: context)
        
        if let contactInfo = contact.contactInfo {
            contact.contactInfo = contactInfo
        }
        if let parentUUID = contact.uuid {
            contact.parentUUID = parentUUID
        }
        if let uuid = uuid {
            contact.uuid = uuid
        } else {
            contact.uuid = UUID().uuidString
        }
        
        activeContact = contact
        
        saveContext()
        print("\n New Active Contact - info: \(contact.contactInfo ?? ""), parentID: \(contact.uuid ?? "")")
    }
    
}

extension ActiveContactManager {
    
    /// Fetch for ActiveContacts parent ActionContact to set as complete, then delete current ActiveContact
    func completeAction() {
        let acm = ActionContactManager()
        guard let activeContact = fetchActiveContact() else { return }
        guard let parentUUID = activeContact.parentUUID else { return }
        guard let actionContact = acm.fetchActionContact(id: parentUUID) else { return }
        acm.updateAction(contact: actionContact, status: .complete)
        print("Complete Action - actionContact: \(actionContact.uuid ?? "") setTo: \(actionContact.status ?? "")")
        
        deleteActiveContact()
    
    }
    
    /// Get Current ActiveContact
    func fetchActiveContact() -> ActiveContact? {
        if let activeContact = activeContact {
            return activeContact
        }
        var activeContact: ActiveContact?
        let request: NSFetchRequest<ActiveContact> = ActiveContact.fetchRequest()
        do {
            let contacts = try context.fetch(request)
            activeContact = contacts.first
        } catch {
            print(error)
        }
        if let activeContact = activeContact {
            return activeContact
        }
        return nil
    }
    
    
    
}


extension ActiveContactManager {
    
    /// Delete active contact
    func deleteActiveContact() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ActiveContact")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(deleteRequest)
            activeContact = nil
        } catch {
            print(error)
        }

    }
    
}
