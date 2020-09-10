///
/// TeamController.swift
///

import Fluent
import Vapor

struct TeamController: RouteCollection {
    // MARK: - Constructor
    func boot(routes: RoutesBuilder) throws {
        // Route: /teams
        let root = routes.grouped("teams")
        
        // Route: PUT /teams/register
        root.put("register", use: create)
        
        // Basic authentication guarded
        let auth = root.grouped(Team.authenticator())
        
        // Route: POST /teams/login
        auth.post("login", use: login)
        
        // Token guarded
        let token = auth.grouped(Token.authenticator(), Team.guardMiddleware())
        
        // Route: GET /teams/profile
        token.get("profile", use: fetch)
        
        // Route: PATCH /teams/profile
        token.patch("profile", use: patch)
    }

    // MARK: - Register
    func create(_ req: Request) throws -> EventLoopFuture<Team> {
        // Try to validate
        try Team.Create.validate(req)
        
        // Decode content
        let content = try req.content.decode(Team.Create.self)
        
        // Hash the password
        let passwordHash = try Bcrypt.hash(content.password)
        
        // Create the team
        let team = Team(
            name: content.name,
            username: content.username,
            passwordHash: passwordHash
        )
        
        return team.save(on: req.db).flatMapErrorThrowing { error in
            throw Abort(.badRequest)
        }.map { team }
    }
    
    // MARK: - Login
    func login(_ req: Request) throws -> EventLoopFuture<Token.Response> {
        // Check for auth
        let team = try req.auth.require(Team.self)
        
        // Generate a token
        let token = try team.generateToken()
        
        // Prepare data
        let response = Token.Response(
            team: team,
            token: token
        )
        
        // Return the userdata with token
        return token.save(on: req.db)
            .map {
                response
            }
    }
    
    // MARK: - User data
    func fetch(_ req: Request) throws -> Team {
        try req.auth.require(Team.self)
    }
    
    // MARK: - Patch data
    func patch(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        // Get user
        let user = try req.auth.require(Team.self)
        
        // Validate content
        try Team.Update.validate(req)
        
        // Get content
        let content = try req.content.decode(Team.Update.self)
        
        // Get model
        return Team.find(user.id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { team -> EventLoopFuture<Void> in
                // Set content
                team.name = content.name ?? team.name
                team.company = content.company
                team.address = content.address
                team.city = content.city
                team.website = content.website
                team.fields = content.fields
                team.image = content.image
                
                // Update
                return team.update(on: req.db)
            }
            .transform(to: .ok)
    }
}
