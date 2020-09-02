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

    // MARK: - Initializers
    init() { }

    init(id: UUID? = nil, name: String, username: String, passwordHash: String) {
        self.id = id
        self.name = name
        self.username = username
        self.passwordHash = passwordHash
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
            validations.add("username", as: String.self, is: !.empty && .alphanumeric)
            validations.add("password", as: String.self, is: .count(8...), required: true)
        }
    }
}
