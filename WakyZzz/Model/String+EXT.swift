//
//  String+EXT.swift
//  WakyZzz
//
//  Created by Matthew Sousa on 5/21/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

import Foundation

extension String {
    
    func convertToPhoneNumber() -> Int? {
        
        let one = self.replacingOccurrences(of: "(", with: "", options: NSString.CompareOptions.literal, range: nil)
        let two = one.replacingOccurrences(of: ")", with: "", options: NSString.CompareOptions.literal, range: nil)
        let three = two.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
        let four = three.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range: nil)
        
        return Int(four)
    }
    
    
    
}
