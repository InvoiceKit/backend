//
//  TeamTests.swift
//  
//
//  Created by Victor Lourme on 02/09/2020.
//

@testable import App
import XCTVapor

struct TeamTests {
    public var app: Application
    public var token: String = ""
    
    // MARK: Initializer
    init(_ app: Application) throws {
        // Store app
        self.app = app
        
        // Launch tests
        try createTeam()
        try createTeamWithSameCredentials()
        try createTeamWithoutPassword()
        try login()
        try loginWrongUsername()
        try loginWrongPassword()
        try getTeamdata()
        try getTeamdataWrongToken()
    }
    
    // MARK: - Registration tests
    func createTeam() throws {
        app.logger.info("[Team] Creating team")
        
        try app.test(.PUT, "teams/register", beforeRequest: { req in
            try req.content.encode([
                "name": "Development Team",
                "username": "devteam",
                "password": "password"
            ])
        }) { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    func createTeamWithSameCredentials() throws {
        app.logger.info("[Team] Creating two time the same team")
        
        try app.test(.PUT, "teams/register", beforeRequest: { req in
            try req.content.encode([
                "name": "Development Team",
                "username": "devteam",
                "password": "password"
            ])
        }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func createTeamWithoutPassword() throws {
        app.logger.info("[Team] Creating team without password")
        
        try app.test(.PUT, "teams/register", beforeRequest: { req in
            try req.content.encode([
                "name": "Development Team",
                "username": "another",
                "password": ""
            ])
        }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    // MARK: - Authentication
    mutating func login() throws {
        app.logger.info("[Team] Signing in")
        
        try app.test(.POST, "teams/login", beforeRequest: { req in
            req.headers.basicAuthorization = BasicAuthorization(
                username: "devteam", password: "password"
            )
        }) { res in
            XCTAssertEqual(res.status, .ok)
    
            // Set token
            token = try res.content.decode(Token.Response.self).token.value
        }
    }
    
    func loginWrongUsername() throws {
        app.logger.info("[Team] Signing in with wrong username and password")
        
        try app.test(.POST, "teams/login", beforeRequest: { req in
            req.headers.basicAuthorization = BasicAuthorization(
                username: "doesnotexist", password: "wrong-password"
            )
        }) { res in
            XCTAssertEqual(res.status, .unauthorized)
        }
    }
    
    func loginWrongPassword() throws {
        app.logger.info("[Team] Signing in with wrong password")
        
        try app.test(.POST, "teams/login", beforeRequest: { req in
            req.headers.basicAuthorization = BasicAuthorization(
                username: "devteam", password: "wrong-password"
            )
        }) { res in
            XCTAssertEqual(res.status, .unauthorized)
        }
    }
    
    // MARK: - Team data
    func getTeamdata() throws {
        app.logger.info("[Team] Getting team data")
        
        // Get team data
        try app.test(.GET, "teams/profile", headers: [
            "Authorization": "Bearer \(self.token)"
        ]) { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    func getTeamdataWrongToken() throws {
        app.logger.info("[Team] Getting team data with wrong token")
        
        try app.test(.GET, "teams/profile", headers: [
            "Authorization": "Bearer wrong-token-here"
        ]) { res in
            XCTAssertEqual(res.status, .unauthorized)
        }
    }
}
