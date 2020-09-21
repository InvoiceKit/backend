//
//  CreateMessage.swift
//
//
//  Created by Victor Lourme on 21/09/2020.
//

import Fluent

struct CreateMessage: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("messages")
            .id()
            .field("team_id", .uuid, .required, .references("teams", "id"))
            .foreignKey("team_id", references: "teams", "id", onDelete: .cascade)
            .field("created_at", .date)
            .field("first_name", .string)
            .field("last_name", .string)
            .field("email", .string)
            .field("phone", .string)
            .field("address", .string)
            .field("text", .string)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("messages").delete()
    }
}


