//
//  InvoiceField.swift
//  
//
//  Created by Victor Lourme on 03/09/2020.
//

import Vapor
import Fluent

final class InvoiceField: Model, Content {
    // MARK: - Model
    static var schema = "invoice_fields"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "invoice_id")
    var invoice: Invoice
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "vat")
    var vat: Int
    
    @Field(key: "price")
    var price: Double
    
    // MARK: - Initializers
    init() {
        
    }
    
    init(id: UUID? = nil, invoiceID: Invoice.IDValue, name: String, vat: Int, price: Double) {
        self.id = id
        self.$invoice.id = invoiceID
        self.name = name
        self.vat = vat
        self.price = price
    }
    
    // MARK: - Validations
    struct Create: Content, Validatable {
        var name: String
        var vat: Int
        var price: Double
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self, is: !.empty, required: true)
            validations.add("vat", as: Int.self, required: true)
            validations.add("price", as: Double.self, required: true)
        }
    }
}
