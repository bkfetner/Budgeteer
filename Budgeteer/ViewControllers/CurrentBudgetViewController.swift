import UIKit

class CurrentBudgetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TransactionDeleteSelectionDelegate {
    
//    struct Constants {
//        static let transactionCellIdentifier = "transactionCell"
//    }
    
    var thisBudget: Budget?
    var selectedTransaction: Transaction?
    
    @IBOutlet weak var currentBalanceAmount: UILabel!
//    @IBOutlet weak var transactionTableView: UITableView!
    @IBOutlet weak var transactionTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transactionTableView.delegate = self
        transactionTableView.dataSource = self
        
//        transactionTableView.register(TransactionCell.self, forCellReuseIdentifier: "TransactionCell")
        
        guard let unwrappedThisBudget = thisBudget else {
            return
        }
        
        navigationItem.title = unwrappedThisBudget.name
        updateCurrentBalanceAmountLabel()
//        print("unwrappedThisBudget in viewdidload: \(unwrappedThisBudget)");
        
//        transactionTableView.register(TransactionCell.self, forCellReuseIdentifier: "TransactionCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard
            let unwrappedThisBudget = thisBudget,
            let unwrappedTransactions = unwrappedThisBudget.transactions
        else {
            return -1
        }
        return unwrappedTransactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowNumberToDisplay = indexPath.row
        
        guard let cell = transactionTableView.dequeueReusableCell(withIdentifier: "TransactionCell") as? TransactionCell else {
            return UITableViewCell()
        }
        guard
            let unwrappedThisBudget = thisBudget,
            let unwrappedTransactions = unwrappedThisBudget.transactions
        else {
//            print("else")
            return UITableViewCell()
        }
//        print("unwrappedTransactions: \(unwrappedTransactions)")
        let transactionSlot = unwrappedTransactions[rowNumberToDisplay]
        
        var sign = "+"
        let amountDouble = transactionSlot.amount
        var amountString = String(format: "%.2f", amountDouble)
        if(amountDouble < 0) {
            sign = "-"
            amountString = String(format: "%.2f", fabs(amountDouble))
        }
        
        let textForLabel = sign + "  $" + amountString + "          " + transactionSlot.description
        
//        cell.textLabel?.text = textForLabel
        cell.update(with: transactionSlot.amount, and: transactionSlot.description)
        
//        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowNumberSelected = indexPath.row
        guard
            let unwrappedThisBudget = thisBudget,
            let unwrappedTransactions = unwrappedThisBudget.transactions
        else {
            return
        }
        selectedTransaction = unwrappedTransactions[rowNumberSelected]
        performSegue(withIdentifier: "CurrentToTransactionSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let unwrappedTransaction = selectedTransaction else {
            return
        }
        
        if let transactionDetailsVC = segue.destination as? TransactionDetailsViewController {
            transactionDetailsVC.thisTransaction = unwrappedTransaction
            transactionDetailsVC.delegate = self
        }
    }
    
    func transactionToDelete(_ transactionId: Int) {
        print("transactionToDelete");
        print("thisBudget: \(thisBudget)");
        
        guard
            let unwrappedThisBudget = thisBudget,
            let unwrappedTransactions = unwrappedThisBudget.transactions
        else {
            return
        }
        
        var elementToDelete = -1
        if unwrappedTransactions.count > 0 {
            for i in 0..<unwrappedTransactions.count {
                if transactionId == unwrappedTransactions[i].transactionId {
                    elementToDelete = i
                    break
                }
            }
        }
        
        thisBudget?.transactions?.remove(at: elementToDelete)
        
        guard
            let unwrappedThisBudget = thisBudget,
            let unwrappedTransactions = unwrappedThisBudget.transactions
        else {
            return
        }
        var newBalance: Double = 0.00
        for i in 0..<unwrappedTransactions.count {
            newBalance += unwrappedTransactions[i].amount
        }
        
        print("newBalance: \(newBalance)")
        thisBudget?.balance = newBalance
        transactionTableView.reloadData()
        updateCurrentBalanceAmountLabel()
        print("thisBudget: \(thisBudget)");
    }
    
    func updateCurrentBalanceAmountLabel() {
        guard let unwrappedThisBudget = thisBudget else {
            return
        }
        currentBalanceAmount.text = "$" + String(format: "%.2f", unwrappedThisBudget.balance)
    }
}
