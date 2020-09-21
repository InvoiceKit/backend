//
//  Message.swift
//  
//
//  Created by Victor Lourme on 21/09/2020.
//

import Vapor
import Fluent

final class Message: APIModel, Content {
    // MARK: - Model
    static var schema = "messages"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "team_id")
    var team: Team
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Field(key: "first_name")
    var firstName: String?
    
    @Field(key: "last_name")
    var lastName: String?
    
    @Field(key: "email")
    var email: String?
    
    @Field(key: "phone")
    var phone: String?
    
    @Field(key: "address")
    var address: String?
    
    @Field(key: "text")
    var text: String?
    
    // MARK: - Initializers
    init() {
        
    }
    
    init(id: UUID? = nil, teamID: UUID, firstName: String?, lastName: String?, email: String?, phone: String?, address: String?, text: String?) {
        self.id = id
        self.$team.id = teamID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.address = address
        self.text = text
    }
    
    // MARK: - Input
    struct Input: Content {
        var teamID: UUID
        var firstName: String?
        var lastName: String?
        var email: String?
        var phone: String?
        var address: String?
        var text: String?
    }
    
    convenience init(_ input: Input) throws {
        self.init(
            teamID: input.teamID,
            firstName: input.firstName,
            lastName: input.lastName,
            email: input.email,
            phone: input.phone,
            address: input.address,
            text: input.text
        )
    }
}
