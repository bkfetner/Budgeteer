import UIKit

protocol CurrentBudgetDeleteTransactionDelegate: AnyObject {
    func deleteTransaction(_ transactionId: Int, _ newBalance: Double)
    func addTransaction(_ newTransaction: Transaction, _ newBalance: Double)
}

class CurrentBudgetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TransactionDeleteSelectionDelegate, AddTransactionDelegate {
    
    @IBOutlet weak var currentBalanceAmount: UILabel!
    @IBOutlet weak var transactionTableView: UITableView!
    
    weak var delegate: CurrentBudgetDeleteTransactionDelegate?
    
    var thisBudget: Budget?
    var selectedTransaction: Transaction?
    var addPositiveFunds: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transactionTableView.delegate = self
        transactionTableView.dataSource = self
        
        guard let unwrappedThisBudget = thisBudget else {
            return
        }
        navigationItem.title = unwrappedThisBudget.name
        updateCurrentBalanceAmountLabel()
    }
    
    @IBAction func addFundsButtonAction(_ sender: UIButton) {
        addPositiveFunds = true
    }
    
    @IBAction func addExpenseButtonAction(_ sender: UIButton) {
        addPositiveFunds = false
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
            return UITableViewCell()
        }
        
        let transactionSlot = unwrappedTransactions[rowNumberToDisplay]
        cell.update(with: transactionSlot.amount, and: transactionSlot.description)
        
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
        if let transactionDetailsVC = segue.destination as? TransactionDetailsViewController {
            guard let unwrappedTransaction = selectedTransaction else {
                return
            }
            transactionDetailsVC.thisTransaction = unwrappedTransaction
            transactionDetailsVC.delegate = self
        }
        
        if let addFundsVC = segue.destination as? AddTransactionViewController {
            addFundsVC.addPositiveFunds = addPositiveFunds
            addFundsVC.delegate = self
        }
    }
    
    func transactionToDelete(_ transactionId: Int) {
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
        
        updateBudgetBalance()
        transactionTableView.reloadData()
        
        guard let unwrappedBalance: Double = thisBudget?.balance else {
            return
        }
        delegate?.deleteTransaction(transactionId, unwrappedBalance)
    }
    
    func addTransaction(_ amountToAdd: Double, _ description: String) {
        guard
            let unwrappedThisBudget = thisBudget,
            let unwrappedTransactions = unwrappedThisBudget.transactions
        else {
            return
        }
        
        var newTransactionId = 0;
        if unwrappedTransactions.count > 0 {
            newTransactionId = unwrappedTransactions[unwrappedTransactions.count-1].transactionId + 1
        }
        let newTransaction: Transaction = Transaction(transactionId: newTransactionId, budgetId: unwrappedThisBudget.budgetId, amount: amountToAdd, description: description)
        
        thisBudget?.transactions?.append(newTransaction)
        
        updateBudgetBalance()
        transactionTableView.reloadData()
        
        guard let unwrappedBalance: Double = thisBudget?.balance else {
            return
        }
        delegate?.addTransaction(newTransaction, unwrappedBalance)
    }
    
    func updateBudgetBalance() {
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
        
        thisBudget?.balance = newBalance
        updateCurrentBalanceAmountLabel()
    }
    
    func updateCurrentBalanceAmountLabel() {
        guard let unwrappedThisBudget = thisBudget else {
            return
        }
        if unwrappedThisBudget.balance < 0 {
            currentBalanceAmount.text = "- $" + String(format: "%.2f", fabs(unwrappedThisBudget.balance))
        } else {
            currentBalanceAmount.text = "$" + String(format: "%.2f", unwrappedThisBudget.balance)
        }
    }
}
