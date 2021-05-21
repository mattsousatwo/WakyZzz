//
//  Action.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import Foundation

enum ActionType: String {
    case text = "TEXT_ACTION"
    case call = "CALL_ACTION"
    case email = "EMAIL_ACTION"
}

class Action: Equatable {
    static func == (lhs: Action, rhs: Action) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    var title: String?
    var message: String? = nil
    var phoneNumber: String? = nil
    var email: String? = nil
    var type: ActionType = .text
    var uuid = UUID().uuidString
    
    init(title: String?, message: String? = nil, phoneNumber: String? = nil, email: String? = nil, type: ActionType) {
        self.title = title
        self.message = message
        self.phoneNumber = phoneNumber
        self.email = email
        self.type = type
    }
    
}

