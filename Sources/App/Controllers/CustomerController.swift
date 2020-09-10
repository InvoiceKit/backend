//
//  CustomerController.swift
//  
//
//  Created by Victor Lourme on 02/09/2020.
//

import Fluent
import Vapor

struct CustomerController: RouteCollection, CRUD {
    // MARK: - Type
    typealias APIModel = Customer
    
    // MARK: - Team
    var parent: KeyPath<Customer, ParentProperty<Customer, Team>> = \.$team
    
    // MARK: - Constructor
    func boot(routes: RoutesBuilder) throws {
        // Authentication
        let root = routes.grouped("customers").grouped(Token.authenticator(), Team.guardMiddleware())
        
        // Route: GET /customers
        root.get(use: fetch)
        
        // Route: PUT /customers
        root.put(use: create)
        
        // Route: /customers/:id
        try root.group(":id") { sub in
            // Route: GET /customers/:id
            sub.get(use: get)
            
            // Route: PATCH /customers/:id
            sub.patch(use: patch)
            
            // Route: DELETE /customers/:id
            sub.delete(use: delete)
            
            // Register addresses
            try sub.register(collection: AddressController())
        }
    }
    
    func get(_ req: Request) throws -> EventLoopFuture<Customer> {
        // Get filtered entry
        return Customer.query(on: req.db)
            .filter(try \.$id == getId(req))
            .with(\.$addresses)
            .first()
            .unwrap(or: Abort(.notFound))
    }
    
    // MARK: - Create
    func create(_ req: Request) throws -> EventLoopFuture<Customer> {
        // Get team
        let team = try req.auth.require(Team.self)
        
        // Get content
        let content = try req.content.decode(Customer.Create.self)
        
        // Check content
        if (content.firstName?.isEmpty ?? true || content.lastName?.isEmpty ?? true)
            && content.company?.isEmpty ?? true {
            throw Abort(.badRequest)
        }
        
        // Create customer
        let customer = Customer(
            teamID: try team.requireID(),
            firstName: content.firstName,
            lastName: content.lastName,
            company: content.company,
            phone: content.phone,
            email: content.email
        )
        
        // Save
        return customer.save(on: req.db)
            .map {
                customer
            }
    }
    
    // MARK: - Patch
    func patch(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        // Get team
        let team = try req.auth.require(Team.self)
        
        // Get content
        let content = try req.content.decode(Customer.Create.self)
        
        // Check content
        if (content.firstName?.isEmpty ?? true || content.lastName?.isEmpty ?? true)
            && content.company?.isEmpty ?? true {
            throw Abort(.badRequest)
        }
        
        // Get from database
        return Customer
            .find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { customer -> EventLoopFuture<Void> in
                // Check ownership
                if try customer.$team.id != team.requireID() {
                    throw Abort(.forbidden)
                }
                
                // Replace values
                customer.firstName = content.firstName
                customer.lastName = content.lastName
                customer.company = content.company
                customer.phone = content.phone
                customer.email = content.email
                
                // Update
                return customer.update(on: req.db)
            }
            .transform(to: .ok)
    }
}
