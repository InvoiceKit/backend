//
//  Invoice.swift
//  
//
//  Created by Victor Lourme on 02/09/2020.
//

import Vapor
import Fluent

final class Invoice: Model, Content {
    // MARK: - Model
    static var schema = "invoices"
    
    @ID(key: .id)
}
