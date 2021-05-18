//
//  ContactsControl.swift
//  WakyZzz
//
//  Created by Matthew Sousa on 5/18/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

import Foundation
import Contacts
import UIKit

class ContactControl {
    
    var contactList: [CNContact] = []
    let contactStore = CNContactStore()
    
    var authorizationStatus: CNAuthorizationStatus {
        return CNContactStore.authorizationStatus(for: .contacts)
    }
    
    func requestAccess(in view: UIViewController) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            
            
            self.getContacts()
            if let randomContact = self.getRandomContactInfo() {
                print("Contact name: \(randomContact.givenName)")
                if let phoneNumber = self.getPhoneNumber(from: randomContact) {
                    print("Contact name: \(randomContact.givenName), \(phoneNumber)")
                }
                
            }
            
                
            
        
            
        case .denied:
            showSettingsAlert(in: view)
        default:
            contactStore.requestAccess(for: .contacts) { granted, error in
//                if granted != true {
//                    DispatchQueue.main.async {
                self.showSettingsAlert(in: view)
//                    }
//                }
                
            }
            
        }
    }
    
    func showSettingsAlert(in view: UIViewController) {
        
        let alert = UIAlertController(title: "WakyZzz",
                                      message: "This app requires access to your contact list to proceed. Go to Settings to grant access.",
                                      preferredStyle: .alert)
        if let settingsURL = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsURL) {
            alert.addAction(UIAlertAction(title: "Open Settings",
                                          style: .default,
                                          handler: { (action) in
                                            
                                            UIApplication.shared.open(settingsURL)
                                            alert.dismiss(animated: true)
                                          }))
        }
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel,
                                      handler: { (action) in
                                        alert.dismiss(animated: true)
                                      }))
        
        view.present(alert, animated: true)
        
    }
    
    
    
    // Get a list of all Contacts with phone numbers
    func getListOfContactNumbers() {
        
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
        let request = CNContactFetchRequest(keysToFetch: keys)
        
        let contactStore = CNContactStore()
        
        if authorizationStatus == .authorized {
            do {
                try contactStore.enumerateContacts(with: request) { (contact, stop) in
                    
                    
                    if contact.phoneNumbers.count != 0 {
                        self.contactList.append(contact)
                    }
                    
                    self.getContacts()
                }
            } catch {
                print(error)
            }
        }
        print("Contacts Count: \(self.contactList.count)")
        
    }
    
    // get a random contact from the list of contacts
    func getRandomContactInfo() -> CNContact? {
        if contactList.count != 0 {
            let randomInt = Int.random(in: 0..<contactList.count)
            return contactList[randomInt]
        }
        return nil
    }
    
    // unwrap first phone number from contact
    func getPhoneNumber(from contact: CNContact) -> [String]? {
        var numbers: [String]?
        for phoneNumber in contact.phoneNumbers {
            let number = phoneNumber.value
            numbers?.append(number.stringValue)
        }
        return numbers
    }
    
    func getContacts() {
        
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey, CNContactEmailAddressesKey] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request) { (contact, stop) in
                
                self.contactList.append(contact)
                for phoneNumber in contact.phoneNumbers {
                    if let number = phoneNumber.value as? CNPhoneNumber, let label = phoneNumber.label {
                        let localizedLable = CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: label)
                        
                        print("Contacts.count: \(self.contactList.count), name: \(contact.givenName), tel: \(localizedLable) - \(number.stringValue)  ")
                        
                        
                    }
                }
                
                
            }
        } catch {
            print(error)
        }

        
    }
}
