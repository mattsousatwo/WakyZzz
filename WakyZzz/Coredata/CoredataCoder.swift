//
//  CoredataCoder.swift
//  WakyZzz
//
//  Created by Matthew Sousa on 5/6/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

import Foundation

class CoredataCoder {
    
    lazy var formatter = DateFormatter()
    lazy var decoder = JSONDecoder()
    lazy var encoder = JSONEncoder()
    
    // Encode Days to String 
    func encode(days: [Day : Bool]) -> String? {
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(days) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    // Decode days String to a dict of days
    func decode(days: String) -> [Day : Bool]? {
        guard let data = days.data(using: .utf8) else { return nil }
        guard let repeatDays = try? decoder.decode([Day:Bool].self, from: data) else { return nil }
        return repeatDays
    }
    
    // Set date to standard format 
    func format(date: Date) -> String {
        formatter.dateStyle = .full
        formatter.timeStyle = .full
        return formatter.string(from: date)
    }
    
    // Return Date from String 
    func format(string: String) -> Date {
        return formatter.date(from: string)!
    }
    
    
}

