//
//  Invoice.swift
//  
//
//  Created by Victor Lourme on 02/09/2020.
//

import Vapor
import Fluent

final class Invoice: APIModel, Relatable, Patchable, CustomOutput {
    // MARK: - Model
    static var schema = "invoices"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "customer_id")
    var customer: Customer
    
    @Parent(key: "address_id")
    var address: Address
    
    @Children(for: \._parent)
    var fields: [InvoiceField]
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Field(key: "due_date")
    var dueDate: String?
    
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
    
    @Field(key: "additional_text")
    var additional_text: String?
    
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
    
    init(id: UUID? = nil, teamID: Team.IDValue, customerID: Customer.IDValue, addressID: Address.IDValue, dueDate: String?, type: InvoiceType, status: InvoiceStatus, number: String?, deposit: Double? = 0, promotion: Int? = 0, additional_text: String? = "") {
        self.id = id
        self._parent.id = teamID
        self.$customer.id = customerID
        self.$address.id = addressID
        self.dueDate = dueDate
        self.type = type
        self.status = status
        self.number = number
        self.deposit = deposit
        self.promotion = promotion
        self.additional_text = additional_text
    }
    
    // MARK: - Relatable    
    static var isAuthChildren = true
    
    var _parent: Parent<Team> = Parent(key: "team_id")
    
    // MARK: - Input
    struct Input: Content {
        var customerID: Customer.IDValue
        var addressID: Address.IDValue
        var dueDate: String?
        var type: InvoiceType
        var status: InvoiceStatus
        var number: String?
        var deposit: Double?
        var promotion: Int?
        var additional_text: String?
    }
    
    convenience init(_ input: Input) throws {
        self.init(
            id: UUID(),
            teamID: UUID(),
            customerID: input.customerID,
            addressID: input.addressID,
            dueDate: input.dueDate,
            type: input.type,
            status: input.status,
            number: input.number,
            deposit: input.deposit,
            promotion: input.promotion,
            additional_text: input.additional_text
        )
    }
    
    // MARK: - Patchable
    struct Update: Content {
        var dueDate: String?
        var type: InvoiceType
        var status: InvoiceStatus
        var number: String?
        var deposit: Double?
        var promotion: Int?
        var additional_text: String?
    }
    
    func update(_ update: Update) throws {
        self.update(\.dueDate, using: update.dueDate)
        self.update(\.type, using: update.type)
        self.update(\.status, using: update.status)
        self.update(\.number, using: update.number)
        self.update(\.deposit, using: update.deposit)
        self.update(\.promotion, using: update.promotion)
        self.update(\.additional_text, using: update.additional_text)
    }
    
    // MARK: - Output
    static func eagerLoad(to builder: QueryBuilder<Invoice>) -> QueryBuilder<Invoice> {
        builder
            .with(\.$fields)
            .with(\._parent)
            .with(\.$customer)
            .with(\.$address)
    }
    
    struct Output: Content {
        var id: Invoice.IDValue?
        var team: Team?
        var customer: Customer
        var address: Address
        var createdAt: Date?
        var updatedAt: Date?
        var dueDate: String?
        var type: InvoiceType
        var status: InvoiceStatus
        var fields: [InvoiceField]
        var number: String?
        var deposit: Double?
        var promotion: Int?
        var additional_text: String?
        var no_vat: Double
        var vat: Double
        var total: Double
        var _promotion: Double
        var final: Double
    }
    
    var output: Output {
        // Prepare return
        var ret = Output.init(
            id: id,
            customer: customer,
            address: address,
            createdAt: createdAt,
            updatedAt: updatedAt,
            dueDate: dueDate,
            type: type,
            status: status,
            fields: fields,
            number: number,
            deposit: deposit,
            promotion: promotion,
            additional_text: additional_text,
            no_vat: 0,
            vat: 0,
            total: 0,
            _promotion: 0,
            final: 0
        )
        
        // Get every fields
        for field in fields {
            // Add no_vat
            ret.no_vat += field.price
            
            // Get vat
            let vat = (field.price * Double(field.vat)) / 100
            ret.vat += vat
            
            // Set total
            ret.total += vat + field.price
        }
        
        // Calculate promotion
        if let promo = promotion {
            ret._promotion = (Double(promo) * ret.total) / 100
        }
        
        // Set final price
        ret.final = ret.total - ret._promotion - Double(deposit ?? 0)
        
        return ret
    }
    
    var outputPrint: Output {
        var ret = output
        ret.team = _parent.wrappedValue
        
        return ret
    }
}
