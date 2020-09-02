//
//  CreateAddress.swift
//  
//
//  Created by Victor Lourme on 02/09/2020.
//

import Fluent

struct CreateAddress: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("addresses")
            .id()
            .field("customer_id", .uuid, .references("customers", "id"))
            .foreignKey("customer_id", references: "customers", "id", onDelete: .cascade)
            .field("line", .string, .required)
            .field("zip", .string, .required)
            .field("city", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("addresses").delete()
    }
}
