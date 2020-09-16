//
//  String+Extension.swift
//  
//
//  Created by Victor Lourme on 14/09/2020.
//

import Foundation

extension String {
    static func random(length: Int) -> String {
        enum s {
            static let c = Array("abcdefghjklmnpqrstuvwxyz12345789")
            static let k = UInt32(c.count)
        }
        
        var result = [Character](repeating: "-", count: length)
        
        for i in 0..<length {
            let r = Int(arc4random_uniform(s.k))
            result[i] = s.c[r]
        }
        
        return String(result)
    }
}
