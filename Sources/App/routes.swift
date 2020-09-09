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
    try app.register(collection: TeamController())
    try app.register(collection: CustomerController())
    try app.register(collection: InvoiceController())
}
