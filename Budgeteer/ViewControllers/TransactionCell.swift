import UIKit

class TransactionCell: UITableViewCell {
    
    @IBOutlet weak var transactionAmount: UILabel!
    @IBOutlet weak var transactionDescription: UILabel!
    
    func update(with updateTransactionAmount: Double, and updateTransactionDescription: String) {
        var stringTransactionAmount = "+  $\(String(format: "%.2f", updateTransactionAmount))"
        if(updateTransactionAmount < 0) {
            stringTransactionAmount = "-  $\(String(format: "%.2f", fabs(updateTransactionAmount)))"
        }

        transactionAmount.text = stringTransactionAmount
        transactionDescription.text = updateTransactionDescription
    }
}
