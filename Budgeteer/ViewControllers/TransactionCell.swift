import UIKit

class TransactionCell: UITableViewCell {
    
    @IBOutlet weak var transactionAmount: UILabel!
    
    func update(with updateTransactionAmount: Double, and updateTransactionDescription: String) {
        var stringTransactionAmount = "+  $\(updateTransactionAmount)"
        if(updateTransactionAmount < 0) {
            stringTransactionAmount = "-  $\(fabs(updateTransactionAmount))"
        }
        
        print("transactionAmount: \(transactionAmount)")
    }
}
