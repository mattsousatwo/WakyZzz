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
    
    /// Returns three Int values of the count of each Action type stored in savedActionContacts
    var countOfSavedIncompleteTypes: (email: Int, call: Int, text: Int) {
        var emails = 0
        var calls = 0
        var texts = 0
        
        refreshActionContacts()
        
        for contact in savedActionContacts {
            if contact.status == ActionStatus.inactive.rawValue {
                
                switch contact.type {
                case ActionType.email.rawValue:
                    emails += 1
                case ActionType.call.rawValue:
                    calls += 1
                case ActionType.text.rawValue:
                    texts += 1
                default:
                    break
                }
                
            }
            
        }
        
        return (emails, calls, texts)
    }
    
    // All ActionContacts with status as .active or .inactive
    var incompleteActions: [ActionContact] {
        refreshActionContacts()
        var contacts: [ActionContact] = []
        
        for contact in savedActionContacts {
            if contact.status == ActionStatus.active.rawValue ||
                contact.status == ActionStatus.inactive.rawValue {
                contacts.append(contact)
            }
        }
        return contacts
    }
    
    // All ActionContacts with status as .complete
    var completeActions: [ActionContact] {
        refreshActionContacts()
        var contacts: [ActionContact] = []
        
        for contact in savedActionContacts {
            if contact.status == ActionStatus.complete.rawValue {
                contacts.append(contact)
            }
        }
        return contacts
    }

    // All ActionContacts with status as .active
    var activeActions: [ActionContact] {
        refreshActionContacts()
        var contacts: [ActionContact] = []
        
        for contact in savedActionContacts {
            if contact.status == ActionStatus.active.rawValue {
                contacts.append(contact)
            }
        }
        return contacts
    }

    
    
    
    /// Types of actions that need to be created to store one of each ActionType for selection
    var typesToBeCreated: [ActionType] {
        
        var types: [ActionType] = []
        let contactControl = ContactControl()
        if contactControl.contactEmailList.count != 0 {
            if countOfSavedIncompleteTypes.email == 0 {
                types.append(ActionType.email)
            }

        }
        
        if countOfSavedIncompleteTypes.call == 0 {
            types.append(ActionType.call)
        }
        
        if countOfSavedIncompleteTypes.text <= 1 {
            types.append(ActionType.text)
        }
        
        return types
    }
    
    /// Randomly select two actions
    func shuffleContacts() -> (actOne: ActionContact?, actTwo: ActionContact?) {
        var actionOne: ActionContact?
        var actionTwo: ActionContact?
        
        refreshActionContacts()
        
        switch incompleteActions.count {
        case 0:
            actionOne = nil
            actionTwo = nil
        case 1:
            actionOne = incompleteActions.first
            actionTwo = nil
        case 2:
            actionOne = incompleteActions.first
            actionTwo = incompleteActions.last
        default:
            let randomInt = Int.random(in: 0..<incompleteActions.count)
            var randomIntTwo = Int.random(in: 0..<incompleteActions.count)
            while randomIntTwo == randomInt {
                randomIntTwo = Int.random(in: 0..<incompleteActions.count)
            }
            actionOne = incompleteActions[randomInt]
            actionTwo = incompleteActions[randomIntTwo]
        }

        return (actOne: actionOne, actTwo: actionTwo)
    }

    
    
    
    
}


enum ActionStatus: String {
    case inactive = "ACTION_INACTIVE"
    case active = "ACTION_ACTIVE"
    case complete = "ACTION_COMPLETE"
}

extension ActionContactManager {

    /**
     Create a new Action Contact to store contact information that is being used in an active action
     
     - Parameters:
        - contactInfo: can be email or phoneNumber as String
        - uuid: use Alarm.uuid as uuid. Will become ("ACTION_CONTACT_" + uuid)
        - type: The type of action used can be .text, .call, .email
        - alarmID: the ID of the alarm this action is attached to
        - status: Shows if ActionContact is in use, pending, or complete
     */
    func createNewActionContact(contactInfo: String,
                                uuid: String? = nil ,
                                type: ActionType = .text,
                                alarmID: String? = nil,
                                status: ActionStatus = .inactive,
                                startDate: String? = nil) {
        
        let actionContact = ActionContact(context: context)
        
        actionContact.contactInfo = contactInfo
        actionContact.type = type.rawValue
        if let uuid = uuid {
            actionContact.uuid = (ACMKey.prefix.rawValue + uuid)
        } else {
            actionContact.uuid = (ACMKey.prefix.rawValue + UUID().uuidString)
        }
        actionContact.status = status.rawValue
        if let id = alarmID {
            actionContact.alarmID = id
        }
        if let startDate = startDate {
            actionContact.startDate = startDate
        }
        
        savedActionContacts.append(actionContact)
        
        saveActionContactContext()
    }
    
    
    func updateAction(contact: ActionContact,
                      contactInfo: String? = nil ,
                      uuid: String? = nil,
                      type: ActionType? = nil,
                      alarmID: String? = nil,
                      status: ActionStatus? = nil ,
                      startDate: String? = nil) {
        
        
        if let contactInfo = contactInfo {
            contact.contactInfo = contactInfo
        }
        if let type = type {
            contact.type = type.rawValue
        }
        if let uuid = uuid {
            contact.uuid = (ACMKey.prefix.rawValue + uuid)
        }
        if let status = status {
            contact.status = status.rawValue
        }
        if let id = alarmID {
            contact.alarmID = id
        }
        if let startDate = startDate {
            contact.startDate = startDate
        }
        
        if contact.hasChanges {
            saveActionContactContext()
        }
    }
    
    
    
}

// Fetching
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
    
    
    /// Search for ActionContact by id and return else return nil
    func fetchActionContactByContactInfo(_ info: String) -> ActionContact? {
        let contactIsLoaded = savedActionContacts.contains(where: { $0.contactInfo == info } )
        
        if contactIsLoaded == true {
            if let foundContact = savedActionContacts.first(where: { $0.contactInfo == info }) {
                return foundContact
            }
        } else {
            let request: NSFetchRequest<ActionContact> = ActionContact.fetchRequest()
            request.predicate = NSPredicate(format: "contactInfo == %@", info)
            var contacts: [ActionContact] = []
            do {
                contacts = try context.fetch(request)
            } catch {
                print(error)
            }
            
            if contacts.count == 0 {
                return nil
            } else {
                if let foundContact = contacts.first(where: { $0.contactInfo == info }) {
                    return foundContact
                }
            }

        }
        
        return nil
    }

    
    func refreshActionContacts() {
        if savedActionContacts.count == 0 {
            fetchAllActionContacts()
        }
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
