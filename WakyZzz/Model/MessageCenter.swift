//
//  MessageCenter.swift
//  WakyZzz
//
//  Created by Matthew Sousa on 5/8/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

import Foundation
import UIKit
import MessageUI


// Phone Call
class MessageCenter: NSObject {
    
    let nm = NotificationManager()
    
    // Call Phone number
    func call(number phoneNumber: String) {
        
        let optionalPhoneNumber = phoneNumber.convertToPhoneNumber()
        guard let phone = optionalPhoneNumber else { return }
        
        guard let number = URL(string: "tel://\(phone)") else { return }
        UIApplication.shared.open(number, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { success in
            if success == true {
                print("Success")
            } else if success == false {
                print("Failure")
            }
            
        })
    }
    
    
    /// Create Message View Controller
    func createComposeMessageView(to recipient: String, in view: UIViewController) {
        let messageVC = MFMessageComposeViewController()
        messageVC.body = "You look amazing today!"
        messageVC.recipients = [recipient]
        messageVC.messageComposeDelegate = view
        
        if MFMessageComposeViewController.canSendText() {
            view.present(messageVC, animated: true)
            
            
        }
    }
    
    // Create an email from action parameters
    func sendEmail(to recipient: String, in view: UIViewController) {
        let body = "Hello, How are you?"

        if MFMailComposeViewController.canSendMail() {
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = view
            mailVC.setToRecipients([recipient])
            mailVC.setMessageBody(body, isHTML: false)

            view.present(mailVC, animated: true)
        }

    }
    
}



extension UIViewController: MFMailComposeViewControllerDelegate {
    
    // Create an email from action parameters
    func sendEmail(to recipient: String, in view: UIViewController) {
        let body = "Hello, How are you?"
        
        if MFMailComposeViewController.canSendMail() {
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = self
            mailVC.setToRecipients([recipient])
            mailVC.setMessageBody(body, isHTML: false)
            
            view.present(mailVC, animated: true)
        }
        
    }
    
    // Handle Mail Events
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        let nm = NotificationManager()
        let view = controller.presentingViewController
        print("\nMAIL COMPOSE CONTROLLER")
        
        
        switch result {
        case .cancelled:
            print("Email canceled")
            
            controller.dismiss(animated: true) {
                view?.presentCancelAlert()
            }
            
        case .failed:
            print("Email failed")
            controller.dismiss(animated: true) {
                
                view?.presentActionAlertController()
            }
        case .saved:
            print("Email saved")
            controller.dismiss(animated: true)
        case .sent:
            print("Email sent")
            controller.dismiss(animated: true) {
                nm.clearBadgeNumbers()
            }
        default:
            controller.dismiss(animated: true)
        }
    }
}


// Text Message Delegate
extension UIViewController: MFMessageComposeViewControllerDelegate {
    
    // Present Alert Controller to warn of canceling message
    func presentCancelAlert() {
        let alert = UIAlertController(title: "WakyZzz",
                                      message: "We will set a reminder for you to complete a task in 30 minutes.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay",
                                      style: .default,
                                      handler: { (action) in
                                        
                                        // Schedule Reminder
                                        let notificationManager = NotificationManager()
                                        notificationManager.scheduleReminder()
                                        
                                        self.dismiss(animated: true)
                                      }))
        
        // If on iPad
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            let bounds = self.view.bounds
            popoverController.sourceRect = CGRect(x: bounds.minX,
                                                  y: bounds.midY,
                                                  width: bounds.width,
                                                  height: bounds.height)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(alert, animated: true)
        
    }

    
    /// Handle text message controller events
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        let nm = NotificationManager()
        
        switch result {
        case .cancelled:

            
            dismiss(animated: true) {
                self.presentCancelAlert()
            }
            
            print("Message Cancelled")
        case .failed:
            print("Message Failed")
            dismiss(animated: true) {
                self.presentActionAlertController()
            }
        case .sent:
            
            nm.clearBadgeNumbers()
            
            dismiss(animated: true)
        default:
            dismiss(animated: true)
            break
        }
    }
        
}

extension UIViewController {
    
    /// All Action Contacts accesable to UIViewController
    var actionContacts: [ActionContact] {
        let actionCM = ActionContactManager()
        actionCM.fetchAllActionContacts()
        return actionCM.savedActionContacts
    }
    
    
    
    /// Present Alert Controller to execute Action
    func presentActionAlertController() {

        print(#function)
        // Get two random acts of kindness
        let actionContact = ActionContactManager()
        let randomContact = actionContact.shuffleContacts()
        let nm = NotificationManager()
        
        let alert = UIAlertController(title: "WakyZzz",
                                      message: "Time to complete a Random Act of Kindness.",
                                      preferredStyle: .actionSheet)
        
        
        if self.actionContacts.count != 0 {
            if let actOne = randomContact.actOne {
                
                let alertOne = createAlertAction(with: actOne)
                alert.addAction(alertOne)
    
            }
            
            if let actTwo = randomContact.actTwo {
                let alertTwo = createAlertAction(with: actTwo)
                alert.addAction(alertTwo)
            }
        }
        
        
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel,
                                      handler: { (action) in
                                        
                                        nm.scheduleReminder()
                                        
                                      }))
        
        // If on iPad
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            let bounds = self.view.bounds
            popoverController.sourceRect = CGRect(x: bounds.minX,
                                                  y: bounds.midY,
                                                  width: bounds.width,
                                                  height: bounds.height)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(alert, animated: true)
        
    }
    
    /// Produce an Action for an alert controller
    func createAlertAction(with contact: ActionContact) -> UIAlertAction {
        let messageCenter = MessageCenter()

        var title: String {
            switch contact.type {
            case ActionType.email.rawValue:
                return "Email Friend"
            case ActionType.call.rawValue:
                return "Call Friend"
            case ActionType.text.rawValue:
                return "Text Friend"
            default:
                return "UNDEFINED"
            }
        }
        let alert = UIAlertAction(title: title,
                                      style: .default,
                                      handler: { (action) in
                                        
                                        switch contact.type {
                                        case ActionType.call.rawValue:
                                            if let phoneNumber = contact.contactInfo {
                                                messageCenter.call(number: phoneNumber)
                                            }
                                            break
                                        case ActionType.email.rawValue:
                                            if let email = contact.contactInfo {
                                                
                                                messageCenter.sendEmail(to: email, in: self)
                                            }
                                            break
                                        case ActionType.text.rawValue:
                                            if let phoneNumber = contact.contactInfo {
                                                messageCenter.createComposeMessageView(to: phoneNumber, in: self)
                                            }
                                            break
                                        default:
                                            break
                                        }
                       
                                      })
        return alert
    }
    
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
