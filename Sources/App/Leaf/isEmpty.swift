//
//  isEmpty.swift
//  
//
//  Created by Victor Lourme on 19/09/2020.
//

import Leaf

struct IsEmptyTag: LeafTag {
    static let name = "isEmpty"
    
    func render(_ ctx: LeafContext) throws -> LeafData {
        guard let str = ctx.parameters.first?.string else {
            throw "unable to get parameter key"
        }
        
        return .bool(str.isEmpty)
    }
}
