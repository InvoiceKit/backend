//
//  CustomerController.swift
//  
//
//  Created by Victor Lourme on 02/09/2020.
//

import Fluent
import Vapor

extension GenericController where Model == Customer {
    @discardableResult
    static func setupRoutes(_ builder: RoutesBuilder) -> RoutesBuilder {
        return Builder(builder.grouped(schemaPath))
            .set { $0.get(use: protected(using: Team.JWTPayload.self, handler: _readAllNoEager)) }
            .set { $0.put(use: protected(using: Team.JWTPayload.self, handler: _create)) }
            .set { $0.grouped(idPath) }
            .set {
                $0.get(use: protected(using: Team.JWTPayload.self, handler: _readByID))
            }
            .set {
                $0.patch(use: protected(using: Team.JWTPayload.self, handler: _updateByID))
            }
            .set {
                $0.delete(use: protected(using: Team.JWTPayload.self, handler: _deleteByID))
            }
            .set {
                $0.grouped(GenericController<Address>.schemaPath)
            }
            .set {
                $0.put(use: protected(using: Team.JWTPayload.self, handler: GenericController<Address>._create))
            }
            .set {
                $0.grouped(GenericController<Address>.childrenPath)
            }
            .set {
                $0.delete(use: protected(using: Team.JWTPayload.self, handler: GenericController<Address>._deleteByID))
            }
            .build()
    }
}
