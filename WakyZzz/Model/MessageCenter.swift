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
extension AlarmsViewController {
    
    // Call Phone number
    func call(number phoneNumber: Int) {
        guard let number = URL(string: "tel://\(phoneNumber)") else { return }
        UIApplication.shared.open(number, options: [:], completionHandler: { success in
            if success == true {
                print("Success")
            } else if success == false {
                print("Failure")
            }
            
        })
    }
}

// Mail Delegate
extension AlarmsViewController: MFMailComposeViewControllerDelegate {
    
    // Create an email from action parameters
    func sendEmail(with action: Action) {
        guard let recipient = action.email else { return }
        guard let body = action.message else { return }
        
        if MFMailComposeViewController.canSendMail() {
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = self
            mailVC.setToRecipients([recipient])
            mailVC.setMessageBody(body, isHTML: false)
            
            self.present(mailVC, animated: true)
        }
        
    }
    
    // Handle Mail Events
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Email canceled")
            
            
            controller.dismiss(animated: true)
        case .failed:
            print("Email failed")
            controller.dismiss(animated: true)
        case .saved:
            print("Email saved")
            controller.dismiss(animated: true)
        case .sent:
            print("Email sent")
            controller.dismiss(animated: true)
        default:
            controller.dismiss(animated: true)
        }
    }
}

// Messages Delegate
extension AlarmsViewController: MFMessageComposeViewControllerDelegate {
    
    /// Handle message controller events
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
//        let actionControl = ActionControl()
        
        switch result {
        case .cancelled:
            
            // Create reminder to send a message
            // Leave notification bage as 1
            controller.presentCancelAlertController()
//            actionControl.scheduleReminder()
            
            print("Message Cancelled")
//            dismiss(animated: true)
        case .failed:
            print("Message Failed")
            dismiss(animated: true)
        case .sent:
            
            // Set notification bage as 0
            
            print("Message Sent")
            dismiss(animated: true)
        }
    }
    
    /// Create Message View Controller with preset body
    func createComposeMessageView() {
        let messageVC = MFMessageComposeViewController()
        messageVC.body = "You look amazing today!"
        messageVC.recipients = []
        messageVC.messageComposeDelegate = self
        
        
        if MFMessageComposeViewController.canSendText() {
            self.present(messageVC, animated: true)
            
            
        }
    }
        
    /// Present Alert Controller to execute Action
    func presentActionAlertController() {
        
        // Get two random acts of kindness
        let actions = ActionControl()
        let randomAction = actions.shuffleActions()
                
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
                                                    self.call(number: phoneNumber)
                                                }
                                                break
                                            case .email:
                                                self.sendEmail(with: actionOne)
                                                break
                                            case .text:
                                                self.createComposeMessageView()
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
                                                    self.call(number: phoneNumber)
                                                }
                                                break
                                            case .email:
                                                self.sendEmail(with: actionTwo)
                                                break
                                            case .text:
                                                self.createComposeMessageView()
                                            }

                                          }))
        }
        
        self.present(alert, animated: true)
        
    }

    
}

// Warning Alert Controller for Message
extension MFMessageComposeViewController {
    
    // Present Alert Controller to warn of canceling message
    func presentCancelAlertController() {
        let alert = UIAlertController(title: "WakyZzz",
                                      message: "Would you like to complete this task later?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes",
                                      style: .default,
                                      handler: { (action) in
                                            //schedule notification
                                        
                                        self.dismiss(animated: true)
                                      }))
        alert.addAction(UIAlertAction(title: "No",
                                      style: .destructive,
                                      handler: { (action) in
                                            
                                        
                                      }))
        self.present(alert, animated: true)
        
    }

}
