//
//  Contract.swift
//  
//
//  Created by Victor Lourme on 19/09/2020.
//

import Vapor
import Fluent

final class Contract: Content, APIModel, Relatable, Patchable {
    // MARK: - Model
    static var schema = "contracts"
    
    @ID(key: .id)
    var id: UUID?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Field(key: "type")
    var type: String
    
    @Field(key: "serial")
    var serial: String
    
    @Field(key: "status")
    var status: ContractStatus
    
    @Field(key: "changes")
    var changes: [ContractChange]?
    
    @Field(key: "date")
    var date: String?
    
    // MARK: - Status
    enum ContractStatus: String, Content {
        case ongoing, canceled
    }
    
    // MARK: - Fields
    struct ContractChange: Codable {
        var date: String
        var description: String
    }
    
    // MARK: - Initializers
    init() {
        
    }
    
    init(id: UUID? = nil, customerID: Customer.IDValue, type: String, serial: String, status: ContractStatus = .ongoing, changes: [ContractChange]?, date: String?) {
        self.id = id
        self._parent.id = customerID
        self.type = type
        self.serial = serial
        self.status = status
        self.changes = changes
        self.date = date
    }
    
    // MARK: - Relatable
    static var isChildren = true
    
    var _parent: Parent<Customer> = Parent(key: "customer_id")
    
    // MARK: - Input
    struct Input: Content {
        var type: String
        var serial: String
        var status: ContractStatus
        var changes: [ContractChange]?
        var date: String?
    }
    
    convenience init(_ input: Input) throws {
        self.init(
            customerID: UUID(),
            type: input.type,
            serial: input.serial,
            status: input.status,
            changes: input.changes,
            date: input.date
        )
    }
    
    // MARK: - Patchable
    typealias Update = Input
    
    func update(_ update: Input) throws {
        self.update(\.type, using: update.type)
        self.update(\.serial, using: update.serial)
        self.update(\.status, using: update.status)
        self.update(\.changes, using: update.changes)
        self.update(\.date, using: update.date)
    }
    
    // MARK: - Output
    
}
