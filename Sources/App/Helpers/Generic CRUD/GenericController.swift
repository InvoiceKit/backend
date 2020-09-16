import Vapor
import Fluent

enum GenericController<Model: APIModel> where Model.IDValue: LosslessStringConvertible {
    // MARK: - Variables and definitions
    ///
    /// Main ID used to identify entries and groups
    ///
    static var idKey: String { "id" }
    
    ///
    /// Children path from idKey
    /// This is used to create URL groups
    ///
    static var idPath: PathComponent { .init(stringLiteral: ":\(idKey)") }
    
    ///
    /// Children key used to ID extraction and groups
    ///
    static var childrenKey: String { "children" }
    
    ///
    /// Children path from childrenKey
    /// This is used to create URL groups
    ///
    static var childrenPath: PathComponent { .init(stringLiteral: ":\(childrenKey)") }
    
    ///
    /// Schema path extracted from model
    /// This is used to create endpoint URL "GET /schemaPath/.../"
    ///
    static var schemaPath: PathComponent { .init(stringLiteral: Model.schema) }
    
    // MARK: - Helpers
    ///
    /// Get main identifier from the URL
    ///
    /// - parameters:
    ///     - req: Request
    /// - returns:
    ///     - Model.IDValue
    ///
    static func getID(_ req: Request, parent: Bool = false) throws -> Model.IDValue {
        // Default target
        let target = Model.isChildren ? childrenKey : idKey
        
        // Get ID
        guard let id = req.parameters.get(parent ? idKey : target, as: Model.IDValue.self) else {
            throw Abort(.badRequest)
        }
        
        // Return ID
        return id
    }
    
    ///
    /// Find and unwrap a model by its ID
    ///
    /// - parameters:
    ///     - req: Request
    /// - returns:
    ///     - Mode
    ///
    static func _findByID(_ req: Request) throws -> EventLoopFuture<Model> {
        Model.find(try getID(req), on: req.db).unwrap(or: Abort(.notFound))
    }
    
    // MARK: - Methods for endpoints
    ///
    /// Save a new entry in the database that does not have a parent
    ///
    /// - parameters:
    ///     - req: Request
    /// - returns:
    ///     - Model
    ///
    static func _create(_ req: Request) throws -> EventLoopFuture<Model> {
        // Get prepared model
        let model = try _prepareModel(req)
        
        // Save
        return model.save(on: req.db)
            .flatMap { model.load(on: req.db) }
            .unwrap(or: Abort(.notFound))
    }
    
    ///
    /// Save a new entry in the database with a parent
    ///
    /// - parameters:
    ///     - req: Request
    /// - returns:
    ///     - Model
    ///
    static func _create(_ req: Request) throws -> EventLoopFuture<Model> where Model: Relatable {
        // Get prepared model
        let model = try _prepareModel(req)
        
        // Assign a parent
        try model.assignParent(req)
        
        // Save
        return model.save(on: req.db)
            .flatMap { model.load(on: req.db) }
            .unwrap(or: Abort(.notFound))
    }
    
    ///
    /// Wrapper methods with CustomOutput support
    ///
    static func _create(_ req: Request) throws -> EventLoopFuture<Model.Output> where Model: CustomOutput & Relatable {
        try _create(req).map(\.output)
    }
    
    static func _create(_ req: Request) throws -> EventLoopFuture<Model.Output> where Model: CustomOutput {
        try _create(req).map(\.output)
    }
    
    ///
    /// Prepare the model for creation of an database entry
    /// - parameters:
    ///     - req: Request
    /// - returns:
    ///     - Model
    ///
    static func _prepareModel(_ req: Request) throws -> Model {
        // Check content
        if let input = Model.Input.self as? Validatable.Type {
            try input.validate(req)
        }
        
        // Get input model
        let request = try req.content.decode(Model.Input.self)
        
        // Create and return model
        return try Model(request)
    }
    
