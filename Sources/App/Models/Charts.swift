//
//  Charts.swift
//  
//
//  Created by Victor Lourme on 19/09/2020.
//

import Vapor
import Fluent

struct Charts: Content {
    // Daily invoices
    var daily: [String: Int]
    
    // Number of invoices
    var invoices: InvoiceStats
    
    // Prices
    var prices: InvoicePrices
    
    // Number of clients
    var customers: Int = 0
}

struct InvoiceStats: Content {
    // Total number of invoice
    var total: Int = 0
    
    // Number of invoice waiting payment
    var waiting: Int = 0
    
    // Number of paid invoices
    var paid: Int = 0
    
    // Number of canceled invoices
    var canceled: Int = 0
}

struct InvoicePrices: Content {
    // Money waiting
    var waiting = InvoicePrice()
    
    // Money paid
    var paid = InvoicePrice()
    
    // Money not paid from canceled invoices
    var canceled = InvoicePrice()
}

struct InvoicePrice: Content {
    var value: Double = 0
    var total: Double = 0
    var tax: Double = 0
}
