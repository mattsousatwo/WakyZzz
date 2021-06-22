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

class ContactControl: ActionContactManager {
    
    var contactList: [CNContact] = []
    var contactEmailList: [String] = []
    let contactStore = CNContactStore()
    var number: String?
    
    var authorizationStatus: CNAuthorizationStatus {
        return CNContactStore.authorizationStatus(for: .contacts)
    }
    
    
    /// Check if authorization status for contacts is enabled, if so create an action contact if minimum has not been met
    func createActionContacts(view: UIViewController) {
        switch authorizationStatus {
        case .authorized:
            
            fetchContactsAndCreateActions()
            
            
//            for type in typesToBeCreated {
//                if let randomContact = self.getRandomContactInfo() {
//                    switch type {
//                    case .email:
//                        if let email = self.unwrapEmail(contact: randomContact) {
//                            createNewActionContact(contactInfo: email, type: .email, status: .inactive)
//                        }
//                    case .call:
//                        if let phoneNumber = self.unwrapPhoneNumbers(contact: randomContact) {
//                            createNewActionContact(contactInfo: phoneNumber, type: .call, status: .inactive)
//                        }
//                    case .text:
//                        if let phoneNumber = self.unwrapPhoneNumbers(contact: randomContact) {
//                            createNewActionContact(contactInfo: phoneNumber, type: .text, status: .inactive)
//                        }
//                    }
//                }
//            }
//
            
        default:
            requestAccess(in: view)
        }
    }
    
    
    /// Request Access to useres Contacts - Get Random Contact to add to Saved ActionContacts if less than three are tagged inactive, or active
    func requestAccess(in view: UIViewController) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            
            fetchAllActionContacts()
            // If less than three ActionContactsSaved
            if savedActionContacts.count < 3 {
                
                // Fetch Contact List
                self.fetchContactsAndCreateActions()
                
            
            
            
            }
            
        case .denied:
            showSettingsAlert(in: view)
        default:
            contactStore.requestAccess(for: .contacts) { granted, error in
                if granted != true {
                    DispatchQueue.main.async {
                self.showSettingsAlert(in: view)
                
                    }
                }
                
            }
            
        }
    }
    
    
    /// Present Alert Message to warn user that the app requires access to their contacts for full functionality - direct user to WakyZzz Settings Page
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
        
        // If on iPad
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = view.view
            let bounds = view.view.bounds
            popoverController.sourceRect = CGRect(x: bounds.minX,
                                                  y: bounds.midY,
                                                  width: bounds.width,
                                                  height: bounds.height)
            popoverController.permittedArrowDirections = []
        }
        
        view.present(alert, animated: true)
        
    }
    
    // get a random contact from the list of contacts
    func getRandomContactPhoneNumber() -> String? {
        if contactList.count != 0 {
            let randomInt = Int.random(in: 0..<contactList.count)
            if let phoneNumber = unwrapPhoneNumbers(contact: contactList[randomInt]) {
                return phoneNumber
            }
        }
        return nil
    }
    
    /// Get random Email from contact list if avalible
    func getRandomContactEmail() -> String? {
        if contactEmailList.count != 0 {
            let randomInt = Int.random(in: 0..<contactEmailList.count)
            return contactEmailList[randomInt]
        }
        return nil
    }
    
    func fetchContactsAndCreateActions() {
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey, CNContactEmailAddressesKey] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            
                try contactStore.enumerateContacts(with: request) { (contact, stop) in
                
                self.contactList.append(contact)
                
                for contact in self.contactList {
                    if let email = self.unwrapEmail(contact: contact) {
                        self.contactEmailList.append(email)
                    }
                }

//                // ONLY FOR PRESENTATION -- Print contacts list
                for phoneNumber in contact.phoneNumbers {
                    if let label = phoneNumber.label {
                        let number = phoneNumber.value
                        let localizedLable = CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: label)
                        print("Contacts.count: \(self.contactList.count), name: \(contact.givenName), tel: \(localizedLable) - \(number.stringValue)  ")
                    }
                }


                
                
                
            }
            
            for type in typesToBeCreated {

                switch type {
                case .email:
                    if let email = self.getRandomContactEmail() {
                        createNewActionContact(contactInfo: email, type: .email, status: .inactive)
                    }
                case .call:
                    if let phoneNumber = self.getRandomContactPhoneNumber() {

                            createNewActionContact(contactInfo: phoneNumber, type: .call, status: .inactive)

                    }
                case .text:
                    if let phoneNumber = self.getRandomContactPhoneNumber() {

                            createNewActionContact(contactInfo: phoneNumber, type: .text, status: .inactive)

                    }
                }

            }
            
        } catch {
            print(error)
        }
    }
    
    /// Unwrap first phone number from contact
    func unwrapPhoneNumbers(contact: CNContact) -> String? {
        var numbers: [CNPhoneNumber] = []
        for phoneNumber in contact.phoneNumbers {
            let number = phoneNumber.value
            numbers.append(number)
        }
        if numbers.count == 0 {
            return nil
        } else {
            let randomIndex = Int.random(in: 0..<numbers.count)
            return "\(numbers[randomIndex].stringValue)"
        }
    }
    
    
    /// Unwrap first email address from contact
    func unwrapEmail(contact: CNContact) -> String? {
        var emails: [String] = []
        for email in contact.emailAddresses {
            let address = email.value
            emails.append(address as String)
        }
        if emails.count == 0 {
            return nil
        } else {
            let randomIndex = Int.random(in: 0..<emails.count)
            return "\(emails[randomIndex])"
        }
    }
    
    
}
