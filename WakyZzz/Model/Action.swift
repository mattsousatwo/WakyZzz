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
    
    enum ActionType {
        case text, call, email
    }
    
    var title: String
    var message: String? = nil
    var phoneNumber: Int? = nil
    var email: String? = nil
    var type: ActionType = .text
    
    
    init(title: String, message: String? = nil, phoneNumber: Int? = nil, email: String? = nil, type: ActionType) {
        self.title = title
        self.message = message
        self.phoneNumber = phoneNumber
        self.email = email
        self.type = type
        
    }
    
}

class ActionControl {
    
    // List of all actions
    var allActions: [Action] {
        // Calls
        let callOne = Action(title: "Call a Friend", message: "Call a Friend", phoneNumber: 6176690050, type: .call)
        
        // Texts
        let textOne = Action(title: "Message a Friend", message: "How are you doing?", type: .text)
        
        // Emails
        let emailOne = Action(title: "Email a Friend", message: "Hello, how are things going?", email: "mattsousatwo@gmail.com", type: .email)
        
        return [callOne, textOne, emailOne]
    }

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
