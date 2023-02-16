//
//  Extensions.swift
//  ios-client
//
//  Created by Praanto on 2023-02-16.
//

import Foundation

extension Double {
    func signOf() -> Int {
        return self > 0 ? 1 : -1
    }
    
    func signOf() -> Double {
        return self > 0 ? 1.0 : -1.0
    }
}
