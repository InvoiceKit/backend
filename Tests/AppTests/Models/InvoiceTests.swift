//
//  InvoiceTests.swift
//  
//
//  Created by Victor Lourme on 03/09/2020.
//

@testable import App
import XCTVapor
import Fluent

struct InvoiceTests {
    // MARK: - Initializers
    private var app: Application
    private var token: String
    private var customer: UUID?
    private var address: UUID?
    private var invoice: UUID?
    private var field: UUID?
    
    init(app: Application, token: String, customer: UUID?, address: UUID?) throws {
        // Set variables
        self.app = app
        self.token = token
        self.customer = customer
        self.address = address
        
        // Execute tests
        try createInvoice()
        try createInvoiceWithMissingData()
        try fetchingInvoices()
        try addingField()
        try addingFieldToWrongInvoice()
        try addingFieldWithMissingData()
        try getInvoice()
        try getInvoiceWrongId()
        try patchingField()
        try patchingFieldWithWrongId()
        try patchingFieldWithMissingData()
        try deletingField()
        try deletingFieldWithWrongId()
        try patchingInvoice()
        try patchingInvoiceWithMissingData()
        try patchingInvoiceWithMissingId()
        try deletingInvoice()
        try deletingInvoiceWithWrongId()
    }
    
    // MARK: - Making invoice
    func createInvoice() throws {
        app.logger.info("[Invoice] Creating invoice")
        
        try app.test(.PUT, "invoices", headers: [
            "Authorization": "Bearer \(token)"
        ], beforeRequest: { req in
            try req.content.encode([
                "customerID": customer?.uuidString ?? "",
                "addressID": address?.uuidString ?? "",
                "status": "waiting",
                "type": "invoice",
                "number": "01/2020",
                "createdAt": ISO8601DateFormatter().string(from: Date())
            ])
        }) { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    func createInvoiceWithMissingData() throws {
        app.logger.info("[Invoice] Creating invoice with missing data")
        
        try app.test(.PUT, "invoices", headers: [
            "Authorization": "Bearer \(token)"
        ], beforeRequest: { req in
            try req.content.encode([
                "customerID": customer?.uuidString ?? "",
                "addressID": address?.uuidString ?? "",
                "status": "waiting"
            ])
        }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    // MARK: - Fetching
    mutating func fetchingInvoices() throws {
        app.logger.info("[Invoice] Getting invoices")
        
        try app.test(.GET, "invoices", headers: [
            "Authorization": "Bearer \(token)"
        ]) { res in
            XCTAssertEqual(res.status, .ok)
            
            invoice = try res.content.decode(Page<Invoice>.self).items[0].id
        }
    }
    
    // MARK: - Adding fields
    mutating func addingField() throws {
        app.logger.info("[Invoice] Adding field")
        
        try app.test(.PUT, "invoices/\(invoice?.uuidString ?? "")/fields", headers: [
            "Authorization": "Bearer \(token)"
        ], beforeRequest: { req in
            try req.content.encode(InvoiceField.Create(
                                    name: "Sample item",
                                    vat: 20,
                                    price: 100
            ))
        }) { res in
            XCTAssertEqual(res.status, .ok)
            
            field = try res.content.decode(InvoiceField.self).id
        }
    }
    
    func addingFieldWithMissingData() throws {
        app.logger.info("[Invoice] Adding field with missing data")
        
        try app.test(.PUT, "invoices/\(invoice?.uuidString ?? "")/fields", headers: [
            "Authorization": "Bearer \(token)"
        ], beforeRequest: { req in
            try req.content.encode([
                "name": "Sample item"
            ])
        }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func addingFieldToWrongInvoice() throws {
        app.logger.info("[Invoice] Adding field to wrong ID")
        
        try app.test(.PUT, "invoices/ABCD-1234/fields", headers: [
            "Authorization": "Bearer \(token)"
        ], beforeRequest: { req in
            try req.content.encode(InvoiceField.Create(
                name: "Sample item",
                vat: 20,
                price: 100
            ))
        }) { res in
            XCTAssertEqual(res.status, .notFound)
        }
    }
    
    // MARK: - Getting
    func getInvoice() throws {
        app.logger.info("[Invoice] Get single invoice")
        
        try app.test(.GET, "invoices/\(invoice?.uuidString ?? "")", headers: [
            "Authorization": "Bearer \(token)"
        ]) { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    func getInvoiceWrongId() throws {
        app.logger.info("[Invoice] Get single invoice with wrong ID")
        
        try app.test(.GET, "invoices/ABCD-1234", headers: [
            "Authorization": "Bearer \(token)"
        ]) { res in
            XCTAssertEqual(res.status, .notFound)
        }
    }
    
    // MARK: - Patching field
    func patchingField() throws {
        app.logger.info("[Invoice] Patching field")
        
        try app.test(.PATCH, "invoices/\(invoice?.uuidString ?? "")/fields/\(field?.uuidString ?? "")", headers: [
            "Authorization": "Bearer \(token)"
        ], beforeRequest: { req in
            try req.content.encode(InvoiceField.Create(
                name: "Edited item name",
                vat: 10,
                price: 150
            ))
        }) { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    func patchingFieldWithMissingData() throws {
        app.logger.info("[Invoice] Patching field with missing data")
        
        try app.test(.PATCH, "invoices/\(invoice?.uuidString ?? "")/fields/\(field?.uuidString ?? "")", headers: [
            "Authorization": "Bearer \(token)"
        ], beforeRequest: { req in
            try req.content.encode([
                "name": ""
            ])
        }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func patchingFieldWithWrongId() throws {
        app.logger.info("[Invoice] Patching field with wrong ID")
        
        try app.test(.PATCH, "invoices/\(invoice?.uuidString ?? "")/fields/ABCD-1234", headers: [
            "Authorization": "Bearer \(token)"
        ], beforeRequest: { req in
            try req.content.encode([
                "name": "New item"
            ])
        }) { res in
            // Content is checked first = badRequest
            // If content is good but ID isn't = notFound
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    // MARK: - Delete field
    func deletingField() throws {
        app.logger.info("[Invoice] Delete field")
        
        try app.test(.DELETE, "invoices/\(invoice?.uuidString ?? "")/fields/\(field?.uuidString ?? "")", headers: [
            "Authorization": "Bearer \(token)"
        ]) { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    func deletingFieldWithWrongId() throws {
        app.logger.info("[Invoice] Delete field with wrong ID")
        
        try app.test(.DELETE, "invoices/\(invoice?.uuidString ?? "")/fields/ABCD-1234", headers: [
            "Authorization": "Bearer \(token)"
        ]) { res in
            XCTAssertEqual(res.status, .notFound)
        }
    }
    
    // MARK: - Patching invoice
    func patchingInvoice() throws {
        app.logger.info("[Invoice] Patching invoice")
        
        try app.test(.PATCH, "invoices/\(invoice?.uuidString ?? "")", headers: [
            "Authorization": "Bearer \(token)"
        ], beforeRequest: { req in
            try req.content.encode([
                "status": "paid",
                "type": "quote",
                "number": "02/2020",
                "statusChanged": ISO8601DateFormatter().string(from: Date())
            ])
        }) { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    func patchingInvoiceWithMissingData() throws {
        app.logger.info("[Invoice] Patching invoice with missing data")
        
        try app.test(.PATCH, "invoices/\(invoice?.uuidString ?? "")", headers: [
            "Authorization": "Bearer \(token)"
        ], beforeRequest: { req in
            try req.content.encode([
                "status": "",
                "type": ""
            ])
        }) { res in
            XCTAssertEqual(res.status, .badRequest)
        }
    }
    
    func patchingInvoiceWithMissingId() throws {
        app.logger.info("[Invoice] Patching invoice with wrong ID")
        
        try app.test(.PATCH, "invoices/ABCD-1234", headers: [
            "Authorization": "Bearer \(token)"
        ], beforeRequest: { req in
            try req.content.encode([
                "status": "paid",
                "type": "quote"
            ])
        }) { res in
            XCTAssertEqual(res.status, .notFound)
        }
    }
    
    // MARK: - Deleting invoice
    func deletingInvoice() throws {
        app.logger.info("[Invoice] Delete invoice")
        
        try app.test(.DELETE, "invoices/\(invoice?.uuidString ?? "")", headers: [
            "Authorization": "Bearer \(token)"
        ]) { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    func deletingInvoiceWithWrongId() throws {
        app.logger.info("[Invoice] Delete invoice with wrong ID")
        
        try app.test(.DELETE, "invoices/ABCD-1234", headers: [
            "Authorization": "Bearer \(token)"
        ]) { res in
            XCTAssertEqual(res.status, .notFound)
        }
    }
}
