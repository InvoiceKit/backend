//
//  Address.swift
//  
//
//  Created by Victor Lourme on 02/09/2020.
//

import Vapor
import Fluent

final class Address: Content, APIModel, Relatable {
    // MARK: - Model
    static var schema = "addresses"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "line")
    var line: String
    
    @Field(key: "zip")
    var zip: String
    
    @Field(key: "city")
    var city: String
    
    // MARK: - Children
    static var isChildren = true
    
    // MARK: - Parent
    typealias ParentType = Customer
    
    var _parent: Parent<Customer> = Parent(key: "customer_id")
    
    // MARK: - Initializers
    init() {
        
    }
    
    init(id: UUID? = nil, customerID: Customer.IDValue, line: String, zip: String, city: String) {
        self._parent.id = customerID
        self.line = line
        self.zip = zip
        self.city = city
    }
    
    // MARK: - Create
    struct Input: Content, Validatable {
        var line: String
        var zip: String
        var city: String
        
        static func validations(_ validations: inout Validations) {
            validations.add("line", as: String.self, is: !.empty)
            validations.add("zip", as: String.self, is: !.empty)
            validations.add("city", as: String.self, is: !.empty)
        }
    }
    
    convenience init(_ input: Input) throws {
        self.init(
            customerID: UUID(),
            line: input.line,
            zip: input.zip,
            city: input.city
        )
    }
}
