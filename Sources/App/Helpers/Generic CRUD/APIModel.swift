import Fluent
import Vapor

// MARK: - CRUDModel
protocol CRUDModel: Content, Model {
    ///
    /// This will impact the ID getting method
    ///
    static var isChildren: Bool { get }
    
    ///
    /// Input structure
    ///
    associatedtype Input: Content
    
    ///
    /// Initialize with structure
    ///
    init(_ input: Input) throws
}

extension CRUDModel {
    static var isChildren: Bool { false }
}

// MARK: - Patchable
protocol Patchable: CRUDModel {
    associatedtype Update: Content
    
    func update(_ update: Update) throws
}

extension Patchable {
    ///
    /// Update specific field by optional
    ///
    func update<Value>(_ keyPath: WritableKeyPath<Self, Value>, using optional: Value?) {
        var _self = self
        if let value = optional { _self[keyPath: keyPath] = value }
    }
}

// MARK: - CustomOuput
protocol CustomOutput: CRUDModel {
    associatedtype Output: Content
    
    var output: Output { get }
}

// MARK: - Relatable
protocol Relatable: CRUDModel {
    associatedtype ParentType: Model
    
    static var isAuthChildren: Bool { get }
    
    var _parent: Parent<ParentType> { get }
    
    static var castError: HTTPResponseStatus { get }
    
    func assignParent(_ req: Request) throws
}

extension Relatable where Self: APIModel, Self.IDValue: LosslessStringConvertible {
    ///
    /// If auth children is true, parent will get associed with Auth Model ID
    ///
    static var isAuthChildren: Bool { false }
    
    ///
    /// Error in case of wrong parent ID
    ///
    static var castError: HTTPResponseStatus { .custom(
        code: 500,
        reasonPhrase: "Unable to cast AuthModel.ID as Parent.IDValue")
    }
    
    ///
    /// Assign a parent to the model
    /// - parameters:
    ///     - req: Request
    ///     - model: Model
    /// - returns:
    ///     - Model with assigned parent
    ///
    func assignParent(_ req: Request) throws {
        // Set parent
        if Self.isAuthChildren {
            // Get auth model
            let auth = try req.auth.require(Team.JWTPayload.self)
            
            guard let id = auth.teamID as? ParentType.IDValue else {
                throw Abort(Self.castError)
            }
            
            _parent.id = id
        } else {
            // Get sub-class model
            guard let id = try GenericController<Self>.getID(req, parent: true) as? ParentType.IDValue else {
                throw Abort(Self.castError)
            }
            
            _parent.id = id
        }
    }
}

// MARK: - EagerLoadProvidingModel

protocol EagerLoadProvidingModel: Model {
    /// Sets up query to load child properties
    ///
    /// Does not modify query by default, should be implemented to load specific fields
    ///
    /// Implementation example:
    /// ```
    /// static func eagerLoad(to builder: QueryBuilder<Self>) -> QueryBuilder<Self> {
    ///     builder.with(\.$field)
    /// }
    /// ```
    ///
    /// Use conveniecne function for access this method
    /// Usage example:
    /// ```
    /// eagerLoadedQuery(for: SomeAPIModel.self, on: req.db) // QueryBuilder<SomeAPIModel>
    /// ```
    static func eagerLoad(to builder: QueryBuilder<Self>) -> QueryBuilder<Self>
}

extension EagerLoadProvidingModel {
    static func eagerLoad(to builder: QueryBuilder<Self>) -> QueryBuilder<Self> { builder }
}

// MARK: - APIModel

protocol APIModel: CRUDModel, EagerLoadProvidingModel {}

extension APIModel {
    static func eagerLoadedQuery(on database: Database) -> QueryBuilder<Self> {
        _eagerLoadedQuery(for: self, on: database)
    }
    
    /// Loads eager loaded instance from the database
    ///
    /// Should not be reimplemented
    func load(on database: Database) -> EventLoopFuture<Self?> {
        Self.load(id, on: database)
    }
    
    /// Loads eager loaded instance from the database
    ///
    /// Should not be reimplemented
    static func load(_ id: IDValue?, on database: Database) -> EventLoopFuture<Self?> {
        _load(self, id, on: database)
    }
}

extension CustomOutput where Self: APIModel {
    /// Loads eager loaded instance from the database
    ///
    /// Should not be reimplemented
    func load(on database: Database) -> EventLoopFuture<Output?> {
        Self.load(id, on: database)
    }
    
    /// Loads eager loaded instance from the database
    ///
    /// Should not be reimplemented
    static func load(_ id: IDValue?, on database: Database) -> EventLoopFuture<Output?> {
        _load(self, id, on: database)
    }
}

private func _eagerLoadedQuery<Model: APIModel>(for type: Model.Type, on database: Database) -> QueryBuilder<Model> {
    type.eagerLoad(to: database.query(type))
}

private func _load<Model: APIModel>(_ type: Model.Type, _ id: Model.IDValue?, on database: Database) -> EventLoopFuture<Model?> {
    // Get ID
    guard let id = id else {
        return database.eventLoop.makeSucceededFuture(nil)
        
    }
    
    return _eagerLoadedQuery(for: type, on: database)
        .filter(\._$id == id)
        .first()
}

private func _load<Model: APIModel & CustomOutput>(_ type: Model.Type, _ id: Model.IDValue?, on database: Database) -> EventLoopFuture<Model.Output?> {
    // Get ID
    guard let id = id else {
        return database.eventLoop.makeSucceededFuture(nil)
        
    }
    
    return _eagerLoadedQuery(for: type, on: database)
        .filter(\._$id == id)
        .first()
        .map {
            $0?.output
        }
}
