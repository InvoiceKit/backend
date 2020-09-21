//
//  String+Extension.swift
//  
//
//  Created by Victor Lourme on 14/09/2020.
//

import Foundation

extension String {
    static func random(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length)
                        .map { _ in
                            letters.randomElement()!
                        }
        )
    }
}
