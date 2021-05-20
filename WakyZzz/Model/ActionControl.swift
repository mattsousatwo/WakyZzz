//
//  ActionControl.swift
//  WakyZzz
//
//  Created by Matthew Sousa on 5/18/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

import Foundation
import UIKit


class ActionControl: ContactControl {
    
    func configure(_ view: UIViewController) {
        requestAccess(in: view) { (phoneNumber) in
                
                let call = Action(title: "Random Call",
                                  message: "Call a random Person",
                                  phoneNumber: phoneNumber,
                                  email: nil,
                                  type: .call)
                self.allActions.append(call)
                
                
                
                
                
            
        }
    }
    
    var allActions: [Action] = []
    
    
    
    // List of all actions
//    var allActions: [Action] {
//        var actions: [Action] = []
//
//        // Cannot get Random person contact
//        if let randomNumber = randomNumber {
//            let randomCall = Action(title: "Random Call", message: "Call a random Person", phoneNumber: randomNumber, email: nil, type: .call)
//            actions.append(randomCall)
//        }
//
        // Calls
//        let callOne = Action(title: "Call a Friend", message: "Call a Friend", phoneNumber: nil, type: .call)
//        actions.append(callOne)
        
        // Texts
//        let textOne = Action(title: "Message a Friend", message: "How are you doing?", type: .text)
//        actions.append(textOne)
//
//        // Emails
//        let emailOne = Action(title: "Email a Friend", message: "Hello, how are things going?", email: "mattsousatwo@gmail.com", type: .email)
//        actions.append(emailOne)
//
//        return actions
//    }

    /// Randomly select two actions
    func shuffleActions() -> (actOne: Action?, actTwo: Action?) {
        var actionOne: Action?
        var actionTwo: Action?
        
        switch allActions.count {
        case 0:
            actionOne = nil
            actionTwo = nil
        case 1:
            actionOne = allActions.first
            actionTwo = nil
        case 2:
            actionOne = allActions.first
            actionTwo = allActions.last
        default:
            let randomInt = Int.random(in: 0..<allActions.count)
            var randomIntTwo = Int.random(in: 0..<allActions.count)
            while randomIntTwo == randomInt {
                randomIntTwo = Int.random(in: 0..<allActions.count)
            }
            actionOne = allActions[randomInt]
            actionTwo = allActions[randomIntTwo]
        }

        return (actOne: actionOne, actTwo: actionTwo)
    }

    
}