    ///
    /// Read all entries with pagination and eager loading (childrens)
    ///
    /// - parameters:
    ///     - req: Request
    /// - returns:
    ///     - Page<Model>
    ///
    static func _readAll(_ req: Request) throws -> EventLoopFuture<Page<Model>> {
        Model.eagerLoadedQuery(on: req.db)
            .paginate(for: req)
    }
    
    ///
    /// Wrapper method for readAll with CustomOutput support
    ///
    static func _readAll(_ req: Request) throws -> EventLoopFuture<Page<Model.Output>> where Model: CustomOutput {
        try _readAll(req)
            .map {
                $0.map(\.output)
            }
    }
    
    ///
    /// Read all entries with pagination but without loading childrens (no eager loading)
    ///
    /// - parameters:
    ///     - req: Request
    /// - returns:
    ///     - Page<Model>
    ///
    static func _readAllNoEager(_ req: Request) throws -> EventLoopFuture<Page<Model>> where Model: Relatable {
        // ID
        var id: Model.ParentType.IDValue
        
        if Model.isAuthChildren {
            // Get auth model
            let auth = try req.auth.require(Team.JWTPayload.self)
            
            // Get ID
            guard let idx = auth.teamID as? Model.ParentType.IDValue else {
                throw Abort(Model.castError)
            }
            
            id = idx
        } else {
            // Get ID
            guard let idx = try getID(req) as? Model.ParentType.IDValue else {
                throw Abort(Model.castError)
            }
            
            id = idx
        }
        
        return Model.query(on: req.db)
            .filter(\._parent.$id == id)
            .paginate(for: req)
    }
    
    ///
    /// Wrapper method for readAllNoEager with CustomOutput support
    ///
    static func _readAllNoEager(_ req: Request) throws -> EventLoopFuture<Page<Model.Output>> where Model: Relatable, Model: CustomOutput {
        try _readAllNoEager(req)
            .map {
                $0.map(\.output)
            }
    }

