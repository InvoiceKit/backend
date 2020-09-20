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
    
    @Parent(key: "customer_id")
    var customer: Customer
    
    @Parent(key: "address_id")
    var address: Address
    
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
    
    init(id: UUID? = nil, teamID: Team.IDValue, customerID: Customer.IDValue, addressID: Address.IDValue, type: String, serial: String, status: ContractStatus = .ongoing, changes: [ContractChange]?, date: String?) {
        self.id = id
        self._parent.id = teamID
        self.$customer.id = customerID
        self.$address.id = addressID
        self.type = type
        self.serial = serial
        self.status = status
        self.changes = changes
        self.date = date
    }
    
    // MARK: - Relatable
    static var isChildren = true
    
    static var isAuthChildren = true
    
    var _parent: Parent<Team> = Parent(key: "team_id")
    
    // MARK: - Input
    struct Input: Content {
        var customerID: Customer.IDValue
        var addressID: Address.IDValue
        var type: String
        var serial: String
        var status: ContractStatus
        var changes: [ContractChange]?
        var date: String?
    }
    
    convenience init(_ input: Input) throws {
        self.init(
            teamID: UUID(),
            customerID: input.customerID,
            addressID: input.addressID,
            type: input.type,
            serial: input.serial,
            status: input.status,
            changes: input.changes,
            date: input.date
        )
    }
    
    // MARK: - Patchable
    struct Update: Content {
        var type: String
        var serial: String
        var status: ContractStatus
        var changes: [ContractChange]?
        var date: String?
    }
    
    func update(_ update: Update) throws {
        self.update(\.type, using: update.type)
        self.update(\.serial, using: update.serial)
        self.update(\.status, using: update.status)
        self.update(\.changes, using: update.changes)
        self.update(\.date, using: update.date)
    }
    
    // MARK: - Output
    static func eagerLoad(to builder: QueryBuilder<Contract>) -> QueryBuilder<Contract> {
        builder
            .with(\.$customer)
            .with(\.$address)
    }
}
