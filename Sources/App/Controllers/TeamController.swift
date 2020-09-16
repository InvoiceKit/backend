//
//  TeamController.swift
//  
//
//  Created by Victor Lourme on 14/09/2020.
//

import Vapor
import Fluent

extension GenericController where Model == Team {
    @discardableResult
    static func setupRoutes(_ builder: RoutesBuilder) -> RoutesBuilder {
        return Builder(builder.grouped(schemaPath))
            .set { $0.put(use: create) }
            .set { $0.post("login", use: login) }
            .set { $0.get(use: protected(using: Team.JWTPayload.self, handler: getTeam)) }
            .set { $0.grouped(idPath) }
            .set { $0.patch(use: protected(using: Team.JWTPayload.self, handler: _updateByID)) }
            .build()
    }
    
    static func create(_ req: Request) throws -> EventLoopFuture<Model.LoginResponse> {
        let input = try req.content.decode(Model.Input.self)
        
        return try Model(input)
            .save(on: req.db)
            .transform(to: try login(
                        Model.LoginRequest(
                            username: input.username,
                            password: input.password
                        ), jwt: req.jwt, on: req.db))
    }
    
    static func login(_ req: Request) throws -> EventLoopFuture<Model.LoginResponse> {
        return try login(req.content.decode(Model.LoginRequest.self), jwt: req.jwt, on: req.db)
    }
    
    static func login(_ input: Model.LoginRequest, jwt: Request.JWT, on database: Database) throws -> EventLoopFuture<Model.LoginResponse> {
        Model.eagerLoadedQuery(on: database)
            .filter(\.$username == input.username)
            .first()
            .unwrap(or: Abort(.notFound))
            .guard({
                (try? Bcrypt.verify(input.password, created: $0.passwordHash)) == true
            }, else: Abort(.unauthorized))
            .flatMapThrowing {
                Model.LoginResponse(token: try jwt.sign(
                    Model.JWTPayload(
                        sub: .init(value: $0.id!.uuidString),
                        username: $0.username,
                        exp: .init(value: Date().addingTimeInterval(3600 * 24 * 7)) // 7 days
                    )
                ))
            }
    }
    
    static func getTeam(_ req: Request) throws -> EventLoopFuture<Team> {
        let payload = try req.auth.require(Team.JWTPayload.self)
        
        return Model.find(payload.teamID, on: req.db)
            .unwrap(or: Abort(.notFound))
    }
}
