///
/// Token.swift
///

import Fluent
import Vapor

final class Token: Model, Content, ModelTokenAuthenticatable {
    // MARK: - Alias
    typealias User = App.Team
    
    // MARK: - Model
    static let schema = "tokens"
    static let valueKey = \Token.$value
    static let userKey = \Token.$team
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "token_value")
    var value: String
    
    @Parent(key: "team_id")
    var team: Team
    
    @Field(key: "expires_at")
    var expiresAt: Date
    
    @Field(key: "is_revoked")
    var isRevoked: Bool

    // MARK: - Initializers
    init() { }

    init(id: UUID? = nil, value: String, teamID: Team.IDValue) {
        self.id = id
        self.value = value
        self.$team.id = teamID
        self.expiresAt = Date().advanced(by: 60 * 60 * 24 * 30)
        self.isRevoked = false
    }
    
    // MARK: - Computed
    var isValid: Bool {
        return self.expiresAt > Date() && !self.isRevoked
    }
    
    // MARK: - Userdata
    struct Response: Content {
        var team: Team
        var token: Token
    }
}
