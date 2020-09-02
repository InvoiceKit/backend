//
//  File.swift
//  
//
//  Created by Victor Lourme on 02/09/2020.
//

@testable import App
import XCTVapor
import Fluent

struct CustomerTests {
    // MARK: - Initializers
    private var app: Application
    private var token: String
    private var id: UUID?
    private var address: UUID?
    
    init(app: Application, token: String) throws {
        // Set variables
        self.app = app
        self.token = token
        
        // Start testing
        try createCustomer()
        try createCustomerWithoutFields()
        try createCustomerWithoutLastName()
        try fetchCustomers()
        try getCustomer()
        try getCustomerNotFound()
        try patchCustomerWithoutData()
        try patchCustomerWrongData()
        try patchCustomer()
        try addAddress()
        try addAddressWithoutdata()
        try deleteCustomerNotExists()
        try deleteCustomer()
        try deleteCustomerNotExists()
    }
    
    // MARK: - Creation tests
    func createCustomer() throws {
        app.logger.info("[Customer] Creating customer")
        
        try app.test(.PUT, "customers", headers: [
            "Authorization": "Bearer \(token)"
        ], beforeRequest: { req in
            try req.content.encode([
                "firstName": "John",
                "lastName": "Doe",
                "company": "Doe Corp.",
                "phone": "01 02 03 04 05",
                "email": "john.doe@provider.tld"
            ])
        }) { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    func createCustomerWithoutFields() throws {
        app.logger.info("[Customer] Creating customer without specifying body")
        
        try app.test(.PUT, "customers", headers: [
            "Authorization": "Bearer \(token)"
        ]) { res in
            XCTAssertEqual(res.status, .unsupportedMediaType)
        }
    }
    
    func createCustomerWithoutLastName() throws {
        app.logger.info("[Customer] Creating customer without lastName")
        
        try app.test(.PUT, "customers", headers: [
            "Authorization": "Bearer \(token)"
        ], beforeRequest: { req in
            try req.content.encode([
                "firstName": "John"
            ])
        }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    // MARK: - Fetching test
    mutating func fetchCustomers() throws {
        app.logger.info("[Customer] Fetching customers")
        
        try app.test(.GET, "customers", headers: [
            "Authorization": "Bearer \(token)"
        ]) { res in
            XCTAssertEqual(res.status, .ok)
            
            // Parse
            let page = try res.content.decode(Page<Customer>.self)
            
            self.id = page.items[0].id
        }
    }
    
    // MARK: - Getting single test
    func getCustomer() throws {
        app.logger.info("[Customer] Getting a single customer data")
        
        try app.test(.GET, "customers/\(self.id?.uuidString ?? "")", headers: [
            "Authorization": "Bearer \(token)"
        ]) { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    func getCustomerNotFound() throws {
        app.logger.info("[Customer] Getting a customer with wrong ID")
        
        try app.test(.GET, "customers/ABCD-1234", headers: [
            "Authorization": "Bearer \(token)"
        ]) { res in
            XCTAssertEqual(res.status, .notFound)
        }
    }
    
    // MARK: - Adding addresses
    func addAddressWithoutdata() throws {
        app.logger.info("[Customer/Address] Adding an address without data")
        
        try app.test(.PUT, "customers/\(self.id?.uuidString ?? "")/addresses", headers: [
            "Authorization": "Bearer \(token)"
        ], beforeRequest: { req in
            try req.content.encode([
                "line": "",
                "zip": "",
                "city": ""
            ])
        }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    mutating func addAddress() throws {
        app.logger.info("[Customer/Address] Adding an address")
        
        try app.test(.PUT, "customers/\(self.id?.uuidString ?? "")/addresses", headers: [
            "Authorization": "Bearer \(token)"
        ], beforeRequest: { req in
            try req.content.encode([
                "line": "Street Number",
                "zip": "12345",
                "city": "City Name"
            ])
        }) { res in
            XCTAssertEqual(res.status, .ok)
            
            // Parse ID
            self.address = try res.content.decode(Address.self).id
        }
    }
    
    // MARK: - Deleting addresses
    func deleteAddress() throws {
        app.logger.info("[Customer/Address] Delete address")
        
        try app.test(.DELETE, "customers/\(self.id?.uuidString ?? "")/addresses/\(self.address?.uuidString ?? "")", headers: [
            "Authorization": "Bearer \(token)"
        ]) { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    func deleteAddressWithWrongID() throws {
        app.logger.info("[Customer/Address] Delete address with wrong ID")
        
        try app.test(.DELETE, "customers/\(self.id?.uuidString ?? "")/addresses/1234-ABCD", headers: [
            "Authorization": "Bearer \(token)"
        ]) { res in
            XCTAssertEqual(res.status, .notFound)
        }
    }
    
    // MARK: - Patch customer
    func patchCustomerWithoutData() throws {
        app.logger.info("[Customer] Patching the customer without data")
        
        try app.test(.PATCH, "customers/\(self.id?.uuidString ?? "")", headers: [
            "Authorization": "Bearer \(token)"
        ]) { res in
            XCTAssertEqual(res.status, .unsupportedMediaType)
        }
    }
    
    func patchCustomerWrongData() throws {
        app.logger.info("[Customer] Patching the customer with wrong data")
        
        try app.test(.PATCH, "customers/\(self.id?.uuidString ?? "")", headers: [
            "Authorization": "Bearer \(token)"
        ], beforeRequest: { req in
            try req.content.encode([
                "firstName": "",
                "lastName": "",
                "company": ""
            ])
        }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func patchCustomer() throws {
        app.logger.info("[Customer] Patching the customer with good data")
        
        try app.test(.PATCH, "customers/\(self.id?.uuidString ?? "")", headers: [
            "Authorization": "Bearer \(token)"
        ], beforeRequest: { req in
            try req.content.encode([
                "firstName": "",
                "lastName": "",
                "company": "Development Team Corp.",
                "phone": "09 08 07 06 05"
            ])
        }) { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    // MARK: - Delete
    func deleteCustomer() throws {
        app.logger.info("[Customer] Deleting customer")
        
        try app.test(.DELETE, "customers/\(self.id?.uuidString ?? "")", headers: [
            "Authorization": "Bearer \(token)"
        ]) { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    func deleteCustomerNotExists() throws {
        app.logger.info("[Customer] Deleting customer with wrong ID")
        
        try app.test(.DELETE, "customers/ABCD-1234", headers: [
            "Authorization": "Bearer \(token)"
        ]) { res in
            XCTAssertEqual(res.status, .notFound)
        }
    }
}
