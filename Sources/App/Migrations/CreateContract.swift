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
            .field("customer_id", .uuid, .references("customers", "id"), .required)
            .foreignKey("customer_id", references: "customers", "id", onDelete: .cascade)
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


