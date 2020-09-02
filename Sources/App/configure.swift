import Fluent
import FluentSQLiteDriver
import Vapor

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

    // Add migrations
    app.migrations.add(CreateTeam())
    app.migrations.add(CreateToken())
    app.migrations.add(CreateCustomer())
    app.migrations.add(CreateAddress())

    // Register routes
    try routes(app)
}
