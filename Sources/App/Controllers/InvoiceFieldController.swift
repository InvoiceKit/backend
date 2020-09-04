//
//  InvoiceFieldController.swift
//
//
//  Created by Victor Lourme on 02/09/2020.
//

import Fluent
import Vapor

struct InvoiceFieldController: RouteCollection {
    // MARK: - Constructor
    func boot(routes: RoutesBuilder) throws {
        // Route: /invoices/:id/fields
        let root = routes.grouped("fields")
        
        // Route: PUT /invoices/:id/fields
        root.put(use: create)
        
        // Sub: /invoices/:id/fields
        root.group(":field") { sub in
            // Route: PATCH /invoices/:id/fields/:field
            sub.patch(use: update)
            
            // Route: DELETE /invoices/:id/fields/:field
            sub.delete(use: delete)
        }
    }
    
    // MARK: - Create
    func create(_ req: Request) throws -> EventLoopFuture<InvoiceField> {
        // Verify
        try InvoiceField.Create.validate(req)
        
        // Get content
        let content = try req.content.decode(InvoiceField.Create.self)
        
        // Get ID
        guard let id = req.parameters.get("id", as: Invoice.IDValue.self) else {
            throw Abort(.notFound)
        }
        
        // Create field
        let field = InvoiceField(
            invoiceID: id,
            name: content.name,
            vat: content.vat,
            price: content.price
        )
        
        // Save
        return field.save(on: req.db)
            .map {
                field
            }
    }
    
    // MARK: - Update
    func update(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        // Verify
        try InvoiceField.Create.validate(req)
        
        // Get content
        let content = try req.content.decode(InvoiceField.Create.self)
        
        // Save
        return InvoiceField.find(req.parameters.get("field"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { field -> EventLoopFuture<Void> in
                // Replace model
                field.name = content.name
                field.price = content.price
                field.vat = content.vat
                
                // Update
                return field.update(on: req.db)
            }
            .transform(to: .ok)
    }

    
    // MARK: - Delete
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return InvoiceField
            .find(req.parameters.get("field"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .map { field in
                field.delete(on: req.db)
            }
            .transform(to: .ok)
    }
}
