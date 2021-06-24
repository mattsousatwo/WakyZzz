//
//  CallMoniterManager.swift
//  WakyZzz
//
//  Created by Matthew Sousa on 6/22/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CallMoniterManager {
    
    var callMoniters: [CallMoniter]?
    
    var context: NSManagedObjectContext
    var entity: NSEntityDescription
    
    init() {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        context = appDel.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: "CallMoniter", in: context)!
    }
    
    func saveContext() {
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    
    func createNew(parentID: String) {
        let moniter = CallMoniter(context: context)
        moniter.isComplete = false
        moniter.uuid = UUID().uuidString
        moniter.parentUUID = parentID
        saveContext()
        print("\n- Create new moniter, parentID: \(parentID)\n")
    }
    
    func setAsComplete(parentID: String) {
        refreshMoniters()
        print(#function)
        guard let callMoniters = callMoniters else { return }
        for moniter in callMoniters {
            if moniter.parentUUID == parentID {
                moniter.isComplete = true
            }
        }
        print("\n- Set call moniter as complete, parentID: \(parentID)\n")
        saveContext()
    }
    
    func fetchAll() {
        let request: NSFetchRequest<CallMoniter> = CallMoniter.fetchRequest()
        do {
            callMoniters = try context.fetch(request)
        } catch {
            print(error)
        }
    }
    
    func refreshMoniters() {
        if callMoniters?.count == 0 {
            fetchAll()
        }
    }
    
    func getActiveMoniters() -> [CallMoniter]? {
        refreshMoniters()
        guard let callMoniters = callMoniters else { return nil }
        var moniters = [CallMoniter]()
        for moniter in callMoniters {
            if moniter.isComplete == false {
                moniters.append(moniter)
            }
        }
        return moniters
    }
    
    
    func fetchAndCompareIfActiveContactIsComplete() {
        let activeContacts = ActiveContactManager()
        let active = activeContacts.fetchActiveContact()
        if let parentID = active?.parentUUID {
            let actionContacts = ActionContactManager()
            for id in actionContacts.activeActions {
                if id.uuid == parentID {
                    if let contact = actionContacts.activeActions.first(where: { $0.uuid == parentID }) {
                        activeContacts.completeAction()
                        print("Active contact type: \(contact.type ?? "nil")")
                        if contact.status == ActionStatus.complete.rawValue {
                            setAsComplete(parentID: parentID)
                            
                            guard let appDel = UIApplication.shared.delegate as? AppDelegate else { return }
                            if let view = appDel.window?.rootViewController {
                                view.presentCompletionAlertController()
                            }

                            
//                            let n = AlarmsViewController()
//                            n.presentCompletionAlertController()
                            
                        }
                        
                    }
                    
                }
            }
            
        }
    }
    
    
    
    
}