    ///
    /// Read specified entry with childrens from ID provided in URL (/model/:id)
    ///
    /// - parameters:
    ///     - req: Request
    /// - returns:
    ///     - Eager loaded model
    ///
    static func _readByID(_ req: Request) throws -> EventLoopFuture<Model> {
        Model.load(try getID(req), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    ///
    /// Wrapper method for readByID with CustomOutput support
    ///
    static func _readByID(_ req: Request) throws -> EventLoopFuture<Model.Output> where Model: CustomOutput {
        try _readByID(req).map(\.output)
    }
    
    ///
    /// Update a model in the database
    /// - note:
    ///     - This is hard-refactoring, when a field is null or not defined, it's overwritten, the old value is not kept
    ///     - Model must be patchable
    /// - parameters:
    ///     - req: Request
    /// - returns:
    ///     - Eager loaded model
    ///
    static func _updateByID(_ req: Request) throws -> EventLoopFuture<Model> where Model: Patchable {
        // Check content
        if let model = Model.Update.self as? Validatable.Type {
            try model.validate(req)
        }
        
        print(type(of: Model.self))
        
        // Parse model
        let content = try req.content.decode(Model.Update.self)
        
        print(try getID(req))
        
        // Update
        return try _findByID(req)
            .flatMapThrowing { model -> Model in
                try modification(of: model) { try $0.update(content) }
            }
            .flatMap { $0.update(on: req.db).transform(to: $0) }
            .flatMap { Model.load($0.id, on: req.db) }
            .unwrap(or: Abort(.notFound))
    }
    
    ///
    /// Wrapper method with CustomOutput support
    ///
    static func _updateByID(_ req: Request) throws -> EventLoopFuture<Model.Output> where Model: Patchable, Model: CustomOutput {
        // Update
        return try _updateByID(req).map(\.output)
    }
    
    ///
    /// Delete a entry from the database
    /// - parameters:
    ///     - req: Request
    /// - returns:
    ///     - HTTP Status
    ///
    static func _deleteByID(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        try _findByID(req)
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
    
    // MARK: - Routing
    ///
    /// Setup the primitive routes
    /// Primitive routes does not need any identifier
    /// Actions possible are fetching all and creating entry
    ///
    /// - parameters:
    ///     - builder: RoutesBuilder
    /// - returns:
    ///     - Builder<RoutesBuilder>
    ///
    static func _setupPrimitiveRoutes(_ builder: RoutesBuilder) -> Builder<RoutesBuilder> {
        return Builder(builder.grouped(schemaPath))
            .set { $0.get(use: _readAll) }
            .set { $0.put(use: _create) }
    }
    
    ///
    /// Setup the identified routes
    /// Identified routes allows user to get an entry with its childrens, update (if Patchable) or delete it
    ///
    /// - parameters:
    ///     - builder: Builder<RoutesBuilder>
    /// - returns:
    ///     - Builder<RoutesBuilder>
    ///
    static func _setupIdentifiedRoutes(_ builder: Builder<RoutesBuilder>) -> Builder<RoutesBuilder> {
        return builder
            .set { $0.grouped(idPath) }
            .set { $0.get(use: _readByID) }
            .set { $0.delete(use: _deleteByID) }
    }
    
    ///
    /// Setup the identified routes for a Patchable model
    /// This adds the PATCH method
    ///
    static func _setupIdentifiedRoutes(_ builder: Builder<RoutesBuilder>) -> Builder<RoutesBuilder> where Model: Patchable {
        return builder
            .set { $0.grouped(idPath) }
            .set { $0.get(use: _readByID) }
            .set { $0.patch(use: _updateByID) }
            .set { $0.delete(use: _deleteByID) }
    }
    
    ///
    /// Makes initial routes setup
    ///
    /// Uses default methods (without auth stuff) to setup routes:
    /// ```
    /// ┌––––––––––┬–––––––––––––┐
    /// |   GET    | /schema     |
    /// ├––––––––––┼–––––––––––––┤
    /// |   PUT    | /schema     |
    /// ├––––––––––┼–––––––––––––┤
    /// |   GET    | /schema/:id |
    /// ├––––––––––┼–––––––––––––┤
    /// |  PATCH   | /schema/:id |
    /// ├––––––––––┼–––––––––––––┤
    /// |  DELETE  | /schema/:id |
    /// └––––––––––┴–––––––––––––┘
    /// ```
    ///
    @discardableResult
    static func _setupRoutes(_ builder: RoutesBuilder) -> RoutesBuilder {
            var routes = _setupPrimitiveRoutes(builder)
            routes = _setupIdentifiedRoutes(routes)
            
            return routes.build()
    }

    // MARK: - Authenticated routes
    /// Protects the route
    static func protected<Requirement: Authenticatable, Response>(
        _ req: Request,
        using auth: Requirement.Type,
        handler: @escaping (Request) throws -> Response
    ) throws -> Response { try protected(using: auth, handler: handler)(req) }
    
    
    /// Protects the route
    static func protected<Requirement: Authenticatable, Response>(
        _ req: Request,
        using auth: Requirement.Type,
        handler: @escaping (Request, Requirement) throws -> Response
    ) throws -> Response { try protected(using: auth, handler: handler)(req) }
    
    /// Protects the route
    static func protected<Requirement: Authenticatable, Response>(
        using auth: Requirement.Type,
        handler: @escaping (Request) throws -> Response
    ) -> (Request) throws -> Response {
        protected(using: auth) { request, _ in try handler(request) }
    }
    
    /// Protects the route
    static func protected<Requirement: Authenticatable, Response>(
        using auth: Requirement.Type,
        handler: @escaping (Request, Requirement) throws -> Response
    ) -> (Request) throws -> Response {
        { request in
            return try handler(request, try request.auth.require(auth))
        }
    }
}
