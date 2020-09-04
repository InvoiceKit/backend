@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    func testAll() throws {
        // Start application
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        // Run migration in memory
        try app.autoMigrate().wait()
        
        // Start tests
        let team = try TeamTests(app)
        let customer = try CustomerTests(app: app, token: team.token)
        _ = try InvoiceTests(app: app, token: team.token, customer: customer.id, address: customer.address)
        
        // Finish the CustomerTests
        try customer.deleteAddress()
        try customer.deleteCustomer()
    }
}
