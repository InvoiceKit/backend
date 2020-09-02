//
//  Customer.swift
//  
//
//  Created by Victor Lourme on 02/09/2020.
//

import Vapor
import Fluent

final class Customer: Model, Content {
    // MARK: - Model
    static var schema = "customers"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "team_id")
    var team: Team
    
    @Children(for: \.$customer)
    var addresses: [Address]
    
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
    
    // MARK: - Initializers
    init() {
        
    }
    
    init(id: UUID? = nil, teamID: Team.IDValue, firstName: String?, lastName: String?, company: String?, phone: String?, email: String?) {
        self.id = id
        self.$team.id = teamID
        self.firstName = firstName
        self.lastName = lastName
        self.company = company
        self.phone = phone
        self.email = email
    }
    
    // MARK: - Validation
    struct Create: Content {
        var firstName: String?
        var lastName: String?
        var company: String?
        var phone: String?
        var email: String?
    }
}
