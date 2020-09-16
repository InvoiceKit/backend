///
/// Team.swift
///

import Fluent
import Vapor
import JWT

final class Team: Content, APIModel, Patchable {
    // MARK: - Model
    static let schema = "teams"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "company")
    var company: String?
    
    @Field(key: "address")
    var address: String?
    
    @Field(key: "zip")
    var zip: String?
    
    @Field(key: "city")
    var city: String?
    
    @Field(key: "website")
    var website: String?
    
    @Field(key: "fields")
    var fields: [String]?
    
    @Field(key: "image_url")
    var image: String?
    
    // MARK: - Initializers
    init() { }
    
    init(id: UUID? = nil, name: String, username: String, passwordHash: String, company: String? = nil, address: String? = nil, city: String? = nil, website: String? = nil, fields: [String]? = nil, image: String? = nil) {
        self.id = id
        self.name = name
        self.username = username
        self.passwordHash = passwordHash
        self.company = company
        self.address = address
        self.city = city
        self.website = website
        self.fields = fields
        self.image = image
    }
    
    // MARK: - Creation
    convenience init(_ input: Input) throws {
        self.init(
            name: input.name,
            username: input.username,
            passwordHash: try Bcrypt.hash(input.password)
        )
    }
    
    struct Input: Content, Validatable {
        var name: String
        var username: String
        var password: String
        
        static func validations(_ validations: inout Validations) {
            validations.add("name", as: String.self, is: !.empty && .ascii)
            validations.add("username", as: String.self, is: .count(6...) && .alphanumeric)
            validations.add("password", as: String.self, is: .count(8...), required: true)
        }
    }
    
    // MARK: - Update
    struct Update: Content {
        var name: String?
        var company: String?
        var address: String?
        var zip: String?
        var city: String?
        var website: String?
        var fields: [String]?
        var image: String?
    }
    
    func update(_ update: Update) throws {
        self.update(\.name, using: update.name)
        self.update(\.company, using: update.company)
        self.update(\.address, using: update.address)
        self.update(\.zip, using: update.zip)
        self.update(\.city, using: update.city)
        self.update(\.website, using: update.website)
        self.update(\.fields, using: update.fields)
        self.update(\.image, using: update.image)
        
    }
    
    // MARK: - Login request
    struct LoginRequest: Content {
        var username: String
        var password: String
    }
    
    // MARK: - Login response
    struct LoginResponse: Content {
        var token: String
    }
    
    // MARK: - JWT
    struct JWTPayload: JWT.JWTPayload, Authenticatable {
        var sub: SubjectClaim
        var username: String
        var exp: ExpirationClaim
        
        var teamID: UUID! {
            UUID(uuidString: sub.value)
        }
        
        func verify(using signer: JWTSigner) throws {
            try self.exp.verifyNotExpired()
        }
    }
    
    // MARK: - JWT Authenticator
    struct JWTAuth: JWTAuthenticator {
        typealias Payload = Team.JWTPayload
        
        func authenticate(jwt: Payload, for request: Request) -> EventLoopFuture<Void> {
            Team.find(jwt.teamID, on: request.db)
                .map {
                    guard $0 != nil else {
                        return
                    }
                    
                    request.auth.login(jwt)
                }

        }
    }
}
