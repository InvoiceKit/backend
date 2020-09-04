//
//  AddressController.swift
//
//
//  Created by Victor Lourme on 02/09/2020.
//

import Fluent
import Vapor

struct AddressController: RouteCollection {
    // MARK: - Constructor
    func boot(routes: RoutesBuilder) throws {
        // Route: /customers/:id/addresses
        let root = routes.grouped("addresses")
        
        // Route: PUT /customers/:id/addresses
        root.put(use: create)
        
        // Route: DELETE /customers/:id/addresses/:address
        root.delete(":address", use: delete)
    }
    
    // MARK: - Create
    func create(_ req: Request) throws -> EventLoopFuture<Address> {
        // Verify
        try Address.Create.validate(req)
        
        // Get content
        let content = try req.content.decode(Address.Create.self)
        
        // Get ID
        guard let id = req.parameters.get("id", as: Customer.IDValue.self) else {
            throw Abort(.notFound)
        }
        
        // Create address
        let address = Address(
            customerID: id,
            line: content.line,
            zip: content.zip,
            city: content.city
        )
        
        // Save
        return address.save(on: req.db)
            .map {
                address
            }
    }
    
    // MARK: - Delete
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Address
            .find(req.parameters.get("address"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .map { address in
                address.delete(on: req.db)
            }
            .transform(to: .ok)
    }
}
