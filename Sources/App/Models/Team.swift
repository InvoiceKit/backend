///
/// Team.swift
///

import Fluent
import Vapor

final class Team: Model, Content, ModelAuthenticatable {
    // MARK: - Model
    static let schema = "teams"
    static let usernameKey = \Team.$username
    static let passwordHashKey = \Team.$passwordHash
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password_hash")
    var passwordHash: String

    @Field(key: "company_name")
    var company: String?
    
    @Field(key: "address_hq")
    var address: String?
    
    @Field(key: "address_hq_city")
    var city: String?
    
    @Field(key: "website")
    var website: String?
    
    @Field(key: "fields")
    var fields: [String]?
    
    @Field(key: "image_url")
    var image: String?
    
    // MARK: - Initializers
    init() { }

    init(id: UUID? = nil, name: String, username: String, passwordHash: String, company: String? = nil, address: String? = nil, city: String? = nil, website: String? = nil, fields: [String]? = nil, image: String? = nil) {
        self.id = id
        self.name = name
        self.username = username
        self.passwordHash = passwordHash
        self.company = company
        self.address = address
        self.city = city
        self.website = website
        self.fields = fields
        self.image = image
    }
    
    // MARK: - Authentication
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
    
    func generateToken() throws -> Token {
        try .init(
            value: [UInt8].random(count: 32).base64,
            teamID: self.requireID()
        )
    }
    
    // MARK: - Validation
    struct Create: Content, Validatable {
        var name: String
        var username: String
        var password: String
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self, is: !.empty && .ascii)
            validations.add("username", as: String.self, is: .count(6...) && .alphanumeric)
            validations.add("password", as: String.self, is: .count(8...), required: true)
        }
    }
    
    // MARK: - Patchable
    struct Update: Content, Validatable {
        var name: String?
        var company: String?
        var address: String?
        var city: String?
        var website: String?
        var fields: [String]?
        var image: String?
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self, is: !.empty && .ascii, required: false)
            validations.add("company", as: String.self, is: .ascii, required: false)
            validations.add("address", as: String.self, is: .ascii, required: false)
            validations.add("city", as: String.self, is: .ascii, required: false)
            validations.add("website", as: String.self, is: .url, required: false)
            validations.add("fields", as: [String?].self, required: false)
            validations.add("image", as: String.self, is: .url, required: false)
        }
    }
}
