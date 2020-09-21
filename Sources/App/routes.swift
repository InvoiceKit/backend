import Fluent
import Vapor

func routes(_ app: Application) throws {
    // CORS
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [
            .GET,
            .POST,
            .PUT,
            .OPTIONS,
            .DELETE,
            .PATCH
        ],
        allowedHeaders: [
            .accept,
            .authorization,
            .contentType,
            .origin,
            .xRequestedWith,
            .userAgent,
            .accessControlAllowOrigin
        ]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    let error = ErrorMiddleware.default(environment: app.environment)
    
    app.middleware.use(cors)
    app.middleware.use(error)
    
    // Routes    
    let protected = app.grouped(Team.JWTAuth())
    GenericController<Message>.setupRoutes(protected)
    GenericController<Team>.setupRoutes(protected)
    GenericController<Customer>.setupRoutes(protected)
    GenericController<Invoice>.setupRoutes(protected)
    GenericController<Contract>.setupRoutes(protected)
    try protected.register(collection: ChartsController())
}
