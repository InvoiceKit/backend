import Fluent
import FluentSQLiteDriver
import Vapor
import Leaf

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
    
    // Add migrations
    app.migrations.add(CreateTeam())
    app.migrations.add(CreateToken())
    app.migrations.add(CreateCustomer())
    app.migrations.add(CreateAddress())
    app.migrations.add(CreateInvoice())
    app.migrations.add(CreateInvoiceField())
    
    // Enable auto-migrations
    try app.autoMigrate().wait()

    // Register routes
    try routes(app)
}
