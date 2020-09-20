//
//  CreateContract.swift
//
//
//  Created by Victor Lourme on 02/09/2020.
//

import Fluent

struct CreateContract: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("contracts")
            .id()
            .field("team_id", .uuid, .required, .references("teams", "id"))
            .foreignKey("team_id", references: "teams", "id", onDelete: .cascade)
            .field("customer_id", .uuid, .required, .references("customers", "id"))
            .foreignKey("customer_id", references: "customers", "id", onDelete: .cascade)
            .field("address_id", .uuid, .required, .references("addresses", "id"))
            .foreignKey("address_id", references: "addresses", "id", onDelete: .restrict)
            .field("created_at", .date)
            .field("updated_at", .date)
            .field("type", .string, .required)
            .field("serial", .string, .required)
            .field("status", .string, .required)
            .field("changes", .array)
            .field("date", .string)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("contracts").delete()
    }
}


