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
    var id: UUID?
    
    @Parent(key: "team_id")
    var team: Team
    
    @Parent(key: "customer_id")
    var customer: Customer
    
    @Parent(key: "address_id")
    var address: Address
    
    @Children(for: \.$invoice)
    var fields: [InvoiceField]
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Field(key: "type")
    var type: InvoiceType
    
    @Field(key: "status")
    var status: InvoiceStatus
    
    @Field(key: "number")
    var number: String?

    @Field(key: "deposit")
    var deposit: Double?
    
    @Field(key: "promotion")
    var promotion: Int?
    
    // MARK: - Enums
    enum InvoiceType: String, Content {
        case invoice, quote
    }
    
    enum InvoiceStatus: String, Content {
        case paid, waiting, canceled
    }
    
    // MARK: - Initializers
    init() {
        
    }
    
    init(id: UUID? = nil, teamID: Team.IDValue, customerID: Customer.IDValue, addressID: Address.IDValue, type: InvoiceType, status: InvoiceStatus, number: String?, deposit: Double? = 0, promotion: Int? = 0) {
        self.id = id
        self.$team.id = teamID
        self.$customer.id = customerID
        self.$address.id = addressID
        self.type = type
        self.status = status
        self.number = number
        self.deposit = deposit
        self.promotion = promotion
    }
    
    // MARK: - Validations
    struct Create: Content, Validatable {
        var customerID: Customer.IDValue
        var addressID: Address.IDValue
        var type: InvoiceType
        var status: InvoiceStatus
        var number: String?
        var deposit: Double?
        var promotion: Int?
        
        static func validations(_ validations: inout Validations) {
            validations.add("customerID", as: Customer.IDValue.self, required: true)
            validations.add("addressID", as: Address.IDValue.self, required: true)
            validations.add("type", as: InvoiceType.self, required: true)
            validations.add("status", as: InvoiceStatus.self, required: true)
            validations.add("number", as: String.self, required: false)
            validations.add("deposit", as: Double.self, required: false)
            validations.add("promotion", as: Int.self, required: false)
        }
    }
    
    // MARK: - Update
    struct Update: Content, Validatable {
        var type: InvoiceType
        var status: InvoiceStatus
        var number: String
        var deposit: Double
        var promotion: Int
        
        static func validations(_ validations: inout Validations) {
            validations.add("type", as: InvoiceType.self)
            validations.add("status", as: InvoiceStatus.self)
            validations.add("number", as: String.self)
            validations.add("deposit", as: Double.self)
            validations.add("promotion", as: Int.self)
        }
    }
    
    // MARK: - Output
    struct Output: Content {
        var invoice: Invoice
        var prices: Prices
    }
    
    // MARK: - Price Output
    struct Prices: Content {
        ///
        /// VAT total
        ///
        var VAT: Double
        
        ///
        /// Total without VAT
        ///
        var totalWV: Double
        
        ///
        /// Total with VAT
        ///
        var total: Double
        
        ///
        /// Promotion
        ///
        var promotion: Double
        
        ///
        /// Final price with deposits and promotion
        ///
        var final: Double
    }
}
