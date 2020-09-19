import Fluent

struct CreateTeam: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("teams")
            .id()
            .field("name", .string, .required)
            .field("username", .string, .required)
            .field("password_hash", .string, .required)
            .field("company", .string)
            .field("address", .string)
            .field("zip", .string)
            .field("city", .string)
            .field("website", .string)
            .field("fields", .array(of: .string))
            .field("image", .data)
            .unique(on: "username")
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("teams").delete()
    }
}
