import UIKit

protocol TransactionDeleteSelectionDelegate: AnyObject {
    func transactionToDelete(_ transactionId: Int)
}

class TransactionDetailsViewController: UIViewController {
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    weak var delegate: TransactionDeleteSelectionDelegate?
    
    var thisTransaction: Transaction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Transaction Details"
//        print("thisTransaction: \(thisTransaction)");
        
        guard let unwrappedTransaction = thisTransaction else {
            return
        }
        
        var amountText = "$" + String(format: "%.2f", unwrappedTransaction.amount)
        if(unwrappedTransaction.amount < 0) {
            amountText = "- $" + String(format: "%.2f", fabs(unwrappedTransaction.amount))
        }
        self.amountLabel.text = amountText
        self.descriptionLabel.text = unwrappedTransaction.description
    }
    
    @IBAction func deleteTransactionAction(_ sender: UIButton) {
        guard let unwrappedTransaction = thisTransaction else {
            return
        }
        
//        presentedViewController?.dismiss(animated: true, completion: nil)
        
        //dismiss when using navigation controller
        _ = navigationController?.popViewController(animated: true)
        delegate?.transactionToDelete(unwrappedTransaction.transactionId)
    }
    
}
