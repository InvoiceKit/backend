//
//  MessageController.swift
//
//
//  Created by Victor Lourme on 21/09/2020.
//

import Fluent
import Vapor

extension GenericController where Model == Message {
    @discardableResult
    static func setupRoutes(_ builder: RoutesBuilder) -> RoutesBuilder {
        return Builder(builder.grouped(schemaPath))
            .set { $0.get(use: protected(using: Team.JWTPayload.self, handler: _readAll)) }
            .set { $0.put(use: _create) }
            .set { $0.grouped(childrenPath) }
            .set {
                $0.get(use: protected(using: Team.JWTPayload.self, handler: _readByID))
            }
            .set {
                $0.delete(use: protected(using: Team.JWTPayload.self, handler: _deleteByID))
            }
            .build()
    }
}
