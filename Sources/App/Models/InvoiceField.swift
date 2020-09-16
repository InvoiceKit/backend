//
//  InvoiceField.swift
//  
//
//  Created by Victor Lourme on 03/09/2020.
//

import Vapor
import Fluent

final class InvoiceField: Content, APIModel, Patchable, Relatable {
    // MARK: - Model
    static var schema = "fields"
    
    @ID(key: .id)
    var id: UUID?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "vat")
    var vat: Int
    
    @Field(key: "price")
    var price: Double
    
    // MARK: - Children
    static var isChildren = true
    
    // MARK: - Parent
    typealias ParentType = Invoice
    
    var _parent: Parent<Invoice> = Parent(key: "invoice_id")
    
    // MARK: - Initializers
    init() {
        
    }
    
    init(id: UUID? = nil, invoiceID: Invoice.IDValue, name: String, vat: Int, price: Double) {
        self.id = id
        self._parent.id = invoiceID
        self.name = name
        self.vat = vat
        self.price = price
    }
    
    // MARK: - Validations
    struct Input: Content, Validatable {
        var name: String
        var vat: Int
        var price: Double
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self, is: !.empty, required: true)
            validations.add("vat", as: Int.self, required: true)
            validations.add("price", as: Double.self, required: true)
        }
    }
    
    convenience init(_ input: Input) throws {
        self.init(
            id: UUID(),
            invoiceID: UUID(),
            name: input.name,
            vat: input.vat,
            price: input.price
        )
    }
    
    // MARK: - Relatable
    typealias Update = Input
    
    func update(_ update: Input) throws {
        self.update(\.name, using: update.name)
        self.update(\.vat, using: update.vat)
        self.update(\.price, using: update.price)
    }
}
