//
//  CreateCustomer.swift
//  
//
//  Created by Victor Lourme on 02/09/2020.
//

import Fluent

struct CreateCustomer: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("customers")
            .id()
            .field("team_id", .uuid, .required, .references("teams", "id"))
            .foreignKey("team_id", references: "teams", "id", onDelete: .cascade)
            .field("first_name", .string)
            .field("last_name", .string)
            .field("company", .string)
            .field("phone", .string)
            .field("email", .string)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("teams").delete()
    }
}
