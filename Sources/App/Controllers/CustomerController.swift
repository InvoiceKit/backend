//
//  CustomerController.swift
//  
//
//  Created by Victor Lourme on 02/09/2020.
//

import Fluent
import Vapor

struct CustomerController: RouteCollection {
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
    
    // MARK: - Fetch every customers
    func fetch(_ req: Request) throws -> EventLoopFuture<Page<Customer>> {
        // Get team
        let team = try req.auth.require(Team.self)
        
        // Get every customers
        return Customer.query(on: req.db)
            .join(Team.self, on: \Customer.$team.$id == \Team.$id)
            .filter(Team.self, try \.$id == team.requireID())
            .paginate(for: req)
    }
    
    // MARK: - Get a customer
    func get(_ req: Request) throws -> EventLoopFuture<Customer> {
        // Get team
        let team = try req.auth.require(Team.self)
        
        // Get ID
        guard let id = req.parameters.get("id", as: Customer.IDValue.self) else {
            throw Abort(.notFound)
        }
        
        // Get customer
        return Customer.query(on: req.db)
            .filter(\.$id == id)
            .join(Team.self, on: \Customer.$team.$id == \Team.$id)
            .filter(Team.self, try \.$id == team.requireID())
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
                customer.firstName = content.firstName ?? customer.firstName
                customer.lastName = content.lastName ?? customer.lastName
                customer.company = content.company ?? customer.company
                customer.phone = content.phone ?? customer.phone
                customer.email = content.email ?? customer.email
                
                // Update
                return customer.update(on: req.db)
            }
            .transform(to: .ok)
    }
    
    // MARK: - Delete
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        // Get team
        let team = try req.auth.require(Team.self)
        
        // Get customer
        return Customer
            .find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { customer -> EventLoopFuture<Void> in
                // Check ownership
                if try customer.$team.id != team.requireID() {
                    throw Abort(.forbidden)
                }
                
                // Update
                return customer.delete(on: req.db)
            }
            .transform(to: .ok)
    }
}
