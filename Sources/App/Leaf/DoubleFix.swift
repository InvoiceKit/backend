//
//  File.swift
//  
//
//  Created by Victor Lourme on 04/09/2020.
//

import Leaf

struct DoubleFix: LeafTag {
    static let name = "getFixed"
    
    func render(_ ctx: LeafContext) throws -> LeafData {
        guard let number = ctx.parameters.first?.double else {
            throw "the given parameter is not a double"
        }
        
        return .string(String(format: "%.2f", number))
    }
}
