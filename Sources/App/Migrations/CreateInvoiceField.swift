//
//  CreateInvoiceField.swift
//  
//
//  Created by Victor Lourme on 03/09/2020.
//

import Fluent

struct CreateInvoiceField: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("fields")
            .id()
            .field("invoice_id", .uuid, .references("invoices", "id"))
            .foreignKey("invoice_id", references: "invoices", "id", onDelete: .cascade)
            .field("created_at", .date)
            .field("name", .string, .required)
            .field("vat", .int, .required)
            .field("price", .double, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("teams").delete()
    }
}
