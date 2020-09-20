//
//  ContractController.swift
//  
//
//  Created by Victor Lourme on 20/09/2020.
//

import Fluent
import Vapor

extension GenericController where Model == Contract {
    @discardableResult
    static func setupRoutes(_ builder: RoutesBuilder) -> RoutesBuilder {
        return Builder(builder.grouped(schemaPath))
            .set { $0.get(use: protected(using: Team.JWTPayload.self, handler: _readAll)) }
            .set { $0.put(use: protected(using: Team.JWTPayload.self, handler: _create)) }
            .set { $0.grouped(childrenPath) }
            .set {
                $0.get(use: protected(using: Team.JWTPayload.self, handler: _readByID))
            }
            .set {
                $0.patch(use: protected(using: Team.JWTPayload.self, handler: _updateByID))
            }
            .set {
                $0.delete(use: protected(using: Team.JWTPayload.self, handler: _deleteByID))
            }
            .build()
    }
}
