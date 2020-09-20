import Fluent
import FluentSQLiteDriver
import Vapor
import Leaf
import JWT

// configures your application
public func configure(_ app: Application) throws {
    // Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Setup SQLite
    if app.environment == .testing {
        app.databases.use(.sqlite(.memory), as: .sqlite)
    } else {
        app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    }
    
    // Enable Leaf
    app.views.use(.leaf)
    app.leaf.cache.isEnabled = app.environment.isRelease

    // Add leaf tags
    app.leaf.tags[DoubleFix.name] = DoubleFix()
    app.leaf.tags[IsEmptyTag.name] = IsEmptyTag()
    
    // Add migrations
    app.migrations.add(CreateTeam())
    app.migrations.add(CreateCustomer())
    app.migrations.add(CreateAddress())
    app.migrations.add(CreateInvoice())
    app.migrations.add(CreateInvoiceField())
    app.migrations.add(CreateContract())
    
    // Enable auto-migrations
    try app.autoMigrate().wait()

    if app.environment == .testing || app.environment == .development {
        // Setup JWT with a static key
        app.jwt.signers.use(.hs256(key: "secret"))
    } else {
        // Setup JWT with a random key per start
        app.jwt.signers.use(.hs256(key: String.random(length: 64)))
    }
    
    
    // Register routes
    try routes(app)
}
