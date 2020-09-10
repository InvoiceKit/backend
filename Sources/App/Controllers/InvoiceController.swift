//
//  InvoiceController.swift
//  
//
//  Created by Victor Lourme on 03/09/2020.
//

import Fluent
import Vapor

final class InvoiceController: RouteCollection, CRUD {
    // MARK: - Model
    typealias APIModel = Invoice
    
    // MARK: - Parent
    var parent: KeyPath<Invoice, ParentProperty<Invoice, Team>> = \.$team
    
    // MARK: - Root
    func boot(routes: RoutesBuilder) throws {
        // Root protected by token
        let root = routes.grouped("invoices")
        
        // GET /invoices/:id/render
        // TODO: Security issue
        root.grouped(":id").get("render", use: render)
        
        // Protected routes
        let protected = root.grouped(Token.authenticator(), Team.guardMiddleware())
        
        // GET /invoices
        protected.get(use: fetch)
        
        // PUT /invoice
        protected.put(use: create)
        
        // Route: /invoices/:id
        try protected.group(":id") { sub in
            // GET /invoices/:id
            sub.get(use: get)
            
            // PATCH /invoices/:id
            sub.patch(use: update)
            
            // DELETE /invoices/:id
            sub.delete(use: delete)
            
            // Register collection
            try sub.register(collection: InvoiceFieldController())
        }
    }

    // MARK: - PDF Rendering
    func render(_ req: Request) throws -> EventLoopFuture<View> {
        // Get invoice
        return Invoice.query(on: req.db)
            .filter(try \.$id == getId(req))
            .with(\.$fields)
            .with(\.$address)
            .with(\.$customer)
            .with(\.$team)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMap { invoice in
                // Get prices
                let inv = self.getPrices(invoice)
                
                struct Context: Codable {
                    var invoice: Invoice
                    var prices: Invoice.Prices
                }
                
                return req.view.render("invoice", Context(invoice: invoice, prices: inv.prices))
            }
    }
    
    // MARK: - Fetch override
    func fetch(_ req: Request) throws -> EventLoopFuture<Page<Invoice>> {
        // Get team
        let team = try req.auth.require(Team.self)
        
        // Get every entries
        return Invoice.query(on: req.db)
            .join(parent: parent)
            .filter(Team.self, try \.$id == team.requireID())
            .with(\.$customer)
            .paginate(for: req)
    }
    
    // MARK: - Price calculation
    func getPrices(_ invoice: Invoice) -> Invoice.Output {
        // Create instance of prices
        var prices = Invoice.Prices(
            VAT: 0,
            totalWV: 0,
            total: 0,
            promotion: 0,
            final: 0
        )
        
        // Get every prices
        for field in invoice.fields {
            // Add to total non vat
            prices.totalWV += field.price
            
            // Get vat
            let vat = (field.price * Double(field.vat)) / 100
            
            // Add to vat
            prices.VAT += vat
            
            // Add to total
            prices.total += field.price + vat
        }
        
        // Get promotion amount
        if let promotion = invoice.promotion {
            prices.promotion = (prices.total * Double(promotion)) / 100
        }
        
        // Set final price
        prices.final = prices.total - prices.promotion
        
        // Remove deposit
        if let deposit = invoice.deposit {
            prices.final -= deposit
        }
        
        return Invoice.Output(invoice: invoice, prices: prices)
    }
    
    // MARK: - Get override
    func get(_ req: Request) throws -> EventLoopFuture<Invoice.Output> {
        // Get filtered entry
        return Invoice.query(on: req.db)
            .filter(try \.$id == getId(req))
            .with(\.$fields)
            .with(\.$address)
            .with(\.$customer)
            .first()
            .unwrap(or: Abort(.notFound))
            .map { invoice in
                return self.getPrices(invoice)
            }
    }
    
    // MARK: - Create
    func create(_ req: Request) throws -> EventLoopFuture<Invoice> {
        // Get team
        let team = try req.auth.require(Team.self)
        
        // Validate
        try Invoice.Create.validate(req)
        
        // Decode
        let content = try req.content.decode(Invoice.Create.self)
        
        // Parse to initial model
        let model = Invoice(
            teamID: try team.requireID(),
            customerID: content.customerID,
            addressID: content.addressID,
            type: content.type,
            status: content.status,
            number: content.number,
            deposit: content.deposit,
            promotion: content.promotion
        )
        
        // Save model
        return model
            .save(on: req.db)
            .map {
                model
            }
    }
    
    // MARK: - Patch
    func update(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        // Get team
        let team = try req.auth.require(Team.self)
        
        // Validate
        try Invoice.Update.validate(req)
        
        // Decode
        let content = try req.content.decode(Invoice.Update.self)
        
        // Get model
        return Invoice.find(try getId(req), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { model -> EventLoopFuture<Void> in
                // Check ownership
                if try model.$team.id != team.requireID() {
                    throw Abort(.forbidden)
                }
                
                // Replace values
                model.type = content.type ?? model.type
                model.status = content.status ?? model.status
                model.number = content.number
                model.deposit = content.deposit
                model.promotion =  content.promotion
                
                // Update
                return model.update(on: req.db)
            }
            .transform(to: .ok)
    }
}
