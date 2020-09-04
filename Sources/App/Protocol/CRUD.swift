//
//  CRUD.swift
//  
//
//  Created by Victor Lourme on 03/09/2020.
//

import Fluent
import Vapor

protocol CRUD {
    // MARK: - Associated type
    associatedtype APIModel: Model, Content
    
    // MARK: - Variables
    var parent: KeyPath<APIModel, ParentProperty<APIModel, Team>> { get }
    
    // MARK: - Helpers
    func getId(_ req: Request) throws -> APIModel.IDValue
    
    // MARK: - Methods
    func fetch(_ req: Request) throws -> EventLoopFuture<Page<APIModel>>
    func get(_ req: Request) throws -> EventLoopFuture<APIModel>
    func delete(_ req: Request) throws -> EventLoopFuture<HTTPStatus>
}
