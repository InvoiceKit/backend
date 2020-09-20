//
//  Customer.swift
//  
//
//  Created by Victor Lourme on 02/09/2020.
//

import Vapor
import Fluent

final class Customer: Content, APIModel, Relatable, Patchable {
    // MARK: - Model
    static var schema = "customers"
    
    @ID(key: .id)
    var id: UUID?
    
    @Children(for: \._parent)
    var addresses: [Address]
    
    @Children(for: \.$customer)
    var invoices: [Invoice]
    
    @Children(for: \.$customer)
    var contracts: [Contract]
    
    @Field(key: "first_name")
    var firstName: String?
    
    @Field(key: "last_name")
    var lastName: String?
    
    @Field(key: "company")
    var company: String?
    
    @Field(key: "phone")
    var phone: String?
    
    @Field(key: "email")
    var email: String?
    
    // MARK: - Parent    
    static var isAuthChildren = true
    
    var _parent: Parent<Team> = Parent(key: "team_id")
    
    // MARK: - Initializers
    init() {
        
    }
    
    init(id: UUID? = nil, teamID: Team.IDValue, firstName: String?, lastName: String?, company: String?, phone: String?, email: String?) {
        self.id = id
        self._parent.id = teamID
        self.firstName = firstName
        self.lastName = lastName
        self.company = company
        self.phone = phone
        self.email = email
    }
    
    // MARK: - Input
    struct Input: Content {
        var firstName: String?
        var lastName: String?
        var company: String?
        var phone: String?
        var email: String?
    }
    
    convenience init(_ input: Input) throws {
        // Check company or names
        if input.lastName == nil && input.company == nil {
            throw Abort(.badRequest, reason: "lastName or company must be filled")
        }
        
        self.init(
            id: UUID(),
            teamID: UUID(), // Controller will replace this field
            firstName: input.firstName,
            lastName: input.lastName,
            company: input.company,
            phone: input.phone,
            email: input.email
        )
    }
    
    // MARK: - Update
    typealias Update = Input
    
    func update(_ update: Update) throws {
        // Check company or names
        if update.lastName == nil && update.company == nil {
            throw Abort(.badRequest, reason: "lastName or company must be filled")
        }
        
        self.update(\.firstName, using: update.firstName)
        self.update(\.lastName, using: update.lastName)
        self.update(\.company, using: update.company)
        self.update(\.phone, using: update.phone)
        self.update(\.email, using: update.email)
    }
    
    // MARK: - Output
    static func eagerLoad(to builder: QueryBuilder<Customer>) -> QueryBuilder<Customer> {
        builder
            .with(\.$addresses)
            .with(\.$invoices)
            .with(\.$contracts)
    }
}
