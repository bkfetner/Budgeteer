import UIKit

struct Budget {
    var budgetId: Int
    var name: String
    var balance: Double
    var transactions: [Transaction]?
}

struct Transaction {
    var transactionId: Int
    var amount: Double
    var description: String
}
