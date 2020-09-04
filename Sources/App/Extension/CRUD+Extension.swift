//
//  CRUD+Extension.swift
//  
//
//  Created by Victor Lourme on 03/09/2020.
//

import Fluent
import Vapor

extension CRUD where APIModel.IDValue: LosslessStringConvertible {
    ///
    /// Get identifier from request parameters
    /// - parameters:
    ///     - req: Request
    /// - returns:
    ///     - IDValue
    ///
    func getId(_ req: Request) throws -> APIModel.IDValue {
        guard let id = req.parameters.get("id", as: APIModel.IDValue.self) else {
            throw Abort(.notFound)
        }
        
        return id
    }
    
    ///
    /// Fetch every entries with pagination
    /// - parameters:
    ///     - req: Request
    /// - returns:
    ///     - Future with paginated associated type models
    ///
    func fetch(_ req: Request) throws -> EventLoopFuture<Page<APIModel>> {
        // Get team
        let team = try req.auth.require(Team.self)
        
        // Get every entries
        return APIModel.query(on: req.db)
            .join(parent: parent)
            .filter(Team.self, try \.$id == team.requireID())
            .paginate(for: req)
    }
    
    ///
    /// Get a single entry
    /// - parameters:
    ///     - req: Request
    /// - returns:
    ///     - Future with associated type model
    ///
    func get(_ req: Request) throws -> EventLoopFuture<APIModel> {
        // Get filtered entry
        return APIModel.find(try getId(req), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    ///
    /// Delete an entry
    /// - parameters:
    ///     - req: Request
    /// - returns:
    ///     - HTTP Status
    ///
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        // Delete the model
        APIModel.find(try getId(req), on: req.db)
            .unwrap(or: Abort(.notFound))
            .map { model in
                model.delete(on: req.db)
            }
            .transform(to: .ok)
    }
}
