//
//  CreateInvoice.swift
//  
//
//  Created by Victor Lourme on 03/09/2020.
//

import Fluent

struct CreateInvoice: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("invoices")
            .id()
            .field("team_id", .uuid, .required, .references("teams", "id"))
            .foreignKey("team_id", references: "teams", "id", onDelete: .cascade)
            .field("customer_id", .uuid, .required, .references("customers", "id"))
            .foreignKey("customer_id", references: "customers", "id", onDelete: .cascade)
            .field("address_id", .uuid, .required, .references("addresses", "id"))
            .foreignKey("address_id", references: "addresses", "id", onDelete: .restrict)
            .field("created_at", .date)
            .field("updated_at", .date)
            .field("due_date", .date)
            .field("type", .string, .required)
            .field("status", .string, .required)
            .field("fields", .array)
            .field("number", .string)
            .field("deposit", .double)
            .field("promotion", .int)
            .field("additional_text", .string)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("teams").delete()
    }
}
