//
//  Address.swift
//  
//
//  Created by Victor Lourme on 02/09/2020.
//

import Vapor
import Fluent

final class Address: Model, Content {
    // MARK: - Model
    static var schema = "addresses"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "customer_id")
    var customer: Customer
    
    @Field(key: "line")
    var line: String
    
    @Field(key: "zip")
    var zip: String
    
    @Field(key: "city")
    var city: String
    
    // MARK: - Initializers
    init() {
        
    }
    
    init(id: UUID? = nil, customerID: Customer.IDValue, line: String, zip: String, city: String) {
        self.$customer.id = customerID
        self.line = line
        self.zip = zip
        self.city = city
    }
    
    // MARK: - Create
    struct Create: Content, Validatable {
        var line: String
        var zip: String
        var city: String
        
        static func validations(_ validations: inout Validations) {
            validations.add("line", as: String.self, is: !.empty)
            validations.add("zip", as: String.self, is: !.empty)
            validations.add("city", as: String.self, is: !.empty)
        }
    }
}
