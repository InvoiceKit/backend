//
//  CustomerController.swift
//
//
//  Created by Victor Lourme on 02/09/2020.
//

import Fluent
import Vapor

struct ChartsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        // Default /charts
        let root = routes.grouped("charts").grouped(Team.JWTPayload.guardMiddleware())
        
        // Get charts /charts
        root.get(use: getCharts)
    }
    
    func getCharts(req: Request) throws -> EventLoopFuture<Charts> {
        // Get team
        let payload = try req.auth.require(Team.JWTPayload.self)
        
        // Generate charts
        var charts = Charts(invoices: InvoiceStats(), prices: InvoicePrices())
        
        // Add customers
        let _ = Customer.query(on: req.db)
            .filter(\._parent.$id == payload.teamID)
            .count()
            .whenSuccess { count in
                charts.customers = count
            }
        
        // Get invoices
        return Invoice.eagerLoadedQuery(on: req.db)
            .filter(\._parent.$id == payload.teamID)
            .all()
            .mapEach { invoice in
                // Get output
                let output = invoice.output
                
                // Assign to charts
                switch output.status {
                    case .paid:
                        charts.invoices.paid += 1
                        charts.prices.paid.value += output.total
                        charts.prices.paid.tax += output.vat
                    case .waiting:
                        charts.invoices.waiting += 1
                        charts.prices.waiting.value += output.total
                        charts.prices.waiting.tax += output.vat
                    case .canceled:
                        charts.invoices.canceled += 1
                        charts.prices.canceled.value += output.total
                        charts.prices.canceled.tax += output.vat
                }
                
                // Add to total
                charts.invoices.total += 1
            }
            .transform(to: charts)
    }
}
