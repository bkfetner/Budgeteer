import UIKit

protocol BudgeteerStore {
    func storeBudget(budget: Budget)
    func updateBudgetBalance(_ budgetId: Int, balance: Double)
    func getAllBudgetItems() -> [Budget]
    func storeTransaction(transaction: Transaction)
    func deleteTransaction(_ budgetId: Int, _ transactionId: Int)
}

class BudgeteerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DeckCellProtocol, CurrentBudgetDeleteTransactionDelegate {
    
    @IBOutlet weak var nameNewBudgetInput: UITextField!
    @IBOutlet weak var startingAmountInput: UITextField!
    @IBOutlet weak var deckTableView: UITableView!
    @IBOutlet weak var createButtonOutlet: UIButton!
    @IBOutlet weak var invalidNameOutlet: UILabel!
    @IBOutlet weak var invalidAmountOutlet: UILabel!
    
    let store: BudgeteerStore = CoreDataStore()
    
    var budgetDeck: [Budget] = []
    
    var selectedBudget: Budget?
    var newBudgetToCreate: Budget?
    var createButtonPressed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        budgetDeck = store.getAllBudgetItems()
        
        navigationItem.title = "Budgeteer"
        
        deckTableView.delegate = self
        deckTableView.dataSource = self
    }
    
    @IBAction func createBudgetButtonAction(_ sender: UIButton) {
        createButtonPressed = true
        
        guard
            let nameNewBudget: String = nameNewBudgetInput.text,
            let stringStartingamount = startingAmountInput.text,
            let startingAmount: Double = Double(stringStartingamount)
        else {
            print("Before return")
            return
        }
        
        var newBudgetId: Int = 0
        if budgetDeck.count > 0 {
            newBudgetId = budgetDeck[budgetDeck.count-1].budgetId+1
        }
        let initialTransaction: Transaction = Transaction(transactionId: 1, budgetId: newBudgetId, amount: startingAmount, description: "Initial Funds")
        newBudgetToCreate = Budget(budgetId: newBudgetId, name: nameNewBudget, balance: startingAmount, transactions: [initialTransaction])
        guard let newBudgetForDeck: Budget = newBudgetToCreate else {
            return
        }
        budgetDeck.append(newBudgetForDeck)
        store.storeBudget(budget: newBudgetForDeck)
        store.storeTransaction(transaction: initialTransaction)
        selectedBudget = budgetDeck[newBudgetId]
        
        let lastItemIndex = budgetDeck.count - 1
        let newItmeIndexPath = IndexPath(row: lastItemIndex, section: 0)
        deckTableView.beginUpdates()
        deckTableView.insertRows(at: [newItmeIndexPath], with: .fade)
        deckTableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return budgetDeck.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowNumberToDisplay = indexPath.row
        
        guard let cell = deckTableView.dequeueReusableCell(withIdentifier: "DeckCell") as? DeckCell else {
            return UITableViewCell()
        }
        let deckSlot = budgetDeck[rowNumberToDisplay]
        cell.updateDeck(with: deckSlot.budgetId, and: deckSlot.name, and: deckSlot.balance)
        
        cell.delegate = self
        
        return cell
    }
    
    func budgetSelected(_ budgetSelected: DeckCell, deckButtonAction budgetId: Int) {
        if budgetId > -1 {
            for i in 0..<budgetDeck.count {
                if budgetId == budgetDeck[i].budgetId {
                    selectedBudget = budgetDeck[i]
                    break
                }
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if createButtonPressed {
            createButtonPressed = false
            guard let testBudgetName = nameNewBudgetInput.text,
                  testBudgetName.count > 0
            else {
                invalidNameOutlet.isHidden = false
                return false
            }
            
            guard let testStartingAmount = startingAmountInput.text,
                  let _: Double = Double(testStartingAmount)
            else {
                invalidAmountOutlet.isHidden = false
                return false
            }
        }
        
        nameNewBudgetInput.text = nil
        startingAmountInput.text = nil
        invalidNameOutlet.isHidden = true
        invalidAmountOutlet.isHidden = true
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let unwrappedBudget = selectedBudget else {
            return
        }
        
        if let currentBudgetVC = segue.destination as? CurrentBudgetViewController {
            currentBudgetVC.thisBudget = unwrappedBudget
            currentBudgetVC.delegate = self
        }
    }
    
    func deleteTransaction(_ transactionId: Int, _ newBalance: Double) {
        for i in 0..<budgetDeck.count {
            if budgetDeck[i].budgetId == selectedBudget?.budgetId {
                guard let unwrappedTransaction = budgetDeck[i].transactions else {
                    return
                }
                for j in 0..<unwrappedTransaction.count {
                    if unwrappedTransaction[j].transactionId == transactionId {
                        budgetDeck[i].transactions?.remove(at: j)
                        print("unwrappedTransaction[j]: \n\(unwrappedTransaction[j])")
                        store.deleteTransaction(unwrappedTransaction[j].budgetId, unwrappedTransaction[j].transactionId)
                        budgetDeck[i].balance = newBalance
                        store.updateBudgetBalance(budgetDeck[i].budgetId, balance: newBalance)
                        break
                    }
                }
            }
        }
        deckTableView.reloadData()
    }
    
    func addTransaction(_ newTransaction: Transaction, _ newBalance: Double) {
        for i in 0..<budgetDeck.count {
            if budgetDeck[i].budgetId == selectedBudget?.budgetId {
                budgetDeck[i].transactions?.append(newTransaction)
                store.storeTransaction(transaction: newTransaction)
                budgetDeck[i].balance = newBalance
                store.updateBudgetBalance(budgetDeck[i].budgetId, balance: newBalance)
                break
            }
        }
        deckTableView.reloadData()
    }
}

