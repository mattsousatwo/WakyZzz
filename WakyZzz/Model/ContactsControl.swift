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
    var number: String?
    
    
    var authorizationStatus: CNAuthorizationStatus {
        return CNContactStore.authorizationStatus(for: .contacts)
    }
    
    func requestAccess(in view: UIViewController, completion: @escaping (String) -> Void) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            
            self.getContacts()
            if let randomContact = self.getRandomContactInfo() {
                print("Contact name: \(randomContact.givenName)")
                if let phoneNumber = self.unwrapPhoneNumbers(contact: randomContact) {
                    print("Contact name: \(randomContact.givenName), \(phoneNumber)")
                    number = phoneNumber
                    completion(phoneNumber)
                }
                
                if let email = self.unwrapEmail(contact: randomContact) {
                    print("Contact name: \(randomContact.givenName), \(email)")
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
    func getRandomContactInfo() -> CNContact? {
        if contactList.count != 0 {
            let randomInt = Int.random(in: 0..<contactList.count)
            return contactList[randomInt]
        }
        return nil
    }
    
    func getContacts() {
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey, CNContactEmailAddressesKey] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request) { (contact, stop) in
                
                self.contactList.append(contact)
                for phoneNumber in contact.phoneNumbers {
                    if let label = phoneNumber.label {
                        let number = phoneNumber.value
                        let localizedLable = CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: label)
                        print("Contacts.count: \(self.contactList.count), name: \(contact.givenName), tel: \(localizedLable) - \(number.stringValue)  ")
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
