import Fluent
import FluentPostgresDriver
import Vapor
import Leaf
import JWT

// configures your application
public func configure(_ app: Application) throws {
    // Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // Setup Postgres
    if let databaseURL = Environment.get("DATABASE_URL") {
        app.databases.use(try .postgres(
            url: databaseURL
        ), as: .psql)
    } else {
        app.databases.use(.postgres(
            hostname: "localhost", username: "postgres", password: ""
        ), as: .psql)
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
    app.migrations.add(CreateContract())
    app.migrations.add(CreateMessage())
    
    // Enable auto-migrations
    try app.autoMigrate().wait()
    
    if app.environment == .testing || app.environment == .development {
        // Setup JWT with a static key
        app.jwt.signers.use(.hs256(key: "secret"))
    } else {
        // Setup JWT with a random key per start
        app.jwt.signers.use(.hs256(key: "PV%BaRD]An?L_5V'@_<Y4aM%1L2Irxm>_g,Y[|~Q#g(>Fr:j_tKM7J/``nzn'*-"))
    }
    
    
    // Register routes
    try routes(app)
}
