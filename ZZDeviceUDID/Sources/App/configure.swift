import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // Host and Port
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 4443
    
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor",
        database: Environment.get("DATABASE_NAME") ?? "vapor"
    ), as: .psql)

    app.migrations.add(CreateTodo())
    app.migrations.add(CreateZZDevice())

    app.views.use(.leaf)

    

    // register routes
    try routes(app)
}
