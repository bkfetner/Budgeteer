import UIKit

class BudgeteerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DeckCellProtocol {
    
//    struct Constants {
//        static let deckCellIdentifier = "deckCell"
//    }
    
    var budgetDeck: [Budget] = [
        Budget(budgetId: 0, name: "Bob1", balance: 2.22, transactions: [Transaction(transactionId: 1, amount: 2.22, description: "Initial Funds")]),
        Budget(budgetId: 1, name: "Bob2", balance: 4.1, transactions: [Transaction(transactionId: 1, amount: 4.1, description: "Initial Funds")]),
        Budget(budgetId: 2, name: "Bob3", balance: 6.543, transactions: [Transaction(transactionId: 1, amount: 6.543, description: "Initial Funds")]),
        Budget(budgetId: 3, name: "Bob4", balance: 8.789, transactions: [Transaction(transactionId: 1, amount: 8.789, description: "Initial Funds")]),
        Budget(budgetId: 4, name: "Bob5", balance: 10, transactions: [Transaction(transactionId: 1, amount: 10, description: "Initial Funds")]),
        Budget(budgetId: 5, name: "Bob6", balance: 12, transactions: [Transaction(transactionId: 1, amount: 12, description: "Initial Funds")]),
        Budget(budgetId: 6, name: "Bob7", balance: 14, transactions: [Transaction(transactionId: 1, amount: 14, description: "Initial Funds")]),
        Budget(budgetId: 7, name: "Bob8", balance: 16, transactions: [Transaction(transactionId: 1, amount: 16, description: "Initial Funds")]),
        Budget(budgetId: 8, name: "Bob9", balance: 18, transactions: [Transaction(transactionId: 1, amount: 18, description: "Initial Funds")]),
        Budget(budgetId: 9, name: "Bob10", balance: 15, transactions: [Transaction(transactionId: 1, amount: 20, description: "Initial Funds"), Transaction(transactionId: 2, amount: -5, description: "Cookie")])
    ]
    
    var selectedBudget: Budget?
    var newBudgetToCreate: Budget?

    @IBOutlet weak var nameNewBudgetInput: UITextField!
    @IBOutlet weak var startingAmountInput: UITextField!
    @IBOutlet weak var deckTableView: UITableView!
    @IBOutlet weak var createButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Budgeteer"
        
        deckTableView.delegate = self
        deckTableView.dataSource = self
        
//        deckTableView.register(DeckCell.self, forCellReuseIdentifier: Constants.deckCellIdentifier)
        
//        print("Constants.deckCellIdentifier: \(Constants.deckCellIdentifier)");
    }
    
    var nameNewBudget: String? {
        guard
            let userInput = nameNewBudgetInput.text
        else {
            return ""
        }
        return userInput
    }
    
    var startingAmount: Double? {
        guard
            let userInput = startingAmountInput.text,
            let newStartingAmount = Double(userInput)
        else {
            return nil
        }
        return newStartingAmount
    }
    
    @IBAction func createBudgetButtonAction(_ sender: UIButton) {
        guard let nameNewBudget: String = nameNewBudget else {
            return
        }
        guard let startingAmount: Double = startingAmount else {
            return
        }
        let newBudgetId: Int = budgetDeck[budgetDeck.count-1].budgetId+1
        let initialTransaction: Transaction = Transaction(transactionId: 1, amount: startingAmount, description: "Initial Funds")
        newBudgetToCreate = Budget(budgetId: newBudgetId, name: nameNewBudget, balance: startingAmount, transactions: [initialTransaction])
        guard let newBudgetForDeck: Budget = newBudgetToCreate else {
            return
        }
        budgetDeck.append(newBudgetForDeck)
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
        
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell") as? TripCell else {
//            return UITableViewCell()
//        }
        
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
        if selectedBudget == nil {
            return false
        }
        return true
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let stationPickerVC = segue.destination as? StationPickerViewController {
//            stationPickerVC.delegate = self
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let unwrappedBudget = selectedBudget else {
            return
        }
        
        if let currentBudgetVC = segue.destination as? CurrentBudgetViewController {
            currentBudgetVC.thisBudget = unwrappedBudget
//            currentBudgetVC.delegate = self
        }
        
//        if segue.destination is CurrentBudgetViewController {
//            let currentBudgetVC = segue.destination as? CurrentBudgetViewController
//            currentBudgetVC?.thisBudget = unwrappedBudget
//        }
    }
}

