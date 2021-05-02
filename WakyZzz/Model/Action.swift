//
//  Action.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import UIKit
import Foundation
import MessageUI

class Action {
    
    var caption: String
    var title: String
    
    init(caption: String, title: String) {
        self.caption = caption
        self.title = title 
    }
    
}


// Messages Delegate
extension AlarmsViewController: MFMessageComposeViewControllerDelegate {
    
    /// Handle message controller events
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            
            // Create reminder to send a message
            // Leave notification bage as 1
            
            print("Message Cancelled")
            dismiss(animated: true)
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
        
        let alert = UIAlertController(title: "",
                                      message: "Time to complete a Random Act of Kindness.",
                                      preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Message a Friend",
                                      style: .default,
                                      handler: { (action) in
                                        
                                        self.createComposeMessageView()
                                      }))
        
        alert.addAction(UIAlertAction(title: "RAK 2",
                                      style: .default,
                                      handler: { (action) in
                                        
                                      }))
        
        alert.addAction(UIAlertAction(title: "Done",
                                      style: .destructive,
                                      handler: { (action) in
                                        alert.dismiss(animated: true)
                                      }))
        
        self.present(alert, animated: true)
        
    }

    
}
