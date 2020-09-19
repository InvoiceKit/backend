//
//  InvoiceController.swift
//  
//
//  Created by Victor Lourme on 03/09/2020.
//

import Fluent
import Vapor

extension GenericController where Model == Invoice {
    @discardableResult
    static func setupRoutes(_ builder: RoutesBuilder) -> RoutesBuilder {
        let root = Builder(builder.grouped(schemaPath))
            .set { $0.get(use: protected(using: Team.JWTPayload.self, handler: _readAll)) }
            .set { $0.put(use: protected(using: Team.JWTPayload.self, handler: _create)) }
            .set { $0.grouped(idPath) }
            .set {
                $0.get("render", use: render)
            }
            .set {
                $0.get(use: protected(using: Team.JWTPayload.self, handler: _readByID))
            }
            .set {
                $0.patch(use: protected(using: Team.JWTPayload.self, handler: _updateByID))
            }
            .set {
                $0.delete(use: protected(using: Team.JWTPayload.self, handler: _deleteByID))
            }
        
        // Breaking up expression, too long for compiler
        return root
            .set {
                $0.grouped(GenericController<InvoiceField>.schemaPath)
            }
            .set {
                $0.put(use: protected(using: Team.JWTPayload.self, handler: GenericController<InvoiceField>._create))
            }
            .set {
                $0.grouped(GenericController<InvoiceField>.childrenPath)
            }
            .set {
                $0.patch(use: protected(using: Team.JWTPayload.self, handler: GenericController<InvoiceField>._updateByID))
            }
            .set {
                $0.delete(use: protected(using: Team.JWTPayload.self, handler: GenericController<InvoiceField>._deleteByID))
            }
            .build()
    }
    
    static func render(_ req: Request) throws -> EventLoopFuture<View> {
        // Return
        Model.eagerLoadedQuery(on: req.db)
            .filter(try \.$id == getID(req))
            .first()
            .unwrap(or: Abort(.notFound))
            .map(\.outputPrint)
            .flatMap { invoice in
                // Render view
                return req.view.render("invoice", invoice)
            }
    }
}
