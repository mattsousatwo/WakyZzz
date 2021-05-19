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
        guard let number = URL(string: "tel://\(phoneNumber)") else { return }
        UIApplication.shared.open(number, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { success in
            if success == true {
                print("Success")
            } else if success == false {
                print("Failure")
            }
            
        })
    }
    
    
    /// Create Message View Controller with preset body
    func createComposeMessageView(in view: UIViewController) {
        let messageVC = MFMessageComposeViewController()
        messageVC.body = "You look amazing today!"
        messageVC.recipients = []
        messageVC.messageComposeDelegate = view
        
        if MFMessageComposeViewController.canSendText() {
            view.present(messageVC, animated: true)
            
            
        }
    }
    
}

// Mail Delegate
extension MessageCenter: MFMailComposeViewControllerDelegate {
    
    // Create an email from action parameters
    func sendEmail(with action: Action, in view: UIViewController) {
        guard let recipient = action.email else { return }
        guard let body = action.message else { return }
        
        if MFMailComposeViewController.canSendMail() {
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = self
            mailVC.setToRecipients([recipient])
            mailVC.setMessageBody(body, isHTML: false)
            
            view.present(mailVC, animated: true)
        }
        
    }
    
    // Handle Mail Events
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        let view = controller.presentingViewController
        
        
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
                self.nm.clearBadgeNumbers()
            }
        default:
            controller.dismiss(animated: true)
        }
    }
}



// Messages Delegate
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

    
    /// Handle message controller events
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
    /// Present Alert Controller to execute Action
    func presentActionAlertController() {
        print(#function)
        // Get two random acts of kindness
        let actions = ActionControl()
        let randomAction = actions.shuffleActions()
        let messageCenter = MessageCenter()
        let nm = NotificationManager()
        
        let alert = UIAlertController(title: "WakyZzz",
                                      message: "Time to complete a Random Act of Kindness.",
                                      preferredStyle: .actionSheet)
        
        if let actionOne = randomAction.actOne {
            alert.addAction(UIAlertAction(title: actionOne.title,
                                          style: .default,
                                          handler: { (action) in
                                            
                                            switch actionOne.type {
                                            case .call:
                                                if let phoneNumber = actionOne.phoneNumber {
                                                    messageCenter.call(number: phoneNumber)
                                                }
                                                break
                                            case .email:
                                                messageCenter.sendEmail(with: actionOne, in: self)
                                                break
                                            case .text:
                                                messageCenter.createComposeMessageView(in: self)
                                                break
                                            }
                           
                                          }))
        }
        
        if let actionTwo = randomAction.actTwo {
            alert.addAction(UIAlertAction(title: actionTwo.title,
                                          style: .default,
                                          handler: { (action) in
                                            
                                            switch actionTwo.type {
                                            case .call:
                                                if let phoneNumber = actionTwo.phoneNumber {
                                                    messageCenter.call(number: phoneNumber)
                                                }
                                                break
                                            case .email:
                                                messageCenter.sendEmail(with: actionTwo, in: self)
                                                break
                                            case .text:
                                                messageCenter.createComposeMessageView(in: self)
                                            }

                                          }))
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
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
